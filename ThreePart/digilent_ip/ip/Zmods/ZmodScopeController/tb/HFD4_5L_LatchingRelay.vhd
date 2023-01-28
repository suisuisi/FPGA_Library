
-------------------------------------------------------------------------------
--
-- File: HFD4_5L_LatchingRelay.vhd
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
-- This module is designed to test the relay drive signals for the HFD4/4.5L
-- latching relay on the Zmod Scope family of products. The module checks if  
-- timing is respected, checks for illegal drive signal combinations and compares  
-- the expected relay state against the state determined based on the drive  
-- signals sequence.
--
-------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.PkgZmodADC.all;

entity HFD4_5L_LatchingRelay is
   Generic (
      -- Relay dynamic/static configuration
      kExtRelayConfigEn : boolean := false;
      -- Relay static configuration option; after initialization the relay state
      -- determined based on the relay drive signals must mach kRelayConfigStatic if
      -- kExtRelayConfigEn = false. 
      kRelayConfigStatic : std_logic := '0'  
   );
   Port (
      -- Relay dynamic configuration signal; after initialization the relay state
      -- determined based on the relay drive signals must mach sRelayConfig if
      -- kExtRelayConfigEn = true.  
      sRelayConfig : in std_logic;     
      -- Relay drive signals
      sRelayDriverH   : in std_logic;
      sRelayDriverL   : in std_logic;
      sRelayComH  : in std_logic;
      sRelayComL  : in std_logic
   );
end HFD4_5L_LatchingRelay;

architecture Behavioral of HFD4_5L_LatchingRelay is

begin

