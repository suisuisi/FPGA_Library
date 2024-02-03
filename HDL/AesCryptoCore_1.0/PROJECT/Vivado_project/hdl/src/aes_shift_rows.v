// Module Name: aes_shift_rows
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
`ifndef u8
    `define u8    [7:0] 
`endif

`ifndef u8_MSB
 `define u8_MSB(x)  8*(x+1) - 1
`endif

`ifndef u8_LSB
    `define u8_LSB(x)  8*x1
`endif

`ifndef ENCRIPT 
    `define ENCRIPT 1'b1
`endif

module aes_shift_rows(data_in, encrypt, data_out);

	input [`DATA_SIZE -1 : 0] data_in;
	input encrypt;
	output [`DATA_SIZE -1 : 0] data_out;
	
	wire `u8 Mix_input0;
	wire `u8 Mix_input1;
	wire `u8 Mix_input2;
	wire `u8 Mix_input3;
	
	wire `u8 Mix_input4;
	wire `u8 Mix_input5;
	wire `u8 Mix_input6;
	wire `u8 Mix_input7;
	
	wire `u8 Mix_input8;
	wire `u8 Mix_input9;
	wire `u8 Mix_input10;
	wire `u8 Mix_input11;
	
	wire `u8 Mix_input12;
	wire `u8 Mix_input13;
	wire `u8 Mix_input14;
	wire `u8 Mix_input15;

	assign Mix_input0  =  data_in [`u8_MSB(0) : `u8_LSB(0)];
	assign Mix_input1  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(5)  :  `u8_LSB(5)] : data_in [`u8_MSB(13): `u8_LSB(13)];
	assign Mix_input2  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(10) : `u8_LSB(10)] : data_in [`u8_MSB(10): `u8_LSB(10)];
	assign Mix_input3  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(15) : `u8_LSB(15)] : data_in [`u8_MSB(7) :  `u8_LSB(7)];
	                                                                 
	assign Mix_input4  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(4)  :  `u8_LSB(4)] : data_in [`u8_MSB(4) :  `u8_LSB(4)];                                         
	assign Mix_input5  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(9)  :  `u8_LSB(9)] : data_in [`u8_MSB(1) :  `u8_LSB(1)];
	assign Mix_input6  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(14) : `u8_LSB(14)] : data_in [`u8_MSB(14): `u8_LSB(14)];
	assign Mix_input7  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(3)  :  `u8_LSB(3)] : data_in [`u8_MSB(11): `u8_LSB(11)];
	                                                                 
	assign Mix_input8  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(8)  :  `u8_LSB(8)] : data_in [`u8_MSB(8) :  `u8_LSB(8)];                              
	assign Mix_input9  = (encrypt == `ENCRIPT)? data_in [`u8_MSB(13) : `u8_LSB(13)] : data_in [`u8_MSB(5) :  `u8_LSB(5)];
	assign Mix_input10 = (encrypt == `ENCRIPT)? data_in [`u8_MSB (2) :  `u8_LSB(2)] : data_in [`u8_MSB(2) :  `u8_LSB(2)];
	assign Mix_input11 = (encrypt == `ENCRIPT)? data_in [`u8_MSB (7) :  `u8_LSB(7)] : data_in [`u8_MSB(15): `u8_LSB(15)];
	                                                                 
	assign Mix_input12 = (encrypt == `ENCRIPT)? data_in [`u8_MSB(12) : `u8_LSB(12)] : data_in [`u8_MSB(12): `u8_LSB(12)];
	assign Mix_input13 = (encrypt == `ENCRIPT)? data_in [`u8_MSB(1)  :  `u8_LSB(1)] : data_in [`u8_MSB(9) :  `u8_LSB(9)];                                          
	assign Mix_input14 = (encrypt == `ENCRIPT)? data_in [`u8_MSB(6)  :  `u8_LSB(6)] : data_in [`u8_MSB(6) :  `u8_LSB(6)];
	assign Mix_input15 = (encrypt == `ENCRIPT)? data_in [`u8_MSB(11) : `u8_LSB(11)] : data_in [`u8_MSB(3) :  `u8_LSB(3)];
	
	
endmodule 