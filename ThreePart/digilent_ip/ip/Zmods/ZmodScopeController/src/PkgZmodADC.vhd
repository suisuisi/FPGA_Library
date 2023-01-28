
-------------------------------------------------------------------------------
--
-- File: PkgZmodADC.vhd
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
-- This package contains the constants and functions used for the
-- ZmodScpeController IP
--  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package PkgZmodADC is

-- Zmod Scope variants identifier
constant kZmodScope1410_105 : integer := 0; -- Zmod Scpe 1410 - 105 (AD9648)
constant kZmodScope1010_40  : integer := 1; -- Zmod Scpe 1010 - 40 (AD9204)
constant kZmodScope1010_125 : integer := 2; -- Zmod Scpe 1010 - 125 (AD9608) 
constant kZmodScope1210_40  : integer := 3; -- Zmod Scpe 1210 - 40 (AD9231)
constant kZmodScope1210_125 : integer := 4; -- Zmod Scpe 1210 - 125 (AD9628) 
constant kZmodScope1410_40  : integer := 5; -- Zmod Scpe 1410 - 40 (AD9251)
constant kZmodScope1410_125 : integer := 6; -- Zmod Scpe 1410 - 125 (AD9648)      
    
--Timing parameters
constant kSysClkPeriod : time := 10ns;              -- System Clock Period
constant ktS : time := 2 ns;                        -- Setup time between CSB and SCLK
constant ktH : time := 2 ns;                        -- Hold time between CSB and SCLK
constant ktDS : time := 2 ns;                       -- Setup time between the data and the rising edge of SCLK
constant ktDH : time := 2 ns;                       -- Hold time between the data and the rising edge of SCLK
constant ktclk : time := 40 ns;                     -- minimum period of the SCLK
constant kSclkHigh : time := 10 ns;                 -- SCLK pulse width high (min)
constant kSclkLow : time := 10 ns;                  -- SCLK pulse width low (min)
--constant kSclkT_Max : time := 10 ns;              -- SCLK pulse width low (min)
constant kSclkT_Min : time := 50 ns;                -- SCLK pulse width low (min)
constant kTdcoMax : time := 4.4 ns;
-- Relay Set and Reset signals in simulation. In real life, this constant should be equal to 3ms.
constant kRelayConfigTime : time := 3us;
--ADC Model Registers
constant aReg00_Mask : std_logic_vector(7 downto 0) := "01100110";

--Implementation constants
constant kCS_PulseWidthHigh : integer := 31;   --CS pulse width high not specified in AD9648
constant kSPI_DataWidth : integer := 8;        --ADI_SPI module data width
constant kSPI_CommandWidth : integer := 16;    --ADI_SPI module command width
constant kSPI_AddrWidth : integer := kSPI_CommandWidth - 3;    --ADI_SPI module command width
constant kSPI_SysClkDiv : integer := 4;       --ADI_SPI module system clock divide constant
                                              --No minimum SPI clock frequency specified by AD9648. The maximum frequency is 25MHz.

type ADC_SPI_Commands_t is array (19 downto 0) of std_logic_vector(23 downto 0);
type ADC_SPI_Readback_t is array (19 downto 0) of std_logic_vector(7 downto 0);
constant kAD96xx_SPI_Cmd : ADC_SPI_Commands_t := (x"000500",  --19 Device index: none
                                               x"000800", --18 Power modes: Normal operation
                                               x"000502", --17 Device index: B
                                               x"000800", --16 Power modes: Normal operation
                                               x"000501", --15 Device index: A
                                               x"003A02", --14 Sync control : continuous | sync enable | 0
                                               x"001781", --13 Output Delay; DCO delay enabled; 1.12ns
                                               x"001511", --12 Output adjust: CMOS drive strength 01 - 2X [DCO | DOUT]
                                               x"002A00", --11 Overrange control: output disable
                                               x"000B03", --10 Clck Divide: 4
                                               x"001680", --9 Clock Phase control: DCO inverted, Input clock divider phase adjust 0
                                               x"000500", --8 Device index: none
                                               x"001421", --7 Output mode: CMOS | interleave | enable B | output not invert | 2's Complement
                                               x"000803", --6 Power modes: digital reset
                                               x"000502", --5 Device index: B
                                               x"001431", --4 Output mode: CMOS | interleave | disable A | output not invert | 2's Complement
                                               x"000803", --3 Power modes: digital reset
                                               x"000501", --2 Device index: A
                                               x"000100", --1 Chip ID: read chip ID
                                               x"00003C"  --0 SPI Port Config: soft reset
                                            );                                            
