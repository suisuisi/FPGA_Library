
-------------------------------------------------------------------------------
--
-- File: ZmodScopeController.vhd
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
-- This module interfaces directly with the Zmod Scope 1410-105, Zmod Scope 
-- 1010-40, Zmod Scope 1010-125, Zmod Scope 1210-40, Zmod Scope 1210-125, 
-- Zmod Scope 1410-40 and the Zmod Scope 1410-125. 
-- It configures the gain and coupling select relays, writes an initial 
-- configuration to the AD96xx/AD92xx on the Zmod via the SPI interface, 
-- demultiplexes the data received over the ADC's parallel interface and 
-- forwards it to the upper levels. 
--  
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
library UNISIM;
use UNISIM.VComponents.all;
use work.PkgZmodADC.all;

entity ZmodScopeController is
   Generic (
      -- Parameter identifying the Zmod:
      -- 0 -> Zmod Scope 1410 - 105 (AD9648)       
      -- 1 -> Zmod Scope 1010 - 40 (AD9204)       
      -- 2 -> Zmod Scope 1010 - 125 (AD9608)       
      -- 3 -> Zmod Scope 1210 - 40 (AD9231)       
      -- 4 -> Zmod Scope 1210 - 125 (AD9628)       
      -- 5 -> Zmod Scope 1410 - 40 (AD9251)       
      -- 6 -> Zmod Scope 1410 - 125 (AD9648)
      kZmodID : integer range 0 to 6 := 0;
      -- Sampling Clock Period in ps. 
      kSamplingPeriod : integer range 8000 to 100000:= 10000;
      -- ADC Clock divider ratio (Register 0x0B of AD96xx and AD92xx).
      kADC_ClkDiv : integer range 1 to 8 := 4;
      -- ADC number of bits.
      kADC_Width : integer range 10 to 16 := 10;
      -- Relay dynamic/static configuration.
      kExtRelayConfigEn : boolean := true;
      -- ADC dynamic/static calibration 
      kExtCalibEn : boolean := true; 
      -- Enable/Disable SPI Indirect Access Port.
      kExtCmdInterfaceEn : boolean := false;
      -- Enables/disables the cSyncIn port to control the iZmodSync 
      -- output signal behavior.
      kExtSyncEn : boolean := false;
      -- Channel1 coupling select relay (static configuration).
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling);
      kCh1CouplingStatic : std_logic := '0';
      -- Channel2 coupling select relay (static configuration).
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling);        
      kCh2CouplingStatic : std_logic := '0';
      -- Channel1 gain select relay (static configuration). 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain);          
      kCh1GainStatic : std_logic := '0';
      -- Channel2 gain select relay (static configuration). 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain);          
      kCh2GainStatic : std_logic := '0';        
        
      -- Channel1 low gain multiplicative (gain) compensation coefficient parameter.
      kCh1LgMultCoefStatic : std_logic_vector (19 downto 0) := "00010000000000000000"; 
      -- Channel1 low gain additive (offset) compensation coefficient parameter.
      kCh1LgAddCoefStatic : std_logic_vector (19 downto 0) := "00000000000000000000"; 
      -- Channel1 high gain multiplicative (gain) compensation coefficient parameter.
      kCh1HgMultCoefStatic : std_logic_vector (19 downto 0) := "00010000000000000000";  
      -- Channel1 high gain additive (offset) compensation coefficient parameter.
      kCh1HgAddCoefStatic : std_logic_vector (19 downto 0) := "00000000000000000000"; 
      -- Channel2 low gain multiplicative (gain) compensation coefficient parameter.
      kCh2LgMultCoefStatic : std_logic_vector (19 downto 0) := "00010000000000000000";  
      -- Channel2 low gain additive (offset) compensation coefficient parameter.
      kCh2LgAddCoefStatic : std_logic_vector (19 downto 0) := "00000000000000000000";  
      -- Channel2 high gain multiplicative (gain) compensation coefficient parameter.
      kCh2HgMultCoefStatic : std_logic_vector (19 downto 0) := "00010000000000000000";  
      -- Channel2 high gain additive (offset) compensation coefficient parameter.
      kCh2HgAddCoefStatic : std_logic_vector (19 downto 0) := "00000000000000000000";
	  kSimulation : boolean := false
   );
   Port (
      -- 100MHZ clock input.
      SysClk100 : in  std_logic; 
      -- Sampling clock.   
      ADC_SamplingClk : in  std_logic;
      -- ADC input clock. The ratio between ADC_InClk and ADC_SamplingClk must be
      -- equal to kADC_ClkDiv. It is the user responsibility to correctly configure
      -- the input clocks.   
      ADC_InClk : in  std_logic; 
      -- Asynchronous reset signal (negative polarity).   
      aRst_n : in std_logic;
      -- When sRstBusy is '1', it is not safe to assert aRst_n.
      sRstBusy : out std_logic;
      -- ADC initialization complete signaling.
      sInitDoneADC : out std_logic;
      -- ADC initialization error signaling.  
      sConfigError : out std_logic; 
      -- Relay initialization complete signaling. 
      sInitDoneRelay : out std_logic; 
	  -- When logic '1', this signal enables data acquisition from the ADC. This signal
	  -- should be kept in logic '0' until the downstream IP (e.g. DMA controller) is
	  -- ready to receive the ADC data.
	  sEnableAcquisition : in std_logic;
      -- sDataOverflow indicates that the shallow synchronization FIFO in the DataPath 
      -- module is full. There are two cases in which this signal is asserted:
      -- 1. The ratio between the ADC_InClk and ADC_SamplingClk clock frequencies is
      -- different from kADC_ClkDiv.
      -- 2. The upper levels can not accept data (cDataAxisTready is not asserted)
      -- This IP is not designed to store data, the upper levels should always be able
      -- to accept incoming samples. The output of this IP should be processed in real time.
      sDataOverflow : out std_logic;

      --AXI Stream (master) data interface
      cDataAxisTvalid: OUT STD_LOGIC;
      cDataAxisTready: IN STD_LOGIC;
      cDataAxisTdata: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      
      --Channel1 low gain multiplicative (gain) compensation coefficient external port.
      cExtCh1LgMultCoef : in std_logic_vector (17 downto 0);
      --Channel1 low gain additive (offset) compensation coefficient external port. 
      cExtCh1LgAddCoef : in std_logic_vector (17 downto 0);
      --Channel1 high gain multiplicative (gain) compensation coefficient external port.  
      cExtCh1HgMultCoef : in std_logic_vector (17 downto 0);
      --Channel1 high gain additive (offset) compensation coefficient external port. 
      cExtCh1HgAddCoef : in std_logic_vector (17 downto 0);
      --Channel2 low gain multiplicative (gain) compensation coefficient external port.   
      cExtCh2LgMultCoef : in std_logic_vector (17 downto 0);
      --Channel2 low gain additive (offset) compensation coefficient external port.  
      cExtCh2LgAddCoef : in std_logic_vector (17 downto 0);
      --Channel2 high gain multiplicative (gain) compensation coefficient external port.   
      cExtCh2HgMultCoef : in std_logic_vector (17 downto 0);
      --Channel2 high gain additive (offset) compensation coefficient external port. 
      cExtCh2HgAddCoef : in std_logic_vector (17 downto 0);
      -- Channel1 coupling select relay (dynamic configuration - optional)
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling).  
      sCh1CouplingConfig : in std_logic := '0';
      -- Channel2 coupling select relay (dynamic configuration - optional)
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling).                     
      sCh2CouplingConfig : in std_logic := '0';
      -- Channel1 gain select relay (dynamic configuration - optional) 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain).                       
      sCh1GainConfig : in std_logic := '0'; 
      -- Channel2 gain select relay (dynamic configuration - optional) 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain).                          
      sCh2GainConfig : in std_logic := '0';
      -- sTestMode is used to bypass the calibration block. When this signal
      -- is asserted, raw samples are provided on the data interface.                         
      sTestMode : in std_logic;
      --ADC Controller SYNC input (Optional).
      cSyncIn : in std_logic_vector(kADC_ClkDiv-1 downto 0);    
               
      -- SPI Indirect access port; it provides the means to indirectly access
      -- the ADC registers. It is designed to interface with 2 AXI StreamFIFOs, 
      -- one that stores commands to be transmitted and one to store the received data.
      
      -- TX command AXI stream interface
      sCmdTxAxisTvalid: IN STD_LOGIC;
      sCmdTxAxisTready: OUT STD_LOGIC;
      sCmdTxAxisTdata: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      -- RX command AXI stream interface
      sCmdRxAxisTvalid: OUT STD_LOGIC;
      sCmdRxAxisTready: IN STD_LOGIC;
      sCmdRxAxisTdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  
   
      --- ADC signals (see AD96xx/AD92xx data sheet) ---
      
      -- ADC differential input clock.
      ZmodAdcClkIn_p : out std_logic;
      ZmodAdcClkIn_n : out std_logic;
      -- ADC Sync signal.
      iZmodSync : out std_logic;
      -- ADC DCO.
      ZmodDcoClk : in std_logic;
      -- ADC Data.
      dZmodADC_Data : in std_logic_vector(kADC_Width-1 downto 0);
      -- ADC SPI interface.
      sZmodADC_SDIO : inout std_logic;
      sZmodADC_CS   : out std_logic;
      sZmodADC_Sclk : out std_logic;
      --Relay drive signals.
      sZmodCh1CouplingH   : out std_logic;
      sZmodCh1CouplingL   : out std_logic;
      sZmodCh2CouplingH   : out std_logic;
      sZmodCh2CouplingL   : out std_logic;
      sZmodCh1GainH   : out std_logic;
      sZmodCh1GainL   : out std_logic;
      sZmodCh2GainH   : out std_logic;
      sZmodCh2GainL   : out std_logic;
      sZmodRelayComH  : out std_logic;
      sZmodRelayComL  : out std_logic
   );
