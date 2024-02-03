//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: Includes File
// File Name: x_time_square.v
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

module x_time_square(data_in, data_out);

	input  [7:0] data_in;
	output [7:0] data_out;

	assign data_out[7] = data_in[5];
	assign data_out[6] = data_in[4];
	assign data_out[5] = data_in[7] ^ data_in[3];
	assign data_out[4] = data_in[2] ^ data_in[6] ^ data_in[7];
	
	assign data_out[3] = data_in[6] ^ data_in[1];
	assign data_out[2] = data_in[7] ^ data_in[0];
	assign data_out[1] = data_in[6] ^ data_in[7];
	assign data_out[0] = data_in[0];
endmodule