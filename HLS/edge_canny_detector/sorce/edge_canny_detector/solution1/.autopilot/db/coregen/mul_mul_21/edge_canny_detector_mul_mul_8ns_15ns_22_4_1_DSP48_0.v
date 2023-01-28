
`timescale 1 ns / 1 ps

  module edge_canny_detector_mul_mul_8ns_15ns_22_4_1_DSP48_0(clk, rst, ce, a, b, p);
input clk;
input rst;
input ce;
input [8 - 1 : 0] a;
input [15 - 1 : 0] b;
output [22 - 1 : 0] p;

reg [22 - 1 : 0] p_reg; 

reg [8 - 1 : 0] a_reg; 
reg [15 - 1 : 0] b_reg; 

reg [22 - 1 : 0] p_reg_tmp; 

always @ (posedge clk) begin
    if (ce) begin
        a_reg <= a;
        b_reg <= b;
        p_reg_tmp <= $unsigned (a_reg) * $unsigned (b_reg);
        p_reg <= p_reg_tmp;
    end
end

assign p = p_reg;

endmodule
