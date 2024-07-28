/*-------------------------------------------------------------------------
 Testbench for 
 One round / One clock version of SEED Macro (ASIC version)
 
 File name   : SEED_1clk_tb.v
 Version     : Version 1.0
 Created     : MAR/08/2007
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


module SEED_tb;

  reg CLK, RSTn;
  reg Drdy, Krdy, EncDec;
  reg [127:0] Din, Kin;
  wire [127:0] Dout;
  wire 	Dvld, Kvld, BSY;

  SEED SEED(// Outputs
	    .Dout (Dout[127:0]),
	    .Dvld (Dvld),
	    .Kvld (Kvld),
	    .BSY  (BSY),
	    // Inputs
	    .CLK  (CLK),
	    .EN   (1'b1),
	    .RSTn (RSTn),
	    .Drdy (Drdy),
	    .Krdy (Krdy),
	    .EncDec (EncDec),
	    .Din (Din[127:0]),
	    .Kin (Kin[127:0])
	    );

  // Test vectors B.1.
  parameter KEY1 = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
  parameter PT1  = 128'h0001_0203_0405_0607_0809_0a0b_0c0d_0e0f;
  parameter CT1  = 128'h5eba_c6e0_054e_1668_19af_f1cc_6d34_6cdb;

  // Test vectors B.2.
  parameter KEY2 = 128'h0001_0203_0405_0607_0809_0a0b_0c0d_0e0f;
  parameter PT2  = 128'h0000_0000_0000_0000_0000_0000_0000_0000;
  parameter CT2  = 128'hc11f_22f2_0140_5050_8448_3597_e437_0f43;

  // Test vectors B.3.
  parameter KEY3 = 128'h4706_4808_51e6_1be8_5d74_bfb3_fd95_6185;
  parameter PT3  = 128'h83a2_f8a2_8864_1fb9_a4e9_a5cc_2f13_1c7d;
  parameter CT3  = 128'hee54_d13e_bcae_706d_226b_c314_2cd4_0d4a;

  // Test vectors B.4.
  parameter KEY4 = 128'h28db_c3bc_49ff_d87d_cfa5_09b1_1d42_2be7;
  parameter PT4  = 128'hb41e_6be2_eba8_4a14_8e2e_ed84_593c_5ec7;
  parameter CT4  = 128'h9b9b_7bfc_d181_3cb9_5d0b_3618_f40f_5122;

  parameter PERIOD = 10;

  parameter Enc = 1'b0;
  parameter Dec = 1'b1;

  always #(PERIOD/2) CLK <= ~CLK;

  initial begin
    //$monitor("%x", Dout);
    CLK <= 1'b0;
    RSTn <= 1'b1;
//    Din <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
//    Din <= 128'h0011_2233_4455_6677_8899_aabb_ccdd_eeff;
//    Kin <= 128'h0011_2233_4455_6677_8899_aabb_ccdd_eeff;    
    Drdy <= 1'b0;
    Krdy <= 1'b0;    
    EncDec <= 1'b0;
    RSTn <= 1'b0;
    #(PERIOD)  RSTn <= 1'b1;
    set_key(KEY1, Enc);
    set_data(PT1, Enc);
    set_data(PT1, Enc);
    #(PERIOD)
    set_key(KEY1, Dec);
    set_data(CT1, Dec);
    #(PERIOD)
    set_key(KEY2, Enc);
    set_data(PT2, Enc);
    #(PERIOD)
    set_key(KEY2, Dec);
    set_data(CT2, Dec);
    #(PERIOD)
    set_key(KEY3, Enc);
    set_data(PT3, Enc);
    #(PERIOD)
    set_key(KEY3, Dec);
    set_data(CT3, Dec);
    #(PERIOD)
    set_key(KEY4, Enc);
    set_data(PT4, Enc);
    #(PERIOD)
    set_key(KEY4, Dec);
    set_data(CT4, Dec);
  end

  task set_key;
    input [127:0] set_key_in;
    input EncDec_in;
    begin
      EncDec <= EncDec_in;
      Kin <= set_key_in;
      Krdy <= 1'b1;
      #(PERIOD)     Krdy <= 1'b0;
      #(PERIOD) $display("Key set to %x", set_key_in);
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
      #(PERIOD * 15) $display("data=%h, EncDec=%h, output=%h",
			      set_data_in, EncDec_in, Dout);
    end
  endtask

endmodule // SEED_tb
