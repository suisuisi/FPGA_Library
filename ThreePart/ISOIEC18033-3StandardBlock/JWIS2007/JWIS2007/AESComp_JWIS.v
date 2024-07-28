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


/////////////////////////////
//   GF(2^2^2^2) inverter  //
/////////////////////////////
module GFinvComp(x, y);
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
module SboxComp(x, y);
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

  GFinvComp GFinvComp(a, b);

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
module InvSboxComp(x, y);
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

  GFinvComp GFinvComp(a, b);

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
module SubBytesComp (x, y);
  input  [31:0] x;
  output [31:0] y;

  SboxComp Sbox3(x[31:24], y[31:24]);
  SboxComp Sbox2(x[23:16], y[23:16]);
  SboxComp Sbox1(x[15: 8], y[15: 8]);
  SboxComp Sbox0(x[ 7: 0], y[ 7: 0]);
endmodule


/////////////////////////////
// InvSubBytes GF(2^2^2^2) //
/////////////////////////////
module InvSubBytesComp (x, y);
  input  [31:0] x;
  output [31:0] y;

  InvSboxComp Sbox3(x[31:24], y[31:24]);
  InvSboxComp Sbox2(x[23:16], y[23:16]);
  InvSboxComp Sbox1(x[15: 8], y[15: 8]);
  InvSboxComp Sbox0(x[ 7: 0], y[ 7: 0]);
endmodule


/////////////////////////////
//       MixColumns        //
/////////////////////////////
module MixColumns(x, y);
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
module InvMixColumns(x, y);
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


////////////////////////////////
// Encryotion/Decryption Core //
////////////////////////////////
module CORE(di, ki, Rrg, EncDec, do, ko);
  input  [127:0] di;
  input  [127:0] ki;
  input  [9:0]   Rrg;
  input  EncDec;
  output [127:0] do;
  output [127:0] ko;

  wire   [127:0] se, sd, sr, isr, mx, imx, dx;
  wire   [31:0]  sbkin, so, kix;

//------------ encryption

  SubBytesComp SB3 (di[127:96], se[127:96]);
  SubBytesComp SB2 (di[ 95:64], se[ 95:64]);
  SubBytesComp SB1 (di[ 63:32], se[ 63:32]);
  SubBytesComp SB0 (di[ 31: 0], se[ 31: 0]);

  assign sr = {se[127:120], se[ 87: 80], se[ 47: 40], se[  7:  0],
               se[ 95: 88], se[ 55: 48], se[ 15:  8], se[103: 96],
               se[ 63: 56], se[ 23: 16], se[111:104], se[ 71: 64],
               se[ 31: 24], se[119:112], se[ 79: 72], se[ 39: 32]};

  MixColumns MX3 (sr[127:96], mx[127:96]);
  MixColumns MX2 (sr[ 95:64], mx[ 95:64]);
  MixColumns MX1 (sr[ 63:32], mx[ 63:32]);
  MixColumns MX0 (sr[ 31: 0], mx[ 31: 0]);

//------------ decryption

  InvMixColumns IMX3 (di[127:96], imx[127:96]);
  InvMixColumns IMX2 (di[ 95:64], imx[ 95:64]);
  InvMixColumns IMX1 (di[ 63:32], imx[ 63:32]);
  InvMixColumns IMX0 (di[ 31: 0], imx[ 31: 0]);

  assign dx  = (Rrg[8] == 1)? di: imx;
  assign isr = {dx[127:120], dx[ 23: 16], dx[ 47: 40], dx[ 71: 64],
                dx[ 95: 88], dx[119:112], dx[ 15:  8], dx[ 39: 32],
                dx[ 63: 56], dx[ 87: 80], dx[111:104], dx[  7:  0],
                dx[ 31: 24], dx[ 55: 48], dx[ 79: 72], dx[103: 96]};

  InvSubBytesComp ISB3 (isr[127:96], sd[127:96]);
  InvSubBytesComp ISB2 (isr[ 95:64], sd[ 95:64]);
  InvSubBytesComp ISB1 (isr[ 63:32], sd[ 63:32]);
  InvSubBytesComp ISB0 (isr[ 31: 0], sd[ 31: 0]);

  assign do = ((EncDec ==0)? ((Rrg[0] == 1)? sr: mx): sd) ^ ki;

//------------ key scheduling

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

  assign kix = ki[31:0] ^ ki[63:32];
  assign sbkin = (EncDec == 0)? ki[31:0]: kix;
  SubBytesComp SBK ({sbkin[23:16], sbkin[15:8], sbkin[7:0], sbkin[31:24]}, so);

  assign ko[127:96] = ki[127:96] ^ {so[31:24] ^ rcon(Rrg), so[23: 0]};
  assign ko[ 95:64] = ki[ 95:64] ^ ((EncDec == 0)? ko[127:96]: ki[127:96]);
  assign ko[ 63:32] = ki[ 63:32] ^ ((EncDec == 0)? ko[ 95:64]: ki[ 95:64]);
  assign ko[ 31: 0] = (EncDec == 0)? ki[ 31: 0] ^ ko[ 63:32]: kix;
endmodule


/////////////////////////////
//      AES main body      //
/////////////////////////////
module AES(Din, Key, Dout, Drdy, Krdy, EncDec, RSTn, EN, CLK, BSY, Dvld);
  input  [127:0] Din;  // Data input
  input  [127:0] Key;  // Key input
  output [127:0] Dout; // Data output
  input  Drdy;         // Data input ready
  input  Krdy;         // Key input ready
  input  EncDec;       // 0:Encryption 1:Decryption
  input  RSTn;         // Reset (Low active)
  input  EN;           // AES circuit enable
  input  CLK;          // System clock
  output BSY;          // Busy signal
  output Dvld;         // Data output valid

  reg  [127:0] Drg;    // Data register
  reg  [127:0] Krg;    // Key register
  reg  [127:0] KrgX;   // Temporary key Register
  reg  [9:0]   Rrg;    // Round counter
  reg  Dvldrg, BSYrg;
  wire [127:0] Dnext, Knext;

  CORE CORE(Drg, KrgX, Rrg, EncDec, Dnext, Knext);

  assign Dvld = Dvldrg;
  assign Dout = Drg;
  assign BSY  = BSYrg;

  always @(posedge CLK) begin
    if (RSTn == 0) begin
      Rrg    <= (EncDec == 0)? 10'b0000000001: 10'b1000000000;
      Dvldrg <= 0;
      BSYrg  <= 0;
    end
    else if (EN == 1) begin
      if (BSYrg == 0) begin
        if (Krdy == 1) begin
          Krg    <= Key;
          KrgX   <= Key;
          Dvldrg <= 0;
        end
        else if (Drdy == 1) begin
          Rrg <= (EncDec == 0)? {Rrg[8:0], Rrg[9]}: {Rrg[0], Rrg[9:1]};
          KrgX   <= Knext;
          Drg    <= Din ^ Krg;
          Dvldrg <= 0;
          BSYrg  <= 1;
        end
      end

      else begin
        Drg <= Dnext;
        if ((EncDec == 0 && Rrg[0] == 1) || (EncDec == 1 && Rrg[9] == 1)) begin
          KrgX   <= Krg;
          Dvldrg <= 1;
          BSYrg  <= 0;
        end
        else begin
          Rrg    <= (EncDec == 0)? {Rrg[8:0], Rrg[9]}: {Rrg[0], Rrg[9:1]};
          KrgX   <= Knext;
        end
      end
    end
  end
endmodule
