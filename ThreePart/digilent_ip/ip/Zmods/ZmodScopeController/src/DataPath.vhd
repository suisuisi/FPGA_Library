
-------------------------------------------------------------------------------
--
-- File: DataPath.vhd
-- Author: Tudor Gherman
-- Original Project: Zmod ADC 1410 Low Level Controller
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
-- This module synchronizes the data output by the ADC on the Dco clock (DcoClk)
-- to the ADC sampling clock (ADC_SamplingClk) domain.
-- A shallow FIFO is instantiated for this purpose.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;
use work.PkgZmodADC.all;

entity DataPath is
   Generic (
      -- sampling clock frequency (in ns).
      kSamplingPeriod : real range 8.0 to 100.0:= 10.0;
      -- ADC number of bits.
      kADC_Width : integer range 10 to 16 := 14
   );
   Port (
      -- Sampling clock. 
      ADC_SamplingClk  : in STD_LOGIC;
      -- Reset signal asynchronously asserted and synchronously 
      -- de-asserted (in the ADC_SamplingClk domain).
      acRst_n          : in STD_LOGIC;
      -- AD92xx/AD96xx DCO output clock.
      DcoClkIn         : in std_logic;
      -- AD92xx/AD96xx DCO output clock forwarded to the IP's upper levels.
      DcoClkOut        : out std_logic;
	  -- When logic '1', this signal enables data acquisition from the ADC. This signal
	  -- should be kept in logic '0' until the downstream IP (e.g. DMA controller) is
	  -- ready to receive the ADC data.
	  dEnableAcquisition : in std_logic;
      -- ADC parallel interleaved output data signals.
      dADC_Data        : in std_logic_vector(kADC_Width-1 downto 0);
      -- AD92xx/AD96xx demutiplexed Channel A data output (synchronized in
      -- the ADC_SamplingClk domain).
      cChannelA        : out STD_LOGIC_VECTOR (kADC_Width-1 downto 0);
      -- AD92xx/AD96xx demutiplexed Channel B data output (synchronized in
      -- the ADC_SamplingClk domain).
      cChannelB        : out STD_LOGIC_VECTOR (kADC_Width-1 downto 0);
      -- Channel A & B data valid indicator.
      cDataOutValid    : out STD_LOGIC;
      -- Synchronization FIFO read enable signal; asserted by the IP's upper levels.
      cFIFO_RdEn       : in STD_LOGIC;
      -- Signal indicating when it is safe to assert acRst_n.
      -- (when dFIFO_WrRstBusy is '1', it is not safe to assert acRst_n).
      dFIFO_WrRstBusy  : out std_logic;
      -- dDataOverflow indicates that the shallow synchronization FIFO in the DataPath 
      -- module is full. There are two cases in which this signal is asserted:
      -- 1. The ratio between the ADC_InClk and ADC_SamplingClk clock frequencies is
      -- different from kADC_ClkDiv.
      -- 2. The upper levels can not accept data (cDataAxisTready is not asserted)
      -- This IP is not designed to store data, the upper levels should always be able
      -- to accept incoming samples. The output of this IP should be processed in real time.
      dDataOverflow    : out STD_LOGIC;
      -- Inputs indicating when both the ADC and relay initialization is complete
      -- synchronized in the ADC_SampingClk domain and in the DcoClk domain.
      cInitDone     : in std_logic;
      dInitDone     : in std_logic
   );
end DataPath;

architecture Behavioral of DataPath is

