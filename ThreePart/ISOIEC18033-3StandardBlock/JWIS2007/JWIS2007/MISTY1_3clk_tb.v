/*-------------------------------------------------------------------------
 Testbench for
 One round / Three clock version of MISTY1 Macro
 
 File name   : MISTY1_3clk_tb.v
 Version     : Version 1.0
 Created     : JUN/26/2007
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
  reg  data_rdy, key_rdy, en_de;
  reg [63:0] data_in;
  reg [127:0] key_in;

  wire [63:0]  data_out;
  wire 	       data_valid, key_valid, busy;	       
  
   top top(/*AUTOINST*/
	   // Outputs
	   .data_out			(data_out[63:0]),
	   .data_valid                  (data_valid),
	   .key_valid                   (key_valid),
	   .busy                        (busy),		       
	   // Inputs
	   .clk				(clk),
	   .nreset			(nreset),
	   .data_rdy			(data_rdy),
	   .key_rdy			(key_rdy),
	   .en_de			(en_de),
	   .data_in			(data_in[63:0]),
	   .key_in			(key_in[127:0]));

   always #5 clk <= ~clk;

   initial begin
      clk <= 1'b0;
      nreset <= 1'b1;
      data_rdy <= 1'b0;
      key_rdy  <= 1'b0;
      en_de    <= 1'b0;
      data_in <= 64'h0123_4567_89ab_cdef;
      key_in  <= 128'h0011_2233_4455_6677_8899_aabb_ccdd_eeff;
      #10  nreset <= 1'b0;
      #10  nreset <= 1'b1;
           key_rdy <= 1'b1;
      #10  key_rdy <= 1'b0;
      #100 data_rdy <= 1'b1;
      #10  data_rdy <= 1'b0;
      #400 key_rdy <= 1'b1;
      #10  key_rdy <= 1'b0;
      #100 en_de <= 1'b1;
           data_in <= 64'h8b1d_a5f5_6ab3_d07c;
           data_rdy <= 1'b1;
      #10  data_rdy <= 1'b0;
      #400 $finish;
   end

   always @(posedge clk)

     $strobe("state=%x, round=%x, data_out=%x, data_in=%x, key_rdy=%x, data_rdy=%x",
	     top.state, top.round, data_out, data_in, key_rdy, data_rdy);

endmodule // top_tb
