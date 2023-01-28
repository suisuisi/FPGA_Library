-- ==============================================================
-- Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity edge_canny_detector_mul_17s_15ns_32_2_1_Multiplier_0 is
port (
    clk: in std_logic;
    ce: in std_logic;
    a: in std_logic_vector(17 - 1 downto 0);
    b: in std_logic_vector(15 - 1 downto 0);
    p: out std_logic_vector(32 - 1 downto 0));
end entity;

architecture behav of edge_canny_detector_mul_17s_15ns_32_2_1_Multiplier_0 is
    signal tmp_product : std_logic_vector(32 - 1 downto 0);
    signal a_i : std_logic_vector(17 - 1 downto 0);
    signal b_i : std_logic_vector(15 - 1 downto 0);
    signal p_tmp : std_logic_vector(32 - 1 downto 0);

begin
    a_i <= a;
    b_i <= b;
    p <= p_tmp;

    tmp_product <= std_logic_vector(resize(unsigned(std_logic_vector(signed(a_i) * signed('0' & b_i))), 32));

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (ce = '1') then
                p_tmp <= tmp_product;
            end if;
        end if;
    end process;
end architecture;
