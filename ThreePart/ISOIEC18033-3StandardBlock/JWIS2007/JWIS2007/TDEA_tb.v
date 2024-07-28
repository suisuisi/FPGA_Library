/*-------------------------------------------------------------------------
 Testbench for TDEA Macro
 
 File name   : TDEA_tb.v
 Version     : Version 1.0
 Created     : JUN/12/2007
 Last update : AUG/06/2007
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


module TDES_TB;
  reg  [1:64] Din;  // Data input
  reg  [1:64] Key1; // Key input 1
  reg  [1:64] Key2; // Key input 2
  reg  [1:64] Key3; // Key input 3
  wire [1:64] Dout; // Data output
  reg  Drdy;        // Data input ready
  reg  Krdy;        // Key input ready
  reg  ENC;         // 1 encryption, 0 decryption
  reg  RSTn;        // Reset (Low active)
  reg  EN;          // DES circuit enable
  reg  CLK;         // System clock
  wire BSY;         // Busy signal
  wire Dvld;        // Data output valid

  parameter PERIOD = 10;
  
  TDES TDES(/*AUTOINST*/
	    // Outputs
	    .Dout			(Dout[1:64]),
	    .BSY			(BSY),
	    .Dvld			(Dvld),
	    // Inputs
	    .Din			(Din[1:64]),
	    .Key1			(Key1[1:64]),
	    .Key2			(Key2[1:64]),
	    .Key3			(Key3[1:64]),
	    .Drdy			(Drdy),
	    .Krdy			(Krdy),
	    .ENC			(ENC),
	    .RSTn			(RSTn),
	    .EN				(EN),
	    .CLK			(CLK));

  always #(PERIOD/2)
    CLK <= ~CLK;

  initial begin
    CLK  <= 1'b1;
    RSTn <= 1'b0;
//    Din  <= 64'h00_00_00_00_00_00_00_00;
    Din  <= 64'h82_DC_BA_FB_DE_AB_66_02;    
    Key1 <= 64'h10_31_6e_02_8c_8f_3b_4a;
    Key2 <= 64'h10_31_6e_02_8c_8f_3b_4a;
    Key3 <= 64'h10_31_6e_02_8c_8f_3b_4a;
//    ENC <= 1'b1; // encryption
    ENC <= 1'b0; // decryption
    EN <= 1'b1;
    #(PERIOD) RSTn <= 1'b1;
    #(PERIOD) Krdy <= 1'b1;
    #(PERIOD) Krdy <= 1'b0;
    #(PERIOD) Drdy <= 1'b1;
    #(PERIOD) Drdy <= 1'b0;
    #(PERIOD * 100) $finish;
  end

endmodule // TDES_TB
