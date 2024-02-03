//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^4) squarer and scalar.
// Module Name: gf_sq_scl_4
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: It performs operation v*(x^2), where x is an input variable, and v is a constant
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "../aes_types.v"

`timescale 1ns/1ps
module tb_gf_scl_4;

	reg 	[3:0] data_in;
	wire	[3:0] data_out;
	
	gf_sq_scl_4 DUT (data_in, data_out);
	
	initial begin
	
		for( data_in = 0; data_in < 16; data_in = data_in + 1) begin
			# 10;
		end	
		$finish;
	end
endmodule