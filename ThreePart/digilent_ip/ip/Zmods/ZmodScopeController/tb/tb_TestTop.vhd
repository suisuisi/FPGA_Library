
-------------------------------------------------------------------------------
--
-- File: tb_TestTop.vhd
-- Author: Tudor Gherman
-- Original Project: ZmodScopeController
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
-- of the ZmodScopeController. Such tests are carried out at component level. 
-- A simulation model is provided for the ADC SPI interface to test  
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
use work.PkgZmodADC.all;

entity tb_TestTop is
   Generic (
      -- Parameter identifying the Zmod:
      -- 0 -> Zmod Scope 1410 - 105 (AD9648)       
      -- 1 -> Zmod Scope 1010 - 40 (AD9204)       
      -- 2 -> Zmod Scope 1010 - 125 (AD9608)       
      -- 3 -> Zmod Scope 1210 - 40 (AD9231)       
      -- 4 -> Zmod Scope 1210 - 125 (AD9628)       
      -- 5 -> Zmod Scope 1410 - 40 (AD9251)       
      -- 6 -> Zmod Scope 1410 - 125 (AD9648)
      kZmodID : integer range 0 to 6 := 1;
      -- Sampling Clock Period in ps; 
      kSamplingPeriod : integer range 2500 to 100000:= 17000;
      -- ADC Clock divider ratio (Register 0x0B of AD96xx and AD92xx)
      kADC_ClkDiv : integer range 1 to 8 := 4;
      -- Relay dynamic/static configuration
      kExtRelayConfigEn : boolean := true;
      -- ADC dynamic/static calibration
      kExtCalibEn : boolean := true; 
      -- Enable/Disable SPI Inirect Access Port
      kExtCmdInterfaceEn : boolean := true;
      -- Enable/disable cSync port to control the iZmodSync output
      -- signal behavior.
      kExtSyncEn : boolean := true;
      -- Channel1 coupling select relay (static configuration)
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling);
      kCh1CouplingStatic : std_logic := '0';
      -- Channel2 coupling select relay (static configuration)
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling); 
      kCh2CouplingStatic : std_logic := '0'; 
      -- Channel1 gain select relay (static configuration) 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain);
      kCh1GainStatic : std_logic := '0';
      -- Channel2 gain select relay (static configuration) 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain);   
      kCh2GainStatic : std_logic := '0';       
      -- Channel1 low gain multiplicative (gain) compensation coefficient parameter
      kCh1LgMultCoefStatic : std_logic_vector (17 downto 0) := "010001101010110010";
      -- Channel1 low gain additive (offset) compensation coefficient parameter 
      kCh1LgAddCoefStatic : std_logic_vector (17 downto 0) := "111111101111010101";
      -- Channel1 high gain multiplicative (gain) compensation coefficient parameter
      kCh1HgMultCoefStatic : std_logic_vector (17 downto 0) := "010001101010111000";
      -- Channel1 high gain additive (offset) compensation coefficient parameter  
      kCh1HgAddCoefStatic : std_logic_vector (17 downto 0) := "111111101111011000";
      -- Channel2 low gain multiplicative (gain) compensation coefficient parameter 
      kCh2LgMultCoefStatic : std_logic_vector (17 downto 0) := "010001101010110010"; 
      -- Channel2 low gain additive (offset) compensation coefficient parameter
      kCh2LgAddCoefStatic : std_logic_vector (17 downto 0) := "111111101111010101";
      -- Channel2 high gain multiplicative (gain) compensation coefficient parameter 
      kCh2HgMultCoefStatic : std_logic_vector (17 downto 0) := "010001101010111000"; 
      -- Channel2 high gain additive (offset) compensation coefficient parameter 
      kCh2HgAddCoefStatic : std_logic_vector (17 downto 0) := "111111101111011000"  
   );
end tb_TestTop;

architecture Behavioral of tb_TestTop is
 
