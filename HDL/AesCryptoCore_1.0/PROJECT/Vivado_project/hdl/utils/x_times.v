//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: Includes File
// File Name: x_time.v
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: 
//			Multiplication with 02 in GF(2^8). Used in MixColumn part
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "aes_types.v"
module x_times(data_in, data_out);

	input  [7:0] data_in;
	output [7:0] data_out;

	wire [7:0] mul_02; 		// multiplication with 02 (x - like polinomial) is implemented as a shift with one position
	//wire [7:0] reduction; 	// modular reduction with x^8 + x^4 + x^3 + x + 1 = 0001_1011
	
	assign mul_02 = (data_in << 1);
	
//	assign reduction = mul_02 ^ `POLYNOMIAL_IRR;

	assign data_out = mul_02;
	
endmodule