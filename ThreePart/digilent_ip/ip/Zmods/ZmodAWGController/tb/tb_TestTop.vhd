
-------------------------------------------------------------------------------
--
-- File: tb_TestTop.vhd
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
-- Top level test bench. This test bench does not extensively test all modules
-- of the ZmodAWG1411_Controller. 
-- A simulation model is provided for the AD9717 DAC SPI interface to test 
-- configuration registers read/write commands. 
-- A command queue is loaded into an external FIFO to exercise the IP's SPI 
-- indirect access port. 
-- A ramp signal is used as stimulus for the data bus. The calibrated samples
-- output by the IP are compared against the expected values in order to test
-- the calibration functionality.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.PkgZmodDAC.all;

entity tb_TestTop is
   Generic (
      -- Simulation system clock period
      kSysClkPeriod : time := 10ns;
      -- Simulation sampling clock period
      kDacClkPeriod : time := 10ns;              
      -- DAC number of bits
      kDAC_Width : integer := 14;
      -- DAC dynamic/static calibration
      kExtCalibEn : boolean := true; 
      -- Enable/Disable SPI Indirect Access Port
      kExtCmdInterfaceEn : boolean := true;
      kExtScaleConfigEn : boolean := true;      
      -- Channel1 low gain multiplicative (gain) compensation coefficient parameter
      kCh1LgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000";
      -- Channel1 low gain additive (offset) compensation coefficient parameter 
      kCh1LgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000";
      -- Channel1 high gain multiplicative (gain) compensation coefficient parameter
      kCh1HgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000";
      -- Channel1 high gain additive (offset) compensation coefficient parameter  
      kCh1HgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000";
      -- Channel2 low gain multiplicative (gain) compensation coefficient parameter 
      kCh2LgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000";
      -- Channel2 low gain additive (offset) compensation coefficient parameter
      kCh2LgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000";
      -- Channel2 high gain multiplicative (gain) compensation coefficient parameter 
      kCh2HgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; 
      -- Channel2 high gain additive (offset) compensation coefficient parameter 
      kCh2HgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000";
      -- Channel1 Scale select satic control: 0 -> Low Gain; 1 -> High Gain;
      kCh1ScaleStatic : std_logic := '0'; 
      -- Channel2 Scale select satic control: 0 -> Low Gain; 1 -> High Gain; 
      kCh2ScaleStatic : std_logic := '0'    
   );
end tb_TestTop;

architecture Behavioral of tb_TestTop is
 
constant kNumClockCycles : integer := 5000000; 

signal DAC_Clk, DAC_InIO_Clk : std_logic := '0'; 
signal SysClk100 : std_logic := '0';  
signal aRst_n: std_logic; 
signal sInitDoneDAC: std_logic;  
signal sConfigError: std_logic;    
signal cDataAxisTvalid: STD_LOGIC;
signal cDataAxisTready: STD_LOGIC;
signal cDataAxisTdata: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal cExtCh1LgMultCoef: std_logic_vector (17 downto 0);
signal cExtCh1LgAddCoef: std_logic_vector (17 downto 0);
signal cExtCh1HgMultCoef: std_logic_vector (17 downto 0);
signal cExtCh1HgAddCoef: std_logic_vector (17 downto 0);
signal cExtCh2LgMultCoef: std_logic_vector (17 downto 0);
signal cExtCh2LgAddCoef: std_logic_vector (17 downto 0);
signal cExtCh2HgAddCoef: std_logic_vector (17 downto 0);
signal cExtCh2HgMultCoef: std_logic_vector (17 downto 0);                     
signal sTestMode: std_logic;           
signal sCmdTxAxisTvalid: STD_LOGIC;
signal sCmdTxAxisTready: STD_LOGIC;
signal sCmdTxAxisTdata: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sCmdRxAxisTvalid: STD_LOGIC;
signal sCmdRxAxisTready: STD_LOGIC;
signal sCmdRxAxisTdata: STD_LOGIC_VECTOR(31 DOWNTO 0);

