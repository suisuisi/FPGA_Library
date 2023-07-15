-------------------------------------------------------------------------------
-- RGB to YCbCr Conversion
--
-- FILE: rgb2ycbcr.vhd
-- AUTHOR: Wade Fife
-- DATE: June 9, 2006
-- MODIFIED: June 23, 2006
--
--
-- DESCRIPTION
--
-- Converts RGB pixels to YCbCr. Data is written to the core by asserting iRed, iGreen,
-- and iRgb.blue with the RGB pixel data and holding iRgb.valid high for one clock
-- cycle. After conversion, the YCbCr data is asserted on the y, cb, and cr
-- outputs and oValid is held high for one clock cycle. No flow control is
-- supported. You can adjust the pixel input/output width by changing the
-- i_data_width generic. The precision of the fixed point computation can be
-- adjusted by changing the i_precision generic. Up to 32-bit precision is
-- supported, but high precision comes at a great cost.
--
-- The arithmetic for the conversion is taken from Keith Jack's book, Video
-- Demystified, 4th Edition. The equations (assuming gamma corrected, 8-bit,
-- RGB values) are as follows. For inputs in the range 0-255:
--
--     Y =  0.257R + 0.504G + 0.098B + 16
--    Cb = -0.148R - 0.291G + 0.439B + 128
--    Cr =  0.439R - 0.368G - 0.071B + 128
--
-- For inputs in the range 16-235:
--
--     Y  =  0.299R + 0.587G + 0.114B
--     Cb = -0.172R - 0.339G + 0.511B + 128
--     Cr =  0.511R - 0.428G - 0.083B + 128
--
-- These equations need to be slightly modified for a general, n-bit pixel
-- components. In the general case 128 should be replaced with 2^(n-1) and 16
-- with 2^(n-4).  The coefficients above are rounded to the nearest 3
-- significant digits, but the actual constants used in the VHDL below may be
-- more precise.
--
-- In general, the code refers the the constant coefficients as follows:
--
--     Y  =  C_Y_R*R +  C_Y_G*G +  C_Y_B*B + C_I_16
--     Cb = C_CB_R*R + C_CB_G*G + C_CB_B*B + C_I_128
--     Cr = C_CR_R*R + C_CR_G*G + C_CR_G*B + C_I_128
--
-- After the multiplication, the equations are referred to as follows:
--
--     Y  =  y_r  + y_g  + y_b  + C_I_16
--     Cb = -cb_r - cb_g + cb_b + C_I_128
--     Cr =  cr_r - cr_g - cr_b + C_I_128
--
-- The constant C_I_16 will be 0 when the core is configured for the input
-- range 16-235.
--
--
-- INPUT RANGE
--
-- In video systems, the full range 0-255 is often not used for pixel values,
-- and instead the range 16-235 is used. If the RGB input pixel values have
-- range 0-255 then i_full_range should be set to TRUE. If they have range
-- 16-235 then i_full_range should be FALSE.
--
--
-- PRECISION
--
-- You can set i_data_width to indicate the input pixel width (e.iGreen., 8 for 8
-- bits per pixel) and i_precision to indicate the precision to be used in the
-- arithmetic computation. For simplicity, rounding is only performed at the
-- end of computation, which generally provides very good results.
--
-- In a bit-accurate software version I found that rounding intermediate
-- results (e.iGreen., after the multiplication) had only a very small effect on the
-- final result. Assuming a i_data_width of 8, I found that a i_precision of 12
-- will cause the resulting output values to be inexact about 6% of the time. A
-- i_precision of 14 gives inexact results about 1.5% of the time. A
-- i_precision of 16 gives inexact results about 0.4% of the time. Resulting
-- pixel values are never off by more than 1 in any of these examples.
-------------------------------------------------------------------------------
--02092019 [02-09-2019]
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
entity rgb2ycbcr is
  generic (
    i_data_width    : integer := 8;      -- Should be < 18 for best results
    i_precision     : integer := 12;     -- Should be < 18 for best results
    i_full_range    : boolean := FALSE);  -- RGB input from 0-255 (true)
  port (
    clk       : in  std_logic;
    rst_l     : in  std_logic;
    iRgb      : in channel;
    oRgb      : out channel);
