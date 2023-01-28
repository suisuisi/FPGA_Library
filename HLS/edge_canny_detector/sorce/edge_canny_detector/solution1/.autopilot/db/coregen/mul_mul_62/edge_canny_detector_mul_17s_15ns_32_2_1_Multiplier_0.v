// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================

`timescale 1 ns / 1 ps

module edge_canny_detector_mul_17s_15ns_32_2_1_Multiplier_0(clk, ce, a, b, p);
input clk;
input ce;
input signed [17 - 1 : 0] a;
input [15 - 1 : 0] b;
output[32 - 1 : 0] p;
reg signed [32 - 1 : 0] p;
wire signed [32 - 1 : 0] tmp_product;

assign tmp_product = $signed(a) * $signed({1'b0, b});
always @ (posedge clk) begin
    if (ce) begin
        p <= tmp_product;
    end
end
endmodule