end ZmodScopeController;

architecture Behavioral of ZmodScopeController is

--Reset signals
signal acRst_n, asRst_n, acRst, asRst, aRst, aiRst : std_logic;
--PLL&Clock signals
signal DcoClkOut : std_logic;
--Initialization complete flags
signal sInitDoneRelayIdata : std_logic_vector(0 downto 0) := "0"; 
signal cInitDoneRelayOdata : std_logic_vector(0 downto 0) := "0";
signal cInitDoneRelayOvld : std_logic := '0'; 
signal cInitDone, sInitDone, dInitDone : std_logic := '0';
signal sInitDoneADC_Loc : std_logic := '0';
signal sInitDoneRelayLoc : std_logic := '0';
signal cInitDoneADC : std_logic := '0';
signal cInitDoneRelay : std_logic := '0';
signal sInitDoneRelayPush : std_logic := '0';
signal sInitDoneRelayRdy : std_logic := '0';      

--RELAY CONFIG
signal sCh1GainState, sCh2GainState: std_logic;
signal cCh1GainState, cCh2GainState: std_logic;

--Data Path
signal OddrClk : std_logic;
signal cDataValid, cDataCalibValid : std_logic;
signal dFIFO_WrRstBusy, sFIFO_WrRstBusy, sFIFO_WrRstBusyDly: std_logic;
signal cFIFO_RdEn: std_logic;
signal dDataOverflow: std_logic;
signal dEnableAcquisition: std_logic := '0';
--Calibration
signal cChannelA, cChannelB : std_logic_vector(kADC_Width-1 downto 0);
signal cCh1Calib, cCh2Calib : std_logic_vector(15 downto 0);
signal cTestMode : std_logic;
--Sync OSERDES input
signal cADC_SyncOserdes : std_logic_vector(7 downto 0);
constant kDummy : std_logic_vector(8 downto 0) := (others => '0');
constant kSamplingPeriodReal : real := (real(kSamplingPeriod)*0.001);

