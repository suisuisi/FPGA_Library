/*-------------------------------------------------------------------------
 Camellia Encryption/Decryption Macro
 (Composite field version)
  
 File name   : CamelliaComp.v
 Version     : Version 1.0
 Created     : JUN/02/2007
 Last update : AUG/3/2007
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


// Idle state
`define IDLE                  4'h0
`define IDLE_READY            4'h1

// Key-schedule state
`define KEY_GET               4'h3
`define KEY_F_FUNC            4'h4
`define KEY_XOR               4'h5

// Encryption state
`define RANDOMIZE_GET         4'h7
`define RANDOMIZE_INITIAL_XOR 4'h8
`define RANDOMIZE_FINAL_XOR   4'h9
`define RANDOMIZE_F_FUNC      4'ha
`define RANDOMIZE_FL_1        4'hb
`define RANDOMIZE_FL_2        4'hc

// A value indicate whether encryption or decryption
`define ENCRYPT               1'b0
`define DECRYPT               1'b1

// Constant values used in key-scheduling.
`define SIGMA1                64'ha09e667f3bcc908b
`define SIGMA2                64'hb67ae8584caa73b2
`define SIGMA3                64'hc6ef372fe94f82be
`define SIGMA4                64'h54ff53a5f1d36f1c


module top( data_out,
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
  
  sequencer     sequencer(// Outputs
			  .state		(state[3:0]),
			  .round		(round[4:0]),
			  // Inputs
			  .clk			(clk),
			  .nreset		(nreset),
			  .data_rdy		(data_rdy),
			  .key_rdy		(key_rdy));

  key_scheduler key_scheduler( .kl_in(key_in),
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
			     // Outputs
			     .data_out		(data_out[127:0]),
			     // Inputs
			     .clk		(clk),
			     .nreset		(nreset),
			     .state		(state[3:0]),
			     .round		(round[4:0]),
			     .data_in		(data_in[127:0]),
			     .key_in		(key_in[127:0]),
			     .kl		(kl[127:0]),
			     .ka		(ka[127:0]),
			     .en_de		(en_de));
endmodule // top


module sequencer(// Outputs
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
	// Idle state
	`IDLE:
	  if(key_rdy == 1'b1)
	    state <= `KEY_GET;
	
	`IDLE_READY:
	  if(key_rdy == 1'b1)
	    state <= `KEY_GET;
	  else if(data_rdy == 1'b1)
	    state <= `RANDOMIZE_GET;

	// Key-schedule states
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

	// Data randomization states
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


module key_scheduler(// Outputs
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

  wire [127:0] 	 kl_rotate_left_15,  ka_rotate_left_15;  
  wire [127:0] 	 kl_rotate_left_17,  ka_rotate_left_17;  
  wire [127:0] 	 kl_rotate_right_15, ka_rotate_right_15; 
  wire [127:0] 	 kl_rotate_right_17, ka_rotate_right_17; 

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

	// Additional rotation in the final round
	// adjust KA and KL to the initial position.
	`RANDOMIZE_FINAL_XOR: begin
	  if(en_de_reg == `ENCRYPT) begin
	    kl <= kl_rotate_left_17;
	    ka <= ka_rotate_left_17;
	  end
	end
	
      endcase // case(state)

  end // always @ (posedge clk)
endmodule


module randomize(// Outputs
		 data_out, ka_out,
		 // Inputs
		 clk, nreset, state, round, data_in, key_in, kl, ka, en_de
		 );
  input          clk, nreset;
  input [3:0] 	 state;
  input [4:0] 	 round;
  input [127:0]  data_in, key_in;
  input [127:0]  kl, ka;     // intermediate keys
  input 	 en_de;
  output [127:0] data_out;
  output [127:0] ka_out;
  
  reg [127:0] 	 data_out;
  reg 		 en_de_reg;
  
  wire [63:0] 	 f_func_out;       // Output of F-function
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
	// load data preparing for key scheduling
	`KEY_GET                                              : data_out <= key_in;
	`KEY_F_FUNC                                           : data_out <= feistel_out;
	`KEY_XOR, `RANDOMIZE_INITIAL_XOR, `RANDOMIZE_FINAL_XOR: data_out <= xor_out;
	`RANDOMIZE_GET                                        : data_out <= data_in;
	`RANDOMIZE_FL_1, `RANDOMIZE_FL_2                      : data_out <= fl_out;
	`RANDOMIZE_F_FUNC:
	  // No data crossing in the final round
	  if(round == 5'd18)
	    data_out <= {feistel_out[63:0], feistel_out[127:64]};
	  else
	    data_out <= feistel_out;
	
      endcase // case(state)
  end

  // a register to indicate whether encryption or decryption
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


// F-function
module f_func(in, out, key);
  input  [63:0] in;
  input [63:0] 	key;
  output [63:0] out;

  wire [63:0] 	sbox_in;
  wire [7:0] 	y1, y2, y3, y4, y5, y6, y7, y8; // input of a S-box
  wire [7:0] 	z1, z2, z3, z4, z5, z6, z7, z8; // output of a S-box

  assign 	sbox_in = in ^ key;

  assign 	y1 = sbox_in[63:56], y2 = sbox_in[55:48], y3 = sbox_in[47:40], y4 = sbox_in[39:32];
  assign 	y5 = sbox_in[31:24], y6 = sbox_in[23:16], y7 = sbox_in[15:8] , y8 = sbox_in[7:0];

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


// P-function
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


// FL / FL^{-1} function
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


// FL function
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


// FL^{-1} function
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


/*
 Arithmetic unit of inversion over GF(2^4^2)
 Reference:
   J. Fan and C. Paar, "On Efficient Inversion in Tower Fields of
   Characteristic Two," ISIT 1997
 */
