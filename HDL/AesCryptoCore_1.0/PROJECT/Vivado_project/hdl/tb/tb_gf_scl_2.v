//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^4) squarer and scalar.
// Module Name: tb_gf_scl_2
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
module tb_gf_scl_2;

	reg 	[1:0] data_in;
	wire	[1:0] data_out;
	
	gf_scl_2 DUT (data_in, data_out);
	
	initial begin
	
		data_in = 0;
		
		#10;
		data_in = 1;
		
		#10;
		data_in = 2;
		
		#10;
		data_in = 3;

		#10;
		$finish;
	end
endmodule