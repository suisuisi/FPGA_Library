/*-------------------------------------------------------------------------
 CAST-128 Encryption/Decryption Macro (ASIC version)
                                   
 File name   : CAST128.v
 Version     : Version 1.0
 Created     : AUG/28/2006
 Last update : SEP/25/2007
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


module CAST128( Kin, Din, Dout, Krdy, Drdy, EncDec, RSTn, EN, CLK, BSY, Kvld, Dvld );
  input  [127:0] Kin; // Key input 
  input  [63:0]  Din; // Data input
  output [63:0]  Dout;// Data output
  input  Krdy;        // Trigger to start key scheduling
  input  Drdy;        // Trigger to start encryption/decryption
  input  EncDec;      // Set 0 for Encryption, 1 for Decryption.
  input  RSTn, EN, CLK;
  output BSY;         // Busy
  output Kvld;        // Key valid
  output Dvld;        // Data valid
  
  wire [31:0] 	km_selected;
  wire [4:0] 	kr_selected;

  wire [2:0] 	state;
  wire [6:0] 	round;
  
  CAST128_sequencer CAST128_sequencer(// Outputs
				      .state	(state[2:0]),
				      .round	(round[6:0]),
				      .BSY	(BSY),
				      .Dvld	(Dvld),
				      .Kvld	(Kvld),
				      // Inputs
				      .CLK	(CLK),
				      .EN       (EN),
				      .RSTn	(RSTn),
				      .Drdy	(Drdy),
				      .Krdy	(Krdy),
				      .EncDec	(EncDec) );

  CAST128_encrypt CAST128_encrypt(// Outputs
				  .Dout		(Dout[63:0]),
				  // Inputs
				  .CLK		(CLK),
				  .EN           (EN),
				  .RSTn		(RSTn),
				  .Drdy		(Drdy),
				  .Din		(Din[63:0]),
				  .state	(state[2:0]),
				  .round	(round[6:0]),
				  .km_selected	(km_selected[31:0]),
				  .kr_selected	(kr_selected[4:0]));
		      
  CAST128_key_scheduler CAST128_key_scheduler(// Outputs
					      .km_selected	(km_selected[31:0]),
					      .kr_selected	(kr_selected[4:0]),
					      // Inputs
					      .CLK		(CLK),
					      .EN               (EN),
					      .RSTn		(RSTn),
					      .Kin		(Kin[127:0]),
					      .state		(state[2:0]),
					      .round		(round[6:0]),
					      .Krdy		(Krdy));
endmodule // CAST128


// A sequencer module for CAST-128 macro
module CAST128_sequencer( Krdy, Drdy, EncDec, RSTn, EN, CLK, BSY, Kvld, Dvld, state, round );
  input CLK, RSTn, EN;
  
  input Drdy;           // Trigger to start encryption/decryption
  input Krdy;           // Trigger to start key scheduling
  input EncDec;         // 0 for Encryption, 1 for Decryption

  output [2:0] state;   // State
  output [6:0] round;   // Round number

  output BSY;           // Busy    
  output Dvld;          // Data valid
  output Kvld;          // Key valid

  // State assign
  parameter INITIAL      = 3'b000;
  parameter IDLE         = 3'b001;
  parameter KEY_SCHEDULE = 3'b011;
  parameter ENCRYPTION   = 3'b111;
  parameter DECRYPTION   = 3'b101;

  parameter Enc = 1'b0;
  parameter Dec = 1'b1;

  parameter KEY_SCHEDULE_FINAL_ROUND = 7'b1111111;
  parameter ENC_DEC_FINAL_ROUND = 7'h0f;

  reg [2:0] state_reg;
  reg [6:0] round_reg;

  reg 	    Dvld_reg, Kvld_reg;

  assign state = state_reg;
  assign round = round_reg;

  assign Dvld = Dvld_reg;
  assign Kvld = Kvld_reg;

  assign BSY = (state_reg == KEY_SCHEDULE ||
		state_reg == ENCRYPTION   ||
		state_reg == DECRYPTION) ? 1'b1 : 1'b0;
  
  // state_reg
  always @(posedge CLK) begin
    if (RSTn == 1'b0)
      state_reg <= INITIAL;
    else if(EN == 1) begin
      case(state_reg)
	INITIAL:      state_reg <= (Krdy == 1'b0)                          ? IDLE : KEY_SCHEDULE;
	KEY_SCHEDULE: state_reg <= (round_reg == KEY_SCHEDULE_FINAL_ROUND) ? IDLE : KEY_SCHEDULE;
	ENCRYPTION:   state_reg <= (round_reg == ENC_DEC_FINAL_ROUND)      ? IDLE : ENCRYPTION;
	DECRYPTION:   state_reg <= (round_reg == ENC_DEC_FINAL_ROUND)      ? IDLE : DECRYPTION;
	default: // IDLE
	  if(Krdy == 1'b1)
	    state_reg <= KEY_SCHEDULE;
	  else if(Drdy == 1'b1)
	    state_reg <= (EncDec == Enc) ? ENCRYPTION : DECRYPTION;
	  else
	    state_reg <= IDLE;
      endcase // case(state_reg)
    end
  end

  // round_reg
  always @(posedge CLK) begin
    if (RSTn == 1'b0)
      round_reg <= 7'h00;
    else if(EN == 1) begin
      case(state_reg)
	KEY_SCHEDULE:
	  round_reg <= (round_reg == KEY_SCHEDULE_FINAL_ROUND) ? 7'h00 : round_reg + 1;
	ENCRYPTION, DECRYPTION:
	  round_reg <= (round_reg == ENC_DEC_FINAL_ROUND)      ? 7'h00 : round_reg + 1;	  
	default: round_reg <= 7'h00;
      endcase
    end
  end

  // Kvld_reg
  always @(posedge CLK) begin
    if (RSTn == 1'b0)
      Kvld_reg <= 1'b0;
    else if(EN == 1) begin
      if( state_reg == KEY_SCHEDULE && round_reg == KEY_SCHEDULE_FINAL_ROUND ) 
	Kvld_reg <= 1'b1;   // set when key-scheduling is to be done
      else
	Kvld_reg <= 1'b0;
    end
  end


  // Dvld_reg
  always @(posedge CLK) begin
    if (RSTn == 1'b0)
      Dvld_reg <= 1'b0;
    else if(EN == 1) begin
      case(state_reg)
	ENCRYPTION, DECRYPTION:
	  if(round_reg == ENC_DEC_FINAL_ROUND)
	    Dvld_reg <= 1'b1;  // set when encryption/decryption is to be done
	default:  Dvld_reg <= 1'b0;
      endcase // case(state_reg)
    end
  end 
endmodule // CAST128_sequencer


// Key-scheduler module for CAST-128 macro
module CAST128_key_scheduler(Kin, Krdy, RSTn, EN, CLK, state, round, km_selected, kr_selected);
  input CLK, RSTn;
  input [127:0] Kin;

  input [2:0] 	state;
  input [6:0] 	round;
  input 	Krdy;
  input         EN;
  
  output [31:0] km_selected;
  output [ 4:0] kr_selected;

  parameter INITIAL      = 3'b000;
  parameter IDLE         = 3'b001;
  parameter KEY_SCHEDULE = 3'b011;
  parameter ENCRYPTION   = 3'b111;
  parameter DECRYPTION   = 3'b101;

  parameter KEY_SCHEDULE_FINAL_ROUND = 7'b1111111;
  parameter ENC_DEC_FINAL_ROUND = 7'h0f;

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
  CAST128_sbox5 CAST128_sbox5( .in(S5_in), .out(S5_out) );
  CAST128_sbox6 CAST128_sbox6( .in(S6_in), .out(S6_out) );
  CAST128_sbox7 CAST128_sbox7( .in(S7_in), .out(S7_out) );
  CAST128_sbox8 CAST128_sbox8( .in(S8_in), .out(S8_out) );

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
  
  // Sequence for Km*
  always @(posedge CLK) begin
    if(RSTn == 1'b0) begin
      km1  <= 32'h0000; km2  <= 32'h0000; km3  <= 32'h0000; km4  <= 32'h0000;
      km5  <= 32'h0000; km6  <= 32'h0000; km7  <= 32'h0000; km8  <= 32'h0000;
      km9  <= 32'h0000; km10 <= 32'h0000; km11 <= 32'h0000; km12 <= 32'h0000;
      km13 <= 32'h0000; km14 <= 32'h0000; km15 <= 32'h0000; km16 <= 32'h0000;
    end
    else if(EN == 1) begin
      if(state == KEY_SCHEDULE)
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
  
  // Sequence for Kr*
  always @(posedge CLK) begin
    if(RSTn == 1'b0) begin
      kr1  <= 5'h00; kr2  <= 5'h00; kr3  <= 5'h00; kr4  <= 5'h00;
      kr5  <= 5'h00; kr6  <= 5'h00; kr7  <= 5'h00; kr8  <= 5'h00;
      kr9  <= 5'h00; kr10 <= 5'h00; kr11 <= 5'h00; kr12 <= 5'h00;
      kr13 <= 5'h00; kr14 <= 5'h00; kr15 <= 5'h00; kr16 <= 5'h00;
    end
    else if(EN == 1) begin
      if(state == KEY_SCHEDULE)
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
	  
  // Sequence for x* and z*
  always @(posedge CLK) begin
    if(RSTn == 1'b0) begin
      {x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA, xB, xC, xD, xE, xF}
	<= 128'h0000000000000000;
      {z0, z1, z2, z3, z4, z5, z6, z7, z8, z9, zA, zB, zC, zD, zE, zF}
	<= 128'h0000000000000000;
    end
    else if(EN == 1) begin
      if( Krdy == 1'b1 && (state == INITIAL || state == IDLE) )
	{x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA, xB, xC, xD, xE, xF}
		   <= Kin;
      else if(state == KEY_SCHEDULE)
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
    	    
  // A selecter to select the data to be XORed by the output of Sbox
  function [31:0] mux_xor;
    input [2:0]  state;
    input [6:0]  round;
    input [31:0] x0x1x2x3, x4x5x6x7, x8x9xAxB, xCxDxExF;
    input [31:0] z0z1z2z3, z4z5z6z7, z8z9zAzB, zCzDzEzF;
    input [31:0] km_selected;
    input [4:0]  kr_selected;

    if(state == KEY_SCHEDULE)
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
  
  // A selector to select the data to input to Sboxes
  function [31:0] switching_box;
    input [2:0]  state;
    input [6:0]  round;
    input [7:0]  x0, x1, x2, x3, x4, x5, x6, x7,
		 x8, x9, xA, xB, xC, xD, xE, xF;
    input [7:0]  z0, z1, z2, z3, z4, z5, z6, z7,
		 z8, z9, zA, zB, zC, zD, zE, zF;

    if( state == KEY_SCHEDULE )
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

    if(state == ENCRYPTION || state == DECRYPTION)
      case(round)
	6'h0: km_selector    = (state == ENCRYPTION) ? km1  : km16;
	6'h1: km_selector    = (state == ENCRYPTION) ? km2  : km15;
	6'h2: km_selector    = (state == ENCRYPTION) ? km3  : km14;
	6'h3: km_selector    = (state == ENCRYPTION) ? km4  : km13;
	6'h4: km_selector    = (state == ENCRYPTION) ? km5  : km12;
	6'h5: km_selector    = (state == ENCRYPTION) ? km6  : km11;
	6'h6: km_selector    = (state == ENCRYPTION) ? km7  : km10;
	6'h7: km_selector    = (state == ENCRYPTION) ? km8  : km9;
	6'h8: km_selector    = (state == ENCRYPTION) ? km9  : km8;
	6'h9: km_selector    = (state == ENCRYPTION) ? km10 : km7;
	6'ha: km_selector    = (state == ENCRYPTION) ? km11 : km6;
	6'hb: km_selector    = (state == ENCRYPTION) ? km12 : km5;
	6'hc: km_selector    = (state == ENCRYPTION) ? km13 : km4;
	6'hd: km_selector    = (state == ENCRYPTION) ? km14 : km3;
	6'he: km_selector    = (state == ENCRYPTION) ? km15 : km2;
	default: km_selector = (state == ENCRYPTION) ? km16 : km1;
      endcase // case(round)
    else if(state == KEY_SCHEDULE)
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

    if(state == ENCRYPTION || state == DECRYPTION)
      case(round)
	4'h0: kr_selector    = (state == ENCRYPTION) ? kr1  : kr16;
	4'h1: kr_selector    = (state == ENCRYPTION) ? kr2  : kr15;
	4'h2: kr_selector    = (state == ENCRYPTION) ? kr3  : kr14;
	4'h3: kr_selector    = (state == ENCRYPTION) ? kr4  : kr13;
	4'h4: kr_selector    = (state == ENCRYPTION) ? kr5  : kr12;
	4'h5: kr_selector    = (state == ENCRYPTION) ? kr6  : kr11;
	4'h6: kr_selector    = (state == ENCRYPTION) ? kr7  : kr10;
	4'h7: kr_selector    = (state == ENCRYPTION) ? kr8  : kr9;
	4'h8: kr_selector    = (state == ENCRYPTION) ? kr9  : kr8;
	4'h9: kr_selector    = (state == ENCRYPTION) ? kr10 : kr7;
	4'ha: kr_selector    = (state == ENCRYPTION) ? kr11 : kr6;
	4'hb: kr_selector    = (state == ENCRYPTION) ? kr12 : kr5;
	4'hc: kr_selector    = (state == ENCRYPTION) ? kr13 : kr4;
	4'hd: kr_selector    = (state == ENCRYPTION) ? kr14 : kr3;
	4'he: kr_selector    = (state == ENCRYPTION) ? kr15 : kr2;
	default: kr_selector = (state == ENCRYPTION) ? kr16 : kr1;
      endcase // case(counter)
    else if(state == KEY_SCHEDULE)
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
    if(state ==KEY_SCHEDULE)
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
endmodule // CAST128_key_scheduler


// Randomization module for CAST-128 macro
module CAST128_encrypt( Din, Dout, Drdy, RSTn, EN, CLK, state, round, km_selected, kr_selected );
  input [63:0]  Din;           // Data input
  output [63:0] Dout;          // Data output
  input         Drdy;          // Data ready
  input         RSTn, EN, CLK;

  input [ 2:0] 	state;
  input [ 6:0] 	round;

  input [31:0]  km_selected;
  input [ 4:0]  kr_selected;


  // State assign
  parameter INITIAL      = 3'b000;
  parameter IDLE         = 3'b001;
  parameter KEY_SCHEDULE = 3'b011;
  parameter ENCRYPTION   = 3'b111;
  parameter DECRYPTION   = 3'b101;

  parameter KEY_SCHEDULE_FINAL_ROUND = 7'b1111111;
  parameter ENC_DEC_FINAL_ROUND = 7'h0f;

  parameter ASX_ADD = 2'b10;
  parameter ASX_SUB = 2'b11;
  parameter ASX_XOR = 2'b00;

  reg [63:0] 	work_reg;

  wire [31:0] 	sbox1_out, sbox2_out, sbox3_out, sbox4_out;   // outputs of sboxes
  wire [31:0] 	f_func_out;                                   // output of F-function

  wire [31:0] 	asx_a_out, asx_b_out, asx_c_out, shifted;
  wire [1:0] 	asx_select_a, asx_select_b, asx_select_c, asx_select_d;

  // directly output work_reg
  assign 	Dout = work_reg;

  // Select the operation of ASX (Add-Sub-Xor combined unit)
  assign       {asx_select_a, asx_select_b, asx_select_c, asx_select_d}
                         = asx_selector(state, round);

  // The expression below are serialized according to the data flow.
  CAST128_asx32 CAST128_asx32_a( .in1(km_selected), .in2(Dout[31:0]), .select(asx_select_a), .out(asx_a_out));
  assign       shifted = (asx_a_out << kr_selected) | asx_a_out >> (32-kr_selected) ;
  CAST128_sbox1 CAST128_sbox1( .in(shifted[31:24]), .out(sbox1_out) );
  CAST128_sbox2 CAST128_sbox2( .in(shifted[23:16]), .out(sbox2_out) );
  CAST128_sbox3 CAST128_sbox3( .in(shifted[15:8]),  .out(sbox3_out) );
  CAST128_sbox4 CAST128_sbox4( .in(shifted[7:0]),   .out(sbox4_out) );
  CAST128_asx32 CAST128_asx32_b( .in1(sbox1_out), .in2(sbox2_out), .select(asx_select_b), .out(asx_b_out));
  CAST128_asx32 CAST128_asx32_c( .in1(asx_b_out), .in2(sbox3_out), .select(asx_select_c), .out(asx_c_out));
  CAST128_asx32 CAST128_asx32_d( .in1(asx_c_out), .in2(sbox4_out), .select(asx_select_d), .out(f_func_out));
  
  // work_reg
  always @( posedge CLK ) begin
    if( RSTn == 1'b0 )
      work_reg <= 32'h0000;    
    else if(EN == 1) begin
      case(state)
	IDLE:
	  if(Drdy == 1'b1) work_reg <= Din;
	
	ENCRYPTION, DECRYPTION:
	  work_reg <= ( round == 4'hf ) ?
		      { Dout[63:32] ^ f_func_out, Dout[31:0] } :
		      { Dout[31:0], Dout[63:32] ^ f_func_out };
      endcase // case(state)
    end
  end
  
  // asx_selector returns a 'select' signal of ASXes
  // The order of the signal is,
  // { asx_select_a, asx_select_b, asx_select_c, asx_select_d }
  function [7:0] asx_selector;
    input [2:0] state;
    input [6:0] round;

    case(round)
      4'h0, 4'h3, 4'h6, 4'h9, 4'hc, 4'hf: 
	asx_selector = {ASX_ADD, ASX_XOR, ASX_SUB, ASX_ADD};  // Type1
      
      4'h1, 4'h4, 4'h7, 4'ha, 4'hd:       
	asx_selector = ( state == ENCRYPTION ) ?
		       {ASX_XOR, ASX_SUB, ASX_ADD, ASX_XOR}:  // Type2
		       {ASX_SUB, ASX_ADD, ASX_XOR, ASX_SUB};  // Type3

      default:
        asx_selector = ( state == ENCRYPTION ) ?
		       {ASX_SUB, ASX_ADD, ASX_XOR, ASX_SUB}:  // Type3
	   	       {ASX_XOR, ASX_SUB, ASX_ADD, ASX_XOR};  // Type2
    endcase // case(counter)
  endfunction // asx_selector
  
endmodule // CAST128_encrypt

// 1bit cell of Add/Sub/Xor combined unit
// select means,
//     2'b10: Add
//     2'b11: Sub
//     2'b00: Xor
//     2'b01: Undefined
module CAST128_asx1(in1, in2, carry_in, select, sum);
  input in1, in2, carry_in;
  input [1:0] select;
  output sum;

  wire 	 fa_in1, fa_in2, fa_carry_in;

  assign fa_in1       = in1;
  assign fa_in2       = (select[0] == 1'b0) ? in2  : ~in2;
  assign fa_carry_in  = (select[1] == 1'b0) ? 1'b0 : carry_in;

  assign sum          = fa_in1 ^ fa_in2 ^ fa_carry_in;
endmodule // CAST128_asx1


// A 32-bit Add/Sub/Xor combined unit
// They are connected like Ripple Carry Adder
module CAST128_asx32(in1, in2, select, out);
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

  CAST128_lookahead32 CAST128_la32( .in1(in1), .in2(in2), .carry_in(select[0]), .carry_out(carry_out) );

  CAST128_asx1 CAST128_asx1_00( in1[ 0], in2[ 0],     select[0], select, out[ 0]);
  CAST128_asx1 CAST128_asx1_01( in1[ 1], in2[ 1], carry_out[ 0], select, out[ 1]);
  CAST128_asx1 CAST128_asx1_02( in1[ 2], in2[ 2], carry_out[ 1], select, out[ 2]);
  CAST128_asx1 CAST128_asx1_03( in1[ 3], in2[ 3], carry_out[ 2], select, out[ 3]);
  CAST128_asx1 CAST128_asx1_04( in1[ 4], in2[ 4], carry_out[ 3], select, out[ 4]);
  CAST128_asx1 CAST128_asx1_05( in1[ 5], in2[ 5], carry_out[ 4], select, out[ 5]);
  CAST128_asx1 CAST128_asx1_06( in1[ 6], in2[ 6], carry_out[ 5], select, out[ 6]);
  CAST128_asx1 CAST128_asx1_07( in1[ 7], in2[ 7], carry_out[ 6], select, out[ 7]);
  CAST128_asx1 CAST128_asx1_08( in1[ 8], in2[ 8], carry_out[ 7], select, out[ 8]);
  CAST128_asx1 CAST128_asx1_09( in1[ 9], in2[ 9], carry_out[ 8], select, out[ 9]);
  CAST128_asx1 CAST128_asx1_10( in1[10], in2[10], carry_out[ 9], select, out[10]);
  CAST128_asx1 CAST128_asx1_11( in1[11], in2[11], carry_out[10], select, out[11]);
  CAST128_asx1 CAST128_asx1_12( in1[12], in2[12], carry_out[11], select, out[12]);
  CAST128_asx1 CAST128_asx1_13( in1[13], in2[13], carry_out[12], select, out[13]);
  CAST128_asx1 CAST128_asx1_14( in1[14], in2[14], carry_out[13], select, out[14]);
  CAST128_asx1 CAST128_asx1_15( in1[15], in2[15], carry_out[14], select, out[15]);
  CAST128_asx1 CAST128_asx1_16( in1[16], in2[16], carry_out[15], select, out[16]);
  CAST128_asx1 CAST128_asx1_17( in1[17], in2[17], carry_out[16], select, out[17]);
  CAST128_asx1 CAST128_asx1_18( in1[18], in2[18], carry_out[17], select, out[18]);
  CAST128_asx1 CAST128_asx1_19( in1[19], in2[19], carry_out[18], select, out[19]);
  CAST128_asx1 CAST128_asx1_20( in1[20], in2[20], carry_out[19], select, out[20]);
  CAST128_asx1 CAST128_asx1_21( in1[21], in2[21], carry_out[20], select, out[21]);
  CAST128_asx1 CAST128_asx1_22( in1[22], in2[22], carry_out[21], select, out[22]);
  CAST128_asx1 CAST128_asx1_23( in1[23], in2[23], carry_out[22], select, out[23]);
  CAST128_asx1 CAST128_asx1_24( in1[24], in2[24], carry_out[23], select, out[24]);
  CAST128_asx1 CAST128_asx1_25( in1[25], in2[25], carry_out[24], select, out[25]);
  CAST128_asx1 CAST128_asx1_26( in1[26], in2[26], carry_out[25], select, out[26]);
  CAST128_asx1 CAST128_asx1_27( in1[27], in2[27], carry_out[26], select, out[27]);
  CAST128_asx1 CAST128_asx1_28( in1[28], in2[28], carry_out[27], select, out[28]);
  CAST128_asx1 CAST128_asx1_29( in1[29], in2[29], carry_out[28], select, out[29]);
  CAST128_asx1 CAST128_asx1_30( in1[30], in2[30], carry_out[29], select, out[30]);
  CAST128_asx1 CAST128_asx1_31( in1[31], in2[31], carry_out[30], select, out[31]);
endmodule // CAST128_asx32


module CAST128_lookahead1(in1, in2, carry_in, carry_out, sp, sg);
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
endmodule // CAST128_lookahead1


module CAST128_lookahead2(sp, sg, carry_in, sc);
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
endmodule // CAST128_lookahead2


module CAST128_lookahead32(in1, in2, carry_in, carry_out);
  input  [31:0] in1, in2;
  input         carry_in;
  output [31:0] carry_out;

  wire [7:0] 	sp, sg;
  wire [31:0] 	sc;
  wire [31:0] 	add_or_sub;
  assign 	add_or_sub = (carry_in == 1'b0) ? in2 : ~in2;
  
  CAST128_lookahead1 CAST128_la0( .in1(in1[3:0]),   .in2(add_or_sub[3:0]),   .carry_in(carry_in), .carry_out(carry_out[3:0]),   .sp(sp[0]), .sg(sg[0]) );
  CAST128_lookahead1 CAST128_la1( .in1(in1[7:4]),   .in2(add_or_sub[7:4]),   .carry_in(sc[0]),    .carry_out(carry_out[7:4]),   .sp(sp[1]), .sg(sg[1]) );
  CAST128_lookahead1 CAST128_la2( .in1(in1[11:8]),  .in2(add_or_sub[11:8]),  .carry_in(sc[1]),    .carry_out(carry_out[11:8]),  .sp(sp[2]), .sg(sg[2]) );
  CAST128_lookahead1 CAST128_la3( .in1(in1[15:12]), .in2(add_or_sub[15:12]), .carry_in(sc[2]),    .carry_out(carry_out[15:12]), .sp(sp[3]), .sg(sg[3]) );
  CAST128_lookahead1 CAST128_la4( .in1(in1[19:16]), .in2(add_or_sub[19:16]), .carry_in(sc[3]),    .carry_out(carry_out[19:16]), .sp(sp[4]), .sg(sg[4]) );
  CAST128_lookahead1 CAST128_la5( .in1(in1[23:20]), .in2(add_or_sub[23:20]), .carry_in(sc[4]),    .carry_out(carry_out[23:20]), .sp(sp[5]), .sg(sg[5]) );
  CAST128_lookahead1 CAST128_la6( .in1(in1[27:24]), .in2(add_or_sub[27:24]), .carry_in(sc[5]),    .carry_out(carry_out[27:24]), .sp(sp[6]), .sg(sg[6]) );
  CAST128_lookahead1 CAST128_la7( .in1(in1[31:28]), .in2(add_or_sub[31:28]), .carry_in(sc[6]),    .carry_out(carry_out[31:28]), .sp(sp[7]), .sg(sg[7]) );

  CAST128_lookahead2 CAST128_sla0( .sp(sp[3:0]), .sg(sg[3:0]), .carry_in(carry_in), .sc(sc[3:0]) );
  CAST128_lookahead2 CAST128_sla1( .sp(sp[7:4]), .sg(sg[7:4]), .carry_in(sc[3]),    .sc(sc[7:4]) );

endmodule // CAST128_lookahead32

module CAST128_sbox1(in, out);
   input [7:0] in;
   output [31:0] out;

   assign 	 out = temp(in);
   
   function [31:0] temp;
      input [7:0] in;
      case(in)
	8'h00: temp = 32'h30fb40d4;
	8'h01: temp = 32'h9fa0ff0b;
	8'h02: temp = 32'h6beccd2f;
	8'h03: temp = 32'h3f258c7a;
	8'h04: temp = 32'h1e213f2f;
	8'h05: temp = 32'h9c004dd3;
	8'h06: temp = 32'h6003e540;
	8'h07: temp = 32'hcf9fc949;
	8'h08: temp = 32'hbfd4af27;
	8'h09: temp = 32'h88bbbdb5;
	8'h0a: temp = 32'he2034090;
	8'h0b: temp = 32'h98d09675;
	8'h0c: temp = 32'h6e63a0e0;
	8'h0d: temp = 32'h15c361d2;
	8'h0e: temp = 32'hc2e7661d;
	8'h0f: temp = 32'h22d4ff8e;
	8'h10: temp = 32'h28683b6f;
	8'h11: temp = 32'hc07fd059;
	8'h12: temp = 32'hff2379c8;
	8'h13: temp = 32'h775f50e2;
	8'h14: temp = 32'h43c340d3;
	8'h15: temp = 32'hdf2f8656;
	8'h16: temp = 32'h887ca41a;
	8'h17: temp = 32'ha2d2bd2d;
	8'h18: temp = 32'ha1c9e0d6;
	8'h19: temp = 32'h346c4819;
	8'h1a: temp = 32'h61b76d87;
	8'h1b: temp = 32'h22540f2f;
	8'h1c: temp = 32'h2abe32e1;
	8'h1d: temp = 32'haa54166b;
	8'h1e: temp = 32'h22568e3a;
	8'h1f: temp = 32'ha2d341d0;
	8'h20: temp = 32'h66db40c8;
	8'h21: temp = 32'ha784392f;
	8'h22: temp = 32'h004dff2f;
	8'h23: temp = 32'h2db9d2de;
	8'h24: temp = 32'h97943fac;
	8'h25: temp = 32'h4a97c1d8;
	8'h26: temp = 32'h527644b7;
	8'h27: temp = 32'hb5f437a7;
	8'h28: temp = 32'hb82cbaef;
	8'h29: temp = 32'hd751d159;
	8'h2a: temp = 32'h6ff7f0ed;
	8'h2b: temp = 32'h5a097a1f;
	8'h2c: temp = 32'h827b68d0;
	8'h2d: temp = 32'h90ecf52e;
	8'h2e: temp = 32'h22b0c054;
	8'h2f: temp = 32'hbc8e5935;
	8'h30: temp = 32'h4b6d2f7f;
	8'h31: temp = 32'h50bb64a2;
	8'h32: temp = 32'hd2664910;
	8'h33: temp = 32'hbee5812d;
	8'h34: temp = 32'hb7332290;
	8'h35: temp = 32'he93b159f;
	8'h36: temp = 32'hb48ee411;
	8'h37: temp = 32'h4bff345d;
	8'h38: temp = 32'hfd45c240;
	8'h39: temp = 32'had31973f;
	8'h3a: temp = 32'hc4f6d02e;
	8'h3b: temp = 32'h55fc8165;
	8'h3c: temp = 32'hd5b1caad;
	8'h3d: temp = 32'ha1ac2dae;
	8'h3e: temp = 32'ha2d4b76d;
	8'h3f: temp = 32'hc19b0c50;
	8'h40: temp = 32'h882240f2;
	8'h41: temp = 32'h0c6e4f38;
	8'h42: temp = 32'ha4e4bfd7;
	8'h43: temp = 32'h4f5ba272;
	8'h44: temp = 32'h564c1d2f;
	8'h45: temp = 32'hc59c5319;
	8'h46: temp = 32'hb949e354;
	8'h47: temp = 32'hb04669fe;
	8'h48: temp = 32'hb1b6ab8a;
	8'h49: temp = 32'hc71358dd;
	8'h4a: temp = 32'h6385c545;
	8'h4b: temp = 32'h110f935d;
	8'h4c: temp = 32'h57538ad5;
	8'h4d: temp = 32'h6a390493;
	8'h4e: temp = 32'he63d37e0;
	8'h4f: temp = 32'h2a54f6b3;
	8'h50: temp = 32'h3a787d5f;
	8'h51: temp = 32'h6276a0b5;
	8'h52: temp = 32'h19a6fcdf;
	8'h53: temp = 32'h7a42206a;
	8'h54: temp = 32'h29f9d4d5;
	8'h55: temp = 32'hf61b1891;
	8'h56: temp = 32'hbb72275e;
	8'h57: temp = 32'haa508167;
	8'h58: temp = 32'h38901091;
	8'h59: temp = 32'hc6b505eb;
	8'h5a: temp = 32'h84c7cb8c;
	8'h5b: temp = 32'h2ad75a0f;
	8'h5c: temp = 32'h874a1427;
	8'h5d: temp = 32'ha2d1936b;
	8'h5e: temp = 32'h2ad286af;
	8'h5f: temp = 32'haa56d291;
	8'h60: temp = 32'hd7894360;
	8'h61: temp = 32'h425c750d;
	8'h62: temp = 32'h93b39e26;
	8'h63: temp = 32'h187184c9;
	8'h64: temp = 32'h6c00b32d;
	8'h65: temp = 32'h73e2bb14;
	8'h66: temp = 32'ha0bebc3c;
	8'h67: temp = 32'h54623779;
	8'h68: temp = 32'h64459eab;
	8'h69: temp = 32'h3f328b82;
	8'h6a: temp = 32'h7718cf82;
	8'h6b: temp = 32'h59a2cea6;
	8'h6c: temp = 32'h04ee002e;
	8'h6d: temp = 32'h89fe78e6;
	8'h6e: temp = 32'h3fab0950;
	8'h6f: temp = 32'h325ff6c2;
	8'h70: temp = 32'h81383f05;
	8'h71: temp = 32'h6963c5c8;
	8'h72: temp = 32'h76cb5ad6;
	8'h73: temp = 32'hd49974c9;
	8'h74: temp = 32'hca180dcf;
	8'h75: temp = 32'h380782d5;
	8'h76: temp = 32'hc7fa5cf6;
	8'h77: temp = 32'h8ac31511;
	8'h78: temp = 32'h35e79e13;
	8'h79: temp = 32'h47da91d0;
	8'h7a: temp = 32'hf40f9086;
	8'h7b: temp = 32'ha7e2419e;
	8'h7c: temp = 32'h31366241;
	8'h7d: temp = 32'h051ef495;
	8'h7e: temp = 32'haa573b04;
	8'h7f: temp = 32'h4a805d8d;
	8'h80: temp = 32'h548300d0;
	8'h81: temp = 32'h00322a3c;
	8'h82: temp = 32'hbf64cddf;
	8'h83: temp = 32'hba57a68e;
	8'h84: temp = 32'h75c6372b;
	8'h85: temp = 32'h50afd341;
	8'h86: temp = 32'ha7c13275;
	8'h87: temp = 32'h915a0bf5;
	8'h88: temp = 32'h6b54bfab;
	8'h89: temp = 32'h2b0b1426;
	8'h8a: temp = 32'hab4cc9d7;
	8'h8b: temp = 32'h449ccd82;
	8'h8c: temp = 32'hf7fbf265;
	8'h8d: temp = 32'hab85c5f3;
	8'h8e: temp = 32'h1b55db94;
	8'h8f: temp = 32'haad4e324;
	8'h90: temp = 32'hcfa4bd3f;
	8'h91: temp = 32'h2deaa3e2;
	8'h92: temp = 32'h9e204d02;
	8'h93: temp = 32'hc8bd25ac;
	8'h94: temp = 32'headf55b3;
	8'h95: temp = 32'hd5bd9e98;
	8'h96: temp = 32'he31231b2;
	8'h97: temp = 32'h2ad5ad6c;
	8'h98: temp = 32'h954329de;
	8'h99: temp = 32'hadbe4528;
	8'h9a: temp = 32'hd8710f69;
	8'h9b: temp = 32'haa51c90f;
	8'h9c: temp = 32'haa786bf6;
	8'h9d: temp = 32'h22513f1e;
	8'h9e: temp = 32'haa51a79b;
	8'h9f: temp = 32'h2ad344cc;
	8'ha0: temp = 32'h7b5a41f0;
	8'ha1: temp = 32'hd37cfbad;
	8'ha2: temp = 32'h1b069505;
	8'ha3: temp = 32'h41ece491;
	8'ha4: temp = 32'hb4c332e6;
	8'ha5: temp = 32'h032268d4;
	8'ha6: temp = 32'hc9600acc;
	8'ha7: temp = 32'hce387e6d;
	8'ha8: temp = 32'hbf6bb16c;
	8'ha9: temp = 32'h6a70fb78;
	8'haa: temp = 32'h0d03d9c9;
	8'hab: temp = 32'hd4df39de;
	8'hac: temp = 32'he01063da;
	8'had: temp = 32'h4736f464;
	8'hae: temp = 32'h5ad328d8;
	8'haf: temp = 32'hb347cc96;
	8'hb0: temp = 32'h75bb0fc3;
	8'hb1: temp = 32'h98511bfb;
	8'hb2: temp = 32'h4ffbcc35;
	8'hb3: temp = 32'hb58bcf6a;
	8'hb4: temp = 32'he11f0abc;
	8'hb5: temp = 32'hbfc5fe4a;
	8'hb6: temp = 32'ha70aec10;
	8'hb7: temp = 32'hac39570a;
	8'hb8: temp = 32'h3f04442f;
	8'hb9: temp = 32'h6188b153;
	8'hba: temp = 32'he0397a2e;
	8'hbb: temp = 32'h5727cb79;
	8'hbc: temp = 32'h9ceb418f;
	8'hbd: temp = 32'h1cacd68d;
	8'hbe: temp = 32'h2ad37c96;
	8'hbf: temp = 32'h0175cb9d;
	8'hc0: temp = 32'hc69dff09;
	8'hc1: temp = 32'hc75b65f0;
	8'hc2: temp = 32'hd9db40d8;
	8'hc3: temp = 32'hec0e7779;
	8'hc4: temp = 32'h4744ead4;
	8'hc5: temp = 32'hb11c3274;
	8'hc6: temp = 32'hdd24cb9e;
	8'hc7: temp = 32'h7e1c54bd;
	8'hc8: temp = 32'hf01144f9;
	8'hc9: temp = 32'hd2240eb1;
	8'hca: temp = 32'h9675b3fd;
	8'hcb: temp = 32'ha3ac3755;
	8'hcc: temp = 32'hd47c27af;
	8'hcd: temp = 32'h51c85f4d;
	8'hce: temp = 32'h56907596;
	8'hcf: temp = 32'ha5bb15e6;
	8'hd0: temp = 32'h580304f0;
	8'hd1: temp = 32'hca042cf1;
	8'hd2: temp = 32'h011a37ea;
	8'hd3: temp = 32'h8dbfaadb;
	8'hd4: temp = 32'h35ba3e4a;
	8'hd5: temp = 32'h3526ffa0;
	8'hd6: temp = 32'hc37b4d09;
	8'hd7: temp = 32'hbc306ed9;
	8'hd8: temp = 32'h98a52666;
	8'hd9: temp = 32'h5648f725;
	8'hda: temp = 32'hff5e569d;
	8'hdb: temp = 32'h0ced63d0;
	8'hdc: temp = 32'h7c63b2cf;
	8'hdd: temp = 32'h700b45e1;
	8'hde: temp = 32'hd5ea50f1;
	8'hdf: temp = 32'h85a92872;
	8'he0: temp = 32'haf1fbda7;
	8'he1: temp = 32'hd4234870;
	8'he2: temp = 32'ha7870bf3;
	8'he3: temp = 32'h2d3b4d79;
	8'he4: temp = 32'h42e04198;
	8'he5: temp = 32'h0cd0ede7;
	8'he6: temp = 32'h26470db8;
	8'he7: temp = 32'hf881814c;
	8'he8: temp = 32'h474d6ad7;
	8'he9: temp = 32'h7c0c5e5c;
	8'hea: temp = 32'hd1231959;
	8'heb: temp = 32'h381b7298;
	8'hec: temp = 32'hf5d2f4db;
	8'hed: temp = 32'hab838653;
	8'hee: temp = 32'h6e2f1e23;
	8'hef: temp = 32'h83719c9e;
	8'hf0: temp = 32'hbd91e046;
	8'hf1: temp = 32'h9a56456e;
	8'hf2: temp = 32'hdc39200c;
	8'hf3: temp = 32'h20c8c571;
	8'hf4: temp = 32'h962bda1c;
	8'hf5: temp = 32'he1e696ff;
	8'hf6: temp = 32'hb141ab08;
	8'hf7: temp = 32'h7cca89b9;
	8'hf8: temp = 32'h1a69e783;
	8'hf9: temp = 32'h02cc4843;
	8'hfa: temp = 32'ha2f7c579;
	8'hfb: temp = 32'h429ef47d;
	8'hfc: temp = 32'h427b169c;
	8'hfd: temp = 32'h5ac9f049;
	8'hfe: temp = 32'hdd8f0f00;
	8'hff: temp = 32'h5c8165bf;
      endcase // case(in)
   endfunction // temp
endmodule // CAST128_sbox1

module CAST128_sbox2(in, out);
   input [7:0] in;
   output [31:0] out;

   assign 	 out = temp(in);
   
   function [31:0] temp;
      input [7:0] in;
      case(in)
	8'h00: temp = 32'h1f201094;
	8'h01: temp = 32'hef0ba75b;
	8'h02: temp = 32'h69e3cf7e;
	8'h03: temp = 32'h393f4380;
	8'h04: temp = 32'hfe61cf7a;
	8'h05: temp = 32'heec5207a;
	8'h06: temp = 32'h55889c94;
	8'h07: temp = 32'h72fc0651;
	8'h08: temp = 32'hada7ef79;
	8'h09: temp = 32'h4e1d7235;
	8'h0a: temp = 32'hd55a63ce;
	8'h0b: temp = 32'hde0436ba;
	8'h0c: temp = 32'h99c430ef;
	8'h0d: temp = 32'h5f0c0794;
	8'h0e: temp = 32'h18dcdb7d;
	8'h0f: temp = 32'ha1d6eff3;
	8'h10: temp = 32'ha0b52f7b;
	8'h11: temp = 32'h59e83605;
	8'h12: temp = 32'hee15b094;
	8'h13: temp = 32'he9ffd909;
	8'h14: temp = 32'hdc440086;
	8'h15: temp = 32'hef944459;
	8'h16: temp = 32'hba83ccb3;
	8'h17: temp = 32'he0c3cdfb;
	8'h18: temp = 32'hd1da4181;
	8'h19: temp = 32'h3b092ab1;
	8'h1a: temp = 32'hf997f1c1;
	8'h1b: temp = 32'ha5e6cf7b;
	8'h1c: temp = 32'h01420ddb;
	8'h1d: temp = 32'he4e7ef5b;
	8'h1e: temp = 32'h25a1ff41;
	8'h1f: temp = 32'he180f806;
	8'h20: temp = 32'h1fc41080;
	8'h21: temp = 32'h179bee7a;
	8'h22: temp = 32'hd37ac6a9;
	8'h23: temp = 32'hfe5830a4;
	8'h24: temp = 32'h98de8b7f;
	8'h25: temp = 32'h77e83f4e;
	8'h26: temp = 32'h79929269;
	8'h27: temp = 32'h24fa9f7b;
	8'h28: temp = 32'he113c85b;
	8'h29: temp = 32'hacc40083;
	8'h2a: temp = 32'hd7503525;
	8'h2b: temp = 32'hf7ea615f;
	8'h2c: temp = 32'h62143154;
	8'h2d: temp = 32'h0d554b63;
	8'h2e: temp = 32'h5d681121;
	8'h2f: temp = 32'hc866c359;
	8'h30: temp = 32'h3d63cf73;
	8'h31: temp = 32'hcee234c0;
	8'h32: temp = 32'hd4d87e87;
	8'h33: temp = 32'h5c672b21;
	8'h34: temp = 32'h071f6181;
	8'h35: temp = 32'h39f7627f;
	8'h36: temp = 32'h361e3084;
	8'h37: temp = 32'he4eb573b;
	8'h38: temp = 32'h602f64a4;
	8'h39: temp = 32'hd63acd9c;
	8'h3a: temp = 32'h1bbc4635;
	8'h3b: temp = 32'h9e81032d;
	8'h3c: temp = 32'h2701f50c;
	8'h3d: temp = 32'h99847ab4;
	8'h3e: temp = 32'ha0e3df79;
	8'h3f: temp = 32'hba6cf38c;
	8'h40: temp = 32'h10843094;
	8'h41: temp = 32'h2537a95e;
	8'h42: temp = 32'hf46f6ffe;
	8'h43: temp = 32'ha1ff3b1f;
	8'h44: temp = 32'h208cfb6a;
	8'h45: temp = 32'h8f458c74;
	8'h46: temp = 32'hd9e0a227;
	8'h47: temp = 32'h4ec73a34;
	8'h48: temp = 32'hfc884f69;
	8'h49: temp = 32'h3e4de8df;
	8'h4a: temp = 32'hef0e0088;
	8'h4b: temp = 32'h3559648d;
	8'h4c: temp = 32'h8a45388c;
	8'h4d: temp = 32'h1d804366;
	8'h4e: temp = 32'h721d9bfd;
	8'h4f: temp = 32'ha58684bb;
	8'h50: temp = 32'he8256333;
	8'h51: temp = 32'h844e8212;
	8'h52: temp = 32'h128d8098;
	8'h53: temp = 32'hfed33fb4;
	8'h54: temp = 32'hce280ae1;
	8'h55: temp = 32'h27e19ba5;
	8'h56: temp = 32'hd5a6c252;
	8'h57: temp = 32'he49754bd;
	8'h58: temp = 32'hc5d655dd;
	8'h59: temp = 32'heb667064;
	8'h5a: temp = 32'h77840b4d;
	8'h5b: temp = 32'ha1b6a801;
	8'h5c: temp = 32'h84db26a9;
	8'h5d: temp = 32'he0b56714;
	8'h5e: temp = 32'h21f043b7;
	8'h5f: temp = 32'he5d05860;
	8'h60: temp = 32'h54f03084;
	8'h61: temp = 32'h066ff472;
	8'h62: temp = 32'ha31aa153;
	8'h63: temp = 32'hdadc4755;
	8'h64: temp = 32'hb5625dbf;
	8'h65: temp = 32'h68561be6;
	8'h66: temp = 32'h83ca6b94;
	8'h67: temp = 32'h2d6ed23b;
	8'h68: temp = 32'heccf01db;
	8'h69: temp = 32'ha6d3d0ba;
	8'h6a: temp = 32'hb6803d5c;
	8'h6b: temp = 32'haf77a709;
	8'h6c: temp = 32'h33b4a34c;
	8'h6d: temp = 32'h397bc8d6;
	8'h6e: temp = 32'h5ee22b95;
	8'h6f: temp = 32'h5f0e5304;
	8'h70: temp = 32'h81ed6f61;
	8'h71: temp = 32'h20e74364;
	8'h72: temp = 32'hb45e1378;
	8'h73: temp = 32'hde18639b;
	8'h74: temp = 32'h881ca122;
	8'h75: temp = 32'hb96726d1;
	8'h76: temp = 32'h8049a7e8;
	8'h77: temp = 32'h22b7da7b;
	8'h78: temp = 32'h5e552d25;
	8'h79: temp = 32'h5272d237;
	8'h7a: temp = 32'h79d2951c;
	8'h7b: temp = 32'hc60d894c;
	8'h7c: temp = 32'h488cb402;
	8'h7d: temp = 32'h1ba4fe5b;
	8'h7e: temp = 32'ha4b09f6b;
	8'h7f: temp = 32'h1ca815cf;
	8'h80: temp = 32'ha20c3005;
	8'h81: temp = 32'h8871df63;
	8'h82: temp = 32'hb9de2fcb;
	8'h83: temp = 32'h0cc6c9e9;
	8'h84: temp = 32'h0beeff53;
	8'h85: temp = 32'he3214517;
	8'h86: temp = 32'hb4542835;
	8'h87: temp = 32'h9f63293c;
	8'h88: temp = 32'hee41e729;
	8'h89: temp = 32'h6e1d2d7c;
	8'h8a: temp = 32'h50045286;
	8'h8b: temp = 32'h1e6685f3;
	8'h8c: temp = 32'hf33401c6;
	8'h8d: temp = 32'h30a22c95;
	8'h8e: temp = 32'h31a70850;
	8'h8f: temp = 32'h60930f13;
	8'h90: temp = 32'h73f98417;
	8'h91: temp = 32'ha1269859;
	8'h92: temp = 32'hec645c44;
	8'h93: temp = 32'h52c877a9;
	8'h94: temp = 32'hcdff33a6;
	8'h95: temp = 32'ha02b1741;
	8'h96: temp = 32'h7cbad9a2;
	8'h97: temp = 32'h2180036f;
	8'h98: temp = 32'h50d99c08;
	8'h99: temp = 32'hcb3f4861;
	8'h9a: temp = 32'hc26bd765;
	8'h9b: temp = 32'h64a3f6ab;
	8'h9c: temp = 32'h80342676;
	8'h9d: temp = 32'h25a75e7b;
	8'h9e: temp = 32'he4e6d1fc;
	8'h9f: temp = 32'h20c710e6;
	8'ha0: temp = 32'hcdf0b680;
	8'ha1: temp = 32'h17844d3b;
	8'ha2: temp = 32'h31eef84d;
	8'ha3: temp = 32'h7e0824e4;
	8'ha4: temp = 32'h2ccb49eb;
	8'ha5: temp = 32'h846a3bae;
	8'ha6: temp = 32'h8ff77888;
	8'ha7: temp = 32'hee5d60f6;
	8'ha8: temp = 32'h7af75673;
	8'ha9: temp = 32'h2fdd5cdb;
	8'haa: temp = 32'ha11631c1;
	8'hab: temp = 32'h30f66f43;
	8'hac: temp = 32'hb3faec54;
	8'had: temp = 32'h157fd7fa;
	8'hae: temp = 32'hef8579cc;
	8'haf: temp = 32'hd152de58;
	8'hb0: temp = 32'hdb2ffd5e;
	8'hb1: temp = 32'h8f32ce19;
	8'hb2: temp = 32'h306af97a;
	8'hb3: temp = 32'h02f03ef8;
	8'hb4: temp = 32'h99319ad5;
	8'hb5: temp = 32'hc242fa0f;
	8'hb6: temp = 32'ha7e3ebb0;
	8'hb7: temp = 32'hc68e4906;
	8'hb8: temp = 32'hb8da230c;
	8'hb9: temp = 32'h80823028;
	8'hba: temp = 32'hdcdef3c8;
	8'hbb: temp = 32'hd35fb171;
	8'hbc: temp = 32'h088a1bc8;
	8'hbd: temp = 32'hbec0c560;
	8'hbe: temp = 32'h61a3c9e8;
	8'hbf: temp = 32'hbca8f54d;
	8'hc0: temp = 32'hc72feffa;
	8'hc1: temp = 32'h22822e99;
	8'hc2: temp = 32'h82c570b4;
	8'hc3: temp = 32'hd8d94e89;
	8'hc4: temp = 32'h8b1c34bc;
	8'hc5: temp = 32'h301e16e6;
	8'hc6: temp = 32'h273be979;
	8'hc7: temp = 32'hb0ffeaa6;
	8'hc8: temp = 32'h61d9b8c6;
	8'hc9: temp = 32'h00b24869;
	8'hca: temp = 32'hb7ffce3f;
	8'hcb: temp = 32'h08dc283b;
	8'hcc: temp = 32'h43daf65a;
	8'hcd: temp = 32'hf7e19798;
	8'hce: temp = 32'h7619b72f;
	8'hcf: temp = 32'h8f1c9ba4;
	8'hd0: temp = 32'hdc8637a0;
	8'hd1: temp = 32'h16a7d3b1;
	8'hd2: temp = 32'h9fc393b7;
	8'hd3: temp = 32'ha7136eeb;
	8'hd4: temp = 32'hc6bcc63e;
	8'hd5: temp = 32'h1a513742;
	8'hd6: temp = 32'hef6828bc;
	8'hd7: temp = 32'h520365d6;
	8'hd8: temp = 32'h2d6a77ab;
	8'hd9: temp = 32'h3527ed4b;
	8'hda: temp = 32'h821fd216;
	8'hdb: temp = 32'h095c6e2e;
	8'hdc: temp = 32'hdb92f2fb;
	8'hdd: temp = 32'h5eea29cb;
	8'hde: temp = 32'h145892f5;
	8'hdf: temp = 32'h91584f7f;
	8'he0: temp = 32'h5483697b;
	8'he1: temp = 32'h2667a8cc;
	8'he2: temp = 32'h85196048;
	8'he3: temp = 32'h8c4bacea;
	8'he4: temp = 32'h833860d4;
	8'he5: temp = 32'h0d23e0f9;
	8'he6: temp = 32'h6c387e8a;
	8'he7: temp = 32'h0ae6d249;
	8'he8: temp = 32'hb284600c;
	8'he9: temp = 32'hd835731d;
	8'hea: temp = 32'hdcb1c647;
	8'heb: temp = 32'hac4c56ea;
	8'hec: temp = 32'h3ebd81b3;
	8'hed: temp = 32'h230eabb0;
	8'hee: temp = 32'h6438bc87;
	8'hef: temp = 32'hf0b5b1fa;
	8'hf0: temp = 32'h8f5ea2b3;
	8'hf1: temp = 32'hfc184642;
	8'hf2: temp = 32'h0a036b7a;
	8'hf3: temp = 32'h4fb089bd;
	8'hf4: temp = 32'h649da589;
	8'hf5: temp = 32'ha345415e;
	8'hf6: temp = 32'h5c038323;
	8'hf7: temp = 32'h3e5d3bb9;
	8'hf8: temp = 32'h43d79572;
	8'hf9: temp = 32'h7e6dd07c;
	8'hfa: temp = 32'h06dfdf1e;
	8'hfb: temp = 32'h6c6cc4ef;
	8'hfc: temp = 32'h7160a539;
	8'hfd: temp = 32'h73bfbe70;
	8'hfe: temp = 32'h83877605;
	8'hff: temp = 32'h4523ecf1;
      endcase // case(in)
   endfunction // temp
endmodule // CAST128_sbox2


module CAST128_sbox3(in, out);
   input [7:0] in;
   output [31:0] out;

   assign 	 out = temp(in);
   
   function [31:0] temp;
      input [7:0] in;
      case(in)
	8'h00: temp = 32'h8defc240;
	8'h01: temp = 32'h25fa5d9f;
	8'h02: temp = 32'heb903dbf;
	8'h03: temp = 32'he810c907;
	8'h04: temp = 32'h47607fff;
	8'h05: temp = 32'h369fe44b;
	8'h06: temp = 32'h8c1fc644;
	8'h07: temp = 32'haececa90;
	8'h08: temp = 32'hbeb1f9bf;
	8'h09: temp = 32'heefbcaea;
	8'h0a: temp = 32'he8cf1950;
	8'h0b: temp = 32'h51df07ae;
	8'h0c: temp = 32'h920e8806;
	8'h0d: temp = 32'hf0ad0548;
	8'h0e: temp = 32'he13c8d83;
	8'h0f: temp = 32'h927010d5;
	8'h10: temp = 32'h11107d9f;
	8'h11: temp = 32'h07647db9;
	8'h12: temp = 32'hb2e3e4d4;
	8'h13: temp = 32'h3d4f285e;
	8'h14: temp = 32'hb9afa820;
	8'h15: temp = 32'hfade82e0;
	8'h16: temp = 32'ha067268b;
	8'h17: temp = 32'h8272792e;
	8'h18: temp = 32'h553fb2c0;
	8'h19: temp = 32'h489ae22b;
	8'h1a: temp = 32'hd4ef9794;
	8'h1b: temp = 32'h125e3fbc;
	8'h1c: temp = 32'h21fffcee;
	8'h1d: temp = 32'h825b1bfd;
	8'h1e: temp = 32'h9255c5ed;
	8'h1f: temp = 32'h1257a240;
	8'h20: temp = 32'h4e1a8302;
	8'h21: temp = 32'hbae07fff;
	8'h22: temp = 32'h528246e7;
	8'h23: temp = 32'h8e57140e;
	8'h24: temp = 32'h3373f7bf;
	8'h25: temp = 32'h8c9f8188;
	8'h26: temp = 32'ha6fc4ee8;
	8'h27: temp = 32'hc982b5a5;
	8'h28: temp = 32'ha8c01db7;
	8'h29: temp = 32'h579fc264;
	8'h2a: temp = 32'h67094f31;
	8'h2b: temp = 32'hf2bd3f5f;
	8'h2c: temp = 32'h40fff7c1;
	8'h2d: temp = 32'h1fb78dfc;
	8'h2e: temp = 32'h8e6bd2c1;
	8'h2f: temp = 32'h437be59b;
	8'h30: temp = 32'h99b03dbf;
	8'h31: temp = 32'hb5dbc64b;
	8'h32: temp = 32'h638dc0e6;
	8'h33: temp = 32'h55819d99;
	8'h34: temp = 32'ha197c81c;
	8'h35: temp = 32'h4a012d6e;
	8'h36: temp = 32'hc5884a28;
	8'h37: temp = 32'hccc36f71;
	8'h38: temp = 32'hb843c213;
	8'h39: temp = 32'h6c0743f1;
	8'h3a: temp = 32'h8309893c;
	8'h3b: temp = 32'h0feddd5f;
	8'h3c: temp = 32'h2f7fe850;
	8'h3d: temp = 32'hd7c07f7e;
	8'h3e: temp = 32'h02507fbf;
	8'h3f: temp = 32'h5afb9a04;
	8'h40: temp = 32'ha747d2d0;
	8'h41: temp = 32'h1651192e;
	8'h42: temp = 32'haf70bf3e;
	8'h43: temp = 32'h58c31380;
	8'h44: temp = 32'h5f98302e;
	8'h45: temp = 32'h727cc3c4;
	8'h46: temp = 32'h0a0fb402;
	8'h47: temp = 32'h0f7fef82;
	8'h48: temp = 32'h8c96fdad;
	8'h49: temp = 32'h5d2c2aae;
	8'h4a: temp = 32'h8ee99a49;
	8'h4b: temp = 32'h50da88b8;
	8'h4c: temp = 32'h8427f4a0;
	8'h4d: temp = 32'h1eac5790;
	8'h4e: temp = 32'h796fb449;
	8'h4f: temp = 32'h8252dc15;
	8'h50: temp = 32'hefbd7d9b;
	8'h51: temp = 32'ha672597d;
	8'h52: temp = 32'hada840d8;
	8'h53: temp = 32'h45f54504;
	8'h54: temp = 32'hfa5d7403;
	8'h55: temp = 32'he83ec305;
	8'h56: temp = 32'h4f91751a;
	8'h57: temp = 32'h925669c2;
	8'h58: temp = 32'h23efe941;
	8'h59: temp = 32'ha903f12e;
	8'h5a: temp = 32'h60270df2;
	8'h5b: temp = 32'h0276e4b6;
	8'h5c: temp = 32'h94fd6574;
	8'h5d: temp = 32'h927985b2;
	8'h5e: temp = 32'h8276dbcb;
	8'h5f: temp = 32'h02778176;
	8'h60: temp = 32'hf8af918d;
	8'h61: temp = 32'h4e48f79e;
	8'h62: temp = 32'h8f616ddf;
	8'h63: temp = 32'he29d840e;
	8'h64: temp = 32'h842f7d83;
	8'h65: temp = 32'h340ce5c8;
	8'h66: temp = 32'h96bbb682;
	8'h67: temp = 32'h93b4b148;
	8'h68: temp = 32'hef303cab;
	8'h69: temp = 32'h984faf28;
	8'h6a: temp = 32'h779faf9b;
	8'h6b: temp = 32'h92dc560d;
	8'h6c: temp = 32'h224d1e20;
	8'h6d: temp = 32'h8437aa88;
	8'h6e: temp = 32'h7d29dc96;
	8'h6f: temp = 32'h2756d3dc;
	8'h70: temp = 32'h8b907cee;
	8'h71: temp = 32'hb51fd240;
	8'h72: temp = 32'he7c07ce3;
	8'h73: temp = 32'he566b4a1;
	8'h74: temp = 32'hc3e9615e;
	8'h75: temp = 32'h3cf8209d;
	8'h76: temp = 32'h6094d1e3;
	8'h77: temp = 32'hcd9ca341;
	8'h78: temp = 32'h5c76460e;
	8'h79: temp = 32'h00ea983b;
	8'h7a: temp = 32'hd4d67881;
	8'h7b: temp = 32'hfd47572c;
	8'h7c: temp = 32'hf76cedd9;
	8'h7d: temp = 32'hbda8229c;
	8'h7e: temp = 32'h127dadaa;
	8'h7f: temp = 32'h438a074e;
	8'h80: temp = 32'h1f97c090;
	8'h81: temp = 32'h081bdb8a;
	8'h82: temp = 32'h93a07ebe;
	8'h83: temp = 32'hb938ca15;
	8'h84: temp = 32'h97b03cff;
	8'h85: temp = 32'h3dc2c0f8;
	8'h86: temp = 32'h8d1ab2ec;
	8'h87: temp = 32'h64380e51;
	8'h88: temp = 32'h68cc7bfb;
	8'h89: temp = 32'hd90f2788;
	8'h8a: temp = 32'h12490181;
	8'h8b: temp = 32'h5de5ffd4;
	8'h8c: temp = 32'hdd7ef86a;
	8'h8d: temp = 32'h76a2e214;
	8'h8e: temp = 32'hb9a40368;
	8'h8f: temp = 32'h925d958f;
	8'h90: temp = 32'h4b39fffa;
	8'h91: temp = 32'hba39aee9;
	8'h92: temp = 32'ha4ffd30b;
	8'h93: temp = 32'hfaf7933b;
	8'h94: temp = 32'h6d498623;
	8'h95: temp = 32'h193cbcfa;
	8'h96: temp = 32'h27627545;
	8'h97: temp = 32'h825cf47a;
	8'h98: temp = 32'h61bd8ba0;
	8'h99: temp = 32'hd11e42d1;
	8'h9a: temp = 32'hcead04f4;
	8'h9b: temp = 32'h127ea392;
	8'h9c: temp = 32'h10428db7;
	8'h9d: temp = 32'h8272a972;
	8'h9e: temp = 32'h9270c4a8;
	8'h9f: temp = 32'h127de50b;
	8'ha0: temp = 32'h285ba1c8;
	8'ha1: temp = 32'h3c62f44f;
	8'ha2: temp = 32'h35c0eaa5;
	8'ha3: temp = 32'he805d231;
	8'ha4: temp = 32'h428929fb;
	8'ha5: temp = 32'hb4fcdf82;
	8'ha6: temp = 32'h4fb66a53;
	8'ha7: temp = 32'h0e7dc15b;
	8'ha8: temp = 32'h1f081fab;
	8'ha9: temp = 32'h108618ae;
	8'haa: temp = 32'hfcfd086d;
	8'hab: temp = 32'hf9ff2889;
	8'hac: temp = 32'h694bcc11;
	8'had: temp = 32'h236a5cae;
	8'hae: temp = 32'h12deca4d;
	8'haf: temp = 32'h2c3f8cc5;
	8'hb0: temp = 32'hd2d02dfe;
	8'hb1: temp = 32'hf8ef5896;
	8'hb2: temp = 32'he4cf52da;
	8'hb3: temp = 32'h95155b67;
	8'hb4: temp = 32'h494a488c;
	8'hb5: temp = 32'hb9b6a80c;
	8'hb6: temp = 32'h5c8f82bc;
	8'hb7: temp = 32'h89d36b45;
	8'hb8: temp = 32'h3a609437;
	8'hb9: temp = 32'hec00c9a9;
	8'hba: temp = 32'h44715253;
	8'hbb: temp = 32'h0a874b49;
	8'hbc: temp = 32'hd773bc40;
	8'hbd: temp = 32'h7c34671c;
	8'hbe: temp = 32'h02717ef6;
	8'hbf: temp = 32'h4feb5536;
	8'hc0: temp = 32'ha2d02fff;
	8'hc1: temp = 32'hd2bf60c4;
	8'hc2: temp = 32'hd43f03c0;
	8'hc3: temp = 32'h50b4ef6d;
	8'hc4: temp = 32'h07478cd1;
	8'hc5: temp = 32'h006e1888;
	8'hc6: temp = 32'ha2e53f55;
	8'hc7: temp = 32'hb9e6d4bc;
	8'hc8: temp = 32'ha2048016;
	8'hc9: temp = 32'h97573833;
	8'hca: temp = 32'hd7207d67;
	8'hcb: temp = 32'hde0f8f3d;
	8'hcc: temp = 32'h72f87b33;
	8'hcd: temp = 32'habcc4f33;
	8'hce: temp = 32'h7688c55d;
	8'hcf: temp = 32'h7b00a6b0;
	8'hd0: temp = 32'h947b0001;
	8'hd1: temp = 32'h570075d2;
	8'hd2: temp = 32'hf9bb88f8;
	8'hd3: temp = 32'h8942019e;
	8'hd4: temp = 32'h4264a5ff;
	8'hd5: temp = 32'h856302e0;
	8'hd6: temp = 32'h72dbd92b;
	8'hd7: temp = 32'hee971b69;
	8'hd8: temp = 32'h6ea22fde;
	8'hd9: temp = 32'h5f08ae2b;
	8'hda: temp = 32'haf7a616d;
	8'hdb: temp = 32'he5c98767;
	8'hdc: temp = 32'hcf1febd2;
	8'hdd: temp = 32'h61efc8c2;
	8'hde: temp = 32'hf1ac2571;
	8'hdf: temp = 32'hcc8239c2;
	8'he0: temp = 32'h67214cb8;
	8'he1: temp = 32'hb1e583d1;
	8'he2: temp = 32'hb7dc3e62;
	8'he3: temp = 32'h7f10bdce;
	8'he4: temp = 32'hf90a5c38;
	8'he5: temp = 32'h0ff0443d;
	8'he6: temp = 32'h606e6dc6;
	8'he7: temp = 32'h60543a49;
	8'he8: temp = 32'h5727c148;
	8'he9: temp = 32'h2be98a1d;
	8'hea: temp = 32'h8ab41738;
	8'heb: temp = 32'h20e1be24;
	8'hec: temp = 32'haf96da0f;
	8'hed: temp = 32'h68458425;
	8'hee: temp = 32'h99833be5;
	8'hef: temp = 32'h600d457d;
	8'hf0: temp = 32'h282f9350;
	8'hf1: temp = 32'h8334b362;
	8'hf2: temp = 32'hd91d1120;
	8'hf3: temp = 32'h2b6d8da0;
	8'hf4: temp = 32'h642b1e31;
	8'hf5: temp = 32'h9c305a00;
	8'hf6: temp = 32'h52bce688;
	8'hf7: temp = 32'h1b03588a;
	8'hf8: temp = 32'hf7baefd5;
	8'hf9: temp = 32'h4142ed9c;
	8'hfa: temp = 32'ha4315c11;
	8'hfb: temp = 32'h83323ec5;
	8'hfc: temp = 32'hdfef4636;
	8'hfd: temp = 32'ha133c501;
	8'hfe: temp = 32'he9d3531c;
	8'hff: temp = 32'hee353783;

      endcase // case(in)
   endfunction // temp
endmodule // CAST128_sbox3


module CAST128_sbox4(in, out);
   input [7:0] in;
   output [31:0] out;

   assign 	 out = temp(in);
   
   function [31:0] temp;
      input [7:0] in;
      case(in)
	8'h00: temp = 32'h9db30420;
	8'h01: temp = 32'h1fb6e9de;
	8'h02: temp = 32'ha7be7bef;
	8'h03: temp = 32'hd273a298;
	8'h04: temp = 32'h4a4f7bdb;
	8'h05: temp = 32'h64ad8c57;
	8'h06: temp = 32'h85510443;
	8'h07: temp = 32'hfa020ed1;
	8'h08: temp = 32'h7e287aff;
	8'h09: temp = 32'he60fb663;
	8'h0a: temp = 32'h095f35a1;
	8'h0b: temp = 32'h79ebf120;
	8'h0c: temp = 32'hfd059d43;
	8'h0d: temp = 32'h6497b7b1;
	8'h0e: temp = 32'hf3641f63;
	8'h0f: temp = 32'h241e4adf;
	8'h10: temp = 32'h28147f5f;
	8'h11: temp = 32'h4fa2b8cd;
	8'h12: temp = 32'hc9430040;
	8'h13: temp = 32'h0cc32220;
	8'h14: temp = 32'hfdd30b30;
	8'h15: temp = 32'hc0a5374f;
	8'h16: temp = 32'h1d2d00d9;
	8'h17: temp = 32'h24147b15;
	8'h18: temp = 32'hee4d111a;
	8'h19: temp = 32'h0fca5167;
	8'h1a: temp = 32'h71ff904c;
	8'h1b: temp = 32'h2d195ffe;
	8'h1c: temp = 32'h1a05645f;
	8'h1d: temp = 32'h0c13fefe;
	8'h1e: temp = 32'h081b08ca;
	8'h1f: temp = 32'h05170121;
	8'h20: temp = 32'h80530100;
	8'h21: temp = 32'he83e5efe;
	8'h22: temp = 32'hac9af4f8;
	8'h23: temp = 32'h7fe72701;
	8'h24: temp = 32'hd2b8ee5f;
	8'h25: temp = 32'h06df4261;
	8'h26: temp = 32'hbb9e9b8a;
	8'h27: temp = 32'h7293ea25;
	8'h28: temp = 32'hce84ffdf;
	8'h29: temp = 32'hf5718801;
	8'h2a: temp = 32'h3dd64b04;
	8'h2b: temp = 32'ha26f263b;
	8'h2c: temp = 32'h7ed48400;
	8'h2d: temp = 32'h547eebe6;
	8'h2e: temp = 32'h446d4ca0;
	8'h2f: temp = 32'h6cf3d6f5;
	8'h30: temp = 32'h2649abdf;
	8'h31: temp = 32'haea0c7f5;
	8'h32: temp = 32'h36338cc1;
	8'h33: temp = 32'h503f7e93;
	8'h34: temp = 32'hd3772061;
	8'h35: temp = 32'h11b638e1;
	8'h36: temp = 32'h72500e03;
	8'h37: temp = 32'hf80eb2bb;
	8'h38: temp = 32'habe0502e;
	8'h39: temp = 32'hec8d77de;
	8'h3a: temp = 32'h57971e81;
	8'h3b: temp = 32'he14f6746;
	8'h3c: temp = 32'hc9335400;
	8'h3d: temp = 32'h6920318f;
	8'h3e: temp = 32'h081dbb99;
	8'h3f: temp = 32'hffc304a5;
	8'h40: temp = 32'h4d351805;
	8'h41: temp = 32'h7f3d5ce3;
	8'h42: temp = 32'ha6c866c6;
	8'h43: temp = 32'h5d5bcca9;
	8'h44: temp = 32'hdaec6fea;
	8'h45: temp = 32'h9f926f91;
	8'h46: temp = 32'h9f46222f;
	8'h47: temp = 32'h3991467d;
	8'h48: temp = 32'ha5bf6d8e;
	8'h49: temp = 32'h1143c44f;
	8'h4a: temp = 32'h43958302;
	8'h4b: temp = 32'hd0214eeb;
	8'h4c: temp = 32'h022083b8;
	8'h4d: temp = 32'h3fb6180c;
	8'h4e: temp = 32'h18f8931e;
	8'h4f: temp = 32'h281658e6;
	8'h50: temp = 32'h26486e3e;
	8'h51: temp = 32'h8bd78a70;
	8'h52: temp = 32'h7477e4c1;
	8'h53: temp = 32'hb506e07c;
	8'h54: temp = 32'hf32d0a25;
	8'h55: temp = 32'h79098b02;
	8'h56: temp = 32'he4eabb81;
	8'h57: temp = 32'h28123b23;
	8'h58: temp = 32'h69dead38;
	8'h59: temp = 32'h1574ca16;
	8'h5a: temp = 32'hdf871b62;
	8'h5b: temp = 32'h211c40b7;
	8'h5c: temp = 32'ha51a9ef9;
	8'h5d: temp = 32'h0014377b;
	8'h5e: temp = 32'h041e8ac8;
	8'h5f: temp = 32'h09114003;
	8'h60: temp = 32'hbd59e4d2;
	8'h61: temp = 32'he3d156d5;
	8'h62: temp = 32'h4fe876d5;
	8'h63: temp = 32'h2f91a340;
	8'h64: temp = 32'h557be8de;
	8'h65: temp = 32'h00eae4a7;
	8'h66: temp = 32'h0ce5c2ec;
	8'h67: temp = 32'h4db4bba6;
	8'h68: temp = 32'he756bdff;
	8'h69: temp = 32'hdd3369ac;
	8'h6a: temp = 32'hec17b035;
	8'h6b: temp = 32'h06572327;
	8'h6c: temp = 32'h99afc8b0;
	8'h6d: temp = 32'h56c8c391;
	8'h6e: temp = 32'h6b65811c;
	8'h6f: temp = 32'h5e146119;
	8'h70: temp = 32'h6e85cb75;
	8'h71: temp = 32'hbe07c002;
	8'h72: temp = 32'hc2325577;
	8'h73: temp = 32'h893ff4ec;
	8'h74: temp = 32'h5bbfc92d;
	8'h75: temp = 32'hd0ec3b25;
	8'h76: temp = 32'hb7801ab7;
	8'h77: temp = 32'h8d6d3b24;
	8'h78: temp = 32'h20c763ef;
	8'h79: temp = 32'hc366a5fc;
	8'h7a: temp = 32'h9c382880;
	8'h7b: temp = 32'h0ace3205;
	8'h7c: temp = 32'haac9548a;
	8'h7d: temp = 32'heca1d7c7;
	8'h7e: temp = 32'h041afa32;
	8'h7f: temp = 32'h1d16625a;
	8'h80: temp = 32'h6701902c;
	8'h81: temp = 32'h9b757a54;
	8'h82: temp = 32'h31d477f7;
	8'h83: temp = 32'h9126b031;
	8'h84: temp = 32'h36cc6fdb;
	8'h85: temp = 32'hc70b8b46;
	8'h86: temp = 32'hd9e66a48;
	8'h87: temp = 32'h56e55a79;
	8'h88: temp = 32'h026a4ceb;
	8'h89: temp = 32'h52437eff;
	8'h8a: temp = 32'h2f8f76b4;
	8'h8b: temp = 32'h0df980a5;
	8'h8c: temp = 32'h8674cde3;
	8'h8d: temp = 32'hedda04eb;
	8'h8e: temp = 32'h17a9be04;
	8'h8f: temp = 32'h2c18f4df;
	8'h90: temp = 32'hb7747f9d;
	8'h91: temp = 32'hab2af7b4;
	8'h92: temp = 32'hefc34d20;
	8'h93: temp = 32'h2e096b7c;
	8'h94: temp = 32'h1741a254;
	8'h95: temp = 32'he5b6a035;
	8'h96: temp = 32'h213d42f6;
	8'h97: temp = 32'h2c1c7c26;
	8'h98: temp = 32'h61c2f50f;
	8'h99: temp = 32'h6552daf9;
	8'h9a: temp = 32'hd2c231f8;
	8'h9b: temp = 32'h25130f69;
	8'h9c: temp = 32'hd8167fa2;
	8'h9d: temp = 32'h0418f2c8;
	8'h9e: temp = 32'h001a96a6;
	8'h9f: temp = 32'h0d1526ab;
	8'ha0: temp = 32'h63315c21;
	8'ha1: temp = 32'h5e0a72ec;
	8'ha2: temp = 32'h49bafefd;
	8'ha3: temp = 32'h187908d9;
	8'ha4: temp = 32'h8d0dbd86;
	8'ha5: temp = 32'h311170a7;
	8'ha6: temp = 32'h3e9b640c;
	8'ha7: temp = 32'hcc3e10d7;
	8'ha8: temp = 32'hd5cad3b6;
	8'ha9: temp = 32'h0caec388;
	8'haa: temp = 32'hf73001e1;
	8'hab: temp = 32'h6c728aff;
	8'hac: temp = 32'h71eae2a1;
	8'had: temp = 32'h1f9af36e;
	8'hae: temp = 32'hcfcbd12f;
	8'haf: temp = 32'hc1de8417;
	8'hb0: temp = 32'hac07be6b;
	8'hb1: temp = 32'hcb44a1d8;
	8'hb2: temp = 32'h8b9b0f56;
	8'hb3: temp = 32'h013988c3;
	8'hb4: temp = 32'hb1c52fca;
	8'hb5: temp = 32'hb4be31cd;
	8'hb6: temp = 32'hd8782806;
	8'hb7: temp = 32'h12a3a4e2;
	8'hb8: temp = 32'h6f7de532;
	8'hb9: temp = 32'h58fd7eb6;
	8'hba: temp = 32'hd01ee900;
	8'hbb: temp = 32'h24adffc2;
	8'hbc: temp = 32'hf4990fc5;
	8'hbd: temp = 32'h9711aac5;
	8'hbe: temp = 32'h001d7b95;
	8'hbf: temp = 32'h82e5e7d2;
	8'hc0: temp = 32'h109873f6;
	8'hc1: temp = 32'h00613096;
	8'hc2: temp = 32'hc32d9521;
	8'hc3: temp = 32'hada121ff;
	8'hc4: temp = 32'h29908415;
	8'hc5: temp = 32'h7fbb977f;
	8'hc6: temp = 32'haf9eb3db;
	8'hc7: temp = 32'h29c9ed2a;
	8'hc8: temp = 32'h5ce2a465;
	8'hc9: temp = 32'ha730f32c;
	8'hca: temp = 32'hd0aa3fe8;
	8'hcb: temp = 32'h8a5cc091;
	8'hcc: temp = 32'hd49e2ce7;
	8'hcd: temp = 32'h0ce454a9;
	8'hce: temp = 32'hd60acd86;
	8'hcf: temp = 32'h015f1919;
	8'hd0: temp = 32'h77079103;
	8'hd1: temp = 32'hdea03af6;
	8'hd2: temp = 32'h78a8565e;
	8'hd3: temp = 32'hdee356df;
	8'hd4: temp = 32'h21f05cbe;
	8'hd5: temp = 32'h8b75e387;
	8'hd6: temp = 32'hb3c50651;
	8'hd7: temp = 32'hb8a5c3ef;
	8'hd8: temp = 32'hd8eeb6d2;
	8'hd9: temp = 32'he523be77;
	8'hda: temp = 32'hc2154529;
	8'hdb: temp = 32'h2f69efdf;
	8'hdc: temp = 32'hafe67afb;
	8'hdd: temp = 32'hf470c4b2;
	8'hde: temp = 32'hf3e0eb5b;
	8'hdf: temp = 32'hd6cc9876;
	8'he0: temp = 32'h39e4460c;
	8'he1: temp = 32'h1fda8538;
	8'he2: temp = 32'h1987832f;
	8'he3: temp = 32'hca007367;
	8'he4: temp = 32'ha99144f8;
	8'he5: temp = 32'h296b299e;
	8'he6: temp = 32'h492fc295;
	8'he7: temp = 32'h9266beab;
	8'he8: temp = 32'hb5676e69;
	8'he9: temp = 32'h9bd3ddda;
	8'hea: temp = 32'hdf7e052f;
	8'heb: temp = 32'hdb25701c;
	8'hec: temp = 32'h1b5e51ee;
	8'hed: temp = 32'hf65324e6;
	8'hee: temp = 32'h6afce36c;
	8'hef: temp = 32'h0316cc04;
	8'hf0: temp = 32'h8644213e;
	8'hf1: temp = 32'hb7dc59d0;
	8'hf2: temp = 32'h7965291f;
	8'hf3: temp = 32'hccd6fd43;
	8'hf4: temp = 32'h41823979;
	8'hf5: temp = 32'h932bcdf6;
	8'hf6: temp = 32'hb657c34d;
	8'hf7: temp = 32'h4edfd282;
	8'hf8: temp = 32'h7ae5290c;
	8'hf9: temp = 32'h3cb9536b;
	8'hfa: temp = 32'h851e20fe;
	8'hfb: temp = 32'h9833557e;
	8'hfc: temp = 32'h13ecf0b0;
	8'hfd: temp = 32'hd3ffb372;
	8'hfe: temp = 32'h3f85c5c1;
	8'hff: temp = 32'h0aef7ed2;

      endcase // case(in)
   endfunction // temp
endmodule // CAST128_sbox4



module CAST128_sbox5(in, out);
   input [7:0] in;
   output [31:0] out;

   assign 	 out = temp(in);
   
   function [31:0] temp;
      input [7:0] in;

      case(in)
	8'h00: temp = 32'h7ec90c04;
	8'h01: temp = 32'h2c6e74b9;
	8'h02: temp = 32'h9b0e66df;
	8'h03: temp = 32'ha6337911;
	8'h04: temp = 32'hb86a7fff;
	8'h05: temp = 32'h1dd358f5;
	8'h06: temp = 32'h44dd9d44;
	8'h07: temp = 32'h1731167f;
	8'h08: temp = 32'h08fbf1fa;
	8'h09: temp = 32'he7f511cc;
	8'h0a: temp = 32'hd2051b00;
	8'h0b: temp = 32'h735aba00;
	8'h0c: temp = 32'h2ab722d8;
	8'h0d: temp = 32'h386381cb;
	8'h0e: temp = 32'hacf6243a;
	8'h0f: temp = 32'h69befd7a;
	8'h10: temp = 32'he6a2e77f;
	8'h11: temp = 32'hf0c720cd;
	8'h12: temp = 32'hc4494816;
	8'h13: temp = 32'hccf5c180;
	8'h14: temp = 32'h38851640;
	8'h15: temp = 32'h15b0a848;
	8'h16: temp = 32'he68b18cb;
	8'h17: temp = 32'h4caadeff;
	8'h18: temp = 32'h5f480a01;
	8'h19: temp = 32'h0412b2aa;
	8'h1a: temp = 32'h259814fc;
	8'h1b: temp = 32'h41d0efe2;
	8'h1c: temp = 32'h4e40b48d;
	8'h1d: temp = 32'h248eb6fb;
	8'h1e: temp = 32'h8dba1cfe;
	8'h1f: temp = 32'h41a99b02;
	8'h20: temp = 32'h1a550a04;
	8'h21: temp = 32'hba8f65cb;
	8'h22: temp = 32'h7251f4e7;
	8'h23: temp = 32'h95a51725;
	8'h24: temp = 32'hc106ecd7;
	8'h25: temp = 32'h97a5980a;
	8'h26: temp = 32'hc539b9aa;
	8'h27: temp = 32'h4d79fe6a;
	8'h28: temp = 32'hf2f3f763;
	8'h29: temp = 32'h68af8040;
	8'h2a: temp = 32'hed0c9e56;
	8'h2b: temp = 32'h11b4958b;
	8'h2c: temp = 32'he1eb5a88;
	8'h2d: temp = 32'h8709e6b0;
	8'h2e: temp = 32'hd7e07156;
	8'h2f: temp = 32'h4e29fea7;
	8'h30: temp = 32'h6366e52d;
	8'h31: temp = 32'h02d1c000;
	8'h32: temp = 32'hc4ac8e05;
	8'h33: temp = 32'h9377f571;
	8'h34: temp = 32'h0c05372a;
	8'h35: temp = 32'h578535f2;
	8'h36: temp = 32'h2261be02;
	8'h37: temp = 32'hd642a0c9;
	8'h38: temp = 32'hdf13a280;
	8'h39: temp = 32'h74b55bd2;
	8'h3a: temp = 32'h682199c0;
	8'h3b: temp = 32'hd421e5ec;
	8'h3c: temp = 32'h53fb3ce8;
	8'h3d: temp = 32'hc8adedb3;
	8'h3e: temp = 32'h28a87fc9;
	8'h3f: temp = 32'h3d959981;
	8'h40: temp = 32'h5c1ff900;
	8'h41: temp = 32'hfe38d399;
	8'h42: temp = 32'h0c4eff0b;
	8'h43: temp = 32'h062407ea;
	8'h44: temp = 32'haa2f4fb1;
	8'h45: temp = 32'h4fb96976;
	8'h46: temp = 32'h90c79505;
	8'h47: temp = 32'hb0a8a774;
	8'h48: temp = 32'hef55a1ff;
	8'h49: temp = 32'he59ca2c2;
	8'h4a: temp = 32'ha6b62d27;
	8'h4b: temp = 32'he66a4263;
	8'h4c: temp = 32'hdf65001f;
	8'h4d: temp = 32'h0ec50966;
	8'h4e: temp = 32'hdfdd55bc;
	8'h4f: temp = 32'h29de0655;
	8'h50: temp = 32'h911e739a;
	8'h51: temp = 32'h17af8975;
	8'h52: temp = 32'h32c7911c;
	8'h53: temp = 32'h89f89468;
	8'h54: temp = 32'h0d01e980;
	8'h55: temp = 32'h524755f4;
	8'h56: temp = 32'h03b63cc9;
	8'h57: temp = 32'h0cc844b2;
	8'h58: temp = 32'hbcf3f0aa;
	8'h59: temp = 32'h87ac36e9;
	8'h5a: temp = 32'he53a7426;
	8'h5b: temp = 32'h01b3d82b;
	8'h5c: temp = 32'h1a9e7449;
	8'h5d: temp = 32'h64ee2d7e;
	8'h5e: temp = 32'hcddbb1da;
	8'h5f: temp = 32'h01c94910;
	8'h60: temp = 32'hb868bf80;
	8'h61: temp = 32'h0d26f3fd;
	8'h62: temp = 32'h9342ede7;
	8'h63: temp = 32'h04a5c284;
	8'h64: temp = 32'h636737b6;
	8'h65: temp = 32'h50f5b616;
	8'h66: temp = 32'hf24766e3;
	8'h67: temp = 32'h8eca36c1;
	8'h68: temp = 32'h136e05db;
	8'h69: temp = 32'hfef18391;
	8'h6a: temp = 32'hfb887a37;
	8'h6b: temp = 32'hd6e7f7d4;
	8'h6c: temp = 32'hc7fb7dc9;
	8'h6d: temp = 32'h3063fcdf;
	8'h6e: temp = 32'hb6f589de;
	8'h6f: temp = 32'hec2941da;
	8'h70: temp = 32'h26e46695;
	8'h71: temp = 32'hb7566419;
	8'h72: temp = 32'hf654efc5;
	8'h73: temp = 32'hd08d58b7;
	8'h74: temp = 32'h48925401;
	8'h75: temp = 32'hc1bacb7f;
	8'h76: temp = 32'he5ff550f;
	8'h77: temp = 32'hb6083049;
	8'h78: temp = 32'h5bb5d0e8;
	8'h79: temp = 32'h87d72e5a;
	8'h7a: temp = 32'hab6a6ee1;
	8'h7b: temp = 32'h223a66ce;
	8'h7c: temp = 32'hc62bf3cd;
	8'h7d: temp = 32'h9e0885f9;
	8'h7e: temp = 32'h68cb3e47;
	8'h7f: temp = 32'h086c010f;
	8'h80: temp = 32'ha21de820;
	8'h81: temp = 32'hd18b69de;
	8'h82: temp = 32'hf3f65777;
	8'h83: temp = 32'hfa02c3f6;
	8'h84: temp = 32'h407edac3;
	8'h85: temp = 32'hcbb3d550;
	8'h86: temp = 32'h1793084d;
	8'h87: temp = 32'hb0d70eba;
	8'h88: temp = 32'h0ab378d5;
	8'h89: temp = 32'hd951fb0c;
	8'h8a: temp = 32'hded7da56;
	8'h8b: temp = 32'h4124bbe4;
	8'h8c: temp = 32'h94ca0b56;
	8'h8d: temp = 32'h0f5755d1;
	8'h8e: temp = 32'he0e1e56e;
	8'h8f: temp = 32'h6184b5be;
	8'h90: temp = 32'h580a249f;
	8'h91: temp = 32'h94f74bc0;
	8'h92: temp = 32'he327888e;
	8'h93: temp = 32'h9f7b5561;
	8'h94: temp = 32'hc3dc0280;
	8'h95: temp = 32'h05687715;
	8'h96: temp = 32'h646c6bd7;
	8'h97: temp = 32'h44904db3;
	8'h98: temp = 32'h66b4f0a3;
	8'h99: temp = 32'hc0f1648a;
	8'h9a: temp = 32'h697ed5af;
	8'h9b: temp = 32'h49e92ff6;
	8'h9c: temp = 32'h309e374f;
	8'h9d: temp = 32'h2cb6356a;
	8'h9e: temp = 32'h85808573;
	8'h9f: temp = 32'h4991f840;
	8'ha0: temp = 32'h76f0ae02;
	8'ha1: temp = 32'h083be84d;
	8'ha2: temp = 32'h28421c9a;
	8'ha3: temp = 32'h44489406;
	8'ha4: temp = 32'h736e4cb8;
	8'ha5: temp = 32'hc1092910;
	8'ha6: temp = 32'h8bc95fc6;
	8'ha7: temp = 32'h7d869cf4;
	8'ha8: temp = 32'h134f616f;
	8'ha9: temp = 32'h2e77118d;
	8'haa: temp = 32'hb31b2be1;
	8'hab: temp = 32'haa90b472;
	8'hac: temp = 32'h3ca5d717;
	8'had: temp = 32'h7d161bba;
	8'hae: temp = 32'h9cad9010;
	8'haf: temp = 32'haf462ba2;
	8'hb0: temp = 32'h9fe459d2;
	8'hb1: temp = 32'h45d34559;
	8'hb2: temp = 32'hd9f2da13;
	8'hb3: temp = 32'hdbc65487;
	8'hb4: temp = 32'hf3e4f94e;
	8'hb5: temp = 32'h176d486f;
	8'hb6: temp = 32'h097c13ea;
	8'hb7: temp = 32'h631da5c7;
	8'hb8: temp = 32'h445f7382;
	8'hb9: temp = 32'h175683f4;
	8'hba: temp = 32'hcdc66a97;
	8'hbb: temp = 32'h70be0288;
	8'hbc: temp = 32'hb3cdcf72;
	8'hbd: temp = 32'h6e5dd2f3;
	8'hbe: temp = 32'h20936079;
	8'hbf: temp = 32'h459b80a5;
	8'hc0: temp = 32'hbe60e2db;
	8'hc1: temp = 32'ha9c23101;
	8'hc2: temp = 32'heba5315c;
	8'hc3: temp = 32'h224e42f2;
	8'hc4: temp = 32'h1c5c1572;
	8'hc5: temp = 32'hf6721b2c;
	8'hc6: temp = 32'h1ad2fff3;
	8'hc7: temp = 32'h8c25404e;
	8'hc8: temp = 32'h324ed72f;
	8'hc9: temp = 32'h4067b7fd;
	8'hca: temp = 32'h0523138e;
	8'hcb: temp = 32'h5ca3bc78;
	8'hcc: temp = 32'hdc0fd66e;
	8'hcd: temp = 32'h75922283;
	8'hce: temp = 32'h784d6b17;
	8'hcf: temp = 32'h58ebb16e;
	8'hd0: temp = 32'h44094f85;
	8'hd1: temp = 32'h3f481d87;
	8'hd2: temp = 32'hfcfeae7b;
	8'hd3: temp = 32'h77b5ff76;
	8'hd4: temp = 32'h8c2302bf;
	8'hd5: temp = 32'haaf47556;
	8'hd6: temp = 32'h5f46b02a;
	8'hd7: temp = 32'h2b092801;
	8'hd8: temp = 32'h3d38f5f7;
	8'hd9: temp = 32'h0ca81f36;
	8'hda: temp = 32'h52af4a8a;
	8'hdb: temp = 32'h66d5e7c0;
	8'hdc: temp = 32'hdf3b0874;
	8'hdd: temp = 32'h95055110;
	8'hde: temp = 32'h1b5ad7a8;
	8'hdf: temp = 32'hf61ed5ad;
	8'he0: temp = 32'h6cf6e479;
	8'he1: temp = 32'h20758184;
	8'he2: temp = 32'hd0cefa65;
	8'he3: temp = 32'h88f7be58;
	8'he4: temp = 32'h4a046826;
	8'he5: temp = 32'h0ff6f8f3;
	8'he6: temp = 32'ha09c7f70;
	8'he7: temp = 32'h5346aba0;
	8'he8: temp = 32'h5ce96c28;
	8'he9: temp = 32'he176eda3;
	8'hea: temp = 32'h6bac307f;
	8'heb: temp = 32'h376829d2;
	8'hec: temp = 32'h85360fa9;
	8'hed: temp = 32'h17e3fe2a;
	8'hee: temp = 32'h24b79767;
	8'hef: temp = 32'hf5a96b20;
	8'hf0: temp = 32'hd6cd2595;
	8'hf1: temp = 32'h68ff1ebf;
	8'hf2: temp = 32'h7555442c;
	8'hf3: temp = 32'hf19f06be;
	8'hf4: temp = 32'hf9e0659a;
	8'hf5: temp = 32'heeb9491d;
	8'hf6: temp = 32'h34010718;
	8'hf7: temp = 32'hbb30cab8;
	8'hf8: temp = 32'he822fe15;
	8'hf9: temp = 32'h88570983;
	8'hfa: temp = 32'h750e6249;
	8'hfb: temp = 32'hda627e55;
	8'hfc: temp = 32'h5e76ffa8;
	8'hfd: temp = 32'hb1534546;
	8'hfe: temp = 32'h6d47de08;
	8'hff: temp = 32'hefe9e7d4;
      endcase // case(in)
   endfunction // temp
endmodule //


module CAST128_sbox6(in, out);
   input  [7:0]  in;
   output [31:0] out; 
   
   assign 	 out = temp(in);
   
   function [31:0] temp;
      input [7:0] in;

      case(in)
	8'h00: temp = 32'hf6fa8f9d;
	8'h01: temp = 32'h2cac6ce1;
	8'h02: temp = 32'h4ca34867;
	8'h03: temp = 32'he2337f7c;
	8'h04: temp = 32'h95db08e7;
	8'h05: temp = 32'h016843b4;
	8'h06: temp = 32'heced5cbc;
	8'h07: temp = 32'h325553ac;
	8'h08: temp = 32'hbf9f0960;
	8'h09: temp = 32'hdfa1e2ed;
	8'h0a: temp = 32'h83f0579d;
	8'h0b: temp = 32'h63ed86b9;
	8'h0c: temp = 32'h1ab6a6b8;
	8'h0d: temp = 32'hde5ebe39;
	8'h0e: temp = 32'hf38ff732;
	8'h0f: temp = 32'h8989b138;
	8'h10: temp = 32'h33f14961;
	8'h11: temp = 32'hc01937bd;
	8'h12: temp = 32'hf506c6da;
	8'h13: temp = 32'he4625e7e;
	8'h14: temp = 32'ha308ea99;
	8'h15: temp = 32'h4e23e33c;
	8'h16: temp = 32'h79cbd7cc;
	8'h17: temp = 32'h48a14367;
	8'h18: temp = 32'ha3149619;
	8'h19: temp = 32'hfec94bd5;
	8'h1a: temp = 32'ha114174a;
	8'h1b: temp = 32'heaa01866;
	8'h1c: temp = 32'ha084db2d;
	8'h1d: temp = 32'h09a8486f;
	8'h1e: temp = 32'ha888614a;
	8'h1f: temp = 32'h2900af98;
	8'h20: temp = 32'h01665991;
	8'h21: temp = 32'he1992863;
	8'h22: temp = 32'hc8f30c60;
	8'h23: temp = 32'h2e78ef3c;
	8'h24: temp = 32'hd0d51932;
	8'h25: temp = 32'hcf0fec14;
	8'h26: temp = 32'hf7ca07d2;
	8'h27: temp = 32'hd0a82072;
	8'h28: temp = 32'hfd41197e;
	8'h29: temp = 32'h9305a6b0;
	8'h2a: temp = 32'he86be3da;
	8'h2b: temp = 32'h74bed3cd;
	8'h2c: temp = 32'h372da53c;
	8'h2d: temp = 32'h4c7f4448;
	8'h2e: temp = 32'hdab5d440;
	8'h2f: temp = 32'h6dba0ec3;
	8'h30: temp = 32'h083919a7;
	8'h31: temp = 32'h9fbaeed9;
	8'h32: temp = 32'h49dbcfb0;
	8'h33: temp = 32'h4e670c53;
	8'h34: temp = 32'h5c3d9c01;
	8'h35: temp = 32'h64bdb941;
	8'h36: temp = 32'h2c0e636a;
	8'h37: temp = 32'hba7dd9cd;
	8'h38: temp = 32'hea6f7388;
	8'h39: temp = 32'he70bc762;
	8'h3a: temp = 32'h35f29adb;
	8'h3b: temp = 32'h5c4cdd8d;
	8'h3c: temp = 32'hf0d48d8c;
	8'h3d: temp = 32'hb88153e2;
	8'h3e: temp = 32'h08a19866;
	8'h3f: temp = 32'h1ae2eac8;
	8'h40: temp = 32'h284caf89;
	8'h41: temp = 32'haa928223;
	8'h42: temp = 32'h9334be53;
	8'h43: temp = 32'h3b3a21bf;
	8'h44: temp = 32'h16434be3;
	8'h45: temp = 32'h9aea3906;
	8'h46: temp = 32'hefe8c36e;
	8'h47: temp = 32'hf890cdd9;
	8'h48: temp = 32'h80226dae;
	8'h49: temp = 32'hc340a4a3;
	8'h4a: temp = 32'hdf7e9c09;
	8'h4b: temp = 32'ha694a807;
	8'h4c: temp = 32'h5b7c5ecc;
	8'h4d: temp = 32'h221db3a6;
	8'h4e: temp = 32'h9a69a02f;
	8'h4f: temp = 32'h68818a54;
	8'h50: temp = 32'hceb2296f;
	8'h51: temp = 32'h53c0843a;
	8'h52: temp = 32'hfe893655;
	8'h53: temp = 32'h25bfe68a;
	8'h54: temp = 32'hb4628abc;
	8'h55: temp = 32'hcf222ebf;
	8'h56: temp = 32'h25ac6f48;
	8'h57: temp = 32'ha9a99387;
	8'h58: temp = 32'h53bddb65;
	8'h59: temp = 32'he76ffbe7;
	8'h5a: temp = 32'he967fd78;
	8'h5b: temp = 32'h0ba93563;
	8'h5c: temp = 32'h8e342bc1;
	8'h5d: temp = 32'he8a11be9;
	8'h5e: temp = 32'h4980740d;
	8'h5f: temp = 32'hc8087dfc;
	8'h60: temp = 32'h8de4bf99;
	8'h61: temp = 32'ha11101a0;
	8'h62: temp = 32'h7fd37975;
	8'h63: temp = 32'hda5a26c0;
	8'h64: temp = 32'he81f994f;
	8'h65: temp = 32'h9528cd89;
	8'h66: temp = 32'hfd339fed;
	8'h67: temp = 32'hb87834bf;
	8'h68: temp = 32'h5f04456d;
	8'h69: temp = 32'h22258698;
	8'h6a: temp = 32'hc9c4c83b;
	8'h6b: temp = 32'h2dc156be;
	8'h6c: temp = 32'h4f628daa;
	8'h6d: temp = 32'h57f55ec5;
	8'h6e: temp = 32'he2220abe;
	8'h6f: temp = 32'hd2916ebf;
	8'h70: temp = 32'h4ec75b95;
	8'h71: temp = 32'h24f2c3c0;
	8'h72: temp = 32'h42d15d99;
	8'h73: temp = 32'hcd0d7fa0;
	8'h74: temp = 32'h7b6e27ff;
	8'h75: temp = 32'ha8dc8af0;
	8'h76: temp = 32'h7345c106;
	8'h77: temp = 32'hf41e232f;
	8'h78: temp = 32'h35162386;
	8'h79: temp = 32'he6ea8926;
	8'h7a: temp = 32'h3333b094;
	8'h7b: temp = 32'h157ec6f2;
	8'h7c: temp = 32'h372b74af;
	8'h7d: temp = 32'h692573e4;
	8'h7e: temp = 32'he9a9d848;
	8'h7f: temp = 32'hf3160289;
	8'h80: temp = 32'h3a62ef1d;
	8'h81: temp = 32'ha787e238;
	8'h82: temp = 32'hf3a5f676;
	8'h83: temp = 32'h74364853;
	8'h84: temp = 32'h20951063;
	8'h85: temp = 32'h4576698d;
	8'h86: temp = 32'hb6fad407;
	8'h87: temp = 32'h592af950;
	8'h88: temp = 32'h36f73523;
	8'h89: temp = 32'h4cfb6e87;
	8'h8a: temp = 32'h7da4cec0;
	8'h8b: temp = 32'h6c152daa;
	8'h8c: temp = 32'hcb0396a8;
	8'h8d: temp = 32'hc50dfe5d;
	8'h8e: temp = 32'hfcd707ab;
	8'h8f: temp = 32'h0921c42f;
	8'h90: temp = 32'h89dff0bb;
	8'h91: temp = 32'h5fe2be78;
	8'h92: temp = 32'h448f4f33;
	8'h93: temp = 32'h754613c9;
	8'h94: temp = 32'h2b05d08d;
	8'h95: temp = 32'h48b9d585;
	8'h96: temp = 32'hdc049441;
	8'h97: temp = 32'hc8098f9b;
	8'h98: temp = 32'h7dede786;
	8'h99: temp = 32'hc39a3373;
	8'h9a: temp = 32'h42410005;
	8'h9b: temp = 32'h6a091751;
	8'h9c: temp = 32'h0ef3c8a6;
	8'h9d: temp = 32'h890072d6;
	8'h9e: temp = 32'h28207682;
	8'h9f: temp = 32'ha9a9f7be;
	8'ha0: temp = 32'hbf32679d;
	8'ha1: temp = 32'hd45b5b75;
	8'ha2: temp = 32'hb353fd00;
	8'ha3: temp = 32'hcbb0e358;
	8'ha4: temp = 32'h830f220a;
	8'ha5: temp = 32'h1f8fb214;
	8'ha6: temp = 32'hd372cf08;
	8'ha7: temp = 32'hcc3c4a13;
	8'ha8: temp = 32'h8cf63166;
	8'ha9: temp = 32'h061c87be;
	8'haa: temp = 32'h88c98f88;
	8'hab: temp = 32'h6062e397;
	8'hac: temp = 32'h47cf8e7a;
	8'had: temp = 32'hb6c85283;
	8'hae: temp = 32'h3cc2acfb;
	8'haf: temp = 32'h3fc06976;
	8'hb0: temp = 32'h4e8f0252;
	8'hb1: temp = 32'h64d8314d;
	8'hb2: temp = 32'hda3870e3;
	8'hb3: temp = 32'h1e665459;
	8'hb4: temp = 32'hc10908f0;
	8'hb5: temp = 32'h513021a5;
	8'hb6: temp = 32'h6c5b68b7;
	8'hb7: temp = 32'h822f8aa0;
	8'hb8: temp = 32'h3007cd3e;
	8'hb9: temp = 32'h74719eef;
	8'hba: temp = 32'hdc872681;
	8'hbb: temp = 32'h073340d4;
	8'hbc: temp = 32'h7e432fd9;
	8'hbd: temp = 32'h0c5ec241;
	8'hbe: temp = 32'h8809286c;
	8'hbf: temp = 32'hf592d891;
	8'hc0: temp = 32'h08a930f6;
	8'hc1: temp = 32'h957ef305;
	8'hc2: temp = 32'hb7fbffbd;
	8'hc3: temp = 32'hc266e96f;
	8'hc4: temp = 32'h6fe4ac98;
	8'hc5: temp = 32'hb173ecc0;
	8'hc6: temp = 32'hbc60b42a;
	8'hc7: temp = 32'h953498da;
	8'hc8: temp = 32'hfba1ae12;
	8'hc9: temp = 32'h2d4bd736;
	8'hca: temp = 32'h0f25faab;
	8'hcb: temp = 32'ha4f3fceb;
	8'hcc: temp = 32'he2969123;
	8'hcd: temp = 32'h257f0c3d;
	8'hce: temp = 32'h9348af49;
	8'hcf: temp = 32'h361400bc;
	8'hd0: temp = 32'he8816f4a;
	8'hd1: temp = 32'h3814f200;
	8'hd2: temp = 32'ha3f94043;
	8'hd3: temp = 32'h9c7a54c2;
	8'hd4: temp = 32'hbc704f57;
	8'hd5: temp = 32'hda41e7f9;
	8'hd6: temp = 32'hc25ad33a;
	8'hd7: temp = 32'h54f4a084;
	8'hd8: temp = 32'hb17f5505;
	8'hd9: temp = 32'h59357cbe;
	8'hda: temp = 32'hedbd15c8;
	8'hdb: temp = 32'h7f97c5ab;
	8'hdc: temp = 32'hba5ac7b5;
	8'hdd: temp = 32'hb6f6deaf;
	8'hde: temp = 32'h3a479c3a;
	8'hdf: temp = 32'h5302da25;
	8'he0: temp = 32'h653d7e6a;
	8'he1: temp = 32'h54268d49;
	8'he2: temp = 32'h51a477ea;
	8'he3: temp = 32'h5017d55b;
	8'he4: temp = 32'hd7d25d88;
	8'he5: temp = 32'h44136c76;
	8'he6: temp = 32'h0404a8c8;
	8'he7: temp = 32'hb8e5a121;
	8'he8: temp = 32'hb81a928a;
	8'he9: temp = 32'h60ed5869;
	8'hea: temp = 32'h97c55b96;
	8'heb: temp = 32'heaec991b;
	8'hec: temp = 32'h29935913;
	8'hed: temp = 32'h01fdb7f1;
	8'hee: temp = 32'h088e8dfa;
	8'hef: temp = 32'h9ab6f6f5;
	8'hf0: temp = 32'h3b4cbf9f;
	8'hf1: temp = 32'h4a5de3ab;
	8'hf2: temp = 32'he6051d35;
	8'hf3: temp = 32'ha0e1d855;
	8'hf4: temp = 32'hd36b4cf1;
	8'hf5: temp = 32'hf544edeb;
	8'hf6: temp = 32'hb0e93524;
	8'hf7: temp = 32'hbebb8fbd;
	8'hf8: temp = 32'ha2d762cf;
	8'hf9: temp = 32'h49c92f54;
	8'hfa: temp = 32'h38b5f331;
	8'hfb: temp = 32'h7128a454;
	8'hfc: temp = 32'h48392905;
	8'hfd: temp = 32'ha65b1db8;
	8'hfe: temp = 32'h851c97bd;
	8'hff: temp = 32'hd675cf2f;
      endcase // case(in)
   endfunction // temp
endmodule //

module CAST128_sbox7(in, out);
   input [7:0] in;
   output [31:0] out;

   assign 	 out = temp(in);
   
   function [31:0] temp;
      input [7:0] in;

      case(in)
	8'h00: temp = 32'h85e04019;
	8'h01: temp = 32'h332bf567;
	8'h02: temp = 32'h662dbfff;
	8'h03: temp = 32'hcfc65693;
	8'h04: temp = 32'h2a8d7f6f;
	8'h05: temp = 32'hab9bc912;
	8'h06: temp = 32'hde6008a1;
	8'h07: temp = 32'h2028da1f;
	8'h08: temp = 32'h0227bce7;
	8'h09: temp = 32'h4d642916;
	8'h0a: temp = 32'h18fac300;
	8'h0b: temp = 32'h50f18b82;
	8'h0c: temp = 32'h2cb2cb11;
	8'h0d: temp = 32'hb232e75c;
	8'h0e: temp = 32'h4b3695f2;
	8'h0f: temp = 32'hb28707de;
	8'h10: temp = 32'ha05fbcf6;
	8'h11: temp = 32'hcd4181e9;
	8'h12: temp = 32'he150210c;
	8'h13: temp = 32'he24ef1bd;
	8'h14: temp = 32'hb168c381;
	8'h15: temp = 32'hfde4e789;
	8'h16: temp = 32'h5c79b0d8;
	8'h17: temp = 32'h1e8bfd43;
	8'h18: temp = 32'h4d495001;
	8'h19: temp = 32'h38be4341;
	8'h1a: temp = 32'h913cee1d;
	8'h1b: temp = 32'h92a79c3f;
	8'h1c: temp = 32'h089766be;
	8'h1d: temp = 32'hbaeeadf4;
	8'h1e: temp = 32'h1286becf;
	8'h1f: temp = 32'hb6eacb19;
	8'h20: temp = 32'h2660c200;
	8'h21: temp = 32'h7565bde4;
	8'h22: temp = 32'h64241f7a;
	8'h23: temp = 32'h8248dca9;
	8'h24: temp = 32'hc3b3ad66;
	8'h25: temp = 32'h28136086;
	8'h26: temp = 32'h0bd8dfa8;
	8'h27: temp = 32'h356d1cf2;
	8'h28: temp = 32'h107789be;
	8'h29: temp = 32'hb3b2e9ce;
	8'h2a: temp = 32'h0502aa8f;
	8'h2b: temp = 32'h0bc0351e;
	8'h2c: temp = 32'h166bf52a;
	8'h2d: temp = 32'heb12ff82;
	8'h2e: temp = 32'he3486911;
	8'h2f: temp = 32'hd34d7516;
	8'h30: temp = 32'h4e7b3aff;
	8'h31: temp = 32'h5f43671b;
	8'h32: temp = 32'h9cf6e037;
	8'h33: temp = 32'h4981ac83;
	8'h34: temp = 32'h334266ce;
	8'h35: temp = 32'h8c9341b7;
	8'h36: temp = 32'hd0d854c0;
	8'h37: temp = 32'hcb3a6c88;
	8'h38: temp = 32'h47bc2829;
	8'h39: temp = 32'h4725ba37;
	8'h3a: temp = 32'ha66ad22b;
	8'h3b: temp = 32'h7ad61f1e;
	8'h3c: temp = 32'h0c5cbafa;
	8'h3d: temp = 32'h4437f107;
	8'h3e: temp = 32'hb6e79962;
	8'h3f: temp = 32'h42d2d816;
	8'h40: temp = 32'h0a961288;
	8'h41: temp = 32'he1a5c06e;
	8'h42: temp = 32'h13749e67;
	8'h43: temp = 32'h72fc081a;
	8'h44: temp = 32'hb1d139f7;
	8'h45: temp = 32'hf9583745;
	8'h46: temp = 32'hcf19df58;
	8'h47: temp = 32'hbec3f756;
	8'h48: temp = 32'hc06eba30;
	8'h49: temp = 32'h07211b24;
	8'h4a: temp = 32'h45c28829;
	8'h4b: temp = 32'hc95e317f;
	8'h4c: temp = 32'hbc8ec511;
	8'h4d: temp = 32'h38bc46e9;
	8'h4e: temp = 32'hc6e6fa14;
	8'h4f: temp = 32'hbae8584a;
	8'h50: temp = 32'had4ebc46;
	8'h51: temp = 32'h468f508b;
	8'h52: temp = 32'h7829435f;
	8'h53: temp = 32'hf124183b;
	8'h54: temp = 32'h821dba9f;
	8'h55: temp = 32'haff60ff4;
	8'h56: temp = 32'hea2c4e6d;
	8'h57: temp = 32'h16e39264;
	8'h58: temp = 32'h92544a8b;
	8'h59: temp = 32'h009b4fc3;
	8'h5a: temp = 32'haba68ced;
	8'h5b: temp = 32'h9ac96f78;
	8'h5c: temp = 32'h06a5b79a;
	8'h5d: temp = 32'hb2856e6e;
	8'h5e: temp = 32'h1aec3ca9;
	8'h5f: temp = 32'hbe838688;
	8'h60: temp = 32'h0e0804e9;
	8'h61: temp = 32'h55f1be56;
	8'h62: temp = 32'he7e5363b;
	8'h63: temp = 32'hb3a1f25d;
	8'h64: temp = 32'hf7debb85;
	8'h65: temp = 32'h61fe033c;
	8'h66: temp = 32'h16746233;
	8'h67: temp = 32'h3c034c28;
	8'h68: temp = 32'hda6d0c74;
	8'h69: temp = 32'h79aac56c;
	8'h6a: temp = 32'h3ce4e1ad;
	8'h6b: temp = 32'h51f0c802;
	8'h6c: temp = 32'h98f8f35a;
	8'h6d: temp = 32'h1626a49f;
	8'h6e: temp = 32'heed82b29;
	8'h6f: temp = 32'h1d382fe3;
	8'h70: temp = 32'h0c4fb99a;
	8'h71: temp = 32'hbb325778;
	8'h72: temp = 32'h3ec6d97b;
	8'h73: temp = 32'h6e77a6a9;
	8'h74: temp = 32'hcb658b5c;
	8'h75: temp = 32'hd45230c7;
	8'h76: temp = 32'h2bd1408b;
	8'h77: temp = 32'h60c03eb7;
	8'h78: temp = 32'hb9068d78;
	8'h79: temp = 32'ha33754f4;
	8'h7a: temp = 32'hf430c87d;
	8'h7b: temp = 32'hc8a71302;
	8'h7c: temp = 32'hb96d8c32;
	8'h7d: temp = 32'hebd4e7be;
	8'h7e: temp = 32'hbe8b9d2d;
	8'h7f: temp = 32'h7979fb06;
	8'h80: temp = 32'he7225308;
	8'h81: temp = 32'h8b75cf77;
	8'h82: temp = 32'h11ef8da4;
	8'h83: temp = 32'he083c858;
	8'h84: temp = 32'h8d6b786f;
	8'h85: temp = 32'h5a6317a6;
	8'h86: temp = 32'hfa5cf7a0;
	8'h87: temp = 32'h5dda0033;
	8'h88: temp = 32'hf28ebfb0;
	8'h89: temp = 32'hf5b9c310;
	8'h8a: temp = 32'ha0eac280;
	8'h8b: temp = 32'h08b9767a;
	8'h8c: temp = 32'ha3d9d2b0;
	8'h8d: temp = 32'h79d34217;
	8'h8e: temp = 32'h021a718d;
	8'h8f: temp = 32'h9ac6336a;
	8'h90: temp = 32'h2711fd60;
	8'h91: temp = 32'h438050e3;
	8'h92: temp = 32'h069908a8;
	8'h93: temp = 32'h3d7fedc4;
	8'h94: temp = 32'h826d2bef;
	8'h95: temp = 32'h4eeb8476;
	8'h96: temp = 32'h488dcf25;
	8'h97: temp = 32'h36c9d566;
	8'h98: temp = 32'h28e74e41;
	8'h99: temp = 32'hc2610aca;
	8'h9a: temp = 32'h3d49a9cf;
	8'h9b: temp = 32'hbae3b9df;
	8'h9c: temp = 32'hb65f8de6;
	8'h9d: temp = 32'h92aeaf64;
	8'h9e: temp = 32'h3ac7d5e6;
	8'h9f: temp = 32'h9ea80509;
	8'ha0: temp = 32'hf22b017d;
	8'ha1: temp = 32'ha4173f70;
	8'ha2: temp = 32'hdd1e16c3;
	8'ha3: temp = 32'h15e0d7f9;
	8'ha4: temp = 32'h50b1b887;
	8'ha5: temp = 32'h2b9f4fd5;
	8'ha6: temp = 32'h625aba82;
	8'ha7: temp = 32'h6a017962;
	8'ha8: temp = 32'h2ec01b9c;
	8'ha9: temp = 32'h15488aa9;
	8'haa: temp = 32'hd716e740;
	8'hab: temp = 32'h40055a2c;
	8'hac: temp = 32'h93d29a22;
	8'had: temp = 32'he32dbf9a;
	8'hae: temp = 32'h058745b9;
	8'haf: temp = 32'h3453dc1e;
	8'hb0: temp = 32'hd699296e;
	8'hb1: temp = 32'h496cff6f;
	8'hb2: temp = 32'h1c9f4986;
	8'hb3: temp = 32'hdfe2ed07;
	8'hb4: temp = 32'hb87242d1;
	8'hb5: temp = 32'h19de7eae;
	8'hb6: temp = 32'h053e561a;
	8'hb7: temp = 32'h15ad6f8c;
	8'hb8: temp = 32'h66626c1c;
	8'hb9: temp = 32'h7154c24c;
	8'hba: temp = 32'hea082b2a;
	8'hbb: temp = 32'h93eb2939;
	8'hbc: temp = 32'h17dcb0f0;
	8'hbd: temp = 32'h58d4f2ae;
	8'hbe: temp = 32'h9ea294fb;
	8'hbf: temp = 32'h52cf564c;
	8'hc0: temp = 32'h9883fe66;
	8'hc1: temp = 32'h2ec40581;
	8'hc2: temp = 32'h763953c3;
	8'hc3: temp = 32'h01d6692e;
	8'hc4: temp = 32'hd3a0c108;
	8'hc5: temp = 32'ha1e7160e;
	8'hc6: temp = 32'he4f2dfa6;
	8'hc7: temp = 32'h693ed285;
	8'hc8: temp = 32'h74904698;
	8'hc9: temp = 32'h4c2b0edd;
	8'hca: temp = 32'h4f757656;
	8'hcb: temp = 32'h5d393378;
	8'hcc: temp = 32'ha132234f;
	8'hcd: temp = 32'h3d321c5d;
	8'hce: temp = 32'hc3f5e194;
	8'hcf: temp = 32'h4b269301;
	8'hd0: temp = 32'hc79f022f;
	8'hd1: temp = 32'h3c997e7e;
	8'hd2: temp = 32'h5e4f9504;
	8'hd3: temp = 32'h3ffafbbd;
	8'hd4: temp = 32'h76f7ad0e;
	8'hd5: temp = 32'h296693f4;
	8'hd6: temp = 32'h3d1fce6f;
	8'hd7: temp = 32'hc61e45be;
	8'hd8: temp = 32'hd3b5ab34;
	8'hd9: temp = 32'hf72bf9b7;
	8'hda: temp = 32'h1b0434c0;
	8'hdb: temp = 32'h4e72b567;
	8'hdc: temp = 32'h5592a33d;
	8'hdd: temp = 32'hb5229301;
	8'hde: temp = 32'hcfd2a87f;
	8'hdf: temp = 32'h60aeb767;
	8'he0: temp = 32'h1814386b;
	8'he1: temp = 32'h30bcc33d;
	8'he2: temp = 32'h38a0c07d;
	8'he3: temp = 32'hfd1606f2;
	8'he4: temp = 32'hc363519b;
	8'he5: temp = 32'h589dd390;
	8'he6: temp = 32'h5479f8e6;
	8'he7: temp = 32'h1cb8d647;
	8'he8: temp = 32'h97fd61a9;
	8'he9: temp = 32'hea7759f4;
	8'hea: temp = 32'h2d57539d;
	8'heb: temp = 32'h569a58cf;
	8'hec: temp = 32'he84e63ad;
	8'hed: temp = 32'h462e1b78;
	8'hee: temp = 32'h6580f87e;
	8'hef: temp = 32'hf3817914;
	8'hf0: temp = 32'h91da55f4;
	8'hf1: temp = 32'h40a230f3;
	8'hf2: temp = 32'hd1988f35;
	8'hf3: temp = 32'hb6e318d2;
	8'hf4: temp = 32'h3ffa50bc;
	8'hf5: temp = 32'h3d40f021;
	8'hf6: temp = 32'hc3c0bdae;
	8'hf7: temp = 32'h4958c24c;
	8'hf8: temp = 32'h518f36b2;
	8'hf9: temp = 32'h84b1d370;
	8'hfa: temp = 32'h0fedce83;
	8'hfb: temp = 32'h878ddada;
	8'hfc: temp = 32'hf2a279c7;
	8'hfd: temp = 32'h94e01be8;
	8'hfe: temp = 32'h90716f4b;
	8'hff: temp = 32'h954b8aa3;
      endcase // case(in)
   endfunction // temp
endmodule // CAST128_sbox7


module CAST128_sbox8(in, out);
   input [7:0] in;
   output [31:0] out;

   assign 	 out = temp(in);
   
   function [31:0] temp;
      input [7:0] in;

      case(in)
	8'h00: temp = 32'he216300d;
	8'h01: temp = 32'hbbddfffc;
	8'h02: temp = 32'ha7ebdabd;
	8'h03: temp = 32'h35648095;
	8'h04: temp = 32'h7789f8b7;
	8'h05: temp = 32'he6c1121b;
	8'h06: temp = 32'h0e241600;
	8'h07: temp = 32'h052ce8b5;
	8'h08: temp = 32'h11a9cfb0;
	8'h09: temp = 32'he5952f11;
	8'h0a: temp = 32'hece7990a;
	8'h0b: temp = 32'h9386d174;
	8'h0c: temp = 32'h2a42931c;
	8'h0d: temp = 32'h76e38111;
	8'h0e: temp = 32'hb12def3a;
	8'h0f: temp = 32'h37ddddfc;
	8'h10: temp = 32'hde9adeb1;
	8'h11: temp = 32'h0a0cc32c;
	8'h12: temp = 32'hbe197029;
	8'h13: temp = 32'h84a00940;
	8'h14: temp = 32'hbb243a0f;
	8'h15: temp = 32'hb4d137cf;
	8'h16: temp = 32'hb44e79f0;
	8'h17: temp = 32'h049eedfd;
	8'h18: temp = 32'h0b15a15d;
	8'h19: temp = 32'h480d3168;
	8'h1a: temp = 32'h8bbbde5a;
	8'h1b: temp = 32'h669ded42;
	8'h1c: temp = 32'hc7ece831;
	8'h1d: temp = 32'h3f8f95e7;
	8'h1e: temp = 32'h72df191b;
	8'h1f: temp = 32'h7580330d;
	8'h20: temp = 32'h94074251;
	8'h21: temp = 32'h5c7dcdfa;
	8'h22: temp = 32'habbe6d63;
	8'h23: temp = 32'haa402164;
	8'h24: temp = 32'hb301d40a;
	8'h25: temp = 32'h02e7d1ca;
	8'h26: temp = 32'h53571dae;
	8'h27: temp = 32'h7a3182a2;
	8'h28: temp = 32'h12a8ddec;
	8'h29: temp = 32'hfdaa335d;
	8'h2a: temp = 32'h176f43e8;
	8'h2b: temp = 32'h71fb46d4;
	8'h2c: temp = 32'h38129022;
	8'h2d: temp = 32'hce949ad4;
	8'h2e: temp = 32'hb84769ad;
	8'h2f: temp = 32'h965bd862;
	8'h30: temp = 32'h82f3d055;
	8'h31: temp = 32'h66fb9767;
	8'h32: temp = 32'h15b80b4e;
	8'h33: temp = 32'h1d5b47a0;
	8'h34: temp = 32'h4cfde06f;
	8'h35: temp = 32'hc28ec4b8;
	8'h36: temp = 32'h57e8726e;
	8'h37: temp = 32'h647a78fc;
	8'h38: temp = 32'h99865d44;
	8'h39: temp = 32'h608bd593;
	8'h3a: temp = 32'h6c200e03;
	8'h3b: temp = 32'h39dc5ff6;
	8'h3c: temp = 32'h5d0b00a3;
	8'h3d: temp = 32'hae63aff2;
	8'h3e: temp = 32'h7e8bd632;
	8'h3f: temp = 32'h70108c0c;
	8'h40: temp = 32'hbbd35049;
	8'h41: temp = 32'h2998df04;
	8'h42: temp = 32'h980cf42a;
	8'h43: temp = 32'h9b6df491;
	8'h44: temp = 32'h9e7edd53;
	8'h45: temp = 32'h06918548;
	8'h46: temp = 32'h58cb7e07;
	8'h47: temp = 32'h3b74ef2e;
	8'h48: temp = 32'h522fffb1;
	8'h49: temp = 32'hd24708cc;
	8'h4a: temp = 32'h1c7e27cd;
	8'h4b: temp = 32'ha4eb215b;
	8'h4c: temp = 32'h3cf1d2e2;
	8'h4d: temp = 32'h19b47a38;
	8'h4e: temp = 32'h424f7618;
	8'h4f: temp = 32'h35856039;
	8'h50: temp = 32'h9d17dee7;
	8'h51: temp = 32'h27eb35e6;
	8'h52: temp = 32'hc9aff67b;
	8'h53: temp = 32'h36baf5b8;
	8'h54: temp = 32'h09c467cd;
	8'h55: temp = 32'hc18910b1;
	8'h56: temp = 32'he11dbf7b;
	8'h57: temp = 32'h06cd1af8;
	8'h58: temp = 32'h7170c608;
	8'h59: temp = 32'h2d5e3354;
	8'h5a: temp = 32'hd4de495a;
	8'h5b: temp = 32'h64c6d006;
	8'h5c: temp = 32'hbcc0c62c;
	8'h5d: temp = 32'h3dd00db3;
	8'h5e: temp = 32'h708f8f34;
	8'h5f: temp = 32'h77d51b42;
	8'h60: temp = 32'h264f620f;
	8'h61: temp = 32'h24b8d2bf;
	8'h62: temp = 32'h15c1b79e;
	8'h63: temp = 32'h46a52564;
	8'h64: temp = 32'hf8d7e54e;
	8'h65: temp = 32'h3e378160;
	8'h66: temp = 32'h7895cda5;
	8'h67: temp = 32'h859c15a5;
	8'h68: temp = 32'he6459788;
	8'h69: temp = 32'hc37bc75f;
	8'h6a: temp = 32'hdb07ba0c;
	8'h6b: temp = 32'h0676a3ab;
	8'h6c: temp = 32'h7f229b1e;
	8'h6d: temp = 32'h31842e7b;
	8'h6e: temp = 32'h24259fd7;
	8'h6f: temp = 32'hf8bef472;
	8'h70: temp = 32'h835ffcb8;
	8'h71: temp = 32'h6df4c1f2;
	8'h72: temp = 32'h96f5b195;
	8'h73: temp = 32'hfd0af0fc;
	8'h74: temp = 32'hb0fe134c;
	8'h75: temp = 32'he2506d3d;
	8'h76: temp = 32'h4f9b12ea;
	8'h77: temp = 32'hf215f225;
	8'h78: temp = 32'ha223736f;
	8'h79: temp = 32'h9fb4c428;
	8'h7a: temp = 32'h25d04979;
	8'h7b: temp = 32'h34c713f8;
	8'h7c: temp = 32'hc4618187;
	8'h7d: temp = 32'hea7a6e98;
	8'h7e: temp = 32'h7cd16efc;
	8'h7f: temp = 32'h1436876c;
	8'h80: temp = 32'hf1544107;
	8'h81: temp = 32'hbedeee14;
	8'h82: temp = 32'h56e9af27;
	8'h83: temp = 32'ha04aa441;
	8'h84: temp = 32'h3cf7c899;
	8'h85: temp = 32'h92ecbae6;
	8'h86: temp = 32'hdd67016d;
	8'h87: temp = 32'h151682eb;
	8'h88: temp = 32'ha842eedf;
	8'h89: temp = 32'hfdba60b4;
	8'h8a: temp = 32'hf1907b75;
	8'h8b: temp = 32'h20e3030f;
	8'h8c: temp = 32'h24d8c29e;
	8'h8d: temp = 32'he139673b;
	8'h8e: temp = 32'hefa63fb8;
	8'h8f: temp = 32'h71873054;
	8'h90: temp = 32'hb6f2cf3b;
	8'h91: temp = 32'h9f326442;
	8'h92: temp = 32'hcb15a4cc;
	8'h93: temp = 32'hb01a4504;
	8'h94: temp = 32'hf1e47d8d;
	8'h95: temp = 32'h844a1be5;
	8'h96: temp = 32'hbae7dfdc;
	8'h97: temp = 32'h42cbda70;
	8'h98: temp = 32'hcd7dae0a;
	8'h99: temp = 32'h57e85b7a;
	8'h9a: temp = 32'hd53f5af6;
	8'h9b: temp = 32'h20cf4d8c;
	8'h9c: temp = 32'hcea4d428;
	8'h9d: temp = 32'h79d130a4;
	8'h9e: temp = 32'h3486ebfb;
	8'h9f: temp = 32'h33d3cddc;
	8'ha0: temp = 32'h77853b53;
	8'ha1: temp = 32'h37effcb5;
	8'ha2: temp = 32'hc5068778;
	8'ha3: temp = 32'he580b3e6;
	8'ha4: temp = 32'h4e68b8f4;
	8'ha5: temp = 32'hc5c8b37e;
	8'ha6: temp = 32'h0d809ea2;
	8'ha7: temp = 32'h398feb7c;
	8'ha8: temp = 32'h132a4f94;
	8'ha9: temp = 32'h43b7950e;
	8'haa: temp = 32'h2fee7d1c;
	8'hab: temp = 32'h223613bd;
	8'hac: temp = 32'hdd06caa2;
	8'had: temp = 32'h37df932b;
	8'hae: temp = 32'hc4248289;
	8'haf: temp = 32'hacf3ebc3;
	8'hb0: temp = 32'h5715f6b7;
	8'hb1: temp = 32'hef3478dd;
	8'hb2: temp = 32'hf267616f;
	8'hb3: temp = 32'hc148cbe4;
	8'hb4: temp = 32'h9052815e;
	8'hb5: temp = 32'h5e410fab;
	8'hb6: temp = 32'hb48a2465;
	8'hb7: temp = 32'h2eda7fa4;
	8'hb8: temp = 32'he87b40e4;
	8'hb9: temp = 32'he98ea084;
	8'hba: temp = 32'h5889e9e1;
	8'hbb: temp = 32'hefd390fc;
	8'hbc: temp = 32'hdd07d35b;
	8'hbd: temp = 32'hdb485694;
	8'hbe: temp = 32'h38d7e5b2;
	8'hbf: temp = 32'h57720101;
	8'hc0: temp = 32'h730edebc;
	8'hc1: temp = 32'h5b643113;
	8'hc2: temp = 32'h94917e4f;
	8'hc3: temp = 32'h503c2fba;
	8'hc4: temp = 32'h646f1282;
	8'hc5: temp = 32'h7523d24a;
	8'hc6: temp = 32'he0779695;
	8'hc7: temp = 32'hf9c17a8f;
	8'hc8: temp = 32'h7a5b2121;
	8'hc9: temp = 32'hd187b896;
	8'hca: temp = 32'h29263a4d;
	8'hcb: temp = 32'hba510cdf;
	8'hcc: temp = 32'h81f47c9f;
	8'hcd: temp = 32'had1163ed;
	8'hce: temp = 32'hea7b5965;
	8'hcf: temp = 32'h1a00726e;
	8'hd0: temp = 32'h11403092;
	8'hd1: temp = 32'h00da6d77;
	8'hd2: temp = 32'h4a0cdd61;
	8'hd3: temp = 32'had1f4603;
	8'hd4: temp = 32'h605bdfb0;
	8'hd5: temp = 32'h9eedc364;
	8'hd6: temp = 32'h22ebe6a8;
	8'hd7: temp = 32'hcee7d28a;
	8'hd8: temp = 32'ha0e736a0;
	8'hd9: temp = 32'h5564a6b9;
	8'hda: temp = 32'h10853209;
	8'hdb: temp = 32'hc7eb8f37;
	8'hdc: temp = 32'h2de705ca;
	8'hdd: temp = 32'h8951570f;
	8'hde: temp = 32'hdf09822b;
	8'hdf: temp = 32'hbd691a6c;
	8'he0: temp = 32'haa12e4f2;
	8'he1: temp = 32'h87451c0f;
	8'he2: temp = 32'he0f6a27a;
	8'he3: temp = 32'h3ada4819;
	8'he4: temp = 32'h4cf1764f;
	8'he5: temp = 32'h0d771c2b;
	8'he6: temp = 32'h67cdb156;
	8'he7: temp = 32'h350d8384;
	8'he8: temp = 32'h5938fa0f;
	8'he9: temp = 32'h42399ef3;
	8'hea: temp = 32'h36997b07;
	8'heb: temp = 32'h0e84093d;
	8'hec: temp = 32'h4aa93e61;
	8'hed: temp = 32'h8360d87b;
	8'hee: temp = 32'h1fa98b0c;
	8'hef: temp = 32'h1149382c;
	8'hf0: temp = 32'he97625a5;
	8'hf1: temp = 32'h0614d1b7;
	8'hf2: temp = 32'h0e25244b;
	8'hf3: temp = 32'h0c768347;
	8'hf4: temp = 32'h589e8d82;
	8'hf5: temp = 32'h0d2059d1;
	8'hf6: temp = 32'ha466bb1e;
	8'hf7: temp = 32'hf8da0a82;
	8'hf8: temp = 32'h04f19130;
	8'hf9: temp = 32'hba6e4ec0;
	8'hfa: temp = 32'h99265164;
	8'hfb: temp = 32'h1ee7230d;
	8'hfc: temp = 32'h50b2ad80;
	8'hfd: temp = 32'heaee6801;
	8'hfe: temp = 32'h8db2a283;
	8'hff: temp = 32'hea8bf59e;
      endcase // case(in)
   endfunction // temp
endmodule // CAST128_sbox8
