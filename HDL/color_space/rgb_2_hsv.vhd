library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_pkg.all;
use work.float_pkg.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
entity rgb_2_hsv is
    port (
        clk            : in std_logic;
        rst            : in std_logic;
        iRGB           : in channel;
        oHSV           : out channel;
        oHSV_YCB       : out channel);
end rgb_2_hsv;
architecture arch_imp of rgb_2_hsv is
    signal rgbSyncValid             : std_logic_vector(23 downto 0) := x"000000";
    signal rgbSyncEol               : std_logic_vector(23 downto 0) := x"000000";
    signal rgbSyncSof               : std_logic_vector(23 downto 0) := x"000000";
    signal rgbSyncEof               : std_logic_vector(23 downto 0) := x"000000";
    signal rgb1Ycbcr                : channel;
    signal rgb2Ycbcr                : channel;

    signal HueRed                   : std_logic_vector(8 downto 0);  
    signal HueGre                   : std_logic_vector(7 downto 0);  
    signal HueBlu                   : std_logic_vector(7 downto 0);
    signal rgb_hue                  : rgbToSf10bRecord;
    signal rgb_ycb                  : rgbToSf10bRecord;
    signal ycb1hue                 : rgbToSf12Record;
    signal ycb2hue                 : rgbToSf10bRecord;
begin
process (clk)begin
    if rising_edge(clk) then
      rgbSyncValid(0)   <= iRgb.valid;
      rgbSyncValid(1)   <= rgbSyncValid(0);
      rgbSyncValid(2)   <= rgbSyncValid(1);
      rgbSyncValid(3)   <= rgbSyncValid(2);
      rgbSyncValid(4)   <= rgbSyncValid(3);
      rgbSyncValid(5)   <= rgbSyncValid(4);
      rgbSyncValid(6)   <= rgbSyncValid(5);
      rgbSyncValid(7)   <= rgbSyncValid(6);
      rgbSyncValid(8)   <= rgbSyncValid(7);
      rgbSyncValid(9)   <= rgbSyncValid(8);
      rgbSyncValid(10)  <= rgbSyncValid(9);
      rgbSyncValid(11)  <= rgbSyncValid(10);
      rgbSyncValid(12)  <= rgbSyncValid(11);
      rgbSyncValid(13)  <= rgbSyncValid(12);
      rgbSyncValid(14)  <= rgbSyncValid(13);
      rgbSyncValid(15)  <= rgbSyncValid(14);
      rgbSyncValid(16)  <= rgbSyncValid(15);
      rgbSyncValid(17)  <= rgbSyncValid(16);
      rgbSyncValid(18)  <= rgbSyncValid(17);
      rgbSyncValid(19)  <= rgbSyncValid(18);
      rgbSyncValid(20)  <= rgbSyncValid(19);
      rgbSyncValid(21)  <= rgbSyncValid(20);
      rgbSyncValid(22)  <= rgbSyncValid(21);
      rgbSyncValid(23)  <= rgbSyncValid(22);
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
      rgbSyncEol(0)   <= iRgb.eol;
      rgbSyncEol(1)   <= rgbSyncEol(0);
      rgbSyncEol(2)   <= rgbSyncEol(1);
      rgbSyncEol(3)   <= rgbSyncEol(2);
      rgbSyncEol(4)   <= rgbSyncEol(3);
      rgbSyncEol(5)   <= rgbSyncEol(4);
      rgbSyncEol(6)   <= rgbSyncEol(5);
      rgbSyncEol(7)   <= rgbSyncEol(6);
      rgbSyncEol(8)   <= rgbSyncEol(7);
      rgbSyncEol(9)   <= rgbSyncEol(8);
      rgbSyncEol(10)  <= rgbSyncEol(9);
      rgbSyncEol(11)  <= rgbSyncEol(10);
      rgbSyncEol(12)  <= rgbSyncEol(11);
      rgbSyncEol(13)  <= rgbSyncEol(12);
      rgbSyncEol(14)  <= rgbSyncEol(13);
      rgbSyncEol(15)  <= rgbSyncEol(14);
      rgbSyncEol(16)  <= rgbSyncEol(15);
      rgbSyncEol(17)  <= rgbSyncEol(16);
      rgbSyncEol(18)  <= rgbSyncEol(17);
      rgbSyncEol(19)  <= rgbSyncEol(18);
      rgbSyncEol(20)  <= rgbSyncEol(19);
      rgbSyncEol(21)  <= rgbSyncEol(20);
      rgbSyncEol(22)  <= rgbSyncEol(21);
      rgbSyncEol(23)  <= rgbSyncEol(22);
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
      rgbSyncSof(0)   <= iRgb.sof;
      rgbSyncSof(1)   <= rgbSyncSof(0);
      rgbSyncSof(2)   <= rgbSyncSof(1);
      rgbSyncSof(3)   <= rgbSyncSof(2);
      rgbSyncSof(4)   <= rgbSyncSof(3);
      rgbSyncSof(5)   <= rgbSyncSof(4);
      rgbSyncSof(6)   <= rgbSyncSof(5);
      rgbSyncSof(7)   <= rgbSyncSof(6);
      rgbSyncSof(8)   <= rgbSyncSof(7);
      rgbSyncSof(9)   <= rgbSyncSof(8);
      rgbSyncSof(10)  <= rgbSyncSof(9);
      rgbSyncSof(11)  <= rgbSyncSof(10);
      rgbSyncSof(12)  <= rgbSyncSof(11);
      rgbSyncSof(13)  <= rgbSyncSof(12);
      rgbSyncSof(14)  <= rgbSyncSof(13);
      rgbSyncSof(15)  <= rgbSyncSof(14);
      rgbSyncSof(16)  <= rgbSyncSof(15);
      rgbSyncSof(17)  <= rgbSyncSof(16);
      rgbSyncSof(18)  <= rgbSyncSof(17);
      rgbSyncSof(19)  <= rgbSyncSof(18);
      rgbSyncSof(20)  <= rgbSyncSof(19);
      rgbSyncSof(21)  <= rgbSyncSof(20);
      rgbSyncSof(22)  <= rgbSyncSof(21);
      rgbSyncSof(23)  <= rgbSyncSof(22);
    end if;
