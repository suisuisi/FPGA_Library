/*-------------------------------------------------------------------------
 Testbench for DES Encryption/Decryption Macro (ASIC version)
                                   
 File name   : DES_TB.v
 Version     : Version 1.0
 Created     : 
 Last update : SEP/04/2007
 Desgined by : Akashi Satoh
 
 
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


///////////////////////////////////
//    DES TestBenchencryption    //
///////////////////////////////////
`timescale 1ns/1ns

module DES_TB;
parameter CLOCK = 10;

reg  [1:64] Din;
reg  [1:64] Key;
reg  Drdy;
reg  Krdy;
reg  ENC;
reg  RSTn;  // negative reset;
reg  EN;
reg  CLK;
wire [1:64] Dout;
wire BSY;
wire Kvld, Dvld;

DES DES(
	.Din(Din),
	.Key(Key),
	.Dout(Dout),
	.Drdy(Drdy),
	.Krdy(Krdy),
	.ENC(ENC),
	.RSTn(RSTn),
	.EN(EN),
	.CLK(CLK),
	.BSY(BSY),
	.Kvld(Kvld), 
	.Dvld(Dvld)
);

// Test Vectors from FIPS PUB 81
reg [1:64] PT0, PT1, PT2, CT0, CT1, CT2;

initial Key = 64'h0123456789abcdef; // Key
initial PT0 = 64'h4e6f772069732074; // Plain Text 0
initial PT1 = 64'h68652074696d6520; // Plain Text 1
initial PT2 = 64'h666f7220616c6c20; // Plain Text 2
initial CT0 = 64'h3fa40e8a984d4815; // Cipher Text 0
initial CT1 = 64'h6a271787ab8883f9; // Cipher Text 1
initial CT2 = 64'h893d51ec4b563b53; // Cipher Text 2

initial CLK = 1;
always #(CLOCK/2)
  CLK <= ~CLK;

initial begin

#(CLOCK/2)
// Reset
  ENC   <= 1;
  EN    <= 0;
  RSTn  <= 0;
  Krdy  <= 0;
  Drdy  <= 0;
#(CLOCK)
  RSTn  <= 1;

// Key set
#(CLOCK)
  EN    <= 1;
  Krdy  <= 1;

#(CLOCK)
  Krdy  <= 0;

// Encrypt 1st plain text
#(CLOCK)
  Drdy  <= 1;
  Din   <= PT0;
#(CLOCK)
  Drdy  <= 0;
#(CLOCK*15)

// Encrypt 2st plain text
#(CLOCK)
  Drdy  <= 1;
  Din   <= PT1;
#(CLOCK)
  Drdy  <= 0;
#(CLOCK*15)

// Encrypt 3st plain text
#(CLOCK)
  Drdy  <= 1;
  Din   <= PT2;
#(CLOCK)
  Drdy  <= 0;
#(CLOCK*15)


// Decrypt 1st cipher text
#(CLOCK)
  ENC   <= 0;
#(CLOCK)
  Drdy  <= 1;
  Din   <= CT0;
#(CLOCK)
  Drdy  <= 0;
#(CLOCK*15)

// Decrypt 2st cipher text
#(CLOCK)
  Drdy  <= 1;
  Din   <= CT1;
#(CLOCK)
  Drdy  <= 0;
#(CLOCK*15)

// Decrypt 3st cipher text
#(CLOCK)
  Drdy  <= 1;
  Din   <= CT2;
#(CLOCK)
  Drdy  <= 0;
#(CLOCK*15)
  $finish;
end
endmodule