constant kAD96xx_SPI_Rdbck : ADC_SPI_Readback_t:= (x"00",  --19 Device index: none
                                                x"00", --18 Power modes: Normal operation
                                                x"02", --17 Device index: B
                                                x"00", --16 Power modes: Normal operation
                                                x"01", --15 Device index: A
                                                x"02", --14 Sync control : continuous | sync enable | 0
                                                x"81", --13 Output Delay; DCO delay enabled; 1.12ns
                                                x"11", --12 Output adjust: CMOS drive strength 01 - 2X [DCO | DOUT]
                                                x"00", --11 Overrange control: output disable
                                                x"03", --10 Clck Divide: 4
                                                x"80", --9 Clock Phase control: DCO inverted, Input clock divider phase adjust 0
                                                x"00", --8 Device index: none
                                                x"21", --7 Output mode: CMOS | interleave | enable B | output not invert | 2's Complement
                                                x"03", --6 Power modes: digital reset
                                                x"02", --5 Device index: B
                                                x"31", --4 Output mode: CMOS | interleave | disable A | output not invert | 2's Complement
                                                x"03", --3 Power modes: digital reset
                                                x"01", --2 Device index: A
                                                x"88", --1 Chip ID expected value:88
                                                x"18"  --0 SPI Port Config: soft reset                                                
                                               );
constant kAD92xx_SPI_Cmd : ADC_SPI_Commands_t := (x"000500",  --19 Device index: none
                                               x"000800", --18 Power modes: Normal operation
                                               x"000502", --17 Device index: B
                                               x"000800", --16 Power modes: Normal operation
                                               x"000501", --15 Device index: A
                                               x"010002", --14 Sync control : continuous | sync enable | 0
                                               x"001781", --13 Output Delay; DCO delay enabled; 1.12ns
                                               x"001511", --12 Output adjust: CMOS drive strength 01 - 2X [DCO | DOUT]
                                               x"002A00", --11 Overrange control: output disable
                                               x"000B03", --10 Clck Divide: 4
                                               x"000500", --9 Device index: none
                                               x"001680", --8 Clock Phase control: DCO inverted, Input clock divider phase adjust 0
                                               x"001421", --7 Output mode: CMOS | interleave | enable B | output not invert | 2's Complement
                                               x"000803", --6 Power modes: digital reset
                                               x"000502", --5 Device index: B
                                               x"001431", --4 Output mode: CMOS | interleave | disable A | output not invert | 2's Complement
                                               x"000803", --3 Power modes: digital reset
                                               x"000501", --2 Device index: A
                                               x"000100", --1 Chip ID: read chip ID
                                               x"00003C"  --0 SPI Port Config: soft reset
                                            );                                            
constant kAD92xx_SPI_Rdbck : ADC_SPI_Readback_t:= (x"00",  --19 Device index: none
                                                x"00", --18 Power modes: Normal operation
                                                x"02", --17 Device index: B
                                                x"00", --16 Power modes: Normal operation
                                                x"01", --15 Device index: A
                                                x"02", --14 Sync control : continuous | sync enable | 0
                                                x"81", --13 Output Delay; DCO delay enabled; 1.12ns
                                                x"11", --12 Output adjust: CMOS drive strength 01 - 2X [DCO | DOUT]
                                                x"00", --11 Overrange control: output disable
                                                x"03", --10 Clck Divide: 4
                                                x"00", --9 Device index: none
                                                x"80", --8 Clock Phase control: DCO inverted, Input clock divider phase adjust 0
                                                x"21", --7 Output mode: CMOS | interleave | enable B | output not invert | 2's Complement
                                                x"03", --6 Power modes: digital reset
                                                x"02", --5 Device index: B
                                                x"31", --4 Output mode: CMOS | interleave | disable A | output not invert | 2's Complement
                                                x"03", --3 Power modes: digital reset
                                                x"01", --2 Device index: A
                                                x"88", --1 Chip ID expected value:88
                                                x"18"  --0 SPI Port Config: soft reset                                                
                                               );                                               
