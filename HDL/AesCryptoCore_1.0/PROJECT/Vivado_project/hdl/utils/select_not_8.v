//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^4) squarer and scalar.
// Module Name: select_not_8
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Test Bench for inverse module in GF(2^8)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module select_not_8 ( A, B, s, Q );
	input [7:0] A;
	input [7:0] B;
	input s;
	output [7:0] Q;
	mux2_1 m7(A[7],B[7],s,Q[7]);
	mux2_1 m6(A[6],B[6],s,Q[6]);
	mux2_1 m5(A[5],B[5],s,Q[5]);
	mux2_1 m4(A[4],B[4],s,Q[4]);
	mux2_1 m3(A[3],B[3],s,Q[3]);
	mux2_1 m2(A[2],B[2],s,Q[2]);
	mux2_1 m1(A[1],B[1],s,Q[1]);
	mux2_1 m0(A[0],B[0],s,Q[0]);
endmodule