-- Removing padding (i.e. most significant 2 bits) from the static calibration constants.
-- The padding is necessary only to be able to enter hexadecimal calibration constants
-- from the GUI.
-- Channel1 low gain multiplicative (gain) compensation coefficient parameter.
constant kCh1LgMultCoefStaticNoPad : std_logic_vector(17 downto 0) :=
  kCh1LgMultCoefStatic(17 downto 0); 
-- Channel1 low gain additive (offset) compensation coefficient parameter.
constant kCh1LgAddCoefStaticNoPad : std_logic_vector(17 downto 0) :=
  kCh1LgAddCoefStatic(17 downto 0); 
-- Channel1 high gain multiplicative (gain) compensation coefficient parameter.
constant kCh1HgMultCoefStaticNoPad : std_logic_vector(17 downto 0) :=
  kCh1HgMultCoefStatic(17 downto 0);  
-- Channel1 high gain additive (offset) compensation coefficient parameter.
constant kCh1HgAddCoefStaticNoPad : std_logic_vector(17 downto 0) :=
  kCh1HgAddCoefStatic(17 downto 0); 
-- Channel2 low gain multiplicative (gain) compensation coefficient parameter.
constant kCh2LgMultCoefStaticNoPad : std_logic_vector(17 downto 0) :=
  kCh2LgMultCoefStatic(17 downto 0);  
