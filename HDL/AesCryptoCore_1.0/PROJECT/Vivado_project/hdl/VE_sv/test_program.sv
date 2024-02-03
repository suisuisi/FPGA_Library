`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2019 08:38:04 PM
// Design Name: 
// Module Name: test_program
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//`include "ve_AES_Include.sv"
`include "ve_AES_types.sv"
program main_program(mix_column_intf.drv intf_drv, mix_column_intf.rcv intf_rcv);
    AesEnvironment env;
    word8 mult_test;
    initial begin
        env = new("Environment", 1, intf_drv, intf_rcv);
        mult_test = env.aes.mul(0, 2);
		$display("Mul test DEBUG %0b", mult_test);
		mult_test = env.aes.mul(1, 2);
		$display("Mul test DEBUG %0b", mult_test);
        env.run();
    end
endprogram
