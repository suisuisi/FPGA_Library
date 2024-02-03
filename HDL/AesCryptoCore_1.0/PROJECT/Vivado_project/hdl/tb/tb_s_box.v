//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: Test Bench for the S-Box
// Module Name: tb_sbox
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Test Bench for inverse module in GF(2^8)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "../aes_include.v"
`timescale 1ns/1ps

module tb_sbox;
	
	reg  [7:0] data_in;
	wire [7:0] data_out_e;
	wire [7:0] data_out_d;
	
	
	bSbox sbox_e(data_in, `ENCRIPT, data_out_e);
	bSbox sbox_e(data_out_e, `DECRIPT, data_out_d);
	
	
	initial begin
		data_in = 8'h01;
		
		#10;
		data_in = 8'h10;
		
		#10;
		data_in = 8'h02;
		
		#10;
		$finish;
	
	end	
endmodule