signal sDAC_EnIn: std_logic;
signal sExtCh1Scale, sExtCh2Scale: std_logic;
signal sCh1Scale, sCh2Scale: std_logic;
signal sZmodDAC_CS: std_logic;
signal sZmodDAC_SCLK: std_logic;
signal sZmodDAC_SDIO: std_logic;
signal sZmodDAC_Reset: std_logic;
signal ZmodDAC_ClkIO: std_logic;
signal ZmodDAC_Clkin: std_logic;
signal dZmodDAC_Data: std_logic_vector(kDAC_Width-1 downto 0);
signal sZmodDAC_SetFS1: std_logic;
signal sZmodDAC_SetFS2: std_logic;  
signal sZmodDAC_EnOut: std_logic;

signal cDAC_DataCh1 : std_logic_vector(kDAC_Width-1 downto 0);
signal cDAC_DataCh2 : std_logic_vector(kDAC_Width-1 downto 0);
signal cCh1_DataTest : std_logic_vector(kDAC_Width-1 downto 0);
signal cCh2_DataTest : std_logic_vector(kDAC_Width-1 downto 0);
signal cZmodDataTest : std_logic_vector(kDAC_Width-1 downto 0);
signal sCh1DataCheckValid : std_logic := '0';
signal sCh2DataCheckValid : std_logic := '0';
signal cZmodDAC_DataInt : integer;
signal cZmodDataTestInt : integer;
signal cDataDiff : integer;
signal cZmodDAC_DataCnt1 : unsigned(kDAC_Width-1 downto 0) := (others => '0');
signal cZmodDAC_DataCnt2 : unsigned(kDAC_Width-1 downto 0) := "10000000000000";
signal cDataGenCntEn1, cDataGenRst1_n : std_logic;
signal cDataGenCntEn2, cDataGenRst2_n : std_logic;  
signal cZmodDataSel : std_logic_vector (2 downto 0);

constant kVal1 : std_logic_vector (15 downto 0) := x"AAAA";
constant kVal2 : std_logic_vector (15 downto 0) := x"5555";
constant kValMin : std_logic_vector (15 downto 0) := x"8000"; 
constant kValMax : std_logic_vector (15 downto 0) := x"7FFF";
constant tStart : time := 0ns; 
constant kDAC_EnLatency : integer := 2;
-- Calibration coefficients use to test the external calibration interface.
-- Must be different values than those assigned as static parameters.
constant kExtCh1LgMultCoef: std_logic_vector (17 downto 0) := "001110111010010100";
constant kExtCh1LgAddCoef: std_logic_vector (17 downto 0) := "111111111010001100";
constant kExtCh1HgMultCoef: std_logic_vector (17 downto 0) := "001111000001101001";
constant kExtCh1HgAddCoef: std_logic_vector (17 downto 0) := "111111111101100111";
constant kExtCh2LgMultCoef: std_logic_vector (17 downto 0) := "001110111110011001";
constant kExtCh2LgAddCoef: std_logic_vector (17 downto 0) := "111111111100101000";  
constant kExtCh2HgMultCoef: std_logic_vector (17 downto 0) := "001111001011010110";
constant kExtCh2HgAddCoef: std_logic_vector (17 downto 0) := "111111111110101101"; 

--
-- 2 stages SyncBase module latency for crossings from SysClk100 domain to 
-- domain DAC_InIO_Clk
constant kSyncBaseLatency: time := kSysClkPeriod + 2*kDacClkPeriod;     
begin

------------------------------------------------------------------------------------------
--Top level component instantiation
------------------------------------------------------------------------------------------ 
sCh1Scale <= sExtCh1Scale when kExtScaleConfigEn = true else kCh1ScaleStatic; --Channel1 AC/DC setting (output port or IP parameter)
sCh2Scale <= sExtCh2Scale when kExtScaleConfigEn = true else kCh2ScaleStatic; --Channel2 AC/DC setting (output port or IP parameter)