end rgb2ycbcr; 
architecture imp of rgb2ycbcr is
  constant C_1_PRE : unsigned(i_precision-1 downto 0) := to_unsigned(1, i_precision);
  -- Coefficients as 0.32 format 32-bit fixeds point numbers
  -- Each is computed as C*(2^32)+0.5, then rounded down.
  signal C_I32_Y_R  : unsigned(31 downto 0);
  signal C_I32_Y_G  : unsigned(31 downto 0);
  signal C_I32_Y_B  : unsigned(31 downto 0);
  signal C_I32_CB_R : unsigned(31 downto 0);
  signal C_I32_CB_G : unsigned(31 downto 0);
  signal C_I32_CB_B : unsigned(31 downto 0);
  signal C_I32_CR_R : unsigned(31 downto 0);
  signal C_I32_CR_G : unsigned(31 downto 0);
  signal C_I32_CR_B : unsigned(31 downto 0);
  -- Coefficients in desired precision
  signal C_I_Y_R  : unsigned(i_precision-1 downto 0);
  signal C_I_Y_G  : unsigned(i_precision-1 downto 0);
  signal C_I_Y_B  : unsigned(i_precision-1 downto 0);
  signal C_I_CB_R : unsigned(i_precision-1 downto 0);
  signal C_I_CB_G : unsigned(i_precision-1 downto 0);
  signal C_I_CB_B : unsigned(i_precision-1 downto 0);
  signal C_I_CR_R : unsigned(i_precision-1 downto 0);
  signal C_I_CR_G : unsigned(i_precision-1 downto 0);
  signal C_I_CR_B : unsigned(i_precision-1 downto 0);
  signal C_I_128  : unsigned(i_data_width-1 downto 0);
  signal C_I_16   : unsigned(i_data_width-1 downto 0);
  -- Stage 0 signals
  signal r_0  : unsigned(i_data_width-1 downto 0);
  signal g_0  : unsigned(i_data_width-1 downto 0);
  signal b_0  : unsigned(i_data_width-1 downto 0);
  signal en_0 : std_logic;
  -- Stage 1 signals
  signal y_r, y_g, y_b    : unsigned(i_precision-1 downto 0);
  signal cb_r, cb_g, cb_b : unsigned(i_precision-1 downto 0);
  signal cr_r, cr_g, cr_b : unsigned(i_precision-1 downto 0);
  signal en_1 : std_logic;
  -- Stage 2 signals
  signal y_2, cb_2, cr_2 : unsigned(i_data_width downto 0);
  signal en_2 : std_logic;
  -- Stage 3 signals
  signal y_3, cb_3, cr_3 : unsigned(i_data_width-1 downto 0);

  
    signal rgbSyncEol     : std_logic_vector(3 downto 0) := x"0";
    signal rgbSyncSof     : std_logic_vector(3 downto 0) := x"0";
    signal rgbSyncEof     : std_logic_vector(3 downto 0) := x"0";
    signal rgbSyncValid   : std_logic_vector(3 downto 0) := x"0";
  
