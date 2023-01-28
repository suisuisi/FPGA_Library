
-------------------------------------------------------------------------------
--
-- File: ConfigDAC.vhd
-- Author: Tudor Gherman
-- Original Project: ZmodAWG1411_Controller
-- Date: 15 January 2020
--
-------------------------------------------------------------------------------
-- (c) 2020 Copyright Digilent Incorporated
-- All Rights Reserved
-- 
-- This program is free software; distributed under the terms of BSD 3-clause 
-- license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
--    of its contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
--
-- This module writes an intial configuration into the DAC registers and then
-- manages the optional SPI Indirect Access Port.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PkgZmodDAC.all;

entity ConfigDAC is
   generic (
      --The number of data bits for the data phase of the SPI transaction: 
      --only 8 data bits currently supported.
      kDataWidth : integer range 8 to 8 := 8;
      -- The number of bits of the command phase of the SPI transaction.
      kCommandWidth : integer range 8 to 8 := 8
   );
   Port (
      -- 100MHZ clock input.
      SysClk100 : in  std_logic;
      -- Asynchronous active low reset. 
      asRst_n : in std_logic;
      -- Initialization done active low indicator. 
      sInitDoneDAC : out std_logic := '0'; 
      -- DAC initialization error signaling. 
      sConfigError : out STD_LOGIC := '0'; 
       
      -- SPI Indirect access port; it provides the means to indirectly access
      -- the DAC registers. It is designed to interface with 2 AXI StreamFIFOs, 
      -- one that stores commands to be transmitted and one to store the received data.
      
      -- TX command AXI stream interface
      sCmdTxAxisTvalid: IN STD_LOGIC;
      sCmdTxAxisTready: OUT STD_LOGIC := '0';
      sCmdTxAxisTdata: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      -- RX command AXI stream interface
      sCmdRxAxisTvalid: OUT STD_LOGIC := '0';
      sCmdRxAxisTready: IN STD_LOGIC;
      sCmdRxAxisTdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);    
       
      -- AD9717 SPI interface
      
      sZmodDAC_CS : out std_logic;
      sZmodDAC_SCLK : out std_logic;
      sZmodDAC_SDIO : inout std_logic 
      );
end ConfigDAC;

architecture Behavioral of ConfigDAC is

signal sInitDoneDAC_Fsm : std_logic := '0';
signal sConfigErrorFsm : std_logic;

signal sCurrentState, sNextState : FsmStates_t;
-- signals used for debug purposes
-- signal fsmcfg_state, DAC_FSM_STATE_R : std_logic_vector(5 downto 0); 
signal sCmdCnt : unsigned(4 downto 0);
signal sCmdCntInt : integer range 0 to 31;
signal sIncCmdCnt, sRstCmdCnt_n : std_logic;
-- SPI Interface signals
signal sDAC_SPI_ApStartR, sDAC_SPI_ApStart :std_logic; 
signal sDAC_SPI_RdWr, sDAC_SPI_RdWrR :std_logic;
signal sDAC_SPI_Done :std_logic; 
signal sDAC_SPI_Busy :std_logic; 
signal sDAC_SPI_RdData, sDAC_SPI_WrData, sDAC_SPI_WrDataR : std_logic_vector (7 downto 0);
signal sDAC_SPI_Width, sDAC_SPI_WidthR : std_logic_vector (1 downto 0);
signal sDAC_SPI_Addr, sDAC_SPI_AddrR : std_logic_vector (4 downto 0);
--External Command FIFO Interface
signal sLdCmdTxData: std_logic;
signal sCmdTxDataReg: std_logic_vector(23 downto 0);
signal sCmdTxAxisTreadyLoc: std_logic;
signal sCmdRxAxisTvalidLoc: std_logic;
signal sCmdRxAxisTdataLoc :  STD_LOGIC_VECTOR(7 DOWNTO 0);                                              

--Timers
signal sCfgTimer : unsigned (23 downto 0);
signal sCfgTimerRst_n : std_logic;
    
begin
           
----------------------------Zmod Configuration-----------------------------------------------------------------------------------------