end process;
process (clk)begin
    if rising_edge(clk) then
      rgbSyncEof(0)   <= iRgb.eof;
      rgbSyncEof(1)   <= rgbSyncEof(0);
      rgbSyncEof(2)   <= rgbSyncEof(1);
      rgbSyncEof(3)   <= rgbSyncEof(2);
      rgbSyncEof(4)   <= rgbSyncEof(3);
      rgbSyncEof(5)   <= rgbSyncEof(4);
      rgbSyncEof(6)   <= rgbSyncEof(5);
      rgbSyncEof(7)   <= rgbSyncEof(6);
      rgbSyncEof(8)   <= rgbSyncEof(7);
      rgbSyncEof(9)   <= rgbSyncEof(8);
      rgbSyncEof(10)  <= rgbSyncEof(9);
      rgbSyncEof(11)  <= rgbSyncEof(10);
      rgbSyncEof(12)  <= rgbSyncEof(11);
      rgbSyncEof(13)  <= rgbSyncEof(12);
      rgbSyncEof(14)  <= rgbSyncEof(13);
      rgbSyncEof(15)  <= rgbSyncEof(14);
      rgbSyncEof(16)  <= rgbSyncEof(15);
      rgbSyncEof(17)  <= rgbSyncEof(16);
      rgbSyncEof(18)  <= rgbSyncEof(17);
      rgbSyncEof(19)  <= rgbSyncEof(18);
      rgbSyncEof(20)  <= rgbSyncEof(19);
      rgbSyncEof(21)  <= rgbSyncEof(20);
      rgbSyncEof(22)  <= rgbSyncEof(21);
      rgbSyncEof(23)  <= rgbSyncEof(22);
    end if;
end process;

--ycc2_inst  : rgb_ycbcr
--generic map(
--    i_data_width         => 10,
--    i_precision          => 12,
--    i_full_range         => TRUE)
--port map(
--    clk                  => clk,
--    rst_l                => rst,
--    iRgb                 => iRGB,
--    oRgb                 => rgb1Ycbcr);

