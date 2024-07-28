/*-------------------------------------------------------------------------
 Testbench for Camellia Macro
                                   
 File name   : Camellia_tb.v
 Version     : Version 1.0
 Created     : SEP/29/2006
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
   reg en_de;
   reg data_rdy, key_rdy;
   reg [127:0] data_in, key_in;

   wire [127:0] data_out;
   wire 	busy, data_valid;

   top top(/*AUTOARG*/
	   // Outputs
	   .data_out			(data_out[127:0]),
	   .busy                        (busy),
	   .data_valid                  (data_valid),
	   // Inputs
	   .clk				(clk),
	   .nreset			(nreset),
	   .en_de			(en_de),
	   .data_rdy			(data_rdy),
	   .key_rdy			(key_rdy),
	   .data_in			(data_in[127:0]),
	   .key_in			(key_in[127:0]));


  initial begin
      clk        <= 1'b0;
     #5      
      nreset     <= 1'b0;
      data_rdy <= 1'b0;
      key_rdy  <= 1'b0;

    // They are test vectors described in specification.
    // The ciphertext is expected to be    
    // 128'h6767_3138_5496_6973_0857_0656_48ea_be43;
      data_in = 128'h0123_4567_89ab_cdef_fedc_ba98_7654_3210;
      key_in  = 128'h0123_4567_89ab_cdef_fedc_ba98_7654_3210;

      en_de <= 1'b0;
     #100 nreset <= 1'b1;

     #100 key_rdy <= 1'b1;
     #10  key_rdy <= 1'b0;
     #100 data_rdy <= 1'b1;
     #10 data_rdy <= 1'b0;
     #500 $finish;
   end

  always #5 clk <= ~clk;


  always @(posedge clk)
    $strobe("round=%d, state=%x, data_out=%x, busy=%b, data_valid=%b",
	    top.round, top.state, top.data_out, top.busy, top.data_valid);
   
endmodule // top_tb

     
