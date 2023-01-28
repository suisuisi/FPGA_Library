
-------------------------------------------------------------------------------
--
-- File: tb_TestConfigRelay.vhd
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
-- This test bench is used to test the ConfigRelay module.
-- The HFD4_5L_LatchingRelay module tests if the relay configuration input
-- (sChxCouplingConfig, sChxGainConfig) of the ConfigRelay module triggers
-- the correct relay drive signals sequence and timing. In addition, this
-- test bench tests the ConfigRelay module's relay state outputs
-- (sChxCouplingState, sChxGainState) against the expected values.
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.PkgZmodADC.all;

entity tb_TestConfigRelay is
   Generic (
      -- Relay dynamic/static configuration
      kExtRelayConfigEn : boolean := true;
      --External configuration ports initial value/static configuration option
      kCh1CouplingConfigInit : std_logic := '0';
      kCh2CouplingConfigInit : std_logic := '0';
      kCh1GainConfigInit : std_logic := '0';
      kCh2GainConfigInit : std_logic := '0'
   );
end tb_TestConfigRelay;

architecture Behavioral of tb_TestConfigRelay is

signal SysClk100 : std_logic := '0';
signal ADC_SamplingClk : std_logic := '0';
signal asRst_n, acRst, asRst : std_logic;
signal sCh1CouplingConfig  : std_logic;
signal sCh2CouplingConfig  : std_logic;
signal sCh1GainConfig  : std_logic; 
signal sCh2GainConfig  : std_logic;
--Relay drive signals
signal sCh1CouplingH  : std_logic;
signal sCh1CouplingL  : std_logic;
signal sCh2CouplingH  : std_logic;
signal sCh2CouplingL  : std_logic;
signal sCh1GainH  : std_logic;
signal sCh1GainL  : std_logic;
signal sCh2GainH  : std_logic;
signal sCh2GainL  : std_logic;
signal sRelayComH  : std_logic;
signal sRelayComL  : std_logic;
signal sInitDoneRelay  : std_logic;
signal sCh1CouplingState  : std_logic;
signal sCh2CouplingState  : std_logic;
signal sCh1GainState  : std_logic;
signal sCh2GainState  : std_logic;
signal sInitDoneRelayPush :  std_logic;
signal sInitDoneRelayRdy  :  std_logic;
signal sInitDoneRelayIdata, cInitDoneRelayOdata : std_logic_vector (0 downto 0);     
signal cInitDoneRelayOvld : std_logic;

begin

sInitDoneRelayIdata(0) <= sInitDoneRelay;

ConfigRelay_inst: entity work.ConfigRelays
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kCh1CouplingStatic => kCh1CouplingConfigInit,
    kCh2CouplingStatic => kCh2CouplingConfigInit,
    kCh1GainStatic => kCh1GainConfigInit,
    kCh2GainStatic => kCh2GainConfigInit,
	kSimulation => true
)  
Port Map( 
    SysClk100 => SysClk100,
    asRst_n => asRst_n,
    sCh1CouplingConfig => sCh1CouplingConfig,
    sCh2CouplingConfig => sCh2CouplingConfig,
    sCh1GainConfig => sCh1GainConfig, 
    sCh2GainConfig => sCh2GainConfig,
    --Relay state
    sCh1CouplingState => sCh1CouplingState,
    sCh2CouplingState => sCh2CouplingState,
    sCh1GainState => sCh1GainState,
    sCh2GainState => sCh2GainState,
    --Relay drive signals
    sCh1CouplingH => sCh1CouplingH,
    sCh1CouplingL => sCh1CouplingL,
    sCh2CouplingH => sCh2CouplingH,
    sCh2CouplingL => sCh2CouplingL,
    sCh1GainH => sCh1GainH,
    sCh1GainL => sCh1GainL,
    sCh2GainH => sCh2GainH,
    sCh2GainL => sCh2GainL,
    sRelayComH => sRelayComH,
    sRelayComL => sRelayComL,
    sInitDoneRelay => sInitDoneRelay,
    sInitDoneRelayPush => sInitDoneRelayPush,
    sInitDoneRelayRdy => sInitDoneRelayRdy
); 