constant kNumClockCycles : integer := 5000000; 
-- ADC number of bits.
constant kADC_Width : integer := SelADC_Width(kZmodID);

signal SysClk100: std_logic := '1';   
signal ADC_SamplingClk: std_logic := '1';    
signal ADC_InClk: std_logic := '1';    
signal aRst_n: std_logic := '0'; 
signal sRstBusy: std_logic;
signal sInitDoneADC: std_logic;  
signal sConfigError: std_logic;  
signal sInitDoneRelay: std_logic;  
signal sDataOverflow: std_logic;
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
signal sCh1CouplingConfig: std_logic;                     
signal sCh2CouplingConfig: std_logic;                  
signal sCh1GainConfig: std_logic;
signal sCh2GainConfig: std_logic;                         
signal sTestMode: std_logic;
signal cSyncIn: std_logic_vector(kADC_ClkDiv-1 downto 0);             
signal sCmdTxAxisTvalid: STD_LOGIC;
signal sCmdTxAxisTready: STD_LOGIC;
signal sCmdTxAxisTdata: STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sCmdRxAxisTvalid: STD_LOGIC;
signal sCmdRxAxisTready: STD_LOGIC;
signal sCmdRxAxisTdata: STD_LOGIC_VECTOR(31 DOWNTO 0);  
signal ZmodAdcClkIn_p: std_logic;
signal ZmodAdcClkIn_n: std_logic;
signal iZmodSync: std_logic;
signal ZmodDcoClk, ZmodDcoClkDly: std_logic := '1';
signal dZmodADC_Data: std_logic_vector(kADC_Width-1 downto 0);
signal sZmodADC_SDIO: std_logic;
signal sZmodADC_CS: std_logic;
signal sZmodADC_Sclk: std_logic;
signal sZmodCh1CouplingH: std_logic;
signal sZmodCh1CouplingL: std_logic;
signal sZmodCh2CouplingH: std_logic;
signal sZmodCh2CouplingL: std_logic;
signal sZmodCh1GainH   : std_logic;
signal sZmodCh1GainL   : std_logic;
signal sZmodCh2GainH   : std_logic;
signal sZmodCh2GainL   : std_logic;
signal sZmodRelayComH  : std_logic;
signal sZmodRelayComL  : std_logic;

signal dZmodADC_DataCnt : unsigned(kADC_Width-1 downto 0);
signal dDataGenCntEn, dDataGenRst_n : std_logic;
signal cChA_DataPathTest, cChB_DataPathTest : std_logic_vector (kADC_Width-1 downto 0);
signal cChannel1_Test, cChannel2_Test : std_logic_vector(kADC_Width-1 downto 0);
signal cCh1OutInt, cCh2OutInt : integer;
signal cCh1TestInt, cCh2TestInt : integer;
signal cCh1Diff, cCh2Diff : integer;
signal aEnOverflowTest : std_logic;
signal sEnableAcquisition : std_logic;