CheckSetup: process
begin
    -- Wait until now /= 0 ps.
    -- Check Idle condition
    if (now /= 0 ps) then
        assert ((sRelayDriverL = '0') and (sRelayDriverH = '0'))
            report "Relay drive signals idle state not respected." & LF & HT & HT 
            severity ERROR;
    end if;        
    -- Wait for first event on the drive signals when exiting idle condition
    wait until ((sRelayDriverH'event) or (sRelayDriverL'event));
    -- Check timing for set command
    if ((sRelayDriverH = '1') and (sRelayDriverL = '0') and (sRelayComH = '0') and (sRelayComL = '1')) then
        -- Wait for drive signals to change state (only transitioning to idle state is accepted at this step)
        wait until ((sRelayDriverH'event) or (sRelayDriverL'event) or (sRelayComH'event) or (sRelayComL'event));
        -- Check that the relay drive signals return to idle state
        assert ((sRelayDriverL = '0') and (sRelayDriverH = '0') and (sRelayComL = '0') and (sRelayComH = '0'))
            report "Relay drive signals do not return to idle state after relay set/reset operation" & LF & HT & HT 
            severity ERROR;
                
        assert ((sRelayDriverL'delayed'last_event  >= kRelayConfigTime))
            report "Relay configuration time smaller than kRelayConfigTime for relay driver low." & LF & HT & HT &
                   "Expected: " & time'image(kRelayConfigTime) & LF & HT & HT &
                   "Actual: " & time'image(sRelayDriverL'delayed'last_event)
            severity ERROR;
        assert ((sRelayDriverH'delayed'last_event  >= kRelayConfigTime))
            report "Relay configuration time smaller than kRelayConfigTime for relay driver high." & LF & HT & HT &
                   "Expected: " & time'image(kRelayConfigTime) & LF & HT & HT &
                   "Actual: " & time'image(sRelayDriverH'delayed'last_event)
            severity ERROR;                
        assert ((sRelayComL'delayed'last_event  >= kRelayConfigTime))
            report "Relay configuration time smaller than kRelayConfigTime for relay com low." & LF & HT & HT &
                   "Expected: " & time'image(kRelayConfigTime) & LF & HT & HT &
                   "Actual: " & time'image(sRelayComH'delayed'last_event)
            severity ERROR;
        assert ((sRelayComH'delayed'last_event  >= kRelayConfigTime))
            report "Relay configuration time smaller than kRelayConfigTime for relay com high." & LF & HT & HT &
                   "Expected: " & time'image(kRelayConfigTime) & LF & HT & HT &
                   "Actual: " & time'image(sRelayComL'delayed'last_event)
            severity ERROR;
        if (kExtRelayConfigEn = true) then
            -- Check if the command that triggered the event was a relay set command       
            assert (sRelayConfig = '1')
                report "Relay state does not coincide with dynamic prescribed state." & LF & HT & HT &
                       "RelayState: " & std_logic'image('1') & LF & HT & HT &
                       "RelayCommand: " & std_logic'image(sRelayConfig) & LF & HT & HT 
                severity ERROR;            
        else
            assert (kRelayConfigStatic = '1')
                report "Relay state does not coincide with static prescribed state." & LF & HT & HT 
                severity ERROR;  
        end if; 
            
    -- Check timing for reset command                                   
    elsif ((sRelayDriverH = '0') and (sRelayDriverL = '1') and (sRelayComH = '1') and (sRelayComL = '0')) then
        -- Wait for drive signals to change state (only transitioning to idle state is accepted at this step)
        wait until ((sRelayDriverH'event) or (sRelayDriverL'event));
        -- Check that the relay drive signals return to idle state
        assert ((sRelayDriverL = '0') and (sRelayDriverH = '0') and (sRelayComL = '0') and (sRelayComH = '0'))
            report "Relay drive signals do not return to idle state after rela set/reset operation" & LF & HT & HT 
        severity ERROR;
                
        assert ((sRelayDriverL'delayed'last_event  >= kRelayConfigTime))
            report "Relay configuration time smaller than kRelayConfigTime for relay driver low." & LF & HT & HT &
                   "Expected: " & time'image(kRelayConfigTime) & LF & HT & HT &
                   "Actual: " & time'image(sRelayDriverL'delayed'last_event)
            severity ERROR;
        assert ((sRelayDriverH'delayed'last_event  >= kRelayConfigTime))
            report "Relay configuration time smaller than kRelayConfigTime for relay driver high." & LF & HT & HT &
                   "Expected: " & time'image(kRelayConfigTime) & LF & HT & HT &
                   "Actual: " & time'image(sRelayDriverH'delayed'last_event)
            severity ERROR;                
        assert ((sRelayComL'delayed'last_event  >= kRelayConfigTime))
            report "Relay configuration time smaller than kRelayConfigTime for relay com low." & LF & HT & HT &
                   "Expected: " & time'image(kRelayConfigTime) & LF & HT & HT &
                   "Actual: " & time'image(sRelayComH'delayed'last_event)
            severity ERROR;
        assert ((sRelayComH'delayed'last_event  >= kRelayConfigTime))
            report "Relay configuration time smaller than kRelayConfigTime for relay com high." & LF & HT & HT &
                   "Expected: " & time'image(kRelayConfigTime) & LF & HT & HT &
                   "Actual: " & time'image(sRelayComL'delayed'last_event)
            severity ERROR;
        if (kExtRelayConfigEn = true) then
            -- Check if the command that triggered the event was a relay reset command       
            assert (sRelayConfig = '0')
                report "Relay state does not coincide with dynamic prescribed state." & LF & HT & HT &
                       "RelayState: " & std_logic'image('0') & LF & HT & HT &
                       "RelayCommand: " & std_logic'image(sRelayConfig) & LF & HT & HT 
                severity ERROR;            
        else
            assert (kRelayConfigStatic = '0')
                report "Relay state does not coincide with static prescribed state." & LF & HT & HT 
                severity ERROR;  
        end if;       
     
    -- For any other event on the com signals (other relays configured) sRelayDriverH 
    -- and sRelayDriverL must be '0'        
    elsif ((sRelayDriverH /= '0') or (sRelayDriverL /= '0')) then 
        report "Invalid relay driver drive signal combinations." & LF & HT & HT &
               "sRelayDriverH: " & std_logic'image(sRelayDriverH) & LF & HT & HT &
               "sRelayDriverL: " & std_logic'image(sRelayDriverL) & LF & HT & HT &
               "sRelayComH: " & std_logic'image(sRelayComH) & LF & HT & HT &
               "sRelayComL: " & std_logic'image(sRelayComL) 
        severity ERROR; 
    end if; 
 end process CheckSetup;

end Behavioral;
