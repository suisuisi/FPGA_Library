-- ==============================================================
-- Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- ==============================================================
Library IEEE;
use IEEE.std_logic_1164.all;
Library work;
use work.all;

entity edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0 is
    generic (
        DataWidth : INTEGER := 8;
        AddressRange : INTEGER := 1280;
        AddressWidth : INTEGER := 11);
    port (
        reset : IN STD_LOGIC;
        clk : IN STD_LOGIC;
        address0 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce0 : IN STD_LOGIC;
        q0 : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
        address1 : IN STD_LOGIC_VECTOR(AddressWidth - 1 DOWNTO 0);
        ce1 : IN STD_LOGIC;
        we1 : IN STD_LOGIC;
        d1 : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
end entity;

architecture arch of edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0 is
    component edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram is
        port (
            clk : IN STD_LOGIC;
            addr0 : IN STD_LOGIC_VECTOR;
            ce0 : IN STD_LOGIC;
            q0 : OUT STD_LOGIC_VECTOR;
            addr1 : IN STD_LOGIC_VECTOR;
            ce1 : IN STD_LOGIC;
            we1 : IN STD_LOGIC;
            d1 : IN STD_LOGIC_VECTOR);
    end component;



begin
    edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram_U :  component edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram
    port map (
        clk => clk,
        addr0 => address0,
        ce0 => ce0,
        q0 => q0,
        addr1 => address1,
        ce1 => ce1,
        we1 => we1,
        d1 => d1);

end architecture;