constant kSysClkPeriod : time := 10ns;
constant kADC_SamplingClkPeriod : time := 17ns;     -- System Clock Period
constant kInitDoneLatency : time := kSysClkPeriod;
-- 2 stages SyncAsync module latency for crossings in SysClk100 domain
constant kSyncAsyncSysLatency: time := kSysClkPeriod*2; 
-- Handshake data module latency when crossing from SysClk100 to ADC_samplingClk domain.
constant kHandshakeSys2ADC_Latency: time := kSysClkPeriod+4*kADC_SamplingClkPeriod; 
-- The latency with which cDataAxisTvalid is de-asserted after a relay state modification
-- is requested.
-- The sInitDoneRelay signal is pushed through a HandshakeData 
-- synchronization module and it will take 1 extra ADC_samplingClk cycle for the
-- FIFO reset to be generated.
-- The ADC_Calibration module adds a latency of extra 3 ADC_SamplingClk cycles
-- The valid signal should be de-asserted in HandshakeDataLatency + 
-- + 3 ADC_SamplingClk cycles + 1 ADC_SamplingClk cycle (wait for valid de-assert after FIFO reset).
constant kAxisValidLatency : time := kHandshakeSys2ADC_Latency + 4*kADC_SamplingClkPeriod;
-- Synchronization FIFO depth
constant kSyncFIFO_Depth : integer := 16;
-- Time required for sDataOverflow to assert after cDataAxisTready is de-asserted: 
-- If the FIFO is empty and rd_en is de-asserted it will take kSyncFIFO_Depth write clock cycles 
-- to fill the FIFO. 1 extra clock cycle will be required by the FIFO to assert the overflow
-- signal, 1 clock cycle will be added by the ProcDataOverflow synchronous process and a maximum 
-- time interval equal to kSyncAsyncSysClkLatency is added to pass the dDataOverflow into the 
-- SysClk100 domain. This assessment is based on the presumption that the FIFO wr_en signal is
-- asserted for longer that the FIFO latency before the rd_en signal is de-asserted.      
constant kOverflowLatency: time := kSyncAsyncSysLatency + kSyncFIFO_Depth * kADC_SamplingClkPeriod + 2 * kADC_SamplingClkPeriod;  
-- Calibration constants used to test the dynamic calibration behavior
constant kCh1LgMultCoefDynamic : std_logic_vector (17 downto 0) := "010000110101100101";
constant kCh1LgAddCoefDynamic : std_logic_vector (17 downto 0) := "111111101111011011";
constant kCh1HgMultCoefDynamic : std_logic_vector (17 downto 0) := "010001101000010001";  
constant kCh1HgAddCoefDynamic : std_logic_vector (17 downto 0) := "111111101110111000";  
constant kCh2LgMultCoefDynamic : std_logic_vector (17 downto 0) := "010000101001111010";  
constant kCh2LgAddCoefDynamic : std_logic_vector (17 downto 0) := "000000000000010000"; 
constant kCh2HgMultCoefDynamic : std_logic_vector (17 downto 0) := "010001011010101111"; 
constant kCh2HgAddCoefDynamic : std_logic_vector (17 downto 0) := "000000001000000111";

-- Adding padding (i.e. 2 bits on the most significant positions) to the static
-- calibration constants.
-- The padding is necessary only to be able to enter hexadecimal calibration constants
-- from the GUI.
-- Channel1 low gain multiplicative (gain) compensation coefficient parameter
constant kCh1LgMultCoefStaticPad : std_logic_vector(19 downto 0) :=
  "00"&kCh1LgMultCoefStatic;
-- Channel1 low gain additive (offset) compensation coefficient parameter 
constant kCh1LgAddCoefStaticPad : std_logic_vector(19 downto 0) :=
  "00"&kCh1LgAddCoefStatic;
-- Channel1 high gain multiplicative (gain) compensation coefficient parameter
constant kCh1HgMultCoefStaticPad : std_logic_vector(19 downto 0) :=
  "00"&kCh1HgMultCoefStatic;
-- Channel1 high gain additive (offset) compensation coefficient parameter  
constant kCh1HgAddCoefStaticPad : std_logic_vector(19 downto 0) :=
  "00"&kCh1HgAddCoefStatic;
-- Channel2 low gain multiplicative (gain) compensation coefficient parameter 
constant kCh2LgMultCoefStaticPad : std_logic_vector(19 downto 0) :=
  "00"&kCh2LgMultCoefStatic; 
-- Channel2 low gain additive (offset) compensation coefficient parameter
constant kCh2LgAddCoefStaticPad : std_logic_vector(19 downto 0) :=
  "00"&kCh2LgAddCoefStatic;
-- Channel2 high gain multiplicative (gain) compensation coefficient parameter 
constant kCh2HgMultCoefStaticPad : std_logic_vector(19 downto 0) :=
  "00"&kCh2HgMultCoefStatic; 
-- Channel2 high gain additive (offset) compensation coefficient parameter 
constant kCh2HgAddCoefStaticPad : std_logic_vector(19 downto 0) :=
  "00"&kCh2HgAddCoefStatic;

