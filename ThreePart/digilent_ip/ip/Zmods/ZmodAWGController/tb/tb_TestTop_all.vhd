
-------------------------------------------------------------------------------
--
-- File: tb_TestTop_all.vhd
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
-- This test bench is used to instantiate the tb_TestTop test bench with
-- various options.
--  
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.PkgZmodDAC.all;

entity tb_TestTop_all is

end tb_TestTop_all;

architecture Behavioral of tb_TestTop_all is               

constant kCh1LgMultCoefStatic: std_logic_vector (17 downto 0) := "001110111010000100";
constant kCh1LgAddCoefStatic: std_logic_vector (17 downto 0) := "111111111011001100";
constant kCh1HgMultCoefStatic: std_logic_vector (17 downto 0) := "001111000001111001";
constant kCh1HgAddCoefStatic: std_logic_vector (17 downto 0) := "111111111101111111";
constant kCh2LgMultCoefStatic: std_logic_vector (17 downto 0) := "001110111110000001";
constant kCh2LgAddCoefStatic: std_logic_vector (17 downto 0) := "111111111100001000";
constant kCh2HgAddCoefStatic: std_logic_vector (17 downto 0) := "001111000011010110";
constant kCh2HgMultCoefStatic: std_logic_vector (17 downto 0) := "111111111110111101";   
constant kSysClkPeriod : time := 10ns;   
constant kDacClkPeriod : time := 10ns;
constant kDAC_Width : integer := 14;   
    
begin

------------------------------------------------------------------------------------------
--Top level component instantiation
------------------------------------------------------------------------------------------ 

-- Instantiate the top level test bench with dynamic configuration  of the scale
-- and calibration coefficients enabled.
InstExtCalibExtScale: entity work.tb_TestTop
   Generic Map(
      kSysClkPeriod => kSysClkPeriod,
      kDacClkPeriod => kDacClkPeriod,            
      kDAC_Width => kDAC_Width,
      kExtCalibEn => true, 
      kExtCmdInterfaceEn => true,
      kExtScaleConfigEn => true,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic,
      kCh1ScaleStatic => '0', 
      kCh2ScaleStatic => '0'  
   );

-- Instantiate the top level test bench with static configuration  of the scale
-- and dynamic configuration of the calibration coefficients. 
InstStaticCalibExtScale: entity work.tb_TestTop
   Generic Map(
      kSysClkPeriod => kSysClkPeriod,
      kDacClkPeriod => kDacClkPeriod,            
      kDAC_Width => kDAC_Width,
      kExtCalibEn => false, 
      kExtCmdInterfaceEn => true,
      kExtScaleConfigEn => true,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic,
      kCh1ScaleStatic => '0', 
      kCh2ScaleStatic => '0'  
   );
   
-- Instantiate the top level test bench with dynamic configuration  of the scale
-- and calibration coefficients disabled. The scale parameter is set to '0' for
-- both channels.
InstStaticCalibStaticScale00: entity work.tb_TestTop
   Generic Map(
      kSysClkPeriod => kSysClkPeriod,
      kDacClkPeriod => kDacClkPeriod,            
      kDAC_Width => kDAC_Width,
      kExtCalibEn => false, 
      kExtCmdInterfaceEn => true,
      kExtScaleConfigEn => false,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic,
      kCh1ScaleStatic => '0', 
      kCh2ScaleStatic => '0'  
   );

-- Instantiate the top level test bench with dynamic configuration  of the scale
-- and calibration coefficients disabled. The scale parameter is set to '1' for
-- both channels.
InstExtCalibStaticScale11: entity work.tb_TestTop
   Generic Map(
      kSysClkPeriod => kSysClkPeriod,
      kDacClkPeriod => kDacClkPeriod,            
      kDAC_Width => kDAC_Width,
      kExtCalibEn => true, 
      kExtCmdInterfaceEn => true,
      kExtScaleConfigEn => false,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic,
      kCh1ScaleStatic => '1', 
      kCh2ScaleStatic => '1'  
   );   

-- Instantiate the top level test bench with dynamic configuration  of the scale
-- and calibration coefficients disabled. The scale parameter is set to '0' for
-- channel 1 and to '1' for channel 2.
InstExtCalibStaticScale01: entity work.tb_TestTop
   Generic Map(
      kSysClkPeriod => kSysClkPeriod,
      kDacClkPeriod => kDacClkPeriod,            
      kDAC_Width => kDAC_Width,
      kExtCalibEn => true, 
      kExtCmdInterfaceEn => true,
      kExtScaleConfigEn => false,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic,
      kCh1ScaleStatic => '0', 
      kCh2ScaleStatic => '1'  
   );   

-- Instantiate the top level test bench with dynamic configuration  of the scale
-- and calibration coefficients disabled. The scale parameter is set to '1' for
-- channel 1 and to '10' for channel 2.
InstExtCalibStaticScale10: entity work.tb_TestTop
   Generic Map(
      kSysClkPeriod => kSysClkPeriod,
      kDacClkPeriod => kDacClkPeriod,            
      kDAC_Width => kDAC_Width,
      kExtCalibEn => true, 
      kExtCmdInterfaceEn => true,
      kExtScaleConfigEn => false,      
      kCh1LgMultCoefStatic => kCh1LgMultCoefStatic,
      kCh1LgAddCoefStatic => kCh1LgAddCoefStatic,
      kCh1HgMultCoefStatic => kCh1HgMultCoefStatic,
      kCh1HgAddCoefStatic => kCh1HgAddCoefStatic,
      kCh2LgMultCoefStatic => kCh2LgMultCoefStatic,
      kCh2LgAddCoefStatic => kCh2LgAddCoefStatic,
      kCh2HgMultCoefStatic => kCh2HgMultCoefStatic,
      kCh2HgAddCoefStatic => kCh2HgAddCoefStatic,
      kCh1ScaleStatic => '1', 
      kCh2ScaleStatic => '0'  
   );   
      
end Behavioral;