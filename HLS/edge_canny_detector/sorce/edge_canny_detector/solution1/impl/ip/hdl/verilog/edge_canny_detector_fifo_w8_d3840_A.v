// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================

`timescale 1ns/1ps

module edge_canny_detector_fifo_w8_d3840_A_ram
#(parameter
    DATA_WIDTH  = 8,
    ADDR_WIDTH  = 12,
    DEPTH       = 3840
)
(
    input  wire                  clk,
    input  wire                  we,
    input  wire [ADDR_WIDTH-1:0] waddr,
    input  wire [DATA_WIDTH-1:0] din,
    input  wire [ADDR_WIDTH-1:0] raddr,
    output wire [DATA_WIDTH-1:0] dout
);

(* rw_addr_collision = "yes" *)
reg  [DATA_WIDTH-1:0] mem[0:DEPTH-1];
reg  [ADDR_WIDTH-1:0] raddr_reg;

//write to ram
always @(posedge clk) begin
    if (we)
        mem[waddr] <= din;
end

//buffer the raddr
always @(posedge clk) begin
    raddr_reg <= raddr;
end

//read from ram
assign dout = mem[raddr_reg];

endmodule

module edge_canny_detector_fifo_w8_d3840_A
#(parameter
    DATA_WIDTH  = 8,
    ADDR_WIDTH  = 12,
    DEPTH       = 3840
)
(
    // system signal
    input  wire                  clk,
    input  wire                  reset,

    // write
    output wire                  if_full_n,
    input  wire                  if_write_ce,
    input  wire                  if_write,
    input  wire [DATA_WIDTH-1:0] if_din,

    // read
    output wire                  if_empty_n,
    input  wire                  if_read_ce,
    input  wire                  if_read,
    output wire [DATA_WIDTH-1:0] if_dout
);
//------------------------Parameter----------------------

//------------------------Local signal-------------------
reg  [ADDR_WIDTH-1:0] waddr = 1'b0;
reg  [ADDR_WIDTH-1:0] raddr = 1'b0;
wire [ADDR_WIDTH-1:0] wnext;
wire [ADDR_WIDTH-1:0] rnext;
wire                  push;
wire                  pop;
reg  [ADDR_WIDTH:0]   mOutPtr = 1'b0;
reg                   full_n = 1'b1;
reg                   empty_n = 1'b0;


//------------------------Instantiation------------------
edge_canny_detector_fifo_w8_d3840_A_ram
#(
 .DATA_WIDTH(DATA_WIDTH),
 .ADDR_WIDTH(ADDR_WIDTH),
 .DEPTH(DEPTH))
U_edge_canny_detector_fifo_w8_d3840_A_ram(
 .clk(clk),
 .we(push),
 .waddr(waddr),
 .din(if_din),
 .raddr(rnext),
 .dout(if_dout)
);

//------------------------Task and function--------------

//------------------------Body---------------------------
assign if_full_n  = full_n;
assign if_empty_n = empty_n;
assign push       = full_n & if_write_ce & if_write;
assign pop        = empty_n & if_read_ce & if_read;
assign wnext      = !push                ? waddr :
                    (waddr == DEPTH - 1) ? 1'b0  :
                    waddr + 1'b1;
assign rnext      = !pop                 ? raddr :
                    (raddr == DEPTH - 1) ? 1'b0  :
                    raddr + 1'b1;

// waddr
always @(posedge clk) begin
    if (reset == 1'b1)
        waddr <= 1'b0;
    else
        waddr <= wnext;
end

// raddr
always @(posedge clk) begin
    if (reset == 1'b1)
        raddr <= 1'b0;
    else
        raddr <= rnext;
end

// mOutPtr
always @(posedge clk) begin
    if (reset == 1'b1)
        mOutPtr <= 1'b0;
    else if (push & ~pop)
        mOutPtr <= mOutPtr + 1'b1;
    else if (~push & pop)
        mOutPtr <= mOutPtr - 1'b1;
end

// full_n
always @(posedge clk) begin
    if (reset == 1'b1)
        full_n <= 1'b1;
    else if (push & ~pop)
        full_n <= (mOutPtr != DEPTH - 1);
    else if (~push & pop)
        full_n <= 1'b1;
end

// empty_n
always @(posedge clk) begin
    if (reset == 1'b1)
        empty_n <= 1'b0;
    else if (push & ~pop)
        empty_n <= 1'b1;
    else if (~push & pop)
        empty_n <= (mOutPtr != 1'b1);
end

endmodule