constant kSetTrsfReg : std_logic_vector(23 downto 0) := x"00FF01";                                                   
--ADC Register addresses
constant kDevIndex : std_logic_vector(12 downto 0)    := "00000" & x"05";
constant kPwrModes : std_logic_vector(12 downto 0)    := "00000" & x"08";
constant kSyncCtrll : std_logic_vector(12 downto 0)   := "00000" & x"3A";
constant kOutDly : std_logic_vector(12 downto 0)      := "00000" & x"17";
constant kOutAdj : std_logic_vector(12 downto 0)      := "00000" & x"15";
constant kOvrrCtrl : std_logic_vector(12 downto 0)    := "00000" & x"2A";
constant kClkPhCtrl : std_logic_vector(12 downto 0)   := "00000" & x"16"; 
constant kClkDiv : std_logic_vector(12 downto 0)      := "00000" & x"0B";  
constant kOutMode : std_logic_vector(12 downto 0)     := "00000" & x"14";                                            
constant kChipID : std_logic_vector(12 downto 0)      := "00000" & x"01";  
constant kSPI_PortCfg : std_logic_vector(12 downto 0) := "00000" & x"01";                                             

--ID Register value for supported Zmods
constant AD9648_ID : std_logic_vector(7 downto 0) := x"88";
constant AD9204_ID : std_logic_vector(7 downto 0) := x"25";
constant AD9608_ID : std_logic_vector(7 downto 0) := x"9C";
constant AD9231_ID : std_logic_vector(7 downto 0) := x"24";
constant AD9628_ID : std_logic_vector(7 downto 0) := x"89";
constant AD9251_ID : std_logic_vector(7 downto 0) := x"23";

constant AD9648_Grade : std_logic_vector(7 downto 0) := x"40";
constant AD9204_Grade : std_logic_vector(7 downto 0) := x"10";
constant AD9608_Grade : std_logic_vector(7 downto 0) := x"50";
constant AD9231_Grade : std_logic_vector(7 downto 0) := x"10";
constant AD9628_Grade : std_logic_vector(7 downto 0) := x"50";
constant AD9251_Grade : std_logic_vector(7 downto 0) := x"10";

-- number of commands to load in the TX command FIFO for the CommandFIFO module                                               
constant kCmdFIFO_NoWrCmds : integer := 3;
-- command list loaded in the TX command FIFO of the CommandFIFO module    
type CmdFIFO_WrCmdList_t is array (kCmdFIFO_NoWrCmds downto 0) of std_logic_vector(23 downto 0);
constant kCmdFIFO_WrList : CmdFIFO_WrCmdList_t := (x"800200", -- read chip grade
                                               x"800100", -- read chip ID
                                               x"00003C", -- write SPI Port Config
                                               x"000000"  -- dummy
                                            );
-- number of commands expected to be returned  and loaded in the RX command FIFO of 
-- the CommandFIFO module by the AD9648_SPI_Module in the tb_TestConfigADC test bench.
-- It should be equal to the number of read commands in the kCmdFIFO_WrList.                                              
constant kCmdFIFO_NoRdCmds : integer := 2;
-- data expected in return after sending the kCmdFIFO_WrList commands by the CommandFIFO module
type CmdFIFO_RdCmdList_t is array (kCmdFIFO_NoRdCmds-1 downto 0) of std_logic_vector(7 downto 0);
constant kCmdFIFO_Timeout : unsigned (23 downto 0) := x"000600";                                              
                                                                                                                                       
type CalibCoef_t is record
    LgMultCoef : std_logic_vector (17 downto 0);
    LgAddCoef : std_logic_vector (17 downto 0);
    HgMultCoef : std_logic_vector (17 downto 0);
    HgAddCoef : std_logic_vector (17 downto 0);
