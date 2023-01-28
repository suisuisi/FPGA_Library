// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
`timescale 1 ns / 1 ps
module edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_buf_V_0_ram (addr0, ce0, d0, we0, addr1, ce1, q1,  clk);

parameter DWIDTH = 16;
parameter AWIDTH = 11;
parameter MEM_SIZE = 1280;

input[AWIDTH-1:0] addr0;
input ce0;
input[DWIDTH-1:0] d0;
input we0;
input[AWIDTH-1:0] addr1;
input ce1;
output reg[DWIDTH-1:0] q1;
input clk;

reg [DWIDTH-1:0] ram[0:MEM_SIZE-1];




always @(posedge clk)  
begin 
    if (ce0) begin
        if (we0) 
            ram[addr0] <= d0; 
    end
end


always @(posedge clk)  
begin 
    if (ce1) begin
        q1 <= ram[addr1];
    end
end


endmodule

`timescale 1 ns / 1 ps
module edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_buf_V_0(
    reset,
    clk,
    address0,
    ce0,
    we0,
    d0,
    address1,
    ce1,
    q1);

parameter DataWidth = 32'd16;
parameter AddressRange = 32'd1280;
parameter AddressWidth = 32'd11;
input reset;
input clk;
input[AddressWidth - 1:0] address0;
input ce0;
input we0;
input[DataWidth - 1:0] d0;
input[AddressWidth - 1:0] address1;
input ce1;
output[DataWidth - 1:0] q1;



edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_buf_V_0_ram edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_buf_V_0_ram_U(
    .clk( clk ),
    .addr0( address0 ),
    .ce0( ce0 ),
    .we0( we0 ),
    .d0( d0 ),
    .addr1( address1 ),
    .ce1( ce1 ),
    .q1( q1 ));

endmodule

