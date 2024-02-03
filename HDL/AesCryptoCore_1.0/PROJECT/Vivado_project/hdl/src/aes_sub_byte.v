// Module Name: aes_sub_byte
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Subbyte is a briklayer permutation consisting of an S-box applied of the state.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module aes_sub_byte(
		s_in,
		s_out,
		);
	input 	[7 : 0] s_in;
	output  [7 : 0] s_out;
	
	wire 	[7 : 0] x_inv_out;
	
	wire    [7 : 0] mx_inv_in;
	wire    [7 : 0] mx_inv_out;
	
	wire 	[7 : 0] inv_in;
	
	
	assign mx_inv_in = s_in ^ 8'h63;
	
	assign x_inv_out[7] = s_in[7] ^ s_in[6] ^ s_in[5] ^ s_in[2] ^ s_in[1] ^ s_in[0]; 
	assign x_inv_out[6] = s_in[6] ^ s_in[5] ^ s_in[4] ^ s_in[0]; 
	assign x_inv_out[5] = s_in[6] ^ s_in[5] ^ s_in[1] ^ s_in[0]; 
	assign x_inv_out[4] = s_in[7] ^ s_in[6] ^ s_in[5] ^ s_in[0]; 
	assign x_inv_out[3] = s_in[7] ^ s_in[4] ^ s_in[3] ^ s_in[1] ^ s_in[0]; 
	assign x_inv_out[2] = s_in[0]; 
	assign x_inv_out[1] = s_in[6] ^ s_in[5] ^ s_in[0]; 
	assign x_inv_out[0] = s_in[6] ^ s_in[3] ^ s_in[2] ^ s_in[1] ^ s_in[0];
	
	
	
	
endmodule