end record;

type RelayConfig_t is record
    CouplingConfig : std_logic;
    GainConfig : std_logic; 
end record; 
                                        
constant kCmdWrTotal_AD9648 : integer := 19;
constant kCmdWrTotal_AD9204 : integer := 19;
constant kCmdWrTotal_AD9608 : integer := 19;
constant kCmdWrTotal_AD9231 : integer := 19;
constant kCmdWrTotal_AD9628 : integer := 19;
constant kCmdWrTotal_AD9251 : integer := 19;

constant kCmdReadID_Index : integer := 1;       --Read ID command index in kADC_SPI_Cmd and kADC_SPI_Rdbck arrays
constant kCmdClkDivIndex : integer := 10;       --Clock Divide command index in kADC_SPI_Cmd and kADC_SPI_Rdbck arrays

-- Constant used to measure 290ms (with a clock frequency of 100MHz) to allow the ADC's
-- transition from power down to normal operation (ConfigADC.vhd).
-- 290ms value is computed from:
-- https://www.analog.com/media/en/technical-documentation/data-sheets/ad9648.pdf page 40, 
-- "The pseudo code sequence for a digital reset":
-- 2.9e6 sample clock cycles @ 10MHz minimum sampling clock frequency (for ZmodScope) = 290ms  
constant kCountResetResume : unsigned := to_unsigned (28999999, 25);
-- Smaller version of the kCountResetResume, used only for simulation purposes.
-- (999 + 1) clock cycles @ 100MHz frequency means 10us.
constant kCountResetResumeSim : unsigned := to_unsigned (999, 25);
-- Constant used to measure 4ms (with a clock frequency of 100MHz) that allows to
-- determine the timin intervals for the relay drive signals (ConfigRelays.vhd)       
constant kCount4ms : unsigned := to_unsigned (399999, 24); 
-- Smaller version of the kCount4ms, used only for simulation purposes.
-- (399 + 1) clock cycles @ 100MHz frequency means 4us.
constant kCount4msSim : unsigned := to_unsigned (399, 24); 
-- Constant used to measure 5ms with a clock frequency of 100MHz
-- Used to determine the ADC calibration timeout condition (tb_TestConfigADC.vhd and tb_TestTop.vhd)       
constant kCount5ms : integer := 500000;    
-- Constant used to measure 291ms (with a clock frequency of 100MHz) that determines a
-- timeout condition on the ADC's SPI interface (ConfigADC.vhd)
-- This value has to be larger than kCountResetResume, otherwise false timeouts on the ADC
-- SPI interface will occur (i.e. after an ADC soft reset is performed).
constant kCfgTimeout : unsigned := to_unsigned (29099999, 25);    
                                                 
type FsmStatesADC_t is (StStart, StCheckCmdCnt, StWriteSoftReset, StWaitDoneRst, StReadPortConfig, 
                        StCheckResetDone, StReadID, StWaitDoneID, StWriteControlReg, StWaitDoneWriteReg, 
                        StWaitDoneReadReg, StReadControlReg, StResetTimer, StWaitRecover, StInitDone, StIdle,  
                        StError, StExtSPI_RdCmd, StExtSPI_WrCmd,  StWaitDoneExtWrReg,  
                        StWaitDoneExtRdReg, StRegExtRxData, StSetTrsfReg, StWaitDoneTrsfReg, StReadTrsfReg, StWaitDoneTrsfRegRd);
 
type FsmStatesRelays_t is (StStart, StConfigCouplingCh1, StConfigCouplingCh1Rst, StConfigCouplingCh2, 
                           StConfigCouplingCh2Rst, StConfigGainCh1, StConfigGainCh1Rst, StConfigGainCh2, 
                           StConfigGainCh2Rst, StPushInitDone, StWaitRdy, StIdle, StError, StWaitAckCouplingCh1, 
                           StChangeCouplingCh1, StWaitAckCouplingCh2, StChangeCouplingCh2, StWaitAckGainCh1, 
                           StChangeGainCh1, StWaitAckGainCh2, StChangeGainCh2, StRstCfgPulse);