constant kSamplingPeriodReal : real := (real(kSamplingPeriod)*0.001);

begin

------------------------------------------------------------------------------------------
--Top level component instantiation
------------------------------------------------------------------------------------------ 

InstZmodADC_Controller: entity work.ZmodScopeController
   Generic Map(
      kZmodID => kZmodID,
      kSamplingPeriod => kSamplingPeriod,
      kADC_ClkDiv => kADC_ClkDiv,
      kADC_Width => kADC_Width,
      kExtRelayConfigEn => kExtRelayConfigEn,
      kExtCalibEn => kExtCalibEn,
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,
      kExtSyncEn => kExtSyncEn,
      kCh1CouplingStatic => kCh1CouplingStatic,
      kCh2CouplingStatic => kCh2CouplingStatic,
      kCh1GainStatic => kCh1GainStatic,
      kCh2GainStatic => kCh2GainStatic,     
      kCh1LgMultCoefStatic => kCh1LgMultCoefStaticPad,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStaticPad,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStaticPad,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStaticPad,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStaticPad,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStaticPad,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStaticPad,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStaticPad,
	  kSimulation => true
   )
   Port Map(
      SysClk100 => SysClk100,
      ADC_SamplingClk => ADC_SamplingClk,
      ADC_InClk => ADC_InClk,
      aRst_n => aRst_n,
      sRstBusy => sRstBusy,
      sInitDoneADC => sInitDoneADC,
      sConfigError => sConfigError,
      sInitDoneRelay => sInitDoneRelay,
	  sEnableAcquisition => sEnableAcquisition,
      sDataOverflow => sDataOverflow,
      cDataAxisTvalid => cDataAxisTvalid,
      cDataAxisTready => cDataAxisTready,
      cDataAxisTdata => cDataAxisTdata,
      cExtCh1LgMultCoef => cExtCh1LgMultCoef,
      cExtCh1LgAddCoef => cExtCh1LgAddCoef,
      cExtCh1HgMultCoef => cExtCh1HgMultCoef,
      cExtCh1HgAddCoef => cExtCh1HgAddCoef,
      cExtCh2LgMultCoef => cExtCh2LgMultCoef,
      cExtCh2LgAddCoef => cExtCh2LgAddCoef,
      cExtCh2HgMultCoef => cExtCh2HgMultCoef,
      cExtCh2HgAddCoef => cExtCh2HgAddCoef,
      sCh1CouplingConfig => sCh1CouplingConfig,                 
      sCh2CouplingConfig => sCh2CouplingConfig,                   
      sCh1GainConfig => sCh1GainConfig,                       
      sCh2GainConfig => sCh2GainConfig,                             
      sTestMode => sTestMode,
      cSyncIn => cSyncIn,            
      sCmdTxAxisTvalid => sCmdTxAxisTvalid,
      sCmdTxAxisTready => sCmdTxAxisTready,
      sCmdTxAxisTdata => sCmdTxAxisTdata,
      sCmdRxAxisTvalid => sCmdRxAxisTvalid,
      sCmdRxAxisTready => sCmdRxAxisTready,
      sCmdRxAxisTdata  => sCmdRxAxisTdata, 
   
      ZmodAdcClkIn_p => ZmodAdcClkIn_p,
      ZmodAdcClkIn_n => ZmodAdcClkIn_n,
      iZmodSync => iZmodSync,
      ZmodDcoClk => ZmodDcoClk,
      dZmodADC_Data => dZmodADC_Data,
   
      sZmodADC_SDIO => sZmodADC_SDIO,
      sZmodADC_CS => sZmodADC_CS,
      sZmodADC_Sclk => sZmodADC_Sclk,

      sZmodCh1CouplingH => sZmodCh1CouplingH,
      sZmodCh1CouplingL => sZmodCh1CouplingL,
      sZmodCh2CouplingH => sZmodCh2CouplingH,
      sZmodCh2CouplingL => sZmodCh2CouplingL,
      sZmodCh1GainH => sZmodCh1GainH,
      sZmodCh1GainL => sZmodCh1GainL,
      sZmodCh2GainH => sZmodCh2GainH,
      sZmodCh2GainL => sZmodCh2GainL,
      sZmodRelayComH => sZmodRelayComH,
      sZmodRelayComL => sZmodRelayComL
   );

