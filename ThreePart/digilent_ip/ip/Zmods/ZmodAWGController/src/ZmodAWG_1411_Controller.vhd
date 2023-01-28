
-------------------------------------------------------------------------------
--
-- File: ZmodAWG1411_Controller.vhd
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
-- This module interfaces directly with the Zmod AWG 1411. It configures the Zmod's 
-- DAC gain based on user options, writes an initial configuration to the AD9717
-- (also performing a self calibration sequence), manages the DAC's SPI interface 
-- and encodes the samples received on the two input data channels in the format
-- requested by AD9717.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;
use work.PkgZmodDAC.all;

entity ZmodAWG_1411_Controller is
   generic (
      -- Parameter identifying the Zmod:     
      -- 7 -> Zmod AWG 1411 - (AD9717)
      kZmodID : integer range 7 to 7 := 7;   
      -- DAC resolution (number of bits). 
	  kDAC_Width : integer range 10 to 16 := 14;
	  -- DAC dynamic/static calibration. 
	  kExtCalibEn : boolean := false;
	  -- Scale dynamic/static calibration.
      kExtScaleConfigEn : boolean := false;
      -- Enable/Disable SPI Indirect Access Port.
      kExtCmdInterfaceEn : boolean := false;
      -- Channel1 low gain multiplicative (gain) compensation coefficient parameter.
	  kCh1LgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000"; 
	  -- Channel1 low gain additive (offset) compensation coefficient parameter.
	  kCh1LgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000";
	  -- Channel1 high gain multiplicative (gain) compensation coefficient parameter.
      kCh1HgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000";
      -- Channel1 high gain additive (offset) compensation coefficient parameter.
      kCh1HgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000";
      -- Channel2 low gain multiplicative (gain) compensation coefficient parameter.
      kCh2LgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000";
      -- Channel2 low gain additive (offset) compensation coefficient parameter.
      kCh2LgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000";  
      -- Channel2 high gain multiplicative (gain) compensation coefficient parameter.
      kCh2HgMultCoefStatic : std_logic_vector (17 downto 0) := "010000000000000000";  
      -- Channel2 high gain additive (offset) compensation coefficient parameter.
      kCh2HgAddCoefStatic : std_logic_vector (17 downto 0) := "000000000000000000"; 
      -- Channel1 Scale select satic control: 0 -> Low Gain; 1 -> High Gain;
      kCh1ScaleStatic : std_logic := '0'; 
      -- Channel2 Scale select satic control: 0 -> Low Gain; 1 -> High Gain; 
      kCh2ScaleStatic : std_logic := '0'  
   );
   Port (
      -- 100MHZ clock input.
      SysClk100 : in  std_logic;
      -- Data Interface (AXI Stream) synchronous clock input.
      DAC_InIO_Clk : in  std_logic;
      -- Input clock used to generate the DAC's DCLKIO. It shouls have the same
      -- frequency and a 90 degree phase shift with respect to DAC_InIO_Clk.
      DAC_Clk : in  std_logic;
      -- Asynchronous active low reset. 
      aRst_n : in std_logic;
      -- sTestMode is used to bypass the calibration block. When this signal
      -- is asserted, raw samples are provided on the data interface.                         
      sTestMode : in std_logic;
      -- Initialization done active low indicator. 
      sInitDoneDAC : out std_logic := '0'; 
      -- DAC initialization error signaling. 
      sConfigError : out STD_LOGIC := '0';
      -- Axi Stream Data Interface (Salve).
      cDataAxisTvalid: in STD_LOGIC;
      cDataAxisTready: out STD_LOGIC;
      cDataAxisTdata: in STD_LOGIC_VECTOR(31 DOWNTO 0);      
      -- Zmod output relay control input signal.   
      sDAC_EnIn : in std_logic;
      -- Channel1 scale select (dynamic) control input.     
      sExtCh1Scale : in std_logic;
      -- Channel2 scale select (dynamic) control input. 
      sExtCh2Scale : in std_logic; 
        
      -- Calibration
      
      -- Channel1 low gain multiplicative (gain) compensation coefficient external port.
      cExtCh1LgMultCoef : in std_logic_vector (17 downto 0); 
      -- Channel1 low gain additive (offset) compensation coefficient external port.
      cExtCh1LgAddCoef : in std_logic_vector (17 downto 0);  
      -- Channel1 high gain multiplicative (gain) compensation coefficient external port.
      cExtCh1HgMultCoef : in std_logic_vector (17 downto 0); 
      -- Channel1 high gain additive (offset) compensation coefficient external port.  
      cExtCh1HgAddCoef : in std_logic_vector (17 downto 0); 
      -- Channel2 low gain multiplicative (gain) compensation coefficient external port.  
      cExtCh2LgMultCoef : in std_logic_vector (17 downto 0); 
      -- Channel2 low gain additive (offset) compensation coefficient external port. 
      cExtCh2LgAddCoef : in std_logic_vector (17 downto 0); 
      -- Channel2 high gain multiplicative (gain) compensation coefficient external port. 
      cExtCh2HgMultCoef : in std_logic_vector (17 downto 0); 
      -- Channel2 high gain additive (offset) compensation coefficient external port.  
      cExtCh2HgAddCoef : in std_logic_vector (17 downto 0);
       
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
      
      --Zmod AWG 1411 external inteface
       
      --AD9717 interface
      sZmodDAC_CS : out std_logic;
      sZmodDAC_SCLK : out std_logic;
      sZmodDAC_SDIO : inout std_logic;
      sZmodDAC_Reset : out std_logic;
      ZmodDAC_ClkIO   : out std_logic;
      ZmodDAC_ClkIn   : out std_logic;
      dZmodDAC_Data     : out std_logic_vector(13 downto 0);
       
      -- Channel1 scale select output control signal.
      sZmodDAC_SetFS1  : out std_logic := '0';
      -- Channel2 scale select output control signal.  
      sZmodDAC_SetFS2  : out std_logic := '0';
      -- Zmod output relay control (output) signal  
      sZmodDAC_EnOut : out std_logic := '0'   
      );