InstZmodDAC_Cotroller: entity work.ZmodAWG_1411_Controller
   Generic Map(
      kDAC_Width => kDAC_Width,
      kExtCalibEn => kExtCalibEn,
      kExtScaleConfigEn => kExtScaleConfigEn,
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,    
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic,
      kCh1ScaleStatic => kCh1ScaleStatic,
      kCh2ScaleStatic => kCh2ScaleStatic 
   )
   Port Map(
      SysClk100 => SysClk100,
      DAC_InIO_Clk => DAC_InIO_Clk,
      DAC_Clk => DAC_Clk,
      aRst_n => aRst_n,
      sTestMode => sTestMode,
      sInitDoneDAC => sInitDoneDAC,
      sConfigError => sConfigError,
      cDataAxisTvalid => cDataAxisTvalid,
      cDataAxisTready => cDataAxisTready,
      cDataAxisTdata => cDataAxisTdata,      
      sDAC_EnIn => sDAC_EnIn,    
      sExtCh1Scale => sExtCh1Scale, 
      sExtCh2Scale => sExtCh2Scale,
      cExtCh1LgMultCoef => cExtCh1LgMultCoef,
      cExtCh1LgAddCoef => cExtCh1LgAddCoef, 
      cExtCh1HgMultCoef => cExtCh1HgMultCoef,
      cExtCh1HgAddCoef => cExtCh1HgAddCoef,
      cExtCh2LgMultCoef => cExtCh2LgMultCoef,
      cExtCh2LgAddCoef => cExtCh2LgAddCoef,
      cExtCh2HgMultCoef => cExtCh2HgMultCoef,  
      cExtCh2HgAddCoef => cExtCh2HgAddCoef,

      sCmdTxAxisTvalid => sCmdTxAxisTvalid,
      sCmdTxAxisTready => sCmdTxAxisTready,
      sCmdTxAxisTdata => sCmdTxAxisTdata,
      sCmdRxAxisTvalid => sCmdRxAxisTvalid,
      sCmdRxAxisTready => sCmdRxAxisTready,
      sCmdRxAxisTdata => sCmdRxAxisTdata,   

      sZmodDAC_CS => sZmodDAC_CS,
      sZmodDAC_SCLK => sZmodDAC_SCLK,
      sZmodDAC_SDIO => sZmodDAC_SDIO,
      sZmodDAC_Reset => sZmodDAC_Reset,
      ZmodDAC_ClkIO => ZmodDAC_ClkIO,
      ZmodDAC_Clkin => ZmodDAC_Clkin,
      dZmodDAC_Data => dZmodDAC_Data,
      sZmodDAC_SetFS1 => sZmodDAC_SetFS1,
      sZmodDAC_SetFS2 => sZmodDAC_SetFS2,
      sZmodDAC_EnOut => sZmodDAC_EnOut       
   );

------------------------------------------------------------------------------------------
-- SPI test related modules instantiation
------------------------------------------------------------------------------------------ 

InstAD9717: entity work.AD9717_2WireSPI_Model
   Generic Map(
      kZmodID => 7,
      kDataWidth => kSPI_DataWidth,
      kCommandWidth => kSPI_CommandWidth      
   )
Port Map(
    SysClk100 => SysClk100,
    asRst_n => aRst_n,
    InsertError => '0', 
    sSPI_Clk => sZmodDAC_Sclk,
    sSDIO => sZmodDAC_SDIO,
    sCS => sZmodDAC_CS
    );     

TestCmdFIFO: entity work.SPI_IAP_AD9717_TestModule
   Generic Map(
      kZmodID => 7      
   )
   Port Map( 
      SysClk100 => SysClk100,
      asRst_n => aRst_n,
      sInitDoneDAC => sInitDoneDAC,
      sCmdTxAxisTvalid => sCmdTxAxisTvalid,
      sCmdTxAxisTready => sCmdTxAxisTready,
      sCmdTxAxisTdata => sCmdTxAxisTdata,
      sCmdRxAxisTvalid => sCmdRxAxisTvalid,
      sCmdRxAxisTready => sCmdRxAxisTready,
      sCmdRxAxisTdata => sCmdRxAxisTdata
   );

------------------------------------------------------------------------------------------
-- Calibration test related modules instantiation
------------------------------------------------------------------------------------------ 
 