------------------------------------------------------------------------------------------
-- SPI test related modules instantiation
------------------------------------------------------------------------------------------ 

InstAD96xx_92xx: entity work.AD96xx_92xxSPI_Model
   Generic Map(
      kZmodID => kZmodID,
      kDataWidth => kSPI_DataWidth,
      kCommandWidth => kSPI_CommandWidth
   )
Port Map(
    SysClk100 => SysClk100,
    asRst_n => aRst_n,
    InsertError => '0', 
    sSPI_Clk => sZmodADC_Sclk,
    sSDIO => sZmodADC_SDIO,
    sCS => sZmodADC_CS
    );     

TestCmdFIFO: entity work.SPI_IAP_TestModule
   Generic Map(
      kZmodID => kZmodID
   )
   Port Map( 
      SysClk100 => SysClk100,
      asRst_n => aRst_n,
      sInitDoneADC => sInitDoneADC,
      sCmdTxAxisTvalid => sCmdTxAxisTvalid,
      sCmdTxAxisTready => sCmdTxAxisTready,
      sCmdTxAxisTdata => sCmdTxAxisTdata,
      sCmdRxAxisTvalid => sCmdRxAxisTvalid,
      sCmdRxAxisTready => sCmdRxAxisTready,
      sCmdRxAxisTdata => sCmdRxAxisTdata
   );

------------------------------------------------------------------------------------------
-- Relay test related modules instantiation
------------------------------------------------------------------------------------------ 
   
InstCouplingSelectRelayCh1: entity work.HFD4_5L_LatchingRelay
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kRelayConfigStatic => kCh1CouplingStatic
)  
Port Map( 
    sRelayConfig => sCh1CouplingConfig,
    sRelayDriverH => sZmodCh1CouplingH,
    sRelayDriverL => sZmodCh1CouplingL,
    sRelayComH => sZmodRelayComH,
    sRelayComL => sZmodRelayComL
); 

InstCouplingSelectRelayCh2: entity work.HFD4_5L_LatchingRelay
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kRelayConfigStatic => kCh2CouplingStatic
)  
Port Map( 
    sRelayConfig => sCh2CouplingConfig,
    sRelayDriverH => sZmodCh2CouplingH,
    sRelayDriverL => sZmodCh2CouplingL,
    sRelayComH => sZmodRelayComH,
    sRelayComL => sZmodRelayComL
);

InstGainSelectRelayCh1: entity work.HFD4_5L_LatchingRelay
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kRelayConfigStatic => kCh1GainStatic
)  
Port Map( 
    sRelayConfig => sCh1GainConfig,
    sRelayDriverH => sZmodCh1GainH,
    sRelayDriverL => sZmodCh1GainL,
    sRelayComH => sZmodRelayComH,
    sRelayComL => sZmodRelayComL
);

InstGainSelectRelayCh2: entity work.HFD4_5L_LatchingRelay
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kRelayConfigStatic => kCh2GainStatic
)  
Port Map( 
    sRelayConfig => sCh2GainConfig,
    sRelayDriverH => sZmodCh2GainH,
    sRelayDriverL => sZmodCh2GainL,
    sRelayComH => sZmodRelayComH,
    sRelayComL => sZmodRelayComL
);

------------------------------------------------------------------------------------------
-- Data path & calibration test related modules instantiation
------------------------------------------------------------------------------------------ 
InstDataPathDlyCh1 : entity work.DataPathLatency
    Generic Map (
        kNumFIFO_Stages => 2, 
        kDataWidth => kADC_Width
    )
    Port Map(
        ADC_SamplingClk => ADC_SamplingClk,
        ZmodDcoClk => ZmodDcoClkDly,
        dDataIn => dZmodADC_Data, 
        cChA_DataOut => cChA_DataPathTest,
		cChB_DataOut => cChB_DataPathTest);
        