end ZmodAWG_1411_Controller;

architecture Behavioral of ZmodAWG_1411_Controller is

signal DAC_ClkInODDR, DAC_ClkIO_ODDR : std_logic;
signal asRst_n, acRst_n, adRst_n : std_logic;
signal asRst, acRst, adRst : std_logic;
signal cTestMode : std_logic;
signal sCh1ScaleState, sCh2ScaleState : std_logic;
signal cCh1ScaleState, cCh2ScaleState : std_logic;
signal sInitDoneDAC_Loc :std_logic;                                              
signal cCh1In, cCh2In : std_logic_vector(kDAC_Width-1 downto 0); 
signal cODDR_D1, cODDR_D2 : std_logic_vector(13 downto 0);
signal cCh1Calib, cCh2Calib : std_logic_vector(15 downto 0);
   
begin

-- The asynchronous reset input is converted to an RSD (reset with synchronous
-- de-assertion) in the SysClk100 domain, in the DacClk domain and in the
-- DAC_InIO_Clk domain.

InstDacSysReset : entity work.ResetBridge
   Generic map(
      kPolarity => '0')
   Port map(
      aRst => aRst_n, 
      OutClk => SysClk100,
      aoRst => asRst_n);

asRst <= not asRst_n;

InstDacSamplingReset : entity work.ResetBridge
   Generic map(
      kPolarity => '0')
   Port map(
      aRst => aRst_n, 
      OutClk => DAC_InIO_Clk,
      aoRst => acRst_n);  

acRst <= not acRst_n;

InstDacClkReset : entity work.ResetBridge
   Generic map(
      kPolarity => '0')
   Port map(
      aRst => aRst_n, 
      OutClk => DAC_Clk,
      aoRst => adRst_n);  

adRst <= not adRst_n;            

------------------------------------------------------------------------------------------
-- Zmod AWG 1411 scale select logic
------------------------------------------------------------------------------------------  

--Select Static or dynamic control for scale select (output port or IP parameter)
sCh1ScaleState <= sExtCh1Scale when kExtScaleConfigEn = true else kCh1ScaleStatic; 
sCh2ScaleState <= sExtCh2Scale when kExtScaleConfigEn = true else kCh2ScaleStatic; 
sZmodDAC_SetFS1 <= sCh1ScaleState;
sZmodDAC_SetFS2 <= sCh2ScaleState;

-- Synchronize the sChxScaleState signal into DAC_InIO_Clk clock domain
-- The sCh1ScaleState will be used by the GainOffsetCalib module to apply the correct
-- calibration coefficients.
InstDacCh1ScaleSync: entity work.SyncBase
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aiReset => asRst,
      InClk => SysClk100,
      iIn => sCh1ScaleState,
      aoReset => acRst,
      OutClk => DAC_InIO_Clk,
      oOut => cCh1ScaleState);   
      
