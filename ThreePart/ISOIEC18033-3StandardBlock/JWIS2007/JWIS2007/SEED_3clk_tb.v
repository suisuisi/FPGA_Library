/*-------------------------------------------------------------------------
 Testbench for 
 One round / Three clock version of SEED Macro
 
 File name   : SEED_3clk_tb.v
 Version     : Version 1.0
 Created     : MAR/04/2007
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
   reg [127:0] data_in;
   reg [127:0] key_in;
   reg 	 activate; // start encryption/decryption
   reg 	 en_de;    // select encryption or decryption

   wire [127:0] data_out;
   wire 	busy;
   wire 	data_valid;

   top top(/*AUTOINST*/
	   // Outputs
	   .data_out			(data_out[127:0]),
	   .busy			(busy),
	   .data_valid			(data_valid),
	   // Inputs
	   .clk				(clk),
	   .nreset			(nreset),
	   .data_in			(data_in[127:0]),
	   .key_in			(key_in[127:0]),
	   .activate			(activate),
	   .en_de			(en_de));

   
   initial begin
      clk <= 1'b0;
      nreset <= 1'b1;
      activate <= 1'b0;
      en_de <= `ENCRYPTION;

      // RFC B.4 encryption/decryption
      // Key        : 28 DB C3 BC 49 FF D8 7D CF A5 09 B1 1D 42 2B E7
      // Plaintext  : B4 1E 6B E2 EB A8 4A 14 8E 2E ED 84 59 3C 5E C7
      // Ciphertext : 9B 9B 7B FC D1 81 3C B9 5D 0B 36 18 F4 0F 51 22

      key_in  <= 128'h28db_c3bc_49ff_d87d_cfa5_09b1_1d42_2be7;
      data_in <= 128'hb41e_6be2_eba8_4a14_8e2e_ed84_593c_5ec7;

      #100 nreset <= 1'b0;
      #100 nreset <= 1'b1;
      #100 activate <= 1'b1;
      #100 activate <= 1'b0;
      #1200 $finish;
   end

   always #10 clk <= ~clk;

   always @(posedge clk)


     $display("state=%x, round_counter=%x, subkey=%x, data_out=%x, next_data=%x",
	      top.state, top.round_counter, top.subkey, top.data_out, top.encrypt.next_data);
endmodule // top_tb
