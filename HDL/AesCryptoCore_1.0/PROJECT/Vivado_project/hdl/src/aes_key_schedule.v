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
`ifndef KEY_SIZE
    `define KEY_SIZE      128
`endif

`ifndef DATA_SIZE
    `define DATA_SIZE	  128
`endif
`ifndef u32
`define u32   [31:0]
`endif

`ifndef u4
    `define u4    [3:0]
`endif

module key_schedule (key_in, encrypt, round_index,  key_out);

	input  [`KEY_SIZE-1: 0] key_in;
	input  encrypt;
	input  `u4 round_index;
	output [`KEY_SIZE-1: 0] key_out;
	
	wire `u32 W0, W1, W2, W3;
	wire `u32 W0_new, W1_new, W2_new, W3_new;
	wire `u32 g_out;
	
	
	function_g g_inst(W3, encrypt, round_index, g_out);
		
	assign W0  = key_in [31 : 0];
	assign W1  = key_in [63 :32];
	assign W2  = key_in [95 :64];
	assign W3  = key_in [127:96];
	
	assign W0_new = W0 ^ g_out;
	assign W1_new = W1 ^ W0_new;
	assign W2_new = W2 ^ W1_new;
	assign W3_new = W3 ^ W2_new;
	
	assign key_out [31 : 0] = W0_new;
	assign key_out [63 :32] = W1_new;
	assign key_out [95 :64] = W2_new;
	assign key_out [127:96] = W3_new;
	
	
endmodule