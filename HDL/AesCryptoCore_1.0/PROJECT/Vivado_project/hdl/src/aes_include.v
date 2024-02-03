//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: Includes File
// File Name: aes_include.v
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: 
//			Header file
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "utils/aes_types.v"

`include "gf_s_box/gf_inv_2.v"
`include "gf_s_box/gf_scl_2.v"
`include "gf_s_box/gf_sq_scl_2.v"
`include "gf_s_box/gf_mul_2.v"
`include "gf_s_box/gf_mul_scl_2.v"


`include "gf_s_box/gf_scl_4.v"
`include "gf_s_box/gf_mul_4.v"
`include "gf_s_box/gf_inv_4.v"

`include "gf_s_box/gf_inv_8.v"

`include "utils/mux2_1.v"
`include "utils/select_not_8.v"

`include "aes_s_box.v"