--ycc2_syncr_inst  : sync_frames
--generic map(
--    pixelDelay      => 7)
--port map(
--    clk             => clk,
--    reset           => rst,
--    iRgb            => rgb1Ycbcr,
--    oRgb            => rgb2Ycbcr);


process (clk) begin
    if rising_edge(clk) then
        rgb_hue.red    <= to_sfixed("00" & HueRed(7 downto 0),rgb_hue.red);
        rgb_hue.green  <= to_sfixed("00" & HueGre,rgb_hue.green);
        rgb_hue.blue   <= to_sfixed("00" & HueBlu,rgb_hue.blue);
    end if;
end process;
    
process (clk) begin
    if rising_edge(clk) then
        rgb_ycb.red    <= to_sfixed("00" & rgb2Ycbcr.red(9 downto 2),rgb_ycb.red);
        rgb_ycb.green  <= to_sfixed("00" & rgb2Ycbcr.green(9 downto 2),rgb_ycb.green);
        rgb_ycb.blue   <= to_sfixed("00" & rgb2Ycbcr.blue(9 downto 2),rgb_ycb.blue);
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
        ycb1hue.red   <= abs(rgb_ycb.red - rgb_hue.red);
        ycb1hue.green <= abs(rgb_ycb.green - rgb_hue.green);
        ycb1hue.blue  <= abs(rgb_ycb.blue - rgb_hue.blue);
        ycb2hue.red   <= resize(ycb1hue.red,ycb2hue.red);
        ycb2hue.green <= resize(ycb1hue.green,ycb2hue.green);
        ycb2hue.blue  <= resize(ycb1hue.blue,ycb2hue.blue);
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        oHSV_YCB.red   <= std_logic_vector(ycb2hue.red(7 downto 0)) & "00";
        oHSV_YCB.green <= std_logic_vector(ycb2hue.green(7 downto 0)) & "00";
        oHSV_YCB.blue  <= std_logic_vector(ycb2hue.blue(7 downto 0)) & "00";
        oHSV_YCB.valid <= rgbSyncValid(14);
        oHSV_YCB.eol   <= rgbSyncEol(14);
        oHSV_YCB.sof   <= rgbSyncSof(14);
        oHSV_YCB.eof   <= rgbSyncEof(14);
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        oHSV.red   <= HueRed & '0';
        oHSV.green <= HueGre & "00";
        oHSV.blue  <= HueBlu & "00";
        oHSV.valid <= rgbSyncValid(11);
        oHSV.eol   <= rgbSyncEol(11);
        oHSV.sof   <= rgbSyncSof(11);
        oHSV.eof   <= rgbSyncEof(11);
    end if;
end process;

rgb_hsv_inst: rgb_hsv
port map(

        clk          => clk,
        rstn         => rst,
        data_rdy     => iRGB.valid,
        r            => iRGB.red(9 downto 2),
        g            => iRGB.green(9 downto 2),
        b            => iRGB.blue(9 downto 2),
        result_rdy   => open,
        h            => HueRed,
        s            => HueGre,
        v            => HueBlu);

end arch_imp;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



--! This component realizes the conversion from RGB to HSV color space.