cDAC_DataCh1 <= cDataAxisTdata(31 downto 32-kDAC_Width);
cDAC_DataCh2 <= cDataAxisTdata(15 downto 16-kDAC_Width);
     
InstCalibDataReferenceCh1 : entity work.CalibDataReference 
    Generic Map (
        kWidth => kDAC_Width,
        kExtCalibEn => kExtCalibEn, 
        kLgMultCoefStatic => kCh1LgMultCoefStatic,
        kLgAddCoefStatic  => kCh1LgAddCoefStatic,
        kHgMultCoefStatic => kCh1HgMultCoefStatic,
        kHgAddCoefStatic  => kCh1HgAddCoefStatic,
        kInvert => false,
        kLatency => 2,
        kTestLatency => 1 
    )
    Port Map(
        SamplingClk => DAC_InIO_Clk,
        cTestMode => sTestMode, -- sTestMode is constant in the current test bench
        cChIn => cDAC_DataCh1,
        cChOut => cCh1_DataTest,
        cExtLgMultCoef => cExtCh1LgMultCoef, 
        cExtLgAddCoef  => cExtCh1LgAddCoef,
        cExtHgMultCoef => cExtCh1HgMultCoef,
        cExtHgAddCoef  => cExtCh1HgAddCoef,
        cGainState => sCh1Scale);  

InstCalibDataReferenceCh2 : entity work.CalibDataReference 
    Generic Map (
        kWidth => kDAC_Width,
        kExtCalibEn => kExtCalibEn, 
        kLgMultCoefStatic => kCh2LgMultCoefStatic,
        kLgAddCoefStatic  => kCh2LgAddCoefStatic,
        kHgMultCoefStatic => kCh2HgMultCoefStatic,
        kHgAddCoefStatic  => kCh2HgAddCoefStatic,
        kInvert => false,
        kLatency => 2,
        kTestLatency => 1  
    )
    Port Map(
        SamplingClk => DAC_InIO_Clk,
        cTestMode => sTestMode, -- sTestMode is constant in the current test bench
        cChIn => cDAC_DataCh2,
        cChOut => cCh2_DataTest,
        cExtLgMultCoef => cExtCh2LgMultCoef, 
        cExtLgAddCoef  => cExtCh2LgAddCoef,
        cExtHgMultCoef => cExtCh2HgMultCoef,
        cExtHgAddCoef  => cExtCh2HgAddCoef,
        cGainState => sCh2Scale);

InstDataPathModel : entity work.DataPathModel
   Generic Map(
      kLatency => 2,
      kDataWidth => 14
   )
   Port Map( 
      DAC_Clk => DAC_InIO_Clk,
      cCh1DataIn => cCh1_DataTest,
      cCh2DataIn => cCh2_DataTest,
      cDataOut => cZmodDataTest
      );

cZmodDAC_DataInt <= to_integer(signed(dZmodDAC_Data));               
cZmodDataTestInt <= to_integer(signed(cZmodDataTest));               
cDataDiff <= cZmodDataTestInt - cZmodDAC_DataInt;

------------------------------------------------------------------------------------------
-- Clock generation
------------------------------------------------------------------------------------------
 
ProcSystmClock: process
begin
   for i in 0 to kNumClockCycles loop
      wait for kSysClkPeriod/2;
      SysClk100 <= not SysClk100;
      wait for kSysClkPeriod/2;
      SysClk100 <= not SysClk100;
   end loop;
   wait;
end process;

ProcSamplingClk: process
begin
   DAC_InIO_Clk <= '0';
   for i in 0 to kNumClockCycles loop
      wait for kDacClkPeriod/2;
      DAC_InIO_Clk <= not DAC_InIO_Clk;
      wait for kDacClkPeriod/2;
      DAC_InIO_Clk <= not DAC_InIO_Clk;
   end loop;
   wait;
end process; 

ProcDacClk: process
begin
   DAC_Clk <= '1';
   wait for kDacClkPeriod/4;
   DAC_Clk <= '0';
   for i in 0 to kNumClockCycles loop
      wait for kDacClkPeriod/2;
      DAC_Clk <= not DAC_Clk;
      wait for kDacClkPeriod/2;
      DAC_Clk <= not DAC_Clk;
   end loop;
   wait;
