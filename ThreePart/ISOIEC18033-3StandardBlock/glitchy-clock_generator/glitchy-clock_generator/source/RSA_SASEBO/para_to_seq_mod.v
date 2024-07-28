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
module para_to_seq_mod(clk, rst, rdy, crt, mod_in, predat_in, data_out);
   parameter RSA_LEN = 512;
    parameter BUS_W   = 32;
   
    input                clk, rst, rdy, crt; //Clock, reset, ready
    input  [RSA_LEN-1:0] mod_in;
    input  [RSA_LEN / 2 -1:0] predat_in;
    output [BUS_W-1  :0] data_out;
   reg [RSA_LEN-1:0] 	 data;
   

   reg [4:0] 		 cnt;

    always @(posedge clk) begin
        if (rst == 1'b1) begin
		   cnt <= 0;
		   data <= 0;
		end else begin
	   if (cnt) begin
		  if (crt && cnt == 5'h1a)       cnt <= 0;
		  else if (!crt && cnt == 5'h0f) cnt <= 0;
		  else                           cnt <= cnt + 1;
		  if (cnt != 5'h10) data <= {32'h00000000, data[RSA_LEN-1:BUS_W]};
		  else data <= {256'h0000000000000000, predat_in};
	   end else if (rdy) begin
		  cnt <= 1;
		  data <= mod_in;
	   end
	end // else: !if(rst == 1'b1)
    end // always @ (posedge clk)
   assign data_out = data[BUS_W-1:0];
   
endmodule
