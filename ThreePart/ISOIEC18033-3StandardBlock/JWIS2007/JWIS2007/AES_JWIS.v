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
//        SubBytes         //
/////////////////////////////
module SubBytes (x, y);
  input  [31:0] x;
  output [31:0] y;

  function [7:0] S;
  input    [7:0] x;
    case (x)
        0:S= 99;   1:S=124;   2:S=119;   3:S=123;   4:S=242;   5:S=107;   6:S=111;   7:S=197;
        8:S= 48;   9:S=  1;  10:S=103;  11:S= 43;  12:S=254;  13:S=215;  14:S=171;  15:S=118;
       16:S=202;  17:S=130;  18:S=201;  19:S=125;  20:S=250;  21:S= 89;  22:S= 71;  23:S=240;
       24:S=173;  25:S=212;  26:S=162;  27:S=175;  28:S=156;  29:S=164;  30:S=114;  31:S=192;
       32:S=183;  33:S=253;  34:S=147;  35:S= 38;  36:S= 54;  37:S= 63;  38:S=247;  39:S=204;
       40:S= 52;  41:S=165;  42:S=229;  43:S=241;  44:S=113;  45:S=216;  46:S= 49;  47:S= 21;
       48:S=  4;  49:S=199;  50:S= 35;  51:S=195;  52:S= 24;  53:S=150;  54:S=  5;  55:S=154;
       56:S=  7;  57:S= 18;  58:S=128;  59:S=226;  60:S=235;  61:S= 39;  62:S=178;  63:S=117;
       64:S=  9;  65:S=131;  66:S= 44;  67:S= 26;  68:S= 27;  69:S=110;  70:S= 90;  71:S=160;
       72:S= 82;  73:S= 59;  74:S=214;  75:S=179;  76:S= 41;  77:S=227;  78:S= 47;  79:S=132;
       80:S= 83;  81:S=209;  82:S=  0;  83:S=237;  84:S= 32;  85:S=252;  86:S=177;  87:S= 91;
       88:S=106;  89:S=203;  90:S=190;  91:S= 57;  92:S= 74;  93:S= 76;  94:S= 88;  95:S=207;
       96:S=208;  97:S=239;  98:S=170;  99:S=251; 100:S= 67; 101:S= 77; 102:S= 51; 103:S=133;
      104:S= 69; 105:S=249; 106:S=  2; 107:S=127; 108:S= 80; 109:S= 60; 110:S=159; 111:S=168;
      112:S= 81; 113:S=163; 114:S= 64; 115:S=143; 116:S=146; 117:S=157; 118:S= 56; 119:S=245;
      120:S=188; 121:S=182; 122:S=218; 123:S= 33; 124:S= 16; 125:S=255; 126:S=243; 127:S=210;
      128:S=205; 129:S= 12; 130:S= 19; 131:S=236; 132:S= 95; 133:S=151; 134:S= 68; 135:S= 23;
      136:S=196; 137:S=167; 138:S=126; 139:S= 61; 140:S=100; 141:S= 93; 142:S= 25; 143:S=115;
      144:S= 96; 145:S=129; 146:S= 79; 147:S=220; 148:S= 34; 149:S= 42; 150:S=144; 151:S=136;
      152:S= 70; 153:S=238; 154:S=184; 155:S= 20; 156:S=222; 157:S= 94; 158:S= 11; 159:S=219;
      160:S=224; 161:S= 50; 162:S= 58; 163:S= 10; 164:S= 73; 165:S=  6; 166:S= 36; 167:S= 92;
      168:S=194; 169:S=211; 170:S=172; 171:S= 98; 172:S=145; 173:S=149; 174:S=228; 175:S=121;
      176:S=231; 177:S=200; 178:S= 55; 179:S=109; 180:S=141; 181:S=213; 182:S= 78; 183:S=169;
      184:S=108; 185:S= 86; 186:S=244; 187:S=234; 188:S=101; 189:S=122; 190:S=174; 191:S=  8;
      192:S=186; 193:S=120; 194:S= 37; 195:S= 46; 196:S= 28; 197:S=166; 198:S=180; 199:S=198;
      200:S=232; 201:S=221; 202:S=116; 203:S= 31; 204:S= 75; 205:S=189; 206:S=139; 207:S=138;
      208:S=112; 209:S= 62; 210:S=181; 211:S=102; 212:S= 72; 213:S=  3; 214:S=246; 215:S= 14;
      216:S= 97; 217:S= 53; 218:S= 87; 219:S=185; 220:S=134; 221:S=193; 222:S= 29; 223:S=158;
      224:S=225; 225:S=248; 226:S=152; 227:S= 17; 228:S=105; 229:S=217; 230:S=142; 231:S=148;
      232:S=155; 233:S= 30; 234:S=135; 235:S=233; 236:S=206; 237:S= 85; 238:S= 40; 239:S=223;
      240:S=140; 241:S=161; 242:S=137; 243:S= 13; 244:S=191; 245:S=230; 246:S= 66; 247:S=104;
      248:S= 65; 249:S=153; 250:S= 45; 251:S= 15; 252:S=176; 253:S= 84; 254:S=187; 255:S= 22;
    endcase
  endfunction

  assign y = {S(x[31:24]), S(x[23:16]), S(x[15: 8]), S(x[ 7: 0])};
