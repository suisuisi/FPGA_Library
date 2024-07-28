/*-------------------------------------------------------------------------
 SEED Encryption/Decryption Macro
 (One round / One clock version)
 
 File name   : SEED_1clk.v
 Version     : Version 1.0
 Created     : MAR/08/2007
 Last update : AUG/03/2007
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


// 暗号化，復号化の定義
`define ENCRYPT           1'b0
`define DECRYPT           1'b1

// 遷移状態の定義
`define ST_INITIAL   3'b111
`define ST_IDLE      3'b000
`define ST_KEY_SCHED 3'b001
`define ST_ENCRYPT   3'b010
`define ST_DECRYPT   3'b100

// 鍵スケジュールで利用する定数
`define KC0     32'h9E3779B9
`define KC1     32'h3C6EF373
`define KC2     32'h78DDE6E6
`define KC3     32'hF1BBCDCC
`define KC4     32'hE3779B99
`define KC5     32'hC6EF3733
`define KC6     32'h8DDE6E67
`define KC7     32'h1BBCDCCF
`define KC8     32'h3779B99E
`define KC9     32'h6EF3733C
`define KC10    32'hDDE6E678
`define KC11    32'hBBCDCCF1
`define KC12    32'h779B99E3
`define KC13    32'hEF3733C6
`define KC14    32'hDE6E678D
`define KC15    32'hBCDCCF1B

module top(// Outputs
	   data_out, data_valid, key_valid, busy,
	   // Inputs
	   clk, nreset, data_rdy, key_rdy, EncDec, data_in
	   );

  input clk, nreset;
  input data_rdy, key_rdy, EncDec;
  input [127:0] data_in;
  output [127:0] data_out;
  output 	 data_valid, key_valid, busy;

  reg [2:0] 	state_reg;
  reg [15:0] 	round_reg;

  wire [63:0] 	subkey;

  assign 	key_valid = ( (state_reg != `ST_INITIAL) || (state_reg != `ST_KEY_SCHED) );
  assign 	data_valid = ( ( (state_reg == `ST_ENCRYPT) || (state_reg == `ST_DECRYPT) )
			       && round_reg[15] == 1'b1 );
  assign 	busy = ( (state_reg != `ST_INITIAL) && (state_reg != `ST_IDLE) );
  
  key_sched key_sched(/*AUTOINST*/
		      // Outputs
		      .subkey		(subkey[63:0]),
		      // Inputs
		      .clk		(clk),
		      .nreset		(nreset),
		      .key_rdy		(key_rdy),
		      .data_rdy		(data_rdy),
		      .EncDec		(EncDec),
		      .data_in		(data_in[127:0]),
		      .state		(state_reg[2:0]),
		      .round		(round_reg[15:0]));

  randomize randomize(/*AUTOINST*/
		      // Outputs
		      .data_out		(data_out[127:0]),
		      // Inputs
		      .clk		(clk),
		      .nreset		(nreset),
		      .key_rdy		(key_rdy),
		      .data_rdy		(data_rdy),
		      .EncDec		(EncDec),
		      .data_in		(data_in[127:0]),
		      .state		(state_reg[2:0]),
		      .round		(round_reg[15:0]),
		      .subkey		(subkey[63:0]));
  
  always @(posedge clk) begin
    if(nreset == 1'b0) begin
      state_reg <= `ST_INITIAL;
      round_reg <= 16'b0000_0000_0000_0001;
    end
    else begin
      case(state_reg)
	`ST_INITIAL: if(key_rdy == 1'b1) state_reg <= `ST_KEY_SCHED;
	`ST_IDLE: begin
	  if(key_rdy == 1'b1) state_reg <= `ST_KEY_SCHED;
	  else if(data_rdy == 1'b1)
	    if(EncDec == `ENCRYPT) state_reg <= `ST_ENCRYPT;
	    else                   state_reg <= `ST_DECRYPT;
	end
	`ST_KEY_SCHED: state_reg <= `ST_IDLE;
	`ST_ENCRYPT, `ST_DECRYPT: begin
	  if( (round_reg[15] == 1'b1) && (data_rdy != 1'b1) )
	    state_reg <= `ST_IDLE;
	  round_reg <= { round_reg[14:0], round_reg[15] };
	end
      endcase // case(state_reg)
    end
  end
endmodule // top


module randomize(/*AUTOARG*/
  // Outputs
  data_out,
  // Inputs
  clk, nreset, key_rdy, data_rdy, EncDec, data_in, state, round,
  subkey
  );

  input clk, nreset;
  input key_rdy, data_rdy, EncDec;
  input [127:0] data_in;
  input [2:0] 	state;
  input [15:0] 	round;

  input [63:0] subkey;

  output [127:0] data_out;

  reg [127:0] 	 data_reg;

  wire [31:0] 	 G1_in, G1_out;
  wire [31:0] 	 G2_in, G2_out;
  wire [31:0] 	 G3_in, G3_out;
  function_g G1( .g_in(G1_in), .g_out(G1_out) );
  function_g G2( .g_in(G2_in), .g_out(G2_out) );
  function_g G3( .g_in(G3_in), .g_out(G3_out) );  

  wire [63:0] 	 subkey_added;
  wire [63:0] 	 f_func_out;  
  wire [127:0] 	 data_next;
  assign 	 subkey_added = data_reg[63:0] ^ subkey;
  assign 	 G1_in = subkey_added[31:0] ^ subkey_added[63:32];
  assign 	 G2_in = G1_out + subkey_added[63:32];
  assign 	 G3_in = G1_out + G2_out;
  assign 	 f_func_out = {G2_out + G3_out, G3_out};
  assign 	 data_next = {data_reg[63:0], data_reg[127:64] ^ f_func_out};
  assign 	 data_out = {data_next[63:0], data_next[127:64]};
  
  always @(posedge clk) begin
    if(nreset == 1'b0) begin
      data_reg <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
    end
    else begin
      case(state)
	`ST_IDLE: if(data_rdy == 1'b1) data_reg <= data_in;
	`ST_ENCRYPT, `ST_DECRYPT:
	  if( (round[15]==1'b1) && (data_rdy == 1'b1) )
	    data_reg <= data_in;
	  else
	    data_reg <= data_next;
      endcase // case(state)
    end
  end
    
endmodule // randomize


module key_sched(/*AUTOARG*/
  // Outputs
  subkey,
  // Inputs
  clk, nreset, key_rdy, data_rdy, EncDec, data_in, state, round
  );
  input clk, nreset;
  input key_rdy, data_rdy, EncDec;
  input [127:0] data_in;
  input [2:0] 	state;
  input [15:0] 	round;

  output [63:0] subkey;

  reg [127:0] 	key_reg;
  reg [127:0] 	subkey_reg;

  assign 	subkey = subkey_reg;

  wire [31:0] G1_in, G1_out;
  wire [31:0] G2_in, G2_out;
  wire [31:0] kc_selector_out;
  function_g G1( .g_in(G1_in), .g_out(G1_out) );
  function_g G2( .g_in(G2_in), .g_out(G2_out) );  

  assign      kc_selector_out = kc_selector(round, state, EncDec);
  assign      G1_in = (key_reg[127:96] + key_reg[ 63: 32]) - kc_selector_out;
  assign      G2_in = (key_reg[ 95:64] - key_reg[ 31:  0]) + kc_selector_out;
  
  always @(posedge clk) begin
    if(nreset == 1'b0) begin
      key_reg <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
    end
    else begin

      case(state)
	`ST_INITIAL, `ST_IDLE:
	  if(key_rdy == 1'b1) 
	    if(EncDec == `ENCRYPT) key_reg <= data_in;
	    else key_reg <= {data_in[127:64], data_in[7:0], data_in[63:8]};
	  else if(data_rdy == 1'b1)
	    if(EncDec == `ENCRYPT)
	      key_reg[127:64] <= {key_reg[ 71:64], key_reg[127: 72]};
	    else
	      key_reg[127:64] <= {key_reg[119:64], key_reg[127:120]};

	`ST_ENCRYPT:
	  if(round[0] | round[2]  | round[4] | round[6] |
	     round[8] | round[10] | round[12] | round[14])
	    key_reg[ 63: 0] <= {key_reg[55: 0], key_reg[ 63:56]};
	  else if(round[15]==1'b1 && data_rdy==1'b0)
	    ; 
	  else
	    key_reg[127:64] <= {key_reg[71:64], key_reg[127:72]};
	
	`ST_DECRYPT:
	  if(round[0] | round[2]  | round[4] | round[6] |
	     round[8] | round[10] | round[12] | round[14])
	    key_reg[ 63: 0] <= {key_reg[  7: 0], key_reg[ 63:  8]};
	  else if(round[15]==1'b1 && data_rdy==1'b0)
	    ;
	  else
	    key_reg[127:64] <= {key_reg[119:64], key_reg[127:120]};	      
      endcase // case(state)    
    end
  end

  always @(posedge clk) begin
    if(nreset == 1'b0)
      subkey_reg <= 64'h0000_0000_0000_0000;
    else
      subkey_reg <= {G1_out, G2_out};
  end
    
  
  // 鍵スケジュールの定数を選択する関数
  // オンザフライで生成するため，round_counter と
  // 出力する定数の番号が 1つずれるのに注意
  function [31:0] kc_selector;
    input [15:0] round;
    input [2:0]  state;
    input 	EncDec;

    if( (state == `ST_ENCRYPT) || (state == `ST_DECRYPT) )
      case(round)
	16'b0000000000000001: kc_selector = (EncDec==`ENCRYPT) ? `KC1  : `KC14;
	16'b0000000000000010: kc_selector = (EncDec==`ENCRYPT) ? `KC2  : `KC13;
	16'b0000000000000100: kc_selector = (EncDec==`ENCRYPT) ? `KC3  : `KC12;
	16'b0000000000001000: kc_selector = (EncDec==`ENCRYPT) ? `KC4  : `KC11;
	16'b0000000000010000: kc_selector = (EncDec==`ENCRYPT) ? `KC5  : `KC10;
	16'b0000000000100000: kc_selector = (EncDec==`ENCRYPT) ? `KC6  :  `KC9;
	16'b0000000001000000: kc_selector = (EncDec==`ENCRYPT) ? `KC7  :  `KC8;
	16'b0000000010000000: kc_selector = (EncDec==`ENCRYPT) ? `KC8  :  `KC7;
	16'b0000000100000000: kc_selector = (EncDec==`ENCRYPT) ? `KC9  :  `KC6;
	16'b0000001000000000: kc_selector = (EncDec==`ENCRYPT) ? `KC10 :  `KC5;
	16'b0000010000000000: kc_selector = (EncDec==`ENCRYPT) ? `KC11 :  `KC4;
	16'b0000100000000000: kc_selector = (EncDec==`ENCRYPT) ? `KC12 :  `KC3;
	16'b0001000000000000: kc_selector = (EncDec==`ENCRYPT) ? `KC13 :  `KC2;
	16'b0010000000000000: kc_selector = (EncDec==`ENCRYPT) ? `KC14 :  `KC1;
	16'b0100000000000000: kc_selector = (EncDec==`ENCRYPT) ? `KC15 :  `KC0;
	default:              kc_selector = (EncDec==`ENCRYPT) ? `KC0  : `KC15;
      endcase // case(round)
    else
      kc_selector = (EncDec==`ENCRYPT) ? `KC0  : `KC15;
  endfunction // kc_selector
     
endmodule // key_sched


/*=========================================================*/
/* G 関数                                                  */
/*=========================================================*/
module function_g(/*AUTOARG*/
   // Outputs
   g_out,
   // Inputs
   g_in
   );
   // 処理に必要な定数
   parameter m3 = 8'h3f;   parameter m2 = 8'hcf;
   parameter m1 = 8'hf3;   parameter m0 = 8'hfc;
   
   input [31:0] g_in;
   output [31:0] g_out;

   wire [7:0] 	 sbox_a_out, sbox_b_out, sbox_c_out,sbox_d_out;

   // 入力と出力を8bitに分割する．
   // 記法は仕様書にそろえてある．
   wire [7:0] 	 x3, x2, x1, x0;
   wire [7:0] 	 z3, z2, z1, z0;

   assign 	 x3 = g_in[31:24];
   assign 	 x2 = g_in[23:16];
   assign 	 x1 = g_in[15: 8];
   assign 	 x0 = g_in[ 7: 0];
   
   sbox2 sbox_a (.in(x3), .out(sbox_a_out));
   sbox1 sbox_b (.in(x2), .out(sbox_b_out));
   sbox2 sbox_c (.in(x1), .out(sbox_c_out));
   sbox1 sbox_d (.in(x0), .out(sbox_d_out));

   assign 	 z3 = (sbox_a_out & m2) ^ (sbox_b_out & m1) ^ (sbox_c_out & m0) ^ (sbox_d_out & m3);
   assign 	 z2 = (sbox_a_out & m1) ^ (sbox_b_out & m0) ^ (sbox_c_out & m3) ^ (sbox_d_out & m2);
   assign 	 z1 = (sbox_a_out & m0) ^ (sbox_b_out & m3) ^ (sbox_c_out & m2) ^ (sbox_d_out & m1);
   assign 	 z0 = (sbox_a_out & m3) ^ (sbox_b_out & m2) ^ (sbox_c_out & m1) ^ (sbox_d_out & m0);
   assign 	 g_out = {z3, z2, z1, z0};
endmodule // function_g


/*=========================================================*/
/* SBOX1                                                   */
/*=========================================================*/
module sbox1(in, out);
   input [7:0] in;
   output [7:0] out;
   reg [7:0] 	out;
   always @(in)
      case(in)
	8'h00: out = 8'ha9;     8'h01: out = 8'h85;     8'h02: out = 8'hd6;     8'h03: out = 8'hd3;    
	8'h04: out = 8'h54;     8'h05: out = 8'h1d;     8'h06: out = 8'hac;     8'h07: out = 8'h25;    
	8'h08: out = 8'h5d;     8'h09: out = 8'h43;     8'h0a: out = 8'h18;     8'h0b: out = 8'h1e;    
	8'h0c: out = 8'h51;     8'h0d: out = 8'hfc;     8'h0e: out = 8'hca;     8'h0f: out = 8'h63;    
	8'h10: out = 8'h28;     8'h11: out = 8'h44;     8'h12: out = 8'h20;     8'h13: out = 8'h9d;    
	8'h14: out = 8'he0;     8'h15: out = 8'he2;     8'h16: out = 8'hc8;     8'h17: out = 8'h17;    
	8'h18: out = 8'ha5;     8'h19: out = 8'h8f;     8'h1a: out = 8'h03;     8'h1b: out = 8'h7b;    
	8'h1c: out = 8'hbb;     8'h1d: out = 8'h13;     8'h1e: out = 8'hd2;     8'h1f: out = 8'hee;    
	8'h20: out = 8'h70;     8'h21: out = 8'h8c;     8'h22: out = 8'h3f;     8'h23: out = 8'ha8;    
	8'h24: out = 8'h32;     8'h25: out = 8'hdd;     8'h26: out = 8'hf6;     8'h27: out = 8'h74;    
	8'h28: out = 8'hec;     8'h29: out = 8'h95;     8'h2a: out = 8'h0b;     8'h2b: out = 8'h57;    
	8'h2c: out = 8'h5c;     8'h2d: out = 8'h5b;     8'h2e: out = 8'hbd;     8'h2f: out = 8'h01;    
	8'h30: out = 8'h24;     8'h31: out = 8'h1c;     8'h32: out = 8'h73;     8'h33: out = 8'h98;    
	8'h34: out = 8'h10;     8'h35: out = 8'hcc;     8'h36: out = 8'hf2;     8'h37: out = 8'hd9;    
	8'h38: out = 8'h2c;     8'h39: out = 8'he7;     8'h3a: out = 8'h72;     8'h3b: out = 8'h83;    
	8'h3c: out = 8'h9b;     8'h3d: out = 8'hd1;     8'h3e: out = 8'h86;     8'h3f: out = 8'hc9;    
	8'h40: out = 8'h60;     8'h41: out = 8'h50;     8'h42: out = 8'ha3;     8'h43: out = 8'heb;    
	8'h44: out = 8'h0d;     8'h45: out = 8'hb6;     8'h46: out = 8'h9e;     8'h47: out = 8'h4f;    
	8'h48: out = 8'hb7;     8'h49: out = 8'h5a;     8'h4a: out = 8'hc6;     8'h4b: out = 8'h78;    
	8'h4c: out = 8'ha6;     8'h4d: out = 8'h12;     8'h4e: out = 8'haf;     8'h4f: out = 8'hd5;    
	8'h50: out = 8'h61;     8'h51: out = 8'hc3;     8'h52: out = 8'hb4;     8'h53: out = 8'h41;    
	8'h54: out = 8'h52;     8'h55: out = 8'h7d;     8'h56: out = 8'h8d;     8'h57: out = 8'h08;    
	8'h58: out = 8'h1f;     8'h59: out = 8'h99;     8'h5a: out = 8'h00;     8'h5b: out = 8'h19;    
	8'h5c: out = 8'h04;     8'h5d: out = 8'h53;     8'h5e: out = 8'hf7;     8'h5f: out = 8'he1;    
	8'h60: out = 8'hfd;     8'h61: out = 8'h76;     8'h62: out = 8'h2f;     8'h63: out = 8'h27;    
	8'h64: out = 8'hb0;     8'h65: out = 8'h8b;     8'h66: out = 8'h0e;     8'h67: out = 8'hab;    
	8'h68: out = 8'ha2;     8'h69: out = 8'h6e;     8'h6a: out = 8'h93;     8'h6b: out = 8'h4d;    
	8'h6c: out = 8'h69;     8'h6d: out = 8'h7c;     8'h6e: out = 8'h09;     8'h6f: out = 8'h0a;    
	8'h70: out = 8'hbf;     8'h71: out = 8'hef;     8'h72: out = 8'hf3;     8'h73: out = 8'hc5;    
	8'h74: out = 8'h87;     8'h75: out = 8'h14;     8'h76: out = 8'hfe;     8'h77: out = 8'h64;    
	8'h78: out = 8'hde;     8'h79: out = 8'h2e;     8'h7a: out = 8'h4b;     8'h7b: out = 8'h1a;    
	8'h7c: out = 8'h06;     8'h7d: out = 8'h21;     8'h7e: out = 8'h6b;     8'h7f: out = 8'h66;    
	8'h80: out = 8'h02;     8'h81: out = 8'hf5;     8'h82: out = 8'h92;     8'h83: out = 8'h8a;    
	8'h84: out = 8'h0c;     8'h85: out = 8'hb3;     8'h86: out = 8'h7e;     8'h87: out = 8'hd0;    
	8'h88: out = 8'h7a;     8'h89: out = 8'h47;     8'h8a: out = 8'h96;     8'h8b: out = 8'he5;    
	8'h8c: out = 8'h26;     8'h8d: out = 8'h80;     8'h8e: out = 8'had;     8'h8f: out = 8'hdf;    
	8'h90: out = 8'ha1;     8'h91: out = 8'h30;     8'h92: out = 8'h37;     8'h93: out = 8'hae;    
	8'h94: out = 8'h36;     8'h95: out = 8'h15;     8'h96: out = 8'h22;     8'h97: out = 8'h38;    
	8'h98: out = 8'hf4;     8'h99: out = 8'ha7;     8'h9a: out = 8'h45;     8'h9b: out = 8'h4c;    
	8'h9c: out = 8'h81;     8'h9d: out = 8'he9;     8'h9e: out = 8'h84;     8'h9f: out = 8'h97;    
	8'ha0: out = 8'h35;     8'ha1: out = 8'hcb;     8'ha2: out = 8'hce;     8'ha3: out = 8'h3c;    
	8'ha4: out = 8'h71;     8'ha5: out = 8'h11;     8'ha6: out = 8'hc7;     8'ha7: out = 8'h89;    
	8'ha8: out = 8'h75;     8'ha9: out = 8'hfb;     8'haa: out = 8'hda;     8'hab: out = 8'hf8;    
	8'hac: out = 8'h94;     8'had: out = 8'h59;     8'hae: out = 8'h82;     8'haf: out = 8'hc4;    
	8'hb0: out = 8'hff;     8'hb1: out = 8'h49;     8'hb2: out = 8'h39;     8'hb3: out = 8'h67;    
	8'hb4: out = 8'hc0;     8'hb5: out = 8'hcf;     8'hb6: out = 8'hd7;     8'hb7: out = 8'hb8;    
	8'hb8: out = 8'h0f;     8'hb9: out = 8'h8e;     8'hba: out = 8'h42;     8'hbb: out = 8'h23;    
	8'hbc: out = 8'h91;     8'hbd: out = 8'h6c;     8'hbe: out = 8'hdb;     8'hbf: out = 8'ha4;    
	8'hc0: out = 8'h34;     8'hc1: out = 8'hf1;     8'hc2: out = 8'h48;     8'hc3: out = 8'hc2;    
	8'hc4: out = 8'h6f;     8'hc5: out = 8'h3d;     8'hc6: out = 8'h2d;     8'hc7: out = 8'h40;    
	8'hc8: out = 8'hbe;     8'hc9: out = 8'h3e;     8'hca: out = 8'hbc;     8'hcb: out = 8'hc1;    
	8'hcc: out = 8'haa;     8'hcd: out = 8'hba;     8'hce: out = 8'h4e;     8'hcf: out = 8'h55;    
	8'hd0: out = 8'h3b;     8'hd1: out = 8'hdc;     8'hd2: out = 8'h68;     8'hd3: out = 8'h7f;    
	8'hd4: out = 8'h9c;     8'hd5: out = 8'hd8;     8'hd6: out = 8'h4a;     8'hd7: out = 8'h56;    
	8'hd8: out = 8'h77;     8'hd9: out = 8'ha0;     8'hda: out = 8'hed;     8'hdb: out = 8'h46;    
	8'hdc: out = 8'hb5;     8'hdd: out = 8'h2b;     8'hde: out = 8'h65;     8'hdf: out = 8'hfa;    
	8'he0: out = 8'he3;     8'he1: out = 8'hb9;     8'he2: out = 8'hb1;     8'he3: out = 8'h9f;    
	8'he4: out = 8'h5e;     8'he5: out = 8'hf9;     8'he6: out = 8'he6;     8'he7: out = 8'hb2;    
	8'he8: out = 8'h31;     8'he9: out = 8'hea;     8'hea: out = 8'h6d;     8'heb: out = 8'h5f;    
	8'hec: out = 8'he4;     8'hed: out = 8'hf0;     8'hee: out = 8'hcd;     8'hef: out = 8'h88;    
	8'hf0: out = 8'h16;     8'hf1: out = 8'h3a;     8'hf2: out = 8'h58;     8'hf3: out = 8'hd4;    
	8'hf4: out = 8'h62;     8'hf5: out = 8'h29;     8'hf6: out = 8'h07;     8'hf7: out = 8'h33;    
	8'hf8: out = 8'he8;     8'hf9: out = 8'h1b;     8'hfa: out = 8'h05;     8'hfb: out = 8'h79;    
	8'hfc: out = 8'h90;     8'hfd: out = 8'h6a;     8'hfe: out = 8'h2a;     default: out = 8'h9a;    
      endcase // case(in)
endmodule // sbox1


/*=========================================================*/
/* SBOX2                                                   */
/*=========================================================*/
module sbox2(in, out);
   input [7:0] in;
   output [7:0] out;
   reg [7:0] 	out;
   always @(in)
      case(in)
	8'h00: out = 8'h38;     8'h01: out = 8'he8;     8'h02: out = 8'h2d;     8'h03: out = 8'ha6;    
	8'h04: out = 8'hcf;     8'h05: out = 8'hde;     8'h06: out = 8'hb3;     8'h07: out = 8'hb8;    
	8'h08: out = 8'haf;     8'h09: out = 8'h60;     8'h0a: out = 8'h55;     8'h0b: out = 8'hc7;    
	8'h0c: out = 8'h44;     8'h0d: out = 8'h6f;     8'h0e: out = 8'h6b;     8'h0f: out = 8'h5b;    
	8'h10: out = 8'hc3;     8'h11: out = 8'h62;     8'h12: out = 8'h33;     8'h13: out = 8'hb5;    
	8'h14: out = 8'h29;     8'h15: out = 8'ha0;     8'h16: out = 8'he2;     8'h17: out = 8'ha7;    
	8'h18: out = 8'hd3;     8'h19: out = 8'h91;     8'h1a: out = 8'h11;     8'h1b: out = 8'h06;    
	8'h1c: out = 8'h1c;     8'h1d: out = 8'hbc;     8'h1e: out = 8'h36;     8'h1f: out = 8'h4b;    
	8'h20: out = 8'hef;     8'h21: out = 8'h88;     8'h22: out = 8'h6c;     8'h23: out = 8'ha8;    
	8'h24: out = 8'h17;     8'h25: out = 8'hc4;     8'h26: out = 8'h16;     8'h27: out = 8'hf4;    
	8'h28: out = 8'hc2;     8'h29: out = 8'h45;     8'h2a: out = 8'he1;     8'h2b: out = 8'hd6;    
	8'h2c: out = 8'h3f;     8'h2d: out = 8'h3d;     8'h2e: out = 8'h8e;     8'h2f: out = 8'h98;    
	8'h30: out = 8'h28;     8'h31: out = 8'h4e;     8'h32: out = 8'hf6;     8'h33: out = 8'h3e;    
	8'h34: out = 8'ha5;     8'h35: out = 8'hf9;     8'h36: out = 8'h0d;     8'h37: out = 8'hdf;    
	8'h38: out = 8'hd8;     8'h39: out = 8'h2b;     8'h3a: out = 8'h66;     8'h3b: out = 8'h7a;    
	8'h3c: out = 8'h27;     8'h3d: out = 8'h2f;     8'h3e: out = 8'hf1;     8'h3f: out = 8'h72;    
	8'h40: out = 8'h42;     8'h41: out = 8'hd4;     8'h42: out = 8'h41;     8'h43: out = 8'hc0;    
	8'h44: out = 8'h73;     8'h45: out = 8'h67;     8'h46: out = 8'hac;     8'h47: out = 8'h8b;    
	8'h48: out = 8'hf7;     8'h49: out = 8'had;     8'h4a: out = 8'h80;     8'h4b: out = 8'h1f;    
	8'h4c: out = 8'hca;     8'h4d: out = 8'h2c;     8'h4e: out = 8'haa;     8'h4f: out = 8'h34;    
	8'h50: out = 8'hd2;     8'h51: out = 8'h0b;     8'h52: out = 8'hee;     8'h53: out = 8'he9;    
	8'h54: out = 8'h5d;     8'h55: out = 8'h94;     8'h56: out = 8'h18;     8'h57: out = 8'hf8;    
	8'h58: out = 8'h57;     8'h59: out = 8'hae;     8'h5a: out = 8'h08;     8'h5b: out = 8'hc5;    
	8'h5c: out = 8'h13;     8'h5d: out = 8'hcd;     8'h5e: out = 8'h86;     8'h5f: out = 8'hb9;    
	8'h60: out = 8'hff;     8'h61: out = 8'h7d;     8'h62: out = 8'hc1;     8'h63: out = 8'h31;    
	8'h64: out = 8'hf5;     8'h65: out = 8'h8a;     8'h66: out = 8'h6a;     8'h67: out = 8'hb1;    
	8'h68: out = 8'hd1;     8'h69: out = 8'h20;     8'h6a: out = 8'hd7;     8'h6b: out = 8'h02;    
	8'h6c: out = 8'h22;     8'h6d: out = 8'h04;     8'h6e: out = 8'h68;     8'h6f: out = 8'h71;    
	8'h70: out = 8'h07;     8'h71: out = 8'hdb;     8'h72: out = 8'h9d;     8'h73: out = 8'h99;    
	8'h74: out = 8'h61;     8'h75: out = 8'hbe;     8'h76: out = 8'he6;     8'h77: out = 8'h59;    
	8'h78: out = 8'hdd;     8'h79: out = 8'h51;     8'h7a: out = 8'h90;     8'h7b: out = 8'hdc;    
	8'h7c: out = 8'h9a;     8'h7d: out = 8'ha3;     8'h7e: out = 8'hab;     8'h7f: out = 8'hd0;    
	8'h80: out = 8'h81;     8'h81: out = 8'h0f;     8'h82: out = 8'h47;     8'h83: out = 8'h1a;    
	8'h84: out = 8'he3;     8'h85: out = 8'hec;     8'h86: out = 8'h8d;     8'h87: out = 8'hbf;    
	8'h88: out = 8'h96;     8'h89: out = 8'h7b;     8'h8a: out = 8'h5c;     8'h8b: out = 8'ha2;    
	8'h8c: out = 8'ha1;     8'h8d: out = 8'h63;     8'h8e: out = 8'h23;     8'h8f: out = 8'h4d;    
	8'h90: out = 8'hc8;     8'h91: out = 8'h9e;     8'h92: out = 8'h9c;     8'h93: out = 8'h3a;    
	8'h94: out = 8'h0c;     8'h95: out = 8'h2e;     8'h96: out = 8'hba;     8'h97: out = 8'h6e;    
	8'h98: out = 8'h9f;     8'h99: out = 8'h5a;     8'h9a: out = 8'hf2;     8'h9b: out = 8'h92;    
	8'h9c: out = 8'hf3;     8'h9d: out = 8'h49;     8'h9e: out = 8'h78;     8'h9f: out = 8'hcc;    
	8'ha0: out = 8'h15;     8'ha1: out = 8'hfb;     8'ha2: out = 8'h70;     8'ha3: out = 8'h75;    
	8'ha4: out = 8'h7f;     8'ha5: out = 8'h35;     8'ha6: out = 8'h10;     8'ha7: out = 8'h03;    
	8'ha8: out = 8'h64;     8'ha9: out = 8'h6d;     8'haa: out = 8'hc6;     8'hab: out = 8'h74;    
	8'hac: out = 8'hd5;     8'had: out = 8'hb4;     8'hae: out = 8'hea;     8'haf: out = 8'h09;    
	8'hb0: out = 8'h76;     8'hb1: out = 8'h19;     8'hb2: out = 8'hfe;     8'hb3: out = 8'h40;    
	8'hb4: out = 8'h12;     8'hb5: out = 8'he0;     8'hb6: out = 8'hbd;     8'hb7: out = 8'h05;    
	8'hb8: out = 8'hfa;     8'hb9: out = 8'h01;     8'hba: out = 8'hf0;     8'hbb: out = 8'h2a;    
	8'hbc: out = 8'h5e;     8'hbd: out = 8'ha9;     8'hbe: out = 8'h56;     8'hbf: out = 8'h43;    
	8'hc0: out = 8'h85;     8'hc1: out = 8'h14;     8'hc2: out = 8'h89;     8'hc3: out = 8'h9b;    
	8'hc4: out = 8'hb0;     8'hc5: out = 8'he5;     8'hc6: out = 8'h48;     8'hc7: out = 8'h79;    
	8'hc8: out = 8'h97;     8'hc9: out = 8'hfc;     8'hca: out = 8'h1e;     8'hcb: out = 8'h82;    
	8'hcc: out = 8'h21;     8'hcd: out = 8'h8c;     8'hce: out = 8'h1b;     8'hcf: out = 8'h5f;    
	8'hd0: out = 8'h77;     8'hd1: out = 8'h54;     8'hd2: out = 8'hb2;     8'hd3: out = 8'h1d;    
	8'hd4: out = 8'h25;     8'hd5: out = 8'h4f;     8'hd6: out = 8'h00;     8'hd7: out = 8'h46;    
	8'hd8: out = 8'hed;     8'hd9: out = 8'h58;     8'hda: out = 8'h52;     8'hdb: out = 8'heb;    
	8'hdc: out = 8'h7e;     8'hdd: out = 8'hda;     8'hde: out = 8'hc9;     8'hdf: out = 8'hfd;    
	8'he0: out = 8'h30;     8'he1: out = 8'h95;     8'he2: out = 8'h65;     8'he3: out = 8'h3c;    
	8'he4: out = 8'hb6;     8'he5: out = 8'he4;     8'he6: out = 8'hbb;     8'he7: out = 8'h7c;    
	8'he8: out = 8'h0e;     8'he9: out = 8'h50;     8'hea: out = 8'h39;     8'heb: out = 8'h26;    
	8'hec: out = 8'h32;     8'hed: out = 8'h84;     8'hee: out = 8'h69;     8'hef: out = 8'h93;    
	8'hf0: out = 8'h37;     8'hf1: out = 8'he7;     8'hf2: out = 8'h24;     8'hf3: out = 8'ha4;    
	8'hf4: out = 8'hcb;     8'hf5: out = 8'h53;     8'hf6: out = 8'h0a;     8'hf7: out = 8'h87;    
	8'hf8: out = 8'hd9;     8'hf9: out = 8'h4c;     8'hfa: out = 8'h83;     8'hfb: out = 8'h8f;    
	8'hfc: out = 8'hce;     8'hfd: out = 8'h3b;     8'hfe: out = 8'h4a;     default: out = 8'hb7;    
      endcase // case(in)
endmodule // sbox1
