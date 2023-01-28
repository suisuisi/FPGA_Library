
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity edge_canny_detector_mul_mul_8ns_15ns_22_4_1_DSP48_0 is
port (
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    a: in std_logic_vector(8 - 1 downto 0);
    b: in std_logic_vector(15 - 1 downto 0);
    p: out std_logic_vector(22 - 1 downto 0));

end entity;

architecture behav of edge_canny_detector_mul_mul_8ns_15ns_22_4_1_DSP48_0 is
    signal a_cvt: unsigned(8 - 1 downto 0);
    signal b_cvt: unsigned(15 - 1 downto 0);
    signal p_cvt: unsigned(22 - 1 downto 0);

    signal p_reg: unsigned(22 - 1 downto 0);

    signal a_reg: unsigned(8 - 1 downto 0) ; 
    signal b_reg: unsigned(15 - 1 downto 0) ; 
    signal p_reg_tmp: unsigned(22 - 1 downto 0);
begin

    a_cvt <= unsigned(a);
    b_cvt <= unsigned(b);

    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (ce = '1') then
                a_reg <= a_cvt;
                b_reg <= b_cvt;
                p_reg_tmp <= p_cvt;
                p_reg <= p_reg_tmp;
            end if;
        end if;
    end process;

    p_cvt <= unsigned (resize(unsigned (unsigned (a_reg) * unsigned (b_reg)), 22));
    p <= std_logic_vector(p_reg);

end architecture;
