//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^4) squarer and scalar.
// Module Name: gf_sq_scl_4
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


module gf_sq_scl_4(
        x, 
        y 
    );
    input 			[3 : 0] x;
	output 			[3 : 0] y;
	
	wire [1:0] a, b, ab2, b2, b2N2;
	assign a = x[3:2];
	assign b = x[1:0];
	
	gf_inv_2 absq(a ^ b, ab2);
	gf_inv_2 bsq(b, b2);
	
	gf_sq_scl_2 bmulN2(b2, b2N2);

	assign y = {ab2, b2N2};
endmodule
