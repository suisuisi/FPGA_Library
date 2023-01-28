// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0(
    reset,
    clk,
    address0,
    ce0,
    q0,
    address1,
    ce1,
    we1,
    d1);

parameter DataWidth = 32'd8;
parameter AddressRange = 32'd1280;
parameter AddressWidth = 32'd11;
input reset;
input clk;
input[AddressWidth - 1:0] address0;
input ce0;
output[DataWidth - 1:0] q0;
input[AddressWidth - 1:0] address1;
input ce1;
input we1;
input[DataWidth - 1:0] d1;



edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram_U(
    .clk( clk ),
    .addr0( address0 ),
    .ce0( ce0 ),
    .q0( q0 ),
    .addr1( address1 ),
    .ce1( ce1 ),
    .we1( we1 ),
    .d1( d1 ));

endmodule