-- Function used to compute the CLKOUT1_DIVIDE and CLKFBOUT_MULT_F parameters
-- of the MMCM so that the VCO frequency is in the specified range.
-- The MMCM is used for de-skew purposes, so the MMCM's input and output
-- clock frequency should be the same. The CLKOUT1_DIVIDE and CLKFBOUT_MULT_F
-- need to be adjusted to cover input clock frequencies between 10MHz and
-- 400MHz.
function MMCM_M_Coef(SamplingPeriod:real) 
        return real is
   begin
      --400MHz to 200MHz -> VCO frequency = [1200;600]
      if ((SamplingPeriod > 2.5) and (SamplingPeriod <= 5.0)) then
         return 3.0;
      --200MHz to 100MHz 
      elsif ((SamplingPeriod > 5.0) and (SamplingPeriod <= 10.0)) then   
         return 6.0;
      --100MHz to 50MHz    
      elsif ((SamplingPeriod > 10.0) and (SamplingPeriod <= 20.0)) then
         return 12.0;
      --50MHz to 25MHz 
      elsif ((SamplingPeriod > 20.0) and (SamplingPeriod <= 40.0)) then
         return 24.0;       
      --25MHz to 12.5MHz 
      elsif ((SamplingPeriod > 40.0) and (SamplingPeriod <= 80.0)) then
         return 48.0;       
      --12.5MHz to 10MHz 
      elsif (SamplingPeriod > 80.0) then
         return 64.0; 
      --Out of specifications;               
      else
         return 1.0;
      end if;          
end function;

COMPONENT ZmodADC_SynchonizationFIFO
   PORT (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      full : OUT STD_LOGIC;
      overflow : OUT STD_LOGIC;
      empty : OUT STD_LOGIC;
      valid : OUT STD_LOGIC);
END COMPONENT;

signal acRstFIFO, adRstFIFO : std_logic;
signal DcoBufgClk, FboutDcoClk, FbinDcoClk, DcoPLL_Clk, DcoPLL_Clk2, DcoBufioClk : std_logic;
signal dFIFO_WrEn: std_logic := '0';
signal asFIFO_Empty, dFIFO_Full : std_logic;
signal dFIFO_In : std_logic_vector(31 downto 0); 
signal dChannelA, dChannelB : std_logic_vector(kADC_Width-1 downto 0);
signal dChannelA_Aux, dChannelB_Aux : std_logic_vector (16 downto 0);
signal cFIFO_Dout : std_logic_vector (31 downto 0);
signal cFIFO_Valid : std_logic;
signal dFIFO_Overflow : std_logic;
signal cFIFO_RdEnLoc : std_logic;
signal aMMCM_Locked: std_logic;
signal cMMCM_LockedLoc: std_logic; 
signal cMMCM_LckdFallingFlag: std_logic;
signal cMMCM_LckdRisingFlag: std_logic;  
signal cMMCM_Locked_q: std_logic_vector(3 downto 0);
signal cMMCM_Reset_q: std_logic_vector(3 downto 0);
signal aMMCM_ClkStop, cMMCM_ClkStop: std_logic;
signal cMMCM_ClkStop_q: std_logic_vector(3 downto 0);
signal cMMCM_ClkStopFallingFlag: std_logic;
signal cFIFO_Reset_q: std_logic_vector(3 downto 0);
signal dFIFO_RstInterval: std_logic_vector(5 downto 0);
signal cInitDoneDly : std_logic;
signal cInitDoneFallingFlag : std_logic;

constant kClkfboutMultF : real := MMCM_M_Coef(kSamplingPeriod);
constant kClk1Divide : integer := integer(MMCM_M_Coef(kSamplingPeriod));
constant kDummy : std_logic_vector (15 downto 0) := x"0000";

begin

DcoClkOut <= DcoBufgClk;

------------------------------------------------------------------------------------------
-- Input data interface decode
------------------------------------------------------------------------------------------ 

-- Demultiplex the input data bus   
GenerateIDDR : for i in 0 to (kADC_Width-1) generate      
      InstIDDR : IDDR 
      generic map (
         DDR_CLK_EDGE => "SAME_EDGE", -- "OPPOSITE_EDGE", "SAME_EDGE" 
                                          -- or "SAME_EDGE_PIPELINED" 
         INIT_Q1 => '0', -- Initial value of Q1: '0' or '1'
         INIT_Q2 => '0', -- Initial value of Q2: '0' or '1'
         SRTYPE => "SYNC") -- Set/Reset type: "SYNC" or "ASYNC" 
      port map (
         Q1 => dChannelA(i), -- 1-bit output for positive edge of clock  
         Q2 => dChannelB(i), -- 1-bit output for negative edge of clock
         C => DcoBufioClk,   -- 1-bit clock input
         CE => '1', -- 1-bit clock enable input
         D => dADC_Data(i),   -- 1-bit DDR data input
         R => '0',   -- 1-bit reset
         S => '0'    -- 1-bit set
         );
  
   end generate GenerateIDDR;

