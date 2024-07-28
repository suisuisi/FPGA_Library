/*-------------------------------------------------------------------------
 SEED Encryption/Decryption Macro
 (One round / Three clock version)
 
 File name   : SEED_3clk.v
 Version     : Version 1.0
 Created     : MAR/04/2007
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


// 状態の定義
`define IDLE       3'b000
`define GET_DATA   3'b001
`define INITIAL1   3'b010
`define INITIAL2   3'b011
`define ROUND1     3'b100
`define ROUND2     3'b101
`define ROUND3     3'b110
`define FINISH     3'b111

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

// オペレーションモードの定義
`define ENCRYPTION 1'b0
`define DECRYPTION 1'b1

module top(clk, nreset,
	   data_in, key_in, activate, en_de,
	   data_out, busy, data_valid);
   input clk, nreset;

   input [127:0] data_in;
   input [127:0] key_in;
   input 	 activate; // start encryption/decryption
   input 	 en_de;    // select encryption or decryption

   output [127:0] data_out;
   output 	  busy;
   output 	  data_valid;
   reg 		  busy;
   reg 		  data_valid;

   wire [2:0] 	  state;        
   wire [3:0] 	 round_counter;
   wire [63:0] 	 subkey;
   
   sequencer     sequencer     (/*AUTOINST*/
				// Outputs
				.state		(state[2:0]),
				.round_counter	(round_counter[3:0]),
				// Inputs
				.clk		(clk),
				.nreset		(nreset),
				.activate	(activate));
   key_scheduler key_scheduler (/*AUTOINST*/
				// Outputs
				.subkey		(subkey[63:0]),
				// Inputs
				.clk		(clk),
				.nreset		(nreset),
				.state		(state[2:0]),
				.round_counter	(round_counter[3:0]),
				.key_in		(key_in[127:0]),
				.en_de		(en_de));
   encrypt       encrypt       (/*AUTOINST*/
				// Outputs
				.data_out	(data_out[127:0]),
				// Inputs
				.clk		(clk),
				.nreset		(nreset),
				.state		(state[2:0]),
				.data_in	(data_in[127:0]),
				.subkey		(subkey[63:0]),
				.round_counter	(round_counter[3:0]));

   always @(state) begin
      if (state == `FINISH)
	data_valid <= 1'b1;
      else
	data_valid <= 1'b0;
   end

   always @(state) begin
      if(state == `IDLE)
	busy <= 1'b0;
      else
	busy <= 1'b1;
   end

endmodule


