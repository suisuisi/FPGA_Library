/*-------------------------------------------------------------------------
 CAST-128 Encryption/Decryption Macro
                                   
 File name   : CAST128.v
 Version     : Version 1.0
 Created     : AUG/28/2006
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


`define INITIAL      3'b000
`define IDLE         3'b001
`define KEY_SCHEDULE 3'b011
`define ENCRYPTION   3'b111
`define DECRYPTION   3'b101

`define ENC 1'b0
`define DEC 1'b1  

`define KEY_SCHEDULE_FINAL_ROUND 7'b1111111
`define ENC_DEC_FINAL_ROUND 7'h0f

`define ASX_ADD 2'b10
`define ASX_SUB 2'b11
`define ASX_XOR 2'b00

module top( clk, nreset, 
	    data_rdy, key_rdy, en_de,
	    data_in, key_in,
	    busy, data_valid, key_valid,
	    data_out );

  input clk, nreset;
  input data_rdy, key_rdy, en_de;
  input [63:0]  data_in;
  input [127:0] key_in;

  output 	busy, data_valid, key_valid;
  output [63:0] data_out;
  
  wire [31:0] 	km_selected;
  wire [4:0] 	kr_selected;

  wire [2:0] 	state;
  wire [6:0] 	round;
  
  sequencer sequencer(/*AUTOINST*/
		      // Outputs
		      .state		(state[2:0]),
		      .round		(round[6:0]),
		      .busy		(busy),
		      .data_valid	(data_valid),
		      .key_valid	(key_valid),
		      // Inputs
		      .clk		(clk),
		      .nreset		(nreset),
		      .data_rdy		(data_rdy),
		      .key_rdy		(key_rdy),
		      .en_de		(en_de));

  encrypt encrypt(/*AUTOINST*/
		  // Outputs
		  .data_out		(data_out[63:0]),
		  // Inputs
		  .clk			(clk),
		  .nreset		(nreset),
		  .data_rdy		(data_rdy),
		  .data_in		(data_in[63:0]),
		  .state		(state[2:0]),
		  .round		(round[6:0]),
		  .km_selected		(km_selected[31:0]),
		  .kr_selected		(kr_selected[4:0]));
		      
  key_scheduler key_scheduler(/*AUTOINST*/
			      // Outputs
			      .km_selected	(km_selected[31:0]),
			      .kr_selected	(kr_selected[4:0]),
			      // Inputs
			      .clk		(clk),
			      .nreset		(nreset),
			      .key_in		(key_in[127:0]),
			      .state		(state[2:0]),
			      .round		(round[6:0]),
			      .key_rdy		(key_rdy));
endmodule // top