end process; 

 ------------------------------------------------------------------------------------------
-- Stimuli generation
------------------------------------------------------------------------------------------ 

-- A ramp signal is used as stimulus for the DAC data bus
ProcDataGen1: process (DAC_InIO_Clk, aRst_n, cDataGenRst1_n)  
begin
   if ((aRst_n = '0') or (cDataGenRst1_n = '0')) then
      cZmodDAC_DataCnt1 <= (others => '0');
   elsif (falling_edge(DAC_InIO_Clk)) then
      if (cDataGenCntEn1 = '1') then
         cZmodDAC_DataCnt1 <= cZmodDAC_DataCnt1 + 1;
      end if;     
   end if;
end process;

ProcDataGen2: process (DAC_InIO_Clk, aRst_n, cDataGenRst2_n)  
begin
   if ((aRst_n = '0') or (cDataGenRst2_n = '0')) then
      cZmodDAC_DataCnt2 <= "10000000000000";
   elsif (falling_edge(DAC_InIO_Clk)) then
      if (cDataGenCntEn2 = '1') then
         cZmodDAC_DataCnt2 <= cZmodDAC_DataCnt2 + 1;
      end if;     
   end if;
end process;

-- Mux that allows selecting (simulating )different patters 
-- on the DAC data interface.
ProcZmodDataMux: process (cZmodDAC_DataCnt1,cZmodDAC_DataCnt2, cZmodDataSel)
begin
   case (cZmodDataSel) is
   when ("000") =>
      cDataAxisTdata <= kVal1 & kVal2;
   when ("001") =>
      cDataAxisTdata <= kVal2 & kVal1;
   when ("010") =>   
      cDataAxisTdata <= std_logic_vector(cZmodDAC_DataCnt1) & "00" & std_logic_vector(cZmodDAC_DataCnt2) & "00";
   when ("011") =>
      cDataAxisTdata <= kValMin & kValMin;
   when ("100") =>
      cDataAxisTdata <= kValMax & kValMax;
   when others =>
      cDataAxisTdata <= std_logic_vector(cZmodDAC_DataCnt1) & "00" & std_logic_vector(cZmodDAC_DataCnt2) & "00";
   end case;
end process;