-- Channel2 low gain additive (offset) compensation coefficient parameter.
constant kCh2LgAddCoefStaticNoPad : std_logic_vector(17 downto 0) :=
  kCh2LgAddCoefStatic(17 downto 0);  
-- Channel2 high gain multiplicative (gain) compensation coefficient parameter.
constant kCh2HgMultCoefStaticNoPad : std_logic_vector(17 downto 0) :=
  kCh2HgMultCoefStatic(17 downto 0);  
-- Channel2 high gain additive (offset) compensation coefficient parameter.
constant kCh2HgAddCoefStaticNoPad : std_logic_vector(17 downto 0) :=
  kCh2HgAddCoefStatic(17 downto 0);

begin

------------------------------------------------------------------------------------------
-- Reset tree
------------------------------------------------------------------------------------------ 

-- The asynchronous reset input is converted to an RSD (reset with synchronous
-- de-assertion) in the SysClk100 domain, in the ADC_SamplingClk domain and in
-- the ADC_InClk domain.

InstAdcSysReset : entity work.ResetBridge
   Generic map(
      kPolarity => '0')
   Port map(
      aRst => aRst_n, 
      OutClk => SysClk100,
      aoRst => asRst_n);
      
asRst <= not asRst_n;
      
InstAdcSamplingReset : entity work.ResetBridge
   Generic map(
      kPolarity => '0')
   Port map(
      aRst => aRst_n, 
      OutClk => ADC_SamplingClk,
      aoRst => acRst_n);
      
acRst <= not acRst_n;

aRst <= not aRst_n;

InstADC_InClkReset : entity work.ResetBridge 
   Generic map(
      kPolarity => '1')
   Port map(
      aRst => aRst, 
      OutClk => ADC_InClk,
      aoRst => aiRst);  
 
------------------------------------------------------------------------------------------
-- Relay configuration
------------------------------------------------------------------------------------------ 
     
InstConfigRelay: entity work.ConfigRelays
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kCh1CouplingStatic => kCh1CouplingStatic,
    kCh2CouplingStatic => kCh2CouplingStatic,
    kCh1GainStatic => kCh1GainStatic,
    kCh2GainStatic => kCh2GainStatic,
	kSimulation => kSimulation
)  
Port Map( 
    SysClk100 => SysClk100,
    asRst_n => asRst_n,
    sCh1CouplingConfig => sCh1CouplingConfig,
    sCh2CouplingConfig => sCh2CouplingConfig,
    sCh1GainConfig => sCh1GainConfig, 
    sCh2GainConfig => sCh2GainConfig,
    --Relay state
    sCh1CouplingState => open,
    sCh2CouplingState => open,
    sCh1GainState => sCh1GainState,
    sCh2GainState => sCh2GainState,
    --Relay drive signals
    sCh1CouplingH => sZmodCh1CouplingH,
    sCh1CouplingL => sZmodCh1CouplingL,
    sCh2CouplingH => sZmodCh2CouplingH,
    sCh2CouplingL => sZmodCh2CouplingL,
    sCh1GainH => sZmodCh1GainH,
    sCh1GainL => sZmodCh1GainL,
    sCh2GainH => sZmodCh2GainH,
    sCh2GainL => sZmodCh2GainL,
    sRelayComH => sZmodRelayComH,
    sRelayComL => sZmodRelayComL,
    sInitDoneRelay => sInitDoneRelayLoc,
    sInitDoneRelayPush => sInitDoneRelayPush,
    sInitDoneRelayRdy => sInitDoneRelayRdy
); 

