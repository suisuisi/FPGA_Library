//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: Includes File
// File Name: aes_include.v
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: 
//			Header file
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MixColumnMul (a_in1, a_in2, a_in3, a_in4, dec, data_out);
	input [7:0] a_in1;
	input [7:0] a_in2;
	input [7:0] a_in3;
	input [7:0] a_in4;
	
	input dec; // dec = 1 for decryption
	output [7:0] data_out;
	
	wire [7:0] mul_en_1 = a_in1 ^ 8'h02;
	wire [7:0] mul_en_2 = a_in2 ^ 8'h03;
	wire [7:0] mul_en_3 = a_in3 ^ 8'h01;
	wire [7:0] mul_en_4 = a_in4 ^ 8'h01;
	
	wire [7:0] mul_dec_1 = a_in1 ^ 8'h0C;
	wire [7:0] mul_dec_2 = a_in2 ^ 8'h08;
	wire [7:0] mul_dec_3 = a_in3 ^ 8'h0C;
	wire [7:0] mul_dec_4 = a_in4 ^ 8'h08;
	
	assign data_out =  (mul_en_1 ^ (mul_dec_1 & dec)) ^
					   (mul_en_2 ^ (mul_dec_2 & dec)) ^
					   (mul_en_3 ^ (mul_dec_3 & dec)) ^
					   (mul_en_4 ^ (mul_dec_4 & dec)); 
	
endmodule