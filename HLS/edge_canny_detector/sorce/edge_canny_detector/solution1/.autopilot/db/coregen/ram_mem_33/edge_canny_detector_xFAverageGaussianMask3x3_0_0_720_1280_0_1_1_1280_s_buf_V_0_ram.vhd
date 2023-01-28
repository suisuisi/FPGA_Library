-- ==============================================================
-- Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
--
library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;

entity edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram is 
    generic(
            MEM_TYPE    : string := "block"; 
            DWIDTH     : integer := 8; 
            AWIDTH     : integer := 11; 
            MEM_SIZE    : integer := 1280
    ); 
    port (
          addr0     : in std_logic_vector(AWIDTH-1 downto 0); 
          ce0       : in std_logic; 
          q0        : out std_logic_vector(DWIDTH-1 downto 0);
          addr1     : in std_logic_vector(AWIDTH-1 downto 0); 
          ce1       : in std_logic; 
          d1        : in std_logic_vector(DWIDTH-1 downto 0); 
          we1       : in std_logic; 
          clk        : in std_logic 
    ); 
end entity; 


architecture rtl of edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram is 

signal addr0_tmp : std_logic_vector(AWIDTH-1 downto 0); 
type mem_array is array (0 to MEM_SIZE-1) of std_logic_vector (DWIDTH-1 downto 0); 
signal ram : mem_array;

attribute syn_ramstyle : string; 
attribute syn_ramstyle of ram : signal is "block_ram";
attribute ram_style : string;
attribute ram_style of ram : signal is MEM_TYPE;

begin 


memory_access_guard_0: process (addr0) 
begin
      addr0_tmp <= addr0;
--synthesis translate_off
      if (CONV_INTEGER(addr0) > mem_size-1) then
           addr0_tmp <= (others => '0');
      else 
           addr0_tmp <= addr0;
      end if;
--synthesis translate_on
end process;

p_memory_access_0: process (clk)  
begin 
    if (clk'event and clk = '1') then
        if (ce0 = '1') then 
            q0 <= ram(CONV_INTEGER(addr0_tmp));
        end if;
    end if;
end process;


p_memory_access_1: process (clk)  
begin 
    if (clk'event and clk = '1') then
        if (ce1 = '1') then 
            if (we1 = '1') then 
                ram(CONV_INTEGER(addr1)) <= d1; 
            end if;
        end if;
    end if;
end process;


end rtl;