InstCalibDataRefCh1 : entity work.CalibDataReference 
    Generic Map (
        kWidth => kADC_Width,
        kExtCalibEn => kExtCalibEn, 
        kLgMultCoefStatic => kCh1LgMultCoefStatic,
        kLgAddCoefStatic  => kCh1LgAddCoefStatic,
        kHgMultCoefStatic => kCh1HgMultCoefStatic,
        kHgAddCoefStatic  => kCh1HgAddCoefStatic,
        kInvert => true,
        kLatency => 2,
        kTestLatency => 1 
    )
    Port Map(
        SamplingClk => ADC_SamplingClk,
        cTestMode => sTestMode, -- sTestMode is constant in the current test bench
        cChIn => cChA_DataPathTest,
        cChOut => cChannel1_Test,
        cExtLgMultCoef => cExtCh1LgMultCoef, 
        cExtLgAddCoef  => cExtCh1LgAddCoef,
        cExtHgMultCoef => cExtCh1HgMultCoef,
        cExtHgAddCoef  => cExtCh1HgAddCoef,
        cGainState => sCh1GainConfig);  

InstCalibDataRefCh2 : entity work.CalibDataReference 
    Generic Map (
        kWidth => kADC_Width,
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
        SamplingClk => ADC_SamplingClk,
        cTestMode => sTestMode, -- sTestMode is constant in the current test bench
        cChIn => cChB_DataPathTest,
        cChOut => cChannel2_Test,
        cExtLgMultCoef => cExtCh2LgMultCoef, 
        cExtLgAddCoef  => cExtCh2LgAddCoef,
        cExtHgMultCoef => cExtCh2HgMultCoef,
        cExtHgAddCoef  => cExtCh2HgAddCoef,
        cGainState => sCh2GainConfig);

cCh1OutInt <= to_integer(signed(cDataAxisTdata(31 downto 32-kADC_Width)));               
cCh2OutInt <= to_integer(signed(cDataAxisTdata(15 downto 16-kADC_Width))); 
cCh1TestInt <= to_integer(signed(cChannel1_Test));               
cCh2TestInt <= to_integer(signed(cChannel2_Test));
cCh1Diff <= cCh1OutInt - cCh1TestInt;
cCh2Diff <= cCh2OutInt - cCh2TestInt; 

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
   for i in 0 to kNumClockCycles loop
      wait for kADC_SamplingClkPeriod/2;
      ADC_SamplingClk <= not ADC_SamplingClk;
      wait for kADC_SamplingClkPeriod/2;
      ADC_SamplingClk <= not ADC_SamplingClk;
   end loop;
   wait;
end process; 

ProcADC_InClk: process
begin
   for i in 0 to (kNumClockCycles*kADC_ClkDiv) loop
      wait for kADC_SamplingClkPeriod/(2*kADC_ClkDiv);
      ADC_InClk <= not ADC_InClk;
      wait for kADC_SamplingClkPeriod/(2*kADC_ClkDiv);
      ADC_InClk <= not ADC_InClk;
   end loop;
   wait;
end process; 

ProcDcoClk: process
begin
   wait for kTdcoMax;
   for i in 0 to kNumClockCycles loop
      wait for kADC_SamplingClkPeriod/2;
      ZmodDcoClk <= not ZmodDcoClk;
      wait for kADC_SamplingClkPeriod/2;
      ZmodDcoClk <= not ZmodDcoClk;
   end loop;
   wait;
end process;  

ZmodDcoClkDly <= ZmodDcoClk after
  (IDDR_ClockPhase(kSamplingPeriodReal)/360.0)*kADC_SamplingClkPeriod;

 ------------------------------------------------------------------------------------------
