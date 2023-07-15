library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants_package.all;
use work.vpf_records.all;
use work.ports_package.all;
use work.vfp_pkg.all;
entity rgb2hsv is
port (
    clk                : in  std_logic;
    reset              : in  std_logic;
    iRgb               : in channel;
    oHsl               : out channel);
end rgb2hsv;
architecture behavioral of rgb2hsv is


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
    
    function min3(a : unsigned; b : unsigned; c : unsigned) return unsigned is
    variable result : unsigned(7 downto 0) := "11111111";
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
    
    function mul_60(a : unsigned; b : unsigned) return signed is
        variable result : signed(16 downto 0) := (others=> '0');
    begin
        result := to_signed(to_integer(a) - to_integer(b), 17);
        result := shift_left(result,6) - shift_left(result,2);
        return result;
    end function mul_60;
    
    function mul_255(a : unsigned; b : unsigned) return signed is
        variable result : signed(16 downto 0) := (others=> '0');
    begin
        result := to_signed(to_integer(a) - to_integer(b), 17);
        result := shift_left(result,8) - result;
        return result;
    end function mul_255;
    
    type u8_array_t is array(natural range <>) of unsigned(7 downto 0);
    type u11_array_t is array(natural range <>) of signed(10 downto 0);
    
    signal h_condition               : u11_array_t(2 downto 0) := (others=>(others=>'0'));
    signal rgbSyncValid              : std_logic_vector(23 downto 0) := x"000000";
    signal rgbSyncEol                : std_logic_vector(23 downto 0) := x"000000";
    signal rgbSyncSof                : std_logic_vector(23 downto 0) := x"000000";
    signal rgbSyncEof                : std_logic_vector(23 downto 0) := x"000000";
    signal saturate                  : std_logic_vector(7 downto 0);
    signal luminosity                : std_logic_vector(7 downto 0);
    signal h_result                  : std_logic_vector(8 downto 0);
    signal h_divided                 : std_logic_vector(16 downto 0);
    signal h_divisor                 : std_logic_vector(7 downto 0);
    signal hue_val                   : std_logic_vector(8 downto 0);
    signal v_result                  : u8_array_t(10 downto 0) := (others=>(others=>'0'));
    signal s_result                  : std_logic_vector(8 downto 0);
    signal s_divided                 : std_logic_vector(16 downto 0);
    signal s_divisor                 : std_logic_vector(7 downto 0);
    
begin

