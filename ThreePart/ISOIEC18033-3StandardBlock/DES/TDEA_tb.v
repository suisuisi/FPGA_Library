/*-------------------------------------------------------------------------
 Testbench for TDEA Macro (ASIC version)
 
 File name   : TDEA_tb.v
 Version     : Version 1.0
 Created     : JUN/12/2007
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


module TDEA_TB;
  reg  [1:64] Din;  // Data input
  reg  [1:64] Kin;  // Key input
  wire [1:64] Dout; // Data output
  reg  Drdy;        // Data input ready
  reg  Krdy;        // Key input ready
  reg  EncDec;         // 1 encryption, 0 decryption
  reg  RSTn;        // Reset (Low active)
  reg  EN;          // DES circuit enable
  reg  CLK;         // System clock
  wire BSY;         // Busy signal
  wire Dvld;        // Data output valid
  wire Kvld;

  // Encryption or Decryption
  parameter Enc = 1'b0;
  parameter Dec = 1'b1;

  parameter PERIOD = 10;

  // Test vectors for single-key mode.
  // NIST special publication 800-17
  parameter [1:64] PTa = 64'h00_00_00_00_00_00_00_00;
  parameter [1:64] CTa = 64'h82_DC_BA_FB_DE_AB_66_02;
  parameter [1:64] Ka  = 64'h10_31_6e_02_8c_8f_3b_4a;

  // Test vectors for triple-key mode.
  // NIST special publication 800-67
  parameter [1:64] Kb1 = 64'h0123_4567_89ab_cdef;
  parameter [1:64] Kb2 = 64'h2345_6789_abcd_ef01;
  parameter [1:64] Kb3 = 64'h4567_89ab_cdef_0123;

  parameter [1:64] PTb = 64'h5468_6520_7175_6663;
  parameter [1:64] CTb = 64'ha826_fd8c_e53b_855f;

  parameter [1:64] PTc = 64'h6b20_6272_6f77_6e20;
  parameter [1:64] CTc = 64'hcce2_1c81_1225_6fe6;

  parameter [1:64] PTd = 64'h666f_7820_6a75_6d70;
  parameter [1:64] CTd = 64'h68d5_c05d_d9b6_b900;
  
  TDEA TDEA(// Outputs
	    .Dout	(Dout[1:64]),
	    .BSY	(BSY),
	    .Dvld	(Dvld),
	    // Inputs
	    .Din	(Din[1:64]),
	    .Kin        (Kin),
	    .Drdy	(Drdy),
	    .Krdy	(Krdy),
	    .EncDec	(EncDec),
	    .RSTn	(RSTn),
	    .EN		(EN),
	    .CLK	(CLK),
	    .Kvld       (Kvld));

  always #(PERIOD/2)
    CLK <= ~CLK;

  initial begin
    //$monitor($time, , "Dout=%h", Dout);
    CLK  <= 1'b0;
    RSTn <= 1'b0;
    EN <= 1'b1;
    Drdy <= 1'b0;
    #(PERIOD) RSTn <= 1'b1;

    set_key(Ka, Ka, Ka, Enc);
    set_data(PTa, Enc);
    set_key(Ka, Ka, Ka, Dec);
    set_data(CTa, Dec);

    set_key(Kb1, Kb2, Kb3, Enc);
    set_data(PTb, Enc);
    set_data(PTc, Enc);
    set_data(PTd, Enc);

    set_key(Kb1, Kb2, Kb3, Dec);
    set_data(CTb, Dec);
    set_data(CTc, Dec);
    set_data(CTd, Dec);
  end

  task set_key;
    input [1:64] A, B, C;
    input 	 EncDec_in;
    begin
      EncDec <= EncDec_in;
      Kin <= A;
      Krdy <= 1'b1;
      #(PERIOD) Kin <= B;
      #(PERIOD) Kin <= C;
      #(PERIOD) Krdy <= 1'b0;
    end
  endtask // set_key
  
  task set_data;
    input[1:64] data;
    input 	 EncDec_in;
    begin
      EncDec <= EncDec_in;
      Din <= data;
      Drdy <= 1'b1;
      #(PERIOD) Drdy <= 1'b0;
      #(PERIOD * 48) 
	$display("EncDec=%x, data=%x, output=%x", 
		 EncDec_in, data, Dout);
    end
  endtask // set_data

endmodule // TDEA_TB
