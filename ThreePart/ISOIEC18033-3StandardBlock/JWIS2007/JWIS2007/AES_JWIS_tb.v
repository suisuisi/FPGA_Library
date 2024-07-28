/*-------------------------------------------------------------------------
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
//    AES TestBench encryption   //
///////////////////////////////////
`timescale 1ns/1ns

module AES_TB;
parameter CLOCK = 10;

reg  [127:0] Din;
reg  [127:0] Key;
reg  Drdy;
reg  Krdy;
reg  EncDec;
reg  RSTn;
reg  EN;
reg  CLK;
wire [127:0] Dout;
wire BSY, Dvld;

AES AES(
  .Din(Din),
  .Key(Key),
  .Dout(Dout),
  .Drdy(Drdy),
  .Krdy(Krdy),
  .EncDec(EncDec),
  .RSTn(RSTn),
  .EN(EN),
  .CLK(CLK),
  .BSY(BSY),
  .Dvld(Dvld)
);

// FIPS-197 Test Vectors
reg [127:0] KE, KD, CT, PT;
initial KE = 128'h000102030405060708090a0b0c0d0e0f; // Encryption Key
initial KD = 128'h13111d7fe3944a17f307a78b4d2b30c5; // Decryption Key (Encryption finlarl round key)
initial PT = 128'h00112233445566778899aabbccddeeff; // Plain Text
initial CT = 128'h69c4e0d86a7b0430d8cdb78070b4c55a; // Cipher Text

initial CLK = 1;
always #(CLOCK/2)
  CLK <= ~CLK;

initial begin

#(CLOCK/2)
// Reset
  EN     <= 0;
  EncDec <= 0; 
  RSTn   <= 0;
  Krdy   <= 0;
  Drdy   <= 0;

// Eecryption key set
#(CLOCK)
  RSTn <= 1;
  EN   <= 1;
  Key  <= KE;
  Krdy <= 1;

// Cipher text set
#(CLOCK)
  Krdy <= 0;
  Din  <= PT;
  Drdy <= 1;

#(CLOCK*1)
  Drdy <= 0;
#(CLOCK*10)

// Reset 
  RSTn   <= 0;
  EncDec <= 1;

// Decryption key set
#(CLOCK)
  RSTn <= 1;
  Key    <= KD;
  Krdy   <= 1;

// Cipher text set
#(CLOCK)
  Krdy <= 0;
  Din  <= CT;
  Drdy <= 1;

#(CLOCK*1)
  Drdy <= 0;

#(CLOCK*15)
  $finish;
end // initial begin

always @(posedge CLK) begin
  $display("%x", Dout);
end

endmodule