type FsmStatesSPI_t is (StIdle, StWrite, StRead1, StRead2, StRead3, StDone, StAssertCS);                                                       
                           
constant kRangeLg : real := 26.25;
constant kRangeHg : real := 1.086;
constant kRangeIdealLg : real := 25.0;
constant kRangeIdealHg : real := 1.0;

-- Function used to determine the Chip ID based on the ZmodIC parameter
-- that identifies the Zmod.
function SelADC_ID(ZmodIC:integer) 
        return std_logic_vector;

-- Function used to determine the Chip grade based on the ZmodIC parameter
-- that identifies the Zmod.
function SelADC_Grade(ZmodIC:integer) 
        return std_logic_vector;

-- Function used to determine the Clock devide ratio field of register 0x0B
-- based on the kADC_ClkDiv generic 
function DetClkDiv(ADC_ClkDiv:integer) 
        return std_logic_vector;         

-- The initiaization command list is different depending on which Zmod is targeted.
-- The SelCmdList function is used to select the appropriate command list based on
-- the ZmodIC parameter.
function SelCmdList(ZmodIC:integer) 
        return ADC_SPI_Commands_t;

-- The initiaization command readback list is different depending on which Zmod is 
-- targeted. The SelCmdList function is used to select the appropriate command list 
-- based on the ZmodIC parameter.
function SelRdbkList(ZmodIC:integer) 
        return ADC_SPI_Readback_t;

-- The OverwriteClkDiv function is used to overwrite the Clock divide ratio field of commad list
-- (CmdList) sent as parameter based on ADC_ClkDiv. It is important to note that the "write
-- Clock Divide register" (address 0x0B) command shares the same position (kCmdClkDivIndex)  in 
-- the command list for the currently supported Zmods.
function OverwriteClkDiv(CmdList:ADC_SPI_Commands_t; ADC_ClkDiv:integer) 
        return ADC_SPI_Commands_t;

-- The OverWriteID_ClkDiv function is used to overwrite the ADC chip ID field of the 
-- command readback list (RdbkList) based on the ZmodIC parameter.
function OverWriteID_ClkDiv(ZmodIC:integer; RdbkList:ADC_SPI_Readback_t; ADC_ClkDiv:integer) 
        return ADC_SPI_Readback_t;

-- The SelCmdWrListLength function is used to detrmine the command list
-- length based on the ZmodIC parameter.
function SelCmdWrListLength(ZmodIC:integer) 
        return integer; 

-- Function used to determine the ADC resolution (kADC_Width) based on the ZmodIC parameter.
-- Used in the top level test bench.
function SelADC_Width(ZmodIC:integer) 
        return integer;   

-- Function used to compute the IDDR sampling clock phase as a function of the sampling
-- period. This is necessary so the clock phase is always an integer multiple of
-- (45 degrees/output clock division factor) of the MMCM which generates it.
function IDDR_ClockPhase(SamplingPeriod:real) 
        return real;

end PkgZmodADC;

package body PkgZmodADC is

function SelADC_ID(ZmodIC:integer) 
        return std_logic_vector is  
   begin
      case ZmodIC is
         when kZmodScope1410_105 => 
            return AD9648_ID;
         when kZmodScope1010_40 =>
            return AD9204_ID;
         when kZmodScope1010_125 =>
            return AD9608_ID;
         when kZmodScope1210_40 =>
            return AD9231_ID;
         when kZmodScope1210_125 =>
            return AD9628_ID;
         when kZmodScope1410_40 =>
            return AD9251_ID; 
         when kZmodScope1410_125 =>
            return AD9648_ID;
         when others =>
            return x"00";                                                                         
      end case;          
end function;
  
function SelADC_Grade(ZmodIC:integer) 
        return std_logic_vector is  
   begin
      case ZmodIC is
         when kZmodScope1410_105 => 
            return AD9648_Grade;
         when kZmodScope1010_40 =>
            return AD9204_Grade;
         when kZmodScope1010_125 =>
            return AD9608_Grade;
         when kZmodScope1210_40 =>
            return AD9231_Grade;
         when kZmodScope1210_125 =>
            return AD9628_Grade;
         when kZmodScope1410_40 =>
            return AD9251_Grade; 
         when kZmodScope1410_125 =>
            return AD9648_Grade;
         when others =>
            return x"00";                                                                         
      end case;          
