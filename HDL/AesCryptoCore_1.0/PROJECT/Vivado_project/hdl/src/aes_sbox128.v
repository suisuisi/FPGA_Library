// Module Name: aes_sub_byte
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Subbyte is a briklayer permutation consisting of an S-box applied of the state.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`ifndef u8_MSB
 `define u8_MSB(x)  8*(x+1) - 1
`endif

`ifndef u8_LSB
    `define u8_LSB(x)  8*x1
`endif


module aes_s_box128( A, encrypt, Q );
	input [`DATA_SIZE -1 : 0] A;
	input encrypt;
	input [`DATA_SIZE -1 : 0] Q;
	
	bSbox s0  (A[`u8_MSB(0) :  `u8_LSB(0)], encrypt, Q[`u8_MSB(0) :  `u8_LSB(0)]);
	bSbox s1  (A[`u8_MSB(1) :  `u8_LSB(1)], encrypt, Q[`u8_MSB(1) :  `u8_LSB(1)]);
	bSbox s2  (A[`u8_MSB(2) :  `u8_LSB(2)], encrypt, Q[`u8_MSB(2) :  `u8_LSB(2)]);
	bSbox s3  (A[`u8_MSB(3) :  `u8_LSB(3)], encrypt, Q[`u8_MSB(3) :  `u8_LSB(3)]);
	                           
	bSbox s4  (A[`u8_MSB(4) :  `u8_LSB(4)], encrypt, Q[`u8_MSB(4) :  `u8_LSB(4)]);
	bSbox s5  (A[`u8_MSB(5) :  `u8_LSB(5)], encrypt, Q[`u8_MSB(5) :  `u8_LSB(5)]);
	bSbox s6  (A[`u8_MSB(6) :  `u8_LSB(6)], encrypt, Q[`u8_MSB(6) :  `u8_LSB(6)]);
	bSbox s7  (A[`u8_MSB(7) :  `u8_LSB(7)], encrypt, Q[`u8_MSB(7) :  `u8_LSB(7)]);
	                                                                    
	bSbox s8  (A[`u8_MSB(8) :  `u8_LSB(8)], encrypt, Q[`u8_MSB(8) :  `u8_LSB(8)]);
	bSbox s9  (A[`u8_MSB(9) :  `u8_LSB(9)], encrypt, Q[`u8_MSB(9) :  `u8_LSB(9)]);
	bSbox s10 (A[`u8_MSB(10): `u8_LSB(10)], encrypt, Q[`u8_MSB(10): `u8_LSB(10)]);
	bSbox s11 (A[`u8_MSB(11): `u8_LSB(11)], encrypt, Q[`u8_MSB(11): `u8_LSB(11)]);
	          
	bSbox s12 (A[`u8_MSB(12): `u8_LSB(12)], encrypt, Q[`u8_MSB(12): `u8_LSB(12)]);
	bSbox s13 (A[`u8_MSB(13): `u8_LSB(13)], encrypt, Q[`u8_MSB(13): `u8_LSB(13)]);
	bSbox s14 (A[`u8_MSB(14): `u8_LSB(14)], encrypt, Q[`u8_MSB(14): `u8_LSB(14)]);
	bSbox s15 (A[`u8_MSB(15): `u8_LSB(15)], encrypt, Q[`u8_MSB(15): `u8_LSB(15)]);

endmodule