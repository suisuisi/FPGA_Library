-------------------------------------------------------------------------------
--
-- File: PkgZmodDAC.vhd
-- Author: Tudor Gherman
-- Original Project: Zmod DAC 1411 Low Level Controller
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
-- ZmodDAC1411_Controller IP
--  
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package PkgZmodDAC is

--Timing parameters
constant ktS : time := 2 ns;                        -- Setup time between CSB and SCLK
constant ktH : time := 2 ns;                        -- Hold time between CSB and SCLK
constant ktDS : time := 2 ns;                       -- Setup time between the data and the rising edge of SCLK
constant ktDH : time := 2 ns;                       -- Hold time between the data and the rising edge of SCLK
constant ktclk : time := 40 ns;                     -- minimum period of the SCLK
constant kSclkHigh : time := 10 ns;                 -- SCLK pulse width high (min)
constant kSclkLow : time := 10 ns;                  -- SCLK pulse width low (min)
--constant kSclkT_Max : time := 10 ns;              -- SCLK pulse width low (min)
constant kSclkT_Min : time := 50 ns;                -- SCLK pulse width low (min)
--constant kNoCommandBits : integer := 16;            -- minimum period of the SCLK
constant kNoDataBits : integer := 8;                -- minimum period of the SCLK
constant kTdcoMax : time := 4.4 ns;
constant kRelayConfigTime : time := 3ms;            -- relay set and reset signals
--ADC Model Registers
constant aReg00_Mask : std_logic_vector(7 downto 0) := "01100110";

--Implementation constants
constant kCS_PulseWidthHigh : integer := 31;   --CS pulse width high not specified for AD8717
constant kSPI_DataWidth : integer := 8;        --ADI_SPI module data width
constant kSPI_CommandWidth : integer := 8;    --ADI_SPI module command width
constant kSPI_AddrWidth : integer := kSPI_CommandWidth - 3;    --ADI_SPI module command width
constant kSPI_SysClkDiv : integer := 4;       --ADI_SPI module system clock divide constant
                                              --No minimum SPI clock frequency specified by AD9717. The maximum frequency is 25MHz.


     
constant kCount20us : unsigned := to_unsigned (1999, 24);       --Constant used to measure 20us with a clock frequency of 100MHz
constant kCount4ms : unsigned := to_unsigned (399999, 24);        --Constant used to measure 4ms with a clock frequency of 100MHz
constant kCount150ms : unsigned := to_unsigned (14999999, 24);    --Constant used to measure 150ms with a clock frequency of 100MHz
constant kCfgTimeout : unsigned := to_unsigned (14999999, 24);    --Constant used to measure 150ms with a clock frequency of 100MHz                                                 

type FsmStatesSPI_t is (StIdle, StWrite, StRead1, StRead2, StRead3, StDone, StAssertCS); 
type FsmStates_t is (StStart, StWriteConfigReg, StWaitDoneWriteReg, StReadControlReg, 
StWaitDoneReadReg, StCheckCmdCnt, StInitDone, StIdle, StExtSPI_WrCmd, 
StWaitDoneExtWrReg, StExtSPI_RdCmd, StWaitDoneExtRdReg, StRegExtRxData, StError); 

type DAC_SPI_Commands_t is array (13 downto 0) of std_logic_vector(15 downto 0);
type DAC_SPI_Readback_t is array (13 downto 0) of std_logic_vector(7 downto 0);
-- List of commands sent to the AD9717 during the initialization process.
constant kDAC_SPI_Cmd : DAC_SPI_Commands_t := (
                                                x"0E00",  -- 13. Cal Control: Disable calibration clock.
                                                x"1200",  -- 12. Memory R/W: clear CALEN.
                                                x"0FC0",  -- 11. Cal Memory: Read CALSTAT. Read ONLY! 
                                                x"1210",  -- 10. Memory R/W: CALEN - initialize self calibration.
                                                x"0E3A",  -- 9. Cal Control - step 3: Select Q DAC, I DAC self calibration.
                                                x"0E0A",  -- 8. Cal Control - step 2: Enable calibration clock.
                                                x"0E02",  -- 7. Cal Control - step 1: DIVSEL - calibration clock divide ratio from DAC clock rate set to 64.
                                                x"1200",  -- 6. Memory R/W: Self calibration step 1 (Write 0x00 to Register 0x12).
                                                x"1400",  -- 5. CLKMODE: Clear Reaquire bit in CLKMODE register. 
                                                x"1408",  -- 4. CLKMODE: Toggle (step 2-set) Reaquire bit in CLKMODE register. 
                                                x"1400",  -- 3. CLKMODE: Toggle (step 1-clear) Reaquire bit in CLKMODE register.
                                                x"02B4",  -- 2. Data Control: 2's Complement input data format, IDATA latched on DCLKIO rising edge, 
												          -- I first of pair on data input pads, data clock input enable, data clock output disable.
                                                x"0000",  -- 1. SPI Control : Clear Reset.
                                                x"0020"   -- 0. SPI Control : Set Reset.
                                               );
-- List of data expected to be read back fro the AD9717 at each step (after each register write) of the initialization process.
constant DAC_SPI_mask : DAC_SPI_Readback_t := (
                                                x"00", 
                                                x"00", 
                                                x"3F",  
                                                x"EF", 
                                                x"00", 
                                                x"00", 
                                                x"00", 
                                                x"EF", 
                                                x"C3", 
                                                x"CB",
                                                x"C3",   
                                                x"40",
                                                x"80",
                                                x"80"
                                               );
constant kCmdTotal : integer := 13;
constant kCmdRdCalstatIndex : integer := 11;       --Read ID command index in kADC_SPI_Cmd and kADC_SPI_Rdbck arrays
-- Constant used to measure 300 calibration clock cycles with a calibration clock divide ratio from DAC clock rate set to 64.
constant kCalTimeout : unsigned := to_unsigned (19200, 24);       

-- Number of commands to load in the TX command FIFO for the CommandFIFO module                                               
constant kCmdFIFO_NoWrCmds : integer := 4;
-- Command list loaded in the TX command FIFO of the CommandFIFO module    
type CmdFIFO_WrCmdList_t is array (kCmdFIFO_NoWrCmds downto 0) of std_logic_vector(23 downto 0);
constant kCmdFIFO_WrList : CmdFIFO_WrCmdList_t := (
                                               x"801F04", -- read Version register
                                               x"0002B4", -- write Data Control register
                                               x"8002B0", -- read Data Control register
                                               x"0002B0", -- write Data Control register
                                               x"000000"  -- dummy
                                            );
-- Number of commands expected to be returned  and loaded in the RX command FIFO of 
-- the SPI_IAP_AD9717_TestModule module in the tb_TestTop test bench.
-- It should be equal to the number of read commands in the kCmdFIFO_WrList.                                              
constant kCmdFIFO_NoRdCmds : integer := 2;
-- Data expected in return after sending the kCmdFIFO_WrList commands by the CommandFIFO module
type CmdFIFO_RdCmdList_t is array (kCmdFIFO_NoRdCmds-1 downto 0) of std_logic_vector(7 downto 0);
constant kCmdFIFO_RdList : CmdFIFO_RdCmdList_t := (x"04",x"B0");
constant kCmdFIFO_RdListMask : CmdFIFO_RdCmdList_t := (x"00",x"40");
constant kCmdFIFO_Timeout : unsigned (23 downto 0) := x"000600"; 
                                                         
end PkgZmodDAC;