sInitDoneRelay <= sInitDoneRelayLoc;

-- Synchronize the sInitDoneRelay output of the ConfigRelay_inst module into the ADC_SamplingClk
-- domain. The cInitDoneRelay will be used by the DataPath_inst module to control the 
-- synchronization FIFO write enable and reset behavior. A handshake mechanism assures that the FIFO 
-- write enable is de-asserted before the relay configuration begins and no corrupted data is loaded 
-- into the FIFO.

sInitDoneRelayIdata(0) <= sInitDoneRelayLoc;

InstHandshakeInitDoneRelay: entity work.HandshakeData
   generic map (
      kDataWidth => 1
   )
   port map (     
      InClk => SysClk100,
      OutClk => ADC_SamplingClk,
      iData => sInitDoneRelayIdata,  
      oData => cInitDoneRelayOdata,
      iPush => sInitDoneRelayPush,
      iRdy => sInitDoneRelayRdy,
      oAck => '1',
      oValid => cInitDoneRelayOvld,
      aiReset => asRst,
      aoReset => acRst);

ProcInitDoneRelay: process(acRst_n, ADC_SamplingClk)
begin
   if (acRst_n = '0') then
      cInitDoneRelay <= '0'; 
   elsif Rising_Edge(ADC_SamplingClk) then
      if (cInitDoneRelayOvld = '1') then
          cInitDoneRelay <= cInitDoneRelayOdata(0);
      end if;
   end if; 
end process;

------------------------------------------------------------------------------------------
-- ADC SPI configuration
------------------------------------------------------------------------------------------ 

InstConfigADC: entity work.ConfigADC
Generic Map(
     kZmodID => kZmodID,
     kADC_ClkDiv => kADC_ClkDiv,
     kDataWidth => kSPI_DataWidth,
     kCommandWidth => kSPI_CommandWidth,
	 kSimulation => kSimulation
    ) 
Port Map( 
    --
    SysClk100 => SysClk100,
    asRst_n => asRst_n,
    sInitDoneADC => sInitDoneADC_Loc, 
    sConfigError => sConfigError,
    --ADC SPI interface signals
    sADC_Sclk => sZmodADC_Sclk,
    sADC_SDIO => sZmodADC_SDIO,
    sADC_CS => sZmodADC_CS,
    sCmdTxAxisTvalid => sCmdTxAxisTvalid,
    sCmdTxAxisTready => sCmdTxAxisTready,
    sCmdTxAxisTdata => sCmdTxAxisTdata,
    sCmdRxAxisTvalid => sCmdRxAxisTvalid,
    sCmdRxAxisTready => sCmdRxAxisTready,
    sCmdRxAxisTdata =>  sCmdRxAxisTdata                 
    ); 

sInitDoneADC <= sInitDoneADC_Loc;

-- Synchronize the sInitDoneADC output of the ConfigADC_Inst module into ADC_SamplingClk clock domain
-- The cInitDoneADC will be used by the DataPath_inst module to control the synchronization FIFO write
-- enable and reset behavior.
InstSyncAsyncInitDoneADC: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aoReset => acRst,
      aIn => sInitDoneADC_Loc,
      OutClk => ADC_SamplingClk,
      oOut => cInitDoneADC);    
      
------------------------------------------------------------------------------------------
-- DATA PATH
------------------------------------------------------------------------------------------ 

cFIFO_RdEn <= cDataAxisTready;

-- The init done signals needs to be synchronized in the ADC_SamplingClk domain
-- where it controls the FIFO reset behavior and in the DcoClkOut domain where it
-- controls the FIFO write enable behavior. A falling edge of cInitDone will trigger
-- a FIFO reset. A falling edge of cInitDone can only be caused by the cInitDoneRelay signal.
-- cInitDoneRelay and cInitDoneADC are passed to the ADC sampling clock domain separately
-- in order to avoid complications that might occur if one of the signals changes while the
-- iRdy signal of the HandshakeData module is not yet asserted (the other signal was pushed
-- to the ADC_SamplingClk domain but has not yet propagated).