endmodule


/////////////////////////////
//      InvSubBytes        //
/////////////////////////////
module InvSubBytes (x, y);
  input  [31:0] x;
  output [31:0] y;

  function [7:0] S;
  input    [7:0] x;
    case (x)
        0:S= 82;   1:S=  9;   2:S=106;   3:S=213;   4:S= 48;   5:S= 54;   6:S=165;   7:S= 56;
        8:S=191;   9:S= 64;  10:S=163;  11:S=158;  12:S=129;  13:S=243;  14:S=215;  15:S=251;
       16:S=124;  17:S=227;  18:S= 57;  19:S=130;  20:S=155;  21:S= 47;  22:S=255;  23:S=135;
       24:S= 52;  25:S=142;  26:S= 67;  27:S= 68;  28:S=196;  29:S=222;  30:S=233;  31:S=203;
       32:S= 84;  33:S=123;  34:S=148;  35:S= 50;  36:S=166;  37:S=194;  38:S= 35;  39:S= 61;
       40:S=238;  41:S= 76;  42:S=149;  43:S= 11;  44:S= 66;  45:S=250;  46:S=195;  47:S= 78;
       48:S=  8;  49:S= 46;  50:S=161;  51:S=102;  52:S= 40;  53:S=217;  54:S= 36;  55:S=178;
       56:S=118;  57:S= 91;  58:S=162;  59:S= 73;  60:S=109;  61:S=139;  62:S=209;  63:S= 37;
       64:S=114;  65:S=248;  66:S=246;  67:S=100;  68:S=134;  69:S=104;  70:S=152;  71:S= 22;
       72:S=212;  73:S=164;  74:S= 92;  75:S=204;  76:S= 93;  77:S=101;  78:S=182;  79:S=146;
       80:S=108;  81:S=112;  82:S= 72;  83:S= 80;  84:S=253;  85:S=237;  86:S=185;  87:S=218;
       88:S= 94;  89:S= 21;  90:S= 70;  91:S= 87;  92:S=167;  93:S=141;  94:S=157;  95:S=132;
       96:S=144;  97:S=216;  98:S=171;  99:S=  0; 100:S=140; 101:S=188; 102:S=211; 103:S= 10;
      104:S=247; 105:S=228; 106:S= 88; 107:S=  5; 108:S=184; 109:S=179; 110:S= 69; 111:S=  6;
      112:S=208; 113:S= 44; 114:S= 30; 115:S=143; 116:S=202; 117:S= 63; 118:S= 15; 119:S=  2;
      120:S=193; 121:S=175; 122:S=189; 123:S=  3; 124:S=  1; 125:S= 19; 126:S=138; 127:S=107;
      128:S= 58; 129:S=145; 130:S= 17; 131:S= 65; 132:S= 79; 133:S=103; 134:S=220; 135:S=234;
      136:S=151; 137:S=242; 138:S=207; 139:S=206; 140:S=240; 141:S=180; 142:S=230; 143:S=115;
      144:S=150; 145:S=172; 146:S=116; 147:S= 34; 148:S=231; 149:S=173; 150:S= 53; 151:S=133;
      152:S=226; 153:S=249; 154:S= 55; 155:S=232; 156:S= 28; 157:S=117; 158:S=223; 159:S=110;
      160:S= 71; 161:S=241; 162:S= 26; 163:S=113; 164:S= 29; 165:S= 41; 166:S=197; 167:S=137;
      168:S=111; 169:S=183; 170:S= 98; 171:S= 14; 172:S=170; 173:S= 24; 174:S=190; 175:S= 27;
      176:S=252; 177:S= 86; 178:S= 62; 179:S= 75; 180:S=198; 181:S=210; 182:S=121; 183:S= 32;
      184:S=154; 185:S=219; 186:S=192; 187:S=254; 188:S=120; 189:S=205; 190:S= 90; 191:S=244;
      192:S= 31; 193:S=221; 194:S=168; 195:S= 51; 196:S=136; 197:S=  7; 198:S=199; 199:S= 49;
      200:S=177; 201:S= 18; 202:S= 16; 203:S= 89; 204:S= 39; 205:S=128; 206:S=236; 207:S= 95;
      208:S= 96; 209:S= 81; 210:S=127; 211:S=169; 212:S= 25; 213:S=181; 214:S= 74; 215:S= 13;
      216:S= 45; 217:S=229; 218:S=122; 219:S=159; 220:S=147; 221:S=201; 222:S=156; 223:S=239;
      224:S=160; 225:S=224; 226:S= 59; 227:S= 77; 228:S=174; 229:S= 42; 230:S=245; 231:S=176;
      232:S=200; 233:S=235; 234:S=187; 235:S= 60; 236:S=131; 237:S= 83; 238:S=153; 239:S= 97;
      240:S= 23; 241:S= 43; 242:S=  4; 243:S=126; 244:S=186; 245:S=119; 246:S=214; 247:S= 38;
      248:S=225; 249:S=105; 250:S= 20; 251:S= 99; 252:S= 85; 253:S= 33; 254:S= 12; 255:S=125; 
    endcase
  endfunction

  assign y = {S(x[31:24]), S(x[23:16]), S(x[15: 8]), S(x[ 7: 0])};