/*=========================================================*/
/* シーケンサ                                              */
/*=========================================================*/
module sequencer(/*AUTOARG*/
   // Outputs
   state, round_counter,
   // Inputs
   clk, nreset, activate
   );
   input clk, nreset;
   input activate;             // 動作を開始させる信号
   
   output [2:0] state;         // 状態
   output [3:0] round_counter; // 実行ラウンドを表すカウンタ
   reg    [2:0] state;        
   reg    [3:0] round_counter;
   
   always @(posedge clk) begin
      if (nreset == 0) begin
	 state <= `IDLE;
	 round_counter <= 4'h0;
      end
      else
	case(state)

	  // アイドリング状態の記述
	  // activate が入ったら動作開始
	  `IDLE:
	    begin
	       if (activate == 1'b1) begin
		  state <= `GET_DATA;
		  round_counter <= 4'h0;
	       end
	       else
		 state <= `IDLE;
	    end

	  // round_counter = 16 の時は
	  // 動作完了なので IDLE に推移する
	  // そうでなければ，次のラウンドへ進む
	  `ROUND3:
	    begin
	       if (round_counter == 4'hf)
		 state <= `FINISH;
	       else begin
		  state <= `ROUND1;
		  round_counter <= round_counter + 1;
	       end
	    end
	  
	  default:    state <= state + 1;
	endcase // case(state)
   end
endmodule // sequencer



/*=========================================================*/
/* 撹拌部                                                  */
/*=========================================================*/
module encrypt(
	       // Outputs
	       data_out,
	       // Inputs
	       clk, nreset, state, data_in, subkey,
	       round_counter
	       );
   input clk, nreset;
   input [2:0] state;           // 状態
   input [127:0] data_in;       // 平文
   input [63:0]  subkey;        // 副鍵
   input [3:0] 	 round_counter;        // 副鍵

   output [127:0] data_out;     // 出力

   reg [31:0] 	  A, B, C, D;   // {A, B, C, D} が，データを格納しておくレジスタ
   reg [31:0] 	  temp_C, temp_D;
   
   wire [63:0]   next_data;   
   wire [31:0] 	  g_in, g_out;  // G 関数への入力と出力
   wire [31:0] 	  key_added_left, key_added_right; 
   wire [31:0] 	  adder_out;
   
   function_g function_g(/*AUTOINST*/
			 // Outputs
			 .g_out			(g_out[31:0]),
			 // Inputs
			 .g_in			(g_in[31:0]));

   assign 	  data_out = {A, B, C, D};
   
   // 鍵加算の出力 {key_added_left, key_added_right}
   assign 	  key_added_left  = C ^ subkey[63:32];
   assign 	  key_added_right = D ^ subkey[31: 0] ^ key_added_left;   

   // G 関数と，加算器への入力の選択
   assign 	  g_in = g_in_selector(state, temp_C, temp_D, key_added_right);
   assign 	  adder_out = g_out + adder_in_selector(state, temp_C, temp_D, key_added_left);

   // レジスタを更新する値の選択
   assign 	  next_data = next_data_selector(g_out, adder_out);

   
   // レジスタ A, B, C, D に関する動作記述
   always @(posedge clk) begin
      if(nreset == 1'b0)
	{A, B, C, D} <= 128'h00000000000000000000000000000000;
      else
	case(state)
	  `GET_DATA: {A, B, C, D} <= data_in;
	  `ROUND3:
	    if(round_counter == 4'hf)  // 最終ラウンドはクロス無し
	      {A, B, C, D} <= {{A, B}^next_data, C, D};
	    else
	      {A, B, C, D} <= {C, D, {A, B}^next_data};
	endcase // case(state)
   end

   
   // レジスタ temp_C, temp_D に関する動作記述
   always @(posedge clk) begin
      if(nreset == 1'b0) begin
	 temp_C <= 32'h00000000;
	 temp_D <= 32'h00000000;
      end
      else if (state == `ROUND1 || state == `ROUND2)
	{temp_C, temp_D} <= next_data;
   end
   
   // G 関数への入力を選択する
   function [31:0] g_in_selector;
      input [2:0] state;
      input [31:0] temp_C, temp_D, key_added_right;
      case(state)
	`ROUND1: g_in_selector = key_added_right;
	`ROUND2: g_in_selector = temp_C;
	`ROUND3: g_in_selector = temp_D;
	default: g_in_selector = 32'h00000000;
      endcase // case(state)
   endfunction // g_in_selector
   
   // 加算器への入力を選択する
   function [31:0] adder_in_selector;
      input [2:0] state;
      input [31:0] C, D, key_added_left;

      case(state)
	`ROUND1: adder_in_selector = key_added_left;
	`ROUND2: adder_in_selector = temp_D;
	`ROUND3: adder_in_selector = temp_C;
	default: adder_in_selector = 32'h00000000;
      endcase // case(state)
   endfunction // adder_in_selector
   
   // レジスタ {A, B, C, D} を更新する値を選択する
   function [63:0] next_data_selector;
      input [31:0] g_out, adder_out;

      case(state)
	`ROUND1, `ROUND3: next_data_selector = {adder_out, g_out};
	`ROUND2: next_data_selector = {g_out, adder_out};
	default: next_data_selector = 64'h0000000000000000;
      endcase // case(state)
   endfunction // next_data_selector
   
endmodule // encrypt



/*=========================================================*/
/* 鍵スケジューラ                                          */
/*=========================================================*/
module key_scheduler(/*AUTOARG*/
   // Outputs
   subkey,
   // Inputs
   clk, nreset, state, round_counter, key_in, en_de
   );
   input clk, nreset;
   input [2:0] state;
   input [3:0] round_counter;
   input [127:0] key_in;
   input 	 en_de;
   output [63:0] subkey;

   reg [31:0] 	 k0, k1;      // 副鍵
   reg [31:0] 	 A, B, C, D;  // 鍵を入れておくレジスタ
                              // 記法は仕様書の通り
   reg 		 en_de_reg;
   
   wire [31:0] 	 g_in, g_out; // 関数Gへの接続用

   wire [31:0] 	 kc_selected;
   
   assign 	 subkey = {k0, k1};
   assign 	 kc_selected = kc_selector(state, round_counter, en_de_reg);
   assign g_in = g_selector(state, A, B, C, D, kc_selected);

   function_g function_g(/*AUTOINST*/
			 // Outputs
			 .g_out			(g_out[31:0]),
			 // Inputs
			 .g_in			(g_in[31:0]));      
   // レジスタA, B, C, D に関する記述
   always @(posedge clk)
     begin
      if(nreset == 1'b0)
	begin
	 A <= 32'h00000000;
	 B <= 32'h00000000;
	 C <= 32'h00000000;
	 D <= 32'h00000000;
	end
      else
	case(state)
	  `GET_DATA: 
	    begin
	       if(en_de == `ENCRYPTION) // 暗号化の場合
		 {A, B, C, D} <= key_in;
	       else
		 begin                  // 復号化の場合
		    {A, B} <= key_in[127:64];
		    {C, D} <= {key_in[  7: 0], key_in[ 63:  8]};
		 end
	       en_de_reg    <= en_de;
	    end
	     
	  `INITIAL2:
	    begin
	       if(en_de_reg == `ENCRYPTION)
		 {A, B} <= {B[7:0], A[31:0], B[31:8]}; // 暗号化
	       else
		 //{C, D} <= {D[7:0], C[31:0], D[31:8]}; // 復号化
	       {A, B} <= {A[23:0], B[31:0], A[31:24]}; // 暗号化
	    end
	     
	  `ROUND3:
	    begin
	       if(en_de_reg == `ENCRYPTION) // 暗号化
		 begin
		    if(round_counter[0] == 1)             //round_counter[0] で偶奇の判定を行っている
		      {A, B} <= {B[7:0], A[31:0], B[31:8]};
		    else
		      {C, D} <= {C[23:0], D[31:0], C[31:24]};
		 end
	       else                     // 復号化
		 begin
		    if(round_counter[0] == 0)
		      {C, D} <= {D[7:0], C[31:0], D[31:8]};
		    else
		      {A, B} <= {A[23:0], B[31:0], A[31:24]};
		 end
	    end
	endcase // case(state)
     end // always @ (posedge clk)
   

 
  // レジスタk0, k1 に関する記述
   always @(posedge clk)
     begin
	case(state)
	  `ROUND1, `INITIAL1: k0 <= g_out;
	  `ROUND2, `INITIAL2: k1 <= g_out;
	endcase
     end
   
   // 鍵スケジュールの定数を選択する関数
   // オンザフライで生成するため，round_counter と
   // 出力する定数の番号が 1つずれるのに注意
   function [31:0] kc_selector;
      input [2:0] state;
      input [3:0] round_counter;
      input 	  en_de_reg;

      if(en_de_reg == `ENCRYPTION)  // 暗号化
	begin
	   if(state == `INITIAL1 || state == `INITIAL2)
	     kc_selector = `KC0;
	   else
	     case (round_counter)
	       4'h0: kc_selector = `KC1;   4'h1: kc_selector = `KC2;
	       4'h2: kc_selector = `KC3;   4'h3: kc_selector = `KC4;
	       4'h4: kc_selector = `KC5;   4'h5: kc_selector = `KC6;	
	       4'h6: kc_selector = `KC7;   4'h7: kc_selector = `KC8;
	       4'h8: kc_selector = `KC9;   4'h9: kc_selector = `KC10;
	       4'ha: kc_selector = `KC11;  4'hb: kc_selector = `KC12;
	       4'hc: kc_selector = `KC13;  4'hd: kc_selector = `KC14;
	       default: kc_selector = `KC15;
	     endcase // case(round_counter)
	end
      else  // 復号化
	begin
	   if(state == `INITIAL1 || state == `INITIAL2)
	     kc_selector = `KC15;
	   else
	     case (round_counter)
	       4'h0: kc_selector = `KC14;   4'h1: kc_selector = `KC13;
	       4'h2: kc_selector = `KC12;   4'h3: kc_selector = `KC11;
	       4'h4: kc_selector = `KC10;   4'h5: kc_selector = `KC9;	
	       4'h6: kc_selector = `KC8;    4'h7: kc_selector = `KC7;
	       4'h8: kc_selector = `KC6;    4'h9: kc_selector = `KC5;
	       4'ha: kc_selector = `KC4;    4'hb: kc_selector = `KC3;
	       4'hc: kc_selector = `KC2;    4'hd: kc_selector = `KC1;
	       default: kc_selector = `KC0;
	     endcase // case(round_counter)
	end
   endfunction // kc_selector

   
   // G 関数への入力を選択する関数   
   function [31:0] g_selector;
      input [2:0] state;
      input [31:0] A, B, C, D, kc;

      case(state)
	`ROUND1, `INITIAL1: g_selector = A + C - kc;
	default:	    g_selector = B - D + kc;
      endcase
   endfunction // g_selector
endmodule // key_scheduler



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