ProcSysClkStimuli: process  
begin
   sDAC_EnIn <= '0';
   sExtCh1Scale <= kCh1ScaleStatic;
   sExtCh2Scale <= kCh2ScaleStatic;
   aRst_n <= '0';
   sTestMode <= '0';
   -- Apply a reset condition.
   wait for kSysClkPeriod;
   wait until falling_edge(SysClk100);
   aRst_n <= '1';
   sDAC_EnIn <= '1';
   wait until sInitDoneDAC = '1';
   
   -- test sZmodDAC_EnOut response to sDAC_EnIn
   wait for kDAC_EnLatency*kSysClkPeriod;
   wait until falling_edge(SysClk100);
   sDAC_EnIn <= '0';
   wait for kDAC_EnLatency*kSysClkPeriod;
   assert (sZmodDAC_EnOut = '0') 
      report "sZmodDAC_EnOut not responding to sDAC_EnIn command" & LF & HT & HT
      severity ERROR;
   sDAC_EnIn <= '1';
   wait for kDAC_EnLatency*kSysClkPeriod;
   assert (sZmodDAC_EnOut = '1') 
      report "sZmodDAC_EnOut not responding to sDAC_EnIn command" & LF & HT & HT
      severity ERROR;
   
   -- test sZmodDAC_SetFS1/2 initialization
   assert (sZmodDAC_SetFS1 = kCh1ScaleStatic) 
      report "sZmodDAC_SetFS1 initialization error" & LF & HT & HT
      severity ERROR;  
   assert (sZmodDAC_SetFS2 = kCh2ScaleStatic) 
      report "sZmodDAC_SetFS2 initialization error" & LF & HT & HT
      severity ERROR;   
         
   -- test sZmodDAC_SetFS1/2 response to sExtCh1Scale
   if (kExtScaleConfigEn = true) then
      sExtCh1Scale <= '1';
      sExtCh2Scale <= '1';
      wait for kSysClkPeriod;
      assert (sZmodDAC_SetFS1 = '1' and sZmodDAC_SetFS2 = '1') 
         report "sZmodDAC_SetFS1/2 not responding to sExtCh1/2Scale command" & LF & HT & HT
         severity ERROR;
      -- Test all possible sample values on the data path for this scale option (useful for the
      -- calibration module test).
      wait for (2**kDAC_Width)*kSysClkPeriod;   
      
      sExtCh1Scale <= '0';
      sExtCh2Scale <= '0';
      wait for kSysClkPeriod;
      assert (sZmodDAC_SetFS1 = '0' and sZmodDAC_SetFS2 = '0') 
         report "sZmodDAC_SetFS1/2 not responding to sExtCh1/2Scale command" & LF & HT & HT
         severity ERROR;
      -- Test all possible sample values on the data path for this scale option.   
      wait for (2**kDAC_Width)*kSysClkPeriod; 
    
      sExtCh1Scale <= '1';
      sExtCh2Scale <= '0';
      wait for kSysClkPeriod;
      assert (sZmodDAC_SetFS1 = '1' and sZmodDAC_SetFS2 = '0') 
         report "sZmodDAC_SetFS1/2 not responding to sExtCh1/2Scale command" & LF & HT & HT
         severity ERROR;
      -- Test all possible sample values on the data path for this scale option.   
      wait for (2**kDAC_Width)*kSysClkPeriod; 
 
      sExtCh1Scale <= '0';
      sExtCh2Scale <= '1';
      wait for kSysClkPeriod;
      assert (sZmodDAC_SetFS1 = '0' and sZmodDAC_SetFS2 = '1') 
         report "sZmodDAC_SetFS1/2 not responding to sExtCh1/2Scale command" & LF & HT & HT
         severity ERROR;
      -- Test all possible sample values on the data path for this scale option.   
      wait for (2**kDAC_Width)*kSysClkPeriod;              
   end if;
   wait;
          
end process;

ProcDacClkStimuli: process  
begin
   -- The coefficients assigned to the external calibration interface
   -- use different values than those assigned as static parameters.
   cExtCh1LgMultCoef <= kExtCh1LgMultCoef;
   cExtCh1LgAddCoef <= kExtCh1LgAddCoef;
   cExtCh1HgMultCoef <= kExtCh1HgMultCoef;
   cExtCh1HgAddCoef <= kExtCh1HgAddCoef;
   cExtCh2LgMultCoef <= kExtCh2LgMultCoef;
   cExtCh2LgAddCoef <= kExtCh2LgAddCoef;  
   cExtCh2HgMultCoef <= kExtCh2HgMultCoef;
   cExtCh2HgAddCoef <= kExtCh2HgAddCoef;
   cDataGenCntEn1 <= '1';
   cDataGenRst1_n <= '1';
   cDataGenCntEn2 <= '1';
   cDataGenRst2_n <= '1';   
   cDataAxisTvalid <= '1';
   wait until sInitDoneDAC = '1';
   -- A counter will be used to generate the input test data for the data path.
   -- However, since a 1LSB error is tolerated so that the CalibDataReference can work 
   -- with real (floating point) values, synchronization problems may not be detected.
   -- For this reason, at the beginning of the test 2 values that differ by more than
   -- 1 LSB will be generated. By this means, the test assures that the data path and
   -- GainOffsetCalib outputs are correctly synchronized with the CalibDataReference.   
   wait until falling_edge(DAC_InIO_Clk);
   cZmodDataSel <= "000";
   wait until falling_edge(DAC_InIO_Clk);
   cZmodDataSel <= "001";
   wait until falling_edge(DAC_InIO_Clk);
   -- Test IP response for minimum negative and maximum positive input
   cZmodDataSel <= "011";  
   wait until falling_edge(DAC_InIO_Clk);
   cZmodDataSel <= "100";  
   -- Apply the ramp pattern on the IP's input.
   wait until falling_edge(DAC_InIO_Clk);
   cZmodDataSel <= "010";   

   wait;   