endmodule


/////////////////////////////
//       MixColumns        //
/////////////////////////////
module MixColumns(x, y);
  input  [31:0]  x;
  output [31:0]  y;

  wire [7:0] a3, a2, a1, a0, b3, b2, b1, b0;

  assign a3 = x[31:24];
  assign a2 = x[23:16];
  assign a1 = x[15: 8];
  assign a0 = x[ 7: 0];

  assign b3 = a3 ^ a2;
  assign b2 = a2 ^ a1;
  assign b1 = a1 ^ a0;
  assign b0 = a0 ^ a3;

  assign y = {a2[7] ^ b1[7] ^ b3[6],
              a2[6] ^ b1[6] ^ b3[5],
              a2[5] ^ b1[5] ^ b3[4],
              a2[4] ^ b1[4] ^ b3[3] ^ b3[7],
              a2[3] ^ b1[3] ^ b3[2] ^ b3[7],
              a2[2] ^ b1[2] ^ b3[1],
              a2[1] ^ b1[1] ^ b3[0] ^ b3[7],
              a2[0] ^ b1[0] ^ b3[7],
              a3[7] ^ b1[7] ^ b2[6],
              a3[6] ^ b1[6] ^ b2[5],
              a3[5] ^ b1[5] ^ b2[4],
              a3[4] ^ b1[4] ^ b2[3] ^ b2[7],
              a3[3] ^ b1[3] ^ b2[2] ^ b2[7],
              a3[2] ^ b1[2] ^ b2[1],
              a3[1] ^ b1[1] ^ b2[0] ^ b2[7],
              a3[0] ^ b1[0] ^ b2[7],
              a0[7] ^ b3[7] ^ b1[6],
              a0[6] ^ b3[6] ^ b1[5],
              a0[5] ^ b3[5] ^ b1[4],
              a0[4] ^ b3[4] ^ b1[3] ^ b1[7],
              a0[3] ^ b3[3] ^ b1[2] ^ b1[7],
              a0[2] ^ b3[2] ^ b1[1],
              a0[1] ^ b3[1] ^ b1[0] ^ b1[7],
              a0[0] ^ b3[0] ^ b1[7],
              a1[7] ^ b3[7] ^ b0[6],
              a1[6] ^ b3[6] ^ b0[5],
              a1[5] ^ b3[5] ^ b0[4],
              a1[4] ^ b3[4] ^ b0[3] ^ b0[7],
              a1[3] ^ b3[3] ^ b0[2] ^ b0[7],
              a1[2] ^ b3[2] ^ b0[1],
              a1[1] ^ b3[1] ^ b0[0] ^ b0[7],
              a1[0] ^ b3[0] ^ b0[7]};
