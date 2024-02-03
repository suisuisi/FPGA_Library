//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^2) multiplier.
// Module Name: tb_gf_mult_2.v
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Test Bench for multiplier module in GF(2^2)
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
module tb_gf_mult_2;

	reg 	[1:0] data_in0;
	reg 	[1:0] data_in1;
	wire	[1:0] data_out;
	
	gf_mul_scl_2 DUT (data_in0, data_in1, data_out);
	
	initial begin
		data_in0 = 0;
		data_in1 = 0;
		#10;
		data_in0 = 1;
		data_in1 = 2;
		#10;
		data_in0 = 2;
		data_in1 = 2;
		#10;
		data_in0 = 1;
		data_in1 = 3;
		#10;
		data_in0 = 3;
		data_in1 = 2;
		#10;
		data_in0 = 1;
		data_in1 = 1;
		#10;
		data_in0 = 3;
		data_in1 = 3;
		#10
		$finish;
	end
endmodule