-- The synchronization FIFO has a constant width that should accommodate
-- ADC widths between 10 and 16 bit wide. Xilinx FIFO generator does not
-- provide any easy means to parametrize the FIFO width.
dChannelA_Aux <= dChannelA & kDummy(16-kADC_Width downto 0);
dChannelB_Aux <= dChannelB & kDummy(16-kADC_Width downto 0);
dFIFO_In <= dChannelA_Aux(16 downto 1) & dChannelB_Aux (16 downto 1);

------------------------------------------------------------------------------------------
-- Input data interface de-skew
------------------------------------------------------------------------------------------ 

--Clock buffer for write FIFO clock.
InstDcoBufg : BUFG    
   port map (
      O => DcoBufgClk, -- 1-bit output: Clock output (connect to I/O clock loads).
      I => DcoPLL_Clk  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
   );
   
--FIFO write clock de-skew.
  
InstBufrFeedbackPLL : BUFR
   generic map (
	  BUFR_DIVIDE => "1",   -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8" 
	  SIM_DEVICE => "7SERIES"  -- Must be set to "7SERIES" 
   )
   port map (
	  O => FbinDcoClk,     -- 1-bit output: Clock output port
	  CE => '1',   -- 1-bit input: Active high, clock enable (Divided modes only)
	  CLR => '0', -- 1-bit input: Active high, asynchronous clear (Divided modes only)
	  I => FboutDcoClk      -- 1-bit input: Clock buffer input driven by an IBUF, MMCM or local interconnect
   );

