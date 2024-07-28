/*-------------------------------------------------------------------------
 Testbench module for 
 AES_Comp.v, AES_TBL.v, AES_PPRM1.v, and AES_PPRM3.v
                                   
 File name   : AES_ENC_TB.v
 Version     : Version 1.0
 Created     : 
 Last update : SEP/25/2007
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

module AES_ENC_TB;

   parameter CLOCK = 10;

   reg [127:0] Kin;
   reg [127:0] Din;
   reg 	       Krdy;
   reg 	       Drdy;
   reg 	       EncDec;
   reg 	       RSTn;
   reg 	       EN;
   reg 	       CLK;

   wire [127:0] Dout_Comp, Dout_TBL, Dout_PPRM1, Dout_PPRM3;
   wire 	BSY_Comp, BSY_TBL, BSY_PPRM1, BSY_PPRM3;
   wire 	Kvld_Comp, Kvld_TBL, Kvld_PPRM1, Kvld_PPRM3;
   wire 	Dvld_Comp, Dvld_TBL, Dvld_PPRM1, Dvld_PPRM3;

   AES_Comp AES_Comp(
      .Kin(Kin),
      .Din(Din),
      .Dout(Dout_Comp),
      .Krdy(Krdy),
      .Drdy(Drdy),
      .EncDec(1'b0),
      .RSTn(RSTn),
      .EN(EN),
      .CLK(CLK),
      .BSY(BSY_Comp),
      .Kvld(Kvld_Comp),
      .Dvld(Dvld_Comp) );

   AES_TBL AES_TBL(
      .Kin       (Kin),
      .Din       (Din),
      .Dout      (Dout_TBL),
      .Krdy      (Krdy),
      .Drdy      (Drdy),
      .RSTn      (RSTn),
      .EN        (EN),
      .CLK       (CLK),
      .BSY       (BSY_TBL),
      .Kvld      (Kvld_TBL),
      .Dvld      (Dvld_TBL) );
  
   AES_PPRM1 AES_PPRM1(
      .Kin       (Kin),
      .Din       (Din),
      .Dout      (Dout_PPRM1),
      .Krdy      (Krdy),
      .Drdy      (Drdy),
      .RSTn      (RSTn),
      .EN        (EN),
      .CLK       (CLK),
      .BSY       (BSY_PPRM1),
      .Kvld      (Kvld_PPRM1),
      .Dvld      (Dvld_PPRM1) );

   AES_PPRM3 AES_PPRM3(
      .Kin       (Kin),
      .Din       (Din),
      .Dout      (Dout_PPRM3),
      .Krdy      (Krdy),
      .Drdy      (Drdy),
      .RSTn      (RSTn),
      .EN        (EN),
      .CLK       (CLK),
      .BSY       (BSY_PPRM3),
      .Kvld      (Kvld_PPRM3),
      .Dvld      (Dvld_PPRM3) );

   // FIPS-197 Test Vectors
   reg [127:0] 	KE, KD, CT, PT;
   initial KE = 128'h000102030405060708090a0b0c0d0e0f; // Encryption Key
   initial KD = 128'h13111d7fe3944a17f307a78b4d2b30c5; // Decryption Key (Encryption final round key)
   initial PT = 128'h00112233445566778899aabbccddeeff; // Plain Text
   initial CT = 128'h69c4e0d86a7b0430d8cdb78070b4c55a; // Cipher Text

   initial CLK = 1;
   always #(CLOCK/2)
     CLK <= ~CLK;

   initial begin

      #(CLOCK/2);
      // Reset
      Krdy <= 0;
      Drdy <= 0;
      RSTn <= 0;
      EN <= 0;

      // Eecryption key set
      #(CLOCK);
      RSTn <= 1;
      EN <= 1;
      EncDec <= 0;
      Kin  <= KE;
      Krdy <= 1;

      // Plain text set
      #(CLOCK);
      Krdy <= 0;
      Din  <= PT;
      Drdy <= 1;

      #(CLOCK*1);
      Drdy <= 0;
      #(CLOCK*10);

      // Decryption key set
      #(CLOCK);
      EncDec <= 1;
      Kin  <= KE;
      Krdy <= 1;

      // Cipher text set
      #(CLOCK*12);
      Krdy <= 0;
      Din  <= CT;
      Drdy <= 1;

      #(CLOCK*1);
      Drdy <= 0;

   end
endmodule
