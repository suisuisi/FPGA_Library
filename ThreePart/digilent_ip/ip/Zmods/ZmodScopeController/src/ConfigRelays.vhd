
-------------------------------------------------------------------------------
--
-- File: ConfigRelays.vhd
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
-- This module handles relay configuration. Both static (from GUI parameters) 
-- and dynamic (using external configuration signals) are supported. Configuration
-- timing requirements are extracted from the HFD4/4.5L relay data sheet.
--  
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.PkgZmodADC.all;

entity ConfigRelays is
   Generic (
      -- Relay dynamic/static configuration.
      kExtRelayConfigEn : boolean := false;
      -- Channel1 coupling select relay (static configuration).
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling).
      kCh1CouplingStatic : std_logic := '0';
      -- Channel2 coupling select relay (static configuration)
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling). 
      kCh2CouplingStatic : std_logic := '0'; 
      -- Channel1 gain select relay (static configuration) 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain).
      kCh1GainStatic : std_logic := '0'; 
      -- Channel2 gain select relay (static configuration) 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain).  
      kCh2GainStatic : std_logic := '0';
	  kSimulation: boolean := false
   );
   Port (
      -- 100MHZ clock input. 
      SysClk100 : in STD_LOGIC;
      -- Reset signal asynchronously asserted and synchronously 
      -- de-asserted (in SysClk100 domain).
      asRst_n : in STD_LOGIC;
      
      -- Relay configuration signals
      
      -- Channel1 coupling select relay (dynamic configuration)
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling).
      sCh1CouplingConfig : in std_logic;
      -- Channel2 coupling select relay (dynamic configuration - optional)
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling).      
      sCh2CouplingConfig : in std_logic;
      -- Channel1 gain select relay (dynamic configuration - optional) 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain).     
      sCh1GainConfig : in std_logic;
      -- Channel2 gain select relay (dynamic configuration - optional) 
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain);.            
      sCh2GainConfig : in std_logic;
               
      -- Relay status signals 
      
      -- Channel1 coupling select relay status:
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling).
      sCh1CouplingState : out std_logic;
      -- Channel2 coupling select relay status:
      -- 1 -> Relay Set (DC coupling); 0 -> Relay Reset (AC coupling).
      sCh2CouplingState : out std_logic;
      -- Channel1 gain select relay status:
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain). 
      sCh1GainState : out std_logic;
      -- Channel2 gain select relay status:
      -- 1 -> Relay Set (High Gain); 0 -> Relay Reset (Low Gain). 
      sCh2GainState : out std_logic;
      
      --Relay drive signals (Zmod relay drive interface)
      
      sCh1CouplingH   : out std_logic := '0';
      sCh1CouplingL   : out std_logic := '0';
      sCh2CouplingH   : out std_logic := '0';
      sCh2CouplingL   : out std_logic := '0';
      sCh1GainH   : out std_logic := '0';
      sCh1GainL   : out std_logic := '0';
      sCh2GainH   : out std_logic := '0';
      sCh2GainL   : out std_logic := '0';
      sRelayComH  : out std_logic := '0';
      sRelayComL  : out std_logic := '0';
      -- Flag indicating when the Zmod's relay initialization is complete. 
      -- Whenever one of the Zmod's relays is requested to change state by 
      -- one of the configuration ports, sInitDoneRelay is de-asserted until 
      -- the relay is configured in the requested state.
      sInitDoneRelay     : out std_logic := '0';
      -- HandshakeData clock domain crossing iPush signal used to push
      -- the sInitDoneRelay signal into the ADC_SamplingClk domain.
      -- The output of the HandshakeData module will be used by the  
      -- DataPath_inst module to control the synchronization FIFO write 
      -- enable and reset behavior.
      sInitDoneRelayPush : out std_logic := '0';
      -- HandshakeData clock domain crossing iRdy signal used to determine
      -- when sInitDoeRelay has propagated to the ADC_SamplingClk domain.
      sInitDoneRelayRdy  : in std_logic
      );
end ConfigRelays;

architecture Behavioral of ConfigRelays is