InstCouplingSelectRelayCh1: entity work.HFD4_5L_LatchingRelay
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kRelayConfigStatic => kCh1CouplingConfigInit
)  
Port Map( 
    sRelayConfig => sCh1CouplingConfig,
    --Relay drive signals
    sRelayDriverH => sCh1CouplingH,
    sRelayDriverL => sCh1CouplingL,
    sRelayComH => sRelayComH,
    sRelayComL => sRelayComL
); 

InstCouplingSelectRelayCh2: entity work.HFD4_5L_LatchingRelay
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kRelayConfigStatic => kCh2CouplingConfigInit
)  
Port Map( 
    sRelayConfig => sCh2CouplingConfig,
    --Relay drive signals
    sRelayDriverH => sCh2CouplingH,
    sRelayDriverL => sCh2CouplingL,
    sRelayComH => sRelayComH,
    sRelayComL => sRelayComL
);

InstGainSelectRelayCh1: entity work.HFD4_5L_LatchingRelay
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kRelayConfigStatic => kCh1GainConfigInit
)  
Port Map( 
    sRelayConfig => sCh1GainConfig,
    --Relay drive signals
    sRelayDriverH => sCh1GainH,
    sRelayDriverL => sCh1GainL,
    sRelayComH => sRelayComH,
    sRelayComL => sRelayComL
);

InstGainSelectRelayCh2: entity work.HFD4_5L_LatchingRelay
Generic Map(
    kExtRelayConfigEn => kExtRelayConfigEn,
    kRelayConfigStatic => kCh2GainConfigInit
)  
Port Map( 
    sRelayConfig => sCh2GainConfig,
    --Relay drive signals
    sRelayDriverH => sCh2GainH,
    sRelayDriverL => sCh2GainL,
    sRelayComH => sRelayComH,
    sRelayComL => sRelayComL
);

InstInitDoneRelaySync: entity work.HandshakeData
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

ProcSystmClock: process
begin
   for i in 0 to 5000000 loop
      wait for kSysClkPeriod/2;
      SysClk100 <= not SysClk100;
      wait for kSysClkPeriod/2;
      SysClk100 <= not SysClk100;
   end loop;
   wait;
end process;

ProcSamplingClock: process
begin
   for i in 0 to 5000000 loop
      wait for kSysClkPeriod/2;
      ADC_SamplingClk <= not ADC_SamplingClk;
      wait for kSysClkPeriod/2;
      ADC_SamplingClk <= not ADC_SamplingClk;
   end loop;
   wait;
end process;

-- Process generating the input stimuli for the ConfigRelay module;
-- The relay state outputs are not checked at all time against the 
-- expected values, but instead at critical moments. 
-- The relay state is first verified after initialization. Afterwards,
-- each relay is set and reset. After each operation, the relay
-- state outputs are tested.

