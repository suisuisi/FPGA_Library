
-------------------------------------------------------------------------------
--
-- File: tb_TestConfigRelay_all.vhd
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
-- This test bench is used instantiate the tb_ConfigRelay test bench with  
-- various configuration options.
--
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_TestConfigRelay_all is
--  Port ( );
end tb_TestConfigRelay_all;

architecture Behavioral of tb_TestConfigRelay_all is
   
begin

-- Test the Relay configuration module with static relay setting.
-- All relays are configured in the set state.
InstConfigRelayStatic0: entity work.tb_TestConfigRelay
   Generic Map(
      kExtRelayConfigEn => false,
      kCh1CouplingConfigInit  => '0',
      kCh2CouplingConfigInit  =>'0',
      kCh1GainConfigInit  => '0',
      kCh2GainConfigInit  => '0'
   );

-- Test the Relay configuration module with static relay setting.
-- All relays are configured in the reset state.
InstConfigRelayStatic1: entity work.tb_TestConfigRelay
   Generic Map(
      kExtRelayConfigEn => false,
      kCh1CouplingConfigInit  => '1',
      kCh2CouplingConfigInit  =>'1',
      kCh1GainConfigInit  => '1',
      kCh2GainConfigInit  => '1'
   );
   
-- Test the Relay configuration module with the external configuration
-- enabled. The initial value of the configuration signals is '0'.
InstConfigRelayInit0: entity work.tb_TestConfigRelay
   Generic Map(
      kExtRelayConfigEn => true,
      kCh1CouplingConfigInit  => '0',
      kCh2CouplingConfigInit  =>'0',
      kCh1GainConfigInit  => '0',
      kCh2GainConfigInit  => '0'
   );

-- Test the Relay configuration module with the external configuration
-- enabled. The initial value of the configuration signals is '1'.
InstConfigRelayInit1: entity work.tb_TestConfigRelay
   Generic Map(
      kExtRelayConfigEn => true,
      kCh1CouplingConfigInit  => '1',
      kCh2CouplingConfigInit  =>'1',
      kCh1GainConfigInit  => '1',
      kCh2GainConfigInit  => '1'
   );   
end Behavioral;