end function;

function DetClkDiv(ADC_ClkDiv:integer) 
        return std_logic_vector is
   begin
      if (ADC_ClkDiv = 1) then
         return x"00";
      elsif (ADC_ClkDiv = 2) then   
         return x"01";  
      elsif (ADC_ClkDiv = 3) then   
         return x"02";  
      elsif (ADC_ClkDiv = 4) then   
         return x"03"; 
      elsif (ADC_ClkDiv = 5) then   
         return x"04"; 
      elsif (ADC_ClkDiv = 6) then   
         return x"05";
      elsif (ADC_ClkDiv = 7) then   
         return x"06";
      elsif (ADC_ClkDiv = 8) then   
         return x"07";             
      else
         return x"00";
      end if;          
end function;
  
function SelCmdList(ZmodIC:integer) 
        return ADC_SPI_Commands_t is
   variable CmdListV : ADC_SPI_Commands_t := kAD96xx_SPI_Cmd;     
   begin
      case ZmodIC is
         when kZmodScope1410_105 => 
            CmdListV := kAD96xx_SPI_Cmd;
            return CmdListV;
         when kZmodScope1010_40 =>
            CmdListV := kAD92xx_SPI_Cmd;
            return CmdListV;
         when kZmodScope1010_125 =>
            CmdListV := kAD96xx_SPI_Cmd;
            return CmdListV;
         when kZmodScope1210_40 =>
            CmdListV := kAD92xx_SPI_Cmd;
            return CmdListV;
         when kZmodScope1210_125 =>
            CmdListV := kAD96xx_SPI_Cmd;
            return CmdListV;
         when kZmodScope1410_40 =>
            CmdListV := kAD92xx_SPI_Cmd;
            return CmdListV; 
         when kZmodScope1410_125 =>
            CmdListV := kAD96xx_SPI_Cmd;
            return CmdListV;
         when others =>
            CmdListV := (others => (others => '0'));
            return CmdListV;                                                                         
      end case;          
end function;
  
function SelRdbkList(ZmodIC:integer) 
        return ADC_SPI_Readback_t is
   variable RdbkListV : ADC_SPI_Readback_t := kAD96xx_SPI_Rdbck;     
   begin
      case ZmodIC is
         when kZmodScope1410_105 => 
            RdbkListV := kAD96xx_SPI_Rdbck;
            return RdbkListV;
         when kZmodScope1010_40 =>
            RdbkListV := kAD92xx_SPI_Rdbck;
            return RdbkListV;
         when kZmodScope1010_125 =>
            RdbkListV := kAD96xx_SPI_Rdbck;
            return RdbkListV;
         when kZmodScope1210_40 =>
            RdbkListV := kAD92xx_SPI_Rdbck;
            return RdbkListV;
         when kZmodScope1210_125 =>
            RdbkListV := kAD96xx_SPI_Rdbck;
            return RdbkListV;
         when kZmodScope1410_40 =>
            RdbkListV := kAD92xx_SPI_Rdbck;
            return RdbkListV; 
         when kZmodScope1410_125 =>
            RdbkListV := kAD96xx_SPI_Rdbck;
            return RdbkListV;
         when others =>
            RdbkListV := (others => (others => '0'));
            return RdbkListV;                                                                         
      end case;          
end function;

function OverwriteClkDiv(CmdList:ADC_SPI_Commands_t; ADC_ClkDiv:integer) 
        return ADC_SPI_Commands_t is
   variable CmdListV : ADC_SPI_Commands_t := CmdList;     
   begin
      CmdListV(kCmdClkDivIndex) := CmdList(kCmdClkDivIndex)(23 downto 8) & DetClkDiv(ADC_ClkDiv);
   return CmdListV;       
end function;
 