-- Stimuli generation
------------------------------------------------------------------------------------------ 

-- A ramp signal is used as stimuli for the ADC data bus
ProcDataGen: process (ZmodDcoClk)  
begin
   if ((aRst_n = '0') or (dDataGenRst_n = '0')) then
      dZmodADC_DataCnt <= (others => '0');
   elsif (rising_edge(ZmodDcoClk) or falling_edge(ZmodDcoClk)) then
      if (dDataGenCntEn = '1') then
         dZmodADC_DataCnt <= dZmodADC_DataCnt + 1;
      end if;     
   end if;
end process;

dZmodADC_Data <= std_logic_vector(dZmodADC_DataCnt);

-- Stimuli generated in the SysClk100 domain
ProcSysClkDomainStimuli: process
begin
   -- Assert reset for 10 clock cycles (this covers the minimum 
   -- hold time for the reset signal) 
   aRst_n <= '0';
   aEnOverflowTest <= '0';
   sEnableAcquisition <= '0';

   sCh1CouplingConfig <= kCh1CouplingStatic; 
   sCh2CouplingConfig <= kCh2CouplingStatic;
   sCh1GainConfig <= kCh1GainStatic;
   sCh2GainConfig <= kCh2GainStatic;
   sTestMode <= '0';
                  
   wait for 10 * kSysClkPeriod;
   wait until falling_edge(SysClk100); 
    
   -- Initialize relays. 
   aRst_n <= '1';
   
   -- Wait for initialization to complete. 
   wait until sInitDoneRelay = '1';
   
   wait until sInitDoneADC = '1';
   
   -- Wait for 100 clock cycles before enabling actual sample acquisition from the ADC
   -- (this number has no specific relevance).
   wait for 100 * kSysClkPeriod;
   sEnableAcquisition <= '1';
   
   -- Process 2 * 2^14 samples to make sure all possible inputs are tested after calibration.
   wait for (2**kADC_Width) * kADC_SamplingClkPeriod;
   -- Change Ch1 coupling relay state. Drive the coupling select input
   -- on the negative edge of SysClk100.
   -- Check if sInitDone relay is de-asserted in response to a relay state change
   -- command. The change in sInitDone is expected to take place in 1 SysClk100 cycle. 
   -- This test can only be performed if dynamic relay control is enabled.
   if (kExtRelayConfigEn = true) then   
      wait until falling_edge(SysClk100);
      sCh1CouplingConfig <= not kCh1CouplingStatic; 

      wait for kInitDoneLatency;

      assert (sInitDoneRelay = '0')
         report "InitDoneRely signal not de-asserted when expected" & LF & HT & HT 
         severity ERROR; 

      wait for kAxisValidLatency; 
      assert (cDataAxisTvalid = '0')
         report "cDataAxisTvalid signal not de-asserted when expected" & LF & HT & HT 
         severity ERROR;   	
   
      wait until sInitDoneRelay = '1';
   end if;
   -- Test overflow behavior.
   -- First wait for the Synchronization FIFO to come out of reset
   -- (the only indicator available from outside the IP is the cDataAxisTvalid
   -- signal)
   wait until cDataAxisTvalid = '1';
   -- cDataAxisTready can be de-asserted now to test the sDataOverflow behavior.
   aEnOverflowTest <= '1';
   wait for kOverflowLatency;
   wait until falling_edge(SysClk100);
   assert (sDataOverflow = '1')
      report "sDataOverflow signal not asserted when expected" & LF & HT & HT 
      severity ERROR;   
   wait;
   
end process;

-- ZmodDcoClk domain stimuli. The counter used to generate the
-- ADC data bus stimuli is free running for this test bench.
ProcDcoDomainStimuli: process
begin

   dDataGenRst_n <= '1';
   dDataGenCntEn <= '1';

   wait; 
end process;

