//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^4) squarer and scalar.
// Module Name: tb_gf_inv_8.v
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

`include "../aes_types.v"

`timescale 1ns/1ps
module tb_gf_inv_8;

	reg 	[7:0] data_in0;
	wire	[7:0] data_out;
	
	gf_inv_8 DUT (data_in0, data_out);
	
	initial begin
		data_in0 = 0;
		#10;
		data_in0 = 8'h10;
		#10;
		data_in0 = 8'h06;
		#10;
		data_in0 = 8'h01;
		#10;
		data_in0 = 8'h74;		
		#10;
		data_in0 = 8'h10;
		#10;
		data_in0 = 8'h47;
		#10;
		$finish;
	end
endmodule