-- Instantiate the SPI controller.
DAC_SPI_inst: entity work.ADI_SPI
Generic Map(
        kSysClkDiv => kSPI_SysClkDiv, 
        kDataWidth => kDataWidth,
        kCommandWidth => kCommandWidth
) 
Port Map( 
    --
    SysClk100 => SysClk100,
    asRst_n => asRst_n,
    sSPI_Clk => sZmodDAC_Sclk,
    sSDIO => sZmodDAC_SDIO,
    sCS => sZmodDAC_CS,
    sApStart => sDAC_SPI_ApStartR,
    sRdData => sDAC_SPI_RdData,
    sWrData => sDAC_SPI_WrDataR,
    sAddr => sDAC_SPI_AddrR,
    sWidth => sDAC_SPI_WidthR, --tested only for width = "00"
    sRdWr => sDAC_SPI_RdWrR,
    sDone => sDAC_SPI_Done,
    sBusy => sDAC_SPI_Busy
    ); 

-- Register the SPI controller inputs.
ProcSPI_ControllerRegister: process (SysClk100, asRst_n)
begin
   if (asRst_n = '0') then
      sDAC_SPI_RdWrR <= '0';
      sDAC_SPI_WrDataR <= (others => '0');
      sDAC_SPI_AddrR <= (others => '0');
      sDAC_SPI_WidthR <= (others => '0');
      sDAC_SPI_ApStartR <= '0';
   elsif (rising_edge(SysClk100)) then
      sDAC_SPI_RdWrR <= sDAC_SPI_RdWr;
      sDAC_SPI_WrDataR <= sDAC_SPI_WrData;
      sDAC_SPI_AddrR <= sDAC_SPI_Addr;
      sDAC_SPI_WidthR <= sDAC_SPI_Width;
      sDAC_SPI_ApStartR <= sDAC_SPI_ApStart;       
   end if;
end process;

-- Register the SPI Indirect Access Port receive interface outputs.
ProcRxExtFIFO_Reg: process (SysClk100, asRst_n) 
begin
   if (asRst_n = '0') then
      sCmdRxAxisTvalid <= '0';
      sCmdRxAxisTdata <= (others => '0');
   elsif (rising_edge(SysClk100)) then
      sCmdRxAxisTvalid <= sCmdRxAxisTvalidLoc;
      sCmdRxAxisTdata <= x"000000" & sCmdRxAxisTdataLoc;       
   end if;
end process; 

-- Register the SPI Indirect Access Port transmit interface outputs. 
ProcCmdAxisTreadyReg: process (SysClk100, asRst_n)  
begin
   if (asRst_n = '0') then
      sCmdTxAxisTready <= '0';
   elsif (rising_edge(SysClk100)) then
      sCmdTxAxisTready <= sCmdTxAxisTreadyLoc;  
    end if;
end process;

-- Register the next SPI Indirect Access Port command on the transmit
-- interface when the configuration state machine is capable of processing it. 
ProcLdCmdTxData: process (SysClk100, asRst_n) 
begin
   if (asRst_n = '0') then
      sCmdTxDataReg <= (others => '0');
   elsif (rising_edge(SysClk100)) then
        if (sLdCmdTxData = '1') then
           sCmdTxDataReg <= sCmdTxAxisTdata(23 downto 0);
        end if;
    end if;
end process;

ProcCmdConter: process (SysClk100, asRst_n)  -- Succesfully sent SPI command counter
begin
   if (asRst_n = '0') then
      sCmdCnt <= (others => '0');
   elsif (rising_edge(SysClk100)) then
      if (sRstCmdCnt_n = '0') then
         sCmdCnt <= (others => '0');
      else
         if (sIncCmdCnt = '1') then
            sCmdCnt <= sCmdCnt + 1;
          end if;
       end if;        
   end if;
end process;

sCmdCntInt <= to_integer(sCmdCnt);

-- Timer used to determine timeout conditions for SPI transfers.
-- When a command is sent to the DAC a certain amount of time is allowed for the state
-- machine to read back the expected value in order to make sure the register was correctly
-- configured. Some commands do not take effect immediately, so this mechanism is necessary
-- (SPI Port Config register (address 0x00) soft reset write for example).
ProcCfgTimer: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sCfgTimer <= (others =>'0');
   elsif (rising_edge(SysClk100)) then
      if (sCfgTimerRst_n = '0') then
         sCfgTimer <= (others =>'0');
      else
         sCfgTimer <= sCfgTimer + 1;     
      end if;
   end if;
end process;

------------------------------------------------------------------------------------------
-- Configuration state machine
------------------------------------------------------------------------------------------    