signal sCh1_AC_DC, sCh2_AC_DC, sCh1_HG_LG, sCh2_HG_LG : std_logic;
signal sCh1_AC_DC_R, sCh2_AC_DC_R, sCh1_HG_LG_R, sCh2_HG_LG_R : std_logic;
signal sCh1TrigCouplingConfig, sCh2TrigCouplingConfig : std_logic;
signal sCh1TrigGainConfig, sCh2TrigGainConfig : std_logic;
signal sCh1TrigCouplingConfigFsm, sCh2TrigCouplingConfigFsm : std_logic;
signal sCh1TrigGainConfigFsm, sCh2TrigGainConfigFsm : std_logic;
signal sCh1TrigCouplingConfigPulse, sCh2TrigCouplingConfigPulse : std_logic;
signal sCh1TrigGainConfigPulse, sCh2TrigGainConfigPulse : std_logic;

signal sCh1GainStateLoc, sCh2GainStateLoc : std_logic := '0';
signal sCh1CouplingStateLoc, sCh2CouplingStateLoc : std_logic := '0';
-- Timers
signal sRelayTimer : unsigned (23 downto 0);
signal sRelayTimerRst_n : std_logic;
-- Initialization done flag
signal sInitDoneRelay_Fsm : std_logic;
signal sInitDonePushFsm : std_logic;
signal sInitDoneRdyRising : std_logic := '0';
signal sInitDoneRdyDly : std_logic := '0';
-- State machine
signal sCurrentState : FsmStatesRelays_t := StStart; 
signal sNextState : FsmStatesRelays_t;
-- signals used for debug purposes
-- signal fsmcfg_state, fsmcfg_state_r : std_logic_vector(5 downto 0); 
signal sCount4msVal : unsigned(kCount4ms'range);

begin

sCount4msVal <= kCount4msSim when kSimulation else
                kCount4ms;

sCh1CouplingState <= sCh1CouplingStateLoc;
sCh2CouplingState <= sCh2CouplingStateLoc;
sCh1GainState <= sCh1GainStateLoc;
sCh2GainState <= sCh2GainStateLoc;

--Channel1 AC/DC setting (output port or IP parameter).           
sCh1_AC_DC <= sCh1CouplingConfig when kExtRelayConfigEn = true else kCh1CouplingStatic;
--Channel2 AC/DC setting (output port or IP parameter). 
sCh2_AC_DC <= sCh2CouplingConfig when kExtRelayConfigEn = true else kCh2CouplingStatic;
--Channel1 High Gain/Low Gain setting (output port or IP parameter). 
sCh1_HG_LG <= sCh1GainConfig when kExtRelayConfigEn = true else kCh1GainStatic;
--Channel2 High Gain/Low Gain setting setting (output port or IP parameter).  
sCh2_HG_LG <= sCh2GainConfig when kExtRelayConfigEn = true else kCh2GainStatic;  

-- Process that generates the external relay drive signals.
-- (Zmod Scope relay drive interface).
ProcRelayReg: process (SysClk100, asRst_n)  
begin
   if (asRst_n = '0') then
      sCh1CouplingH <= '0';
      sCh1CouplingL <= '0';
      sCh2CouplingH <= '0';
      sCh2CouplingL <= '0';
      sCh1GainH <= '0';
      sCh1GainL <= '0';
      sCh2GainH <= '0';
      sCh2GainL <= '0';
      sRelayComH <= '0';
      sRelayComL <= '0';
      sCh1CouplingStateLoc <= '0';
      sCh2CouplingStateLoc <= '0';
      sCh1GainStateLoc <= '0';
      sCh2GainStateLoc <= '0';
   elsif (rising_edge(SysClk100)) then
      sCh1CouplingH <= '0';
      sCh1CouplingL <= '0';
      sCh2CouplingH <= '0';
      sCh2CouplingL <= '0';
      sCh1GainH <= '0';
      sCh1GainL <= '0';
      sCh2GainH <= '0';
      sCh2GainL <= '0';
      sRelayComH <= '0';
      sRelayComL <= '0';
      if (sCh1TrigCouplingConfig = '1') then 
         if (sCh1_AC_DC_R = '1') then 
            -- Channel1 coupling config relay set -> DC Coupling
            sCh1CouplingH <= '1';
            sCh1CouplingL <= '0';
            sRelayComH <= '0';
            sRelayComL <= '1';
            if (sRelayTimer = sCount4msVal) then
               sCh1CouplingStateLoc <= '1';
            end if;                    
         else                      
            -- Channel1 coupling config relay reset -> AC Coupling
            sCh1CouplingH <= '0';
            sCh1CouplingL <= '1';
            sRelayComH <= '1';
            sRelayComL <= '0';
            if (sRelayTimer = sCount4msVal) then
               sCh1CouplingStateLoc <= '0';
            end if;                    
         end if;
      elsif (sCh2TrigCouplingConfig = '1') then
         if (sCh2_AC_DC_R = '1') then 
            -- Channel2 coupling config relay set -> DC Coupling
            sCh2CouplingH <= '1';
            sCh2CouplingL <= '0';
            sRelayComH <= '0';
            sRelayComL <= '1';
            if (sRelayTimer = sCount4msVal) then
               sCh2CouplingStateLoc <= '1';
            end if;                    
         else                      
            -- Channel2 coupling config relay reset -> AC Coupling
            sCh2CouplingH <= '0';
            sCh2CouplingL <= '1';
            sRelayComH <= '1';
            sRelayComL <= '0';
            if (sRelayTimer = sCount4msVal) then
               sCh2CouplingStateLoc <= '0';
            end if;                     
         end if;
      elsif (sCh1TrigGainConfig = '1') then
         if (sCh1_HG_LG_R = '1') then 
            -- Channel1 gain config relay set -> High Gain
            sCh1GainH <= '1';
            sCh1GainL <= '0';
            sRelayComH <= '0';
            sRelayComL <= '1';
            if (sRelayTimer = sCount4msVal) then
               sCh1GainStateLoc <= '1';
            end if;
         else
            -- Channel1 gain config relay reset -> Low Gain
            sCh1GainH <= '0';
            sCh1GainL <= '1';
            sRelayComH <= '1';
            sRelayComL <= '0';
            if (sRelayTimer = sCount4msVal) then
               sCh1GainStateLoc <= '0';
            end if;
         end if;
      elsif (sCh2TrigGainConfig = '1') then  
         if (sCh2_HG_LG_R = '1') then 
            -- Channel2 gain config relay set -> High Gain
            sCh2GainH <= '1';
            sCh2GainL <= '0';
            sRelayComH <= '0';
            sRelayComL <= '1';
            if (sRelayTimer = sCount4msVal) then
               sCh2GainStateLoc <= '1';
            end if;
         else                      
            -- Channel2 gain config relay reset -> Low Gain
            sCh2GainH <= '0';
            sCh2GainL <= '1';
            sRelayComH <= '1';
            sRelayComL <= '0';
            if (sRelayTimer = sCount4msVal) then
               sCh2GainStateLoc <= '0';
            end if;
         end if;   
      end if;
   end if;
end process;

-- Counter used to time the set and reset intervals of the latching relays.
ProcRelayTimer: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sRelayTimer <= (others => '0');
   elsif (rising_edge(SysClk100)) then
      if (sRelayTimerRst_n = '0') then
         sRelayTimer <= (others => '0');
      else
         sRelayTimer <= sRelayTimer + 1;     
      end if;
   end if;
end process;

-- Register relay  initialization done related FSM outputs. The initialization
-- done signal is pushed into the ADC_SamplingClk domain through a HandshakeData
-- module in the top level design. 
ProcInitDoneReg: process (SysClk100, asRst_n)  
begin
   if (asRst_n = '0') then
      sInitDoneRelay <= '0';
      sInitDoneRelayPush  <= '0';
   elsif (rising_edge(SysClk100)) then
      sInitDoneRelay <= sInitDoneRelay_Fsm;
      sInitDoneRelayPush <= sInitDonePushFsm;
    end if;
end process;

-- The following section generates a pulse when the HandshakeData
-- module's iRdy signal is asserted high. This pulse is used by
-- the state machine to detect when the relay initialization done
-- signal has propagated to the destination lock domain.
ProcInitDoneRdyDly: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sInitDoneRdyDly <= '0';
   elsif (rising_edge(SysClk100)) then
      sInitDoneRdyDly <= sInitDoneRelayRdy;           
   end if;
end process;

sInitDoneRdyRising <= sInitDoneRelayRdy and (not sInitDoneRdyDly);

-- The following section generates a pulse indicating that the state machine is  
-- ready to process a relay configuration command (individually, for each channel). 
-- The corresponding relay configuration input is registered on this pulse. Further
-- relay state change requests are ignored until the state machine is in the idle
-- state.
ProcTrigConfigReg: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sCh1TrigGainConfig <= '0';
      sCh2TrigGainConfig <= '0';
      sCh1TrigCouplingConfig <= '0';
      sCh2TrigCouplingConfig <= '0';
   elsif (rising_edge(SysClk100)) then
      sCh1TrigGainConfig <= sCh1TrigGainConfigFsm;
      sCh2TrigGainConfig <= sCh2TrigGainConfigFsm;         
      sCh1TrigCouplingConfig <= sCh1TrigCouplingConfigFsm;
      sCh2TrigCouplingConfig <= sCh2TrigCouplingConfigFsm;           
   end if;
end process;

sCh1TrigGainConfigPulse <= sCh1TrigGainConfigFsm and (not sCh1TrigGainConfig);
sCh2TrigGainConfigPulse <= sCh2TrigGainConfigFsm and (not sCh2TrigGainConfig);
sCh1TrigCouplingConfigPulse <= sCh1TrigCouplingConfigFsm and (not sCh1TrigCouplingConfig);
sCh2TrigCouplingConfigPulse <= sCh2TrigCouplingConfigFsm and (not sCh2TrigCouplingConfig);

ProcCh1_AC_DC_Reg: process (SysClk100, asRst_n)  
begin
   if (asRst_n = '0') then
      sCh1_AC_DC_R <= '0';
   elsif (rising_edge(SysClk100)) then
      if (sCh1TrigCouplingConfigPulse = '1') then
         sCh1_AC_DC_R <= sCh1_AC_DC;
      end if;           
   end if;
end process;
 
ProcCh2_AC_DC_Reg: process (SysClk100, asRst_n)  
begin
   if (asRst_n = '0') then
      sCh2_AC_DC_R <= '0';
   elsif (rising_edge(SysClk100)) then
      if (sCh2TrigCouplingConfigPulse = '1') then
         sCh2_AC_DC_R <= sCh2_AC_DC;
      end if;           
   end if;
end process;

ProcCh1_HG_LG_Reg: process (SysClk100, asRst_n)  
begin
   if (asRst_n = '0') then
      sCh1_HG_LG_R <= '0';
   elsif (rising_edge(SysClk100)) then
      if (sCh1TrigGainConfigPulse = '1') then
         sCh1_HG_LG_R <= sCh1_HG_LG;
      end if;           
   end if;
end process;

ProcCh2_HG_LG_Reg: process (SysClk100, asRst_n)   
begin
   if (asRst_n = '0') then
      sCh2_HG_LG_R <= '0';
   elsif (rising_edge(SysClk100)) then
      if (sCh2TrigGainConfigPulse = '1') then
         sCh2_HG_LG_R <= sCh2_HG_LG;
      end if;           
   end if;
end process;

-- Relay configuration state machine.

-- Synchronous Process.
ProcSyncFsm: process (SysClk100, asRst_n)
begin
   if (asRst_n = '0') then
      sCurrentState <= StStart;
      --fsmcfg_state_r <= (others => '0');
   elsif (rising_edge(SysClk100)) then
      sCurrentState <= sNextState;
      --fsmcfg_state_r <= fsmcfg_state;
   end if;        
end process;

-- Next state and output decode process.      
ProcNextStateAndOutputDecode: process (sCurrentState, sRelayTimer, sCh1CouplingStateLoc,
sInitDoneRdyRising, sCh2CouplingStateLoc, sCh1GainStateLoc, sCh2GainStateLoc, sCh1_AC_DC,
sCh2_AC_DC, sCh1_HG_LG, sCh2_HG_LG, sCount4msVal)
begin         
   sNextState <= sCurrentState;  
   --fsmcfg_state <= "000000";
   sCh1TrigGainConfigFsm <= '0';
   sCh2TrigGainConfigFsm <= '0';
   sCh1TrigCouplingConfigFsm <= '0';
   sCh2TrigCouplingConfigFsm <= '0';
   sRelayTimerRst_n <= '0';
   sInitDoneRelay_Fsm <= '0';
   sInitDonePushFsm <= '0';
                  
   case (sCurrentState) is
      when StStart =>
         --fsmcfg_state <= "000000";
         sNextState <= StConfigCouplingCh1;
      
      -- Initialization
                
      when StConfigCouplingCh1 => 
      -- Configure AC/DC coupling for channel1.
         --fsmcfg_state <= "000001";
         sRelayTimerRst_n <= '1';
         sCh1TrigCouplingConfigFsm <= '1';
         if (sRelayTimer = sCount4msVal) then
            sNextState <= StConfigCouplingCh1Rst;
         end if;   
                  
      when StConfigCouplingCh1Rst =>  
      -- Reset relay timer.
         --fsmcfg_state <= "000010"; 
         sNextState <= StConfigCouplingCh2; 
                
      when StConfigCouplingCh2 => 
      -- Configure AC/DC coupling for channel2. 
         --fsmcfg_state <= "000011";
         sRelayTimerRst_n <= '1';
         sCh2TrigCouplingConfigFsm <= '1';
         if (sRelayTimer = sCount4msVal) then
            sNextState <= StConfigCouplingCh2Rst;
         end if;
                
      when StConfigCouplingCh2Rst => 
      -- Reset relay timer
         --fsmcfg_state <= "000100";
         sNextState <= StConfigGainCh1; 

      when StConfigGainCh1 =>  
      -- Configure High Gain/Low Gain coupling for channel1.
         --fsmcfg_state <= "000101";
         sRelayTimerRst_n <= '1';
         sCh1TrigGainConfigFsm <= '1';
         if (sRelayTimer = sCount4msVal) then
            sNextState <= StConfigGainCh1Rst;
         end if;
                
      when StConfigGainCh1Rst =>  
      -- reset relay timer
         --fsmcfg_state <= "000111"; 
         sNextState <= StConfigGainCh2; 
                
      when StConfigGainCh2 =>   
      -- Configure High Gain/Low Gain coupling for channel2.
         --fsmcfg_state <= "001000";
         sRelayTimerRst_n <= '1';
         sCh2TrigGainConfigFsm <= '1';
         if (sRelayTimer = sCount4msVal) then
            sNextState <= StConfigGainCh2Rst;
         end if;
                
      when StConfigGainCh2Rst =>  
      -- Reset relay timer
         --fsmcfg_state <= "001001";
         sNextState <= StPushInitDone;                                        
                 
      when StPushInitDone =>  
      --indicate the initialization sequence has completed.
         --fsmcfg_state <= "001010";
         sInitDoneRelay_Fsm <= '1';
         --Push the sInitDoneRelay into the ADC_SamplingClk domain.
         sInitDonePushFsm <= '1';
         sNextState <= StWaitRdy; 
         
      when StWaitRdy =>
      -- When in StIdle the HandshakeData synchronization module must be ready
      -- to push the state of sInitDoneRelay signal in the ADC_SamplingClk domain.
         --fsmcfg_state <= "001011";
         sInitDoneRelay_Fsm <= '1';
         if (sInitDoneRdyRising = '1') then
            sNextState <= StIdle;
         end if;
      
      -- Normal operation; the state machine monitors the configuration inputs and
      -- reacts upon input configuration signals state changes.
             
      when StIdle =>  
      --IDLE state; wait for changes on the relay configuration signals.
         --fsmcfg_state <= "001100";
         sInitDoneRelay_Fsm <= '1';
         if (sCh1CouplingStateLoc /= sCh1_AC_DC) then
            sInitDoneRelay_Fsm <= '0';
            sInitDonePushFsm <= '1';
            sNextState <= StWaitAckCouplingCh1;
         elsif (sCh2CouplingStateLoc /= sCh2_AC_DC) then
            sInitDoneRelay_Fsm <= '0';
            sInitDonePushFsm <= '1';
            sNextState <= StWaitAckCouplingCh2;
         elsif (sCh1GainStateLoc /= sCh1_HG_LG) then
            sInitDoneRelay_Fsm <= '0';
            sInitDonePushFsm <= '1';
            sNextState <= StWaitAckGainCh1;
         elsif (sCh2GainStateLoc /= sCh2_HG_LG) then
            sInitDoneRelay_Fsm <= '0';
            sInitDonePushFsm <= '1';
            sNextState <= StWaitAckGainCh2;    
         else
            sNextState <= StIdle;
         end if;

      when StWaitAckCouplingCh1 => 
      -- Wait for sInitDoneRelay to propagate in the ADC_SamplingClk domain.
         --fsmcfg_state <= "001101";
         if (sInitDoneRdyRising = '1') then
            sNextState <= StChangeCouplingCh1;
         end if;  
               
      when StChangeCouplingCh1 => 
      -- Configure AC/DC coupling for channel1 in response to a configuration input
      -- state change.
         --fsmcfg_state <= "001110";
         sRelayTimerRst_n <= '1';
         sCh1TrigCouplingConfigFsm <= '1';
         if (sRelayTimer = sCount4msVal) then
            sNextState <= StRstCfgPulse;
         end if;   
 
      when StWaitAckCouplingCh2 => 
      -- Wait for sInitDoneRelay to propagate in the ADC_SamplingClk domain.
         --fsmcfg_state <= "001111";
         if (sInitDoneRdyRising = '1') then
            sNextState <= StChangeCouplingCh2;
         end if;  
                        
      when StChangeCouplingCh2 => 
      -- Configure AC/DC coupling for channel2 in response to a configuration input
      -- state change.
         --fsmcfg_state <= "010000";
         sRelayTimerRst_n <= '1';
         sCh2TrigCouplingConfigFsm <= '1';
         if (sRelayTimer = sCount4msVal) then
            sNextState <= StRstCfgPulse;
         end if;

      when StWaitAckGainCh1 => 
      -- Wait for sInitDoneRelay to propagate in the ADC_SamplingClk domain.
         --fsmcfg_state <= "010001";
         if (sInitDoneRdyRising = '1') then
            sCh1TrigGainConfigFsm <= '1';
            sNextState <= StChangeGainCh1;
         end if; 
               
      when StChangeGainCh1 => 
      -- Configure High Gain/Low gain coupling for channel1 in response to a configuration 
      -- input state change.
         --fsmcfg_state <= "010010";
         sRelayTimerRst_n <= '1';
         sCh1TrigGainConfigFsm <= '1';
         if (sRelayTimer = sCount4msVal) then
            sNextState <= StRstCfgPulse;
         end if;

      when StWaitAckGainCh2 => 
      -- Wait for sInitDoneRelay to propagate in the ADC_SamplingClk domain.
         --fsmcfg_state <= "010011";
         if (sInitDoneRdyRising = '1') then
            sNextState <= StChangeGainCh2;
         end if; 
                         
      when StChangeGainCh2 =>  
      -- Configure High Gain/Low gain coupling for channel2 in response to a configuration 
      -- input state change.
         --fsmcfg_state <= "010100";
         sRelayTimerRst_n <= '1';
         sCh2TrigGainConfigFsm <= '1';
         if (sRelayTimer = sCount4msVal) then
            sNextState <= StRstCfgPulse;
         end if;    
      
      when StRstCfgPulse =>  
      -- Reset configuration trigger pulses.
         --fsmcfg_state <= "010101";
         sNextState <= StPushInitDone;                                                            
                                                   
      when others =>
         sNextState <= StStart;
   end case;      
end process; 
      
end Behavioral;