end process;

-- Check if sZmodDAC_EnOut is disabled while sInitDoneDAC is de-asserted
ProcCheckEnOut: process
begin
      assert (sInitDoneDAC = '0' or sZmodDAC_EnOut = '0') 
      report "sInitDoneDAC  and sZmodDAC_EnOut incorrectly asserted after POR" & LF & HT & HT
      severity ERROR;
      
      wait until sInitDoneDAC = '1';
      assert ((sZmodDAC_EnOut'delayed'last_event) > tStart)
        report "sZmodDAC_EnOut asserted sooner than expected" & LF & HT & HT &
               "Expected: " & time'image(now) & LF & HT & HT &
               "Actual: " & time'image(sZmodDAC_EnOut'delayed'last_event)
        severity ERROR;
      wait for kDAC_EnLatency*kSysClkPeriod;  
      wait until falling_edge(SysClk100);
      if (sDAC_EnIn = '1') then
         assert (sZmodDAC_EnOut = '1') 
         report "sZmodDAC_EnOut not asserted when expected" & LF & HT & HT
         severity ERROR;      
      end if;
      wait;
end process;

-- Process that determines the conditions in which the output data of the 
-- Zmod AWG 1411 Controller is invalid due to requested scale changes.
-- sCh1ScaleState, sCh2ScaleState need to be passed to the GainOffseCalib module
-- so that correct calibration coefficients can be applied to the input data 
-- (in the ZmodAWG1411_Controller top module). Thus, sExtCh1Scale and sExtCh2Scale 
-- need to cross clock domains from the SysClk100 domain to the DAC_InIO_Clk domain 
-- where the GainOffseCalib module operates.
-- When the external scale configuration is enabled and an event occurs on 
-- sExtCh1Scale/sExtCh2Scale it will propagate to the DAC_InIO_Clk clock domain
-- with a latency equal to kSyncBaseLatency.
-- Because the GainOffseCalib module consists of a 2 stage pipe, when the 
-- sCh1ScaleState/sCh2ScaleState finally propagate to the DAC_InIO_Clk domain, it
-- will take another 2 extra DAC_InIO_Clk clock cycles for the calibration module
-- to produce correct data on its output. Due to the ODDR primitive, valid data can
-- be expected on the output in another 2 DAC_InIO_Clk cycles.
-- As a result, it is considered that the output data has unexpected values for
-- kSyncBaseLatency + 4*kDacClkPeriod. This process will not work if consecutive
-- changes on sCh1Scale/sCh2Scale occur at intervals less than 
-- kSyncBaseLatency + 4*kDacClkPeriod!
ProcCh1DataCheckValid: process
begin
   sCh1DataCheckValid <= '1';
   wait until sCh1Scale'event;
   sCh1DataCheckValid <= '0';
   wait for kSyncBaseLatency + 4*kDacClkPeriod;
end process;

ProcCh2DataCheckValid: process
begin
   sCh2DataCheckValid <= '1';
   wait until sCh2Scale'event;
   sCh2DataCheckValid <= '0';
   wait for kSyncBaseLatency + 4*kDacClkPeriod;
end process;

-- Compare the calibrated data samples against the expected values.
ProcCheckCalibData: process (ZmodDAC_ClkIO)
begin
   if (rising_edge(ZmodDAC_ClkIO) or falling_edge(ZmodDAC_ClkIO)) then
      if ((sInitDoneDAC = '1') and (sCh1DataCheckValid = '1') and (sCh2DataCheckValid = '1')) then
         assert (abs(cDataDiff) < 2)
         report "Calibration error: mismatch between expected data and actual data" & LF & HT & HT &
                "Expected: " & integer'image(cZmodDataTestInt) & LF & HT & HT &
                "Actual: " & integer'image(cZmodDAC_DataInt) & LF & HT & HT &
                "Difference: " & integer'image(cDataDiff)
         severity ERROR;
      end if;
   end if;
end process;

end Behavioral;