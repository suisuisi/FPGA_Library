/*-------------------------------------------------------------------------
 Camellia Encryption/Decryption Macro
                                    
 File name   : Camellia.v
 Version     : Version 1.0
 Created     : SEP/29/2006
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


// アイドリング状態
`define IDLE                  4'h0
`define IDLE_READY            4'h1

// 鍵スケジュールに関する状態
`define KEY_GET               4'h3
`define KEY_F_FUNC            4'h4
`define KEY_XOR               4'h5

// 暗号化に関する状態
`define RANDOMIZE_GET         4'h7
`define RANDOMIZE_INITIAL_XOR 4'h8
`define RANDOMIZE_FINAL_XOR   4'h9
`define RANDOMIZE_F_FUNC      4'ha
`define RANDOMIZE_FL_1        4'hb
`define RANDOMIZE_FL_2        4'hc

// 暗号化 or 復号化の選択 
`define ENCRYPT               1'b0
`define DECRYPT               1'b1

// 鍵スケジュールに用いる定数
`define SIGMA1                64'ha09e667f3bcc908b
`define SIGMA2                64'hb67ae8584caa73b2
`define SIGMA3                64'hc6ef372fe94f82be
`define SIGMA4                64'h54ff53a5f1d36f1c


module top(/*AUTOARG*/
	   // Outputs
	   data_out,
	   // Inputs
	   clk, nreset, en_de, data_rdy, key_rdy, data_in, key_in, busy,
	   data_valid
	   );

  input         clk, nreset;
  input         en_de;
  input         data_rdy, key_rdy;
  input [127:0] data_in, key_in;

  output [127:0] data_out;
  output 	 busy, data_valid;
  reg 		 busy, data_valid;   

  wire [127:0] 	 kl, ka;
  wire [127:0] 	 ka_in;
  wire [3:0] 	 state;
  wire [4:0] 	 round;

  // busy
  always @(state) begin
    if(state == `IDLE || state == `IDLE_READY)
      busy <= 1'b0;
    else
      busy <= 1'b1;
  end

  // data_valid
  always @(state) begin
    if(state == `RANDOMIZE_FINAL_XOR)
      data_valid <= 1'b1;
    else
      data_valid <= 1'b0;
  end
  
  
  sequencer     sequencer(/*AUTOINST*/
			  // Outputs
			  .state		(state[3:0]),
			  .round		(round[4:0]),
			  // Inputs
			  .clk			(clk),
			  .nreset		(nreset),
			  .data_rdy		(data_rdy),
			  .key_rdy		(key_rdy));

  key_scheduler key_scheduler( .kl_in(key_in),
			       /*AUTOINST*/
			       // Outputs
			       .kl		(kl[127:0]),
			       .ka		(ka[127:0]),
			       // Inputs
			       .clk		(clk),
			       .nreset		(nreset),
			       .state		(state[3:0]),
			       .round		(round[4:0]),
			       .ka_in		(ka_in[127:0]),
			       .en_de		(en_de));

  randomize       randomize( .ka_out(ka_in),
			     /*AUTOINST*/
			     // Outputs
			     .data_out		(data_out[127:0]),
			     // Inputs
			     .clk			(clk),
			     .nreset		(nreset),
			     .state			(state[3:0]),
			     .round			(round[4:0]),
			     .data_in		(data_in[127:0]),
			     .key_in		(key_in[127:0]),
			     .kl			(kl[127:0]),
			     .ka			(ka[127:0]),
			     .en_de			(en_de));
endmodule // top



module sequencer(/*AUTOARG*/
		 // Outputs
		 state, round,
		 // Inputs
		 clk, nreset, data_rdy, key_rdy
		 );
  input  clk, nreset;
  input  data_rdy, key_rdy;
  output [3:0] state;
  output [4:0] round;

  reg [3:0]    state;
  reg [4:0]    round;

  always @(posedge clk) begin
    if(nreset == 1'b0) begin
      state <= `IDLE;
      round <= 5'd00;
    end
    else begin
      case(state)
	// アイドリング状態に関する記述
	`IDLE:
	  if(key_rdy == 1'b1)
	    state <= `KEY_GET;
	
	`IDLE_READY:
	  if(key_rdy == 1'b1)
	    state <= `KEY_GET;
	  else if(data_rdy == 1'b1)
	    state <= `RANDOMIZE_GET;

	// 鍵スケジュールに関する記述
	`KEY_GET: begin
	  round <= 5'd01;
	  state <= `KEY_F_FUNC;
	end

	`KEY_F_FUNC:
	  case(round)
	    5'd02:   state <= `KEY_XOR;
	    5'd04:   state <= `IDLE_READY;
	    default: round <= round + 1;
	  endcase // case(round)
	
	`KEY_XOR: begin
	  round <= round + 1;
	  state <= `KEY_F_FUNC;
	end

	// 撹拌部に関する記述
	`RANDOMIZE_GET: begin
	  round <= 5'd01;
	  state <= `RANDOMIZE_INITIAL_XOR;
	end

	`RANDOMIZE_INITIAL_XOR: state <= `RANDOMIZE_F_FUNC;
	
	`RANDOMIZE_F_FUNC:
	  case(round)
	    5'd06:   state <= `RANDOMIZE_FL_1;
	    5'd12:   state <= `RANDOMIZE_FL_2;
	    5'd18:   state <= `RANDOMIZE_FINAL_XOR;
	    default: round <= round + 1;
	  endcase // case(round)

	`RANDOMIZE_FL_1, `RANDOMIZE_FL_2: begin
	  round <= round + 1;
	  state <= `RANDOMIZE_F_FUNC;
	end
	
	`RANDOMIZE_FINAL_XOR: state <= `IDLE_READY;
      endcase // case(state)
    end // else: !if(nreset == 1'b0)
  end // always @ (posedge clk)
endmodule // sequencer



module key_scheduler(/*AUTOARG*/
		     // Outputs
		     kl, ka,
		     // Inputs
		     clk, nreset, state, round, kl_in, ka_in, en_de
		     );
  input          clk, nreset;
  input [3:0] 	 state;
  input [4:0] 	 round;
  input [127:0]  kl_in;
  input [127:0]  ka_in;
  input 	 en_de;
  
  output [127:0] kl, ka;
  reg [127:0] 	 kl, ka;
  reg 		 en_de_reg;

  wire [127:0] 	 kl_rotate_left_15,  ka_rotate_left_15;  // 15bit 左循環シフト
  wire [127:0] 	 kl_rotate_left_17,  ka_rotate_left_17;  // 17bit 左循環シフト
  wire [127:0] 	 kl_rotate_right_15, ka_rotate_right_15; // 15bit 右循環シフト
  wire [127:0] 	 kl_rotate_right_17, ka_rotate_right_17; // 17bit 右循環シフト

  assign 	 kl_rotate_left_15 = {kl[112:0], kl[127:113]};
  assign 	 ka_rotate_left_15 = {ka[112:0], ka[127:113]};
  assign 	 kl_rotate_left_17 = {kl[110:0], kl[127:111]};
  assign 	 ka_rotate_left_17 = {ka[110:0], ka[127:111]};

  assign 	 kl_rotate_right_15 = {kl[14:0], kl[127:15]};
  assign 	 ka_rotate_right_15 = {ka[14:0], ka[127:15]};
  assign 	 kl_rotate_right_17 = {kl[16:0], kl[127:17]};
  assign 	 ka_rotate_right_17 = {ka[16:0], ka[127:17]};
  
  always @(posedge clk) begin
    if (nreset == 1'b0) begin
      kl <= 128'h00000000000000000000000000000000;
      ka <= 128'h00000000000000000000000000000000;
    end
    else
      case(state)
	`KEY_GET:    kl <= kl_in;
	`KEY_F_FUNC: if(round == 5'd04) ka <= ka_in;

	`RANDOMIZE_GET: begin
	  en_de_reg <= en_de;
	  if(en_de == `DECRYPT) begin
	    // KL <<< 111, KA <<< 111
	    kl <= kl_rotate_right_17;
	    ka <= ka_rotate_right_17;
	  end
	end

	`RANDOMIZE_FL_1: begin
	  kl <= (en_de_reg == `ENCRYPT) ? kl_rotate_left_15 : kl_rotate_right_17;
	  ka <= (en_de_reg == `ENCRYPT) ? ka_rotate_left_15 : ka_rotate_right_17;
	end

	`RANDOMIZE_FL_2: begin
	  kl <= (en_de_reg == `ENCRYPT) ? kl_rotate_left_17 : kl_rotate_right_15;
	  ka <= (en_de_reg == `ENCRYPT) ? ka_rotate_left_17 : ka_rotate_right_15;
	end
	
	`RANDOMIZE_F_FUNC:
	  case(round)
	    5'd02, 5'd06 :   begin
	      kl <= (en_de_reg == `ENCRYPT) ? kl_rotate_left_15 : kl_rotate_right_17;
	      ka <= (en_de_reg == `ENCRYPT) ? ka_rotate_left_15 : ka_rotate_right_17;
	    end
	    
	    5'd09 : begin
	      kl <= (en_de_reg == `ENCRYPT) ? kl_rotate_left_15 : kl_rotate_right_15;
	      ka <= (en_de_reg == `ENCRYPT) ? ka_rotate_left_15 : ka_rotate_right_15;
	    end		 
	    
	    5'd12, 5'd16: begin
	      kl <= (en_de_reg == `ENCRYPT) ? kl_rotate_left_17 : kl_rotate_right_15;
	      ka <= (en_de_reg == `ENCRYPT) ? ka_rotate_left_17 : ka_rotate_right_15;
	    end
	  endcase // case(round)

	// 最後に余計にシフトすることで，KA と KL を元の状態に戻す
	`RANDOMIZE_FINAL_XOR: begin
	  if(en_de_reg == `ENCRYPT) begin
	    kl <= kl_rotate_left_17;
	    ka <= ka_rotate_left_17;
	  end
	end
	
      endcase // case(state)

  end // always @ (posedge clk)
endmodule


module randomize(/*AUTOARG*/
		 // Outputs
		 data_out, ka_out,
		 // Inputs
		 clk, nreset, state, round, data_in, key_in, kl, ka, en_de
		 );
  input          clk, nreset;
  input [3:0] 	 state;
  input [4:0] 	 round;
  input [127:0]  data_in, key_in;
  input [127:0]  kl, ka;     // 鍵スケジューラか供給される副鍵
  input 	 en_de;
  output [127:0] data_out;
  output [127:0] ka_out;
  
  reg [127:0] 	 data_out;
  reg 		 en_de_reg;
  
  wire [63:0] 	 f_func_out;       // F関数の出力
  wire [63:0] 	 selected_key;     // 使用する副鍵 64bit
  wire [127:0] 	 key_kl_or_ka;     // 使用する副鍵 128bit

  wire [127:0] 	 feistel_out;      // F関数の出力をXORした上でクロスしたもの
  wire [127:0] 	 xor_out;          // XOR の出力
  wire [127:0] 	 fl_out;           // FL/FL-1 の出力

  assign 	 feistel_out = {data_out[63:0] ^ f_func_out, data_out[127:64]};
  assign 	 ka_out = feistel_out; // 鍵スケジューラへの入力

  assign 	 xor_out = data_out ^ key_kl_or_ka;

  assign 	 key_kl_or_ka = kl_or_ka(kl, ka, state, round, en_de_reg);
  assign 	 selected_key = select_key(key_kl_or_ka, state, round, en_de_reg);
  
  f_func f_func( .in(data_out[127:64]), .out(f_func_out), .key(selected_key) );
  fl     fl    ( .in(data_out),         .out(fl_out),     .key(key_kl_or_ka), .en_de_reg(en_de_reg));

  
  always @(posedge clk) begin
    if(nreset == 1'b0)
      data_out <= 128'h00000000000000000000000000000000;
    else
      case(state)
	//鍵スケジュールのために読み込む
	`KEY_GET                                              : data_out <= key_in;
	`KEY_F_FUNC                                           : data_out <= feistel_out;
	`KEY_XOR, `RANDOMIZE_INITIAL_XOR, `RANDOMIZE_FINAL_XOR: data_out <= xor_out;
	`RANDOMIZE_GET                                        : data_out <= data_in;
	`RANDOMIZE_FL_1, `RANDOMIZE_FL_2                      : data_out <= fl_out;
	`RANDOMIZE_F_FUNC:
	  // 最終ラウンドはクロス無し
	  if(round == 5'd18)
	    data_out <= {feistel_out[63:0], feistel_out[127:64]};
	  else
	    data_out <= feistel_out;
	
      endcase // case(state)
  end

  
  // 暗号化 or 復号化の選択
  always @(posedge clk) begin
    if(nreset == 1'b0)
      en_de_reg <= 1'b0;
    else if(state == `RANDOMIZE_GET)
      en_de_reg <= en_de;
  end

  
  // 副鍵に KL を使うか KA を使うか選択する関数
  function [127:0] kl_or_ka;
    input [127:0] kl;
    input [127:0] ka;
    input [3:0]   state;
    input [4:0]   round;
    input 	  en_de_reg;

    case(state)
      `KEY_XOR                               : kl_or_ka = kl;
      `RANDOMIZE_FL_1, `RANDOMIZE_FINAL_XOR  : kl_or_ka = (en_de_reg == `ENCRYPT) ? ka : kl;
      `RANDOMIZE_FL_2, `RANDOMIZE_INITIAL_XOR: kl_or_ka = (en_de_reg == `ENCRYPT) ? kl : ka;
      `RANDOMIZE_F_FUNC:
	case(round)
	  5'd03, 5'd04, 5'd7, 5'd8, 5'd10, 5'd13, 5'd14, 5'd17, 5'd18:
	    kl_or_ka = (en_de_reg == `ENCRYPT) ? kl : ka;
	  default:
	    kl_or_ka = (en_de_reg == `ENCRYPT) ? ka : kl;
	endcase // case(round)

      default:
	kl_or_ka = kl;
    endcase // case(state)
  endfunction // kl_or_ka

  
  // 関数 kl_or_ka の出力のうち、右半分を使うか左半分を使うか選択する
  function [63:0] select_key;
    input [127:0] kl_or_ka;
    input [3:0]   state;
    input [4:0]   round;
    input 	  en_de_reg;

    case(state)
      `KEY_F_FUNC:
	case(round)
	  5'd01:   select_key = `SIGMA1;
	  5'd02:   select_key = `SIGMA2;
	  5'd03:   select_key = `SIGMA3;
	  default: select_key = `SIGMA4;
	endcase // case(round)

      `RANDOMIZE_F_FUNC:
	case(round)
	  5'd01, 5'd03, 5'd05, 5'd07, 5'd09, 5'd11, 5'd13, 5'd15, 5'd17:
	    select_key = (en_de_reg == `ENCRYPT) ? kl_or_ka[127:64] : kl_or_ka[ 63: 0];
	  default:
	    select_key = (en_de_reg == `ENCRYPT) ? kl_or_ka[ 63: 0] : kl_or_ka[127:64];
	endcase // case(round)

      default:
	// その他の場合では、select_key の出力を利用しない。
	// そのため、最適化を期待して kl_or_ka[63:0] を出力するようにしている。
	select_key = kl_or_ka[63:0];
    endcase // case(state)
  endfunction // select_key
  
endmodule


// F関数
module f_func(in, out, key);
  input  [63:0] in;
  input [63:0] 	key;
  output [63:0] out;

  wire [63:0] 	key_added;
  wire [7:0] 	y1, y2, y3, y4, y5, y6, y7, y8; //各sboxへの入力
  wire [7:0] 	z1, z2, z3, z4, z5, z6, z7, z8; //各sboxへの出力

  assign 	key_added = in ^ key;

  //8つのsboxへの入力を，わかり易いように一度分岐する
  assign 	y1 = key_added[63:56], y2 = key_added[55:48], y3 = key_added[47:40], y4 = key_added[39:32];
  assign 	y5 = key_added[31:24], y6 = key_added[23:16], y7 = key_added[15:8] , y8 = key_added[7:0];

  //sboxとの接続
  sbox1 sbox1a( .in(y1), .out(z1) );
  sbox2 sbox2a( .in(y2), .out(z2) );
  sbox3 sbox3a( .in(y3), .out(z3) );
  sbox4 sbox4a( .in(y4), .out(z4) );
  sbox2 sbox2b( .in(y5), .out(z5) );
  sbox3 sbox3b( .in(y6), .out(z6) );
  sbox4 sbox4b( .in(y7), .out(z7) );
  sbox1 sbox1b( .in(y8), .out(z8) );
  p_func p_func(.in( {z1, z2, z3, z4, z5, z6, z7, z8} ), .out(out) );
endmodule // f_func

//P関数
module p_func(in, out);
  input [63:0] in;
  output [63:0] out;
  assign 	out[63:56] = in[63:56]             ^ in[47:40] ^ in[39:32]             ^ in[23:16] ^ in[15:8] ^ in[7:0];
  assign 	out[55:48] = in[63:56] ^ in[55:48]             ^ in[39:32] ^ in[31:24]             ^ in[15:8] ^ in[7:0];
  assign 	out[47:40] = in[63:56] ^ in[55:48] ^ in[47:40]             ^ in[31:24] ^ in[23:16]            ^ in[7:0];
  assign 	out[39:32] =             in[55:48] ^ in[47:40] ^ in[39:32] ^ in[31:24] ^ in[23:16] ^ in[15:8]          ;
  assign 	out[31:24] = in[63:56] ^ in[55:48]                                     ^ in[23:16] ^ in[15:8] ^ in[7:0];
  assign 	out[23:16] =             in[55:48] ^ in[47:40]             ^ in[31:24]             ^ in[15:8] ^ in[7:0];
  assign 	out[15:8]  =                         in[47:40] ^ in[39:32] ^ in[31:24] ^ in[23:16]            ^ in[7:0];
  assign 	out[7:0]   = in[63:56]                         ^ in[39:32] ^ in[31:24] ^ in[23:16] ^ in[15:8]          ;
endmodule // p_func


//FL/FL-1関数の実装
module fl(in, out, key, en_de_reg);
  input  [127:0] in;
  input [127:0]  key;
  input 	 en_de_reg;

  output [127:0] out;
  wire [63:0] 	 in_plus, in_minus;
  wire [63:0] 	 key_plus, key_minus;
  wire [63:0] 	 out_plus, out_minus;

  assign 	 {in_plus, in_minus}   = in;
  assign 	 out   = {out_plus, out_minus};
  assign 	 {key_plus, key_minus} = (en_de_reg == `ENCRYPT) ? key : {key[63:0], key[127:64]};

  fl_plus  fl_plus(  .in(in_plus ), .out(out_plus ), .key(key_plus ) );
  fl_minus fl_minus( .in(in_minus), .out(out_minus), .key(key_minus) );
endmodule // fl


//FL関数の実装
module fl_plus(in, out, key);
  input  [63:0] in, key;
  output [63:0] out;
  wire [63:0] 	in_left, in_right, out_left, out_right, key_left, key_right, temp;

  assign 	in_left = in[63:32],   in_right = in[31:0];
  assign 	out[63:32] = out_left, out[31:0] = out_right;
  assign 	key_left = key[63:32], key_right = key[31:0];

  assign 	{temp[0], temp[31:1]} = in_left & key_left;
  assign 	out_right = in_right ^ temp;
  assign 	out_left = in_left ^ ( out_right | key_right );
endmodule // fl_plus


//FL-1関数の実装
module fl_minus(in, out, key);
  input  [63:0] in, key;
  output [63:0] out;
  wire [63:0] 	in_left, in_right, out_left, out_right, key_left, key_right, temp;

  assign 	in_left = in[63:32],   in_right = in[31:0];
  assign 	out[63:32] = out_left, out[31:0] = out_right;
  assign 	key_left = key[63:32], key_right = key[31:0];

  assign 	out_left = in_left ^ ( in_right | key_right );
  assign 	{temp[0], temp[31:1]} = out_left & key_left;
  assign 	out_right = in_right ^ temp;
endmodule // fl_minus


module sbox1(in, out);
  input [7:0] in;
  output [7:0] out;

  assign       out = temp(in);
  
  function [7:0] temp;
    input [7:0] in;

    case(in)
      8'h00: temp = 8'h70;    8'h01: temp = 8'h82;    8'h02: temp = 8'h2c;    8'h03: temp = 8'hec;    
      8'h04: temp = 8'hb3;    8'h05: temp = 8'h27;    8'h06: temp = 8'hc0;    8'h07: temp = 8'he5;    
      8'h08: temp = 8'he4;    8'h09: temp = 8'h85;    8'h0a: temp = 8'h57;    8'h0b: temp = 8'h35;    
      8'h0c: temp = 8'hea;    8'h0d: temp = 8'h0c;    8'h0e: temp = 8'hae;    8'h0f: temp = 8'h41;    
      8'h10: temp = 8'h23;    8'h11: temp = 8'hef;    8'h12: temp = 8'h6b;    8'h13: temp = 8'h93;    
      8'h14: temp = 8'h45;    8'h15: temp = 8'h19;    8'h16: temp = 8'ha5;    8'h17: temp = 8'h21;    
      8'h18: temp = 8'hed;    8'h19: temp = 8'h0e;    8'h1a: temp = 8'h4f;    8'h1b: temp = 8'h4e;    
      8'h1c: temp = 8'h1d;    8'h1d: temp = 8'h65;    8'h1e: temp = 8'h92;    8'h1f: temp = 8'hbd;    
      8'h20: temp = 8'h86;    8'h21: temp = 8'hb8;    8'h22: temp = 8'haf;    8'h23: temp = 8'h8f;    
      8'h24: temp = 8'h7c;    8'h25: temp = 8'heb;    8'h26: temp = 8'h1f;    8'h27: temp = 8'hce;    
      8'h28: temp = 8'h3e;    8'h29: temp = 8'h30;    8'h2a: temp = 8'hdc;    8'h2b: temp = 8'h5f;    
      8'h2c: temp = 8'h5e;    8'h2d: temp = 8'hc5;    8'h2e: temp = 8'h0b;    8'h2f: temp = 8'h1a;    
      8'h30: temp = 8'ha6;    8'h31: temp = 8'he1;    8'h32: temp = 8'h39;    8'h33: temp = 8'hca;    
      8'h34: temp = 8'hd5;    8'h35: temp = 8'h47;    8'h36: temp = 8'h5d;    8'h37: temp = 8'h3d;    
      8'h38: temp = 8'hd9;    8'h39: temp = 8'h01;    8'h3a: temp = 8'h5a;    8'h3b: temp = 8'hd6;    
      8'h3c: temp = 8'h51;    8'h3d: temp = 8'h56;    8'h3e: temp = 8'h6c;    8'h3f: temp = 8'h4d;    
      8'h40: temp = 8'h8b;    8'h41: temp = 8'h0d;    8'h42: temp = 8'h9a;    8'h43: temp = 8'h66;    
      8'h44: temp = 8'hfb;    8'h45: temp = 8'hcc;    8'h46: temp = 8'hb0;    8'h47: temp = 8'h2d;    
      8'h48: temp = 8'h74;    8'h49: temp = 8'h12;    8'h4a: temp = 8'h2b;    8'h4b: temp = 8'h20;    
      8'h4c: temp = 8'hf0;    8'h4d: temp = 8'hb1;    8'h4e: temp = 8'h84;    8'h4f: temp = 8'h99;    
      8'h50: temp = 8'hdf;    8'h51: temp = 8'h4c;    8'h52: temp = 8'hcb;    8'h53: temp = 8'hc2;    
      8'h54: temp = 8'h34;    8'h55: temp = 8'h7e;    8'h56: temp = 8'h76;    8'h57: temp = 8'h05;    
      8'h58: temp = 8'h6d;    8'h59: temp = 8'hb7;    8'h5a: temp = 8'ha9;    8'h5b: temp = 8'h31;    
      8'h5c: temp = 8'hd1;    8'h5d: temp = 8'h17;    8'h5e: temp = 8'h04;    8'h5f: temp = 8'hd7;    
      8'h60: temp = 8'h14;    8'h61: temp = 8'h58;    8'h62: temp = 8'h3a;    8'h63: temp = 8'h61;    
      8'h64: temp = 8'hde;    8'h65: temp = 8'h1b;    8'h66: temp = 8'h11;    8'h67: temp = 8'h1c;    
      8'h68: temp = 8'h32;    8'h69: temp = 8'h0f;    8'h6a: temp = 8'h9c;    8'h6b: temp = 8'h16;    
      8'h6c: temp = 8'h53;    8'h6d: temp = 8'h18;    8'h6e: temp = 8'hf2;    8'h6f: temp = 8'h22;    
      8'h70: temp = 8'hfe;    8'h71: temp = 8'h44;    8'h72: temp = 8'hcf;    8'h73: temp = 8'hb2;    
      8'h74: temp = 8'hc3;    8'h75: temp = 8'hb5;    8'h76: temp = 8'h7a;    8'h77: temp = 8'h91;    
      8'h78: temp = 8'h24;    8'h79: temp = 8'h08;    8'h7a: temp = 8'he8;    8'h7b: temp = 8'ha8;    
      8'h7c: temp = 8'h60;    8'h7d: temp = 8'hfc;    8'h7e: temp = 8'h69;    8'h7f: temp = 8'h50;    
      8'h80: temp = 8'haa;    8'h81: temp = 8'hd0;    8'h82: temp = 8'ha0;    8'h83: temp = 8'h7d;    
      8'h84: temp = 8'ha1;    8'h85: temp = 8'h89;    8'h86: temp = 8'h62;    8'h87: temp = 8'h97;    
      8'h88: temp = 8'h54;    8'h89: temp = 8'h5b;    8'h8a: temp = 8'h1e;    8'h8b: temp = 8'h95;    
      8'h8c: temp = 8'he0;    8'h8d: temp = 8'hff;    8'h8e: temp = 8'h64;    8'h8f: temp = 8'hd2;    
      8'h90: temp = 8'h10;    8'h91: temp = 8'hc4;    8'h92: temp = 8'h00;    8'h93: temp = 8'h48;    
      8'h94: temp = 8'ha3;    8'h95: temp = 8'hf7;    8'h96: temp = 8'h75;    8'h97: temp = 8'hdb;    
      8'h98: temp = 8'h8a;    8'h99: temp = 8'h03;    8'h9a: temp = 8'he6;    8'h9b: temp = 8'hda;    
      8'h9c: temp = 8'h09;    8'h9d: temp = 8'h3f;    8'h9e: temp = 8'hdd;    8'h9f: temp = 8'h94;    
      8'ha0: temp = 8'h87;    8'ha1: temp = 8'h5c;    8'ha2: temp = 8'h83;    8'ha3: temp = 8'h02;    
      8'ha4: temp = 8'hcd;    8'ha5: temp = 8'h4a;    8'ha6: temp = 8'h90;    8'ha7: temp = 8'h33;    
      8'ha8: temp = 8'h73;    8'ha9: temp = 8'h67;    8'haa: temp = 8'hf6;    8'hab: temp = 8'hf3;    
      8'hac: temp = 8'h9d;    8'had: temp = 8'h7f;    8'hae: temp = 8'hbf;    8'haf: temp = 8'he2;    
      8'hb0: temp = 8'h52;    8'hb1: temp = 8'h9b;    8'hb2: temp = 8'hd8;    8'hb3: temp = 8'h26;    
      8'hb4: temp = 8'hc8;    8'hb5: temp = 8'h37;    8'hb6: temp = 8'hc6;    8'hb7: temp = 8'h3b;    
      8'hb8: temp = 8'h81;    8'hb9: temp = 8'h96;    8'hba: temp = 8'h6f;    8'hbb: temp = 8'h4b;    
      8'hbc: temp = 8'h13;    8'hbd: temp = 8'hbe;    8'hbe: temp = 8'h63;    8'hbf: temp = 8'h2e;    
      8'hc0: temp = 8'he9;    8'hc1: temp = 8'h79;    8'hc2: temp = 8'ha7;    8'hc3: temp = 8'h8c;    
      8'hc4: temp = 8'h9f;    8'hc5: temp = 8'h6e;    8'hc6: temp = 8'hbc;    8'hc7: temp = 8'h8e;    
      8'hc8: temp = 8'h29;    8'hc9: temp = 8'hf5;    8'hca: temp = 8'hf9;    8'hcb: temp = 8'hb6;    
      8'hcc: temp = 8'h2f;    8'hcd: temp = 8'hfd;    8'hce: temp = 8'hb4;    8'hcf: temp = 8'h59;    
      8'hd0: temp = 8'h78;    8'hd1: temp = 8'h98;    8'hd2: temp = 8'h06;    8'hd3: temp = 8'h6a;    
      8'hd4: temp = 8'he7;    8'hd5: temp = 8'h46;    8'hd6: temp = 8'h71;    8'hd7: temp = 8'hba;    
      8'hd8: temp = 8'hd4;    8'hd9: temp = 8'h25;    8'hda: temp = 8'hab;    8'hdb: temp = 8'h42;    
      8'hdc: temp = 8'h88;    8'hdd: temp = 8'ha2;    8'hde: temp = 8'h8d;    8'hdf: temp = 8'hfa;    
      8'he0: temp = 8'h72;    8'he1: temp = 8'h07;    8'he2: temp = 8'hb9;    8'he3: temp = 8'h55;    
      8'he4: temp = 8'hf8;    8'he5: temp = 8'hee;    8'he6: temp = 8'hac;    8'he7: temp = 8'h0a;    
      8'he8: temp = 8'h36;    8'he9: temp = 8'h49;    8'hea: temp = 8'h2a;    8'heb: temp = 8'h68;    
      8'hec: temp = 8'h3c;    8'hed: temp = 8'h38;    8'hee: temp = 8'hf1;    8'hef: temp = 8'ha4;    
      8'hf0: temp = 8'h40;    8'hf1: temp = 8'h28;    8'hf2: temp = 8'hd3;    8'hf3: temp = 8'h7b;    
      8'hf4: temp = 8'hbb;    8'hf5: temp = 8'hc9;    8'hf6: temp = 8'h43;    8'hf7: temp = 8'hc1;    
      8'hf8: temp = 8'h15;    8'hf9: temp = 8'he3;    8'hfa: temp = 8'had;    8'hfb: temp = 8'hf4;    
      8'hfc: temp = 8'h77;    8'hfd: temp = 8'hc7;    8'hfe: temp = 8'h80;    default: temp = 8'h9e;    
    endcase // case(in)
  endfunction // temp
endmodule // sbox1

module sbox2(in, out);
  input [7:0] in;
  output [7:0] out;

  assign       out = temp(in);
  
  function [7:0] temp;
    input [7:0] in;

    case(in)
      8'h00: temp = 8'he0;    8'h01: temp = 8'h05;    8'h02: temp = 8'h58;    8'h03: temp = 8'hd9;    
      8'h04: temp = 8'h67;    8'h05: temp = 8'h4e;    8'h06: temp = 8'h81;    8'h07: temp = 8'hcb;    
      8'h08: temp = 8'hc9;    8'h09: temp = 8'h0b;    8'h0a: temp = 8'hae;    8'h0b: temp = 8'h6a;    
      8'h0c: temp = 8'hd5;    8'h0d: temp = 8'h18;    8'h0e: temp = 8'h5d;    8'h0f: temp = 8'h82;    
      8'h10: temp = 8'h46;    8'h11: temp = 8'hdf;    8'h12: temp = 8'hd6;    8'h13: temp = 8'h27;    
      8'h14: temp = 8'h8a;    8'h15: temp = 8'h32;    8'h16: temp = 8'h4b;    8'h17: temp = 8'h42;    
      8'h18: temp = 8'hdb;    8'h19: temp = 8'h1c;    8'h1a: temp = 8'h9e;    8'h1b: temp = 8'h9c;    
      8'h1c: temp = 8'h3a;    8'h1d: temp = 8'hca;    8'h1e: temp = 8'h25;    8'h1f: temp = 8'h7b;    
      8'h20: temp = 8'h0d;    8'h21: temp = 8'h71;    8'h22: temp = 8'h5f;    8'h23: temp = 8'h1f;    
      8'h24: temp = 8'hf8;    8'h25: temp = 8'hd7;    8'h26: temp = 8'h3e;    8'h27: temp = 8'h9d;    
      8'h28: temp = 8'h7c;    8'h29: temp = 8'h60;    8'h2a: temp = 8'hb9;    8'h2b: temp = 8'hbe;    
      8'h2c: temp = 8'hbc;    8'h2d: temp = 8'h8b;    8'h2e: temp = 8'h16;    8'h2f: temp = 8'h34;    
      8'h30: temp = 8'h4d;    8'h31: temp = 8'hc3;    8'h32: temp = 8'h72;    8'h33: temp = 8'h95;    
      8'h34: temp = 8'hab;    8'h35: temp = 8'h8e;    8'h36: temp = 8'hba;    8'h37: temp = 8'h7a;    
      8'h38: temp = 8'hb3;    8'h39: temp = 8'h02;    8'h3a: temp = 8'hb4;    8'h3b: temp = 8'had;    
      8'h3c: temp = 8'ha2;    8'h3d: temp = 8'hac;    8'h3e: temp = 8'hd8;    8'h3f: temp = 8'h9a;    
      8'h40: temp = 8'h17;    8'h41: temp = 8'h1a;    8'h42: temp = 8'h35;    8'h43: temp = 8'hcc;    
      8'h44: temp = 8'hf7;    8'h45: temp = 8'h99;    8'h46: temp = 8'h61;    8'h47: temp = 8'h5a;    
      8'h48: temp = 8'he8;    8'h49: temp = 8'h24;    8'h4a: temp = 8'h56;    8'h4b: temp = 8'h40;    
      8'h4c: temp = 8'he1;    8'h4d: temp = 8'h63;    8'h4e: temp = 8'h09;    8'h4f: temp = 8'h33;    
      8'h50: temp = 8'hbf;    8'h51: temp = 8'h98;    8'h52: temp = 8'h97;    8'h53: temp = 8'h85;    
      8'h54: temp = 8'h68;    8'h55: temp = 8'hfc;    8'h56: temp = 8'hec;    8'h57: temp = 8'h0a;    
      8'h58: temp = 8'hda;    8'h59: temp = 8'h6f;    8'h5a: temp = 8'h53;    8'h5b: temp = 8'h62;    
      8'h5c: temp = 8'ha3;    8'h5d: temp = 8'h2e;    8'h5e: temp = 8'h08;    8'h5f: temp = 8'haf;    
      8'h60: temp = 8'h28;    8'h61: temp = 8'hb0;    8'h62: temp = 8'h74;    8'h63: temp = 8'hc2;    
      8'h64: temp = 8'hbd;    8'h65: temp = 8'h36;    8'h66: temp = 8'h22;    8'h67: temp = 8'h38;    
      8'h68: temp = 8'h64;    8'h69: temp = 8'h1e;    8'h6a: temp = 8'h39;    8'h6b: temp = 8'h2c;    
      8'h6c: temp = 8'ha6;    8'h6d: temp = 8'h30;    8'h6e: temp = 8'he5;    8'h6f: temp = 8'h44;    
      8'h70: temp = 8'hfd;    8'h71: temp = 8'h88;    8'h72: temp = 8'h9f;    8'h73: temp = 8'h65;    
      8'h74: temp = 8'h87;    8'h75: temp = 8'h6b;    8'h76: temp = 8'hf4;    8'h77: temp = 8'h23;    
      8'h78: temp = 8'h48;    8'h79: temp = 8'h10;    8'h7a: temp = 8'hd1;    8'h7b: temp = 8'h51;    
      8'h7c: temp = 8'hc0;    8'h7d: temp = 8'hf9;    8'h7e: temp = 8'hd2;    8'h7f: temp = 8'ha0;    
      8'h80: temp = 8'h55;    8'h81: temp = 8'ha1;    8'h82: temp = 8'h41;    8'h83: temp = 8'hfa;    
      8'h84: temp = 8'h43;    8'h85: temp = 8'h13;    8'h86: temp = 8'hc4;    8'h87: temp = 8'h2f;    
      8'h88: temp = 8'ha8;    8'h89: temp = 8'hb6;    8'h8a: temp = 8'h3c;    8'h8b: temp = 8'h2b;    
      8'h8c: temp = 8'hc1;    8'h8d: temp = 8'hff;    8'h8e: temp = 8'hc8;    8'h8f: temp = 8'ha5;    
      8'h90: temp = 8'h20;    8'h91: temp = 8'h89;    8'h92: temp = 8'h00;    8'h93: temp = 8'h90;    
      8'h94: temp = 8'h47;    8'h95: temp = 8'hef;    8'h96: temp = 8'hea;    8'h97: temp = 8'hb7;    
      8'h98: temp = 8'h15;    8'h99: temp = 8'h06;    8'h9a: temp = 8'hcd;    8'h9b: temp = 8'hb5;    
      8'h9c: temp = 8'h12;    8'h9d: temp = 8'h7e;    8'h9e: temp = 8'hbb;    8'h9f: temp = 8'h29;    
      8'ha0: temp = 8'h0f;    8'ha1: temp = 8'hb8;    8'ha2: temp = 8'h07;    8'ha3: temp = 8'h04;    
      8'ha4: temp = 8'h9b;    8'ha5: temp = 8'h94;    8'ha6: temp = 8'h21;    8'ha7: temp = 8'h66;    
      8'ha8: temp = 8'he6;    8'ha9: temp = 8'hce;    8'haa: temp = 8'hed;    8'hab: temp = 8'he7;    
      8'hac: temp = 8'h3b;    8'had: temp = 8'hfe;    8'hae: temp = 8'h7f;    8'haf: temp = 8'hc5;    
      8'hb0: temp = 8'ha4;    8'hb1: temp = 8'h37;    8'hb2: temp = 8'hb1;    8'hb3: temp = 8'h4c;    
      8'hb4: temp = 8'h91;    8'hb5: temp = 8'h6e;    8'hb6: temp = 8'h8d;    8'hb7: temp = 8'h76;    
      8'hb8: temp = 8'h03;    8'hb9: temp = 8'h2d;    8'hba: temp = 8'hde;    8'hbb: temp = 8'h96;    
      8'hbc: temp = 8'h26;    8'hbd: temp = 8'h7d;    8'hbe: temp = 8'hc6;    8'hbf: temp = 8'h5c;    
      8'hc0: temp = 8'hd3;    8'hc1: temp = 8'hf2;    8'hc2: temp = 8'h4f;    8'hc3: temp = 8'h19;    
      8'hc4: temp = 8'h3f;    8'hc5: temp = 8'hdc;    8'hc6: temp = 8'h79;    8'hc7: temp = 8'h1d;    
      8'hc8: temp = 8'h52;    8'hc9: temp = 8'heb;    8'hca: temp = 8'hf3;    8'hcb: temp = 8'h6d;    
      8'hcc: temp = 8'h5e;    8'hcd: temp = 8'hfb;    8'hce: temp = 8'h69;    8'hcf: temp = 8'hb2;    
      8'hd0: temp = 8'hf0;    8'hd1: temp = 8'h31;    8'hd2: temp = 8'h0c;    8'hd3: temp = 8'hd4;    
      8'hd4: temp = 8'hcf;    8'hd5: temp = 8'h8c;    8'hd6: temp = 8'he2;    8'hd7: temp = 8'h75;    
      8'hd8: temp = 8'ha9;    8'hd9: temp = 8'h4a;    8'hda: temp = 8'h57;    8'hdb: temp = 8'h84;    
      8'hdc: temp = 8'h11;    8'hdd: temp = 8'h45;    8'hde: temp = 8'h1b;    8'hdf: temp = 8'hf5;    
      8'he0: temp = 8'he4;    8'he1: temp = 8'h0e;    8'he2: temp = 8'h73;    8'he3: temp = 8'haa;    
      8'he4: temp = 8'hf1;    8'he5: temp = 8'hdd;    8'he6: temp = 8'h59;    8'he7: temp = 8'h14;    
      8'he8: temp = 8'h6c;    8'he9: temp = 8'h92;    8'hea: temp = 8'h54;    8'heb: temp = 8'hd0;    
      8'hec: temp = 8'h78;    8'hed: temp = 8'h70;    8'hee: temp = 8'he3;    8'hef: temp = 8'h49;    
      8'hf0: temp = 8'h80;    8'hf1: temp = 8'h50;    8'hf2: temp = 8'ha7;    8'hf3: temp = 8'hf6;    
      8'hf4: temp = 8'h77;    8'hf5: temp = 8'h93;    8'hf6: temp = 8'h86;    8'hf7: temp = 8'h83;    
      8'hf8: temp = 8'h2a;    8'hf9: temp = 8'hc7;    8'hfa: temp = 8'h5b;    8'hfb: temp = 8'he9;    
      8'hfc: temp = 8'hee;    8'hfd: temp = 8'h8f;    8'hfe: temp = 8'h01;    default: temp = 8'h3d;    
    endcase // case(in)
  endfunction // temp
endmodule // sbox2


module sbox3(in, out);
  input [7:0] in;
  output [7:0] out;

  assign       out = temp(in);
  
  function [7:0] temp;
    input [7:0] in;
    case(in)
      8'h00: temp = 8'h38;    8'h01: temp = 8'h41;    8'h02: temp = 8'h16;    8'h03: temp = 8'h76;    
      8'h04: temp = 8'hd9;    8'h05: temp = 8'h93;    8'h06: temp = 8'h60;    8'h07: temp = 8'hf2;    
      8'h08: temp = 8'h72;    8'h09: temp = 8'hc2;    8'h0a: temp = 8'hab;    8'h0b: temp = 8'h9a;    
      8'h0c: temp = 8'h75;    8'h0d: temp = 8'h06;    8'h0e: temp = 8'h57;    8'h0f: temp = 8'ha0;    
      8'h10: temp = 8'h91;    8'h11: temp = 8'hf7;    8'h12: temp = 8'hb5;    8'h13: temp = 8'hc9;    
      8'h14: temp = 8'ha2;    8'h15: temp = 8'h8c;    8'h16: temp = 8'hd2;    8'h17: temp = 8'h90;    
      8'h18: temp = 8'hf6;    8'h19: temp = 8'h07;    8'h1a: temp = 8'ha7;    8'h1b: temp = 8'h27;    
      8'h1c: temp = 8'h8e;    8'h1d: temp = 8'hb2;    8'h1e: temp = 8'h49;    8'h1f: temp = 8'hde;    
      8'h20: temp = 8'h43;    8'h21: temp = 8'h5c;    8'h22: temp = 8'hd7;    8'h23: temp = 8'hc7;    
      8'h24: temp = 8'h3e;    8'h25: temp = 8'hf5;    8'h26: temp = 8'h8f;    8'h27: temp = 8'h67;    
      8'h28: temp = 8'h1f;    8'h29: temp = 8'h18;    8'h2a: temp = 8'h6e;    8'h2b: temp = 8'haf;    
      8'h2c: temp = 8'h2f;    8'h2d: temp = 8'he2;    8'h2e: temp = 8'h85;    8'h2f: temp = 8'h0d;    
      8'h30: temp = 8'h53;    8'h31: temp = 8'hf0;    8'h32: temp = 8'h9c;    8'h33: temp = 8'h65;    
      8'h34: temp = 8'hea;    8'h35: temp = 8'ha3;    8'h36: temp = 8'hae;    8'h37: temp = 8'h9e;    
      8'h38: temp = 8'hec;    8'h39: temp = 8'h80;    8'h3a: temp = 8'h2d;    8'h3b: temp = 8'h6b;    
      8'h3c: temp = 8'ha8;    8'h3d: temp = 8'h2b;    8'h3e: temp = 8'h36;    8'h3f: temp = 8'ha6;    
      8'h40: temp = 8'hc5;    8'h41: temp = 8'h86;    8'h42: temp = 8'h4d;    8'h43: temp = 8'h33;    
      8'h44: temp = 8'hfd;    8'h45: temp = 8'h66;    8'h46: temp = 8'h58;    8'h47: temp = 8'h96;    
      8'h48: temp = 8'h3a;    8'h49: temp = 8'h09;    8'h4a: temp = 8'h95;    8'h4b: temp = 8'h10;    
      8'h4c: temp = 8'h78;    8'h4d: temp = 8'hd8;    8'h4e: temp = 8'h42;    8'h4f: temp = 8'hcc;    
      8'h50: temp = 8'hef;    8'h51: temp = 8'h26;    8'h52: temp = 8'he5;    8'h53: temp = 8'h61;    
      8'h54: temp = 8'h1a;    8'h55: temp = 8'h3f;    8'h56: temp = 8'h3b;    8'h57: temp = 8'h82;    
      8'h58: temp = 8'hb6;    8'h59: temp = 8'hdb;    8'h5a: temp = 8'hd4;    8'h5b: temp = 8'h98;    
      8'h5c: temp = 8'he8;    8'h5d: temp = 8'h8b;    8'h5e: temp = 8'h02;    8'h5f: temp = 8'heb;    
      8'h60: temp = 8'h0a;    8'h61: temp = 8'h2c;    8'h62: temp = 8'h1d;    8'h63: temp = 8'hb0;    
      8'h64: temp = 8'h6f;    8'h65: temp = 8'h8d;    8'h66: temp = 8'h88;    8'h67: temp = 8'h0e;    
      8'h68: temp = 8'h19;    8'h69: temp = 8'h87;    8'h6a: temp = 8'h4e;    8'h6b: temp = 8'h0b;    
      8'h6c: temp = 8'ha9;    8'h6d: temp = 8'h0c;    8'h6e: temp = 8'h79;    8'h6f: temp = 8'h11;    
      8'h70: temp = 8'h7f;    8'h71: temp = 8'h22;    8'h72: temp = 8'he7;    8'h73: temp = 8'h59;    
      8'h74: temp = 8'he1;    8'h75: temp = 8'hda;    8'h76: temp = 8'h3d;    8'h77: temp = 8'hc8;    
      8'h78: temp = 8'h12;    8'h79: temp = 8'h04;    8'h7a: temp = 8'h74;    8'h7b: temp = 8'h54;    
      8'h7c: temp = 8'h30;    8'h7d: temp = 8'h7e;    8'h7e: temp = 8'hb4;    8'h7f: temp = 8'h28;    
      8'h80: temp = 8'h55;    8'h81: temp = 8'h68;    8'h82: temp = 8'h50;    8'h83: temp = 8'hbe;    
      8'h84: temp = 8'hd0;    8'h85: temp = 8'hc4;    8'h86: temp = 8'h31;    8'h87: temp = 8'hcb;    
      8'h88: temp = 8'h2a;    8'h89: temp = 8'had;    8'h8a: temp = 8'h0f;    8'h8b: temp = 8'hca;    
      8'h8c: temp = 8'h70;    8'h8d: temp = 8'hff;    8'h8e: temp = 8'h32;    8'h8f: temp = 8'h69;    
      8'h90: temp = 8'h08;    8'h91: temp = 8'h62;    8'h92: temp = 8'h00;    8'h93: temp = 8'h24;    
      8'h94: temp = 8'hd1;    8'h95: temp = 8'hfb;    8'h96: temp = 8'hba;    8'h97: temp = 8'hed;    
      8'h98: temp = 8'h45;    8'h99: temp = 8'h81;    8'h9a: temp = 8'h73;    8'h9b: temp = 8'h6d;    
      8'h9c: temp = 8'h84;    8'h9d: temp = 8'h9f;    8'h9e: temp = 8'hee;    8'h9f: temp = 8'h4a;    
      8'ha0: temp = 8'hc3;    8'ha1: temp = 8'h2e;    8'ha2: temp = 8'hc1;    8'ha3: temp = 8'h01;    
      8'ha4: temp = 8'he6;    8'ha5: temp = 8'h25;    8'ha6: temp = 8'h48;    8'ha7: temp = 8'h99;    
      8'ha8: temp = 8'hb9;    8'ha9: temp = 8'hb3;    8'haa: temp = 8'h7b;    8'hab: temp = 8'hf9;    
      8'hac: temp = 8'hce;    8'had: temp = 8'hbf;    8'hae: temp = 8'hdf;    8'haf: temp = 8'h71;    
      8'hb0: temp = 8'h29;    8'hb1: temp = 8'hcd;    8'hb2: temp = 8'h6c;    8'hb3: temp = 8'h13;    
      8'hb4: temp = 8'h64;    8'hb5: temp = 8'h9b;    8'hb6: temp = 8'h63;    8'hb7: temp = 8'h9d;    
      8'hb8: temp = 8'hc0;    8'hb9: temp = 8'h4b;    8'hba: temp = 8'hb7;    8'hbb: temp = 8'ha5;    
      8'hbc: temp = 8'h89;    8'hbd: temp = 8'h5f;    8'hbe: temp = 8'hb1;    8'hbf: temp = 8'h17;    
      8'hc0: temp = 8'hf4;    8'hc1: temp = 8'hbc;    8'hc2: temp = 8'hd3;    8'hc3: temp = 8'h46;    
      8'hc4: temp = 8'hcf;    8'hc5: temp = 8'h37;    8'hc6: temp = 8'h5e;    8'hc7: temp = 8'h47;    
      8'hc8: temp = 8'h94;    8'hc9: temp = 8'hfa;    8'hca: temp = 8'hfc;    8'hcb: temp = 8'h5b;    
      8'hcc: temp = 8'h97;    8'hcd: temp = 8'hfe;    8'hce: temp = 8'h5a;    8'hcf: temp = 8'hac;    
      8'hd0: temp = 8'h3c;    8'hd1: temp = 8'h4c;    8'hd2: temp = 8'h03;    8'hd3: temp = 8'h35;    
      8'hd4: temp = 8'hf3;    8'hd5: temp = 8'h23;    8'hd6: temp = 8'hb8;    8'hd7: temp = 8'h5d;    
      8'hd8: temp = 8'h6a;    8'hd9: temp = 8'h92;    8'hda: temp = 8'hd5;    8'hdb: temp = 8'h21;    
      8'hdc: temp = 8'h44;    8'hdd: temp = 8'h51;    8'hde: temp = 8'hc6;    8'hdf: temp = 8'h7d;    
      8'he0: temp = 8'h39;    8'he1: temp = 8'h83;    8'he2: temp = 8'hdc;    8'he3: temp = 8'haa;    
      8'he4: temp = 8'h7c;    8'he5: temp = 8'h77;    8'he6: temp = 8'h56;    8'he7: temp = 8'h05;    
      8'he8: temp = 8'h1b;    8'he9: temp = 8'ha4;    8'hea: temp = 8'h15;    8'heb: temp = 8'h34;    
      8'hec: temp = 8'h1e;    8'hed: temp = 8'h1c;    8'hee: temp = 8'hf8;    8'hef: temp = 8'h52;    
      8'hf0: temp = 8'h20;    8'hf1: temp = 8'h14;    8'hf2: temp = 8'he9;    8'hf3: temp = 8'hbd;    
      8'hf4: temp = 8'hdd;    8'hf5: temp = 8'he4;    8'hf6: temp = 8'ha1;    8'hf7: temp = 8'he0;    
      8'hf8: temp = 8'h8a;    8'hf9: temp = 8'hf1;    8'hfa: temp = 8'hd6;    8'hfb: temp = 8'h7a;    
      8'hfc: temp = 8'hbb;    8'hfd: temp = 8'he3;    8'hfe: temp = 8'h40;    default: temp = 8'h4f;    
    endcase // case(in)
  endfunction // temp
endmodule // sbox3

module sbox4(in, out);
  input [7:0] in;
  output [7:0] out;

  assign       out = temp(in);
  
  function [7:0] temp;
    input [7:0] in;

    case(in)
      8'h00: temp = 8'h70;    8'h01: temp = 8'h2c;    8'h02: temp = 8'hb3;    8'h03: temp = 8'hc0;    
      8'h04: temp = 8'he4;    8'h05: temp = 8'h57;    8'h06: temp = 8'hea;    8'h07: temp = 8'hae;    
      8'h08: temp = 8'h23;    8'h09: temp = 8'h6b;    8'h0a: temp = 8'h45;    8'h0b: temp = 8'ha5;    
      8'h0c: temp = 8'hed;    8'h0d: temp = 8'h4f;    8'h0e: temp = 8'h1d;    8'h0f: temp = 8'h92;    
      8'h10: temp = 8'h86;    8'h11: temp = 8'haf;    8'h12: temp = 8'h7c;    8'h13: temp = 8'h1f;    
      8'h14: temp = 8'h3e;    8'h15: temp = 8'hdc;    8'h16: temp = 8'h5e;    8'h17: temp = 8'h0b;    
      8'h18: temp = 8'ha6;    8'h19: temp = 8'h39;    8'h1a: temp = 8'hd5;    8'h1b: temp = 8'h5d;    
      8'h1c: temp = 8'hd9;    8'h1d: temp = 8'h5a;    8'h1e: temp = 8'h51;    8'h1f: temp = 8'h6c;    
      8'h20: temp = 8'h8b;    8'h21: temp = 8'h9a;    8'h22: temp = 8'hfb;    8'h23: temp = 8'hb0;    
      8'h24: temp = 8'h74;    8'h25: temp = 8'h2b;    8'h26: temp = 8'hf0;    8'h27: temp = 8'h84;    
      8'h28: temp = 8'hdf;    8'h29: temp = 8'hcb;    8'h2a: temp = 8'h34;    8'h2b: temp = 8'h76;    
      8'h2c: temp = 8'h6d;    8'h2d: temp = 8'ha9;    8'h2e: temp = 8'hd1;    8'h2f: temp = 8'h04;    
      8'h30: temp = 8'h14;    8'h31: temp = 8'h3a;    8'h32: temp = 8'hde;    8'h33: temp = 8'h11;    
      8'h34: temp = 8'h32;    8'h35: temp = 8'h9c;    8'h36: temp = 8'h53;    8'h37: temp = 8'hf2;    
      8'h38: temp = 8'hfe;    8'h39: temp = 8'hcf;    8'h3a: temp = 8'hc3;    8'h3b: temp = 8'h7a;    
      8'h3c: temp = 8'h24;    8'h3d: temp = 8'he8;    8'h3e: temp = 8'h60;    8'h3f: temp = 8'h69;    
      8'h40: temp = 8'haa;    8'h41: temp = 8'ha0;    8'h42: temp = 8'ha1;    8'h43: temp = 8'h62;    
      8'h44: temp = 8'h54;    8'h45: temp = 8'h1e;    8'h46: temp = 8'he0;    8'h47: temp = 8'h64;    
      8'h48: temp = 8'h10;    8'h49: temp = 8'h00;    8'h4a: temp = 8'ha3;    8'h4b: temp = 8'h75;    
      8'h4c: temp = 8'h8a;    8'h4d: temp = 8'he6;    8'h4e: temp = 8'h09;    8'h4f: temp = 8'hdd;    
      8'h50: temp = 8'h87;    8'h51: temp = 8'h83;    8'h52: temp = 8'hcd;    8'h53: temp = 8'h90;    
      8'h54: temp = 8'h73;    8'h55: temp = 8'hf6;    8'h56: temp = 8'h9d;    8'h57: temp = 8'hbf;    
      8'h58: temp = 8'h52;    8'h59: temp = 8'hd8;    8'h5a: temp = 8'hc8;    8'h5b: temp = 8'hc6;    
      8'h5c: temp = 8'h81;    8'h5d: temp = 8'h6f;    8'h5e: temp = 8'h13;    8'h5f: temp = 8'h63;    
      8'h60: temp = 8'he9;    8'h61: temp = 8'ha7;    8'h62: temp = 8'h9f;    8'h63: temp = 8'hbc;    
      8'h64: temp = 8'h29;    8'h65: temp = 8'hf9;    8'h66: temp = 8'h2f;    8'h67: temp = 8'hb4;    
      8'h68: temp = 8'h78;    8'h69: temp = 8'h06;    8'h6a: temp = 8'he7;    8'h6b: temp = 8'h71;    
      8'h6c: temp = 8'hd4;    8'h6d: temp = 8'hab;    8'h6e: temp = 8'h88;    8'h6f: temp = 8'h8d;    
      8'h70: temp = 8'h72;    8'h71: temp = 8'hb9;    8'h72: temp = 8'hf8;    8'h73: temp = 8'hac;    
      8'h74: temp = 8'h36;    8'h75: temp = 8'h2a;    8'h76: temp = 8'h3c;    8'h77: temp = 8'hf1;    
      8'h78: temp = 8'h40;    8'h79: temp = 8'hd3;    8'h7a: temp = 8'hbb;    8'h7b: temp = 8'h43;    
      8'h7c: temp = 8'h15;    8'h7d: temp = 8'had;    8'h7e: temp = 8'h77;    8'h7f: temp = 8'h80;    
      8'h80: temp = 8'h82;    8'h81: temp = 8'hec;    8'h82: temp = 8'h27;    8'h83: temp = 8'he5;    
      8'h84: temp = 8'h85;    8'h85: temp = 8'h35;    8'h86: temp = 8'h0c;    8'h87: temp = 8'h41;    
      8'h88: temp = 8'hef;    8'h89: temp = 8'h93;    8'h8a: temp = 8'h19;    8'h8b: temp = 8'h21;    
      8'h8c: temp = 8'h0e;    8'h8d: temp = 8'h4e;    8'h8e: temp = 8'h65;    8'h8f: temp = 8'hbd;    
      8'h90: temp = 8'hb8;    8'h91: temp = 8'h8f;    8'h92: temp = 8'heb;    8'h93: temp = 8'hce;    
      8'h94: temp = 8'h30;    8'h95: temp = 8'h5f;    8'h96: temp = 8'hc5;    8'h97: temp = 8'h1a;    
      8'h98: temp = 8'he1;    8'h99: temp = 8'hca;    8'h9a: temp = 8'h47;    8'h9b: temp = 8'h3d;    
      8'h9c: temp = 8'h01;    8'h9d: temp = 8'hd6;    8'h9e: temp = 8'h56;    8'h9f: temp = 8'h4d;    
      8'ha0: temp = 8'h0d;    8'ha1: temp = 8'h66;    8'ha2: temp = 8'hcc;    8'ha3: temp = 8'h2d;    
      8'ha4: temp = 8'h12;    8'ha5: temp = 8'h20;    8'ha6: temp = 8'hb1;    8'ha7: temp = 8'h99;    
      8'ha8: temp = 8'h4c;    8'ha9: temp = 8'hc2;    8'haa: temp = 8'h7e;    8'hab: temp = 8'h05;    
      8'hac: temp = 8'hb7;    8'had: temp = 8'h31;    8'hae: temp = 8'h17;    8'haf: temp = 8'hd7;    
      8'hb0: temp = 8'h58;    8'hb1: temp = 8'h61;    8'hb2: temp = 8'h1b;    8'hb3: temp = 8'h1c;    
      8'hb4: temp = 8'h0f;    8'hb5: temp = 8'h16;    8'hb6: temp = 8'h18;    8'hb7: temp = 8'h22;    
      8'hb8: temp = 8'h44;    8'hb9: temp = 8'hb2;    8'hba: temp = 8'hb5;    8'hbb: temp = 8'h91;    
      8'hbc: temp = 8'h08;    8'hbd: temp = 8'ha8;    8'hbe: temp = 8'hfc;    8'hbf: temp = 8'h50;    
      8'hc0: temp = 8'hd0;    8'hc1: temp = 8'h7d;    8'hc2: temp = 8'h89;    8'hc3: temp = 8'h97;    
      8'hc4: temp = 8'h5b;    8'hc5: temp = 8'h95;    8'hc6: temp = 8'hff;    8'hc7: temp = 8'hd2;    
      8'hc8: temp = 8'hc4;    8'hc9: temp = 8'h48;    8'hca: temp = 8'hf7;    8'hcb: temp = 8'hdb;    
      8'hcc: temp = 8'h03;    8'hcd: temp = 8'hda;    8'hce: temp = 8'h3f;    8'hcf: temp = 8'h94;    
      8'hd0: temp = 8'h5c;    8'hd1: temp = 8'h02;    8'hd2: temp = 8'h4a;    8'hd3: temp = 8'h33;    
      8'hd4: temp = 8'h67;    8'hd5: temp = 8'hf3;    8'hd6: temp = 8'h7f;    8'hd7: temp = 8'he2;    
      8'hd8: temp = 8'h9b;    8'hd9: temp = 8'h26;    8'hda: temp = 8'h37;    8'hdb: temp = 8'h3b;    
      8'hdc: temp = 8'h96;    8'hdd: temp = 8'h4b;    8'hde: temp = 8'hbe;    8'hdf: temp = 8'h2e;    
      8'he0: temp = 8'h79;    8'he1: temp = 8'h8c;    8'he2: temp = 8'h6e;    8'he3: temp = 8'h8e;    
      8'he4: temp = 8'hf5;    8'he5: temp = 8'hb6;    8'he6: temp = 8'hfd;    8'he7: temp = 8'h59;    
      8'he8: temp = 8'h98;    8'he9: temp = 8'h6a;    8'hea: temp = 8'h46;    8'heb: temp = 8'hba;    
      8'hec: temp = 8'h25;    8'hed: temp = 8'h42;    8'hee: temp = 8'ha2;    8'hef: temp = 8'hfa;    
      8'hf0: temp = 8'h07;    8'hf1: temp = 8'h55;    8'hf2: temp = 8'hee;    8'hf3: temp = 8'h0a;    
      8'hf4: temp = 8'h49;    8'hf5: temp = 8'h68;    8'hf6: temp = 8'h38;    8'hf7: temp = 8'ha4;    
      8'hf8: temp = 8'h28;    8'hf9: temp = 8'h7b;    8'hfa: temp = 8'hc9;    8'hfb: temp = 8'hc1;    
      8'hfc: temp = 8'he3;    8'hfd: temp = 8'hf4;    8'hfe: temp = 8'hc7;    default: temp = 8'h9e;    
    endcase // case(in)
  endfunction // temp
endmodule // sbox4
