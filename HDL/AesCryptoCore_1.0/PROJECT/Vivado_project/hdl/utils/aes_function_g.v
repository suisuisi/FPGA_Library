// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: G Function of Round.
// Module Name: function_g
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Function g
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module function_g(data_in, encrypt, round_no, data_out);

	input 		`u32  data_in;
	input			  encrypt;
	input 		`u4	 round_no;
	output 		`u32  data_out;

	wire `u8 v0_in, v1_in, v2_in, v_3in;
	wire `u8 v0, v1, v2, v3;
	wire `u8 v0_out, v1_out, v2_out, v3_out;
	
	wire `u8 rc_i;
	
	assign v0 = data_in[31:24];
	assign v1 = data_in[23:16];
	assign v2 = data_in[15: 8];
	assign v3 = data_in[ 7: 0];
	
	
	bSbox s0(A.(v0), .encrypt(encrypt), .Q(v0_out)); 
	bSbox s1(A.(v1), .encrypt(encrypt), .Q(v1_out));
	bSbox s2(A.(v2), .encrypt(encrypt), .Q(v2_out));
	bSbox s3(A.(v3), .encrypt(encrypt), .Q(v3_out));

	round_constants rc_inst (round_no, rc_i);
	
	assign data_out[31:24] = v1_out ^ rc_i;
	assign data_out[23:16] = v2_out;
	assign data_out[15: 8] = v3_out;
	assign data_out[ 7: 0] = v0_out;

endmodule