module inv_gf242(in, out);
  input  [7:0] in;
  output [7:0] out;

  wire [3:0] a0, a1, b0, b1;

  wire [3:0] a0_a1;          // a0 + a1
  wire [3:0] a1a1;           // a1 * a1
  wire [3:0] p0a1a1;         // p0 * a1 * a1
  wire [3:0] a0a0_a0a1;      // a0 ( a0 + a1 )
  wire [3:0] delta, inv_delta;

  assign {a1, a0} = in;

  assign a0_a1 = a0 ^ a1;  
  assign a1a1 = sqrt_gf24(a1);
  assign p0a1a1 = constant_mult_gf24(a1a1);
  assign a0a0_a0a1 = mult_gf24(a0, a0_a1);

  assign delta = a0a0_a0a1 ^ p0a1a1;
  assign inv_delta = inv_gf24(delta);

  assign b0 = mult_gf24(a0_a1, inv_delta);
  assign b1 = mult_gf24(a1, inv_delta);

  assign out = {b1, b0};

  function [3:0] sqrt_gf24;
    input [3:0] in;
    begin
      sqrt_gf24[0] = in[0] ^ in[2];
      sqrt_gf24[1] = in[2];
      sqrt_gf24[2] = in[1] ^ in[3];
      sqrt_gf24[3] = in[3];
    end
  endfunction // sqrt_gf24

  function [3:0] mult_gf24;
    input [3:0] A, B;
    begin
      mult_gf24[0] = (A[0]&B[0]) ^ (A[3]&B[1]) ^ (A[2]&B[2]) ^ (A[1]&B[3]);
      mult_gf24[1] = (A[1]&B[0]) ^ (A[0]&B[1]) ^ (A[3]&B[1]) ^ (A[2]&B[2]) ^ (A[3]&B[2]) ^ (A[1]&B[3]) ^ (A[2]&B[3]);
      mult_gf24[2] = (A[2]&B[0]) ^ (A[1]&B[1]) ^ (A[0]&B[2]) ^ (A[3]&B[2]) ^ (A[2]&B[3]) ^ (A[3]&B[3]);
      mult_gf24[3] = (A[3]&B[0]) ^ (A[2]&B[1]) ^ (A[1]&B[2]) ^ (A[0]&B[3]) ^ (A[3]&B[3]);
    end
  endfunction // mult_gf24

  // Constant multiplication by p0
  // Note that p0 = Lambda  = {1001}
  function [3:0] constant_mult_gf24;
    input [3:0] in;
    begin
      constant_mult_gf24[0] = in[0] ^ in[1];
      constant_mult_gf24[1] = in[2];
      constant_mult_gf24[2] = in[3];
      constant_mult_gf24[3] = in[0];
    end
  endfunction // constant_mult_gf24

  function [3:0] inv_gf24;
    input [3:0] in;
    case(in)
      4'b0000: inv_gf24 = 4'b0000;
      4'b0001: inv_gf24 = 4'b0001;
      4'b0010: inv_gf24 = 4'b1001;
      4'b0011: inv_gf24 = 4'b1110;
      4'b0100: inv_gf24 = 4'b1101;
      4'b0101: inv_gf24 = 4'b1011;
      4'b0110: inv_gf24 = 4'b0111;
      4'b0111: inv_gf24 = 4'b0110;
      4'b1000: inv_gf24 = 4'b1111;
      4'b1001: inv_gf24 = 4'b0010;
      4'b1010: inv_gf24 = 4'b1100;
      4'b1011: inv_gf24 = 4'b0101;
      4'b1100: inv_gf24 = 4'b1010;
      4'b1101: inv_gf24 = 4'b0100;
      4'b1110: inv_gf24 = 4'b0011;
      4'b1111: inv_gf24 = 4'b1000;
      default: inv_gf24 = 4'b0000;
    endcase // case(in)
  endfunction // inv_gf24
