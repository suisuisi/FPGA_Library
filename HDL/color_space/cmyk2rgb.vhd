-------------------------------------------------------------------------------
--
-- Filename    : cmyk2rgb.vhd
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
entity cmyk2rgb is
port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    iRgb           : in cmyk_channel;
    oRgb           : out channel);
end cmyk2rgb;
architecture behavioral of cmyk2rgb is
    signal rgbSyncEol           : std_logic_vector(7 downto 0) := x"00";
    signal rgbSyncSof           : std_logic_vector(7 downto 0) := x"00";
    signal rgbSyncEof           : std_logic_vector(7 downto 0) := x"00";
    signal cymk_colors          : type_inteCmykChannel(0 to 5);
    signal rgb_colors           : inteChannel;
begin
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEol(0)  <= iRgb.eol;
        for i in 0 to 6 loop
          rgbSyncEol(i+1)  <= rgbSyncEol(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncSof(0)  <= iRgb.sof;
        for i in 0 to 6 loop
          rgbSyncSof(i+1)  <= rgbSyncSof(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEof(0)  <= iRgb.eof;
        for i in 0 to 6 loop
          rgbSyncEof(i+1)  <= rgbSyncEof(i);
        end loop;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        cymk_colors(0).cyan     <= u_to_integer(iRgb.cyan(9 downto 2));
        cymk_colors(0).magenta  <= u_to_integer(iRgb.magenta(9 downto 2));
        cymk_colors(0).yellow   <= u_to_integer(iRgb.yellow(9 downto 2));
        cymk_colors(0).keyblack <= u_to_integer(iRgb.keyblack(9 downto 2));
        cymk_colors(0).valid    <= iRgb.valid;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        cymk_colors(1).cyan     <= covert_to_upper_limit(cymk_colors(0).cyan);
        cymk_colors(1).magenta  <= covert_to_upper_limit(cymk_colors(0).magenta);
        cymk_colors(1).yellow   <= covert_to_upper_limit(cymk_colors(0).yellow);
        cymk_colors(1).keyblack <= cymk_colors(0).keyblack;
        cymk_colors(1).valid    <= cymk_colors(0).valid;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        cymk_colors(2).cyan      <= set_range(cymk_colors(1).cyan,cymk_colors(1).keyblack);
        cymk_colors(2).magenta   <= set_range(cymk_colors(1).magenta,cymk_colors(1).keyblack);
        cymk_colors(2).yellow    <= set_range(cymk_colors(1).yellow,cymk_colors(1).keyblack);
        cymk_colors(2).keyblack  <= cymk_colors(1).keyblack;
        cymk_colors(2).valid     <= cymk_colors(1).valid;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        cymk_colors(3).cyan     <= covert_to_upper_limit(cymk_colors(2).cyan);
        cymk_colors(3).magenta  <= covert_to_upper_limit(cymk_colors(2).magenta);
        cymk_colors(3).yellow   <= covert_to_upper_limit(cymk_colors(2).yellow);
        cymk_colors(3).keyblack <= cymk_colors(2).keyblack;
        cymk_colors(3).valid    <= cymk_colors(2).valid;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        cymk_colors(4).cyan     <= domain_limits(cymk_colors(3).cyan);
        cymk_colors(4).magenta  <= domain_limits(cymk_colors(3).magenta);
        cymk_colors(4).yellow   <= domain_limits(cymk_colors(3).yellow);
        cymk_colors(4).keyblack <= domain_limits(cymk_colors(3).keyblack);
        cymk_colors(4).valid    <= cymk_colors(3).valid;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        cymk_colors(5).cyan     <= covert_to_upper_limit(cymk_colors(4).cyan);
        cymk_colors(5).magenta  <= covert_to_upper_limit(cymk_colors(4).magenta);
        cymk_colors(5).yellow   <= covert_to_upper_limit(cymk_colors(4).yellow);
        cymk_colors(5).keyblack <= cymk_colors(4).keyblack;
        cymk_colors(5).valid    <= cymk_colors(4).valid;
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        rgb_colors.red    <= cymk_colors(5).cyan;
        rgb_colors.green  <= cymk_colors(5).magenta;
        rgb_colors.blue   <= cymk_colors(5).yellow;
        rgb_colors.valid  <= cymk_colors(5).valid;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        oRgb.red     <= std_logic_vector(to_unsigned(rgb_colors.red, 8)) & "00";
        oRgb.green   <= std_logic_vector(to_unsigned(rgb_colors.green, 8)) & "00";
        oRgb.blue    <= std_logic_vector(to_unsigned(rgb_colors.blue, 8)) & "00";
        oRgb.valid   <= rgb_colors.valid;
        oRgb.eol     <= rgbSyncEol(5);
        oRgb.sof     <= rgbSyncSof(5);
        oRgb.eof     <= rgbSyncEof(5);
    end if;
end process;
end behavioral;