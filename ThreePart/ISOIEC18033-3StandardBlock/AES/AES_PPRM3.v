/*-------------------------------------------------------------------------
 AES Encryption/Decryption Macro (ASIC version)
 
 File name   : AES_PPRM3.v
 Version     : Version 1.0
 Created     : 
 Last update : SEP/25/2007
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

//`timescale 1ns / 1ps

module AES_PPRM3(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY, Kvld, Dvld);
  input  [127:0] Kin;  // Key input
  input  [127:0] Din;  // Data input
  output [127:0] Dout; // Data output
  input  Krdy;         // Key input ready
  input  Drdy;         // Data input ready
//  input  EncDec;       // 0:Encryption 1:Decryption
  input  RSTn;         // Reset (Low active)
  input  EN;           // AES circuit enable
  input  CLK;          // System clock
  output BSY;          // Busy signal
  output Kvld;         // Data output valid
  output Dvld;         // Data output valid

  wire EN_E, EN_D;
  wire [127:0] Dout_E, Dout_D;
  wire BSY_E, BSY_D;
  wire Dvld_E, Dvld_D;
  wire Kvld_E, Kvld_D;

  wire Dvld_tmp, Kvld_tmp;
  reg  Dvld_reg, Kvld_reg;

  parameter EncDec = 1'b0; // Only encryption is supported

  assign EN_E = (~EncDec) & EN;
  assign EN_D =  EncDec & EN;
//  assign BSY  = BSY_E | BSY_D;
  assign BSY  = BSY_E;

  assign Dvld_tmp = Dvld_E & (~EncDec) | Dvld_D & EncDec;
  assign Kvld_tmp = Kvld_E & (~EncDec) | Kvld_D & EncDec;

  assign Dvld = ( (Dvld_reg == 1'b0) && (Dvld_tmp == 1'b1) ) ? 1'b1: 1'b0;
  assign Kvld = ( (Kvld_reg == 1'b0) && (Kvld_tmp == 1'b1) ) ? 1'b1: 1'b0;  

  assign Dout = (EncDec == 0)? Dout_E: Dout_D;

  AES_PPRM3_ENC AES_PPRM3_ENC(Kin, Din, Dout_E, Krdy, Drdy, RSTn, EN_E, CLK, BSY_E, Kvld_E, Dvld_E);
  //AES_DEC AES_DEC(Kin, Din, Dout_D, Krdy, Drdy, RSTn, EN_D, CLK, BSY_D, Kvld_D, Dvld_D);

  // Behavior for Dvld_reg and Kvld_reg.
  always @(posedge CLK) begin
    if (RSTn == 0) begin
      Dvld_reg <= 1'b0;
      Kvld_reg <= 1'b0;
    end
    else if (EN == 1) begin
      Dvld_reg <= Dvld_tmp;
      Kvld_reg <= Kvld_tmp;
    end
  end
endmodule

/////////////////////////////
//        Sbox PPRM        //
/////////////////////////////
module AES_PPRM3_SboxPPRM(x, y);
  input  [7:0]  x;
  output [7:0]  y;

  wire  [3:0] a, b, c, d;

  assign a = { x[7] ^ x[5],
               x[7] ^ x[6] ^ x[4] ^ x[3] ^ x[2] ^ x[1],
               x[7] ^ x[5] ^ x[3] ^ x[2],
               x[7] ^ x[5] ^ x[3] ^ x[2] ^ x[1]};
  assign b = { x[5] ^ x[6] ^ x[2] ^ x[1],
               x[6],
               x[7] ^ x[5] ^ x[3] ^ x[2] ^ x[6] ^ x[4] ^ x[1],
               x[7] ^ x[5] ^ x[3] ^ x[2] ^ x[6] ^ x[0]};
  assign c[3] = (x[5] & x[1]) ^ (x[7] & x[1]) ^ (x[5] & x[2]) ^ (x[5] & x[6])
              ^ (x[5] & x[7]) ^ (x[5] & x[4]) ^ (x[7] & x[4]) ^ (x[5] & x[0])
              ^ (x[7] & x[0]) ^ (x[3] & x[1]) ^ (x[4] & x[1]) ^ (x[3] & x[2])
              ^ (x[2] & x[4]) ^ (x[4] & x[6]) ^ (x[2] & x[1]) ^ (x[2] & x[6])
              ^ (x[6] & x[1]);
  assign c[2] = (x[6] & x[1]) ^ (x[2] & x[6]) ^ (x[3] & x[6]) ^ (x[7] & x[6])
              ^ (x[1] & x[0]) ^ (x[2] & x[0]) ^ (x[3] & x[0]) ^ (x[4] & x[0])
              ^ (x[6] & x[0]) ^ (x[7] & x[0]) ^ (x[5] & x[2]) ^ (x[5] & x[3])
              ^ (x[2] & x[4]) ^ (x[3] & x[4]) ^ (x[5] & x[7]) ^ (x[7] & x[2])
              ^ (x[5] & x[6]) ^ (x[3] & x[2]) ^ (x[7] & x[3]);
  assign c[1] = (x[2] & x[1]) ^ (x[2] & x[4]) ^ (x[5] & x[4]) ^ (x[3] & x[6])
              ^ (x[5] & x[6]) ^ (x[2] & x[0]) ^ (x[3] & x[0]) ^ (x[5] & x[0])
              ^ (x[7] & x[0]) ^ x[1] ^ (x[5] & x[2]) ^ (x[7] & x[2])
              ^ (x[5] & x[3]) ^ (x[5] & x[7]) ^ x[7] ^ x[2] ^ (x[3] & x[2])
              ^ x[4] ^ x[5];
  assign c[0] = (x[1] & x[0]) ^ (x[2] & x[0]) ^ (x[3] & x[0]) ^ (x[5] & x[0])
              ^ (x[7] & x[0]) ^ (x[3] & x[1]) ^ (x[6] & x[1]) ^ (x[3] & x[6])
              ^ (x[5] & x[6]) ^ (x[7] & x[6]) ^ (x[3] & x[4]) ^ (x[7] & x[4])
              ^ (x[5] & x[3]) ^ (x[4] & x[1]) ^ x[2] ^ (x[3] & x[2])
              ^ (x[4] & x[6]) ^ x[6] ^ x[5] ^ x[3] ^ x[0];

  assign d[3] = (c[3] & c[2] & c[1]) ^ (c[3] & c[0]) ^ c[3] ^ c[2];
  assign d[2] = (c[3] & c[2] & c[0]) ^ (c[3] & c[0]) ^ (c[3] & c[2] & c[1])
              ^ (c[2] & c[1]) ^ c[2];
  assign d[1] = (c[3] & c[2] & c[1]) ^ (c[3] & c[1] & c[0]) ^ c[3]
              ^ (c[2] & c[0]) ^ c[2] ^ c[1];
  assign d[0] = (c[3] & c[2] & c[0]) ^ (c[3] & c[1] & c[0])
              ^ (c[3] & c[2] & c[1]) ^ (c[3] & c[1]) ^ (c[3] & c[0])
              ^ (c[2] & c[1] & c[0]) ^ c[2] ^ (c[2] & c[1]) ^ c[1] ^ c[0];

  assign y[7] = (d[3] & a[0]) ^ (d[2] & a[1]) ^ (d[1] & a[2]) ^ (d[0] & a[3])
              ^ (b[2] & d[3]) ^ ( b[3] & d[2]) ^ (b[2] & d[2]) ^ (d[3] & a[3])
              ^ (d[3] & a[1]) ^ (d[1] & a[3]) ^ (b[0] & d[2]) ^ (b[2] & d[0])
              ^ (d[3] & a[2]) ^ (d[2] & a[3]) ^ (b[0] & d[3]) ^ (b[1] & d[2])
              ^ (b[2] & d[1]) ^ (b[3] & d[0]);
  assign y[6] = ~(a[0] & d[2]) ^ (a[2] & d[0]) ^ (d[3] & a[3]) ^ (a[0] & d[1])
              ^ (a[1] & d[0]) ^ (d[3] & a[2]) ^ (d[2] & a[3]) ^ (a[0] & d[0])
              ^ (d[3] & a[0]) ^ (d[2] & a[1]) ^ (d[1] & a[2]) ^ (d[0] & a[3]);
  assign y[5] = ~(d[3] & a[3]) ^ (d[3] & a[1]) ^ (d[1] & a[3]) ^ (d[3] & a[2])
              ^ (d[2] & a[3]) ^ (b[2] & d[2]) ^ (b[0] & d[2]) ^ (b[2] & d[0])
              ^ (b[3] & d[3]) ^ (b[1] & d[3]) ^ (b[3] & d[1]) ^ (d[3] & a[0])
              ^ (d[2] & a[1]) ^ (d[1] & a[2]) ^ (d[0] & a[3]);
  assign y[4] = (d[3] & a[1]) ^ (d[1] & a[3]) ^ (a[0] & d[0]) ^ (b[3] & d[3])
              ^ (b[0] & d[1]) ^ (b[1] & d[0]) ^ (d[3] & a[0]) ^ (d[2] & a[1])
              ^ (d[1] & a[2]) ^ (d[0] & a[3]) ^ (a[1] & d[1]) ^ (b[2] & d[2])
              ^ (b[0] & d[0]);
  assign y[3] = (b[0] & d[1]) ^ (b[1] & d[0]) ^ (b[0] & d[2]) ^ (b[2] & d[0])
              ^ (b[1] & d[3]) ^ (b[3] & d[1]) ^ (b[0] & d[0]);
  assign y[2] = (a[0] & d[2]) ^ (a[2] & d[0]) ^ (a[0] & d[1]) ^ (a[1] & d[0])
              ^ (b[1] & d[1]) ^ (b[2] & d[2]) ^ (d[3] & a[1]) ^ (d[1] & a[3])
              ^ (b[0] & d[2]) ^ (b[2] & d[0]) ^ (b[3] & d[3]) ^ (a[0] & d[0])
              ^ (b[0] & d[3]) ^ (b[1] & d[2]) ^ (b[2] & d[1]) ^ (b[3] & d[0])
              ^ (b[0] & d[0]);
  assign y[1] = ~(d[3] & a[0]) ^ (d[2] & a[1]) ^ (d[1] & a[2]) ^ (d[0] & a[3])
             ^ (b[1] & d[1]) ^ (b[2] & d[3]) ^ (b[3] & d[2]) ^ (d[3] & a[3])
             ^ (d[3] & a[1]) ^ (d[1] & a[3]) ^ (b[3] & d[3]) ^ (d[3] & a[2])
             ^ (d[2] & a[3]) ^ (b[0] & d[0]);
  assign y[0] = ~(d[3] & a[0]) ^ (d[2] & a[1]) ^ (d[1] & a[2]) ^ (d[0] & a[3])
             ^ (a[0] & d[2]) ^ (a[2] & d[0]) ^ (b[0] & d[1]) ^ (b[1] & d[0])
             ^ (d[2] & a[2]) ^ (b[0] & d[2]) ^ (b[2] & d[0]) ^ (b[1] & d[3])
             ^ (b[3] & d[1]) ^ (d[3] & a[2]) ^ (d[2] & a[3]) ^ (b[0] & d[0]);
endmodule


/////////////////////////////
//     SubBytes PPRM       //
/////////////////////////////
module AES_PPRM3_SubBytesPPRM (x, y);
  input  [31:0] x;
  output [31:0] y;

  AES_PPRM3_SboxPPRM Sbox3(x[31:24], y[31:24]);
  AES_PPRM3_SboxPPRM Sbox2(x[23:16], y[23:16]);
  AES_PPRM3_SboxPPRM Sbox1(x[15: 8], y[15: 8]);
  AES_PPRM3_SboxPPRM Sbox0(x[ 7: 0], y[ 7: 0]);
endmodule


/////////////////////////////
//       MixColumns        //
/////////////////////////////
module AES_PPRM3_MixColumns(x, y);
  input  [31:0]  x;
  output [31:0]  y;

  wire [7:0] a3, a2, a1, a0, b3, b2, b1, b0;

  assign a3 = x[31:24]; assign a2 = x[23:16];
  assign a1 = x[15: 8]; assign a0 = x[ 7: 0];

  assign b3 = a3 ^ a2; assign b2 = a2 ^ a1;
  assign b1 = a1 ^ a0; assign b0 = a0 ^ a3;

  assign y = {a2[7] ^ b1[7] ^ b3[6],         a2[6] ^ b1[6] ^ b3[5],
              a2[5] ^ b1[5] ^ b3[4],         a2[4] ^ b1[4] ^ b3[3] ^ b3[7],
              a2[3] ^ b1[3] ^ b3[2] ^ b3[7], a2[2] ^ b1[2] ^ b3[1],
              a2[1] ^ b1[1] ^ b3[0] ^ b3[7], a2[0] ^ b1[0] ^ b3[7],
              a3[7] ^ b1[7] ^ b2[6],         a3[6] ^ b1[6] ^ b2[5],
              a3[5] ^ b1[5] ^ b2[4],         a3[4] ^ b1[4] ^ b2[3] ^ b2[7],
              a3[3] ^ b1[3] ^ b2[2] ^ b2[7], a3[2] ^ b1[2] ^ b2[1],
              a3[1] ^ b1[1] ^ b2[0] ^ b2[7], a3[0] ^ b1[0] ^ b2[7],
              a0[7] ^ b3[7] ^ b1[6],         a0[6] ^ b3[6] ^ b1[5],
              a0[5] ^ b3[5] ^ b1[4],         a0[4] ^ b3[4] ^ b1[3] ^ b1[7],
              a0[3] ^ b3[3] ^ b1[2] ^ b1[7], a0[2] ^ b3[2] ^ b1[1],
              a0[1] ^ b3[1] ^ b1[0] ^ b1[7], a0[0] ^ b3[0] ^ b1[7],
              a1[7] ^ b3[7] ^ b0[6],         a1[6] ^ b3[6] ^ b0[5],
              a1[5] ^ b3[5] ^ b0[4],         a1[4] ^ b3[4] ^ b0[3] ^ b0[7],
              a1[3] ^ b3[3] ^ b0[2] ^ b0[7], a1[2] ^ b3[2] ^ b0[1],
              a1[1] ^ b3[1] ^ b0[0] ^ b0[7], a1[0] ^ b3[0] ^ b0[7]};
endmodule


/////////////////////////////
//     Encryption Core     //
/////////////////////////////
module AES_PPRM3_EncCore(di, ki, Rrg, do, ko);
  input  [127:0] di, ki;
  input  [9:0]   Rrg;
  output [127:0] do, ko;

  wire   [127:0] sb, sr, mx;
  wire   [31:0]  so;

  AES_PPRM3_SubBytesPPRM SB3 (di[127:96], sb[127:96]);
  AES_PPRM3_SubBytesPPRM SB2 (di[ 95:64], sb[ 95:64]);
  AES_PPRM3_SubBytesPPRM SB1 (di[ 63:32], sb[ 63:32]);
  AES_PPRM3_SubBytesPPRM SB0 (di[ 31: 0], sb[ 31: 0]);
  AES_PPRM3_SubBytesPPRM SBK ({ki[23:16], ki[15:8], ki[7:0], ki[31:24]}, so);

  assign sr = {sb[127:120], sb[ 87: 80], sb[ 47: 40], sb[  7:  0],
               sb[ 95: 88], sb[ 55: 48], sb[ 15:  8], sb[103: 96],
               sb[ 63: 56], sb[ 23: 16], sb[111:104], sb[ 71: 64],
               sb[ 31: 24], sb[119:112], sb[ 79: 72], sb[ 39: 32]};

  AES_PPRM3_MixColumns MX3 (sr[127:96], mx[127:96]);
  AES_PPRM3_MixColumns MX2 (sr[ 95:64], mx[ 95:64]);
  AES_PPRM3_MixColumns MX1 (sr[ 63:32], mx[ 63:32]);
  AES_PPRM3_MixColumns MX0 (sr[ 31: 0], mx[ 31: 0]);

  assign do = ((Rrg[0] == 1)? sr: mx) ^ ki;

  function [7:0] rcon;
  input [9:0] x;
    casex (x)
      10'bxxxxxxxxx1: rcon = 8'h01;
      10'bxxxxxxxx1x: rcon = 8'h02;
      10'bxxxxxxx1xx: rcon = 8'h04;
      10'bxxxxxx1xxx: rcon = 8'h08;
      10'bxxxxx1xxxx: rcon = 8'h10;
      10'bxxxx1xxxxx: rcon = 8'h20;
      10'bxxx1xxxxxx: rcon = 8'h40;
      10'bxx1xxxxxxx: rcon = 8'h80;
      10'bx1xxxxxxxx: rcon = 8'h1b;
      10'b1xxxxxxxxx: rcon = 8'h36;
    endcase
  endfunction

  assign ko = {ki[127:96] ^ {so[31:24] ^ rcon(Rrg), so[23: 0]},
               ki[ 95:64] ^ ko[127:96],
               ki[ 63:32] ^ ko[ 95:64],
               ki[ 31: 0] ^ ko[ 63:32]};
endmodule


/////////////////////////////
//   AES for encryption    //
/////////////////////////////
module AES_PPRM3_ENC(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY, Kvld, Dvld);
  input  [127:0] Kin;  // Key input
  input  [127:0] Din;  // Data input
  output [127:0] Dout; // Data output
  input  Krdy;         // Key input ready
  input  Drdy;         // Data input ready
  input  RSTn;         // Reset (Low active)
  input  EN;           // AES circuit enable
  input  CLK;          // System clock
  output BSY;          // Busy signal
  output Kvld;         // Key valid
  output Dvld;         // Data output valid

  reg  [127:0] Drg;    // Data register
  reg  [127:0] Krg;    // Key register
  reg  [127:0] KrgX;   // Temporary key Register
  reg  [9:0]   Rrg;    // Round counter
  reg  Kvldrg, Dvldrg, BSYrg;
  wire [127:0] Dnext, Knext;

  AES_PPRM3_EncCore EC (Drg, KrgX, Rrg, Dnext, Knext);

  assign Kvld = Kvldrg;
  assign Dvld = Dvldrg;
  assign Dout = Drg;
  assign BSY  = BSYrg;

  always @(posedge CLK) begin
    if (RSTn == 0) begin
      Krg    <= 128'h0000000000000000;
      KrgX   <= 128'h0000000000000000;
      Rrg    <= 10'b0000000001;
      Kvldrg <= 0;
      Dvldrg <= 0;
      BSYrg  <= 0;
    end
    else if (EN == 1) begin
      if (BSYrg == 0) begin
        if (Krdy == 1) begin
          Krg    <= Kin;
          KrgX   <= Kin;
          Kvldrg <= 1;
          Dvldrg <= 0;
        end
        else if (Drdy == 1) begin
          Rrg    <= {Rrg[8:0], Rrg[9]};
          KrgX   <= Knext;
          Drg    <= Din ^ Krg;
          Dvldrg <= 0;
          BSYrg  <= 1;
        end
      end
      else begin
        Drg <= Dnext;
        if (Rrg[0] == 1) begin
          KrgX   <= Krg;
          Dvldrg <= 1;
          BSYrg  <= 0;
        end
        else begin
          Rrg    <= {Rrg[8:0], Rrg[9]};
          KrgX   <= Knext;
        end
      end
    end
  end
endmodule


/////////////////////////////
//   AES for encryption    //
//   with output register  //
/////////////////////////////
module AES_PPRM3_ENCx(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY, Kvld, Dvld);
  input  [127:0] Kin;  // Key input
  input  [127:0] Din;  // Data input
  output [127:0] Dout; // Data output
  input  Krdy;         // Key input ready
  input  Drdy;         // Data input ready
  input  RSTn;         // Reset (Low active)
  input  EN;           // AES circuit enable
  input  CLK;          // System clock
  output BSY;          // Busy signal
  output Kvld;         // Key valid
  output Dvld;         // Data output valid

  reg  [127:0] Drg;    // Data register
  reg  [127:0] DrgX;   // Data output regsiter
  reg  [127:0] Krg;    // Key register
  reg  [127:0] KrgX;   // Temporary key Register
  reg  [9:0]   Rrg;    // Round counter
  reg  Kvldrg, Dvldrg, BSYrg;
  wire [127:0] Dnext, Knext;

  AES_PPRM3_EncCore EC (Drg, KrgX, Rrg, Dnext, Knext);

  assign Kvld = Kvldrg;
  assign Dvld = Dvldrg;
  assign Dout = DrgX;
  assign BSY  = BSYrg;

  always @(posedge CLK) begin
    if (RSTn == 0) begin
      Krg    <= 128'h0000000000000000;
      KrgX   <= 128'h0000000000000000;
      Rrg    <= 10'b0000000001;
      Kvldrg <= 0;
      Dvldrg <= 0;
      BSYrg  <= 0;
    end
    else if (EN == 1) begin
      if (BSYrg == 0) begin
        if (Krdy == 1) begin
          Krg    <= Kin;
          KrgX   <= Kin;
          Kvldrg <= 1;
          Dvldrg <= 0;
        end
        else if (Drdy == 1) begin
          Rrg    <= {Rrg[8:0], Rrg[9]};
          KrgX   <= Knext;
          Drg    <= Din ^ Krg;
          Dvldrg <= 0;
          BSYrg  <= 1;
        end
      end
      else begin
        if (Rrg[0] == 1) begin
          KrgX   <= Krg;
          DrgX   <= Dnext;
          Dvldrg <= 1;
          BSYrg  <= 0;
        end
        else begin
          Rrg    <= {Rrg[8:0], Rrg[9]};
          KrgX   <= Knext;
          Drg    <= Dnext;
        end
      end
    end
  end
endmodule