InstDacCh2ScaleSync: entity work.SyncBase
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aiReset => asRst,
      InClk => SysClk100,
      iIn => sCh2ScaleState,
      aoReset => acRst,
      OutClk => DAC_InIO_Clk,
      oOut => cCh2ScaleState);  

------------------------------------------------------------------------------------------
-- DAC (AD9717) configuration
------------------------------------------------------------------------------------------  

--AD9717 reset signal generation
ProcDAC_Reset: process (SysClk100, asRst_n) 
begin
   if (asRst_n = '0') then
      sZmodDAC_Reset <= '1';
   elsif (rising_edge(SysClk100)) then
      sZmodDAC_Reset <= '0';
   end if;
end process;
      
InstConfigDAC: entity work.ConfigDAC
   Generic Map (

      kDataWidth => kSPI_DataWidth,
      kCommandWidth => kSPI_CommandWidth
   )
   Port Map (
      SysClk100 => SysClk100,
      asRst_n => asRst_n,                       
      sInitDoneDAC => sInitDoneDAC_Loc,
      sConfigError => sConfigError,
      sCmdTxAxisTvalid => sCmdTxAxisTvalid,
      sCmdTxAxisTready => sCmdTxAxisTready,
      sCmdTxAxisTdata => sCmdTxAxisTdata,
      sCmdRxAxisTvalid => sCmdRxAxisTvalid,
      sCmdRxAxisTready => sCmdRxAxisTready,
      sCmdRxAxisTdata => sCmdRxAxisTdata, 
      sZmodDAC_CS => sZmodDAC_CS,
      sZmodDAC_SCLK => sZmodDAC_SCLK,
      sZmodDAC_SDIO => sZmodDAC_SDIO
      );

sInitDoneDAC <= sInitDoneDAC_Loc;

-- Zmod AWG 1411 output relay control
ProcDAC_En: process (SysClk100, asRst_n) 
begin
   if (asRst_n = '0') then
      sZmodDAC_EnOut <= '0';
   elsif (rising_edge (SysClk100)) then
      --enable output once initialization is complete and external enable port is set
      sZmodDAC_EnOut <= sInitDoneDAC_Loc and sDAC_EnIn; 
   end if;
end process;

------------------------------------------------------------------------------------------
-- AD9717 clock (DCLKIO and CLKIN) generation
------------------------------------------------------------------------------------------  

InstDAC_ClkIO_ODDR : ODDR
generic map(
   DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => DAC_ClkIO_ODDR,   -- 1-bit DDR output
   C => DAC_Clk,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '1',  -- 1-bit data input (positive edge)
   D2 => '0',  -- 1-bit data input (negative edge)
   R => adRst,    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);

-- Obuf instantiation is necessary so that the timing analysis for the output data
-- bus (sZmodData) accounts for the output buffers of both clock (ZmodDAC_ClkIO) 
-- and data signals (-prop_thru_buffers is used with the set_output_delay constraint 
-- for the data signals, so the output buffers are not explicitely instantiated for this sZmodData).

InstObufDAC_ClkIO : OBUF
   generic map (
      DRIVE => 12,
      IOSTANDARD => "DEFAULT",
      SLEW => "FAST")
   port map (
      O => ZmodDAC_ClkIO,     -- Buffer output (connect directly to top-level port)
      I => DAC_ClkIO_ODDR      -- Buffer input 
   );
   
InstDAC_ClkinODDR : ODDR
generic map(
   DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => DAC_ClkInODDR,   -- 1-bit DDR output
   C => DAC_Clk,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => '1',  -- 1-bit data input (positive edge)
   D2 => '0',  -- 1-bit data input (negative edge)
   R => adRst,    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);

InstObufDAC_ClkIn : OBUF
   generic map (
      DRIVE => 12,
      IOSTANDARD => "DEFAULT",
      SLEW => "FAST")
   port map (
      O => ZmodDAC_ClkIn,     -- Buffer output (connect directly to top-level port)
      I => DAC_ClkInODDR      -- Buffer input 
   );

------------------------------------------------------------------------------------------
-- Input Data interface
------------------------------------------------------------------------------------------ 

-- This IP processes the input samples in real time, so it can accept samples on the Data
-- Interface at any time.
cDataAxisTready <= '1';