// CAST-128 のシーケンサ  
module sequencer( clk, nreset,
		  data_rdy, key_rdy, en_de,
		  state, round,
		  busy, data_valid, key_valid );
  input clk, nreset;
  
  input data_rdy; // start encryption/decryption
  input key_rdy;  // start key scheduling
  input en_de;    // select encryption or decryption

  output [2:0] state;   // state
  output [6:0] round;   // round number

  output busy;       
  output data_valid; 
  output key_valid;  // the flag: subkeys are ready 

  reg [2:0] state;
  reg [6:0] round;

  reg 	    busy, data_valid, key_valid;
  
  // state
  always @(posedge clk) begin
    if (nreset == 1'b0) state <= `INITIAL;
    else begin
      case(state)
	`INITIAL:      state <= (key_rdy == 1'b0)                    ? `IDLE : `KEY_SCHEDULE;
	`KEY_SCHEDULE: state <= (round == `KEY_SCHEDULE_FINAL_ROUND) ? `IDLE : `KEY_SCHEDULE;
	`ENCRYPTION:   state <= (round == `ENC_DEC_FINAL_ROUND)      ? `IDLE : `ENCRYPTION;
	`DECRYPTION:   state <= (round == `ENC_DEC_FINAL_ROUND)      ? `IDLE : `DECRYPTION;
	default: // `IDLE
	  if(key_rdy == 1'b1)
	    state <= `KEY_SCHEDULE;
	  else if(data_rdy == 1'b1)
	    state <= (en_de == `ENC) ? `ENCRYPTION : `DECRYPTION;
	  else
	    state <= `IDLE;
      endcase // case(state)
    end
  end

  // round
  always @(posedge clk) begin
    if (nreset == 1'b0) begin
      round <= 7'h00;
    end
    else begin
      case(state)
	`KEY_SCHEDULE:
	  round <= (round == `KEY_SCHEDULE_FINAL_ROUND) ? 7'h00 : round + 1;
	`ENCRYPTION, `DECRYPTION:
	  round <= (round == `ENC_DEC_FINAL_ROUND)      ? 7'h00 : round + 1;	  
	default: round <= 7'h00;
      endcase
    end
  end

  // busy
  // KEY_SCHEDULE/ENCRYPTION/DECRYPTION のいずれかが実行中に1となる
  always @(state) begin
    if(state == `KEY_SCHEDULE || state == `ENCRYPTION || state == `DECRYPTION)
      busy <= 1'b1;
    else
      busy <= 1'b0;
  end
  
  // key_valid
  // 鍵が使用可能である時に，1となる
  always @(posedge clk) begin
    if (nreset == 1'b0) key_valid <= 1'b0;
    else begin
      if( state ==`KEY_SCHEDULE && round == `KEY_SCHEDULE_FINAL_ROUND ) 
	key_valid <= 1'b1;   // set when key-scheduling is to be done
      else if( state == `IDLE && key_rdy == 1'b1 )
	key_valid <= 1'b0;   // unset when re-key-scheduling is to begin
    end
  end

  // data_valid
  // 出力が使用可能であるときに, 1となる
  always @(posedge clk) begin
    if (nreset == 1'b0) data_valid <= 1'b0;
    else begin
      case(state)
	`ENCRYPTION, `DECRYPTION:
	  if(round == `ENC_DEC_FINAL_ROUND)
	    data_valid <= 1'b1;  // set when encryption/decryption is to be done
	`IDLE:
	  if(key_rdy == 1'b1 || data_rdy == 1'b1)
	    data_valid <= 1'b0;  // unset when new operation it to begin
      endcase // case(state)
    end
  end 
endmodule // sequencer



module key_scheduler(clk, nreset, key_rdy, key_in, state, round,
		     km_selected, kr_selected);

  input clk, nreset;
  input [127:0] key_in;

  input [2:0] 	state;
  input [6:0] 	round;
  input 	key_rdy;
  
  output [31:0] km_selected;
  output [ 4:0] kr_selected;

  reg [7:0] 	x0, x1, x2, x3, x4, x5, x6, x7,
		x8, x9, xA, xB, xC, xD, xE, xF;
  reg [7:0] 	z0, z1, z2, z3, z4, z5, z6, z7,
		z8, z9, zA, zB, zC, zD, zE, zF;

  // subkeys
  reg [31:0] 	 km1,  km2,   km3,   km4,   km5,   km6,   km7,   km8;
  reg [31:0] 	 km9,  km10,  km11,  km12,  km13,  km14,  km15,  km16;
  reg [4:0] 	 kr1,  kr2,   kr3,   kr4,   kr5,   kr6,   kr7,   kr8;
  reg [4:0] 	 kr9,  kr10,  kr11,  kr12,  kr13,  kr14,  kr15,  kr16;

  wire [7:0] 	 S5_in , S6_in , S7_in , S8_in ;  
  wire [31:0] 	 S5_out, S6_out, S7_out, S8_out;

  wire [31:0] 	 xor_in;
  wire [31:0] 	 xor_out;
  
  wire [31:0] 	 km_selected;
  wire [4:0] 	 kr_selected;

  wire [31:0] 	 S5_out_selected, S6_out_selected,
		 S7_out_selected, S8_out_selected;
  
  assign {S5_in , S6_in , S7_in , S8_in } = switching_box( state, round,
							   x0, x1, x2, x3, x4, x5, x6, x7,
							   x8, x9, xA, xB, xC, xD, xE, xF,
							   z0, z1, z2, z3, z4, z5, z6, z7,
							   z8, z9, zA, zB, zC, zD, zE, zF );

  sbox5 sbox5( .in(S5_in), .out(S5_out) );
  sbox6 sbox6( .in(S6_in), .out(S6_out) );
  sbox7 sbox7( .in(S7_in), .out(S7_out) );
  sbox8 sbox8( .in(S8_in), .out(S8_out) );

  assign km_selected = km_selector( state, round,
				    km1, km2,  km3,  km4,  km5,  km6,  km7,  km8,
				    km9, km10, km11, km12, km13, km14, km15, km16 );

  assign kr_selected = kr_selector( state, round,
				    kr1, kr2,  kr3,  kr4,  kr5,  kr6,  kr7,  kr8,
				    kr9, kr10, kr11, kr12, kr13, kr14, kr15, kr16 );
  
  assign xor_in = mux_xor( state, round,
			   {x0, x1, x2, x3}, {x4, x5, x6, x7},
			   {x8, x9, xA, xB}, {xC, xD, xE, xF},
			   {z0, z1, z2, z3}, {z4, z5, z6, z7},
			   {z8, z9, zA, zB}, {zC, zD, zE, zF},
			   km_selected, kr_selected );

  assign {S5_out_selected, S6_out_selected, S7_out_selected, S8_out_selected}
    = sbox_selector( state, round, S5_out, S6_out, S7_out, S8_out);
  
  assign xor_out = xor_in
		   ^ S5_out_selected ^ S6_out_selected
		   ^ S7_out_selected ^ S8_out_selected;
  
  // Km に関する記述
  always @(posedge clk) begin
    if(nreset == 1'b0) begin
      km1  <= 32'h0000; km2  <= 32'h0000; km3  <= 32'h0000; km4  <= 32'h0000;
      km5  <= 32'h0000; km6  <= 32'h0000; km7  <= 32'h0000; km8  <= 32'h0000;
      km9  <= 32'h0000; km10 <= 32'h0000; km11 <= 32'h0000; km12 <= 32'h0000;
      km13 <= 32'h0000; km14 <= 32'h0000; km15 <= 32'h0000; km16 <= 32'h0000;
    end
    else begin
      if(state == `KEY_SCHEDULE)
	case(round)
	  7'h08, 7'h09: km1  <= xor_out;
	  7'h0a, 7'h0b: km2  <= xor_out;
	  7'h0c, 7'h0d: km3  <= xor_out;
	  7'h0e, 7'h0f: km4  <= xor_out;
	  7'h18, 7'h19: km5  <= xor_out;
	  7'h1a, 7'h1b: km6  <= xor_out;
	  7'h1c, 7'h1d: km7  <= xor_out;
	  7'h1e, 7'h1f: km8  <= xor_out;
	  7'h28, 7'h29: km9  <= xor_out;
	  7'h2a, 7'h2b: km10 <= xor_out;
	  7'h2c, 7'h2d: km11 <= xor_out;
	  7'h2e, 7'h2f: km12 <= xor_out;
	  7'h38, 7'h39: km13 <= xor_out;
	  7'h3a, 7'h3b: km14 <= xor_out;
	  7'h3c, 7'h3d: km15 <= xor_out;
	  7'h3e, 7'h3f: km16 <= xor_out;
	endcase // case(round)
    end
  end
  
  // Kr に関する記述
  always @(posedge clk) begin
    if(nreset == 1'b0) begin
      kr1  <= 5'h00; kr2  <= 5'h00; kr3  <= 5'h00; kr4  <= 5'h00;
      kr5  <= 5'h00; kr6  <= 5'h00; kr7  <= 5'h00; kr8  <= 5'h00;
      kr9  <= 5'h00; kr10 <= 5'h00; kr11 <= 5'h00; kr12 <= 5'h00;
      kr13 <= 5'h00; kr14 <= 5'h00; kr15 <= 5'h00; kr16 <= 5'h00;
    end
    else begin
      if(state == `KEY_SCHEDULE)
	case(round)
	  7'h48, 7'h49: kr1  <= xor_out[4:0];
	  7'h4a, 7'h4b: kr2  <= xor_out[4:0];
	  7'h4c, 7'h4d: kr3  <= xor_out[4:0];
	  7'h4e, 7'h4f: kr4  <= xor_out[4:0];
	  7'h58, 7'h59: kr5  <= xor_out[4:0];
	  7'h5a, 7'h5b: kr6  <= xor_out[4:0];
	  7'h5c, 7'h5d: kr7  <= xor_out[4:0];
	  7'h5e, 7'h5f: kr8  <= xor_out[4:0];
	  7'h68, 7'h69: kr9  <= xor_out[4:0];
	  7'h6a, 7'h6b: kr10 <= xor_out[4:0];
	  7'h6c, 7'h6d: kr11 <= xor_out[4:0];
	  7'h6e, 7'h6f: kr12 <= xor_out[4:0];
	  7'h78, 7'h79: kr13 <= xor_out[4:0];
	  7'h7a, 7'h7b: kr14 <= xor_out[4:0];
	  7'h7c, 7'h7d: kr15 <= xor_out[4:0];
	  7'h7e, 7'h7f: kr16 <= xor_out[4:0];
	endcase // case(round)
    end
  end
	  
  // xとzに関する記述
  always @(posedge clk) begin
    if(nreset == 1'b0) begin
      {x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA, xB, xC, xD, xE, xF}
	<= 128'h0000000000000000;
      {z0, z1, z2, z3, z4, z5, z6, z7, z8, z9, zA, zB, zC, zD, zE, zF}
	<= 128'h0000000000000000;
    end
    else begin
      if( key_rdy == 1'b1 && (state == `INITIAL || state == `IDLE) )
	{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA, xB, xC, xD, xE, xF}
		   <= key_in;
      else if(state == `KEY_SCHEDULE)
	case(round)
	  7'h00, 7'h01, 7'h20, 7'h21, 7'h40, 7'h41, 7'h60, 7'h61: {z0, z1, z2, z3} <= xor_out;
	  7'h02, 7'h03, 7'h22, 7'h23, 7'h42, 7'h43, 7'h62, 7'h63: {z4, z5, z6, z7} <= xor_out;
	  7'h04, 7'h05, 7'h24, 7'h25, 7'h44, 7'h45, 7'h64, 7'h65: {z8, z9, zA, zB} <= xor_out;
	  7'h06, 7'h07, 7'h26, 7'h27, 7'h46, 7'h47, 7'h66, 7'h67: {zC, zD, zE, zF} <= xor_out;
	  7'h10, 7'h11, 7'h30, 7'h31, 7'h50, 7'h51, 7'h70, 7'h71: {x0, x1, x2, x3} <= xor_out;
	  7'h12, 7'h13, 7'h32, 7'h33, 7'h52, 7'h53, 7'h72, 7'h73: {x4, x5, x6, x7} <= xor_out;
	  7'h14, 7'h15, 7'h34, 7'h35, 7'h54, 7'h55, 7'h74, 7'h75: {x8, x9, xA, xB} <= xor_out;
	  7'h16, 7'h17, 7'h36, 7'h37, 7'h56, 7'h57, 7'h76, 7'h77: {xC, xD, xE, xF} <= xor_out;
	endcase // case(round)
    end
  end
    
	    
  // Sbox 出力とXORするデータを選択する
  function [31:0] mux_xor;
    input [2:0]  state;
    input [6:0]  round;
    input [31:0] x0x1x2x3, x4x5x6x7, x8x9xAxB, xCxDxExF;
    input [31:0] z0z1z2z3, z4z5z6z7, z8z9zAzB, zCzDzEzF;
    input [31:0] km_selected;
    input [4:0]  kr_selected;

    if(state == `KEY_SCHEDULE)
      case(round)
	//   z0z1z2z3 = x0x1x2x3 ^ S5[xD] ^ S6[xF] ^ S7[xC] ^ S8[xE] ^ S7[x8]
	7'h00, 7'h40: mux_xor = x0x1x2x3;
	7'h01, 7'h41: mux_xor  = z0z1z2z3;

	//   z4z5z6z7 = x8x9xAxB ^ S5[z0] ^ S6[z2] ^ S7[z1] ^ S8[z3] ^ S8[xA]
	7'h02, 7'h42: mux_xor = x8x9xAxB;
	7'h03, 7'h43: mux_xor = z4z5z6z7;

	//   z8z9zAzB = xCxDxExF ^ S5[z7] ^ S6[z6] ^ S7[z5] ^ S8[z4] ^ S5[x9]
	7'h04, 7'h44: mux_xor = xCxDxExF;
	7'h05, 7'h45: mux_xor = z8z9zAzB;

	//    zCzDzEzF = x4x5x6x7 ^ S5[zA] ^ S6[z9] ^ S7[zB] ^ S8[z8] ^ S6[xB]
	7'h06, 7'h46: mux_xor = x4x5x6x7;
	7'h07, 7'h47: mux_xor = zCzDzEzF;

	//   K1 - K4
	7'h08, 7'h0a, 7'h0c, 7'h0e: mux_xor = 32'h0000;
	7'h09, 7'h0b, 7'h0d, 7'h0f: mux_xor = km_selected;

	//   K17 - K20
	7'h48, 7'h4a, 7'h4c, 7'h4e: mux_xor = 32'h0000;
	7'h49, 7'h4b, 7'h4d, 7'h4f: mux_xor = {27'h0000, kr_selected};

	//   x0x1x2x3 = z8z9zAzB ^ S5[z5] ^ S6[z7] ^ S7[z4] ^ S8[z6] ^ S7[z0]
	7'h10, 7'h50: mux_xor = z8z9zAzB;
	7'h11, 7'h51: mux_xor = x0x1x2x3;

	//   x4x5x6x7 = z0z1z2z3 ^ S5[x0] ^ S6[x2] ^ S7[x1] ^ S8[x3] ^ S8[z2]
	7'h12, 7'h52: mux_xor = z0z1z2z3;
	7'h13, 7'h53: mux_xor = x4x5x6x7;

	//   x8x9xAxB = z4z5z6z7 ^ S5[x7] ^ S6[x6] ^ S7[x5] ^ S8[x4] ^ S5[z1]
	7'h14, 7'h54: mux_xor = z4z5z6z7;
	7'h15, 7'h55: mux_xor = x8x9xAxB;
	
	//   xCxDxExF = zCzDzEzF ^ S5[xA] ^ S6[x9] ^ S7[xB] ^ S8[x8] ^ S6[z3]
	7'h16, 7'h56: mux_xor = zCzDzEzF;
	7'h17, 7'h57: mux_xor = xCxDxExF;

	// K5 - K8
	7'h18, 7'h1a, 7'h1c, 7'h1e: mux_xor = 32'h0000;
	7'h19, 7'h1b, 7'h1d, 7'h1f: mux_xor = km_selected;

	// K21 - K24
	7'h58, 7'h5a, 7'h5c, 7'h5e: mux_xor = 32'h0000;
	7'h59, 7'h5b, 7'h5d, 7'h5f: mux_xor = {27'h0000, kr_selected};
	
	//   z0z1z2z3 = x0x1x2x3 ^ S5[xD] ^ S6[xF] ^ S7[xC] ^ S8[xE] ^ S7[x8]
	7'h20, 7'h60: mux_xor = x0x1x2x3;
	7'h21, 7'h61: mux_xor = z0z1z2z3;

	//   z4z5z6z7 = x8x9xAxB ^ S5[z0] ^ S6[z2] ^ S7[z1] ^ S8[z3] ^ S8[xA]
	7'h22, 7'h62: mux_xor = x8x9xAxB;
	7'h23, 7'h63: mux_xor = z4z5z6z7;

	//   z8z9zAzB = xCxDxExF ^ S5[z7] ^ S6[z6] ^ S7[z5] ^ S8[z4] ^ S5[x9]
	7'h24, 7'h64: mux_xor = xCxDxExF;
	7'h25, 7'h65: mux_xor = z8z9zAzB;

	//   zCzDzEzF = x4x5x6x7 ^ S5[zA] ^ S6[z9] ^ S7[zB] ^ S8[z8] ^ S6[xB]
	7'h26, 7'h66: mux_xor = x4x5x6x7;
	7'h27, 7'h67: mux_xor = zCzDzEzF;

	// K9 - K12
	7'h28, 7'h2a, 7'h2c, 7'h2e: mux_xor = 32'h0000;
	7'h29, 7'h2b, 7'h2d, 7'h2f: mux_xor = km_selected;

	// K25 - K28
	7'h68, 7'h6a, 7'h6c, 7'h6e: mux_xor = 32'h0000;
	7'h69, 7'h6b, 7'h6d, 7'h6f: mux_xor = {27'h0000, kr_selected};

	//   x0x1x2x3 = z8z9zAzB ^ S5[z5] ^ S6[z7] ^ S7[z4] ^ S8[z6] ^ S7[z0]
	7'h30, 7'h70: mux_xor = z8z9zAzB;
	7'h31, 7'h71: mux_xor = x0x1x2x3;
	
	//   x4x5x6x7 = z0z1z2z3 ^ S5[x0] ^ S6[x2] ^ S7[x1] ^ S8[x3] ^ S8[z2]
	7'h32, 7'h72: mux_xor = z0z1z2z3;
	7'h33, 7'h73: mux_xor = x4x5x6x7;
	
	//   x8x9xAxB = z4z5z6z7 ^ S5[x7] ^ S6[x6] ^ S7[x5] ^ S8[x4] ^ S5[z1]
	7'h34, 7'h74: mux_xor = z4z5z6z7;
	7'h35, 7'h75: mux_xor = x8x9xAxB;

	//   xCxDxExF = zCzDzEzF ^ S5[xA] ^ S6[x9] ^ S7[xB] ^ S8[x8] ^ S6[z3]
	7'h36, 7'h76: mux_xor = zCzDzEzF;
	7'h37, 7'h77: mux_xor = xCxDxExF;

	// K13 - K16
	7'h38, 7'h3a, 7'h3c, 7'h3e: mux_xor = 32'h0000;
	7'h39, 7'h3b, 7'h3d, 7'h3f: mux_xor = km_selected;

	// K29 - K32
	7'h78, 7'h7a, 7'h7c, 7'h7e: mux_xor = 32'h0000;
	7'h79, 7'h7b, 7'h7d, 7'h7f: mux_xor = {27'h0000, kr_selected};

	default: mux_xor = 32'h0000;
      endcase // case(round)
    else
      mux_xor = 32'h0000;
  endfunction // mux_xor


  
  // Sbox への入力を選択する
  function [31:0] switching_box;
    input [2:0]  state;
    input [6:0]  round;
    input [7:0]  x0, x1, x2, x3, x4, x5, x6, x7,
		 x8, x9, xA, xB, xC, xD, xE, xF;
    input [7:0]  z0, z1, z2, z3, z4, z5, z6, z7,
		 z8, z9, zA, zB, zC, zD, zE, zF;

    if( state == `KEY_SCHEDULE )
      case(round)
	//   z0z1z2z3 = x0x1x2x3 ^ S5[xD] ^ S6[xF] ^ S7[xC] ^ S8[xE] ^ S7[x8]
	7'h00, 7'h40: switching_box = {8'h00, 8'h00,    x8, 8'h00};
	7'h01, 7'h41: switching_box = {   xD,    xF,    xC,    xE};

	//   z4z5z6z7 = x8x9xAxB ^ S5[z0] ^ S6[z2] ^ S7[z1] ^ S8[z3] ^ S8[xA]
	7'h02, 7'h42: switching_box = {8'h00, 8'h00, 8'h00,    xA};
	7'h03, 7'h43: switching_box = {   z0,    z2,    z1,    z3};

	//   z8z9zAzB = xCxDxExF ^ S5[z7] ^ S6[z6] ^ S7[z5] ^ S8[z4] ^ S5[x9]
	7'h04, 7'h44: switching_box = {   x9, 8'h00, 8'h00, 8'h00};
	7'h05, 7'h45: switching_box = {   z7,    z6,    z5,    z4};

	//    zCzDzEzF = x4x5x6x7 ^ S5[zA] ^ S6[z9] ^ S7[zB] ^ S8[z8] ^ S6[xB]
	7'h06, 7'h46: switching_box = {8'h00,    xB, 8'h00, 8'h00};
	7'h07, 7'h47: switching_box = {   zA,    z9,    zB,    z8};

	//   K1  = S5[z8] ^ S6[z9] ^ S7[z7] ^ S8[z6] ^ S5[z2]
	//   K17 = S5[z8] ^ S6[z9] ^ S7[z7] ^ S8[z6] ^ S5[z2]
	7'h08, 7'h48: switching_box = {   z2, 8'h00, 8'h00, 8'h00};
	7'h09, 7'h49: switching_box = {   z8,    z9,    z7,    z6};

	//   K2  = S5[zA] ^ S6[zB] ^ S7[z5] ^ S8[z4] ^ S6[z6]
	//   K18 = S5[zA] ^ S6[zB] ^ S7[z5] ^ S8[z4] ^ S6[z6]
	7'h0a, 7'h4a: switching_box = {8'h00,    z6, 8'h00, 8'h00};
	7'h0b, 7'h4b: switching_box = {   zA,    zB,    z5,    z4};

	//   K3  = S5[zC] ^ S6[zD] ^ S7[z3] ^ S8[z2] ^ S7[z9]
	//   K19 = S5[zC] ^ S6[zD] ^ S7[z3] ^ S8[z2] ^ S7[z9]	
	7'h0c, 7'h4c: switching_box = {8'h00, 8'h00,    z9, 8'h00};
	7'h0d, 7'h4d: switching_box = {   zC,    zD,    z3,    z2};
	
	//   K4  = S5[zE] ^ S6[zF] ^ S7[z1] ^ S8[z0] ^ S8[zC]
	//   K20 = S5[zE] ^ S6[zF] ^ S7[z1] ^ S8[z0] ^ S8[zC]
	7'h0e, 7'h4e: switching_box = {8'h00, 8'h00, 8'h00,    zC};
	7'h0f, 7'h4f: switching_box = {   zE,    zF,    z1,    z0};
	
	//   x0x1x2x3 = z8z9zAzB ^ S5[z5] ^ S6[z7] ^ S7[z4] ^ S8[z6] ^ S7[z0]
	7'h10, 7'h50: switching_box = {8'h00, 8'h00,    z0, 8'h00};
	7'h11, 7'h51: switching_box = {   z5,    z7,    z4,    z6};
	
	//   x4x5x6x7 = z0z1z2z3 ^ S5[x0] ^ S6[x2] ^ S7[x1] ^ S8[x3] ^ S8[z2]
	7'h12, 7'h52: switching_box = {8'h00, 8'h00, 8'h00,    z2};
	7'h13, 7'h53: switching_box = {   x0,    x2,    x1,    x3};

	//   x8x9xAxB = z4z5z6z7 ^ S5[x7] ^ S6[x6] ^ S7[x5] ^ S8[x4] ^ S5[z1]
	7'h14, 7'h54: switching_box = {   z1, 8'h00, 8'h00, 8'h00};
	7'h15, 7'h55: switching_box = {   x7,    x6,    x5,    x4};

	//   xCxDxExF = zCzDzEzF ^ S5[xA] ^ S6[x9] ^ S7[xB] ^ S8[x8] ^ S6[z3]
	7'h16, 7'h56: switching_box = {8'h00,    z3, 8'h00, 8'h00};
	7'h17, 7'h57: switching_box = {   xA,    x9,    xB,    x8};

	//   K5  = S5[x3] ^ S6[x2] ^ S7[xC] ^ S8[xD] ^ S5[x8]
	//   K21 = S5[x3] ^ S6[x2] ^ S7[xC] ^ S8[xD] ^ S5[x8]
	7'h18, 7'h58: switching_box = {   x8, 8'h00, 8'h00, 8'h00};
	7'h19, 7'h59: switching_box = {   x3,    x2,    xC,    xD};
	
	//   K6  = S5[x1] ^ S6[x0] ^ S7[xE] ^ S8[xF] ^ S6[xD]
	//   K22 = S5[x1] ^ S6[x0] ^ S7[xE] ^ S8[xF] ^ S6[xD]
	7'h1a, 7'h5a: switching_box = {8'h00,    xD, 8'h00, 8'h00};
	7'h1b, 7'h5b: switching_box = {   x1,    x0,    xE,    xF};

	//   K7  = S5[x7] ^ S6[x6] ^ S7[x8] ^ S8[x9] ^ S7[x3]
	//   K23 = S5[x7] ^ S6[x6] ^ S7[x8] ^ S8[x9] ^ S7[x3]
	7'h1c, 7'h5c: switching_box = {8'h00, 8'h00,    x3, 8'h00};
	7'h1d, 7'h5d: switching_box = {   x7,    x6,    x8,    x9};
	
	//   K8  = S5[x5] ^ S6[x4] ^ S7[xA] ^ S8[xB] ^ S8[x7]
	//   K24 = S5[x5] ^ S6[x4] ^ S7[xA] ^ S8[xB] ^ S8[x7]
	7'h1e, 7'h5e: switching_box = {8'h00, 8'h00, 8'h00,    x7};
	7'h1f, 7'h5f: switching_box = {   x5,    x4,    xA,    xB};

	//   z0z1z2z3 = x0x1x2x3 ^ S5[xD] ^ S6[xF] ^ S7[xC] ^ S8[xE] ^ S7[x8]
	7'h20, 7'h60: switching_box = {8'h00, 8'h00,    x8, 8'h00};
	7'h21, 7'h61: switching_box = {   xD,    xF,    xC,    xE};
	
	//   z4z5z6z7 = x8x9xAxB ^ S5[z0] ^ S6[z2] ^ S7[z1] ^ S8[z3] ^ S8[xA]
	7'h22, 7'h62: switching_box = {8'h00, 8'h00, 8'h00,    xA};
	7'h23, 7'h63: switching_box = {   z0,    z2,    z1,    z3};
	
	//   z8z9zAzB = xCxDxExF ^ S5[z7] ^ S6[z6] ^ S7[z5] ^ S8[z4] ^ S5[x9]
	7'h24, 7'h64: switching_box = {   x9, 8'h00, 8'h00, 8'h00};
	7'h25, 7'h65: switching_box = {   z7,    z6,    z5,    z4};
	
	//   zCzDzEzF = x4x5x6x7 ^ S5[zA] ^ S6[z9] ^ S7[zB] ^ S8[z8] ^ S6[xB]
	7'h26, 7'h66: switching_box = {8'h00,    xB, 8'h00, 8'h00};
	7'h27, 7'h67: switching_box = {   zA,    z9,    zB,    z8};

	//   K9  = S5[z3] ^ S6[z2] ^ S7[zC] ^ S8[zD] ^ S5[z9]
	//   K25 = S5[z3] ^ S6[z2] ^ S7[zC] ^ S8[zD] ^ S5[z9]
	7'h28, 7'h68: switching_box = {   z9, 8'h00, 8'h00, 8'h00};
	7'h29, 7'h69: switching_box = {   z3,    z2,    zC,    zD};
	
	//   K10 = S5[z1] ^ S6[z0] ^ S7[zE] ^ S8[zF] ^ S6[zC]
	//   K26 = S5[z1] ^ S6[z0] ^ S7[zE] ^ S8[zF] ^ S6[zC]
	7'h2a, 7'h6a: switching_box = {8'h00,    zC, 8'h00, 8'h00};
	7'h2b, 7'h6b: switching_box = {   z1,    z0,    zE,    zF};
	
	//   K11 = S5[z7] ^ S6[z6] ^ S7[z8] ^ S8[z9] ^ S7[z2]
	//   K27 = S5[z7] ^ S6[z6] ^ S7[z8] ^ S8[z9] ^ S7[z2]
	7'h2c, 7'h6c: switching_box = {8'h00, 8'h00,    z2, 8'h00};
	7'h2d, 7'h6d: switching_box = {   z7,    z6,    z8,    z9};
	
	//   K12 = S5[z5] ^ S6[z4] ^ S7[zA] ^ S8[zB] ^ S8[z6]
	//   K28 = S5[z5] ^ S6[z4] ^ S7[zA] ^ S8[zB] ^ S8[z6]
	7'h2e, 7'h6e: switching_box = {8'h00, 8'h00, 8'h00,    z6};
	7'h2f, 7'h6f: switching_box = {   z5,    z4,    zA,    zB};

	//   x0x1x2x3 = z8z9zAzB ^ S5[z5] ^ S6[z7] ^ S7[z4] ^ S8[z6] ^ S7[z0]
	7'h30, 7'h70: switching_box = {8'h00, 8'h00,    z0, 8'h00};
	7'h31, 7'h71: switching_box = {   z5,    z7,    z4,    z6};
	
	//   x4x5x6x7 = z0z1z2z3 ^ S5[x0] ^ S6[x2] ^ S7[x1] ^ S8[x3] ^ S8[z2]
	7'h32, 7'h72: switching_box = {8'h00, 8'h00, 8'h00,    z2};
	7'h33, 7'h73: switching_box = {   x0,    x2,    x1,    x3};
	
	//   x8x9xAxB = z4z5z6z7 ^ S5[x7] ^ S6[x6] ^ S7[x5] ^ S8[x4] ^ S5[z1]
	7'h34, 7'h74: switching_box = {   z1, 8'h00, 8'h00, 8'h00};
	7'h35, 7'h75: switching_box = {   x7,    x6,    x5,    x4};
	
	//   xCxDxExF = zCzDzEzF ^ S5[xA] ^ S6[x9] ^ S7[xB] ^ S8[x8] ^ S6[z3]
	7'h36, 7'h76: switching_box = {8'h00,    z3, 8'h00, 8'h00};
	7'h37, 7'h77: switching_box = {   xA,    x9,    xB,    x8};

	//   K13 = S5[x8] ^ S6[x9] ^ S7[x7] ^ S8[x6] ^ S5[x3]
	//   K29 = S5[x8] ^ S6[x9] ^ S7[x7] ^ S8[x6] ^ S5[x3]
	7'h38, 7'h78: switching_box = {   x3, 8'h00, 8'h00, 8'h00};
	7'h39, 7'h79: switching_box = {   x8,    x9,    x7,    x6};
	
	//   K14 = S5[xA] ^ S6[xB] ^ S7[x5] ^ S8[x4] ^ S6[x7]
	//   K30 = S5[xA] ^ S6[xB] ^ S7[x5] ^ S8[x4] ^ S6[x7]
	7'h3a, 7'h7a: switching_box = {8'h00,    x7, 8'h00, 8'h00};
	7'h3b, 7'h7b: switching_box = {   xA,    xB,    x5,    x4};
	
	//   K15 = S5[xC] ^ S6[xD] ^ S7[x3] ^ S8[x2] ^ S7[x8]
	//   K31 = S5[xC] ^ S6[xD] ^ S7[x3] ^ S8[x2] ^ S7[x8]
	7'h3c, 7'h7c: switching_box = {8'h00, 8'h00,    x8, 8'h00};
	7'h3d, 7'h7d: switching_box = {   xC,    xD,    x3,    x2};
	
	//   K16 = S5[xE] ^ S6[xF] ^ S7[x1] ^ S8[x0] ^ S8[xD]
	//   K32 = S5[xE] ^ S6[xF] ^ S7[x1] ^ S8[x0] ^ S8[xD]
	7'h3e, 7'h7e: switching_box = {8'h00, 8'h00, 8'h00,    xD};
	7'h3f, 7'h7f: switching_box = {   xE,    xF,    x1,    x0};

	default:      switching_box = {8'h00, 8'h00, 8'h00, 8'h00};
      endcase // case(round)
    else
      switching_box = {8'h00, 8'h00, 8'h00, 8'h00};
  endfunction // switching_box

  
  function [31:0] km_selector;
    input [2:0]  state;
    input [6:0]  round;
    input [31:0] km1,  km2,   km3,   km4,   km5,   km6,   km7,   km8;
    input [31:0] km9,  km10,  km11,  km12,  km13,  km14,  km15,  km16;

    if(state == `ENCRYPTION || state == `DECRYPTION)
      case(round)
	6'h0: km_selector    = (state == `ENCRYPTION) ? km1  : km16;
	6'h1: km_selector    = (state == `ENCRYPTION) ? km2  : km15;
	6'h2: km_selector    = (state == `ENCRYPTION) ? km3  : km14;
	6'h3: km_selector    = (state == `ENCRYPTION) ? km4  : km13;
	6'h4: km_selector    = (state == `ENCRYPTION) ? km5  : km12;
	6'h5: km_selector    = (state == `ENCRYPTION) ? km6  : km11;
	6'h6: km_selector    = (state == `ENCRYPTION) ? km7  : km10;
	6'h7: km_selector    = (state == `ENCRYPTION) ? km8  : km9;
	6'h8: km_selector    = (state == `ENCRYPTION) ? km9  : km8;
	6'h9: km_selector    = (state == `ENCRYPTION) ? km10 : km7;
	6'ha: km_selector    = (state == `ENCRYPTION) ? km11 : km6;
	6'hb: km_selector    = (state == `ENCRYPTION) ? km12 : km5;
	6'hc: km_selector    = (state == `ENCRYPTION) ? km13 : km4;
	6'hd: km_selector    = (state == `ENCRYPTION) ? km14 : km3;
	6'he: km_selector    = (state == `ENCRYPTION) ? km15 : km2;
	default: km_selector = (state == `ENCRYPTION) ? km16 : km1;
      endcase // case(round)
    else if(state == `KEY_SCHEDULE)
      case(round)
	7'h09: km_selector = km1;  // K1
	7'h0b: km_selector = km2;  // K2
	7'h0d: km_selector = km3;  // K3
	7'h0f: km_selector = km4;  // K4
	7'h19: km_selector = km5;  // K5
	7'h1b: km_selector = km6;  // K6
	7'h1d: km_selector = km7;  // K7
	7'h1f: km_selector = km8;  // K8
	7'h29: km_selector = km9;  // K9
	7'h2b: km_selector = km10; // K10
	7'h2d: km_selector = km11; // K11
	7'h2f: km_selector = km12; // K12
	7'h39: km_selector = km13; // K13
	7'h3b: km_selector = km14; // K14
	7'h3d: km_selector = km15; // K15
	7'h3f: km_selector = km16; // K16
	default: km_selector = 32'h0000;
      endcase // case(round)
    else
      km_selector = 32'h0000;
  endfunction // km_selector
  

  function [4:0] kr_selector;
    input [2:0]  state;
    input [6:0]  round;
    input [4:0]  kr1,  kr2,   kr3,   kr4,   kr5,   kr6,   kr7,   kr8;
    input [4:0]  kr9,  kr10,  kr11,  kr12,  kr13,  kr14,  kr15,  kr16;

    if(state == `ENCRYPTION || state == `DECRYPTION)
      case(round)
	4'h0: kr_selector    = (state == `ENCRYPTION) ? kr1  : kr16;
	4'h1: kr_selector    = (state == `ENCRYPTION) ? kr2  : kr15;
	4'h2: kr_selector    = (state == `ENCRYPTION) ? kr3  : kr14;
	4'h3: kr_selector    = (state == `ENCRYPTION) ? kr4  : kr13;
	4'h4: kr_selector    = (state == `ENCRYPTION) ? kr5  : kr12;
	4'h5: kr_selector    = (state == `ENCRYPTION) ? kr6  : kr11;
	4'h6: kr_selector    = (state == `ENCRYPTION) ? kr7  : kr10;
	4'h7: kr_selector    = (state == `ENCRYPTION) ? kr8  : kr9;
	4'h8: kr_selector    = (state == `ENCRYPTION) ? kr9  : kr8;
	4'h9: kr_selector    = (state == `ENCRYPTION) ? kr10 : kr7;
	4'ha: kr_selector    = (state == `ENCRYPTION) ? kr11 : kr6;
	4'hb: kr_selector    = (state == `ENCRYPTION) ? kr12 : kr5;
	4'hc: kr_selector    = (state == `ENCRYPTION) ? kr13 : kr4;
	4'hd: kr_selector    = (state == `ENCRYPTION) ? kr14 : kr3;
	4'he: kr_selector    = (state == `ENCRYPTION) ? kr15 : kr2;
	default: kr_selector = (state == `ENCRYPTION) ? kr16 : kr1;
      endcase // case(counter)
    else if(state == `KEY_SCHEDULE)
      case(round)
	7'h49: kr_selector = kr1;  // K17
	7'h4b: kr_selector = kr2;  // K18
	7'h4d: kr_selector = kr3;  // K19
	7'h4f: kr_selector = kr4;  // K20
	7'h59: kr_selector = kr5;  // K21
	7'h5b: kr_selector = kr6;  // K22
	7'h5d: kr_selector = kr7;  // K23
	7'h5f: kr_selector = kr8;  // K24
	7'h69: kr_selector = kr9;  // K25
	7'h6b: kr_selector = kr10; // K26
	7'h6d: kr_selector = kr11; // K27
	7'h6f: kr_selector = kr12; // K28
	7'h79: kr_selector = kr13; // K29
	7'h7b: kr_selector = kr14; // K30
	7'h7d: kr_selector = kr15; // K31
	7'h7f: kr_selector = kr16; // K32
	default: kr_selector = 5'h00;
      endcase // case(round)
    else kr_selector = 5'h00;
  endfunction // kr_selector

  function [127:0] sbox_selector;
    input [2:0]  state;
    input [6:0]  round;
    input [31:0] S5_out, S6_out, S7_out, S8_out;
    if(state ==`KEY_SCHEDULE)
      case(round)
	//   z0z1z2z3 = x0x1x2x3 ^ S5[xD] ^ S6[xF] ^ S7[xC] ^ S8[xE] ^ S7[x8]
	7'h00, 7'h10, 7'h20, 7'h30, 7'h40, 7'h50, 7'h60, 7'h70:
	  sbox_selector = { 32'h0000, 32'h0000, S7_out, 32'h0000 };
	
	//   z4z5z6z7 = x8x9xAxB ^ S5[z0] ^ S6[z2] ^ S7[z1] ^ S8[z3] ^ S8[xA]
	7'h02, 7'h12, 7'h22, 7'h32, 7'h42, 7'h52, 7'h62, 7'h72:
	  sbox_selector = { 32'h0000, 32'h0000, 32'h0000, S8_out };	  

	//   z8z9zAzB = xCxDxExF ^ S5[z7] ^ S6[z6] ^ S7[z5] ^ S8[z4] ^ S5[x9]
	7'h04, 7'h14, 7'h34, 7'h24, 7'h44, 7'h54, 7'h64, 7'h74:
	  sbox_selector = { S5_out,   32'h0000, 32'h0000, 32'h0000 };	  	  

	//    zCzDzEzF = x4x5x6x7 ^ S5[zA] ^ S6[z9] ^ S7[zB] ^ S8[z8] ^ S6[xB]
	7'h06, 7'h16, 7'h26, 7'h36, 7'h46, 7'h56, 7'h66, 7'h76:
	  sbox_selector = { 32'h0000, S6_out, 32'h0000, 32'h0000 };

	//   K1  = S5[z8] ^ S6[z9] ^ S7[z7] ^ S8[z6] ^ S5[z2]
	7'h08, 7'h18, 7'h28, 7'h38, 7'h48, 7'h58, 7'h68,  7'h78:
	  sbox_selector = { S5_out, 32'h0000, 32'h0000, 32'h0000 };	  	  

	//   K2  = S5[zA] ^ S6[zB] ^ S7[z5] ^ S8[z4] ^ S6[z6]
	7'h0a, 7'h1a, 7'h2a, 7'h3a, 7'h4a, 7'h5a, 7'h6a, 7'h7a:
	  sbox_selector = { 32'h0000, S6_out, 32'h0000, 32'h0000 };

	//   K3  = S5[zC] ^ S6[zD] ^ S7[z3] ^ S8[z2] ^ S7[z9]
	7'h0c, 7'h1c, 7'h2c, 7'h3c, 7'h4c, 7'h5c, 7'h6c, 7'h7c:
	  sbox_selector = { 32'h0000, 32'h0000, S7_out, 32'h0000 };

	//   K4  = S5[zE] ^ S6[zF] ^ S7[z1] ^ S8[z0] ^ S8[zC]
	7'h0e, 7'h1e, 7'h2e, 7'h3e, 7'h4e, 7'h5e, 7'h6e, 7'h7e:
	  sbox_selector = { 32'h0000, 32'h0000, 32'h0000, S8_out };	  

	default:
	  sbox_selector = { S5_out, S6_out, S7_out, S8_out };	  
      endcase // case(round)
    else
      sbox_selector = { 32'h0000, 32'h0000, 32'h0000, 32'h0000 };
  endfunction // sbox_selector
  
endmodule // key_scheduler


module encrypt( clk, nreset,
		data_rdy, data_in,
		state, round,
		km_selected, kr_selected,
		data_out );

  input         clk, nreset;
  input         data_rdy;
  input [63:0]  data_in;

  input [ 2:0] 	state;
  input [ 6:0] 	round;

  input [31:0]  km_selected;
  input [ 4:0]  kr_selected;
  output [63:0] data_out;

  reg [63:0] 	work_reg;

  wire [31:0] 	sbox1_out, sbox2_out, sbox3_out, sbox4_out;   // outputs of sboxes
  wire [31:0] 	f_func_out;                                   // output of F-function

  wire [31:0] 	asx_a_out, asx_b_out, asx_c_out, shifted;
  wire [1:0] 	asx_select_a, asx_select_b, asx_select_c, asx_select_d;

  // directly output work_reg
  assign 	data_out = work_reg;

  // Select the operation of ASX (Add-Sub-Xor combined unit)
  assign       {asx_select_a, asx_select_b, asx_select_c, asx_select_d}
                         = asx_selector(state, round);

  // You may feel unfamiler with description below
  // Notice that they are serialized according to the data flow
  asx32 asx32_a( .in1(km_selected), .in2(data_out[31:0]), .select(asx_select_a), .out(asx_a_out));
  assign       shifted = (asx_a_out << kr_selected) | asx_a_out >> (32-kr_selected) ;
  sbox1 sbox1( .in(shifted[31:24]), .out(sbox1_out) );
  sbox2 sbox2( .in(shifted[23:16]), .out(sbox2_out) );
  sbox3 sbox3( .in(shifted[15:8]),  .out(sbox3_out) );
  sbox4 sbox4( .in(shifted[7:0]),   .out(sbox4_out) );
  asx32 asx32_b( .in1(sbox1_out), .in2(sbox2_out), .select(asx_select_b), .out(asx_b_out));
  asx32 asx32_c( .in1(asx_b_out), .in2(sbox3_out), .select(asx_select_c), .out(asx_c_out));
  asx32 asx32_d( .in1(asx_c_out), .in2(sbox4_out), .select(asx_select_d), .out(f_func_out));
  

  // description about work_reg
  always @( posedge clk ) begin
    if( nreset == 1'b0 ) begin      // initialize
      work_reg <= 32'h0000;
    end
    else begin
      case(state)
	`IDLE:
	  if(data_rdy == 1'b1) work_reg <= data_in;
	
	`ENCRYPTION, `DECRYPTION:
	  work_reg <= ( round == 4'hf ) ?
		      { data_out[63:32] ^ f_func_out, data_out[31:0] } :
		      { data_out[31:0], data_out[63:32] ^ f_func_out };
      endcase // case(state)
    end
  end
  
  // asx_selector returns a 'select' signal of ASXes
  // its order is,
  // { asx_select_a, asx_select_b, asx_select_c, asx_select_d }
  function [7:0] asx_selector;
    input [2:0] state;
    input [6:0] round;

    case(round)
      4'h0, 4'h3, 4'h6, 4'h9, 4'hc, 4'hf: 
	asx_selector = {`ASX_ADD, `ASX_XOR, `ASX_SUB, `ASX_ADD};  // Type1
      
      4'h1, 4'h4, 4'h7, 4'ha, 4'hd:       
	asx_selector = ( state == `ENCRYPTION ) ?
		       {`ASX_XOR, `ASX_SUB, `ASX_ADD, `ASX_XOR}:  // Type2
		       {`ASX_SUB, `ASX_ADD, `ASX_XOR, `ASX_SUB};  // Type3

      default:
        asx_selector = ( state == `ENCRYPTION ) ?
		       {`ASX_SUB, `ASX_ADD, `ASX_XOR, `ASX_SUB}:  // Type3
	   	       {`ASX_XOR, `ASX_SUB, `ASX_ADD, `ASX_XOR};  // Type2
    endcase // case(counter)
  endfunction // asx_selector
  
endmodule // encrypt

// 1bit cell of Add/Sub/Xor combined unit
// select means,
//     2'b10: Add
//     2'b11: Sub
//     2'b00: Xor
//     2'b01: Undefined
module asx1(in1, in2, carry_in, select, sum);
  input in1, in2, carry_in;
  input [1:0] select;
  output sum;

  wire 	 fa_in1, fa_in2, fa_carry_in;

  assign fa_in1       = in1;
  assign fa_in2       = (select[0] == 1'b0) ? in2  : ~in2;
  assign fa_carry_in  = (select[1] == 1'b0) ? 1'b0 : carry_in;

  assign sum          = fa_in1 ^ fa_in2 ^ fa_carry_in;
endmodule // asx1


// 32bit Add/Sub/Xor combined unit
// They are connected like Ripple Carry Adder
module asx32(in1, in2, select, out);
  input  [31:0] in1, in2;
  input  [ 1:0] select;
  output [31:0] out;

  wire 		cout00, cout01, cout02, cout03;
  wire 		cout04, cout05, cout06, cout07;
  wire 		cout08, cout09, cout10, cout11;
  wire 		cout12, cout13, cout14, cout15;
  wire 		cout16, cout17, cout18, cout19;
  wire 		cout20, cout21, cout22, cout23;
  wire 		cout24, cout25, cout26, cout27;
  wire 		cout28, cout29, cout30, cout31;
  wire [31:0] 	carry_out;

  lookahead32 la32( .in1(in1), .in2(in2), .carry_in(select[0]), .carry_out(carry_out) );

  asx1 asx1_00( in1[ 0], in2[ 0],     select[0], select, out[ 0]);
  asx1 asx1_01( in1[ 1], in2[ 1], carry_out[ 0], select, out[ 1]);
  asx1 asx1_02( in1[ 2], in2[ 2], carry_out[ 1], select, out[ 2]);
  asx1 asx1_03( in1[ 3], in2[ 3], carry_out[ 2], select, out[ 3]);
  asx1 asx1_04( in1[ 4], in2[ 4], carry_out[ 3], select, out[ 4]);
  asx1 asx1_05( in1[ 5], in2[ 5], carry_out[ 4], select, out[ 5]);
  asx1 asx1_06( in1[ 6], in2[ 6], carry_out[ 5], select, out[ 6]);
  asx1 asx1_07( in1[ 7], in2[ 7], carry_out[ 6], select, out[ 7]);
  asx1 asx1_08( in1[ 8], in2[ 8], carry_out[ 7], select, out[ 8]);
  asx1 asx1_09( in1[ 9], in2[ 9], carry_out[ 8], select, out[ 9]);
  asx1 asx1_10( in1[10], in2[10], carry_out[ 9], select, out[10]);
  asx1 asx1_11( in1[11], in2[11], carry_out[10], select, out[11]);
  asx1 asx1_12( in1[12], in2[12], carry_out[11], select, out[12]);
  asx1 asx1_13( in1[13], in2[13], carry_out[12], select, out[13]);
  asx1 asx1_14( in1[14], in2[14], carry_out[13], select, out[14]);
  asx1 asx1_15( in1[15], in2[15], carry_out[14], select, out[15]);
  asx1 asx1_16( in1[16], in2[16], carry_out[15], select, out[16]);
  asx1 asx1_17( in1[17], in2[17], carry_out[16], select, out[17]);
  asx1 asx1_18( in1[18], in2[18], carry_out[17], select, out[18]);
  asx1 asx1_19( in1[19], in2[19], carry_out[18], select, out[19]);
  asx1 asx1_20( in1[20], in2[20], carry_out[19], select, out[20]);
  asx1 asx1_21( in1[21], in2[21], carry_out[20], select, out[21]);
  asx1 asx1_22( in1[22], in2[22], carry_out[21], select, out[22]);
  asx1 asx1_23( in1[23], in2[23], carry_out[22], select, out[23]);
  asx1 asx1_24( in1[24], in2[24], carry_out[23], select, out[24]);
  asx1 asx1_25( in1[25], in2[25], carry_out[24], select, out[25]);
  asx1 asx1_26( in1[26], in2[26], carry_out[25], select, out[26]);
  asx1 asx1_27( in1[27], in2[27], carry_out[26], select, out[27]);
  asx1 asx1_28( in1[28], in2[28], carry_out[27], select, out[28]);
  asx1 asx1_29( in1[29], in2[29], carry_out[28], select, out[29]);
  asx1 asx1_30( in1[30], in2[30], carry_out[29], select, out[30]);
  asx1 asx1_31( in1[31], in2[31], carry_out[30], select, out[31]);
endmodule // asx32


module lookahead1(in1, in2, carry_in, carry_out, sp, sg);
  input  [3:0] in1, in2;
  input        carry_in;
  output [3:0] carry_out;
  output       sp, sg;
  
  wire   [3:0]   p, g;

  assign       g = in1 & in2;
  assign       p = in1 | in2;

  assign       carry_out[0] = g[0] | (p[0] & carry_in);
  assign       carry_out[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & carry_in);
  assign       carry_out[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0])
                           | (p[2] & p[1] & p[0] & carry_in );
  assign       carry_out[3] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1])
                           | (p[3] & p[2] & p[1] & g[0] )
			   | (p[3] & p[2] & p[1] & p[0] & carry_in ) ;

  assign       sp = p[3] & p[2] & p[1] & p[0];
  assign       sg =  g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1])
                  | (p[3] & p[2] & p[1] & g[0] );
endmodule // lookahead1


module lookahead2(sp, sg, carry_in, sc);
  input [3:0] sp, sg;
  input       carry_in;
  output [3:0] sc;

  assign       sc[0] = sg[0] | (sp[0] & carry_in);
  assign       sc[1] = sg[1] | (sp[1] & sg[0]) | (sp[1] & sp[0] & carry_in);
  assign       sc[2] = sg[2] | (sp[2] & sg[1]) | (sp[2] & sp[1] & sg[0])
                           | (sp[2] & sp[1] & sp[0] & carry_in );
  assign       sc[3] = sg[3] | (sp[3] & sg[2]) | (sp[3] & sp[2] & sg[1])
                           | (sp[3] & sp[2] & sp[1] & sg[0] )
			   | (sp[3] & sp[2] & sp[1] & sp[0] & carry_in ) ;
endmodule // lookahead2


module lookahead32(in1, in2, carry_in, carry_out);
  input  [31:0] in1, in2;
  input         carry_in;
  output [31:0] carry_out;

  wire [7:0] 	sp, sg;
  wire [31:0] 	sc;
  wire [31:0] 	add_or_sub;
  assign 	add_or_sub = (carry_in == 1'b0) ? in2 : ~in2;
  
  lookahead1 la0( .in1(in1[3:0]),   .in2(add_or_sub[3:0]),   .carry_in(carry_in), .carry_out(carry_out[3:0]),   .sp(sp[0]), .sg(sg[0]) );
  lookahead1 la1( .in1(in1[7:4]),   .in2(add_or_sub[7:4]),   .carry_in(sc[0]),    .carry_out(carry_out[7:4]),   .sp(sp[1]), .sg(sg[1]) );
  lookahead1 la2( .in1(in1[11:8]),  .in2(add_or_sub[11:8]),  .carry_in(sc[1]),    .carry_out(carry_out[11:8]),  .sp(sp[2]), .sg(sg[2]) );
  lookahead1 la3( .in1(in1[15:12]), .in2(add_or_sub[15:12]), .carry_in(sc[2]),    .carry_out(carry_out[15:12]), .sp(sp[3]), .sg(sg[3]) );
  lookahead1 la4( .in1(in1[19:16]), .in2(add_or_sub[19:16]), .carry_in(sc[3]),    .carry_out(carry_out[19:16]), .sp(sp[4]), .sg(sg[4]) );
  lookahead1 la5( .in1(in1[23:20]), .in2(add_or_sub[23:20]), .carry_in(sc[4]),    .carry_out(carry_out[23:20]), .sp(sp[5]), .sg(sg[5]) );
  lookahead1 la6( .in1(in1[27:24]), .in2(add_or_sub[27:24]), .carry_in(sc[5]),    .carry_out(carry_out[27:24]), .sp(sp[6]), .sg(sg[6]) );
  lookahead1 la7( .in1(in1[31:28]), .in2(add_or_sub[31:28]), .carry_in(sc[6]),    .carry_out(carry_out[31:28]), .sp(sp[7]), .sg(sg[7]) );

  lookahead2 sla0( .sp(sp[3:0]), .sg(sg[3:0]), .carry_in(carry_in), .sc(sc[3:0]) );
  lookahead2 sla1( .sp(sp[7:4]), .sg(sg[7:4]), .carry_in(sc[3]),    .sc(sc[7:4]) );

endmodule // lookahead32