InstDcoBufio : BUFIO
	port map (
		O => DcoBufioClk,
		I => DcoPLL_Clk2
	);
  
   MMCME2_ADV_inst : MMCME2_ADV
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming (OPTIMIZED, HIGH, LOW)
      CLKFBOUT_MULT_F => kClkfboutMultF,    -- Multiply value for all CLKOUT (2.000-64.000).
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (-360.000-360.000).
      CLKIN1_PERIOD => kSamplingPeriod,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).

      CLKIN2_PERIOD => kSamplingPeriod,
            -- CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
      CLKOUT1_DIVIDE => kClk1Divide,
      CLKOUT2_DIVIDE => kClk1Divide,
      CLKOUT3_DIVIDE => 1,
      CLKOUT4_DIVIDE => 1,
      CLKOUT5_DIVIDE => 1,
      CLKOUT6_DIVIDE => 1,
      CLKOUT0_DIVIDE_F => 1.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
      -- CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
      CLKOUT0_DUTY_CYCLE => 0.5,
      CLKOUT1_DUTY_CYCLE => 0.5,
      CLKOUT2_DUTY_CYCLE => 0.5,
      CLKOUT3_DUTY_CYCLE => 0.5,
      CLKOUT4_DUTY_CYCLE => 0.5,
      CLKOUT5_DUTY_CYCLE => 0.5,
      CLKOUT6_DUTY_CYCLE => 0.5,
      -- CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
      CLKOUT0_PHASE => 0.0,
      CLKOUT1_PHASE => 0.0,
      CLKOUT2_PHASE => IDDR_ClockPhase(kSamplingPeriod),
      CLKOUT3_PHASE => 0.0,
      CLKOUT4_PHASE => 0.0,
      CLKOUT5_PHASE => 0.0,
      CLKOUT6_PHASE => 0.0,
      CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)

      COMPENSATION => "ZHOLD",       -- ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      DIVCLK_DIVIDE => 1,            -- Master division value (1-106)
      -- REF_JITTER: Reference input jitter in UI (0.000-0.999).
      REF_JITTER1 => 0.0,
      REF_JITTER2 => 0.0,
      STARTUP_WAIT => FALSE,         -- Delays DONE until MMCM is locked (FALSE, TRUE)
      -- Spread Spectrum: Spread Spectrum Attributes
      SS_EN => "FALSE",              -- Enables spread spectrum (FALSE, TRUE)
      SS_MODE => "CENTER_HIGH",      -- CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
      SS_MOD_PERIOD => 10000,        -- Spread spectrum modulation period (ns) (VALUES)
      -- USE_FINE_PS: Fine phase shift enable (TRUE/FALSE)
      CLKFBOUT_USE_FINE_PS => FALSE,
      CLKOUT0_USE_FINE_PS => FALSE,
      CLKOUT1_USE_FINE_PS => FALSE,
      CLKOUT2_USE_FINE_PS => FALSE,
      CLKOUT3_USE_FINE_PS => FALSE,
      CLKOUT4_USE_FINE_PS => FALSE,
      CLKOUT5_USE_FINE_PS => FALSE,
      CLKOUT6_USE_FINE_PS => FALSE
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => open,     -- 1-bit output: CLKOUT0
      CLKOUT0B => open,   -- 1-bit output: Inverted CLKOUT0
      CLKOUT1 => DcoPLL_Clk,     -- 1-bit output: CLKOUT1
      CLKOUT1B => open,   -- 1-bit output: Inverted CLKOUT1
      CLKOUT2 => DcoPLL_Clk2,     -- 1-bit output: CLKOUT2
      CLKOUT2B => open,   -- 1-bit output: Inverted CLKOUT2
      CLKOUT3 => open,     -- 1-bit output: CLKOUT3
      CLKOUT3B => open,   -- 1-bit output: Inverted CLKOUT3
      CLKOUT4 => open,     -- 1-bit output: CLKOUT4
      CLKOUT5 => open,     -- 1-bit output: CLKOUT5
      CLKOUT6 => open,     -- 1-bit output: CLKOUT6

      -- DRP Ports: 16-bit (each) output: Dynamic reconfiguration ports
      DO => open,                     -- 16-bit output: DRP data
      DRDY => open,                 -- 1-bit output: DRP ready
      -- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
      PSDONE => open,             -- 1-bit output: Phase shift done
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => FboutDcoClk,         -- 1-bit output: Feedback clock
      CLKFBOUTB => open,       -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      CLKFBSTOPPED => open, -- 1-bit output: Feedback clock stopped
      CLKINSTOPPED => aMMCM_ClkStop, -- 1-bit output: Input clock stopped
      LOCKED => aMMCM_Locked,             -- 1-bit output: LOCK
      -- Clock Inputs: 1-bit (each) input: Clock inputs
      CLKIN1 => DcoClkIn,             -- 1-bit input: Primary clock
      CLKIN2 => '0',             -- 1-bit input: Secondary clock
      -- Control Ports: 1-bit (each) input: MMCM control ports
      CLKINSEL => '1',         -- 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
      PWRDWN => '0',             -- 1-bit input: Power-down
      RST => cMMCM_Reset_q(0),                   -- 1-bit input: Reset
      -- DRP Ports: 7-bit (each) input: Dynamic reconfiguration ports
      DADDR => (others => '0'),               -- 7-bit input: DRP address
      DCLK => '0',                 -- 1-bit input: DRP clock
      DEN => '0',                   -- 1-bit input: DRP enable
      DI => (others => '0'),                     -- 16-bit input: DRP data
      DWE => '0',                   -- 1-bit input: DRP write enable
      -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
      PSCLK => '0',               -- 1-bit input: Phase shift clock
      PSEN => '0',                 -- 1-bit input: Phase shift enable
      PSINCDEC => '0',         -- 1-bit input: Phase shift increment/decrement
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => FbinDcoClk            -- 1-bit input: Feedback clock
   );

