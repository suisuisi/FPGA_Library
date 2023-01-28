
-------------------------------------------------------------------------------
--
-- File: AD9717_RegisterDecode.vhd
-- Author: Tudor Gherman
-- Original Project: ZmodAWG1411_Controller
-- Date: 11 Dec. 2020
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
-- This module implements the register set for the AD9717 simulation model
--  
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.PkgZmodDAC.all;

entity AD9717_RegisterDecode is
   Generic (
      -- Parameter identifying the Zmod:     
      -- 7 -> Zmod AWG 1411 - (AD9717)
      kZmodID : integer range 7 to 7 := 7;
      -- Register address width
      kAddrWidth : integer range 0 to 32 := 5;
      -- Register data width: only 8 data bits currently supported
      kRegDataWidth : integer range 0 to 32 := 8
   );
   Port (   
      -- 100MHZ clock input
      SysClk100 : in STD_LOGIC;
      -- Reset signal asynchronously asserted and synchronously 
      -- de-asserted (in SysClk100 domain) 
      asRst_n : in STD_LOGIC;
      -- When InsertError is asserted the model produces an erroneous reading for register address x01
      InsertError : in STD_LOGIC;  
      -- Signal indicating that the data phase of he register write SPI transaction is completed and aDataDecode is valid      
      sDataWriteDecodeReady : in STD_LOGIC;
      -- Signal indicating that the address phase of the SPI transaction is completed and aAddrDecode is valid
      sAddrDecodeReady : in STD_LOGIC;
      -- Input register data used to update internal egister values for write register operations
      sDataDecode : in STD_LOGIC_VECTOR (kRegDataWidth-1 downto 0); 
      -- Register address input 
      sAddrDecode : in STD_LOGIC_VECTOR (kAddrWidth-1 downto 0);
      -- Output register data produced by this module upon address decode for register read operations
      sRegDataOut : out STD_LOGIC_VECTOR (kRegDataWidth-1 downto 0)
   );
end AD9717_RegisterDecode;

architecture Behavioral of AD9717_RegisterDecode is

signal sAddrDecodeReadyPulse, sAddrDecodeReadyDly : std_logic := '0';
signal sDataWriteDecodeReadyPulse, sDataWriteDecodeReadyDly : std_logic := '0';
signal sReg00 : std_logic_vector(7 downto 0) := x"00";
signal sReg01 : std_logic_vector(7 downto 0) := x"40";
signal sReg02 : std_logic_vector(7 downto 0) := x"34";
signal sReg03 : std_logic_vector(7 downto 0) := x"00";
signal sReg04 : std_logic_vector(7 downto 0) := x"00";
signal sReg05 : std_logic_vector(7 downto 0) := x"00";
signal sReg06 : std_logic_vector(7 downto 0) := x"00";
signal sReg07 : std_logic_vector(7 downto 0) := x"00";
signal sReg08 : std_logic_vector(7 downto 0) := x"00";
signal sReg09 : std_logic_vector(7 downto 0) := x"00";
signal sReg0A : std_logic_vector(7 downto 0) := x"00";
signal sReg0B : std_logic_vector(7 downto 0) := x"00";
signal sReg0C : std_logic_vector(7 downto 0) := x"00";
signal sReg0D : std_logic_vector(7 downto 0) := x"00";
signal sReg0E : std_logic_vector(7 downto 0) := x"00";
signal sReg0F : std_logic_vector(7 downto 0) := x"00";
signal sReg10 : std_logic_vector(7 downto 0) := x"00";
signal sReg11 : std_logic_vector(7 downto 0) := x"34";
signal sReg12 : std_logic_vector(7 downto 0) := x"00";
signal sReg14 : std_logic_vector(7 downto 0) := x"00";
signal sReg1F : std_logic_vector(7 downto 0) := x"04";

signal sCalstatQ_TimerRst_n, sCalstatI_TimerRst_n : std_logic;
signal sCalstatQ_Timer, sCalstatI_Timer : unsigned (23 downto 0);
signal sSetCalstatQ, sSetCalstatI : std_logic;
signal sAddrAux : integer range 0 to 511;

begin