process (clk) begin
    if rising_edge(clk) then
        rgbSyncValid(0)  <= iRgb.valid;
        for i in 0 to 22 loop
          rgbSyncValid(i+1)  <= rgbSyncValid(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEol(0)  <= iRgb.eol;
        for i in 0 to 22 loop
          rgbSyncEol(i+1)  <= rgbSyncEol(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncSof(0)  <= iRgb.sof;
        for i in 0 to 22 loop
          rgbSyncSof(i+1)  <= rgbSyncSof(i);
        end loop;
    end if;
end process;
process (clk) begin
    if rising_edge(clk) then
        rgbSyncEof(0)  <= iRgb.eof;
        for i in 0 to 22 loop
          rgbSyncEof(i+1)  <= rgbSyncEof(i);
        end loop;
    end if;
end process;



div_hue_instance : div16_8_8
generic map (
    a_width          => 17,
    b_width          => 8,
    result_width     => 9)
port map(
    clk              => clk,
    en               => '1',
    rstn             => reset,
    a                => h_divided,
    b                => h_divisor,
    result           => h_result);
    
div_sat_instance : div16_8_8
generic map (
    a_width          => 17,
    b_width          => 8,
    result_width     => 9)
port map(clk         => clk,
    en               => '1',
    rstn             => reset,
    a                => s_divided,
    b                => s_divisor,
    result           => s_result); 

process (clk)
        variable hue           : signed(8 downto 0); 
        variable uhue          : unsigned(8 downto 0); 
        variable max, min      : unsigned(7 downto 0);
        variable v_h_condition : u11_array_t(2 downto 0) := (others=>(others=>'0'));
begin
    if rising_edge(clk) then
        v_h_condition(0) := shift_left(h_condition(0),1); 
        v_h_condition(1) := shift_left(h_condition(1),1); 
        v_h_condition(2) := shift_left(h_condition(2),1);     
        h_condition(0)   <= v_h_condition(0);
        h_condition(1)   <= v_h_condition(1);
        h_condition(2)   <= v_h_condition(2);

        max := max3(unsigned(iRgb.red(9 downto 2)), unsigned(iRgb.green(9 downto 2)), unsigned(iRgb.blue(9 downto 2)));
        min := min3(unsigned(iRgb.red(9 downto 2)), unsigned(iRgb.green(9 downto 2)), unsigned(iRgb.blue(9 downto 2)));  
        
        ----------------------------------------------------------
        -- HUE
        ----------------------------------------------------------
        if max = unsigned(iRgb.red(9 downto 2)) and max /= min then
            h_condition(0)   <= v_h_condition(0) + 1; 
            h_divided        <= std_logic_vector(mul_60(unsigned(iRgb.green(9 downto 2)), unsigned(iRgb.blue(9 downto 2))));
            h_divisor        <= std_logic_vector(max - min);
        elsif max = unsigned(iRgb.green(9 downto 2)) and max /= min then
            h_condition(1)   <= v_h_condition(1) + 1;
            h_divided        <= std_logic_vector(mul_60(unsigned(iRgb.blue(9 downto 2)), unsigned(iRgb.red(9 downto 2)))); 
            h_divisor        <= std_logic_vector(max - min);
        elsif max = unsigned(iRgb.blue(9 downto 2)) and max /= min then
            h_condition(2)   <= v_h_condition(2) + 1;
            h_divided        <= std_logic_vector(mul_60(unsigned(iRgb.red(9 downto 2)), unsigned(iRgb.green(9 downto 2)))); 
            h_divisor        <= std_logic_vector(max - min);
        elsif(max = min) then
            h_divided         <= std_logic_vector(to_signed(0,17)); 
            h_divisor         <= std_logic_vector(to_signed(1,8));
        end if;
        
        if h_condition(0)(10) = '1' then
            hue         := signed(h_result);
            uhue        := unsigned(hue);
        elsif h_condition(1)(10) = '1' then
            hue         := signed(h_result) + 120;
            uhue        := unsigned(hue);
        elsif h_condition(2)(10) = '1' then
            if to_integer(signed(h_result)) + 240 > 255 then
                uhue    := to_unsigned((to_integer(signed(h_result)) + 240),9);
                hue     := to_signed(240,9);
            else
                hue     := signed(h_result) + 240;
                uhue    := unsigned(hue);
            end if;
        else
            hue         := signed(h_result);
            uhue        := unsigned(hue);
        end if;

        case(hue < 0) is
            when true =>
                uhue := unsigned(hue + 360);
                hue_val    <= std_logic_vector(uhue);
            when false =>
                hue_val    <= std_logic_vector(uhue);
        end case;
        
        ----------------------------------------------------------
        -- SATURATE
        ----------------------------------------------------------
        if max = 0 then
            s_divided <= std_logic_vector(to_signed(0,17));
            s_divisor <= std_logic_vector(to_signed(1,8));
        else
            s_divided <= std_logic_vector(mul_255(max,min)); 
            s_divisor <= std_logic_vector(max);
        end if;
        
        saturate <= s_result(7 downto 0);
        
        ----------------------------------------------------------
        -- LUMINOSITY
        ----------------------------------------------------------
        v_result(0) <= max;
        for i in 0 to 9 loop
            v_result(i+1) <= v_result(i);
        end loop;
        luminosity <= std_logic_vector(v_result(10));
        
        
    end if;
end process;

process (clk) begin
    if rising_edge(clk) then
       oHsl.red   <= hue_val & '0';
       oHsl.green <= saturate & "00";
       oHsl.blue  <= luminosity & "00";
    end if;
end process;

    oHsl.valid <= rgbSyncValid(12);
    oHsl.eol   <= rgbSyncEol(12);
    oHsl.sof   <= rgbSyncSof(12);
    oHsl.eof   <= rgbSyncEof(12);
    
end behavioral;