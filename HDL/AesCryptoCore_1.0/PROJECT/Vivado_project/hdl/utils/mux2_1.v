//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^4) squarer and scalar.
// Module Name: mux2_1
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Multiplexor
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module mux2_1 ( A, B, s, Q );
	input A;
	input B;
	input s;
	output Q;
	assign Q = ~ ( s ? A : B ); /* mock-up for FPGA implementation */
endmodule