-- ADC_SamplingClk domain stimuli.
ProcSamplingDomainStimuli: process
begin

   cDataAxisTready <= '1';
   cSyncIn(0) <= '1';
   if (kADC_ClkDiv > 1) then
      cSyncIn(kADC_ClkDiv-1 downto 1) <= (others => '0');
   end if;
   cExtCh1LgMultCoef <= kCh1LgMultCoefDynamic;
   cExtCh1LgAddCoef <= kCh1LgAddCoefDynamic;
   cExtCh1HgMultCoef <= kCh1HgMultCoefDynamic; 
   cExtCh1HgAddCoef <= kCh1HgAddCoefDynamic;
   cExtCh2LgMultCoef <= kCh2LgMultCoefDynamic;
   cExtCh2LgAddCoef <= kCh2LgAddCoefDynamic;
   cExtCh2HgMultCoef <= kCh2HgMultCoefDynamic; 
   cExtCh2HgAddCoef <= kCh2HgAddCoefDynamic;
   
   -- Test overflow behavior. When all other tests re completed,
   -- cDataAxisTready is de-asserted and the behavior of sDataOverflow
   -- is observed (in the ProcSysClkDomainStimuli process).
   wait until aEnOverflowTest = '1';
   cDataAxisTready <= '0';
   
   wait; 
end process;

-- Compare the calibrated data samples against the expected values.

ProcCh1CheckCalibData: process
begin
   wait until cCh1TestInt'event or cCh1OutInt'event;
   -- cCh1Diff is generated on the rising edge of ADC_SamplingClk
   -- and checked on the negative edge of ADC_SamplingClk.
   wait until falling_edge(ADC_SamplingClk);
   if ((cDataAxisTvalid = '1') and (aEnOverflowTest = '0')) then
      assert (abs(cCh1Diff) < 2)
      report "Calibration error: mismatch between expected data and actual data" & LF & HT & HT &
             "Expected: " & integer'image(to_integer(signed(cChannel1_Test))) & LF & HT & HT &
             "Actual: " & integer'image(cCh1OutInt) & LF & HT & HT &
             "Difference: " & integer'image(cCh1Diff)
      severity ERROR;
   end if;
end process;

ProcCh2CheckCalibData: process
begin
   wait until cCh2TestInt'event or cCh2OutInt'event;
   -- cCh1Diff is generated on the rising edge of ADC_SamplingClk
   -- and checked on the negative edge of ADC_SamplingClk.
   wait until falling_edge(ADC_SamplingClk);
   if ((cDataAxisTvalid = '1') and (aEnOverflowTest = '0')) then
      assert (abs(cCh2Diff) < 2)
      report "Calibration error: mismatch between expected data and actual data" & LF & HT & HT &
             "Expected: " & integer'image(to_integer(signed(cChannel2_Test))) & LF & HT & HT &
             "Actual: " & integer'image(cCh2OutInt) & LF & HT & HT &
             "Difference: " & integer'image(cCh2Diff)
      severity ERROR;
   end if;
end process;

ProcCheckADC_Init: process
begin
   
   -- Wait for the reset signal to be de-asserted   
   wait until rising_edge(aRst_n);
   -- Check if the sInitDoneADC signal is asserted and sConfigError is de-asserted 
   -- after the configuration timeout period (determined empirically)
   wait for kCount5ms * kSysClkPeriod;
   assert (sInitDoneADC = '1')
      report "sInitDoneADC signal not asserted when expected" & LF & HT & HT 
      severity ERROR;
   assert (sConfigError = '0')
      report "sConfigError signal not de-asserted when expected" & LF & HT & HT 
      severity ERROR;
end process;

ProcCheckNoDataBeforeEnableAcquisition: process
begin
   
   -- Wait for the reset signal to be de-asserted   
   wait until rising_edge(aRst_n);
   
   -- Check that until sample acquisition is enabled, no data is being sent by the IP
   assert ((sEnableAcquisition = '1') or (cDataAxisTvalid='0'))
     report "Data sent by the IP before acquisition is enabled" & LF & HT & HT 
     severity ERROR;
   
end process;
	  
end Behavioral;