sAddrAux <= to_integer (unsigned (std_logic_vector'((sAddrDecode))));

-- The following section generates a pulse when sAddrDecodeReady is asserted.
-- This pulse indicates that the command phase of the SPI read transaction is
-- completed and that sAddrDecode contains valid data.
ProcAddrDecodeDly: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sAddrDecodeReadyDly <= '0';
   elsif (rising_edge(SysClk100)) then
      sAddrDecodeReadyDly <= sAddrDecodeReady;
    end if;
end process;

sAddrDecodeReadyPulse <= sAddrDecodeReady and (not sAddrDecodeReadyDly);

-- Process managing register read operations 
ReadRegister: process(SysClk100, asRst_n)
begin
if (asRst_n = '0') then
   sRegDataOut <= (others => '0');
elsif (rising_edge (SysClk100)) then
   if (sAddrDecodeReadyPulse = '1') then
      case (sAddrDecode) is
         when "00000" =>
            sRegDataOut <= sReg00;
         when "00001" =>
            if (InsertError = '0') then
                sRegDataOut <= sReg01;
            else
                sRegDataOut <= x"00";
            end if;
         when "00010" =>
            sRegDataOut <= sReg02;        
         when "00011" =>
            sRegDataOut <= sReg03;
         when "00100" =>
            sRegDataOut <= sReg04;
         when "00101" =>
            sRegDataOut <= sReg05;
         when "00110" =>
            sRegDataOut <= sReg06;
         when "00111" =>
            sRegDataOut <= sReg07;
         when "01000" =>
            sRegDataOut <= sReg08;
         when "01001" =>
            sRegDataOut <= sReg09;
        when "01010" =>
            sRegDataOut <= sReg0A;
        when "01011" =>
            sRegDataOut <= sReg0B;
        when "01100" =>
            sRegDataOut <= sReg0C;
        when "01101" =>
            sRegDataOut <= sReg0D;
        when "01110" =>
            sRegDataOut <= sReg0E;
        when "01111" =>
            sRegDataOut <= sReg0F;
        when "10000" =>
            sRegDataOut <= sReg10;
        when "10001" =>
            sRegDataOut <= sReg11;
        when "10010" =>
            sRegDataOut <= sReg12;
        when "10100" =>
            sRegDataOut <= sReg14;
        when "11111" =>
            sRegDataOut <= sReg1F;
        when others =>
            sRegDataOut <= x"00";
            report "Invalid Read Address." & LF & HT & HT
            severity ERROR; 
        end case;
    end if;
end if;            
end process ReadRegister;

-- The following section generates a pulse when sDataWriteDecodeReady is asserted.
-- This pulse indicates that the command phase of the SPI write transaction is
-- completed and that sAddrDecode contains valid data.
ProcDataDecodeDly: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sDataWriteDecodeReadyDly <= '0';
   elsif (rising_edge(SysClk100)) then
      sDataWriteDecodeReadyDly <= sDataWriteDecodeReady;
    end if;
end process;

sDataWriteDecodeReadyPulse <= sDataWriteDecodeReady and (not sDataWriteDecodeReadyDly);

-- Process managing register write operations (Reg0F is treated separately).
WriteRegister: process (SysClk100, asRst_n)
begin
   if (asRst_n = '0') then
      sReg00 <= x"00";
      sReg01 <= x"40";
      sReg02 <= x"34";
      sReg03 <= x"00";
      sReg04 <= x"00";
      sReg05 <= x"00";
      sReg06 <= x"00";
      sReg07 <= x"00";
      sReg08 <= x"00";
      sReg09 <= x"00";
      sReg0A <= x"00";
      sReg0B <= x"00";
      sReg0C <= x"00";
      sReg0D <= x"00";
      sReg0E(7 downto 6) <= "00";
      sReg0E(3 downto 0) <= x"0";
      sReg10 <= x"00";
      sReg11 <= x"34";
      sReg12 <= x"00";
      sReg14 <= x"00";
      sReg1F <= x"04";
   elsif (rising_edge (SysClk100)) then    
      if (sDataWriteDecodeReadyPulse = '1') then
         case (sAddrDecode) is
            when "00000" =>
               sReg00(7 downto 4) <= sDataDecode(7 downto 4);
            when "00001" =>
               sReg01 <= sDataDecode;
            when "00010" =>
               sReg02 <= sDataDecode;
            when "00011" =>
               sReg03(5 downto 0) <= sDataDecode(5 downto 0);
            when "00100" =>
               sReg04(7) <= sDataDecode(7);
               sReg04(5 downto 0) <= sDataDecode(5 downto 0);
            when "00101" =>
               sReg05(7) <= sDataDecode(7);
               sReg05(5 downto 0) <= sDataDecode(5 downto 0);           
            when "00110" =>
                sReg06(5 downto 0) <= sDataDecode(5 downto 0);
            when "00111" =>
               sReg07(7) <= sDataDecode(7);
               sReg07(5 downto 0) <= sDataDecode(5 downto 0);
            when "01000" =>
               sReg08(7) <= sDataDecode(7);
               sReg08(5 downto 0) <= sDataDecode(5 downto 0);
            when "01001" =>
               sReg09 <= sDataDecode;
            when "01010" =>
               sReg0A <= sDataDecode;
            when "01011" =>
               sReg0B <= sDataDecode;
            when "01100" =>
               sReg0C <= sDataDecode; 
            when "01101" =>
                sReg0D(5 downto 0) <= sDataDecode(5 downto 0); 
            when "01110" =>
                sReg0E(7 downto 6) <= sDataDecode(7 downto 6);
                sReg0E(3 downto 0) <= sDataDecode(3 downto 0);
            when "01111" =>
--               sReg0F(7 downto 6) <= sDataDecode(7 downto 6);
--               sReg0F(3 downto 0) <= sDataDecode(3 downto 0);
               report "Attempt to write to a READ ONLY location." & integer'image(sAddrAux) & LF & HT & HT
               severity ERROR;   
            when "10000" =>
               sReg10(5 downto 0) <= sDataDecode(5 downto 0);
            when "10001" =>
               sReg11(5 downto 0) <= sDataDecode(5 downto 0);
            when "10010" =>
               sReg12(7 downto 6) <= sDataDecode(7 downto 6);
               sReg12(4 downto 0) <= sDataDecode(4 downto 0);
            when "10100" =>
               sReg14(7 downto 6) <= sDataDecode(7 downto 6);
               sReg14(4 downto 0) <= sDataDecode(4 downto 0);
            when "11111" =>
               report "Attempt to write to a READ ONLY location." & integer'image(sAddrAux) & LF & HT & HT
               severity ERROR;                                                                                                                                                         
            when others =>
               report "Invalid Write Address." & integer'image(sAddrAux) & LF & HT & HT
               severity ERROR;    
         end case;
      -- Soft Reset		 
	  elsif (sReg00(5) = '1') then	
         sReg01 <= x"40";
         sReg02 <= x"34";
         sReg03 <= x"00";
         sReg04 <= x"00";
         sReg05 <= x"00";
         sReg06 <= x"00";
         sReg07 <= x"00";
         sReg08 <= x"00";
         sReg09 <= x"00";
         sReg0A <= x"00";
         sReg0B <= x"00";
         sReg0C <= x"00";
         sReg0D <= x"00";
         sReg0E(7 downto 6) <= "00";
         sReg0E(3 downto 0) <= x"0";
         sReg10 <= x"00";
         sReg11 <= x"34";
         sReg12 <= x"00";
         sReg14 <= x"00";
         sReg1F <= x"04";	  
      end if;
   end if;        
end process WriteRegister;

-- Counter used to implement the CALSTATQ bit behavior
ProcCalstatQ_Tmr: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sCalstatQ_Timer <= (others => '0');
   elsif (rising_edge(SysClk100)) then
      if (sCalstatQ_TimerRst_n = '0') then
         sCalstatQ_Timer <= (others => '0');
      else
         sCalstatQ_Timer <= sCalstatQ_Timer + 1;     
      end if;
   end if;
end process;

-- Counter used to implement the CALSTATI bit behavior
ProcCalstatI_Tmr: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sCalstatI_Timer <= (others => '0');
   elsif (rising_edge(SysClk100)) then
      if (sCalstatI_TimerRst_n = '0') then
         sCalstatI_Timer <= (others => '0');
      else
         sCalstatI_Timer <= sCalstatI_Timer + 1;     
      end if;
   end if;
end process;

ProcEnCalstatQ_TmrRst: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sCalstatQ_TimerRst_n <= '0';
   elsif (rising_edge(SysClk100)) then
      if (sReg0E(5) = '1') then
         sCalstatQ_TimerRst_n <= '1';
      else
         sCalstatQ_TimerRst_n <= '0';     
      end if;
   end if;
end process;

ProcEnCalstatI_TmrRst: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sCalstatI_TimerRst_n <= '0';
   elsif (rising_edge(SysClk100)) then
      if (sReg0E(4) = '1') then
         sCalstatI_TimerRst_n <= '1';
      else
         sCalstatI_TimerRst_n <= '0';     
      end if;
   end if;
end process;

-- Configure the CALSELQ bit in the Cal Control register (0x0E)
-- for register write operations.
-- Clear CALSELQ when the Q DAC self-calibration is complete.
WriteReg0E_CALSELQ: process (SysClk100, asRst_n)
begin
   if (asRst_n = '0') then
      sReg0E(5) <= '0';
   elsif (rising_edge (SysClk100)) then    
      if (sDataWriteDecodeReadyPulse = '1') then
         if (sAddrDecode = "01110") then
            sReg0E(5) <= sDataDecode(5);
         end if;                                                                                                                                                                
      elsif (sSetCalstatQ = '1') then
         sReg0E(5) <= '0';
      end if;
   end if;        
end process;

-- Configure the CALSELI bit in the Cal Control register (0x0E)
-- for register write operations.
-- Clear CALSELQ when the I DAC self-calibration is complete.
WriteReg0E_CALSELI: process (SysClk100, asRst_n)
begin
   if (asRst_n = '0') then
      sReg0E(4) <= '0';
   elsif (rising_edge (SysClk100)) then    
      if (sDataWriteDecodeReadyPulse = '1') then
         if (sAddrDecode = "01110") then
            sReg0E(4) <= sDataDecode(5);
         end if;                                                                                                                                                                
      elsif (sSetCalstatI = '1') then
         sReg0E(4) <= '0';
      end if;
   end if;        
end process;

-- Manage the CALSTATQ bit in the Cal Memory register (0x0F).
-- Write operations at this address have no effect (except
-- reporting an error).
-- CALSTATQ is set at a predefined interval after the CALSETQ
-- bit in the Cal Control register is set.
-- CALSTATQ is cleared when he CALRSTQ bit in the Memory R/W
-- register (0x12) is set.
WriteReg0F_CALSTATQ: process (SysClk100, asRst_n)
begin
   if (asRst_n = '0') then
      sReg0F(7) <= '0';
   elsif (rising_edge (SysClk100)) then    
      if (sDataWriteDecodeReadyPulse = '1') then
         if (sAddrDecode = "01111") then
            report "Attempt to write to a READ ONLY location." & integer'image(sAddrAux) & LF & HT & HT
            severity ERROR;
         end if;                                                                                                                                                                
      elsif (sReg12(7) = '1') then
         sReg0F(7) <= '0';
      elsif (sSetCalstatQ = '1') then
         sReg0F(7) <= '1';
      end if;
   end if;        
end process;

-- Manage the CALSTATI bit in the Cal Memory register (0x0F).
-- Write operations at this address have no effect (except
-- reporting an error).
-- CALSTATI is set at a predefined interval after the CALSETI
-- bit in the Cal Control register is set.
-- CALSTATI is cleared when he CALRSTI bit in the Memory R/W
-- register (0x12) is set.
WriteReg0F_CALSTATI: process (SysClk100, asRst_n)
begin
   if (asRst_n = '0') then
      sReg0F(6) <= '0';
   elsif (rising_edge (SysClk100)) then    
      if (sDataWriteDecodeReadyPulse = '1') then
         if (sAddrDecode = "01111") then
            report "Attempt to write to a READ ONLY location." & integer'image(sAddrAux) & LF & HT & HT
            severity ERROR;
         end if;                                                                                                                                                                
      elsif (sReg12(6) = '1') then
         sReg0F(6) <= '0';
      elsif (sSetCalstatI = '1') then
         sReg0F(6) <= '1';
      end if;
   end if;        
end process;

-- Process used to set CALSTATQ in 300 calibration clock cycles (kCalTimeout) after
-- the self calibration process has been enabled
ProcStCalstatQ: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sSetCalstatQ <= '0';
   elsif (rising_edge(SysClk100)) then
      if (sCalstatQ_Timer = kCalTimeout) then
         sSetCalstatQ <= '1';
      else
         sSetCalstatQ <= '0';     
      end if;
   end if;
end process;

-- Process used to set CALSTATI in 300 calibration clock cycles (kCalTimeout) after
-- the self calibration process has been enabled
ProcStCalstatI: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sSetCalstatI <= '0';
   elsif (rising_edge(SysClk100)) then
      if (sCalstatI_Timer = kCalTimeout) then
         sSetCalstatI <= '1';
      else
         sSetCalstatI <= '0';     
      end if;
   end if;
end process;

end Behavioral;
