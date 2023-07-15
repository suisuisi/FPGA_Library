-------------------------------------------------------------------------------
--
-- Filename    : rgbogp.vhd
-- Create Date : 02052023 [02-20-2023]
-- Author      : Sakinder
--
-- Description:
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_package.all;
use work.vfp_pkg.all;
use work.vpf_records.all;
use work.ports_package.all;
entity rgbogp is
port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    iRgb           : in channel;
    oRgb           : out channel);
end rgbogp;
architecture behavioral of rgbogp is
    signal rgbSyncSof                    : std_logic_vector(7 downto 0);
    signal rgbSyncEol                    : std_logic_vector(7 downto 0);
    signal rgbSyncEof                    : std_logic_vector(7 downto 0);
    signal rgbSyncValid                  : std_logic_vector(7 downto 0);
    signal rgb                           : type_inteChannel(0 to 5);
    signal key                           : integer;
    signal rgb_min                       : integer;
    signal rgb_max                       : integer;
    signal rgb_mid                       : integer;
    signal rgb_max_is                    : integer;
    signal rgb_mid_is                    : integer;
    signal rgb_min_is                    : integer;
    signal rgb_delta_max_mid_min         : integer;
    signal ogp_red                       : std_logic_vector(7 downto 0);
    signal ogp_gre                       : std_logic_vector(7 downto 0);
    signal ogp_blu                       : std_logic_vector(7 downto 0);
    signal ogp                           : channel;
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
process (clk) begin
    if rising_edge(clk) then
        rgbSyncValid(0)  <= iRgb.valid;
        for i in 0 to 6 loop
          rgbSyncValid(i+1)  <= rgbSyncValid(i);
        end loop;
    end if;
end process;
-------------------------------------------------------------------------------
process (clk) begin
    if rising_edge(clk) then
        rgb(0).red    <= u_to_integer(iRgb.red(9 downto 2));
        rgb(0).green  <= u_to_integer(iRgb.green(9 downto 2));
        rgb(0).blue   <= u_to_integer(iRgb.blue(9 downto 2));
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        for i in 0 to 3 loop
            rgb(i+1)  <= rgb(i);
        end loop;
    end if;
end process;
-------------------------------------------------------------------------------
process (clk) begin
    if rising_edge(clk) then
        rgb_max_is             <= max3(rgb(0).red,rgb(0).green,rgb(0).blue);
        rgb_mid_is             <= mid3(rgb(0).red,rgb(0).green,rgb(0).blue);
        rgb_min_is             <= min3(rgb(0).red,rgb(0).green,rgb(0).blue);
    end if;
end process;
-------------------------------------------------------------------------------
process (clk) begin
    if rising_edge(clk) then
        rgb_min          <= covert_to_upper_limit(rgb_min_is);
        rgb_max          <= rgb_max_is;
        rgb_mid          <= rgb_mid_is;
    end if;
end process;
-------------------------------------------------------------------------------
process (clk) begin
    if rising_edge(clk) then
        rgb_delta_max_mid_min      <= int_abs_delta(rgb_max,rgb_mid,rgb_min);
    end if;
end process;
-------------------------------------------------------------------------------
process (clk) begin
    if rising_edge(clk) then 
        key     <= covert_to_upper_limit(rgb_delta_max_mid_min);
    end if;
end process;
-------------------------------------------------------------------------------
-- RGB TO ORANGE GREEN PURPLE(OGP)
-------------------------------------------------------------------------------
process (clk) begin
    if rising_edge(clk) then
        rgb(5).red         <= rgb(4).red + key;
        rgb(5).green       <= rgb(4).green + key;
        rgb(5).blue        <= rgb(4).blue + key;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        ogp.red         <= std_logic_vector(to_unsigned(rgb(5).red, 10));
        ogp.green       <= std_logic_vector(to_unsigned(rgb(5).green, 10));
        ogp.blue        <= std_logic_vector(to_unsigned(rgb(5).blue, 10));
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        ogp_red         <= ogp.red(8 downto 1);
        ogp_gre         <= ogp.green(8 downto 1);
        ogp_blu         <= ogp.blue(8 downto 1);
    end if;
end process;
-------------------------------------------------------------------------------
process (clk) begin
    if rising_edge(clk) then
        oRgb.red       <= ogp_red & "00";
        oRgb.green     <= ogp_gre & "00";
        oRgb.blue      <= ogp_blu & "00";
        oRgb.valid     <= rgbSyncValid(7);
        oRgb.eol       <= rgbSyncEol(7);
        oRgb.sof       <= rgbSyncSof(7);
        oRgb.eof       <= rgbSyncEof(7);
    end if;
end process;
-------------------------------------------------------------------------------
end behavioral;