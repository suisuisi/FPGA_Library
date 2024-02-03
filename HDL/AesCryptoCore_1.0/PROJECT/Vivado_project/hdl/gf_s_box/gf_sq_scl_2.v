//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^2) squarer and scalar.
// Module Name: gf_sq_scl_2
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: It performs operation N*(x^2), where x, N are from GF(2^2). x is an input variable, and N is a constant;
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gf_sq_scl_2(
        x, 
        y 
    );
    input 			[1 : 0] x;
	output 			[1 : 0] y;
	
	wire d0, d1;
	
	assign d1 = x[0] ^ x[1];
	assign d0 = x[1];
	assign y  = {d1, d0};
endmodule
