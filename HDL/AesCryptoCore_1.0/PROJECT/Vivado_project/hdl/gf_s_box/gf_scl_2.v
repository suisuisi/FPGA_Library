//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^2) scaler.
// Module Name: gf_scl_2
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: It performs operation N*x, where x, N are from GF(2^2).
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gf_scl_2(
        x, 
        y 
    );
    input 			[1 : 0] x;
	output 			[1 : 0] y;
	
	wire d0, d1;
		
	assign d0 = x[0] ^ x[1];
	assign d1 = x[0];
	
	assign y  = {d1, d0};
endmodule
