/*-------------------------------------------------------------------------
 Testbench for Camellia Macro (ASIC version)
                                   
 File name   : Camellia_tb.v
 Version     : Version 1.0
 Created     : SEP/29/2006
 Last update : SEP/04/2007
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


module Camellia_tb;
   reg CLK, RSTn;
   reg EncDec;
   reg Drdy, Krdy;
   reg [127:0] Din, Kin;

   wire [127:0] Dout;
   wire 	BSY, Dvld, Kvld;

   Camellia Camellia( // Outputs
		      .Dout	(Dout[127:0]),
		      .BSY      (BSY),
		      .Dvld     (Dvld),
		      .Kvld     (Kvld),
		      // Inputs
		      .CLK	(CLK),
		      .EN       (1'b1),
		      .RSTn	(RSTn),
		      .EncDec	(EncDec),
		      .Drdy	(Drdy),
		      .Krdy	(Krdy),
		      .Din	(Din[127:0]),
		      .Kin	(Kin[127:0]));

  // Test-vectors from the specification. 
  parameter KEY = 128'h0123_4567_89ab_cdef_fedc_ba98_7654_3210;
  parameter PT  = 128'h0123_4567_89ab_cdef_fedc_ba98_7654_3210;
  parameter CT  = 128'h6767_3138_5496_6973_0857_0656_48ea_be43;

  parameter PERIOD = 10;
  parameter Enc = 1'b0;
  parameter Dec = 1'b1;

  initial begin
    CLK        <= 1'b0;
    RSTn     <= 1'b0;
    Drdy <= 1'b0;
    Krdy  <= 1'b0;
    EncDec <= 1'b0;

    #(PERIOD) RSTn <= 1'b1;
    set_key(KEY);
    set_data(PT, Enc);
    set_data(CT, Dec);
    set_key(KEY);
    set_data(PT, Enc);
   end

  always #(PERIOD/2) CLK <= ~CLK;

  task set_key;
    input [127:0] set_key_in;
    begin
      Kin <= set_key_in;
      Krdy <= 1'b1;
      #(PERIOD)     Krdy <= 1'b0;
      #(PERIOD*6);
    end
  endtask // set_key

  task set_data;
    input [127:0] set_data_in;
    input EncDec_in;
    begin
      EncDec <= EncDec_in;
      Din <= set_data_in;
      Drdy <= 1'b1;
      #(PERIOD) Drdy <= 1'b0;
      #(PERIOD * 23) $display("data=%h, EncDec=%h, output=%h",
			      set_data_in, EncDec_in, Dout);
    end
  endtask
   
endmodule // Camellia_tb