------------------------------------------------------------------------------------------
--DcoClock presence detection
------------------------------------------------------------------------------------------ 
-- Not sure if LOCKED or CLKINSTOPPED should be used to reset the MMCM. For now,
-- logic relying on CLKINSTOPPED is commented out

InstMMCM_LockSampingClkSync: entity work.SyncAsync
   port map (
      aoReset => '0',
      aIn => aMMCM_Locked,
      OutClk => ADC_SamplingClk,
      oOut => cMMCM_LockedLoc);
      
--InstMMCM_ClkInStoppedSync: entity work.SyncAsync
--   port map (
--      aoReset => '0',
--      aIn => aMMCM_ClkStop,
--      OutClk => ADC_SamplingClk,
--      oOut => cMMCM_ClkStop);

--the process has no reset signal, however the synchronous logic input
--has no reset either. I don't think this is an issue      
ProcMMCM_LockedDetect: process(ADC_SamplingClk)
begin
   if Rising_Edge(ADC_SamplingClk) then
      cMMCM_Locked_q <= cMMCM_LockedLoc & cMMCM_Locked_q(3 downto 1);
      cMMCM_LckdFallingFlag <= cMMCM_Locked_q(3) and not cMMCM_LockedLoc;
      cMMCM_LckdRisingFlag <= not cMMCM_Locked_q(3) and cMMCM_LockedLoc;
   end if;
end process;

--ProcMMCM_ClkInStoppedDetect: process(ADC_SamplingClk)
--begin
--   if Rising_Edge(ADC_SamplingClk) then
--      cMMCM_ClkStop_q <= cMMCM_ClkStop & cMMCM_ClkStop_q(3 downto 1);
--      cMMCM_ClkStopFallingFlag <= cMMCM_ClkStop_q(3) and not cMMCM_ClkStop;
--      --cMMCM_ClkStopRisingFlag <= not cMMCM_Locked_q(3) and cMMCM_ClkStop;
--   end if;
--end process;

------------------------------------------------------------------------------------------
--MMCM Reset
------------------------------------------------------------------------------------------ 
-- This process will keep the generated reset (cMMCM_Reset_q(0)) asserted for
-- 4 ADC_SamplingClk cycles. The MMCM_RSTMINPULSE Minimum Reset Pulse Width is 5.00ns
-- This condition is guaranteed for Sampling frequencies up to 800MHz.

ProcMMCM_Reset: process(acRst_n, ADC_SamplingClk)
begin
   if (acRst_n = '0') then
      cMMCM_Reset_q <= (others => '1'); 
   elsif Rising_Edge(ADC_SamplingClk) then
      --if (cMMCM_ClkStopFallingFlag = '1') then -- Not clear which condition should be used from Xilinx documentation
      if (cMMCM_LckdFallingFlag = '1') then 
         cMMCM_Reset_q <= (others => '1');
      else
         cMMCM_Reset_q <= '0' & cMMCM_Reset_q(cMMCM_Reset_q'high downto 1);
      end if;
   end if; 
end process;

------------------------------------------------------------------------------------------
--Synchronization FIFO Reset
------------------------------------------------------------------------------------------ 
-- Generate synchronization FIFO reset requirements: 
-- 1. It is always recommended to have the asynchronous reset
-- asserted for at least 3 or C_SYNCHRONIZER_STAGE (whichever is maximum) slowest clock 
-- cycles. 
-- 2. Ensure that there is a minimum gap of 6 clocks (slower clock in case of independent 
-- clock) between 2 consecutive resets when you use Asynchronous reset.
-- 3. The clock(s) must be available when the reset is applied. If for any reason, the 
-- clock(s) is/are lost at the time of reset, you must apply the reset again when the 
-- clock(s) is/are available. Violating this requirement may cause an unexpected behavior. 
-- Sometimes, the busy signals may be stuck and might need reconfiguration of FPGA.

-- Solution:
-- 1. The asynchronous FIFO reset is generated by the LSB of a 4 bit shift register with 
-- the reset value of "1111" (cMMCM_Reset_q). This guarantees that requirement 1 is respected.
-- 2. The responsibility of respecting requirement 2 is passed to the user. 
-- The dFIFO_WrRstBusy which is synchronized in the top level module in the SysClk100 domain 
-- indicates when it is safe to assert the reset.
-- 3. The cMMCM_LckdRisingFlag assures the FIFO is reset after a power cycle.

-- FIFO has 3 reset sources: 
-- 1)IP input reset signal propagated through acRst_n. 
-- 2)MMCM Locked rising edge: the cMMCM_LckdRisingFlag assures the FIFO is reset after a 
-- power cycle.
-- 3)Initialization done flag from the ADC and Relay configuration modules.
-- cInitDoneFallingFlag will not trigger a FIFO reset before the initial ADC configuration is 
-- completed but that it is not necessary since cMMCM_LckdRisingFlag will handle this. Upon 
-- initial configuration completion any relay state change will trigger a reset through the 
-- cInitDoneFallingFlag.

