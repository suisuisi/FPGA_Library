-------------------------------------------------------------------------------
--
-- Filename    : rgb2cmyk.vhd
-- Create Date : 02052023 [02-05-2023]
-- Author      : Sakinder
--
-- Description:
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use work.float_pkg.all;
use work.constants_package.all;
use work.vfp_pkg.all;
use work.vpf_records.all;
use work.ports_package.all;
entity rgb2cmyk is
port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    cymk_key_red   : in integer;
    cymk_key_gre   : in integer;
    cymk_key_blu   : in integer;
    iRgb           : in channel;
    oRgb           : out cmyk_channel);
end rgb2cmyk;
architecture behavioral of rgb2cmyk is
    signal rgbSyncEol           : std_logic_vector(63 downto 0) := x"0000000000000000";
    signal rgbSyncSof           : std_logic_vector(63 downto 0) := x"0000000000000000";
    signal rgbSyncEof           : std_logic_vector(63 downto 0) := x"0000000000000000";
    signal rgb_colors           : type_inteChannel(0 to 3);
    signal rgb_cymk             : type_inteChannel(0 to 63);
    signal rgb_value            : type_intePerChannel(0 to 16);
    signal cymk_colors          : inteChannel;
    signal rgb_equation_min1n   : integer;
    signal rgb_equation_min1    : integer;
    signal rgb_equation_min2    : integer;
    signal rgb_max              : integer;
    signal rgb_max_is           : integer;
    signal rgb_max1             : std_logic_vector(7 downto 0);
    signal rgb_max2             : std_logic_vector(7 downto 0);
    signal rgb_equation_gain1   : std_logic_vector(15 downto 0);
    signal rgb_domain_check     : integer;
    signal rgb_domain_check2    : std_logic_vector(7 downto 0);
    signal rgb_equation_delta   : integer;
    signal rgb_gain_saturation  : std_logic_vector(23 downto 0);
    signal saturation1_gain     : std_logic_vector(23 downto 0);
    signal saturation2_gain     : std_logic_vector(31 downto 0);
    signal red_key              : std_logic_vector(7 downto 0);
    signal rgb_key              : integer;
    signal key                  : integer;
begin
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEol(0)  <= iRgb.eol;
        for i in 0 to 30 loop
          rgbSyncEol(i+1)  <= rgbSyncEol(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncSof(0)  <= iRgb.sof;
        for i in 0 to 30 loop
          rgbSyncSof(i+1)  <= rgbSyncSof(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEof(0)  <= iRgb.eof;
        for i in 0 to 30 loop
          rgbSyncEof(i+1)  <= rgbSyncEof(i);
        end loop;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        rgb_colors(0).red    <= u_to_integer(iRgb.red(9 downto 2));
        rgb_colors(0).green  <= u_to_integer(iRgb.green(9 downto 2));
        rgb_colors(0).blue   <= u_to_integer(iRgb.blue(9 downto 2));
        rgb_colors(0).valid  <= iRgb.valid;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        cymk_colors.red    <= u_to_integer(iRgb.red(9 downto 2));
        cymk_colors.green  <= u_to_integer(iRgb.green(9 downto 2));
        cymk_colors.blue   <= u_to_integer(iRgb.blue(9 downto 2));
        cymk_colors.valid  <= iRgb.valid;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_colors(1).red    <= covert_to_upper_limit(rgb_colors(0).red);
        rgb_colors(1).green  <= covert_to_upper_limit(rgb_colors(0).green);
        rgb_colors(1).blue   <= covert_to_upper_limit(rgb_colors(0).blue);
        rgb_colors(1).valid  <= rgb_colors(0).valid;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_equation_min1       <= min3(cymk_colors.red,cymk_colors.green,cymk_colors.blue);
        rgb_equation_min1n      <= rgb_equation_min1;
        rgb_equation_min2       <= covert_to_upper_limit(rgb_equation_min1);
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_max_is             <= max3(cymk_colors.red,cymk_colors.green,cymk_colors.blue);
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        if(rgb_max_is = 0)then
            rgb_max      <= 1;
        else
            rgb_max      <= rgb_max_is;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_value(0).was  <= rgb_max;
        for i in 0 to 15 loop
          rgb_value(i+1)  <= rgb_value(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_equation_delta      <= (rgb_max-rgb_equation_min2);
        rgb_domain_check        <= domain(rgb_equation_delta);
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_domain_check2      <= std_logic_vector(to_unsigned(rgb_domain_check, 8));
        rgb_max1               <= std_logic_vector(to_unsigned(rgb_value(1).was, 8));
    end if;
end process;
xil_mul1_inst : xil_mul
port map (
    CLK    => clk,
    A      => rgb_domain_check2,
    B      => rgb_max1,
    P      => rgb_equation_gain1);
process (clk) begin
    if rising_edge(clk) then
        rgb_max2                <= std_logic_vector(to_unsigned(rgb_value(6).was, 8));
    end if;
end process;
divider1_inst : xil_div
port map (
    aclk                       => clk,
    s_axis_dividend_tvalid     => '1',
    s_axis_dividend_tdata      => rgb_equation_gain1,
    s_axis_divisor_tvalid      => '1',
    s_axis_divisor_tdata       => rgb_max2,
    m_axis_dout_tvalid         => open,
    m_axis_dout_tdata          => rgb_gain_saturation);
process (clk) begin
    if rising_edge(clk) then 
        red_key <= std_logic_vector(to_unsigned(cymk_key_red, 8));
    end if;
end process;
xil_mul2_inst : xil_fixed_val_mul
port map ( -- Latency=5
    CLK    => clk,
    A      => rgb_gain_saturation(23 downto 8),
    B      => red_key,
    P      => saturation1_gain);
divider2_inst : xil_fixed_val_div
port map ( -- Latency=26
    aclk                       => clk,
    s_axis_dividend_tvalid     => '1',
    s_axis_dividend_tdata      => saturation1_gain,
    s_axis_divisor_tvalid      => '1',
    s_axis_divisor_tdata       => x"64",
    m_axis_dout_tvalid         => open,
    m_axis_dout_tdata          => saturation2_gain);
process (clk) begin
    if rising_edge(clk) then 
        rgb_key <= u_to_integer(saturation2_gain(31 downto 8));
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then 
        key <= rgb_key;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        rgb_colors(2)        <= rgb_colors(1);
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_colors(3).red    <= rgb_colors(2).red + rgb_equation_min1n;
        rgb_colors(3).green  <= rgb_colors(2).green + rgb_equation_min1n;
        rgb_colors(3).blue   <= rgb_colors(2).blue + rgb_equation_min1n;
        rgb_colors(3).valid  <= rgb_colors(2).valid;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_cymk(0)  <= rgb_colors(3);
        for i in 0 to 62 loop
            rgb_cymk(i+1)  <= rgb_cymk(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        oRgb.cyan      <= std_logic_vector(to_unsigned(rgb_cymk(57).red, 8)) & "00";
        oRgb.magenta   <= std_logic_vector(to_unsigned(rgb_cymk(57).green, 8)) & "00";
        oRgb.yellow    <= std_logic_vector(to_unsigned(rgb_cymk(57).blue, 8)) & "00";
        oRgb.keyblack  <= std_logic_vector(to_unsigned(rgb_key, 8)) & "00";
        oRgb.valid     <= rgb_cymk(57).valid;
        oRgb.eol       <= rgbSyncEol(57);
        oRgb.sof       <= rgbSyncSof(57);
        oRgb.eof       <= rgbSyncEof(57);
    end if;
end process;
end behavioral;