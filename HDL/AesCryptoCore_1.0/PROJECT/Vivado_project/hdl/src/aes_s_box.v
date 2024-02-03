//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: Sbox.
// Module Name: bSbox
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: find either Sbox or its inverse in GF(2^8), by Canright Algorithm
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module bSbox ( A, encrypt, Q );
	input [7:0] A;
	input encrypt; /* 1 for Sbox, 0 for inverse Sbox */
	output [7:0] Q;
	wire [7:0] B, C, D, X, Y, Z;
	wire R1, R2, R3, R4, R5, R6, R7, R8, R9;
	wire T1, T2, T3, T4, T5, T6, T7, T8, T9, T10;
	/* change basis from GF(2^8) to GF(2^8)/GF(2^4)/GF(2^2) */
	/* combine with bit inverse matrix multiply of Sbox */
	assign R1 = A[7] ^ A[5] ;
	assign R2 = A[7] ~^ A[4] ;
	assign R3 = A[6] ^ A[0] ;
	assign R4 = A[5] ~^ R3 ;
	assign R5 = A[4] ^ R4 ;
	assign R6 = A[3] ^ A[0] ;
	assign R7 = A[2] ^ R1 ;
	assign R8 = A[1] ^ R3 ;
	assign R9 = A[3] ^ R8 ;
	assign B[7] = R7 ~^ R8 ;
	assign B[6] = R5 ;
	assign B[5] = A[1] ^ R4 ;
	assign B[4] = R1 ~^ R3 ;
	assign B[3] = A[1] ^ R2 ^ R6 ;
	assign B[2] = ~ A[0] ;
	assign B[1] = R4 ;
	assign B[0] = A[2] ~^ R9 ;
	assign Y[7] = R2 ;
	assign Y[6] = A[4] ^ R8 ;
	assign Y[5] = A[6] ^ A[4] ;
	assign Y[4] = R9 ;
	assign Y[3] = A[6] ~^ R2 ;
	assign Y[2] = R7 ;
	assign Y[1] = A[4] ^ R6 ;
	assign Y[0] = A[1] ^ R5 ;
	select_not_8 sel_in( B, Y, encrypt, Z );
	gf_inv_8 inv( Z, C );
	/* change basis back from GF(2^8)/GF(2^4)/GF(2^2) to GF(2^8) */
	assign T1 = C[7] ^ C[3] ;
	assign T2 = C[6] ^ C[4] ;
	assign T3 = C[6] ^ C[0] ;
	assign T4 = C[5] ~^ C[3] ;
	assign T5 = C[5] ~^ T1 ;
	assign T6 = C[5] ~^ C[1] ;
	assign T7 = C[4] ~^ T6 ;
	assign T8 = C[2] ^ T4 ;
	assign T9 = C[1] ^ T2 ;
	assign T10 = T3 ^ T5 ;
	assign D[7] = T4 ;
	assign D[6] = T1 ;
	assign D[5] = T3 ;
	assign D[4] = T5 ;
	assign D[3] = T2 ^ T5 ;
	assign D[2] = T3 ^ T8 ;
	assign D[1] = T7 ;
	assign D[0] = T9 ;
	assign X[7] = C[4] ~^ C[1] ;
	assign X[6] = C[1] ^ T10 ;
	assign X[5] = C[2] ^ T10 ;
	assign X[4] = C[6] ~^ C[1] ;
	assign X[3] = T8 ^ T9 ;
	assign X[2] = C[7] ~^ T7 ;
	assign X[1] = T6 ;
	assign X[0] = ~ C[2] ;
	select_not_8 sel_out( D, X, encrypt, Q );
endmodule
	
	