--! The component can take one color pixel per clock cycle as input.
--! The HSV calculation is pipelined and may take a several clock cycles.
--! The result_rdy output indicates, if the outputs hold a valid computation result.
--! The pixels are processed using the FIFO principle.
entity rgb_hsv is
    port (

        clk        : in  std_logic;   --! Clock input
        rstn       : in  std_logic;   --! Negated asynchronous reset
        data_rdy   : in  std_logic;   --! Input bit indicating if the input data (#r, #g, #b) is ready to be processed
        r          : in  std_logic_vector(7 downto 0);  --! 8 bit red component of the input pixel
        g          : in  std_logic_vector(7 downto 0);  --! 8 bit green component of the input pixel
        b          : in  std_logic_vector(7 downto 0);  --! 8 bit blue component of the input pixel
        result_rdy : out std_logic;       --! Indicates whether the outputs (#h, #s, #v) represent valid pixel data
        h          : out std_logic_vector(8 downto 0);    --! 9 bit hue component of the output pixel (Range: 0° - 360°)
        s          : out std_logic_vector(7 downto 0);    --! 8 bit saturation component of the output pixel
        v          : out std_logic_vector(7 downto 0)     --! 8 bit value component of the output pixel
    );
end entity rgb_hsv;

--! rtl implementation of rgb_hsv
architecture rtl of rgb_hsv is

    --! returns the maximum value of the three given parameters
    function max3(a : unsigned; b : unsigned; c : unsigned) return unsigned is
        variable result : unsigned(7 downto 0) := "00000000";
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

    --! returns the minimum value of the three given parameters
    function min3(a : unsigned; b : unsigned; c : unsigned) return unsigned is
        variable result : unsigned(7 downto 0) := "11111111";
    begin
        -- STUDENT CODE HERE
		if a < b then
            result := a;
        else
            result := b;
        end if;
        if c < result then
            result := c;
        end if;
        return result;
        -- STUDENT CODE until HERE
    end function min3;
    
    --! left shifting to realize multiplication 60*
    function mul_60(a : unsigned; b : unsigned) return signed is
        variable result : signed(16 downto 0) := (others=> '0');
    begin
        -- STUDENT CODE HERE
        -- converts to signed with 17 bits
        result := to_signed(to_integer(a) - to_integer(b), 17);
        -- multiplication with 60
        -- left shift 6 times (*64) and subtract its left shifting with 2 times (*4)
        -- 64*result - 4*result = 60*result
        result := shift_left(result,6) - shift_left(result,2);
        return result;
        -- STUDENT CODE until HERE
    end function mul_60;
    
    --! left shifting to realize multiplication 255*
    function mul_255(a : unsigned; b : unsigned) return signed is
        variable result : signed(16 downto 0) := (others=> '0');
    begin
        -- STUDENT CODE HERE
        -- converts to signed with 17 bits
        result := to_signed(to_integer(a) - to_integer(b), 17);
        -- multiplication with 60
        -- left shift 8 times (*256) and subtract selfs (*1)
        -- 256*result - 1*result = 255*result
        result := shift_left(result,8) - result;
        return result;
        -- STUDENT CODE until HERE
    end function mul_255;
    

    type u8_array_t is array(natural range <>) of unsigned(7 downto 0);
    type u16_array_t is array(natural range <>) of signed(15 downto 0);
    type u11_array_t is array(natural range <>) of signed(10 downto 0);

    component div16_8_8 is
    port (
        clk        : in  std_logic;
		en         : in  STD_LOGIC;
        rstn       : in  std_logic;
        a          : in  std_logic_vector(16 downto 0);
        b          : in  std_logic_vector( 7 downto 0);
        result     : out std_logic_vector( 8 downto 0)
    );
    end component;

    -- STUDENT CODE HERE
--    -- max,min signal
--    signal max: unsigned(7 downto 0);
--    signal min: unsigned(7 downto 0);
    -- enable signal for divider
    signal en : std_logic := '0'; 
    
    -- signal for a and b ports (hue)
    signal h_divided : std_logic_vector(16 downto 0);
    signal h_divisor : std_logic_vector(7 downto 0);
    -- signal for a and b ports (saturation)
    signal s_divided : std_logic_vector(16 downto 0);
    signal s_divisor : std_logic_vector(7 downto 0);
    -- signal for value
--    signal v_divided : std_logic_vector(16 downto 0);
--    signal v_divisor : std_logic_vector(7 downto 0);
    
    -- result of divider for hue
    signal h_result : std_logic_vector(8 downto 0);
    -- result of divider for saturation
    signal s_result : std_logic_vector(8 downto 0);
    -- result of value
    signal v_result : u8_array_t(10 downto 0) := (others=>(others=>'0'));
    
    -- condition array for hue calculation
    signal h_condition : u11_array_t(2 downto 0) := (others=>(others=>'0'));
    
    -- pipeline register of result_rdy
    signal r_result_rdy : std_logic_vector(10 downto 0);


    -- STUDENT CODE until HERE

begin

    -- STUDENT CODE HERE
    div_16_instance_h : div16_8_8
        port map(clk  => clk,
                 en   => en,
                 rstn => rstn,
                 a    => h_divided,
                 b    => h_divisor,
                 result => h_result);
                 
    div_16_instance_s : div16_8_8
        port map(clk  => clk,
                 en   => en,
                 rstn => rstn,
                 a    => s_divided,
                 b    => s_divisor,
                 result => s_result);
    
    rgb3hsv: process(rstn, clk, data_rdy)
        -- results fo function of max3 and min3
        variable max, min : unsigned(7 downto 0); 
        -- real result of hue
        variable hue : signed(8 downto 0); 
        variable uhue : unsigned(8 downto 0); 
        -- condition array for hue calculation
        variable v_h_condition : u11_array_t(2 downto 0) := (others=>(others=>'0'));

    begin
        if rstn = '0' then
            -- initialize hsv
            h <= (others => '0');
            s <= (others => '0');
            v <= (others => '0');
            -- initialize result_rdy 
            result_rdy <= '0';
            r_result_rdy <= (others=>'0');
            -- turn off the divider
            en <= '0';
        elsif rising_edge(clk) then  
        
            -- pipeline structrue run always, has nothing to do with data_rdy 
            -- No matter how the conditions change, the array shifts left by one bit per round       
            v_h_condition(0) := shift_left(h_condition(0),1); 
            v_h_condition(1) := shift_left(h_condition(1),1); 
            v_h_condition(2) := shift_left(h_condition(2),1); 
            -- read the last condition array after shifting      
            h_condition(0) <= v_h_condition(0);
            h_condition(1) <= v_h_condition(1);
            h_condition(2) <= v_h_condition(2);    
                  
            -- read the new data, controlled by data_rdy
            if data_rdy = '1' then
                -- start the divider
                en <= '1';
                -- max, min,of rgb
                max := max3(unsigned(r), unsigned(g), unsigned(b));
                min := min3(unsigned(r), unsigned(g), unsigned(b));           
                -- divider part of hue 
                if max = unsigned(r) and max /= min then
                    h_divided <= std_logic_vector(mul_60(unsigned(g), unsigned(b)));
                    h_divisor <= std_logic_vector(max - min);
                    h_condition(0) <= v_h_condition(0) + 1;
                elsif max = unsigned(g) and max /= min then
                    h_divided <= std_logic_vector(mul_60(unsigned(b), unsigned(r))); 
                    h_divisor <= std_logic_vector(max - min);
                    h_condition(1) <= v_h_condition(1) + 1;
                elsif max = unsigned(b) and max /= min then
                    h_divided <= std_logic_vector(mul_60(unsigned(r), unsigned(g))); 
                    h_divisor <= std_logic_vector(max - min);
                    h_condition(2) <= v_h_condition(2) + 1;
                elsif max = min then
                    -- default result is 0
                    h_divided <= std_logic_vector(to_signed(0,17)); 
                    h_divisor <= std_logic_vector(to_signed(1,8));
                end if;
                
                -- divider part of saturation (need to convert from 1 to 255)
                if max = 0 then
                    s_divided <= std_logic_vector(to_signed(0,17));
                    s_divisor <= std_logic_vector(to_signed(1,8));
                else
                    s_divided <= std_logic_vector(mul_255(max,min)); 
                    s_divisor <= std_logic_vector(max);
                end if;
                
                -- pipeline reading part of value (must be max)
                v_result(0) <= max;
            end if;
            
            -- pipeline structrue run always, has nothing to do with data_rdy 
            for i in 0 to 9 loop
                v_result(i+1) <= v_result(i);
            end loop;
            
            -- show the result of divider or pipeline
            -- calculation of hue       
            if h_condition(0)(10) = '1' then
                hue := signed(h_result);
                uhue := unsigned(hue);
            elsif h_condition(1)(10) = '1' then
                hue := signed(h_result) + 120;
                uhue := unsigned(hue);
            elsif h_condition(2)(10) = '1' then
                if to_integer(signed(h_result)) + 240 > 255 then
                    uhue := to_unsigned((to_integer(signed(h_result)) + 240),9);
                    -- make sure it is not negative
                    hue := to_signed(240,9);
                else
                    hue := signed(h_result) + 240;
                    uhue := unsigned(hue);
                end if;
            else
                hue := signed(h_result);
                uhue := unsigned(hue);
            end if;
            -- determine if hue is negative
            case(hue < 0) is
                when true =>
                    uhue := unsigned(hue + 360);
                    h <= std_logic_vector(uhue);
                when false =>
                    h <= std_logic_vector(uhue);
            end case;

            -- calculation of saturation
            s <= s_result(7 downto 0);
            
            -- caculation of value
            v <= std_logic_vector(v_result(10));
            
            -- after 9 clock cycles the conversion result is ready
            -- in fact, it is 11 clock cycles
            -- realize result_rdy by pipeline structrue
            -- value of result_rdy changes with data_rdy          
            r_result_rdy(0) <= data_rdy;
            for i in 0 to 9 loop
                r_result_rdy(i+1) <= r_result_rdy(i);
            end loop;
            result_rdy <= r_result_rdy(10);       
          
        end if;
    end process;
    -- STUDENT CODE until HERE

end architecture rtl;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std.unsigned;

entity div16_8_8 is
	generic(
		A_WIDTH			: POSITIVE := 17;
		B_WIDTH			: POSITIVE := 8;
		RESULT_WIDTH	: POSITIVE := 9
	);
	port (
		clk        : in  STD_LOGIC;
		en         : in  STD_LOGIC;
		rstn       : in  STD_LOGIC;
		a          : in  STD_LOGIC_VECTOR( A_WIDTH-1 downto 0);
		b          : in  STD_LOGIC_VECTOR( B_WIDTH-1 downto 0);
		result     : out STD_LOGIC_VECTOR( RESULT_WIDTH-1 downto 0)	
	);
end entity div16_8_8;

architecture rtl of div16_8_8 is

    type unsigned_8_array  is array(natural range <>) of UNSIGNED( 7 downto 0);
	type unsigned_16_array is array(natural range <>) of UNSIGNED(15 downto 0);

	signal r_remainder 		: unsigned_16_array(1 to 9);
	signal r_shifted_b 		: unsigned_16_array(1 to 9);
	signal r_result    		: unsigned_8_array (1 to 9);
	signal r_result_signed 	: SIGNED(8 downto 0);
	signal r_sign      		: STD_LOGIC_VECTOR(1 to 9);
	signal r_en		     	: STD_LOGIC_VECTOR(1 to 9);
	
------------------------------------------------------------------------------------------
  
FUNCTION is_positive (in_zahl : IN SIGNED) RETURN std_logic IS		-- Check the input a 

	BEGIN
		IF in_zahl > 0 THEN -- Check the input a positive or negative
			RETURN '1';
		ELSE
			RETURN '0';
		END IF;
	END;
		
------------------------------------------------------------------------------------------
	
FUNCTION right_shift_0 (in_vector : IN STD_LOGIC_VECTOR) RETURN std_logic_vector IS	
        variable result : std_logic_vector(1 to 9);
	BEGIN
        for i in 1 to 8 loop
            result(i+1) := in_vector(i);
        end loop;
        result(1) := '0'; -- Shift '1' in s_sign vector (positive result)
        RETURN result;
	END;
		
------------------------------------------------------------------------------------------
	
FUNCTION right_shift_1 (in_vector : IN STD_LOGIC_VECTOR) RETURN std_logic_vector IS	
        variable result : std_logic_vector(1 to 9);
	BEGIN
        for i in 1 to 8 loop
            result(i+1) := in_vector(i);
        end loop;
        result(1) := '1'; -- Shift '1' in s_sign vector (negative result)
        RETURN result;
	END;
		
-------------------------------------------------------------------------------------------

FUNCTION right_shift_0_for_b (in_unsigned : IN UNSIGNED) RETURN unsigned IS	
        variable result : unsigned(15 downto 0);
	BEGIN
        for i in 14 downto 0 loop
            result(i) := in_unsigned(i+1);
        end loop;
        result(15) := '0'; -- Shift '0' in r_shifted_b 
        RETURN result;
	END;
		
------------------------------------------------------------------------------------------

begin

	process(clk, rstn, en)
		variable v_result 	: UNSIGNED( 8 downto 1);
        variable a_signed 	: SIGNED(16 downto 0);
        variable a_unsigned : UNSIGNED(15 downto 0);
 
	begin
		if rstn = '0' then
	
	        -- STUDENT CODE HERE
	        -- Initialize the result register
            r_result <= (others=>(others=>'0'));
            r_result_signed <= (others=>'0');
            -- Use lower 8 digits to append zero to divisor
            r_en <= (others=>'0');
            -- STUDENT CODE until HERE
		elsif rising_edge(clk) then
		
    		-- STUDENT CODE HERE
            if en = '1' then
                -- Push the dividend in r_remainder, 
                -- if dividend is positive, no change,
                -- store the sign '0' in r_sign
                if is_positive(signed(a)) = '1' then
                    a_unsigned := unsigned(a(15 downto 0));
                    r_remainder(1) <= a_unsigned;
                    r_sign <= right_shift_0(r_sign);
                -- If divided is negative, changes to absolute for calculation,   
                -- finally perform the result to negative,
                -- store the sign '1' in r_sign
                elsif is_positive(signed(a)) = '0' then
                    a_signed := abs(signed(a));
                    r_remainder(1) <= unsigned(a_signed(15 downto 0));
                    r_sign <= right_shift_1(r_sign);
                end if; 
                -- Push the divisor in r_shifted_b, 
                -- append zeros to divisor to apply shift and subtract algorithm
                r_shifted_b(1) <= unsigned(b & r_en(1 to 8));
                
                -- after one clock the highest digit becomes '1'
                r_en(9) <= '1';
              
                -- Pipeline structure
                -- The highest digit of r_en controls pipeline, not to execute before the transmission of signal
                if r_en(9) = '1' then
                    for i in 2 to RESULT_WIDTH loop
                        -- The first comparison result is not needed (must be 0),
                        -- direct to the second comparsion
                        v_result := r_result(i-1);
                        -- If divided small than divisor,
                        -- then implement with shift registers,
                        -- this digit of the register of result set '0'  
                        if r_remainder(i-1) < r_shifted_b(i-1) then
                            r_remainder(i) <= r_remainder(i-1);
                            r_shifted_b(i) <= right_shift_0_for_b(r_shifted_b(i-1));
                            v_result := shift_left(v_result,1);
                            r_result(i) <= v_result;
                        -- Until divided large than divisor,
                        -- then implement the subtraction,
                        -- this digit of the register of result set '1' 
                        elsif r_remainder(i-1) >= r_shifted_b(i-1) then
                            r_remainder(i) <= r_remainder(i-1) - r_shifted_b(i-1);
                            r_shifted_b(i) <= right_shift_0_for_b(r_shifted_b(i-1));
                            v_result := shift_left(v_result,1) + 1;
                            r_result(i) <= v_result;
                        end if;
                    end loop;

                
                    -- The last implementation only set the bit of r_result,
                    -- but not shift register anymore  
                    -- Divided small than divisor,
                    -- this digit of the register of result set '0'  
                    if r_remainder(RESULT_WIDTH) < r_shifted_b(RESULT_WIDTH) then
                        v_result := r_result(RESULT_WIDTH);
                        v_result := shift_left(v_result,1);
                    -- Divided large than divisor,
                    -- this digit of the register of result set '1' 
                    elsif r_remainder(RESULT_WIDTH) >= r_shifted_b(RESULT_WIDTH) then
                        v_result := r_result(RESULT_WIDTH);
                        v_result := shift_left(v_result,1) + 1;
                    end if;
                end if;
                            
                -- After each clock give a result with sign,
                -- the result is correct after each 9 implementations
                -- If the result should be positive
                if r_sign(9) = '0' then
                    -- the binary representation is its true value
                    r_result_signed <= signed(r_sign(9) & v_result); 
                -- If the result should be negative,
                -- and the temporary result is also 0,
                -- it will appear that conversion beyond the bit limit,
                -- it should be artificial corrected 
                elsif r_sign(9) = '1' and v_result = 0 then
                    r_result_signed <= signed('0' & v_result);
                -- Else the other situation with a normal negative result
                elsif r_sign(9) = '1' and v_result /= 0 then
                    -- Calculate the complement representation 
                    r_result_signed <= signed(r_sign(9) & (not v_result + 1));
                end if;
            end if;
			-- STUDENT CODE until HERE
		end if;
	end process;
	
	result <= STD_LOGIC_VECTOR(r_result_signed);

end architecture rtl;