cInitDone <= cInitDoneRelay and cInitDoneADC;

-- The dInitDone signal is used to control the Synchronization FIFO write enable behavior.
-- No samples are loaded into the FIFO before the initial configuration is completed or during
-- relay configuration intervals. The dInitDone is expected to propagate to the DcoClkOut domain
-- faster than the cInitDone so the FIFO write enable should be safely de-asserted before the
-- FIFO reset occurs 

sInitDone <= sInitDoneRelayLoc and sInitDoneADC_Loc;

-- Since the reset value of the InstSyncAsyncInitDoneDco module is known,
-- the reset can be safely left permanently de-asserted
InstSyncAsyncInitDoneDco: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aoReset => '0',
      aIn => sInitDone,
      OutClk => DcoClkOut,
      oOut => dInitDone);    

-- Since the reset value of the InstSyncAsyncEnableAcquisitionDco module is known,
-- the reset can be safely left permanently de-asserted
InstSyncAsyncEnableAcquisitionDco: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aoReset => '0',
      aIn => sEnableAcquisition,
      OutClk => DcoClkOut,
      oOut => dEnableAcquisition); 
 
InstDataPath : entity work.DataPath
Generic Map(
   kSamplingPeriod => kSamplingPeriodReal,
   kADC_Width => kADC_Width
) 
Port Map( 
    ADC_SamplingClk => ADC_SamplingClk,
    acRst_n => acRst_n,
    DcoClkIn => ZmodDcoClk,
    DcoClkOut => DcoClkOut,
	dEnableAcquisition => dEnableAcquisition,
    dADC_Data => dZmodADC_Data,
    cChannelA => cChannelA,
    cChannelB => cChannelB,
    cDataOutValid => cDataValid,
    cFIFO_RdEn    => cFIFO_RdEn,
    dFIFO_WrRstBusy  => dFIFO_WrRstBusy,
    dDataOverflow => dDataOverflow,
    cInitDone => cInitDone,
    dInitDone => dInitDone
);

-- Synchronize the dFIFO_WrRstBusy signal in SysClk100 clock domain
-- The dFIFO_WrRstBusy is asserted for at least 6 ADC_SamplingClk cycles
InstSyncAsyncFIFO_WrRstBusySysClk: entity work.SyncAsync
   port map (
      aoReset => asRst,
      aIn => dFIFO_WrRstBusy,
      OutClk => SysClk100,
      oOut => sFIFO_WrRstBusy);

ProcWrRstBusyDly: process(asRst_n, SysClk100)
begin
   if (asRst_n = '0') then
      sFIFO_WrRstBusyDly <= '0'; 
   elsif Rising_Edge(SysClk100) then
      sFIFO_WrRstBusyDly <= sFIFO_WrRstBusy;
   end if; 
end process;

-- Generate the sRstBusy signal; sRstBusy is asserted upon reset and de-asserted when a 
-- falling edge on sFIFO_WrRstBusy is detected
ProcRstBusy: process(asRst_n, SysClk100)
begin
   if (asRst_n = '0') then
      sRstBusy <= '1'; 
   elsif Rising_Edge(SysClk100) then
      if ((sFIFO_WrRstBusy = '0') and (sFIFO_WrRstBusyDly = '1')) then
          sRstBusy <= '0';
      end if;
   end if; 
end process;

-- synchronize the dDataOverflow output of the DataPathInst into the ADC_SamplingClk domain
-- The dDataOverflow can only be asserted if the clocking tree is not correctly configured or
-- the higher level IPs can not accept data. However, this IP is designed to operate in real time
-- and not to store samples. Thus, the higher level IPs connected to it should be able to process
-- data at the sampling rate configured. sDataOverflow is an error flag and can only be cleared 
-- by applying a reset to the IP. 

