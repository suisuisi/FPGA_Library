/*-------------------------------------------------------------------------
 AES Encryption/Decryption Macro (ASIC version)
                                   
 File name   : AES_Comp.v
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

module AES_Comp(Kin, Din, Dout, Krdy, Drdy, EncDec, RSTn, EN, CLK, BSY, Kvld, Dvld);
  input  [127:0] Kin;  // Key input
  input  [127:0] Din;  // Data input
  output [127:0] Dout; // Data output
  input  Krdy;         // Key input ready
  input  Drdy;         // Data input ready
  input  EncDec;       // 0:Encryption 1:Decryption
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

  assign EN_E = (~EncDec) & EN;
  assign EN_D =  EncDec & EN;
  assign BSY  = BSY_E | BSY_D;

  assign Dvld_tmp = Dvld_E & (~EncDec) | Dvld_D & EncDec;
  assign Kvld_tmp = Kvld_E & (~EncDec) | Kvld_D & EncDec;

  assign Dvld = ( (Dvld_reg == 1'b0) && (Dvld_tmp == 1'b1) ) ? 1'b1: 1'b0;
  assign Kvld = ( (Kvld_reg == 1'b0) && (Kvld_tmp == 1'b1) ) ? 1'b1: 1'b0;  

  assign Dout = (EncDec == 0)? Dout_E: Dout_D;

  AES_Comp_ENC AES_Comp_ENC(Kin, Din, Dout_E, Krdy, Drdy, RSTn, EN_E, CLK, BSY_E, Kvld_E, Dvld_E);
  AES_Comp_DEC AES_Comp_DEC(Kin, Din, Dout_D, Krdy, Drdy, RSTn, EN_D, CLK, BSY_D, Kvld_D, Dvld_D);

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
//   GF(2^2^2^2) inverter  //
/////////////////////////////
module AES_Comp_GFinvComp(x, y);
  input  [7:0] x;
  output [7:0] y;

  wire [8:0] da, db, dx, dy, va, tp, tn;
  wire [3:0] u, v;
  wire [4:0] mx;
  wire [5:0] my;

  assign da ={x[3], x[2]^x[3], x[2], x[1]^x[3], x[0]^x[1]^x[2]^x[3], x[0]^x[2], x[1], x[0]^x[1], x[0]};
  assign db ={x[7], x[6]^x[7], x[6], x[5]^x[7], x[4]^x[5]^x[6]^x[7], x[4]^x[6], x[5], x[4]^x[5], x[4]};
  assign va ={v[3], v[2]^v[3], v[2], v[1]^v[3], v[0]^v[1]^v[2]^v[3], v[0]^v[2], v[1], v[0]^v[1], v[0]};
  assign dx = da ^ db;
  assign dy = da & dx;
  assign tp = va & dx;
  assign tn = va & db;

  assign u = {dy[0] ^ dy[1] ^ dy[3] ^ dy[4] ^ x[4] ^ x[5] ^ x[6],
              dy[0] ^ dy[2] ^ dy[3] ^ dy[5] ^ x[4] ^ x[7],
              dy[0] ^ dy[1] ^ dy[7] ^ dy[8] ^ x[7],
              dy[0] ^ dy[2] ^ dy[6] ^ dy[7] ^ x[6] ^ x[7]};

  assign y = {tn[0] ^ tn[1] ^ tn[3] ^ tn[4], tn[0] ^ tn[2] ^ tn[3] ^ tn[5],
              tn[0] ^ tn[1] ^ tn[7] ^ tn[8], tn[0] ^ tn[2] ^ tn[6] ^ tn[7],
              tp[0] ^ tp[1] ^ tp[3] ^ tp[4], tp[0] ^ tp[2] ^ tp[3] ^ tp[5],
              tp[0] ^ tp[1] ^ tp[7] ^ tp[8], tp[0] ^ tp[2] ^ tp[6] ^ tp[7]};

  ////////////////////////
  // GF(2^2^2) Inverter //
  ////////////////////////
    assign mx = {mx[0] ^ mx[1] ^ u[2],
                 mx[0] ^ mx[2] ^ u[3],
                 u[1] & (u[1] ^ u[3]),
                 (u[0] ^ u[1]) & (u[0] ^ u[1]  ^ u[2] ^ u[3]),
                 u[0] & (u[0] ^ u[2])};

    assign my = {~(mx[4] & u[3]),
                 ~(mx[3] & (u[2] ^ u[3])),
                 ~((mx[3] ^ mx[4]) & u[2]),
                 ~(mx[4] & (u[1] ^ u[3])),
                 ~(mx[3] & (u[0] ^ u[1]  ^ u[2] ^ u[3])),
                 ~((mx[3] ^ mx[4]) & (u[0] ^ u[2]))};

    assign v = {my[3]^my[4], my[3]^my[5], my[0]^my[1], my[0]^my[2]};
endmodule


/////////////////////////////
//     Sbox GF(2^2^2^2)    //
/////////////////////////////
module AES_Comp_SboxComp(x, y);
  input  [7:0] x;
  output [7:0] y;

  wire [7:0] a, b;

  assign a = {x[5] ^ x[7],
              x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[6] ^ x[7],
              x[2] ^ x[3] ^ x[5] ^ x[7],
              x[1] ^ x[2] ^ x[3] ^ x[5] ^ x[7],
              x[1] ^ x[2] ^ x[6] ^ x[7],
              x[1] ^ x[2] ^ x[3] ^ x[4] ^ x[7],
              x[1] ^ x[4] ^ x[6],
              x[0] ^ x[1] ^ x[6]};

  AES_Comp_GFinvComp AES_Comp_GFinvComp(a, b);

  assign y = { b[2] ^ b[3] ^ b[7],
              ~b[4] ^ b[5] ^ b[6] ^ b[7],
              ~b[2] ^ b[7],
               b[0] ^ b[1] ^ b[4] ^ b[7],
               b[0] ^ b[1] ^ b[2],
               b[0] ^ b[2] ^ b[3] ^ b[4] ^ b[5] ^ b[6],
              ~b[0] ^ b[7],
              ~b[0] ^ b[1] ^ b[2] ^ b[6] ^ b[7]};
endmodule


/////////////////////////////
//   InvSbox GF(2^2^2^2)   //
/////////////////////////////
module AES_Comp_InvSboxComp(x, y);
  input  [7:0] x;
  output [7:0] y;

  wire [7:0] a, b;

  assign a = { x[1] ^ x[2] ^ x[6] ^ x[7],
              ~x[0] ^ x[1] ^ x[2] ^ x[3] ^ x[6] ^ x[7],
              ~x[0] ^ x[4] ^ x[5] ^ x[6],
              ~x[3] ^ x[4] ^ x[5],
              ~x[5] ^ x[7],
              ~x[1] ^ x[2] ^ x[5] ^ x[6] ^ x[7],
               x[1] ^ x[3] ^ x[5],
              ~x[2] ^ x[6] ^ x[7]};

  AES_Comp_GFinvComp AES_Comp_GFinvComp(a, b);

  assign y = {b[1] ^ b[5] ^ b[6] ^ b[7],
              b[2] ^ b[6],
              b[1] ^ b[5] ^ b[6],
              b[1] ^ b[2] ^ b[4] ^ b[5] ^ b[6],
              b[1] ^ b[2] ^ b[3] ^ b[4] ^ b[5],
              b[1] ^ b[2] ^ b[3] ^ b[4] ^ b[7],
              b[4] ^ b[5],
              b[0] ^ b[2] ^ b[4] ^ b[5] ^ b[6]};
endmodule


/////////////////////////////
//   SubBytes GF(2^2^2^2)  //
/////////////////////////////
module AES_Comp_SubBytesComp (x, y);
  input  [31:0] x;
  output [31:0] y;

  AES_Comp_SboxComp Sbox3(x[31:24], y[31:24]);
  AES_Comp_SboxComp Sbox2(x[23:16], y[23:16]);
  AES_Comp_SboxComp Sbox1(x[15: 8], y[15: 8]);
  AES_Comp_SboxComp Sbox0(x[ 7: 0], y[ 7: 0]);
endmodule


/////////////////////////////
// InvSubBytes GF(2^2^2^2) //
/////////////////////////////
module AES_Comp_InvSubBytesComp (x, y);
  input  [31:0] x;
  output [31:0] y;

  AES_Comp_InvSboxComp Sbox3(x[31:24], y[31:24]);
  AES_Comp_InvSboxComp Sbox2(x[23:16], y[23:16]);
  AES_Comp_InvSboxComp Sbox1(x[15: 8], y[15: 8]);
  AES_Comp_InvSboxComp Sbox0(x[ 7: 0], y[ 7: 0]);
endmodule


/////////////////////////////
//       MixColumns        //
/////////////////////////////
module AES_Comp_MixColumns(x, y);
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
//     InvMixColumns       //
/////////////////////////////
module AES_Comp_InvMixColumns(x, y);
  input  [31:0]  x;
  output [31:0]  y;

  wire [7:0] a3, a2, a1, a0, b3, b2, b1, b0;
  wire [7:0] c3, c2, c1, c0, d3, d2, d1, d0;

  assign a3 = x[31:24]; assign a2 = x[23:16];
  assign a1 = x[15: 8]; assign a0 = x[ 7: 0];

  assign b3 = a3 ^ a2; assign b2 = a2 ^ a1;
  assign b1 = a1 ^ a0; assign b0 = a0 ^ a3;

  assign c3 = {a2[7] ^ b1[7] ^ b3[6],         a2[6] ^ b1[6] ^ b3[5],
               a2[5] ^ b1[5] ^ b3[4],         a2[4] ^ b1[4] ^ b3[3] ^ b3[7],
               a2[3] ^ b1[3] ^ b3[2] ^ b3[7], a2[2] ^ b1[2] ^ b3[1],
               a2[1] ^ b1[1] ^ b3[0] ^ b3[7], a2[0] ^ b1[0] ^ b3[7]};
  assign c2 = {a3[7] ^ b1[7] ^ b2[6],         a3[6] ^ b1[6] ^ b2[5],
               a3[5] ^ b1[5] ^ b2[4],         a3[4] ^ b1[4] ^ b2[3] ^ b2[7],
               a3[3] ^ b1[3] ^ b2[2] ^ b2[7], a3[2] ^ b1[2] ^ b2[1],
               a3[1] ^ b1[1] ^ b2[0] ^ b2[7], a3[0] ^ b1[0] ^ b2[7]};
  assign c1 = {a0[7] ^ b3[7] ^ b1[6],         a0[6] ^ b3[6] ^ b1[5],
               a0[5] ^ b3[5] ^ b1[4],         a0[4] ^ b3[4] ^ b1[3] ^ b1[7],
               a0[3] ^ b3[3] ^ b1[2] ^ b1[7], a0[2] ^ b3[2] ^ b1[1],
               a0[1] ^ b3[1] ^ b1[0] ^ b1[7], a0[0] ^ b3[0] ^ b1[7]};
  assign c0 = {a1[7] ^ b3[7] ^ b0[6],         a1[6] ^ b3[6] ^ b0[5],
               a1[5] ^ b3[5] ^ b0[4],         a1[4] ^ b3[4] ^ b0[3] ^ b0[7],
               a1[3] ^ b3[3] ^ b0[2] ^ b0[7], a1[2] ^ b3[2] ^ b0[1],
               a1[1] ^ b3[1] ^ b0[0] ^ b0[7], a1[0] ^ b3[0] ^ b0[7]};
  assign d3 = {c3[5], c3[4], c3[3] ^ c3[7], c3[2] ^ c3[7] ^ c3[6],
               c3[1] ^ c3[6], c3[0] ^ c3[7], c3[7] ^ c3[6], c3[6]};
  assign d2 = {c2[5], c2[4], c2[3] ^ c2[7], c2[2] ^ c2[7] ^ c2[6],
               c2[1] ^ c2[6], c2[0] ^ c2[7], c2[7] ^ c2[6], c2[6]};
  assign d1 = {c1[5], c1[4], c1[3] ^ c1[7], c1[2] ^ c1[7] ^ c1[6],
               c1[1] ^ c1[6], c1[0] ^ c1[7], c1[7] ^ c1[6], c1[6]};
  assign d0 = {c0[5], c0[4], c0[3] ^ c0[7], c0[2] ^ c0[7] ^ c0[6],
               c0[1] ^ c0[6], c0[0] ^ c0[7], c0[7] ^ c0[6], c0[6]};
  assign y  = {d3 ^ d1 ^ c3, d2 ^ d0 ^ c2, d3 ^ d1 ^ c1, d2 ^ d0 ^ c0};
endmodule


/////////////////////////////
//     Encryption Core     //
/////////////////////////////
module AES_Comp_EncCore(di, ki, Rrg, do, ko);
  input  [127:0] di, ki;
  input  [9:0]   Rrg;
  output [127:0] do, ko;

  wire   [127:0] sb, sr, mx;
  wire   [31:0]  so;

  AES_Comp_SubBytesComp SB3 (di[127:96], sb[127:96]);
  AES_Comp_SubBytesComp SB2 (di[ 95:64], sb[ 95:64]);
  AES_Comp_SubBytesComp SB1 (di[ 63:32], sb[ 63:32]);
  AES_Comp_SubBytesComp SB0 (di[ 31: 0], sb[ 31: 0]);
  AES_Comp_SubBytesComp SBK ({ki[23:16], ki[15:8], ki[7:0], ki[31:24]}, so);

  assign sr = {sb[127:120], sb[ 87: 80], sb[ 47: 40], sb[  7:  0],
               sb[ 95: 88], sb[ 55: 48], sb[ 15:  8], sb[103: 96],
               sb[ 63: 56], sb[ 23: 16], sb[111:104], sb[ 71: 64],
               sb[ 31: 24], sb[119:112], sb[ 79: 72], sb[ 39: 32]};

  AES_Comp_MixColumns MX3 (sr[127:96], mx[127:96]);
  AES_Comp_MixColumns MX2 (sr[ 95:64], mx[ 95:64]);
  AES_Comp_MixColumns MX1 (sr[ 63:32], mx[ 63:32]);
  AES_Comp_MixColumns MX0 (sr[ 31: 0], mx[ 31: 0]);

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
//     Decryotion Core     //
/////////////////////////////
module AES_Comp_DecCore(di, ki, Rrg, Kgen, do, ko);
  input  [127:0] di, ki;
  input  [9:0]   Rrg;
  input  Kgen;
  output [127:0] do, ko;

  wire   [127:0] sb, sr, mx, dx;
  wire   [31:0]  so;

  AES_Comp_InvMixColumns MX3 (di[127:96], mx[127:96]);
  AES_Comp_InvMixColumns MX2 (di[ 95:64], mx[ 95:64]);
  AES_Comp_InvMixColumns MX1 (di[ 63:32], mx[ 63:32]);
  AES_Comp_InvMixColumns MX0 (di[ 31: 0], mx[ 31: 0]);

  assign dx = (Rrg[8] == 1)? di: mx;
  assign sr = {dx[127:120], dx[ 23: 16], dx[ 47: 40], dx[ 71: 64],
               dx[ 95: 88], dx[119:112], dx[ 15:  8], dx[ 39: 32],
               dx[ 63: 56], dx[ 87: 80], dx[111:104], dx[  7:  0],
               dx[ 31: 24], dx[ 55: 48], dx[ 79: 72], dx[103: 96]};

  wire [31:0] temp;
  assign temp = ki[31:0] ^ ki[63:32];

  AES_Comp_InvSubBytesComp SB3 (sr[127:96], sb[127:96]);
  AES_Comp_InvSubBytesComp SB2 (sr[ 95:64], sb[ 95:64]);
  AES_Comp_InvSubBytesComp SB1 (sr[ 63:32], sb[ 63:32]);
  AES_Comp_InvSubBytesComp SB0 (sr[ 31: 0], sb[ 31: 0]);
  AES_Comp_SubBytesComp SBK (((Kgen == 0)?
			      {temp[23:16], temp[15:8], temp[7:0], temp[31:24]}:
			      {ki[23:16],   ki[15:8],   ki[7:0],   ki[31:24]}), so);

  assign do = sb ^ ki;

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

  assign ko = ((Kgen == 0)? {ki[127:96] ^ {so[31:24] ^ rcon(Rrg), so[23: 0]},
                          ki[ 95:64] ^ ki[127:96],
                          ki[ 63:32] ^ ki[ 95:64],
                          ki[ 31: 0] ^ ki[ 63:32]}:
                         {ki[127:96] ^ {so[31:24] ^ rcon(Rrg), so[23: 0]},
                          ki[ 95:64] ^ ko[127:96],
                          ki[ 63:32] ^ ko[ 95:64],
                          ki[ 31: 0] ^ ko[ 63:32]});
endmodule


/////////////////////////////
//   AES for encryption    //
/////////////////////////////
module AES_Comp_ENC(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY, Kvld, Dvld);
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

  AES_Comp_EncCore EC (Drg, KrgX, Rrg, Dnext, Knext);

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
//   AES for decryption    //
/////////////////////////////
module AES_Comp_DEC(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY, Kvld, Dvld);
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

  AES_Comp_DecCore DC (Drg, KrgX, Rrg, ~Kvldrg, Dnext, Knext);

  assign Kvld = Kvldrg;
  assign Dvld = Dvldrg;
  assign Dout = Drg;
  assign BSY  = BSYrg;

  always @(posedge CLK) begin
    if (RSTn == 0) begin
      Krg     <= 128'h0000000000000000;
      KrgX    <= 128'h0000000000000000;
      Kvldrg  <= 0;
      Dvldrg  <= 0;
      BSYrg   <= 0;
    end
    else if (EN == 1) begin
      if (BSYrg == 0) begin
        if (Krdy == 1) begin
          KrgX   <= Kin;
          Rrg    <= 10'b0000000001;
          Kvldrg <= 0;
          Dvldrg <= 0;
          BSYrg  <= 1;
        end
        else if ((Kvldrg == 1) && (Drdy == 1)) begin
          KrgX   <= Knext;
          Drg    <= Din ^ Krg;
          Rrg    <= {Rrg[0], Rrg[9:1]};
          Dvldrg <= 0;
          BSYrg  <= 1;
        end
      end
      else if (Kvldrg == 0) begin    // initial key generation
        if (Rrg == 10'b0000000000) begin
          Rrg    <= 10'b1000000000;
          Krg    <= KrgX;
          Kvldrg <= 1;
          BSYrg  <= 0;
        end
        else begin
          Rrg    <= {Rrg[8:0], 1'b0};
          KrgX   <= Knext;
        end
      end
      else begin
        Drg <= Dnext;
        if (Rrg[9] == 1) begin
          KrgX   <= Krg;
          Dvldrg <= 1;
          BSYrg  <= 0;
        end
        else begin
          Rrg    <= {Rrg[0], Rrg[9:1]};
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
module AES_Comp_ENCx(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY, Kvld, Dvld);
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

  AES_Comp_EncCore EC (Drg, KrgX, Rrg, Dnext, Knext);

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


/////////////////////////////
//   AES for decryption    //
//   with output register  //
/////////////////////////////

module AES_Comp_DECx(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY, Kvld, Dvld);
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

  AES_Comp_DecCore DC (Drg, KrgX, Rrg, ~Kvldrg, Dnext, Knext);

  assign Kvld = Kvldrg;
  assign Dvld = Dvldrg;
  assign Dout = DrgX;
  assign BSY  = BSYrg;

  always @(posedge CLK) begin
    if (RSTn == 0) begin
      Krg     <= 128'h0000000000000000;
      KrgX    <= 128'h0000000000000000;
      Kvldrg  <= 0;
      Dvldrg  <= 0;
      BSYrg   <= 0;
    end
    else if (EN == 1) begin
      if (BSYrg == 0) begin
        if (Krdy == 1) begin
          KrgX   <= Kin;
          Rrg    <= 10'b0000000001;
          Kvldrg <= 0;
          Dvldrg <= 0;
          BSYrg  <= 1;
        end
        else if ((Kvldrg == 1) && (Drdy == 1)) begin
          KrgX   <= Knext;
          Drg    <= Din ^ Krg;
          Rrg    <= {Rrg[0], Rrg[9:1]};
          Dvldrg <= 0;
          BSYrg  <= 1;
        end
      end
      else if (Kvldrg == 0) begin    // initial key generation
        if (Rrg == 10'b0000000000) begin
          Rrg    <= 10'b1000000000;
          Krg    <= KrgX;
          Kvldrg <= 1;
          BSYrg  <= 0;
        end
        else begin
          Rrg    <= {Rrg[8:0], 1'b0};
          KrgX   <= Knext;
        end
      end
      else begin
        if (Rrg[9] == 1) begin
          KrgX   <= Krg;
          DrgX   <= Dnext;
          Dvldrg <= 1;
          BSYrg  <= 0;
        end
        else begin
          Rrg    <= {Rrg[0], Rrg[9:1]};
          KrgX   <= Knext;
          Drg    <= Dnext; 
        end
      end
    end
  end
endmodule


module AES_Comp_DECy(Kin, Din, Dout, Krdy, Drdy, RSTn, EN, CLK, BSY, Dvld);
  input  [127:0] Kin;  // Key input
  input  [127:0] Din;  // Data input
  output [127:0] Dout; // Data output
  input  Krdy;         // Key input ready
  input  Drdy;         // Data input ready
  input  RSTn;         // Reset (Low active)
  input  EN;           // AES circuit enable
  input  CLK;          // System clock
  output BSY;          // Busy signal
  output Dvld;         // Data output valid

  reg  [127:0] Drg;    // Data register
  reg  [127:0] DrgX;   // Data output regsiter
  reg  [127:0] Krg;    // Key register
  reg  [127:0] KrgX;   // Temporary key Register
  reg  [9:0]   Rrg;    // Round counter
  reg  Dvldrg, BSYrg;
  wire [127:0] Dnext, Knext;

  AES_Comp_DecCore DC (Drg, KrgX, Rrg, Dnext, Knext);

  assign Dvld = Dvldrg;
  assign Dout = DrgX;
  assign BSY  = BSYrg;

  always @(posedge CLK) begin
    if (RSTn == 0) begin
      Rrg    <= 10'b1000000000;
      Dvldrg <= 0;
      BSYrg  <= 0;
    end
    else if (EN == 1) begin
      if (BSYrg == 0) begin
        if (Krdy == 1) begin
          Krg    <= Kin;
          KrgX   <= Kin;
          Dvldrg <= 0;
        end
        else if (Drdy == 1) begin
          Rrg    <= {Rrg[0], Rrg[9:1]};
          KrgX   <= Knext;
          Drg    <= Din ^ Krg;
          Dvldrg <= 0;
          BSYrg  <= 1;
        end
      end
      else begin
        if (Rrg[9] == 1) begin
          KrgX   <= Krg;
          DrgX   <= Dnext;
          Dvldrg <= 1;
          BSYrg  <= 0;
        end
        else begin
          Rrg    <= {Rrg[0], Rrg[9:1]};
          KrgX   <= Knext;
          Drg    <= Dnext; 
        end
      end
    end
  end
endmodule
