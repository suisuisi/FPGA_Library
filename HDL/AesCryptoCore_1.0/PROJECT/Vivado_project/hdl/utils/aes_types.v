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

`define ENCRIPT 1'b1
`define DECRIPT 1'b0

`define POLYNOMIAL_IRR 8'b0001_1011

`define KEY_SIZE      128
`define DATA_SIZE	  128

`define R_ACTIV     1'b1
`define R_INACTIV   1'b0

`define NO_OF_ROUNDS  10

`define u32   [31:0]
`define u8    [7:0] 
`define u4    [3:0]

`define u8_MSB(x)  8*(x+1) - 1
     
`define u8_LSB(x)  8*x
