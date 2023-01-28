
-------------------------------------------------------------------------------
--
-- File: DataPathModel.vhd
-- Author: Tudor Gherman
-- Original Project: ZmodAWG1411_Controller
-- Date: 20 May 2020
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
-- This module emulates the latency of the data path associated with the 
-- ZmodAWG1411_Controller (one register stage followed by an ODDR primitive).
-- The latency associated with the calibration block is modeled separately 
-- by the CalibDataReference module.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DataPathModel is
   Generic (
      -- Number of register stages. Set to 2 to emulate the targeted
	  -- IP latency on the data path. Must be greater or equal to 2.
      kLatency : integer range 2 to 2:= 2;
      -- Channel data width
      kDataWidth : integer := 14
   );
   Port ( 
      DAC_Clk : in STD_LOGIC;
      cCh1DataIn : in STD_LOGIC_VECTOR (kDataWidth-1 downto 0);
      cCh2DataIn : in STD_LOGIC_VECTOR (kDataWidth-1 downto 0);
      cDataOut : out STD_LOGIC_VECTOR (kDataWidth-1 downto 0)
      );
end DataPathModel;

architecture Behavioral of DataPathModel is

type cDlyArray_t is array (kLatency-1 downto 0) of std_logic_vector(kDataWidth-1 downto 0); 
signal cCh1DataInDly, cCh2DataInDly : cDlyArray_t := (others => (others => '0')); 

begin

-- Add kLatency register stages to the data path
ProcDelaySamplingClk : process (DAC_Clk) 
begin
    if (rising_edge(DAC_Clk)) then
        cCh1DataInDly(0) <= cCh1DataIn;
        cCh2DataInDly(0) <= cCh2DataIn;
        for Index in 1 to kLatency-1 loop
            cCh1DataInDly (Index) <= cCh1DataInDly (Index - 1); 
            cCh2DataInDly (Index) <= cCh2DataInDly (Index - 1); 
        end loop;        
    end if;
end process;

-- Emulate the ODDR primitive on the output of the ZmodAWG1411_Controller
ProcOutputData : process (DAC_Clk) 
begin
   if (rising_edge(DAC_Clk)) then
      cDataOut <= cCh1DataInDly (kLatency-2);
   elsif (falling_edge(DAC_Clk)) then 
      cDataOut <= cCh2DataInDly (kLatency-1);       
   end if;
end process;

end Behavioral;