InstSyncAsyncOverflow: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aoReset => asRst,
      aIn => dDataOverflow,
      OutClk => SysClk100,
      oOut => sDataOverflow);
     
------------------------------------------------------------------------------------------
-- ADC CLKIN
------------------------------------------------------------------------------------------ 

InstADC_ClkODDR : ODDR   
   generic map(
      DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
      INIT => '0',   -- Initial value for Q port ('1' or '0')
      SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
   port map (
      Q => OddrClk,   -- 1-bit DDR output
      C => ADC_InClk,    -- 1-bit clock input
      CE => '1',  -- 1-bit clock enable input
      D1 => '1',  -- 1-bit data input (positive edge)
      D2 => '0',  -- 1-bit data input (negative edge)
      R => aiRst,    -- 1-bit reset input
      S => '0'     -- 1-bit set input
   ); 
   
InstADC_ClkOBUFDS : OBUFDS
   generic map (
      IOSTANDARD => "DEFAULT", -- Specify the output I/O standard
      SLEW => "SLOW")          -- Specify the output slew rate
   port map (
      O => ZmodAdcClkIn_p,     -- Diff_p output (connect directly to top-level port)
      OB => ZmodAdcClkIn_n,   -- Diff_n output (connect directly to top-level port)
      I => OddrClk      -- Buffer input 
   );

------------------------------------------------------------------------------------------
-- Calibration
------------------------------------------------------------------------------------------  

-- Synchronize sTestMode in the ADC_SamplingClk domain.      
InstAdcTestModeSync: entity work.SyncBase
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aiReset => asRst,
      InClk => SysClk100,
      iIn => sTestMode,
      aoReset => acRst,
      OutClk => ADC_SamplingClk,
      oOut => cTestMode);  

-- Synchronize sChxGainState in the ADC_SamplingClk domain. The relay gain state
-- is used to select the correct calibration coefficients which are different between
-- the high gain and the low gain settings. 
      
InstSyncAsyncCh1GainState: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aoReset => acRst,
      aIn => sCh1GainState,
      OutClk => ADC_SamplingClk,
      oOut => cCh1GainState);
      
InstSyncAsyncCh2GainState: entity work.SyncAsync
   generic map (
      kResetTo => '0',
      kStages => 2)
   port map (
      aoReset => acRst,
      aIn => sCh2GainState,
      OutClk => ADC_SamplingClk,
      oOut => cCh2GainState);

-- Instantiate the calibration modules for both channels.
            
InstCh1ADC_Calibration : entity work.GainOffsetCalib 
   Generic Map(
      kWidth => kADC_Width,
      kExtCalibEn => kExtCalibEn,
      kInvert => true,
      kLgMultCoefStatic => kCh1LgMultCoefStaticNoPad,
      kLgAddCoefStatic  => kCh1LgAddCoefStaticNoPad,
      kHgMultCoefStatic => kCh1HgMultCoefStaticNoPad,
      kHgAddCoefStatic  => kCh1HgAddCoefStaticNoPad
   )
   Port Map
   (
      SamplingClk => ADC_SamplingClk,
      acRst_n => acRst_n,
      cTestMode => cTestMode,
      cExtLgMultCoef => cExtCh1LgMultCoef,
      cExtLgAddCoef => cExtCh1LgAddCoef,
      cExtHgMultCoef => cExtCh1HgMultCoef, 
      cExtHgAddCoef => cExtCh1HgAddCoef,
      cGainState => cCh1GainState,
      cDataRaw => cChannelA,
      cDataInValid => cDataValid,
      cCalibDataOut => cCh1Calib,
      cDataCalibValid => cDataCalibValid
   );
    
