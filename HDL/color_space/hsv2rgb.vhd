library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_package.all;
use work.vfp_pkg.all;
use work.vpf_records.all;
use work.ports_package.all;
entity hsv2rgb is
port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    iHsl           : in channel;
    oRgb           : out channel);
end hsv2rgb;
architecture behavioral of hsv2rgb is
  signal RGB_Max_Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Max1Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Max2Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Max3Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Max4Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Max5Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Tmp_Data    : unsigned(15 downto 0):= (others =>'0');
  signal RGB_Max_Adjust  : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Min_Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Min1Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Min2Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Min3Data    : unsigned(7 downto 0):= (others =>'0');
  signal RGB_Delta_Data  : unsigned(7 downto 0):= (others =>'0');
  signal Data_H1         : unsigned(8 downto 0):= (others =>'0');
  signal Data_H2         : unsigned(8 downto 0):= (others =>'0');
  signal Data_H3         : unsigned(8 downto 0):= (others =>'0');
  signal Data_H4         : unsigned(8 downto 0):= (others =>'0');
  signal Data_H5         : unsigned(8 downto 0):= (others =>'0');
  signal Data_H_Mod      : unsigned(8 downto 0):= (others =>'0');
  signal Data_H1Mod      : unsigned(8 downto 0):= (others =>'0');
  signal Data_H2Mod      : unsigned(8 downto 0):= (others =>'0');
  signal Data_H3Mod      : unsigned(8 downto 0):= (others =>'0');
  signal Data_H4Mod      : unsigned(8 downto 0):= (others =>'0');
  signal RGB_Adjust_Tmp  : unsigned(16 downto 0):= (others =>'0');
  signal RGB_Adjust      : unsigned(16 downto 0):= (others =>'0');
  signal RGB_R           : unsigned(7 downto 0):= (others =>'0');
  signal RGB_G           : unsigned(7 downto 0):= (others =>'0');
  signal RGB_B           : unsigned(7 downto 0):= (others =>'0');
  signal rgbSyncValid    : std_logic_vector(23 downto 0) := x"000000";
  signal rgbSyncEol      : std_logic_vector(23 downto 0) := x"000000";
  signal rgbSyncSof      : std_logic_vector(23 downto 0) := x"000000";
  signal rgbSyncEof      : std_logic_vector(23 downto 0) := x"000000";
  
  
begin    

process (clk) begin
    if rising_edge(clk) then
        RGB_Max_Data   <= unsigned(iHsl.blue(9 downto 2));
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        RGB_Max1Data   <= RGB_Max_Data;
        RGB_Max2Data   <= RGB_Max1Data;
        RGB_Max3Data   <= RGB_Max2Data;
        RGB_Max4Data   <= RGB_Max3Data;
        RGB_Max5Data   <= RGB_Max4Data;
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        RGB_Tmp_Data   <= unsigned(iHsl.blue(9 downto 2)) * (255 - unsigned(iHsl.green(9 downto 2)));
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        RGB_Min_Data   <= RGB_Tmp_Data(15 downto 8);
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        RGB_Min1Data   <= RGB_Min_Data;
        RGB_Min2Data   <= RGB_Min1Data;
        RGB_Min3Data   <= RGB_Min2Data;
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        RGB_Delta_Data <= (RGB_Max1Data-RGB_Min_Data);
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        Data_H_Mod     <= unsigned(iHsl.red(9 downto 1)) mod 60;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        Data_H1     <= unsigned(iHsl.red(9 downto 1));
        Data_H2     <= Data_H1;
        Data_H3     <= Data_H2;
        Data_H4     <= Data_H3;
        Data_H5     <= Data_H4;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        Data_H1Mod     <= Data_H_Mod;
        Data_H2Mod     <= Data_H1Mod;
        Data_H3Mod     <= Data_H2Mod;
        Data_H4Mod     <= Data_H3Mod;
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        RGB_Adjust_Tmp <= (RGB_Delta_Data*Data_H2Mod);
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        RGB_Adjust     <= RGB_Adjust_Tmp/60;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncValid(0)  <= iHsl.valid;
        for i in 0 to 22 loop
          rgbSyncValid(i+1)  <= rgbSyncValid(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEol(0)  <= iHsl.eol;
        for i in 0 to 22 loop
          rgbSyncEol(i+1)  <= rgbSyncEol(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncSof(0)  <= iHsl.sof;
        for i in 0 to 22 loop
          rgbSyncSof(i+1)  <= rgbSyncSof(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEof(0)  <= iHsl.eof;
        for i in 0 to 22 loop
          rgbSyncEof(i+1)  <= rgbSyncEof(i);
        end loop;
    end if;
end process;
RGB_Max_Adjust <= x"ff" when (RGB_Min3Data+RGB_Adjust) >=255 else (resize(unsigned(RGB_Min3Data+RGB_Adjust), 8));
process (clk) begin
    if (reset = lo) then
        RGB_R  <= (others =>'0');
        RGB_G  <= (others =>'0');
        RGB_B  <= (others =>'0');
    elsif rising_edge(clk) then
        if (Data_H5 < 60) then--RED MAX RANGE [RED-G,ORANGE,YELLOW]
            RGB_R    <= (RGB_Max4Data);
            RGB_G    <= (RGB_Max_Adjust);
            RGB_B    <= (RGB_Min3Data);
        elsif(Data_H5 < 120)then--GREEN MAX RANGE [YELLOW,LIGHT-GREEN,GREEN]
            RGB_R    <= (resize(unsigned(RGB_Max4Data-RGB_Adjust), 8));
            RGB_G    <= (RGB_Max4Data);
            RGB_B    <= (RGB_Min3Data);
        elsif(Data_H5 < 180)then--BLUE MAX RANGE [LIGHT-CYAN,CYAN,BLUE]
            RGB_R    <= (RGB_Min3Data);
            RGB_G    <= (RGB_Max4Data);
            RGB_B    <= (RGB_Max_Adjust);
        elsif(Data_H5 < 240)then --BLUE MAX RANGE [BLUE-R,MAGENTA] 
            RGB_R    <= (RGB_Min3Data);
            RGB_G    <= (resize(unsigned(RGB_Max4Data-RGB_Adjust), 8));
            RGB_B    <= (RGB_Max4Data);
        elsif(Data_H5 < 300)then --RED MAX RANGE [RED-B,MAGENTA]
            RGB_R    <= (RGB_Max_Adjust);
            RGB_G    <= (RGB_Min3Data);
            RGB_B    <= (RGB_Max4Data);
        else
            RGB_R    <= (RGB_Max4Data);
            RGB_G    <= (RGB_Min3Data);
            RGB_B    <= (resize(unsigned(RGB_Max4Data-RGB_Adjust), 8));
        end if;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        oRgb.red        <= std_logic_vector(RGB_R(7 downto 0)) & "00";
        oRgb.green      <= std_logic_vector(RGB_G(7 downto 0)) & "00";
        oRgb.blue       <= std_logic_vector(RGB_B(7 downto 0)) & "00";
        oRgb.valid      <= rgbSyncValid(6);
        oRgb.eol      <= rgbSyncEol(6);
        oRgb.sof      <= rgbSyncSof(6);
        oRgb.eof      <= rgbSyncEof(6);
    end if;
end process;
end behavioral;