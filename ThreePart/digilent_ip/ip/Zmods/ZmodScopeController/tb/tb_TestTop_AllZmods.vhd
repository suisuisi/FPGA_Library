
-------------------------------------------------------------------------------
--
-- File: tb_TestTop_AllZmods.vhd
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
-- This test bench is used to instantiate the tb_TestTop test bench for all
-- supported ZmodADC variants.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.PkgZmodADC.all;

entity tb_TestTop_AllZmods is

end tb_TestTop_AllZmods;

architecture Behavioral of tb_TestTop_AllZmods is

constant kSamplingPeriod : integer range 2500 to 100000:= 17000;
constant kExtRelayConfigEn : boolean := true;
constant kExtCalibEn : boolean := true; 
constant kExtCmdInterfaceEn : boolean := true;
constant kExtSyncEn : boolean := true;
constant kCh1CouplingStatic : std_logic := '0';
constant kCh2CouplingStatic : std_logic := '0'; 
constant kCh1GainStatic : std_logic := '0'; 
constant kCh2GainStatic : std_logic := '0';       
constant kCh1LgMultCoefStatic : std_logic_vector (17 downto 0) := "010001101010110010";
constant kCh1LgAddCoefStatic : std_logic_vector (17 downto 0) := "111111101111010101";
constant kCh1HgMultCoefStatic : std_logic_vector (17 downto 0) := "010001101010100010";  
constant kCh1HgAddCoefStatic : std_logic_vector (17 downto 0) := "111111101111000101";  
constant kCh2LgMultCoefStatic : std_logic_vector (17 downto 0) := "010001101010010010";  
constant kCh2LgAddCoefStatic : std_logic_vector (17 downto 0) := "111111101101010101"; 
constant kCh2HgMultCoefStatic : std_logic_vector (17 downto 0) := "010001101000110010"; 
constant kCh2HgAddCoefStatic : std_logic_vector (17 downto 0) := "111111101111010001";    
     
begin

------------------------------------------------------------------------------------------
-- Top level test bench instantiated for all supported Zmod ADC variants
------------------------------------------------------------------------------------------ 
   
InstTbTestTop_ZmodADC1410_105: entity work.tb_TestTop
   Generic Map(
      kZmodID => kZmodScope1410_105,
      kSamplingPeriod => kSamplingPeriod,
      kADC_ClkDiv => 4,
      kExtRelayConfigEn => kExtRelayConfigEn,
      kExtCalibEn => kExtCalibEn, 
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,
      kExtSyncEn => kExtSyncEn,
      kCh1CouplingStatic => kCh1CouplingStatic, 
      kCh2CouplingStatic => kCh2CouplingStatic, 
      kCh1GainStatic => kCh1GainStatic,
      kCh2GainStatic => kCh2GainStatic,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic	  
   );

InstTbTestTop_ZmodADC1010_40: entity work.tb_TestTop
   Generic Map(
      kZmodID => kZmodScope1010_40,
      kSamplingPeriod => kSamplingPeriod,
      kADC_ClkDiv => 4,
      kExtRelayConfigEn => kExtRelayConfigEn,
      kExtCalibEn => kExtCalibEn, 
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,
      kExtSyncEn => kExtSyncEn,
      kCh1CouplingStatic => kCh1CouplingStatic, 
      kCh2CouplingStatic => kCh2CouplingStatic, 
      kCh1GainStatic => kCh1GainStatic,
      kCh2GainStatic => kCh2GainStatic,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic	  
   );

InstTbTestTop_ZmodADC1010_125: entity work.tb_TestTop
   Generic Map(
      kZmodID => kZmodScope1010_125,
      kSamplingPeriod => kSamplingPeriod,
      kADC_ClkDiv => 2,
      kExtRelayConfigEn => kExtRelayConfigEn,
      kExtCalibEn => kExtCalibEn, 
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,
      kExtSyncEn => kExtSyncEn,
      kCh1CouplingStatic => kCh1CouplingStatic, 
      kCh2CouplingStatic => kCh2CouplingStatic, 
      kCh1GainStatic => kCh1GainStatic,
      kCh2GainStatic => kCh2GainStatic,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic	  
   );

InstTbTestTop_ZmodADC1210_40: entity work.tb_TestTop
   Generic Map(
      kZmodID => kZmodScope1210_40,
      kSamplingPeriod => kSamplingPeriod,
      kADC_ClkDiv => 4,
      kExtRelayConfigEn => kExtRelayConfigEn,
      kExtCalibEn => kExtCalibEn, 
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,
      kExtSyncEn => kExtSyncEn,
      kCh1CouplingStatic => kCh1CouplingStatic, 
      kCh2CouplingStatic => kCh2CouplingStatic, 
      kCh1GainStatic => kCh1GainStatic,
      kCh2GainStatic => kCh2GainStatic,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic	  
   );

InstTbTestTop_ZmodADC1210_125: entity work.tb_TestTop
   Generic Map(
      kZmodID => kZmodScope1210_125,
      kSamplingPeriod => kSamplingPeriod,
      kADC_ClkDiv => 2,
      kExtRelayConfigEn => kExtRelayConfigEn,
      kExtCalibEn => kExtCalibEn, 
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,
      kExtSyncEn => kExtSyncEn,
      kCh1CouplingStatic => kCh1CouplingStatic, 
      kCh2CouplingStatic => kCh2CouplingStatic, 
      kCh1GainStatic => kCh1GainStatic,
      kCh2GainStatic => kCh2GainStatic,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic	  
   );

InstTbTestTop_ZmodADC1410_40: entity work.tb_TestTop
   Generic Map(
      kZmodID => kZmodScope1410_40,
      kSamplingPeriod => kSamplingPeriod,
      kADC_ClkDiv => 4,
      kExtRelayConfigEn => kExtRelayConfigEn,
      kExtCalibEn => kExtCalibEn, 
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,
      kExtSyncEn => kExtSyncEn,
      kCh1CouplingStatic => kCh1CouplingStatic, 
      kCh2CouplingStatic => kCh2CouplingStatic, 
      kCh1GainStatic => kCh1GainStatic,
      kCh2GainStatic => kCh2GainStatic,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic	  
   );

InstTbTestTop_ZmodADC1410_125: entity work.tb_TestTop
   Generic Map(
      kZmodID => kZmodScope1410_125,
      kSamplingPeriod => kSamplingPeriod,
      kADC_ClkDiv => 2,
      kExtRelayConfigEn => kExtRelayConfigEn,
      kExtCalibEn => kExtCalibEn, 
      kExtCmdInterfaceEn => kExtCmdInterfaceEn,
      kExtSyncEn => kExtSyncEn,
      kCh1CouplingStatic => kCh1CouplingStatic, 
      kCh2CouplingStatic => kCh2CouplingStatic, 
      kCh1GainStatic => kCh1GainStatic,
      kCh2GainStatic => kCh2GainStatic,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic	  
   );

end Behavioral;