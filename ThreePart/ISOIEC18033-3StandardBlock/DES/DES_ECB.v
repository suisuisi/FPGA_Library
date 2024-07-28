/*-------------------------------------------------------------------------
 DES Encryption/Decryption Macro (ASIC version)
                                   
 File name   : DES_ECB.v
 Version     : Version 1.0
 Created     : 
 Last update : SEP/24/2007
 Desgined by : Akashi Satoh
 Modified by : Takeshi Sugawara
 
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
//   S-Box & Permutation   //
/////////////////////////////
module SP(S, P);
  input  [1:48] S;
  output [1:32] P;

  reg [1:4] x1, x2, x3, x4, x5, x6, x7, x8;

  assign P = {x4[4], x2[3], x5[4], x6[1], x8[1], x3[4], x7[4], x5[1],
              x1[1], x4[3], x6[3], x7[2], x2[1], x5[2], x8[3], x3[2],
              x1[2], x2[4], x6[4], x4[2], x8[4], x7[3], x1[3], x3[1],
              x5[3], x4[1], x8[2], x2[2], x6[2], x3[3], x1[4], x7[1]};

  always @(S[1:6]) begin
    case ({S[1], S[6], S[ 2: 5]})
      0: x1 = 14;   1: x1 =  4;   2: x1 = 13;   3: x1 =  1;
      4: x1 =  2;   5: x1 = 15;   6: x1 = 11;   7: x1 =  8;
      8: x1 =  3;   9: x1 = 10;  10: x1 =  6;  11: x1 = 12;
     12: x1 =  5;  13: x1 =  9;  14: x1 =  0;  15: x1 =  7;
     16: x1 =  0;  17: x1 = 15;  18: x1 =  7;  19: x1 =  4;
     20: x1 = 14;  21: x1 =  2;  22: x1 = 13;  23: x1 =  1;
     24: x1 = 10;  25: x1 =  6;  26: x1 = 12;  27: x1 = 11;
     28: x1 =  9;  29: x1 =  5;  30: x1 =  3;  31: x1 =  8;
     32: x1 =  4;  33: x1 =  1;  34: x1 = 14;  35: x1 =  8;
     36: x1 = 13;  37: x1 =  6;  38: x1 =  2;  39: x1 = 11;
     40: x1 = 15;  41: x1 = 12;  42: x1 =  9;  43: x1 =  7;
     44: x1 =  3;  45: x1 = 10;  46: x1 =  5;  47: x1 =  0;
     48: x1 = 15;  49: x1 = 12;  50: x1 =  8;  51: x1 =  2;
     52: x1 =  4;  53: x1 =  9;  54: x1 =  1;  55: x1 =  7;
     56: x1 =  5;  57: x1 = 11;  58: x1 =  3;  59: x1 = 14;
     60: x1 = 10;  61: x1 =  0;  62: x1 =  6;  63: x1 = 13;
    endcase
  end

  always @(S[7:12]) begin
    case ({S[7], S[12], S[ 8:11]})
       0: x2 = 15;   1: x2 =  1;   2: x2 =  8;   3: x2 = 14;
       4: x2 =  6;   5: x2 = 11;   6: x2 =  3;   7: x2 =  4;
       8: x2 =  9;   9: x2 =  7;  10: x2 =  2;  11: x2 = 13;
      12: x2 = 12;  13: x2 =  0;  14: x2 =  5;  15: x2 = 10;
      16: x2 =  3;  17: x2 = 13;  18: x2 =  4;  19: x2 =  7;
      20: x2 = 15;  21: x2 =  2;  22: x2 =  8;  23: x2 = 14;
      24: x2 = 12;  25: x2 =  0;  26: x2 =  1;  27: x2 = 10;
      28: x2 =  6;  29: x2 =  9;  30: x2 = 11;  31: x2 =  5;
      32: x2 =  0;  33: x2 = 14;  34: x2 =  7;  35: x2 = 11;
      36: x2 = 10;  37: x2 =  4;  38: x2 = 13;  39: x2 =  1;
      40: x2 =  5;  41: x2 =  8;  42: x2 = 12;  43: x2 =  6;
      44: x2 =  9;  45: x2 =  3;  46: x2 =  2;  47: x2 = 15;
      48: x2 = 13;  49: x2 =  8;  50: x2 = 10;  51: x2 =  1;
      52: x2 =  3;  53: x2 = 15;  54: x2 =  4;  55: x2 =  2;
      56: x2 = 11;  57: x2 =  6;  58: x2 =  7;  59: x2 = 12;
      60: x2 =  0;  61: x2 =  5;  62: x2 = 14;  63: x2 =  9;
    endcase
  end

  always @(S[13:18]) begin
    case ({S[13], S[18], S[14:17]})
       0: x3 = 10;   1: x3 =  0;   2: x3 =  9;   3: x3 = 14;
       4: x3 =  6;   5: x3 =  3;   6: x3 = 15;   7: x3 =  5;
       8: x3 =  1;   9: x3 = 13;  10: x3 = 12;  11: x3 =  7;
      12: x3 = 11;  13: x3 =  4;  14: x3 =  2;  15: x3 =  8;
      16: x3 = 13;  17: x3 =  7;  18: x3 =  0;  19: x3 =  9;
      20: x3 =  3;  21: x3 =  4;  22: x3 =  6;  23: x3 = 10;
      24: x3 =  2;  25: x3 =  8;  26: x3 =  5;  27: x3 = 14;
      28: x3 = 12;  29: x3 = 11;  30: x3 = 15;  31: x3 =  1;
      32: x3 = 13;  33: x3 =  6;  34: x3 =  4;  35: x3 =  9;
      36: x3 =  8;  37: x3 = 15;  38: x3 =  3;  39: x3 =  0;
      40: x3 = 11;  41: x3 =  1;  42: x3 =  2;  43: x3 = 12;
      44: x3 =  5;  45: x3 = 10;  46: x3 = 14;  47: x3 =  7;
      48: x3 =  1;  49: x3 = 10;  50: x3 = 13;  51: x3 =  0;
      52: x3 =  6;  53: x3 =  9;  54: x3 =  8;  55: x3 =  7;
      56: x3 =  4;  57: x3 = 15;  58: x3 = 14;  59: x3 =  3;
      60: x3 = 11;  61: x3 =  5;  62: x3 =  2;  63: x3 = 12;
    endcase
  end

  always @(S[19:24]) begin
    case ({S[19], S[24], S[20:23]})
       0: x4 =  7;   1: x4 = 13;   2: x4 = 14;   3: x4 =  3;
       4: x4 =  0;   5: x4 =  6;   6: x4 =  9;   7: x4 = 10;
       8: x4 =  1;   9: x4 =  2;  10: x4 =  8;  11: x4 =  5;
      12: x4 = 11;  13: x4 = 12;  14: x4 =  4;  15: x4 = 15;
      16: x4 = 13;  17: x4 =  8;  18: x4 = 11;  19: x4 =  5;
      20: x4 =  6;  21: x4 = 15;  22: x4 =  0;  23: x4 =  3;
      24: x4 =  4;  25: x4 =  7;  26: x4 =  2;  27: x4 = 12;
      28: x4 =  1;  29: x4 = 10;  30: x4 = 14;  31: x4 =  9;
      32: x4 = 10;  33: x4 =  6;  34: x4 =  9;  35: x4 =  0;
      36: x4 = 12;  37: x4 = 11;  38: x4 =  7;  39: x4 = 13;
      40: x4 = 15;  41: x4 =  1;  42: x4 =  3;  43: x4 = 14;
      44: x4 =  5;  45: x4 =  2;  46: x4 =  8;  47: x4 =  4;
      48: x4 =  3;  49: x4 = 15;  50: x4 =  0;  51: x4 =  6;
      52: x4 = 10;  53: x4 =  1;  54: x4 = 13;  55: x4 =  8;
      56: x4 =  9;  57: x4 =  4;  58: x4 =  5;  59: x4 = 11;
      60: x4 = 12;  61: x4 =  7;  62: x4 =  2;  63: x4 = 14;
    endcase
  end

  always @(S[25:30]) begin
    case ({S[25], S[30], S[26:29]})
       0: x5 =  2;   1: x5 = 12;   2: x5 =  4;   3: x5 =  1;
       4: x5 =  7;   5: x5 = 10;   6: x5 = 11;   7: x5 =  6;
       8: x5 =  8;   9: x5 =  5;  10: x5 =  3;  11: x5 = 15;
      12: x5 = 13;  13: x5 =  0;  14: x5 = 14;  15: x5 =  9;
      16: x5 = 14;  17: x5 = 11;  18: x5 =  2;  19: x5 = 12;
      20: x5 =  4;  21: x5 =  7;  22: x5 = 13;  23: x5 =  1;
      24: x5 =  5;  25: x5 =  0;  26: x5 = 15;  27: x5 = 10;
      28: x5 =  3;  29: x5 =  9;  30: x5 =  8;  31: x5 =  6;
      32: x5 =  4;  33: x5 =  2;  34: x5 =  1;  35: x5 = 11;
      36: x5 = 10;  37: x5 = 13;  38: x5 =  7;  39: x5 =  8;
      40: x5 = 15;  41: x5 =  9;  42: x5 = 12;  43: x5 =  5;
      44: x5 =  6;  45: x5 =  3;  46: x5 =  0;  47: x5 = 14;
      48: x5 = 11;  49: x5 =  8;  50: x5 = 12;  51: x5 =  7;
      52: x5 =  1;  53: x5 = 14;  54: x5 =  2;  55: x5 = 13;
      56: x5 =  6;  57: x5 = 15;  58: x5 =  0;  59: x5 =  9;
      60: x5 = 10;  61: x5 =  4;  62: x5 =  5;  63: x5 =  3;
    endcase
  end

  always @(S[31:36]) begin
    case ({S[31], S[36], S[32:35]})
       0: x6 = 12;   1: x6 =  1;   2: x6 = 10;   3: x6 = 15;
       4: x6 =  9;   5: x6 =  2;   6: x6 =  6;   7: x6 =  8;
       8: x6 =  0;   9: x6 = 13;  10: x6 =  3;  11: x6 =  4;
      12: x6 = 14;  13: x6 =  7;  14: x6 =  5;  15: x6 = 11;
      16: x6 = 10;  17: x6 = 15;  18: x6 =  4;  19: x6 =  2;
      20: x6 =  7;  21: x6 = 12;  22: x6 =  9;  23: x6 =  5;
      24: x6 =  6;  25: x6 =  1;  26: x6 = 13;  27: x6 = 14;
      28: x6 =  0;  29: x6 = 11;  30: x6 =  3;  31: x6 =  8;
      32: x6 =  9;  33: x6 = 14;  34: x6 = 15;  35: x6 =  5;
      36: x6 =  2;  37: x6 =  8;  38: x6 = 12;  39: x6 =  3;
      40: x6 =  7;  41: x6 =  0;  42: x6 =  4;  43: x6 = 10;
      44: x6 =  1;  45: x6 = 13;  46: x6 = 11;  47: x6 =  6;
      48: x6 =  4;  49: x6 =  3;  50: x6 =  2;  51: x6 = 12;
      52: x6 =  9;  53: x6 =  5;  54: x6 = 15;  55: x6 = 10;
      56: x6 = 11;  57: x6 = 14;  58: x6 =  1;  59: x6 =  7;
      60: x6 =  6;  61: x6 =  0;  62: x6 =  8;  63: x6 = 13;
    endcase
  end

  always @(S[37:42]) begin
    case ({S[37], S[42], S[38:41]})
       0: x7 =  4;   1: x7 = 11;   2: x7 =  2;   3: x7 = 14;
       4: x7 = 15;   5: x7 =  0;   6: x7 =  8;   7: x7 = 13;
       8: x7 =  3;   9: x7 = 12;  10: x7 =  9;  11: x7 =  7;
      12: x7 =  5;  13: x7 = 10;  14: x7 =  6;  15: x7 =  1;
      16: x7 = 13;  17: x7 =  0;  18: x7 = 11;  19: x7 =  7;
      20: x7 =  4;  21: x7 =  9;  22: x7 =  1;  23: x7 = 10;
      24: x7 = 14;  25: x7 =  3;  26: x7 =  5;  27: x7 = 12;
      28: x7 =  2;  29: x7 = 15;  30: x7 =  8;  31: x7 =  6;
      32: x7 =  1;  33: x7 =  4;  34: x7 = 11;  35: x7 = 13;
      36: x7 = 12;  37: x7 =  3;  38: x7 =  7;  39: x7 = 14;
      40: x7 = 10;  41: x7 = 15;  42: x7 =  6;  43: x7 =  8;
      44: x7 =  0;  45: x7 =  5;  46: x7 =  9;  47: x7 =  2;
      48: x7 =  6;  49: x7 = 11;  50: x7 = 13;  51: x7 =  8;
      52: x7 =  1;  53: x7 =  4;  54: x7 = 10;  55: x7 =  7;
      56: x7 =  9;  57: x7 =  5;  58: x7 =  0;  59: x7 = 15;
      60: x7 = 14;  61: x7 =  2;  62: x7 =  3;  63: x7 = 12;
    endcase
  end

  always @(S[43:48]) begin
    case ({S[43], S[48], S[44:47]})
       0: x8 = 13;   1: x8 =  2;   2: x8 =  8;   3: x8 =  4;
       4: x8 =  6;   5: x8 = 15;   6: x8 = 11;   7: x8 =  1;
       8: x8 = 10;   9: x8 =  9;  10: x8 =  3;  11: x8 = 14;
      12: x8 =  5;  13: x8 =  0;  14: x8 = 12;  15: x8 =  7;
      16: x8 =  1;  17: x8 = 15;  18: x8 = 13;  19: x8 =  8;
      20: x8 = 10;  21: x8 =  3;  22: x8 =  7;  23: x8 =  4;
      24: x8 = 12;  25: x8 =  5;  26: x8 =  6;  27: x8 = 11;
      28: x8 =  0;  29: x8 = 14;  30: x8 =  9;  31: x8 =  2;
      32: x8 =  7;  33: x8 = 11;  34: x8 =  4;  35: x8 =  1;
      36: x8 =  9;  37: x8 = 12;  38: x8 = 14;  39: x8 =  2;
      40: x8 =  0;  41: x8 =  6;  42: x8 = 10;  43: x8 = 13;
      44: x8 = 15;  45: x8 =  3;  46: x8 =  5;  47: x8 =  8;
      48: x8 =  2;  49: x8 =  1;  50: x8 = 14;  51: x8 =  7;
      52: x8 =  4;  53: x8 = 10;  54: x8 =  8;  55: x8 = 13;
      56: x8 = 15;  57: x8 = 12;  58: x8 =  9;  59: x8 =  0;
      60: x8 =  3;  61: x8 =  5;  62: x8 =  6;  63: x8 = 11;
    endcase
  end
endmodule


/////////////////////////////
//         DES core        //
/////////////////////////////
module DES(Din, Key, Dout, Drdy, Krdy, ENC, RSTn, EN, CLK, BSY, Kvld, Dvld);
  input  [1:64] Din;  // Data input
  input  [1:64] Key;  // Key input
  output [1:64] Dout; // Data output
  input  Drdy;        // Data input ready
  input  Krdy;        // Key input ready
  input  ENC;         // 1 encryption, 0 decryption
  input  RSTn;        // Reset (Low active)
  input  EN;          // DES circuit enable
  input  CLK;         // System clock
  output BSY;         // Busy signal
  output Kvld;        // Key valid  
  output Dvld;        // Data output valid

  reg  [1:64] Drg;    // Data register
  reg  [1:56] Krg;    // Key Register
  reg  [1:16] Rrg;    // Round Register
  reg  BSYrg;         // 0 WAIT, 1 ROUND (busy)
  reg  Dvldrg;

  wire [1:64] IP;
  wire [1:56] PC1, PC2, Knext;
  wire [1:48] Kadd, Sin;
  wire [1:32] Pout;

  assign IP   = {Din[58], Din[50], Din[42], Din[34], Din[26], Din[18], Din[10], Din[2],
                 Din[60], Din[52], Din[44], Din[36], Din[28], Din[20], Din[12], Din[4],
                 Din[62], Din[54], Din[46], Din[38], Din[30], Din[22], Din[14], Din[6],
                 Din[64], Din[56], Din[48], Din[40], Din[32], Din[24], Din[16], Din[8],
                 Din[57], Din[49], Din[41], Din[33], Din[25], Din[17], Din[ 9], Din[1],
                 Din[59], Din[51], Din[43], Din[35], Din[27], Din[19], Din[11], Din[3],
                 Din[61], Din[53], Din[45], Din[37], Din[29], Din[21], Din[13], Din[5],
                 Din[63], Din[55], Din[47], Din[39], Din[31], Din[23], Din[15], Din[7]};

  assign Dout = {Drg[8], Drg[40], Drg[16], Drg[48], Drg[24], Drg[56], Drg[32], Drg[64],
                 Drg[7], Drg[39], Drg[15], Drg[47], Drg[23], Drg[55], Drg[31], Drg[63],
                 Drg[6], Drg[38], Drg[14], Drg[46], Drg[22], Drg[54], Drg[30], Drg[62],
                 Drg[5], Drg[37], Drg[13], Drg[45], Drg[21], Drg[53], Drg[29], Drg[61],
                 Drg[4], Drg[36], Drg[12], Drg[44], Drg[20], Drg[52], Drg[28], Drg[60],
                 Drg[3], Drg[35], Drg[11], Drg[43], Drg[19], Drg[51], Drg[27], Drg[59],
                 Drg[2], Drg[34], Drg[10], Drg[42], Drg[18], Drg[50], Drg[26], Drg[58],
                 Drg[1], Drg[33], Drg[ 9], Drg[41], Drg[17], Drg[49], Drg[25], Drg[57]};

  assign PC1  = {Key[57], Key[49], Key[41], Key[33], Key[25], Key[17], Key[ 9],
                 Key[ 1], Key[58], Key[50], Key[42], Key[34], Key[26], Key[18],
                 Key[10], Key[ 2], Key[59], Key[51], Key[43], Key[35], Key[27],
                 Key[19], Key[11], Key[ 3], Key[60], Key[52], Key[44], Key[36],
                 Key[63], Key[55], Key[47], Key[39], Key[31], Key[23], Key[15],
                 Key[ 7], Key[62], Key[54], Key[46], Key[38], Key[30], Key[22],
                 Key[14], Key[ 6], Key[61], Key[53], Key[45], Key[37], Key[29],
                 Key[21], Key[13], Key[ 5], Key[28], Key[20], Key[12], Key[ 4]};

  assign Knext = (ENC == 1)? 
                 (((Rrg[1] | Rrg[2] | Rrg[9] | Rrg[16]) == 1)?
                   {Krg[2:28], Krg[1], Krg[30:56], Krg[29]}:
                   {Krg[3:28], Krg[1:2], Krg[31:56], Krg[29:30]}):
                 (((Rrg[1] | Rrg[8] | Rrg[15] | Rrg[16]) == 1)?
                   {Krg[28], Krg[1:27], Krg[56], Krg[29:55]}:
                   {Krg[27:28], Krg[1:26], Krg[55:56], Krg[29:54]});

  assign PC2 = (ENC ==1)? Knext: Krg;
  assign Kadd = {PC2[14], PC2[17], PC2[11], PC2[24], PC2[ 1], PC2[ 5],
                 PC2[ 3], PC2[28], PC2[15], PC2[ 6], PC2[21], PC2[10],
                 PC2[23], PC2[19], PC2[12], PC2[ 4], PC2[26], PC2[ 8],
                 PC2[16], PC2[ 7], PC2[27], PC2[20], PC2[13], PC2[ 2],
                 PC2[41], PC2[52], PC2[31], PC2[37], PC2[47], PC2[55],
                 PC2[30], PC2[40], PC2[51], PC2[45], PC2[33], PC2[48],
                 PC2[44], PC2[49], PC2[39], PC2[56], PC2[34], PC2[53],
                 PC2[46], PC2[42], PC2[50], PC2[36], PC2[29], PC2[32]};

  assign Sin = {Drg[64], Drg[33:37], Drg[36:41], Drg[40:45], Drg[44:49],
                Drg[48:53], Drg[52:57], Drg[56:61], Drg[60:64], Drg[33]} ^ Kadd;
  SP SP (Sin, Pout);

  assign BSY = BSYrg;
  //assign Dvld = Dvldrg;

  reg Dvldrg2;
  reg Kvldrg;
  assign Dvld = ( (Dvldrg2 == 1'b0) && (Dvldrg == 1'b1) ) ? 1'b1 : 1'b0;
  assign Kvld = Kvldrg;

  // Behavior of Dvldrg2
  always @(posedge CLK) begin
    if (RSTn == 0)        Dvldrg2 <= 1'b0;
    else if (EN == 1) Dvldrg2 <= Dvldrg;
  end

  // Behavior of Kvldrg
  always @(posedge CLK) begin
    if (RSTn == 0)        Kvldrg <= 1'b0;
    else if (EN == 1)
      if( (Kvldrg == 1'b0) && (Krdy==1'b1) ) Kvldrg <= 1'b1;
      else                                   Kvldrg <= 1'b0;
  end

  always @(posedge CLK) begin
    if (RSTn == 0) begin
       Rrg    <= 16'b1000000000000000;
       BSYrg  <= 0;
       Dvldrg <= 0;
    end
    else if (EN == 1) begin
      if (BSYrg == 0) begin  // Idol
        if (Krdy == 1)
          Krg <= PC1;
        if (Drdy == 1) begin
          BSYrg  <= 1;
          Drg    <= IP;
          Dvldrg <= 0;
        end
      end
      else begin  // Round
        Drg <= {Drg[33:64], Drg[1:32] ^ Pout};
        Krg <= Knext;
        Rrg <= {Rrg[16], Rrg[1:15]};
        if (Rrg[16] == 1) begin
          BSYrg  <= 0;
          Dvldrg <= 1;
        end
      end
    end
  end
endmodule