InstCh2ADC_Calibration : entity work.GainOffsetCalib 
   Generic Map(
      kWidth => kADC_Width,
      kExtCalibEn => kExtCalibEn,
      kInvert => false,
      kLgMultCoefStatic => kCh2LgMultCoefStaticNoPad,
      kLgAddCoefStatic  => kCh2LgAddCoefStaticNoPad,
      kHgMultCoefStatic => kCh2HgMultCoefStaticNoPad,
      kHgAddCoefStatic  => kCh2HgAddCoefStaticNoPad
   )
   Port Map
   (
      SamplingClk => ADC_SamplingClk,
      acRst_n => acRst_n,
      cTestMode => cTestMode,
      cExtLgMultCoef => cExtCh2LgMultCoef,
      cExtLgAddCoef => cExtCh2LgAddCoef,
      cExtHgMultCoef => cExtCh2HgMultCoef, 
      cExtHgAddCoef => cExtCh2HgAddCoef,
      cGainState => cCh2GainState,
      cDataRaw => cChannelB,
      cDataInValid => cDataValid, 
      cCalibDataOut => cCh2Calib,
      cDataCalibValid => open --both channels share the same valid signal
   );

cDataAxisTdata <= cCh1Calib & cCh2Calib;
cDataAxisTvalid <= cDataCalibValid;

------------------------------------------------------------------------------------------
-- SYNC generation
------------------------------------------------------------------------------------------ 

cADC_SyncOserdes <= kDummy(7 downto kADC_ClkDiv) & cSyncIn(kADC_ClkDiv-1 downto 0);
OserdesGenerate: if(kADC_ClkDiv > 1) generate
   InstSyncOserdes : OSERDESE2
      generic map (
         DATA_RATE_OQ => "SDR",       -- DDR, SDR
         DATA_RATE_TQ => "BUF",       -- DDR, BUF, SDR
         DATA_WIDTH => kADC_ClkDiv,   -- Parallel data width (2-8,10,14)
         INIT_OQ => '0',              -- Initial value of OQ output (1'b0,1'b1)
         INIT_TQ => '0',              -- Initial value of TQ output (1'b0,1'b1)
         SERDES_MODE => "MASTER",     -- MASTER, SLAVE
         SRVAL_OQ => '0',             -- OQ output value when SR is used (1'b0,1'b1)
         SRVAL_TQ => '0',             -- TQ output value when SR is used (1'b0,1'b1)
         TBYTE_CTL => "FALSE",        -- Enable tristate byte operation (FALSE, TRUE)
         TBYTE_SRC => "FALSE",        -- Tristate byte source (FALSE, TRUE)
         TRISTATE_WIDTH => 1          -- 3-state converter width (1,4)
      )
      port map (
         OFB => open,             -- 1-bit output: Feedback path for data
         OQ => iZmodSync,               -- 1-bit output: Data path output
         -- SHIFTOUT1 / SHIFTOUT2: 1-bit (each) output: Data output expansion (1-bit each)
         SHIFTOUT1 => open,
         SHIFTOUT2 => open,
         TBYTEOUT => open,   -- 1-bit output: Byte group tristate
         TFB => open,             -- 1-bit output: 3-state control
         TQ => open,               -- 1-bit output: 3-state control
         CLK => ADC_InClk,             -- 1-bit input: High speed clock
         CLKDIV => ADC_SamplingClk,       -- 1-bit input: Divided clock
         -- D1 - D8: 1-bit (each) input: Parallel data inputs (1-bit each)
         D1 => cADC_SyncOserdes(0),
         D2 => cADC_SyncOserdes(1),
         D3 => cADC_SyncOserdes(2),
         D4 => cADC_SyncOserdes(3),
         D5 => cADC_SyncOserdes(4),
         D6 => cADC_SyncOserdes(5),
         D7 => cADC_SyncOserdes(6),
         D8 => cADC_SyncOserdes(7),
         OCE => '1',             -- 1-bit input: Output data clock enable
         RST => acRst,             -- 1-bit input: Reset
         -- SHIFTIN1 / SHIFTIN2: 1-bit (each) input: Data input expansion (1-bit each)
         SHIFTIN1 => '0',
         SHIFTIN2 => '0',
         -- T1 - T4: 1-bit (each) input: Parallel 3-state inputs
         T1 => '0',
         T2 => '0',
         T3 => '0',
         T4 => '0',
         TBYTEIN => '0',     -- 1-bit input: Byte group tristate
         TCE => '0'              -- 1-bit input: 3-state clock enable
      );
end generate;
 
SDR_SyncGenerate: if(kADC_ClkDiv = 1) generate
    iZmodSync <= '1';
end generate;
            
end Behavioral;