ProcInitDoneDly: process(acRst_n, ADC_SamplingClk)
begin
   if (acRst_n = '0') then
      cInitDoneDly <= '0'; 
   elsif Rising_Edge(ADC_SamplingClk) then
      cInitDoneDly <= cInitDone;
   end if; 
end process;

cInitDoneFallingFlag <= cInitDoneDly and (not cInitDone);
                  
ProcFIFO_Reset: process(acRst_n, ADC_SamplingClk)
begin
   if (acRst_n = '0') then
      cFIFO_Reset_q <= (others => '1'); 
   elsif Rising_Edge(ADC_SamplingClk) then
      if ((cMMCM_LckdRisingFlag = '1') or (cInitDoneFallingFlag = '1')) then
         cFIFO_Reset_q <= (others => '1');
      else
         cFIFO_Reset_q <= '0' & cFIFO_Reset_q(cFIFO_Reset_q'high downto 1);
      end if;
   end if; 
end process;

acRstFIFO <= cFIFO_Reset_q(0);

-- Synchronize the FIFO reset signal generated in the ADC_SamplingClk domain
-- in the DcoBufgClk domain to be used by the reset busy logic and by the
-- FIFO write enable logic. The reset busy logic is designed in the DcoBufgClk
-- domain so that a BRAM FIFO implementation using the dedicated write reset
-- busy port can be easily accommodated in the design.

InstSyncDcoFIFO_Reset : entity work.ResetBridge
   Generic map(
      kPolarity => '1')
   Port map(
      aRst => acRstFIFO, 
      OutClk => DcoBufgClk,
      aoRst => adRstFIFO);

ProcFIFO_ResetInterval: process(adRstFIFO, DcoBufgClk)
begin
   if (adRstFIFO = '1') then
      dFIFO_RstInterval <= (others => '1'); 
   elsif Rising_Edge(DcoBufgClk) then
      dFIFO_RstInterval <= '0' & dFIFO_RstInterval(dFIFO_RstInterval'high downto 1);
   end if; 
end process;

dFIFO_WrRstBusy <= dFIFO_RstInterval(0);

------------------------------------------------------------------------------------------
--Synchronization FIFO write enable
------------------------------------------------------------------------------------------ 
            
-- Requirements: 
-- 1. While in reset state the full flag is asserted and wr_en should be low;
-- 2. Samples should not be loaded while the DcoClk is not stable.
-- 3. Samples should not be loaded before the initial configuration is completed
--    or while AC/DC coupling or gain select relays are changing states.  
-- Solution: Allow FIFO write enable to be asserted while the DcoClk  is lost
-- and count on de-asserting the output AXI Stream data interface valid signal during
-- this interval. The FIFO is reset anyway when the clock recovers, so there is no risk that 
-- the user can read samples loaded into the FIFO before the MMCM locks after Dco recovery.
-- The valid signal is de-asserted with some latency caused by the SyncAsync module
-- (InstMMCM_LockSampingClkSync) that passes the aMMCM_Locked in the ADC_SamplingClk domain.
-- However, the FIFO latency is greater than that of the SyncAsync module, so there is
-- no risk that samples loaded after the MMCM locked is de-asserted can be read by the
-- user. 

ProcFIFO_WrEn : process (DcoBufgClk, adRstFIFO) 
begin
   if (adRstFIFO = '1') then 
      dFIFO_WrEn <= '0';
   elsif (rising_edge(DcoBufgClk)) then
      if (dFIFO_Full = '1' or dInitDone = '0' or dEnableAcquisition = '0') then
         dFIFO_WrEn <= '0';
      else   
         dFIFO_WrEn <= '1';
      end if;
   end if;
end process;

------------------------------------------------------------------------------------------
--Synchronization FIFO write enable
------------------------------------------------------------------------------------------ 

-- FIFO Generator v13.2www.xilinx.com136PG057 October 4, 2017Chapter 3:
-- To avoid unexpected behavior, it is not recommended to drive/toggle wr_en/rd_en 
-- when rst is asserted/high.

cFIFO_RdEnLoc <= cFIFO_RdEn and (not acRstFIFO);
 
------------------------------------------------------------------------------------------
--Synchronization FIFO 
------------------------------------------------------------------------------------------
-- FIFO data latency specified in:
-- Xilinx pg057 Table 3-26 (Read Port Flags Update Latency Due to a Write Operation)
-- not sure if this is the correct reference. Does data have he same latency as read 
-- port flags in response to write operations?
-- Latency: 1 wr_clk + (N + 4) rd_clk (+1 rd_clk) 
-- 2 synchronization stages => N = 2; Extra 1 wr_clk latency added by the IDDR primitive
InstADC_FIFO : ZmodADC_SynchonizationFIFO 
  PORT MAP (
    rst => acRstFIFO,
    wr_clk => DcoBufgClk, 
    rd_clk => ADC_SamplingClk,
    din => dFIFO_In,
    wr_en => dFIFO_WrEn,
    rd_en => cFIFO_RdEnLoc,
    dout => cFIFO_Dout,
    full => dFIFO_Full,
    overflow => dFIFO_Overflow,
    empty => asFIFO_Empty,
    valid => cFIFO_Valid
  );
 
------------------------------------------------------------------------------------------
-- Data Output Valid Logic:
-- The output valid flag is forced to '0' when the DCO strobe is lost and is 
-- only allowed to be reasserted after the FIFO is reset on the rising edge
-- of cMMCM_Locked.
-- A disadvantage of adding this process is that it adds an extra clock latency
-- Also, the user has to extract all data from the FIFO before disabling the
-- Dco strobe
ProcOutDataValid: process(acRst_n, ADC_SamplingClk)
begin
   if (acRst_n = '0') then
      cDataOutValid <= '0';
      cChannelA <= (others => '0');
      cChannelB <= (others => '0'); 
   elsif Rising_Edge(ADC_SamplingClk) then
      cChannelA <= cFIFO_Dout (31 downto 32-kADC_Width);
      cChannelB <= cFIFO_Dout (15 downto 16-kADC_Width);
      if ((cMMCM_LockedLoc = '0') or (cMMCM_Locked_q /= "1111")) then
         cDataOutValid <= '0';
      else
         cDataOutValid <= cFIFO_Valid;
      end if;
   end if; 
end process;

-- Overflow flag logic. The assertion of dDataOverflow can only occur in
-- 2 conditions:
-- 1. The clock tree or ADC clock divider are incorrectly configured.
-- 2. The upper level logic can not accept the data provided by this IP.
-- It is the user responsibility to avoid this situation or to reduce the 
-- sampling rate so that this condition s avoided.
-- dDataOverflow can only be reset by asserting the IP reset input.

ProcDataOverflow : process (DcoBufgClk, adRstFIFO)  
begin
   if (adRstFIFO = '1') then
      dDataOverflow <= '0';
   elsif (rising_edge(DcoBufgClk)) then
      if (dFIFO_Overflow = '1') then
         dDataOverflow <= '1';
      end if;
   end if;
end process;
 
end Behavioral;
