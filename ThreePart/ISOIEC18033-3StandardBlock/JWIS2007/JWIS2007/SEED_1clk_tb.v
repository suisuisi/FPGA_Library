/*-------------------------------------------------------------------------
 Testbench for 
 One round / One clock version of SEED Macro
 
 File name   : SEED_1clk_tb.v
 Version     : Version 1.0
 Created     : MAR/08/2007
 Last update : AUG/03/2007
 Desgined by : Takeshi Sugawara
 
 
 Copyright (C) 2007 AIST and Tohoku Univ.
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by AIST and Tohoku University ("us").
 
 Permission is hereby granted to copy, reproduce, redistribute or
 otherwise use this code as long as: there is no monetary profit gained
 specifically from the use or reproduction of this code, it is not sold,
 rented, traded or otherwise marketed, and this copyright notice is
 included prominently in any copy made.
 
 We shall not be liable for any damages, including without limitation
 direct, indirect, incidental, special or consequential damages arising
 from the use of this code.
 
 When you publish any results arising from the use of this code, we will
 appreciate it if you can cite our webpage
 (http://www.aoki.ecei.tohoku.ac.jp/crypto/).
 -------------------------------------------------------------------------*/ 


module top_tb;

  reg clk, nreset;
  reg data_rdy, key_rdy, EncDec;
  reg [127:0] data_in;
  wire [127:0] data_out;
  wire 	data_valid, key_valid, busy;

  top top(/*AUTOINST*/
	  // Outputs
	  .data_out			(data_out[127:0]),
	  .data_valid			(data_valid),
	  .key_valid			(key_valid),
	  .busy				(busy),
	  // Inputs
	  .clk				(clk),
	  .nreset			(nreset),
	  .data_rdy			(data_rdy),
	  .key_rdy			(key_rdy),
	  .EncDec			(EncDec),
	  .data_in			(data_in[127:0]));

  parameter PERIOD = 10;

  always #(PERIOD/2) clk <= ~clk;

  initial begin
    clk <= 1'b0;
    nreset <= 1'b1;
//    data_in <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
    data_in <= 128'h0011_2233_4455_6677_8899_aabb_ccdd_eeff;    
    data_rdy <= 1'b0;
    key_rdy <= 1'b0;    
    EncDec <= 1'b0;
    #(PERIOD)   nreset <= 1'b0;
    #(PERIOD)   nreset <= 1'b1;
    #(PERIOD)   key_rdy <= 1'b1;
    #(PERIOD)   key_rdy <= 1'b0;
    #(PERIOD)    
      data_rdy <= 1'b1;
    #(PERIOD)   data_rdy <= 1'b0;
    #(PERIOD*15) data_rdy <= 1'b1;
    #(PERIOD)   data_rdy <= 1'b0;
    #(PERIOD*30)
      key_rdy <= 1'b1;
      EncDec <= 1'b1;
    #(PERIOD)   key_rdy <= 1'b0;
    #(PERIOD*2) 
      //data_in <= 128'h284a_3dfa_4683_581a_c9c6_296f_9dbf_dc1d;
      data_in <= 128'hc9c6_296f_9dbf_dc1d_284a_3dfa_4683_581a;
      data_rdy <= 1'b1;    
    #(PERIOD)   data_rdy <= 1'b0;

  end
endmodule // top_tb
