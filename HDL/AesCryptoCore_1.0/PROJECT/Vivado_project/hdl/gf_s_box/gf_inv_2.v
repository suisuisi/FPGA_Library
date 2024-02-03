/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^2) inverter.
// Module Name: gf_inv_2
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: calculate the invers of number in gf(2^2). a* a^(-1) = -1
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module gf_inv_2(
        x, 
        y 
    );
    input 			[1 : 0] x;
	output 			[1 : 0] y;
	
	assign y = {x[0], x[1]};
endmodule
