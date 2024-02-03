//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^2) multiplier.
// Module Name: gf_mul_scl_2
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: GF(2^2) multiplier and scaler. It performs multiplication Nxy, where x, y, N are from GF(2^2).
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gf_mul_scl_2(x, ab, y, cd, z);
    input 			[1 : 0] x;
	input					ab;
	input 			[1 : 0] y;
	input 					cd;
	output          [1 : 0] z;
	
	wire t, p, q;
	assign t = ~(x[0] & y[0]);
	assign p = (~(ab &cd)) ^ t;
	assign q = (~(x[1] & y[1])) ^ t;
	
	assign z  = {p, q};
endmodule