ProcMain: process
begin
   -- Hold the reset condition for 10 clock cycles
   -- (one clock cycle is sufficient, however 10 clock cycles makes
   -- it easier to visualize the reset condition in simulation).
   asRst_n <= '0';
   acRst <= '1';
   asRst <= '1';
   sCh1CouplingConfig <= '0'; 
   sCh2CouplingConfig <= '0';
   sCh1GainConfig <= '0';
   sCh2GainConfig <= '0';                     
   wait for 10 * kSysClkPeriod;
   wait until falling_edge(ADC_SamplingClk);
    
   --initialize relays 
   asRst_n <= '1';
   acRst <= '0';
   asRst <= '0';
   sCh1CouplingConfig <= kCh1CouplingConfigInit; 
   sCh2CouplingConfig <= kCh2CouplingConfigInit;
   sCh1GainConfig <= kCh1GainConfigInit;
   sCh2GainConfig <= kCh2GainConfigInit; 
   
   -- Test relay state after initialization. 
   wait until sInitDoneRelay = '1';
   assert (sCh1CouplingState = kCh1CouplingConfigInit)
      report "Ch1 coupling select relay initialization state error" & LF & HT & HT 
      severity ERROR;
   assert (sCh2CouplingState = kCh2CouplingConfigInit)
      report "Ch2 coupling select relay initialization state error" & LF & HT & HT 
      severity ERROR;
   assert (sCh1GainState = kCh1GainConfigInit)
      report "Ch1 gain select relay initialization state error" & LF & HT & HT 
      severity ERROR;
   assert (sCh2GainState = kCh2GainConfigInit)
      report "Ch2 gain select relay initialization state error" & LF & HT & HT 
      severity ERROR; 
                        
   wait until falling_edge(SysClk100);       
   if (kExtRelayConfigEn = true) then
      -- If static relay configuration is used no further relay state
      -- modifications are possible.    
      -- For dynamic control, the first test performed is the
      -- reset of Ch1 coupling select relay.
      sCh1CouplingConfig <= '1'; 
      sCh2CouplingConfig <= kCh2CouplingConfigInit;
      sCh1GainConfig <= kCh1GainConfigInit;
      sCh2GainConfig <= kCh2GainConfigInit;
      -- Check if the above command produced a change in the relay state.
      if (kCh1CouplingConfigInit /= '1') then
         wait until sInitDoneRelay = '1';
      end if;
      assert (sCh1CouplingState = '1')
         report "Ch1 coupling select relay state error after Ch1 coupling select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh2CouplingState = kCh2CouplingConfigInit)
         report "Ch2 coupling select relay state error after Ch1 coupling select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh1GainState = kCh1GainConfigInit)
         report "Ch1 gain select relay state error after Ch1 coupling select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh2GainState = kCh2GainConfigInit)
         report "Ch2 gain select relay state error after Ch1 coupling select relay reset" & LF & HT & HT 
         severity ERROR;    
      wait until falling_edge(SysClk100);

      -- Set Ch1 coupling select relay.
      sCh1CouplingConfig <= '0'; 
      sCh2CouplingConfig <= kCh2CouplingConfigInit;
      sCh1GainConfig <= kCh1GainConfigInit;
      sCh2GainConfig <= kCh2GainConfigInit;  
      wait until sInitDoneRelay = '1';
      assert (sCh1CouplingState = '0')
         report "Ch1 coupling select relay state error after Ch1 coupling select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh2CouplingState = kCh2CouplingConfigInit)
         report "Ch2 coupling select relay state error after Ch1 coupling select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh1GainState = kCh1GainConfigInit)
         report "Ch1 gain select relay state error after Ch1 coupling seect relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh2GainState = kCh2GainConfigInit)
         report "Ch2 gain select relay state error after Ch1 coupling select relay set" & LF & HT & HT 
         severity ERROR;    
      wait until falling_edge(SysClk100);

      -- Reset Ch2 coupling select relay.
      sCh1CouplingConfig <= '0'; 
      sCh2CouplingConfig <= '1';
      sCh1GainConfig <= kCh1GainConfigInit;
      sCh2GainConfig <= kCh2GainConfigInit;
      -- Check if the above command produced a change in the relay state.
      if (kCh2CouplingConfigInit /= '1') then
         wait until sInitDoneRelay = '1';
      end if;      
         assert (sCh1CouplingState = '0')
         report "Ch1 coupling select relay state error after Ch2 coupling select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh2CouplingState = '1')
         report "Ch2 coupling select relay state error after Ch2 coupling select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh1GainState = kCh1GainConfigInit)
         report "Ch1 gain select relay state error after Ch2 coupling select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh2GainState = kCh2GainConfigInit)
         report "Ch2 gain select relay state error after Ch2 coupling select relay reset" & LF & HT & HT 
         severity ERROR;    
      wait until falling_edge(SysClk100);
   
      -- Set Ch2 coupling select relay.
      sCh1CouplingConfig <= '0'; 
      sCh2CouplingConfig <= '0';
      sCh1GainConfig <= kCh1GainConfigInit;
      sCh2GainConfig <= kCh2GainConfigInit;      
      wait until sInitDoneRelay = '1';
      assert (sCh1CouplingState = '0')
         report "Ch1 coupling select relay state error after Ch2 coupling select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh2CouplingState = '0')
         report "Ch2 coupling select relay state error after Ch2 coupling select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh1GainState = kCh1GainConfigInit)
         report "Ch1 gain select relay state error after Ch2 coupling select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh2GainState = kCh2GainConfigInit)
         report "Ch2 gain select relay state error after Ch2 coupling select relay set" & LF & HT & HT 
         severity ERROR;    
      wait until falling_edge(SysClk100);    

      -- Reset Ch1 gain select relay.
      sCh1CouplingConfig <= '0'; 
      sCh2CouplingConfig <= '0';
      sCh1GainConfig <= '1';
      sCh2GainConfig <= kCh2GainConfigInit;
      -- Check if the above command produced a change in the relay state.
      if (sCh1GainConfig /= '1') then
         wait until sInitDoneRelay = '1';
      end if;       
      assert (sCh1CouplingState = '0')
         report "Ch1 coupling select relay state error after Ch1 gain select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh2CouplingState = '0')
         report "Ch2 coupling select relay state error after Ch1 gain select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh1GainState = '1')
         report "Ch1 gain select relay state error after Ch1 gain select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh2GainState = kCh2GainConfigInit)
         report "Ch2 gain select relay state error after Ch1 gain select relay reset" & LF & HT & HT 
         severity ERROR;    
      wait until falling_edge(SysClk100);
   
      -- Set Ch1 gain select relay.
      sCh1CouplingConfig <= '0'; 
      sCh2CouplingConfig <= '0';
      sCh1GainConfig <= '0';
      sCh2GainConfig <= kCh2GainConfigInit;     
      wait until sInitDoneRelay = '1';
      assert (sCh1CouplingState = '0')
         report "Ch1 coupling select relay state error after Ch1 gain select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh2CouplingState = '0')
         report "Ch2 coupling select relay state error after Ch1 gain select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh1GainState = '0')
         report "Ch1 gain select relay state error after Ch1 gain select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh2GainState = kCh2GainConfigInit)
         report "Ch2 gain select relay state error after Ch1 gain select relay set" & LF & HT & HT 
         severity ERROR;    
      wait until falling_edge(SysClk100); 

      -- Reset Ch2 gain select relay.
      sCh1CouplingConfig <= '0'; 
      sCh2CouplingConfig <= '0';
      sCh1GainConfig <= '0';
      sCh2GainConfig <= '1';
      -- Check if the above command produced a change in the relay state.
      if (sCh2GainConfig /= '1') then
         wait until sInitDoneRelay = '1';
      end if;      
      assert (sCh1CouplingState = '0')
         report "Ch1 coupling select relay state error after Ch2 gain select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh2CouplingState = '0')
         report "Ch2 coupling select relay state error after Ch2 gain select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh1GainState = '0')
         report "Ch1 gain select relay state error after Ch2 gain select relay reset" & LF & HT & HT 
         severity ERROR;
      assert (sCh2GainState = '1')
         report "Ch2 gain select relay state error after Ch2 gain select relay reset" & LF & HT & HT 
         severity ERROR;    
      wait until falling_edge(SysClk100);
   
      -- Set Ch2 gain select  relay.
      sCh1CouplingConfig <= '0'; 
      sCh2CouplingConfig <= '0';
      sCh1GainConfig <= '0';
      sCh2GainConfig <= '0';     
      wait until sInitDoneRelay = '1';
      assert (sCh1CouplingState = '0')
         report "Ch1 coupling select relay state error after Ch2 gain select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh2CouplingState = '0')
         report "Ch2 coupling select relay state error after Ch2 gain select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh1GainState = '0')
         report "Ch1 gain select relay state error after Ch2 gain select relay set" & LF & HT & HT 
         severity ERROR;
      assert (sCh2GainState = '0')
         report "Ch2 gain select relay state error after Ch2 gain select relay set" & LF & HT & HT 
         severity ERROR;    
      wait until falling_edge(SysClk100);  
   end if;       
   wait;
end process;

end Behavioral;
