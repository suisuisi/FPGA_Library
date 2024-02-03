//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^2) multiplier.
// Module Name: gf_mul_4
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: GF(2^4) multiplier.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gf_mul_4(A, a, Al, Ah, aa, B, b, Bl, Bh, bb, Q);
    input  [3:0]  A;
	input  [1:0]  a;
	input  		 Al;
	input  		 Ah;
	input  		 aa;
	input  [3:0]  B;
	input  [1:0]  b;
	input  		 Bl;
	input  		 Bh;
	input  		 bb;
	output [3:0] Q;
	
	wire   [1:0] ph, pl, ps, p;
	wire 	t;
	
	gf_mul_2 himul (A[3:2], Ah, B[3:2], Bh, ph);
	gf_mul_2 lomul (A[1:0], Al, B[1:0], Bl, pl);
	gf_mul_scl_2 summul (a, aa, b, bb, p);
	assign Q = { (ph^p), (pl^p) };
endmodule