endmodule


/////////////////////////////
//     InvMixColumns       //
/////////////////////////////
module InvMixColumns(x, y);
  input  [31:0]  x;
  output [31:0]  y;

  wire [7:0] a3, a2, a1, a0, b3, b2, b1, b0;
  wire [7:0] c3, c2, c1, c0, d3, d2, d1, d0;

  assign a3 = x[31:24];
  assign a2 = x[23:16];
  assign a1 = x[15: 8];
  assign a0 = x[ 7: 0];

  assign b3 = a3 ^ a2;
  assign b2 = a2 ^ a1;
  assign b1 = a1 ^ a0;
  assign b0 = a0 ^ a3;

  assign c3 = {a2[7] ^ b1[7] ^ b3[6],
               a2[6] ^ b1[6] ^ b3[5],
               a2[5] ^ b1[5] ^ b3[4],
               a2[4] ^ b1[4] ^ b3[3] ^ b3[7],
               a2[3] ^ b1[3] ^ b3[2] ^ b3[7],
               a2[2] ^ b1[2] ^ b3[1],
               a2[1] ^ b1[1] ^ b3[0] ^ b3[7],
               a2[0] ^ b1[0] ^ b3[7]};
  assign c2 = {a3[7] ^ b1[7] ^ b2[6],
               a3[6] ^ b1[6] ^ b2[5],
               a3[5] ^ b1[5] ^ b2[4],
               a3[4] ^ b1[4] ^ b2[3] ^ b2[7],
               a3[3] ^ b1[3] ^ b2[2] ^ b2[7],
               a3[2] ^ b1[2] ^ b2[1],
               a3[1] ^ b1[1] ^ b2[0] ^ b2[7],
               a3[0] ^ b1[0] ^ b2[7]};
  assign c1 = {a0[7] ^ b3[7] ^ b1[6],
               a0[6] ^ b3[6] ^ b1[5],
               a0[5] ^ b3[5] ^ b1[4],
               a0[4] ^ b3[4] ^ b1[3] ^ b1[7],
               a0[3] ^ b3[3] ^ b1[2] ^ b1[7],
               a0[2] ^ b3[2] ^ b1[1],
               a0[1] ^ b3[1] ^ b1[0] ^ b1[7],
               a0[0] ^ b3[0] ^ b1[7]};
  assign c0 = {a1[7] ^ b3[7] ^ b0[6],
               a1[6] ^ b3[6] ^ b0[5],
               a1[5] ^ b3[5] ^ b0[4],
               a1[4] ^ b3[4] ^ b0[3] ^ b0[7],
               a1[3] ^ b3[3] ^ b0[2] ^ b0[7],
               a1[2] ^ b3[2] ^ b0[1],
               a1[1] ^ b3[1] ^ b0[0] ^ b0[7],
               a1[0] ^ b3[0] ^ b0[7]};
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

  SubBytes SB3 (di[127:96], se[127:96]);
  SubBytes SB2 (di[ 95:64], se[ 95:64]);
  SubBytes SB1 (di[ 63:32], se[ 63:32]);
  SubBytes SB0 (di[ 31: 0], se[ 31: 0]);

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

  InvSubBytes ISB3 (isr[127:96], sd[127:96]);
  InvSubBytes ISB2 (isr[ 95:64], sd[ 95:64]);
  InvSubBytes ISB1 (isr[ 63:32], sd[ 63:32]);
  InvSubBytes ISB0 (isr[ 31: 0], sd[ 31: 0]);

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
  SubBytes SBK ({sbkin[23:16], sbkin[15:8], sbkin[7:0], sbkin[31:24]}, so);

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
