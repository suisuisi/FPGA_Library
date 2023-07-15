library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_package.all;
use work.vfp_pkg.all;
use work.vpf_records.all;
use work.ports_package.all;
entity rgb_to_ryb is
generic (
    i_data_width   : natural := 8);
port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    iRgb           : in channel;
    oRgb           : out channel);
end rgb_to_ryb;
architecture behavioral of rgb_to_ryb is

    function min2(a : integer; b : integer) return integer is
        variable result : integer;
    begin
		if a < b then
            result := a;
        else
            result := b;
        end if;
        return result;
    end function min2;
    function min3(a : integer; b : integer; c : integer) return integer is
        variable result : integer;
    begin
		if a < b then
            result := a;
        else
            result := b;
        end if;
        if c < result then
            result := c;
        end if;
        return result;
    end function min3;
    
    function max3(a : integer; b : integer; c : integer) return integer is
        variable result : integer;
    begin
        if a > b then
            result := a;
        else
            result := b;
        end if;
        if c > result then
            result := c;
        end if;
        return result;
    end function max3;
    signal rgbSyncValid         : std_logic_vector(11 downto 0) := x"000";
    signal rgbSyncEol           : std_logic_vector(11 downto 0) := x"000";
    signal rgbSyncSof           : std_logic_vector(11 downto 0) := x"000";
    signal rgbSyncEof           : std_logic_vector(11 downto 0) := x"000";
    signal rgb_sync11           : inteChannel;
    signal rgb_sync12           : inteChannel;
    signal rgb_sync_1           : inteChannel;
    signal rgb_sync_2           : inteChannel;
    signal rgb_sync_3           : inteChannel;
    signal rgb_sync33           : inteChannel;
    signal rgb_sync_4           : inteChannel;
    signal rgb_sync_5           : inteChannel;
    signal rgb_sync_6           : inteChannel;
    signal rgb_sync1            : inteChannel;
    signal rgb_sync2            : inteChannel;
    signal rgb_sync3            : inteChannel;
    signal rgb_sync4            : inteChannel;
    signal rgb_sync5            : inteChannel;
    signal rgb_sync6            : inteChannel;
    signal rgb_sync7            : inteChannel;
    signal red_gre_min          : integer;
    signal yel_blue_min         : integer;
    signal rgb_min              : integer;
    signal rgb1max              : integer;
    signal rgb_max              : integer;
    signal ryb_min              : integer;
    signal ryb_max              : integer;
    signal color_n              : integer;
  
begin

process (clk) begin
    if rising_edge(clk) then
        rgbSyncValid(0)  <= iRgb.valid;
        for i in 0 to 10 loop
          rgbSyncValid(i+1)  <= rgbSyncValid(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEol(0)  <= iRgb.eol;
        for i in 0 to 10 loop
          rgbSyncEol(i+1)  <= rgbSyncEol(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncSof(0)  <= iRgb.sof;
        for i in 0 to 10 loop
          rgbSyncSof(i+1)  <= rgbSyncSof(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEof(0)  <= iRgb.eof;
        for i in 0 to 10 loop
          rgbSyncEof(i+1)  <= rgbSyncEof(i);
        end loop;
    end if;
end process;

process (clk)begin
    if rising_edge(clk) then
        rgb_sync11.red    <= to_integer(unsigned(iRgb.red(9 downto 2)));
        rgb_sync11.green  <= to_integer(unsigned(iRgb.green(9 downto 2)));
        rgb_sync11.blue   <= to_integer(unsigned(iRgb.blue(9 downto 2)));

    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_sync1        <= rgb_sync11;
        rgb_sync2        <= rgb_sync1;
        rgb_sync3        <= rgb_sync2;
        rgb_sync4        <= rgb_sync3;
        rgb_sync5        <= rgb_sync4;
        rgb_sync6        <= rgb_sync5;
        rgb_sync7        <= rgb_sync6;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_sync12        <= rgb_sync11;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_min        <= min3(rgb_sync11.red,rgb_sync11.green,rgb_sync11.blue);
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        rgb_sync_1.red    <= rgb_sync12.red - rgb_min;
        rgb_sync_1.green  <= rgb_sync12.green - rgb_min;
        rgb_sync_1.blue   <= rgb_sync12.blue - rgb_min;

    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
        red_gre_min    <= min2(rgb_sync_1.red,rgb_sync_1.green);
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_sync_2        <= rgb_sync_1;

    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb1max        <= max3((rgb_sync_2.red),(rgb_sync_2.green),(rgb_sync_2.blue));
        rgb_max        <= rgb1max;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_sync_3.red <= abs(rgb_sync_2.red - red_gre_min);
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_sync_3.green <= (rgb_sync_2.green + red_gre_min)/2;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_sync_3.blue <= (rgb_sync_2.blue + (rgb_sync_2.green - red_gre_min))/2;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        ryb_max        <= max3((rgb_sync_3.red),(rgb_sync_3.green),(rgb_sync_3.blue));
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        if (ryb_max>0) then
            color_n        <= rgb_max/ryb_max;
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
            rgb_sync33.red        <= rgb_sync_3.red;
            rgb_sync33.green      <= rgb_sync_3.green;
            rgb_sync33.blue       <= rgb_sync_3.blue;

    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        ryb_min        <= min3((rgb_sync7.red),(rgb_sync7.green),(rgb_sync7.blue));
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_sync_4        <= rgb_sync33;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgb_sync_5.red   <= (rgb_sync_4.red + ryb_min);
        rgb_sync_5.green <= (rgb_sync_4.green + ryb_min);
        rgb_sync_5.blue  <= (rgb_sync_4.blue + ryb_min);
    end if;
end process;

process (clk)begin
    if rising_edge(clk) then
        if(rgb_sync_5.red >= 255)then
            rgb_sync_6.red      <= 255;
        else
            rgb_sync_6.red      <= rgb_sync_5.red;
        end if;
        if(rgb_sync_5.green >= 255)then
            rgb_sync_6.green      <= 255;
        else
            rgb_sync_6.green      <= rgb_sync_5.green;
        end if;
        if(rgb_sync_5.blue >= 255)then
            rgb_sync_6.blue      <= 255;
        else
            rgb_sync_6.blue      <= rgb_sync_5.blue;
        end if;
    end if;
end process;




process (clk)begin
    if rising_edge(clk) then
        oRgb.red     <= std_logic_vector(to_unsigned(rgb_sync_6.red, 8)) & "00";
        oRgb.green   <= std_logic_vector(to_unsigned(rgb_sync_6.green, 8)) & "00";
        oRgb.blue    <= std_logic_vector(to_unsigned(rgb_sync_6.blue, 8)) & "00";
        oRgb.eol     <= rgbSyncEol(7);
        oRgb.sof     <= rgbSyncSof(7);
        oRgb.eof     <= rgbSyncEof(7);
        oRgb.valid   <= rgbSyncValid(7);
    end if;
end process;

end behavioral;