begin
  -- Assign constants based on current mode (full range or not)
  GEN_FULL_RANGE_CONSTANTS_T: if i_full_range generate
    C_I32_Y_R  <= x"41bcec85";
    C_I32_Y_G  <= x"810e9920";
    C_I32_Y_B  <= x"19105e1c";
    C_I32_CB_R <= x"25f1f14a";
    C_I32_CB_G <= x"4a7e73a3";
    C_I32_CB_B <= x"707064ed";
    C_I32_CR_R <= x"707064ed";
    C_I32_CR_G <= x"5e276b7f";
    C_I32_CR_B <= x"1248f96e";
    C_I_16 <= shift_left(to_unsigned(1,i_data_width), i_data_width-4);
  end generate;
  GEN_FULL_RANGE_CONSTANTS_F: if not i_full_range generate
    C_I32_Y_R  <= x"4c8b4396";
    C_I32_Y_G  <= x"9645a1cb";
    C_I32_Y_B  <= x"1d2f1aa0";
    C_I32_CB_R <= x"2c2e989a";
    C_I32_CB_G <= x"56bd6e8b";
    C_I32_CB_B <= x"82ec0725";
    C_I32_CR_R <= x"82ec0725";
    C_I32_CR_G <= x"6da187a5";
    C_I32_CR_B <= x"154a7f80";
    C_I_16     <= (others => '0');
  end generate;
  -- Compute coefficients constants in desired precsion, with a bit of rounding
  C_I_Y_R <= C_I32_Y_R(31 downto 31-i_precision+1)
             when C_I32_Y_R(31-i_precision) = '0'
             else C_I32_Y_R(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_Y_G <= C_I32_Y_G(31 downto 31-i_precision+1)
             when C_I32_Y_G(31-i_precision) = '0'
             else C_I32_Y_G(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_Y_B <= C_I32_Y_B(31 downto 31-i_precision+1)
             when C_I32_Y_B(31-i_precision) = '0'
             else C_I32_Y_B(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_CB_R <= C_I32_CB_R(31 downto 31-i_precision+1)
             when C_I32_CB_R(31-i_precision) = '0'
             else C_I32_CB_R(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_CB_G <= C_I32_CB_G(31 downto 31-i_precision+1)
             when C_I32_CB_G(31-i_precision) = '0'
             else C_I32_CB_G(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_CB_B <= C_I32_CB_B(31 downto 31-i_precision+1)
             when C_I32_CB_B(31-i_precision) = '0'
             else C_I32_CB_B(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_CR_R <= C_I32_CR_R(31 downto 31-i_precision+1)
             when C_I32_CR_R(31-i_precision) = '0'
             else C_I32_CR_R(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_CR_G <= C_I32_CR_G(31 downto 31-i_precision+1)
             when C_I32_CR_G(31-i_precision) = '0'
             else C_I32_CR_G(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_CR_B <= C_I32_CR_B(31 downto 31-i_precision+1)
             when C_I32_CR_B(31-i_precision) = '0'
             else C_I32_CR_B(31 downto 31-i_precision+1) + C_1_PRE;
  C_I_128 <= shift_left(to_unsigned(1,i_data_width), i_data_width-1);
  -----------------------------------------------------------------------------
  -- STAGE 0: Input registers
  -----------------------------------------------------------------------------
  STAGE_0_PROC: process (clk, rst_l)
  begin
    if rst_l = '0' then
      en_0  <= '0';
      r_0   <= (others => '0');
      g_0   <= (others => '0');
      b_0   <= (others => '0');
    elsif clk'event and clk = '1' then
      r_0  <= unsigned(iRgb.red(9 downto 2));
      g_0  <= unsigned(iRgb.green(9 downto 2));
      b_0  <= unsigned(iRgb.blue(9 downto 2));
      en_0 <= iRgb.valid;
    end if;
  end process;
  
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
  
  
  
  -----------------------------------------------------------------------------
  -- STAGE 1: Multiplication
  -----------------------------------------------------------------------------
  STAGE_1_PROC: process (clk, rst_l, en_0, r_0, g_0, b_0)
    variable temp : unsigned(i_data_width+i_precision-1 downto 0);
  begin
    if rst_l = '0' then
      en_1 <= '0';
      y_r  <= (others => '0');
      y_g  <= (others => '0');
      y_b  <= (others => '0');
      cb_r <= (others => '0');
      cb_g <= (others => '0');
      cb_b <= (others => '0');
      cr_r <= (others => '0');
      cr_g <= (others => '0');
      cr_b <= (others => '0');
    elsif clk'event and clk = '1' then
      en_1 <= en_0;
      -- Perform multiplication at full precision. i_precision-bit *
      -- i_data_width-bit to produce (i_precision+i_data_width)-bit result.
      temp := C_I_Y_R * r_0;
      y_r <= temp(temp'left downto temp'left-i_precision+1);
      temp := C_I_Y_G * g_0;
      y_g <= temp(temp'left downto temp'left-i_precision+1);
      temp := C_I_Y_B * b_0;
      y_b <= temp(temp'left downto temp'left-i_precision+1);
      temp := C_I_CB_R * r_0;
      cb_r <= temp(temp'left downto temp'left-i_precision+1);
      temp := C_I_CB_G * g_0;
      cb_g <= temp(temp'left downto temp'left-i_precision+1);
      temp := C_I_CB_B * b_0;
      cb_b <= temp(temp'left downto temp'left-i_precision+1);
      temp := C_I_CR_R * r_0;
      cr_r <= temp(temp'left downto temp'left-i_precision+1);
      temp := C_I_CR_G * g_0;
      cr_g <= temp(temp'left downto temp'left-i_precision+1);
      temp := C_I_CR_B * b_0;
      cr_b <= temp(temp'left downto temp'left-i_precision+1);
    end if;
  end process;
  -----------------------------------------------------------------------------
  -- STAGE 2: Addition
  -----------------------------------------------------------------------------
  STAGE_2_PROC: process (clk, rst_l, en_1,y_r, y_g, y_b,cb_r, cb_g, cb_b,cr_r, cr_g, cr_b)
    variable temp_y   : unsigned(i_precision-1 downto 0);
    variable temp_cb  : unsigned(i_precision-1 downto 0);
    variable temp_cr  : unsigned(i_precision-1 downto 0);
  begin
    if rst_l = '0' then
      en_2 <= '0';
      y_2 <= (others => '0');
      cb_2 <= (others => '0');
      cr_2 <= (others => '0');
    elsif clk'event and clk = '1' then
      en_2 <= en_1;
      -- Do addition
      temp_y  := y_r + y_g + y_b;
      temp_cb := cb_b - cb_g - cb_r;
      temp_cr := cr_r - cr_g - cr_b;
      -- Truncate result to i_data_width+1 bits (1 bit for rounding later)
      y_2  <= temp_y(temp_y'left downto temp_y'left-i_data_width);
      cb_2 <= temp_cb(temp_cb'left downto temp_cb'left-i_data_width);
      cr_2 <= temp_cr(temp_cr'left downto temp_cr'left-i_data_width);
    end if;
  end process;
  -----------------------------------------------------------------------------
  -- STAGE 3: Final Addition and Rounding
  -----------------------------------------------------------------------------
  STAGE_3_PROC: process (clk, rst_l, en_2,y_r, y_g, y_b,cb_r, cb_g, cb_b,cr_r, cr_g, cr_b)
    variable y_round  : unsigned(i_data_width-1 downto 0);
    variable cb_round : unsigned(i_data_width-1 downto 0);
    variable cr_round : unsigned(i_data_width-1 downto 0);
  begin
    if rst_l = '0' then

      y_3 <= (others => '0');
      cb_3 <= (others => '0');
      cr_3 <= (others => '0');
    elsif clk'event and clk = '1' then

      -- Determine rounding, combine with the 128 constant
      if y_2(0) = '1' then
        if i_full_range then
          y_round := C_I_16+1;
        else
          y_round := to_unsigned(1, i_data_width);
        end if;
      else
        if i_full_range then
          y_round := C_I_16;
        else
          y_round := (others => '0');
        end if;
      end if;
      if cb_2(0) = '1' then
        cb_round := resize(C_I_128+1, i_data_width);
      else
        cb_round := C_I_128;
      end if;
      if cr_2(0) = '1' then
        cr_round := resize(C_I_128+1, i_data_width);
      else
        cr_round := C_I_128;
      end if;
      y_3  <= y_2(y_2'left downto 1) + y_round;
      cb_3 <= cb_2(cb_2'left downto 1) + cb_round;
      cr_3 <= cr_2(cr_2'left downto 1) + cr_round;
    end if;
  end process;
  oRgb.red      <= std_logic_vector(y_3) & "00";
  oRgb.green    <= std_logic_vector(cb_3) & "00";
  oRgb.blue     <= std_logic_vector(cr_3) & "00";
  oRgb.valid    <= rgbSyncValid(3);
  oRgb.eol      <= rgbSyncEol(3);
  oRgb.sof      <= rgbSyncSof(3);
  oRgb.eof      <= rgbSyncEof(3);
end imp;