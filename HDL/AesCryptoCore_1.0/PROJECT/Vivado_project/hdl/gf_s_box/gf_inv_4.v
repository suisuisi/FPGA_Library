/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^2) inverter.
// Module Name: gf_inv_4
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


module gf_inv_4(
        x, 
        y 
    );
    input 			[3 : 0] x;
	output 			[3 : 0] y;
	
	wire [1:0] a, b, c, d, p, q;
	wire sa, sb, sd; // shared factors in multipliers
	
	assign a = x[3:2];
	assign b = x[1:0];
	assign sa = a[1] ^ a[0];
	assign sb = b[1] ^ b[0];
	
	assign c = {
			~(a[1] | b[1]) ^ (~(sa & sb)),
			~(sa | sb) ^ (~(a[0] & b[0])) };
	gf_inv_2 d_inv(c, d);
	assign sd = d[1] ^ d[0];
	gf_mul_2 pmul(d, sd, b, sb, p);
	gf_mul_2 qmult(d, sd, a, sa, q);
	assign y = {p, q};
endmodule
