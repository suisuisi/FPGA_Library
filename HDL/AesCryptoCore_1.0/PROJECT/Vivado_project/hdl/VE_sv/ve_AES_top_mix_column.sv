/////////////////////////////////////////////////////////////////////////////////
// Faculty: AC Isi
// Student: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: Class with all the matrix computed
// Module Name: ve_AES_top.sv
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: top file for the verification environment
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`define 	U_8 8
`timescale 1ns/1ps
module top;

	MixColumns MixColumns_DUT (
							.b0			(mix_column_intf0.b0), //input
							.b1			(mix_column_intf0.b1), //input
							.b2			(mix_column_intf0.b2), //input
							.b3			(mix_column_intf0.b3), //input
							.a0			(mix_column_intf0.a0), //output
							.a1			(mix_column_intf0.a1), //output
							.a2			(mix_column_intf0.a2), //output
							.a3			(mix_column_intf0.a3), //output
							.c0			(mix_column_intf0.c0), //output
							.c1			(mix_column_intf0.c1), //output
							.c2			(mix_column_intf0.c2), //output.c0			(c0), //output
							.c3			(mix_column_intf0.c3) //output
							);
							
/* 	mix_column_intf mix_column_intf0 (
							.b0			(b0), //input
							.b1			(b1), //input
							.b2			(b2), //input
							.b3			(b3), //input
							.a0			(a0), //output
							.a1			(a1), //output
							.a2			(a2), //output
							.a3			(a3), //output
							.c0			(c0), //output
							.c1			(c1), //output
							.c2			(c2), //output.c0			(c0), //output
							.c3			(c3) //output
							); */
							
	mix_column_intf mix_column_intf0();						
	
	main_program test(mix_column_intf0, mix_column_intf0);
endmodule