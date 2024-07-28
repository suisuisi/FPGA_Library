`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:34:26 08/24/2010 
// Design Name: 
// Module Name:    para_to_seq 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seq_to_para(clk, rst, rdy, data_in, data_out, vld);
   parameter RSA_LEN = 512;
   parameter BUS_W   = 32;
   
   input                clk, rst, rdy; //Clock, reset, ready
   input [BUS_W-1  :0] 	data_in;
   output [RSA_LEN-1:0] data_out;
   output 				vld;
   
   reg [RSA_LEN-1:0] 	data_out;
   reg [4:0] 			cnt;
   reg 					vld;
   
   always @(posedge clk) begin
      if (rst == 1'b1) begin
		 data_out <= 0;
		 vld <= 0;
	  end else begin
		 if (cnt) begin
			if (cnt == 5'h10) cnt <= 0;
			else cnt <= cnt + 1;
			data_out <= {data_in, data_out[RSA_LEN-1:BUS_W]};
		 end else if (rdy) cnt <= 1;
		 if (cnt == 5'h10) vld <= 1;
		 else vld <= 0;
	  end // else: !if(rst == 1'b1)
   end // always @ (posedge clk)
   
endmodule