ProcCh1Ch2Data : process (DAC_InIO_Clk, acRst_n) 
begin
   if (acRst_n = '0') then
      cCh1In <= (others => '0');
      cCh2In <= (others => '0');
   elsif(rising_edge(DAC_InIO_Clk)) then
      if (cDataAxisTvalid = '1') then
         cCh1In <= cDataAxisTdata(31 downto 32-kDAC_Width);
         cCh2In <= cDataAxisTdata(15 downto 16-kDAC_Width);
      end if;
   end if;
end process;
   
------------------------------------------------------------------------------------------
-- Calibration
------------------------------------------------------------------------------------------ 
 
-- Synchronize sTestMode in the DAC_InIO_Clk domain.      
InstDacTestModeSync: entity work.SyncBase
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aiReset => asRst,
      InClk => SysClk100,
      iIn => sTestMode,
      aoReset => acRst,
      OutClk => DAC_InIO_Clk,
      oOut => cTestMode);

-- Apply the gain and offset calibration coefficients to the
-- samples received on the input Data Interface.
      
InstCh1DAC_Calibration : entity work.GainOffsetCalib 
   Generic Map(
      kWidth => kDAC_Width,
      kExtCalibEn => kExtCalibEn,
      kInvert => false,
      kLgMultCoefStatic => kCh1LgMultCoefStatic,
      kLgAddCoefStatic  => kCh1LgAddCoefStatic,
      kHgMultCoefStatic => kCh1HgMultCoefStatic,
      kHgAddCoefStatic  => kCh1HgAddCoefStatic
   )
   Port Map
   (
      SamplingClk => DAC_InIO_Clk,
      acRst_n => acRst_n,
      cTestMode => cTestMode,
      cExtLgMultCoef => cExtCh1LgMultCoef,
      cExtLgAddCoef => cExtCh1LgAddCoef,
      cExtHgMultCoef => cExtCh1HgMultCoef, 
      cExtHgAddCoef => cExtCh1HgAddCoef,
      cGainState => cCh1ScaleState,
      cDataRaw => cCh1In,
      cDataInValid => '1',
      cCalibDataOut => cCh1Calib,
      cDataCalibValid => open
   );

InstCh2DAC_Calibration : entity work.GainOffsetCalib 
   Generic Map(
      kWidth => kDAC_Width,
      kExtCalibEn => kExtCalibEn,
      kInvert => false,
      kLgMultCoefStatic => kCh2LgMultCoefStatic,
      kLgAddCoefStatic  => kCh2LgAddCoefStatic,
      kHgMultCoefStatic => kCh2HgMultCoefStatic,
      kHgAddCoefStatic  => kCh2HgAddCoefStatic
   )
   Port Map
   (
      SamplingClk => DAC_InIO_Clk,
      acRst_n => acRst_n,
      cTestMode => cTestMode,
      cExtLgMultCoef => cExtCh2LgMultCoef,
      cExtLgAddCoef => cExtCh2LgAddCoef,
      cExtHgMultCoef => cExtCh2HgMultCoef, 
      cExtHgAddCoef => cExtCh2HgAddCoef,
      cGainState => cCh2ScaleState,
      cDataRaw => cCh2In,
      cDataInValid => '1',
      cCalibDataOut => cCh2Calib,
      cDataCalibValid => open
   );
   
cODDR_D1 <=  cCh1Calib(15 downto 2);
cODDR_D2 <=  cCh2Calib(15 downto 2);

------------------------------------------------------------------------------------------
-- Output Data interface
------------------------------------------------------------------------------------------ 

-- The AD9717 DAC features a 14bit wide double data rate interface. The configuration
-- of the ODDR primitives used to encode the data on this interface assumes the following
-- settings have been applied to the Data Control register (address 0x02) of the AD9717: 
-- IRISING = 1 and IFIRST = 1. Thus, the AD9717 should capture the I channel samples on
-- the rising edge of ZmodDAC_ClkIO (DCLKIO). 
     
ForDAC_Data: for i in 0 to 13 generate
InstDataODDR : ODDR
generic map(
   DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
   INIT => '0',   -- Initial value for Q port ('1' or '0')
   SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
port map (
   Q => dZmodDAC_Data(i),   -- 1-bit DDR output
   C => DAC_InIO_Clk,    -- 1-bit clock input
   CE => '1',  -- 1-bit clock enable input
   D1 => cODDR_D1(i),  -- 1-bit data input (positive edge)
   D2 => cODDR_D2(i),  -- 1-bit data input (negative edge)
   R => '0',    -- 1-bit reset input
   S => '0'     -- 1-bit set input
);
end generate;

end Behavioral;
