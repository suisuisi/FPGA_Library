library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
entity ycbcr2rgb is
  port (
    clk             : in std_logic;
    rst_l           : in std_logic;
    iRgb            : in channel;
    oRgb            : out channel);
end ycbcr2rgb;
architecture behavioral of ycbcr2rgb is
    signal rgb_pixel      : s_channel;
    constant coef_red     : signed(8 downto 0):="010010101";--149
    constant coef_blu1    : signed(8 downto 0):="011001100";--204
    constant coef_blu2    : signed(8 downto 0):="110011000";--104
    constant coef_gre     : signed(8 downto 0):="111001110";--50
    signal product_red    : signed(17 downto 0);
    signal product_blu1   : signed(17 downto 0);
    signal product_blu2   : signed(17 downto 0);
    signal product_gre1   : signed(17 downto 0);
    signal product_gre2   : signed(17 downto 0);
    signal sum_red        : signed(17 downto 0);
    signal sum_gre        : signed(17 downto 0);
    signal sum_blu        : signed(17 downto 0);
    signal rgbSyncEol     : std_logic_vector(3 downto 0) := x"0";
    signal rgbSyncSof     : std_logic_vector(3 downto 0) := x"0";
    signal rgbSyncEof     : std_logic_vector(3 downto 0) := x"0";
    signal rgbSyncValid   : std_logic_vector(3 downto 0) := x"0";
begin
process (clk) begin
    if rising_edge(clk) then
        rgbSyncValid(0)  <= iRgb.valid;
        for i in 0 to 2 loop
          rgbSyncValid(i+1)  <= rgbSyncValid(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEol(0)  <= iRgb.eol;
        for i in 0 to 2 loop
          rgbSyncEol(i+1)  <= rgbSyncEol(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncSof(0)  <= iRgb.sof;
        for i in 0 to 2 loop
          rgbSyncSof(i+1)  <= rgbSyncSof(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEof(0)  <= iRgb.eof;
        for i in 0 to 2 loop
          rgbSyncEof(i+1)  <= rgbSyncEof(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_pixel.red    <= ('0' & signed(iRgb.red(9 downto 2)))  - "000010000";
        rgb_pixel.green  <= ('0' & signed(iRgb.green(9 downto 2)))- "010000000";
        rgb_pixel.blue   <= ('0' & signed(iRgb.blue(9 downto 2))) - "010000000";
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        product_red    <= rgb_pixel.red   * coef_red;
        product_blu1   <= rgb_pixel.blue  * coef_blu1;
        product_blu2   <= rgb_pixel.blue  * coef_blu2;
        product_gre1   <= rgb_pixel.green * coef_gre;
        product_gre2   <= (rgb_pixel.green(8) & rgb_pixel.green(8 downto 0) & "00000000") + (rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(7 downto 0) & '0') ;
    end if;
end process;
--sum_red   <= (1.164 * 128 * red) + (1.596 * 128 * blue);
--sum_green <= (1.164 * 128 * red) + (0.813 * 128 * blue) + (0.392 * 128 * green);
--sum_blue  <= (1.164 * 128 * red) + (rgb_pixel.green(8) & rgb_pixel.green(8 downto 0) & "00000000") + (rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(8) & rgb_pixel.green(7 downto 0) & '0') ;
process (clk) begin
    if rising_edge(clk) then
        sum_red    <= product_red + product_blu1;
        sum_gre    <= product_red + product_blu2 + product_gre1;
        sum_blu    <= product_red + product_gre2;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if (sum_red(17) = '1') then
            oRgb.red     <= (others =>'0');
        elsif(sum_red(15)= '1' or sum_red(16)= '1') then
            oRgb.red     <= (others =>'1');
        else
            oRgb.red     <= std_logic_vector(sum_red(14 downto 7)) & "00";
        end if;
        if (sum_gre(17) = '1') then
            oRgb.green     <= (others =>'0');
        elsif(sum_gre(15)= '1' or sum_gre(16)= '1') then
            oRgb.green     <= (others =>'1');
        else
            oRgb.green     <= std_logic_vector(sum_gre(14 downto 7)) & "00";
        end if;
        if (sum_blu(17) = '1') then
            oRgb.blue     <= (others =>'0');
        elsif(sum_blu(15)= '1' or sum_blu(16)= '1') then
            oRgb.blue     <= (others =>'1');
        else
            oRgb.blue     <= std_logic_vector(sum_blu(14 downto 7)) & "00";
        end if;
        oRgb.valid   <= rgbSyncValid(3);
        oRgb.eol     <= rgbSyncEol(3);
        oRgb.sof     <= rgbSyncSof(3);
        oRgb.eof     <= rgbSyncEof(3);
    end if;
end process;
end behavioral;