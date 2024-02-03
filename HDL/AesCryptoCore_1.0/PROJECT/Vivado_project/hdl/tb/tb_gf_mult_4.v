//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^4) squarer and scalar.
// Module Name: tb_gf_mult_4.v
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Test Bench for multiplier module in GF(2^4)
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
module tb_gf_mult_4;

	reg 	[3:0] data_in0;
	reg 	[3:0] data_in1;
	wire	[3:0] data_out;
	
	gf_mul_4 DUT (data_in0, data_in1, data_out);
	
	initial begin
		data_in0 = 0;
		data_in1 = 0;
		#10;
		data_in0 = 4;
		data_in1 = 2;
		#10;
		data_in0 = 2;
		data_in1 = 4;
		#10;
		data_in0 = 5;
		data_in1 = 10;
		#10;
		data_in0 = 15;
		data_in1 = 3;
		#10;
		data_in0 = 2;
		data_in1 = 7;
		#10;
		data_in0 = 14;
		data_in1 = 5;
		#10
		$finish;
	end
endmodule