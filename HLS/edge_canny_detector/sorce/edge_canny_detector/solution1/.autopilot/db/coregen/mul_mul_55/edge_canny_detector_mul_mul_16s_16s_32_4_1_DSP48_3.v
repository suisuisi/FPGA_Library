
`timescale 1 ns / 1 ps

  module edge_canny_detector_mul_mul_16s_16s_32_4_1_DSP48_3(clk, rst, ce, a, b, p);
input clk;
input rst;
input ce;
input signed [16 - 1 : 0] a;
input signed [16 - 1 : 0] b;
output signed [32 - 1 : 0] p;

reg signed [32 - 1 : 0] p_reg; 

reg signed [16 - 1 : 0] a_reg; 
reg signed [16 - 1 : 0] b_reg; 

reg signed [32 - 1 : 0] p_reg_tmp; 

always @ (posedge clk) begin
    if (ce) begin
        a_reg <= a;
        b_reg <= b;
        p_reg_tmp <= $signed (a_reg) * $signed (b_reg);
        p_reg <= p_reg_tmp;
    end
end

assign p = p_reg;

endmodule