-- State machine synchronous process
ProcFsmSync: process (SysClk100, asRst_n)
begin
   if (asRst_n = '0') then
      sCurrentState <= StStart;
      --DAC_FSM_STATE_R <= (others => '0');
   elsif (rising_edge(SysClk100)) then
      sCurrentState <= sNextState;
      --DAC_FSM_STATE_R <= fsmcfg_state;
   end if;        
end process;

-- Next State an output decode     
procNextStateAndOutput: process (sCurrentState, sCmdCntInt, sDAC_SPI_Done, sDAC_SPI_RdData, 
sCmdTxAxisTvalid, sCmdTxAxisTdata, sCmdTxDataReg, sCmdRxAxisTready, sDAC_SPI_Busy, sCfgTimer)
begin         
   sNextState <= sCurrentState;  
   --fsmcfg_state <= "000000";
   sRstCmdCnt_n <= '0';
   sIncCmdCnt <= '0';
         
   sDAC_SPI_ApStart <= '0';
   sDAC_SPI_WrData <= (others => '0');
   sDAC_SPI_Addr <= (others => '0');
   sDAC_SPI_Width <= (others => '0');
   sDAC_SPI_RdWr <= '0';
   sCmdTxAxisTreadyLoc <= '0';
   sCmdRxAxisTvalidLoc  <= '0';
   sCmdRxAxisTdataLoc  <= (others => '0');
   sLdCmdTxData <= '0';

   sCfgTimerRst_n <= '0';
   sInitDoneDAC_Fsm <= '0';
   sConfigErrorFsm <= '0';                                
         
   case (sCurrentState) is
      when StStart =>
         --fsmcfg_state <= "000000";
         sNextState <= StWriteConfigReg;              

      -- Perform a register write operation for the sCmdCntInt'th command in the queue.
      -- For some sCmdCntInt only register reads are required.                  
      when StWriteConfigReg =>
         --fsmcfg_state <= "000001"; 
         sRstCmdCnt_n <= '1';
         if (sCmdCntInt = kCmdRdCalstatIndex) then
            sNextState <= StReadControlReg; 
         else
            if (sDAC_SPI_Busy = '0') then
               sDAC_SPI_ApStart <= '1';                
               sDAC_SPI_WrData <= kDAC_SPI_Cmd(sCmdCntInt)(7 downto 0);--x"84";               
               sDAC_SPI_Addr <= kDAC_SPI_Cmd(sCmdCntInt)(12 downto 8);--"00010";                  
               sDAC_SPI_Width <= "00";
               sNextState <= StWaitDoneWriteReg;  
            end if;
         end if;
         
         -- Wait for register write command to be completed                      
         when StWaitDoneWriteReg => 
            --fsmcfg_state <= "000010";
            sRstCmdCnt_n <= '1';
            sCfgTimerRst_n <= '1';
            if (sDAC_SPI_Done = '1') then
               sNextState <= StReadControlReg; 
            end if;
            
         -- Read back the register value configured in the StWriteControlReg state.
         when StReadControlReg => 
            --fsmcfg_state <= "000011";
            sRstCmdCnt_n <= '1';
            sCfgTimerRst_n <= '1';
            if (sDAC_SPI_Busy = '0') then
               sDAC_SPI_ApStart <= '1';
               sDAC_SPI_Addr <= kDAC_SPI_Cmd(sCmdCntInt)(12 downto 8);
               sDAC_SPI_Width <= "00";
               sDAC_SPI_RdWr <= '1';
               sNextState <= StWaitDoneReadReg;
            end if; 
         
         -- Wait for SPI command to be completed and compare the read data against 
         -- the expected value.  
         when StWaitDoneReadReg => 
            --fsmcfg_state <= "000100";
            sRstCmdCnt_n <= '1';
            sCfgTimerRst_n <= '1';
            if (sDAC_SPI_Done = '1') then
               if ((sDAC_SPI_RdData or DAC_SPI_mask(sCmdCntInt)) = (kDAC_SPI_Cmd(sCmdCntInt)(7 downto 0) or DAC_SPI_mask(sCmdCntInt))) then
                  sNextState <= StCheckCmdCnt;
               elsif (sCfgTimer >= kCfgTimeout) then 
                  sNextState <= StError;
               else
                  sNextState <= StReadControlReg;
               end if;
            end if;                           

         -- Check if the command sequence has completed.
         when StCheckCmdCnt =>
            --fsmcfg_state <= "000101";
            sRstCmdCnt_n <= '1';
            if (sCmdCntInt = kCmdTotal) then
               sNextState <= StInitDone;
               sRstCmdCnt_n <= '0';
            else
               sIncCmdCnt <= '1';
               sNextState <= StWriteConfigReg;       
            end if;    
         
         -- Indicate that the initialization sequence has completed.                                                   
         when StInitDone => 
            --fsmcfg_state <= "000110";
            sInitDoneDAC_Fsm <= '1';
            sNextState <= StIdle;

         -- IDLE state; wait for changes on the SPI Indirect Access Port.
         when StIdle => 
            --fsmcfg_state <= "000111";
            sInitDoneDAC_Fsm <= '1';
            if ((sCmdTxAxisTvalid = '1') and (sDAC_SPI_Busy = '0')) then
               sLdCmdTxData <= '1';
               if (sCmdTxAxisTdata(23) = '0') then
                  sNextState <= StExtSPI_WrCmd; 
               else
                  sNextState <= StExtSPI_RdCmd; 
               end if; 
            end if;
         
         -- Execute the register write command requested on the SPI Indirect Access Port.                       
         when StExtSPI_WrCmd =>  
            --fsmcfg_state <= "001000";
            sInitDoneDAC_Fsm <= '1';
            sDAC_SPI_ApStart <= '1';
            sDAC_SPI_WrData <= sCmdTxDataReg(7 downto 0);
            sDAC_SPI_Addr <= sCmdTxDataReg(12 downto 8);
            sDAC_SPI_Width <= sCmdTxDataReg(22 downto 21);
            sDAC_SPI_RdWr  <= '0';
            sNextState <= StWaitDoneExtWrReg;  
         
         -- Wait for the register write command to complete   
         when StWaitDoneExtWrReg => 
            --fsmcfg_state <= "001001";
            sInitDoneDAC_Fsm <= '1';
            if (sDAC_SPI_Done = '1') then
               sCmdTxAxisTreadyLoc <= '1';
               sNextState <= StIdle;
            end if;
         
         -- Execute the register read command requested on the SPI Indirect Access Port.                                  
         when StExtSPI_RdCmd =>  
            --fsmcfg_state <= "001010";
            sInitDoneDAC_Fsm <= '1';
            sDAC_SPI_ApStart <= '1';
            sDAC_SPI_Addr <= sCmdTxDataReg(12 downto 8);
            sDAC_SPI_Width <= sCmdTxDataReg(22 downto 21);
            sDAC_SPI_RdWr <= '1';
            sNextState <= StWaitDoneExtRdReg;
         
         -- Wait for the register read command to complete.  
         when StWaitDoneExtRdReg => 
            --fsmcfg_state <= "001011";
            sInitDoneDAC_Fsm <= '1';
            if (sDAC_SPI_Done = '1') then
               sCmdTxAxisTreadyLoc <= '1';
               sNextState <= StRegExtRxData;
            end if;
         
         -- State used to register the incoming SPI data.       
         when StRegExtRxData => 
            --fsmcfg_state <= "001100";
            sInitDoneDAC_Fsm <= '1';
            sCmdRxAxisTvalidLoc  <= '1';
            sCmdRxAxisTdataLoc  <= sDAC_SPI_RdData;
            if (sCmdRxAxisTready = '1') then
               sNextState <= StIdle;
            end if;  
             
         -- When an error condition is detected the state machine stalls in this state.
         -- An external reset condition is necessary to exit this state.                                   
         when StError => 
            --fsmcfg_state <= "111111";
            sConfigErrorFsm <= '1';
            report "DAC Configuration readback error." & LF & HT & HT 
            severity ERROR;
                                       
            when others =>
                sNextState <= StStart;
         end case;      
      end process; 

-- Register FSM output flags.      
ProcInitDone: process (SysClk100, asRst_n) 
begin
   if (asRst_n = '0') then
      sInitDoneDAC <= '0';
      sConfigError <= '0';
   elsif (rising_edge (SysClk100)) then
      sInitDoneDAC <= sInitDoneDAC_Fsm;  
      sConfigError <= sConfigErrorFsm;
   end if;
end process;

end Behavioral;