endmodule // inv_gf242


// S-box1 is defined as h( g( f(0xc5 ^ x) ) ) ^ 0x6e
// See p.13 - 14 of algorithm specification for more details.
module sbox1(in, out);
  input  [7:0] in;
  output [7:0] out;

  wire [7:0] 	B, x, z, k, J, I, v, c;

  wire [7:0] f_out, g_out, h_out;
  assign f_out = f( in ^ 8'hc5 );

  inv_gf242 inv_gf242( .in(f_out), .out(g_out) );

  assign h_out = h( g_out );
  assign out = h_out ^ 8'h6e;

  // Note that endian is changed
  function [1:8] f;
    input [1:8] in;
    begin
      f[1] = in[6] ^ in[2];
      f[2] = in[7] ^ in[1];
      f[3] = in[8] ^ in[5] ^ in[3];
      f[4] = in[8] ^ in[3];
      f[5] = in[7] ^ in[4];
      f[6] = in[5] ^ in[2];
      f[7] = in[8] ^ in[1];
      f[8] = in[6] ^ in[4];
    end
  endfunction // f

  function [1:8] h;
    input [1:8] in;
    begin
      h[1] = in[5] ^ in[6] ^ in[2];
      h[2] = in[6] ^ in[2];
      h[3] = in[7] ^ in[4];
      h[4] = in[8] ^ in[2];
      h[5] = in[7] ^ in[3];
      h[6] = in[8] ^ in[1];
      h[7] = in[5] ^ in[1];
      h[8] = in[6] ^ in[3];
    end
  endfunction // h

endmodule // sbox1


module sbox2(in, out);
  input  [7:0] in;
  output [7:0] out;
  sbox1 sbox1(in, {out[0], out[7:1]} );
endmodule // sbox2


module sbox3(in, out);
  input  [7:0] in;
  output [7:0] out;
  sbox1 sbox1(in, {out[6:0], out[7]} );
endmodule // sbox3


module sbox4(in, out);
  input  [7:0] in;
  output [7:0] out;
  sbox1 sbox1( {in[6:0], in[7]}, out );
endmodule // sbox4