function OverWriteID_ClkDiv(ZmodIC:integer; RdbkList:ADC_SPI_Readback_t; ADC_ClkDiv:integer) 
        return ADC_SPI_Readback_t is
   variable RdbkListV : ADC_SPI_Readback_t := RdbkList;     
   begin
      RdbkListV(kCmdClkDivIndex) := DetClkDiv(ADC_ClkDiv);
      case ZmodIC is
         when kZmodScope1410_105 => 
            RdbkListV(kCmdReadID_Index) := AD9648_ID;
            return RdbkListV;
         when kZmodScope1010_40 =>
            RdbkListV(kCmdReadID_Index) := AD9204_ID;
            return RdbkListV;
         when kZmodScope1010_125 =>
            RdbkListV(kCmdReadID_Index) := AD9608_ID;
            return RdbkListV;
         when kZmodScope1210_40 =>
            RdbkListV(kCmdReadID_Index) := AD9231_ID;
            return RdbkListV;
         when kZmodScope1210_125 =>
            RdbkListV(kCmdReadID_Index) := AD9628_ID;
            return RdbkListV;
         when kZmodScope1410_40 =>
            RdbkListV(kCmdReadID_Index) := AD9251_ID;
            return RdbkListV; 
         when kZmodScope1410_125 =>
            RdbkListV(kCmdReadID_Index) := AD9648_ID;
            return RdbkListV;
         when others =>
            RdbkListV(kCmdReadID_Index) := x"00";
            return RdbkListV;                                                                         
      end case;          
end function;

function SelCmdWrListLength(ZmodIC:integer) 
        return integer is   
   begin
      case ZmodIC is
         when kZmodScope1410_105 => 
            return kCmdWrTotal_AD9648;
         when kZmodScope1010_40 =>
            return kCmdWrTotal_AD9204;
         when kZmodScope1010_125 =>
            return kCmdWrTotal_AD9608;
         when kZmodScope1210_40 =>
            return kCmdWrTotal_AD9231;
         when kZmodScope1210_125 =>
            return kCmdWrTotal_AD9628;
         when kZmodScope1410_40 =>
            return kCmdWrTotal_AD9251; 
         when kZmodScope1410_125 =>
            return kCmdWrTotal_AD9648;
         when others =>
            return 0;                                                                         
      end case;          
end function;

function SelADC_Width(ZmodIC:integer) 
        return integer is   
   begin
      case ZmodIC is
         when kZmodScope1410_105 => 
            return 14;
         when kZmodScope1010_40 =>
            return 10;
         when kZmodScope1010_125 =>
            return 10;
         when kZmodScope1210_40 =>
            return 12;
         when kZmodScope1210_125 =>
            return 12;
         when kZmodScope1410_40 =>
            return 14; 
         when kZmodScope1410_125 =>
            return 14;
         when others =>
            return 14;                                                                         
      end case;          
end function;

function IDDR_ClockPhase(SamplingPeriod:real) 
        return real is
   begin
      --400MHz to 200MHz
      if ((SamplingPeriod > 2.5) and (SamplingPeriod <= 5.0)) then
         return 120.0;
      --200MHz to 111MHz 
      elsif ((SamplingPeriod > 5.0) and (SamplingPeriod <= 9.0)) then   
         return 127.5;
	  --111MHz to 100MHz 
      elsif ((SamplingPeriod > 9.0) and (SamplingPeriod <= 10.0)) then   
         return 120.0;
      --100MHz to 50MHz    
      elsif ((SamplingPeriod > 10.0) and (SamplingPeriod <= 20.0)) then
         return 123.75;
      --50MHz to 25MHz 
      elsif ((SamplingPeriod > 20.0) and (SamplingPeriod <= 40.0)) then
         return 125.625;       
      --25MHz to 12.5MHz 
      elsif ((SamplingPeriod > 40.0) and (SamplingPeriod <= 80.0)) then
         return 125.625;       
      --12.5MHz to 10MHz 
      elsif (SamplingPeriod > 80.0) then
         return 125.859375; 
      --Out of specifications;               
      else
         return 1.0;
      end if;          
end function;

end PkgZmodADC;