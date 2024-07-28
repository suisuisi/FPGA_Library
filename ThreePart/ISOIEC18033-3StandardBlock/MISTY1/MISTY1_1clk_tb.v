/* ---------------------------------------------------
 Testbench for
 one round / one clock version of MISTY1 Macro (ASIC version)
 
 File name   : MISTY1_1clk_tb.v
 Version     : Version 1.0
 Created     : MAR/04/2007
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

module MISTY1_tb;

  reg CLK, RSTn;
  reg Drdy, Krdy, EncDec;
  reg [ 63:0] Din;
  reg [127:0] Kin;
  wire [63:0] Dout;
  wire 	Dvld, Kvld, BSY;

  MISTY1 MISTY1(// Outputs
		.Dout    (Dout[63:0]),
		.Dvld    (Dvld),
		.Kvld	   (Kvld),
		.BSY     (BSY),
		// Inputs
		.CLK     (CLK),
		.EN      (1'b1),
		.RSTn    (RSTn),
		.Drdy    (Drdy),
		.Krdy    (Krdy),
		.EncDec  (EncDec),
		.Din     (Din[ 63:0]),
		.Kin     (Kin[127:0]));

  parameter KEY = 128'h0011_2233_4455_6677_8899_aabb_ccdd_eeff;
  parameter PT = 64'h0123_4567_89ab_cdef;
  parameter CT = 64'h8b1d_a5f5_6ab3_d07c;
  parameter PERIOD = 10;

  parameter Enc = 1'b0;
  parameter Dec = 1'b1;

  always #(PERIOD/2) CLK <= ~CLK;
  
  initial begin
    CLK <= 1'b0;
    RSTn <= 1'b1;
    Drdy <= 1'b0;
    Krdy <= 1'b0;    
    EncDec <= 1'b0;
    RSTn <= 1'b0;
    #(PERIOD)   RSTn <= 1'b1;
    set_key(KEY);
    set_data(PT, Enc);
    set_data(PT, Enc);
    #(PERIOD)
    set_data(CT, Dec);
    set_data(CT, Dec);
  end

  task set_key;
    input [127:0] set_key_in;
    begin
      Kin <= set_key_in;
      Krdy <= 1'b1;
      #(PERIOD)     Krdy <= 1'b0;
      #(PERIOD*8) $display("Key set to %x", set_key_in);
    end
  endtask // set_key

  task set_data;
    input [63:0] set_data_in;
    input EncDec_in;
    begin
      EncDec <= EncDec_in;
      Din <= set_data_in;
      Drdy <= 1'b1;
      #(PERIOD) Drdy <= 1'b0;
      #(PERIOD * 8) $display("data=%h, EncDec=%h, output=%h",
			      set_data_in, EncDec_in, Dout);
    end
  endtask


endmodule // MISTY1_tb
