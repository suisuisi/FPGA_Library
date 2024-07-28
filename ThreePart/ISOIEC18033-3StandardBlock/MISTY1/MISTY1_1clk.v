/*-------------------------------------------------------------------------
 MISTY1 Encryption/Decryption Macro
 one round / one clock version, ASIC version
 
 File name   : MISTY1_1clk.v
 Version     : Version 1.0
 Created     : MAR/04/2007
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

module MISTY1( Kin, Din, Dout, Krdy, Drdy, EncDec, RSTn, EN, CLK, BSY, Kvld, Dvld );
  input CLK, RSTn, EN;
  input Drdy, Krdy, EncDec;
  input [ 63:0] Din;
  input [127:0] Kin;
  output [63:0] Dout;
  output 	Dvld, Kvld, BSY;

  // State assign
  parameter ST_IDLE =      3'b000;
  parameter ST_KEY_SCHED = 3'b001;
  parameter ST_ENCRYPT   = 3'b010;
  parameter ST_DECRYPT   = 3'b100;

  parameter Enc = 1'b0;
  parameter Dec = 1'b1;

  reg [2:0] 	state_reg;
  reg [8:0] 	round_reg;

  // Signals for Subkeys
  wire [63:0] KO;
  wire [47:0] KI;
  wire [31:0] KL1, KL2;
  wire [15:0] FI_to_sched;
  wire [31:0] sched_to_FI;

  assign Dvld = ( (round_reg[8] == 1'b1) && 
		  ( (state_reg == ST_ENCRYPT) || (state_reg == ST_DECRYPT) ) );

  //assign Kvld = (state_reg != ST_KEY_SCHED);
  assign Kvld = ( (state_reg == ST_KEY_SCHED) && (round_reg[7] == 1'b1) ) ? 1:0;

  assign BSY = (state_reg == ST_IDLE) ? 1'b0 : 1'b1;

  MISTY1_key_sched MISTY1_key_sched( .CLK         (CLK),
				     .EN          (EN),
				     .RSTn        (RSTn),
				     .Krdy        (Krdy),
				     .EncDec      (EncDec),
				     .Kin         (Kin),
				     .state       (state_reg),
				     .round       (round_reg),
				     .KO          (KO),
				     .KI          (KI),
				     .KL1         (KL1),
				     .KL2         (KL2),
				     .FI_to_sched (FI_to_sched),
				     .sched_to_FI (sched_to_FI) );

  MISTY1_randomize MISTY1_randomize(// Outputs
				    .Dout		(Dout),
				    .FI_to_sched	(FI_to_sched[15:0]),
				    // Inputs
				    .CLK		(CLK),
				    .EN               (EN),
				    .RSTn		(RSTn),
				    .state		(state_reg[2:0]),
				    .round		(round_reg[8:0]),
				    .EncDec           (EncDec),
				    .Drdy             (Drdy),
				    .Krdy             (Krdy),
				    .Din		(Din),
				    .sched_to_FI	(sched_to_FI[31:0]),
				    .KO		(KO[63:0]),
				    .KI		(KI[47:0]),
				    .KL1		(KL1[31:0]),
				    .KL2		(KL2[31:0]) );
  
  always @(posedge CLK) begin
    if(RSTn == 1'b0) begin
      state_reg <= ST_IDLE;
      round_reg <= 9'b0_0000_0001;
    end
    else if(EN == 1'b1) begin
      case(state_reg)
	ST_IDLE: begin
	  if(Krdy == 1'b1) state_reg <= ST_KEY_SCHED;
	  else if(Drdy == 1'b1)
	    if(EncDec == Enc) state_reg <= ST_ENCRYPT;
	    else                   state_reg <= ST_DECRYPT;
	end

	ST_KEY_SCHED: begin
	  if( round_reg[7] == 1'b1 ) begin
	    state_reg <= ST_IDLE;
	    round_reg <= 9'b0_0000_0001;	    
	  end else
	    round_reg <= { round_reg[7:0], round_reg[8] };
	end

	ST_ENCRYPT: begin
	  if( (round_reg[8] == 1'b1) && (Drdy != 1'b1 || EncDec == Dec) )
	    state_reg <= ST_IDLE;
	  round_reg <= { round_reg[7:0], round_reg[8] };
	end

	ST_DECRYPT: begin
	  if( (round_reg[8] == 1'b1) && (Drdy != 1'b1 || EncDec == Enc) )
	    state_reg <= ST_IDLE;
	  round_reg <= { round_reg[7:0], round_reg[8] };
	end
      endcase // case(state_reg)
    end
  end

endmodule // MISTY1


module MISTY1_randomize( Din, Dout, Krdy, Drdy, EncDec, RSTn, EN, CLK, 
		  FI_to_sched, state, round, sched_to_FI, KO, KI, KL1, KL2 );
  input CLK, RSTn, EN;  
  input [2:0] 	state;
  input [8:0] 	round;
  input 	EncDec;
  input 	Drdy, Krdy;

  input [63:0] Din;
  input [31:0] 	sched_to_FI;  

  input [63:0] KO;
  input [47:0] KI;
  input [31:0] KL1, KL2;

  output [63:0] Dout;
  output [15:0] FI_to_sched;

  // State assign
  parameter ST_IDLE =      3'b000;
  parameter ST_KEY_SCHED = 3'b001;
  parameter ST_ENCRYPT   = 3'b010;
  parameter ST_DECRYPT   = 3'b100;

  parameter Enc = 1'b0;
  parameter Dec = 1'b1;

  reg [63:0] 	data_reg;

  wire [63:0] 	FL_plus_out, FL_minus_out;
  MISTY1_FL_plus  MISTY1_FL_plus_L( .in( data_reg[63:32] ), .KL( KL1 ), .out( FL_plus_out[63:32] ) );
  MISTY1_FL_plus  MISTY1_FL_plus_R( .in( data_reg[31: 0] ), .KL( KL2 ), .out( FL_plus_out[31: 0] ) );
  MISTY1_FL_minus MISTY1_FL_minus_L( .in( data_reg[63:32] ), .KL( KL1 ), .out( FL_minus_out[63:32] ) );
  MISTY1_FL_minus MISTY1_FL_minus_R( .in( data_reg[31: 0] ), .KL( KL2 ), .out( FL_minus_out[31: 0] ) );

  wire [63:0] 	Feistel_in, Feistel_out;
  wire [31:0] 	FO_out;
  wire [63:0] 	data_next;
  wire [63:0] 	Feistel_or_through;
  assign Feistel_in = Feistel_in_select( data_reg, FL_plus_out, FL_minus_out,
					 round, EncDec );

  MISTY1_FO_sched MISTY1_FO_sched( .out		(FO_out),
				   .FI_to_sched	(FI_to_sched[15:0]),
				   // Inputs
				   .in		(Feistel_in[63:32]),
				   .KO		(KO[63:0]),
				   .KI		(KI[47:0]),
				   .state		(state[2:0]),
				   .sched_to_FI	(sched_to_FI[31:0])
				   );

  assign Feistel_out = { Feistel_in[63:32], Feistel_in[31:0] ^ FO_out };
  assign Feistel_or_through = (round[8]==1'b1) ? Feistel_in : Feistel_out;
			      
  assign data_next = (EncDec==Enc) ? 
		     {Feistel_or_through[31:0], Feistel_or_through[63:32]} : Feistel_or_through;
  assign Dout = data_next;
  
  always @(posedge CLK) begin
    if(RSTn == 1'b0) begin
      data_reg <= 64'h0000_0000_0000_0000;
    end
    else if(EN == 1'b1) begin
      case(state)
	ST_IDLE:
	  if(Krdy == 1'b0 && Drdy == 1'b1)
	    if(EncDec == Enc)
	      data_reg <= Din[63:0];
	    else
	      data_reg <= { Din[31:0], Din[63:32] };
	
	ST_ENCRYPT: begin
	  if(round[8] == 1'b1 && Krdy == 1'b0 && Drdy == 1'b1)
	    data_reg <= Din[63:0];
	  else
	    data_reg <= data_next;
	end

	ST_DECRYPT: begin
	  if(round[8] == 1'b1 && Krdy == 1'b0 && Drdy == 1'b1)
	    data_reg <= { Din[31:0], Din[63:32] };
	  else
	    data_reg <= data_next;
	end	
      endcase // case(state)
    end
  end    
      
  function [63:0] Feistel_in_select;
    input [63:0] through, FL_plus_out, FL_minus_out;
    input [8:0]   round;
    input 	  EncDec;

    if( EncDec==Enc )
      if( round[1] | round[3] | round[5] | round[7] )
	Feistel_in_select =  through;
      else 
	Feistel_in_select = FL_plus_out;

    else // EncDec==Dec
      if( round[0] | round[2] | round[4] | round[6] )
	Feistel_in_select = { FL_minus_out[31:0], FL_minus_out[63:32] };
      else if( round[1] | round[3] | round[5] | round[7] )
	Feistel_in_select = { through[31:0], through[63:32] };
      else
	Feistel_in_select = FL_minus_out;
  endfunction // Feistel_in_select
  
endmodule // MISTY1_randomize


module MISTY1_key_sched( Kin, Krdy, EncDec, RSTn, EN, CLK, state, round,
		  KO, KI, KL1, KL2, sched_to_FI, FI_to_sched );
  input CLK, RSTn, EN;
  input Krdy;
  input EncDec;
  input [127:0] Kin;
  input [2:0] 	state;
  input [8:0] 	round;
  input [15:0] 	FI_to_sched;

  output [63:0] KO;
  output [47:0] KI;
  output [31:0] KL1, KL2;
  output [31:0] sched_to_FI;

  // State assign
  parameter ST_IDLE =      3'b000;
  parameter ST_KEY_SCHED = 3'b001;
  parameter ST_ENCRYPT   = 3'b010;
  parameter ST_DECRYPT   = 3'b100;

  parameter Enc = 1'b0;
  parameter Dec = 1'b1;
  
  reg [127:0] K_reg, Kp_reg;

  assign      sched_to_FI = sched_to_FI_select(K_reg, round);
  assign      KL1 = KL1_select(K_reg, Kp_reg, round, EncDec);
  assign      KL2 = KL2_select(K_reg, Kp_reg, round, EncDec);  
  assign      KO = KO_select(K_reg, round, EncDec);
  assign      KI = KI_select(Kp_reg, round, EncDec);
  
  always @(posedge CLK) begin
    if(RSTn == 1'b0) begin
      K_reg  <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;
      Kp_reg <= 128'h0000_0000_0000_0000_0000_0000_0000_0000;      
    end
    else if(EN == 1'b1) begin
      case(state)
	ST_IDLE: if(Krdy == 1'b1) K_reg <= Kin;
	ST_KEY_SCHED: begin
	  if( round[ 0] == 1'b1 ) Kp_reg[127:112] <= FI_to_sched;
	  if( round[ 1] == 1'b1 ) Kp_reg[111: 96] <= FI_to_sched;	  
	  if( round[ 2] == 1'b1 ) Kp_reg[ 95: 80] <= FI_to_sched;
	  if( round[ 3] == 1'b1 ) Kp_reg[ 79: 64] <= FI_to_sched;
	  if( round[ 4] == 1'b1 ) Kp_reg[ 63: 48] <= FI_to_sched;
	  if( round[ 5] == 1'b1 ) Kp_reg[ 47: 32] <= FI_to_sched;
	  if( round[ 6] == 1'b1 ) Kp_reg[ 31: 16] <= FI_to_sched;
	  if( round[ 7] == 1'b1 ) Kp_reg[ 15:  0] <= FI_to_sched;
	end
      endcase // case(state)
    end
  end

  // Selector to select the input to the function FI while key-scheduling.
  // Note that two 16-bit input to FI is concatenated to
  // one 32-bit signal for the purpose of simplicity
  function [31:0] sched_to_FI_select;
    input [127:0] K_reg;
    input [8:0]   round;

    case(round)
      9'b0_0000_0001: sched_to_FI_select = K_reg[127: 96];
      9'b0_0000_0010: sched_to_FI_select = K_reg[111: 80];
      9'b0_0000_0100: sched_to_FI_select = K_reg[ 95: 64];
      9'b0_0000_1000: sched_to_FI_select = K_reg[ 79: 48];
      9'b0_0001_0000: sched_to_FI_select = K_reg[ 63: 32];
      9'b0_0010_0000: sched_to_FI_select = K_reg[ 47: 16];
      9'b0_0100_0000: sched_to_FI_select = K_reg[ 31:  0];
      default:        sched_to_FI_select = {K_reg[15: 0], K_reg[127:112]};
    endcase // case(round)
  endfunction // sched_to_FI_select
  
  function [31:0] KL1_select;
    input [127:0] K_reg, Kp_reg;
    input [8:0]   round;
    input 	  EncDec;

    reg [15:0] 	  K1, K2, K3, K4, K5, K6, K7, K8;
    reg [15:0] 	  Kp1, Kp2, Kp3, Kp4, Kp5, Kp6, Kp7, Kp8;

    begin
      { K1, K2, K3, K4, K5, K6, K7, K8 }         = K_reg;
      { Kp1, Kp2, Kp3, Kp4, Kp5, Kp6, Kp7, Kp8 } = Kp_reg;

      case(round)
	9'b0_0000_0001: KL1_select = (EncDec == Enc) ? {K1, Kp7} : {K5, Kp3};
	9'b0_0000_0100: KL1_select = (EncDec == Enc) ? {K2, Kp8} : {K4, Kp2};
	9'b0_0001_0000: KL1_select =                        {K3, Kp1};
	9'b0_0100_0000: KL1_select = (EncDec == Enc) ? {K4, Kp2} : {K2, Kp8};
	default:        KL1_select = (EncDec == Enc) ? {K5, Kp3} : {K1, Kp7};
      endcase // case(round)
    end	
  endfunction // KL1_select

  function [31:0] KL2_select;
    input [127:0] K_reg, Kp_reg;
    input [8:0]   round;
    input 	  EncDec;

    reg [15:0] 	  K1, K2, K3, K4, K5, K6, K7, K8;
    reg [15:0] 	  Kp1, Kp2, Kp3, Kp4, Kp5, Kp6, Kp7, Kp8;

    begin
      { K1, K2, K3, K4, K5, K6, K7, K8 }         = K_reg;
      { Kp1, Kp2, Kp3, Kp4, Kp5, Kp6, Kp7, Kp8 } = Kp_reg;

      case(round)
	9'b0_0000_0001: KL2_select = (EncDec == Enc) ? {Kp3, K5} : {Kp7, K1};
	9'b0_0000_0100: KL2_select = (EncDec == Enc) ? {Kp4, K6} : {Kp6, K8};
	9'b0_0001_0000: KL2_select =                        {Kp5, K7};
	9'b0_0100_0000: KL2_select = (EncDec == Enc) ? {Kp6, K8} : {Kp4, K6};
	default:        KL2_select = (EncDec == Enc) ? {Kp7, K1} : {Kp3, K5};
      endcase // case(round)
    end	
  endfunction // KL2_select

  function [63:0] KO_select;
    input [127:0] K_reg;
    input [8:0]   round;
    input 	  EncDec;

    reg [15:0] 	  K1, K2, K3, K4, K5, K6, K7, K8;

    begin
      { K1, K2, K3, K4, K5, K6, K7, K8 } = K_reg;
      case(round)
	9'b0_0000_0001: KO_select = (EncDec == Enc) ? {K1, K3, K8, K5} : {K8, K2, K7, K4};
	9'b0_0000_0010: KO_select = (EncDec == Enc) ? {K2, K4, K1, K6} : {K7, K1, K6, K3};
	9'b0_0000_0100: KO_select = (EncDec == Enc) ? {K3, K5, K2, K7} : {K6, K8, K5, K2};
	9'b0_0000_1000: KO_select = (EncDec == Enc) ? {K4, K6, K3, K8} : {K5, K7, K4, K1};
	9'b0_0001_0000: KO_select = (EncDec == Enc) ? {K5, K7, K4, K1} : {K4, K6, K3, K8};
	9'b0_0010_0000: KO_select = (EncDec == Enc) ? {K6, K8, K5, K2} : {K3, K5, K2, K7};
	9'b0_0100_0000: KO_select = (EncDec == Enc) ? {K7, K1, K6, K3} : {K2, K4, K1, K6};
	default:        KO_select = (EncDec == Enc) ? {K8, K2, K7, K4} : {K1, K3, K8, K5};
      endcase // case(round)
    end
  endfunction // KO_select

  function [47:0] KI_select;
    input [127:0] Kp_reg;
    input [8:0]   round;
    input 	  EncDec;
    reg [15:0] 	  Kp1, Kp2, Kp3, Kp4, Kp5, Kp6, Kp7, Kp8;

    begin
      { Kp1, Kp2, Kp3, Kp4, Kp5, Kp6, Kp7, Kp8 } = Kp_reg;
      case(round)
	9'b0_0000_0001: KI_select = (EncDec == Enc) ? {Kp6, Kp2, Kp4} : {Kp5, Kp1, Kp3};
	9'b0_0000_0010: KI_select = (EncDec == Enc) ? {Kp7, Kp3, Kp5} : {Kp4, Kp8, Kp2};
	9'b0_0000_0100: KI_select = (EncDec == Enc) ? {Kp8, Kp4, Kp6} : {Kp3, Kp7, Kp1};
	9'b0_0000_1000: KI_select = (EncDec == Enc) ? {Kp1, Kp5, Kp7} : {Kp2, Kp6, Kp8};
	9'b0_0001_0000: KI_select = (EncDec == Enc) ? {Kp2, Kp6, Kp8} : {Kp1, Kp5, Kp7};
	9'b0_0010_0000: KI_select = (EncDec == Enc) ? {Kp3, Kp7, Kp1} : {Kp8, Kp4, Kp6};
	9'b0_0100_0000: KI_select = (EncDec == Enc) ? {Kp4, Kp8, Kp2} : {Kp7, Kp3, Kp5};
	default:        KI_select = (EncDec == Enc) ? {Kp5, Kp1, Kp3} : {Kp6, Kp2, Kp4};
      endcase // case(round)
    end
  endfunction // KI_select
  
endmodule // MISTY1_key_sched


//
//  FO-function
//  (Supports key-scheduling)
//
module MISTY1_FO_sched( out, FI_to_sched, in, KO, KI, state, sched_to_FI );
  input [31:0] in;
  input [63:0] KO;
  input [47:0] KI;
  input [2:0]  state;
  output [31:0] out;

  // I/Os for key scheduling
  input  [31:0] sched_to_FI;  
  output [15:0] FI_to_sched;

  // State assign
  parameter ST_IDLE =      3'b000;
  parameter ST_KEY_SCHED = 3'b001;
  parameter ST_ENCRYPT   = 3'b010;
  parameter ST_DECRYPT   = 3'b100;


  wire [15:0]  KOi1, KOi2, KOi3, KOi4;
  wire [15:0]  KIi1, KIi2, KIi3;
  assign       { KOi1, KOi2, KOi3, KOi4 } = KO;
  assign       KIi1 = KI[47:32];
  assign       KIi2 = (state==ST_KEY_SCHED) ? sched_to_FI[15:0] : KI[31:16];
  assign       KIi3 = KI[15: 0];    

  wire [15:0]  FIi1_in, FIi1_out;
  wire [15:0]  FIi2_in, FIi2_out;
  wire [15:0]  FIi3_in, FIi3_out;
  wire [31:0]  round1_out, round2_out, round3_out;

  
  MISTY1_FI MISTY1_FIi1( .in(FIi1_in), .out(FIi1_out), .KI(KIi1) );
  MISTY1_FI MISTY1_FIi2( .in(FIi2_in), .out(FIi2_out), .KI(KIi2) );
  MISTY1_FI MISTY1_FIi3( .in(FIi3_in), .out(FIi3_out), .KI(KIi3) );  
  assign 	FI_to_sched = FIi2_out;
  
  assign       FIi1_in = in[31:16] ^ KOi1;
  assign       round1_out = { in[15:0], FIi1_out ^ in[15:0] };

  assign       FIi2_in = (state==ST_KEY_SCHED) ?
			 sched_to_FI[31:16] : round1_out[31:16] ^ KOi2;

  assign       round2_out = { round1_out[15:0], FIi2_out ^ round1_out[15:0] };

  assign       FIi3_in = round2_out[31:16] ^ KOi3;
  assign       round3_out = { round2_out[15:0], FIi3_out ^ round2_out[15:0] };

  assign       out = { round3_out[31:16] ^ KOi4, round3_out[15:0] };
endmodule // MISTY1_FO_sched

module MISTY1_FO( out, in, KO, KI );
  input [31:0] in;
  input [63:0] KO;
  input [47:0] KI;
  output [31:0] out;
  
  wire [15:0]  KOi1, KOi2, KOi3, KOi4;
  wire [15:0]  KIi1, KIi2, KIi3;
  assign       { KOi1, KOi2, KOi3, KOi4 } = KO;
  assign       { KIi1, KIi2, KIi3 } = KI;

  wire [15:0]  FIi1_in, FIi1_out;
  wire [15:0]  FIi2_in, FIi2_out;
  wire [15:0]  FIi3_in, FIi3_out;
  wire [31:0]  round1_out, round2_out, round3_out;

  MISTY1_FI MISTY1_FIi1( .in(FIi1_in), .out(FIi1_out), .KI(KIi1) );
  MISTY1_FI MISTY1_FIi2( .in(FIi2_in), .out(FIi2_out), .KI(KIi2) );
  MISTY1_FI MISTY1_FIi3( .in(FIi3_in), .out(FIi3_out), .KI(KIi3) );  

  assign       FIi1_in = in[31:16] ^ KOi1;
  assign       round1_out = { in[15:0], FIi1_out ^ in[15:0] };

  assign       FIi2_in = round1_out[31:16] ^ KOi2;
  assign       round2_out = { round1_out[15:0], FIi2_out ^ round1_out[15:0] };

  assign       FIi3_in = round2_out[31:16] ^ KOi3;
  assign       round3_out = { round2_out[15:0], FIi3_out ^ round2_out[15:0] };

  assign       out = { round3_out[31:16] ^ KOi4, round3_out[15:0] };
endmodule // MISTY1_FO

// FI function
module MISTY1_FI( out, in, KI );
   input [15:0] in;
   input [15:0] KI;
   output [15:0] out;

   wire [8:0] 	 in_9bit, KI_9bit, round1_9bit, round2_9bit, round3_9bit;
   wire [6:0] 	 in_7bit, KI_7bit, round1_7bit, round2_7bit, round3_7bit;

   wire [8:0] 	 S9_a_out, S9_b_out;
   wire [6:0] 	 S7_out;
   
   MISTY1_S9 MISTY1_S9_a( .in( in_9bit  ),    .out( S9_a_out ) );
   MISTY1_S9 MISTY1_S9_b( .in( round2_9bit ), .out( S9_b_out ) );
   MISTY1_S7 MISTY1_S7(   .in( round1_7bit ), .out( S7_out   ) );

   assign 	 {in_9bit, in_7bit} = in;
   assign 	 {KI_7bit, KI_9bit} = KI;
   
   assign 	 round1_7bit = in_7bit;
   assign 	 round1_9bit = S9_a_out ^ { 2'b00, in_7bit };

   assign 	 round2_9bit  = round1_9bit ^ KI_9bit;
   assign 	 round2_7bit  = S7_out ^ round1_9bit[6:0] ^ KI_7bit;

   assign 	 round3_7bit = round2_7bit;
   assign 	 round3_9bit = S9_b_out ^ { 2'b00, round2_7bit };

   assign 	 out = {round3_7bit, round3_9bit};
endmodule // MISTY1_FI

// FL function
module MISTY1_FL_plus( out, in, KL );
   input [31:0] in;
   input [31:0] KL;
   output [31:0] out;

   wire [15:0] 	 in_left,   in_right;
   wire [15:0] 	 temp_left, temp_right;
   wire [15:0] 	 out_left,  out_right;
   wire [15:0] 	 KL_left, KL_right;
   
   assign 	 {in_left, in_right} = in;
   assign 	 {KL_left, KL_right} = KL;

   assign 	 temp_left = in_left;
   assign 	 temp_right = in_right ^ ( in_left & KL_left);

   assign 	 out_left = temp_left ^ ( temp_right | KL_right );
   assign 	 out_right = temp_right;

   assign 	 out = {out_left, out_right};
endmodule // MISTY1_FL_plus

// FL^{-1} function
module MISTY1_FL_minus( out, in, KL );
   input [31:0] in;
   input [31:0] KL;
   output [31:0] out;

   wire [15:0] 	 in_left,   in_right;
   wire [15:0] 	 temp_left, temp_right;
   wire [15:0] 	 out_left,  out_right;
   wire [15:0] 	 KL_left, KL_right;
   
   assign 	 {in_left, in_right} = in;
   assign 	 {KL_left, KL_right} = KL;

   assign 	 temp_left = in_left ^ ( in_right | KL_right );
   assign 	 temp_right = in_right;

   assign 	 out_left = temp_left;
   assign 	 out_right = temp_right ^ ( temp_left & KL_left );

   assign 	 out = {out_left, out_right};
endmodule // MISTY1_FL_minus


module MISTY1_S7( out, in );
   input [6:0] in;
   output [6:0] out;

   assign 	out = temp(in);
   
   function [6:0] temp;
      input [6:0] in;
      case(in)
	7'h00: temp = 7'h1b;     7'h01: temp = 7'h32;     7'h02: temp = 7'h33;     7'h03: temp = 7'h5a;
	7'h04: temp = 7'h3b;     7'h05: temp = 7'h10;     7'h06: temp = 7'h17;     7'h07: temp = 7'h54;
	7'h08: temp = 7'h5b;     7'h09: temp = 7'h1a;     7'h0a: temp = 7'h72;     7'h0b: temp = 7'h73;
	7'h0c: temp = 7'h6b;     7'h0d: temp = 7'h2c;     7'h0e: temp = 7'h66;     7'h0f: temp = 7'h49;
	7'h10: temp = 7'h1f;     7'h11: temp = 7'h24;     7'h12: temp = 7'h13;     7'h13: temp = 7'h6c;
	7'h14: temp = 7'h37;     7'h15: temp = 7'h2e;     7'h16: temp = 7'h3f;     7'h17: temp = 7'h4a;
	7'h18: temp = 7'h5d;     7'h19: temp = 7'h0f;     7'h1a: temp = 7'h40;     7'h1b: temp = 7'h56;
	7'h1c: temp = 7'h25;     7'h1d: temp = 7'h51;     7'h1e: temp = 7'h1c;     7'h1f: temp = 7'h04;
	7'h20: temp = 7'h0b;     7'h21: temp = 7'h46;     7'h22: temp = 7'h20;     7'h23: temp = 7'h0d;
	7'h24: temp = 7'h7b;     7'h25: temp = 7'h35;     7'h26: temp = 7'h44;     7'h27: temp = 7'h42;
	7'h28: temp = 7'h2b;     7'h29: temp = 7'h1e;     7'h2a: temp = 7'h41;     7'h2b: temp = 7'h14;
	7'h2c: temp = 7'h4b;     7'h2d: temp = 7'h79;     7'h2e: temp = 7'h15;     7'h2f: temp = 7'h6f;
	7'h30: temp = 7'h0e;     7'h31: temp = 7'h55;     7'h32: temp = 7'h09;     7'h33: temp = 7'h36;
	7'h34: temp = 7'h74;     7'h35: temp = 7'h0c;     7'h36: temp = 7'h67;     7'h37: temp = 7'h53;
	7'h38: temp = 7'h28;     7'h39: temp = 7'h0a;     7'h3a: temp = 7'h7e;     7'h3b: temp = 7'h38;
	7'h3c: temp = 7'h02;     7'h3d: temp = 7'h07;     7'h3e: temp = 7'h60;     7'h3f: temp = 7'h29;
	7'h40: temp = 7'h19;     7'h41: temp = 7'h12;     7'h42: temp = 7'h65;     7'h43: temp = 7'h2f;
	7'h44: temp = 7'h30;     7'h45: temp = 7'h39;     7'h46: temp = 7'h08;     7'h47: temp = 7'h68;
	7'h48: temp = 7'h5f;     7'h49: temp = 7'h78;     7'h4a: temp = 7'h2a;     7'h4b: temp = 7'h4c;
	7'h4c: temp = 7'h64;     7'h4d: temp = 7'h45;     7'h4e: temp = 7'h75;     7'h4f: temp = 7'h3d;
	7'h50: temp = 7'h59;     7'h51: temp = 7'h48;     7'h52: temp = 7'h03;     7'h53: temp = 7'h57;
	7'h54: temp = 7'h7c;     7'h55: temp = 7'h4f;     7'h56: temp = 7'h62;     7'h57: temp = 7'h3c;
	7'h58: temp = 7'h1d;     7'h59: temp = 7'h21;     7'h5a: temp = 7'h5e;     7'h5b: temp = 7'h27;
	7'h5c: temp = 7'h6a;     7'h5d: temp = 7'h70;     7'h5e: temp = 7'h4d;     7'h5f: temp = 7'h3a;
	7'h60: temp = 7'h01;     7'h61: temp = 7'h6d;     7'h62: temp = 7'h6e;     7'h63: temp = 7'h63;
	7'h64: temp = 7'h18;     7'h65: temp = 7'h77;     7'h66: temp = 7'h23;     7'h67: temp = 7'h05;
	7'h68: temp = 7'h26;     7'h69: temp = 7'h76;     7'h6a: temp = 7'h00;     7'h6b: temp = 7'h31;
	7'h6c: temp = 7'h2d;     7'h6d: temp = 7'h7a;     7'h6e: temp = 7'h7f;     7'h6f: temp = 7'h61;
	7'h70: temp = 7'h50;     7'h71: temp = 7'h22;     7'h72: temp = 7'h11;     7'h73: temp = 7'h06;
	7'h74: temp = 7'h47;     7'h75: temp = 7'h16;     7'h76: temp = 7'h52;     7'h77: temp = 7'h4e;
	7'h78: temp = 7'h71;     7'h79: temp = 7'h3e;     7'h7a: temp = 7'h69;     7'h7b: temp = 7'h43;
	7'h7c: temp = 7'h34;     7'h7d: temp = 7'h5c;     7'h7e: temp = 7'h58;     default: temp = 7'h7d;
      endcase // case(in)
   endfunction // temp
endmodule // MISTY1_S7


module MISTY1_S9( out, in );
   input [8:0] in;
   output [8:0] out;

   assign 	out = temp(in);
   
   function [8:0] temp;
      input [8:0] in;
      case(in)
	9'h000: temp = 9'h1c3;     9'h001: temp = 9'h0cb;     9'h002: temp = 9'h153;     9'h003: temp = 9'h19f;    
	9'h004: temp = 9'h1e3;     9'h005: temp = 9'h0e9;     9'h006: temp = 9'h0fb;     9'h007: temp = 9'h035;    
	9'h008: temp = 9'h181;     9'h009: temp = 9'h0b9;     9'h00a: temp = 9'h117;     9'h00b: temp = 9'h1eb;    
	9'h00c: temp = 9'h133;     9'h00d: temp = 9'h009;     9'h00e: temp = 9'h02d;     9'h00f: temp = 9'h0d3;    
	9'h010: temp = 9'h0c7;     9'h011: temp = 9'h14a;     9'h012: temp = 9'h037;     9'h013: temp = 9'h07e;    
	9'h014: temp = 9'h0eb;     9'h015: temp = 9'h164;     9'h016: temp = 9'h193;     9'h017: temp = 9'h1d8;    
	9'h018: temp = 9'h0a3;     9'h019: temp = 9'h11e;     9'h01a: temp = 9'h055;     9'h01b: temp = 9'h02c;    
	9'h01c: temp = 9'h01d;     9'h01d: temp = 9'h1a2;     9'h01e: temp = 9'h163;     9'h01f: temp = 9'h118;    
	9'h020: temp = 9'h14b;     9'h021: temp = 9'h152;     9'h022: temp = 9'h1d2;     9'h023: temp = 9'h00f;    
	9'h024: temp = 9'h02b;     9'h025: temp = 9'h030;     9'h026: temp = 9'h13a;     9'h027: temp = 9'h0e5;    
	9'h028: temp = 9'h111;     9'h029: temp = 9'h138;     9'h02a: temp = 9'h18e;     9'h02b: temp = 9'h063;    
	9'h02c: temp = 9'h0e3;     9'h02d: temp = 9'h0c8;     9'h02e: temp = 9'h1f4;     9'h02f: temp = 9'h01b;    
	9'h030: temp = 9'h001;     9'h031: temp = 9'h09d;     9'h032: temp = 9'h0f8;     9'h033: temp = 9'h1a0;    
	9'h034: temp = 9'h16d;     9'h035: temp = 9'h1f3;     9'h036: temp = 9'h01c;     9'h037: temp = 9'h146;    
	9'h038: temp = 9'h07d;     9'h039: temp = 9'h0d1;     9'h03a: temp = 9'h082;     9'h03b: temp = 9'h1ea;    
	9'h03c: temp = 9'h183;     9'h03d: temp = 9'h12d;     9'h03e: temp = 9'h0f4;     9'h03f: temp = 9'h19e;    
	9'h040: temp = 9'h1d3;     9'h041: temp = 9'h0dd;     9'h042: temp = 9'h1e2;     9'h043: temp = 9'h128;    
	9'h044: temp = 9'h1e0;     9'h045: temp = 9'h0ec;     9'h046: temp = 9'h059;     9'h047: temp = 9'h091;    
	9'h048: temp = 9'h011;     9'h049: temp = 9'h12f;     9'h04a: temp = 9'h026;     9'h04b: temp = 9'h0dc;    
	9'h04c: temp = 9'h0b0;     9'h04d: temp = 9'h18c;     9'h04e: temp = 9'h10f;     9'h04f: temp = 9'h1f7;    
	9'h050: temp = 9'h0e7;     9'h051: temp = 9'h16c;     9'h052: temp = 9'h0b6;     9'h053: temp = 9'h0f9;    
	9'h054: temp = 9'h0d8;     9'h055: temp = 9'h151;     9'h056: temp = 9'h101;     9'h057: temp = 9'h14c;    
	9'h058: temp = 9'h103;     9'h059: temp = 9'h0b8;     9'h05a: temp = 9'h154;     9'h05b: temp = 9'h12b;    
	9'h05c: temp = 9'h1ae;     9'h05d: temp = 9'h017;     9'h05e: temp = 9'h071;     9'h05f: temp = 9'h00c;    
	9'h060: temp = 9'h047;     9'h061: temp = 9'h058;     9'h062: temp = 9'h07f;     9'h063: temp = 9'h1a4;    
	9'h064: temp = 9'h134;     9'h065: temp = 9'h129;     9'h066: temp = 9'h084;     9'h067: temp = 9'h15d;    
	9'h068: temp = 9'h19d;     9'h069: temp = 9'h1b2;     9'h06a: temp = 9'h1a3;     9'h06b: temp = 9'h048;    
	9'h06c: temp = 9'h07c;     9'h06d: temp = 9'h051;     9'h06e: temp = 9'h1ca;     9'h06f: temp = 9'h023;    
	9'h070: temp = 9'h13d;     9'h071: temp = 9'h1a7;     9'h072: temp = 9'h165;     9'h073: temp = 9'h03b;    
	9'h074: temp = 9'h042;     9'h075: temp = 9'h0da;     9'h076: temp = 9'h192;     9'h077: temp = 9'h0ce;    
	9'h078: temp = 9'h0c1;     9'h079: temp = 9'h06b;     9'h07a: temp = 9'h09f;     9'h07b: temp = 9'h1f1;    
	9'h07c: temp = 9'h12c;     9'h07d: temp = 9'h184;     9'h07e: temp = 9'h0fa;     9'h07f: temp = 9'h196;    
	9'h080: temp = 9'h1e1;     9'h081: temp = 9'h169;     9'h082: temp = 9'h17d;     9'h083: temp = 9'h031;    
	9'h084: temp = 9'h180;     9'h085: temp = 9'h10a;     9'h086: temp = 9'h094;     9'h087: temp = 9'h1da;    
	9'h088: temp = 9'h186;     9'h089: temp = 9'h13e;     9'h08a: temp = 9'h11c;     9'h08b: temp = 9'h060;    
	9'h08c: temp = 9'h175;     9'h08d: temp = 9'h1cf;     9'h08e: temp = 9'h067;     9'h08f: temp = 9'h119;    
	9'h090: temp = 9'h065;     9'h091: temp = 9'h068;     9'h092: temp = 9'h099;     9'h093: temp = 9'h150;    
	9'h094: temp = 9'h008;     9'h095: temp = 9'h007;     9'h096: temp = 9'h17c;     9'h097: temp = 9'h0b7;    
	9'h098: temp = 9'h024;     9'h099: temp = 9'h019;     9'h09a: temp = 9'h0de;     9'h09b: temp = 9'h127;    
	9'h09c: temp = 9'h0db;     9'h09d: temp = 9'h0e4;     9'h09e: temp = 9'h1a9;     9'h09f: temp = 9'h052;    
	9'h0a0: temp = 9'h109;     9'h0a1: temp = 9'h090;     9'h0a2: temp = 9'h19c;     9'h0a3: temp = 9'h1c1;    
	9'h0a4: temp = 9'h028;     9'h0a5: temp = 9'h1b3;     9'h0a6: temp = 9'h135;     9'h0a7: temp = 9'h16a;    
	9'h0a8: temp = 9'h176;     9'h0a9: temp = 9'h0df;     9'h0aa: temp = 9'h1e5;     9'h0ab: temp = 9'h188;    
	9'h0ac: temp = 9'h0c5;     9'h0ad: temp = 9'h16e;     9'h0ae: temp = 9'h1de;     9'h0af: temp = 9'h1b1;    
	9'h0b0: temp = 9'h0c3;     9'h0b1: temp = 9'h1df;     9'h0b2: temp = 9'h036;     9'h0b3: temp = 9'h0ee;    
	9'h0b4: temp = 9'h1ee;     9'h0b5: temp = 9'h0f0;     9'h0b6: temp = 9'h093;     9'h0b7: temp = 9'h049;    
	9'h0b8: temp = 9'h09a;     9'h0b9: temp = 9'h1b6;     9'h0ba: temp = 9'h069;     9'h0bb: temp = 9'h081;    
	9'h0bc: temp = 9'h125;     9'h0bd: temp = 9'h00b;     9'h0be: temp = 9'h05e;     9'h0bf: temp = 9'h0b4;    
	9'h0c0: temp = 9'h149;     9'h0c1: temp = 9'h1c7;     9'h0c2: temp = 9'h174;     9'h0c3: temp = 9'h03e;    
	9'h0c4: temp = 9'h13b;     9'h0c5: temp = 9'h1b7;     9'h0c6: temp = 9'h08e;     9'h0c7: temp = 9'h1c6;    
	9'h0c8: temp = 9'h0ae;     9'h0c9: temp = 9'h010;     9'h0ca: temp = 9'h095;     9'h0cb: temp = 9'h1ef;    
	9'h0cc: temp = 9'h04e;     9'h0cd: temp = 9'h0f2;     9'h0ce: temp = 9'h1fd;     9'h0cf: temp = 9'h085;    
	9'h0d0: temp = 9'h0fd;     9'h0d1: temp = 9'h0f6;     9'h0d2: temp = 9'h0a0;     9'h0d3: temp = 9'h16f;    
	9'h0d4: temp = 9'h083;     9'h0d5: temp = 9'h08a;     9'h0d6: temp = 9'h156;     9'h0d7: temp = 9'h09b;    
	9'h0d8: temp = 9'h13c;     9'h0d9: temp = 9'h107;     9'h0da: temp = 9'h167;     9'h0db: temp = 9'h098;    
	9'h0dc: temp = 9'h1d0;     9'h0dd: temp = 9'h1e9;     9'h0de: temp = 9'h003;     9'h0df: temp = 9'h1fe;    
	9'h0e0: temp = 9'h0bd;     9'h0e1: temp = 9'h122;     9'h0e2: temp = 9'h089;     9'h0e3: temp = 9'h0d2;    
	9'h0e4: temp = 9'h18f;     9'h0e5: temp = 9'h012;     9'h0e6: temp = 9'h033;     9'h0e7: temp = 9'h06a;    
	9'h0e8: temp = 9'h142;     9'h0e9: temp = 9'h0ed;     9'h0ea: temp = 9'h170;     9'h0eb: temp = 9'h11b;    
	9'h0ec: temp = 9'h0e2;     9'h0ed: temp = 9'h14f;     9'h0ee: temp = 9'h158;     9'h0ef: temp = 9'h131;    
	9'h0f0: temp = 9'h147;     9'h0f1: temp = 9'h05d;     9'h0f2: temp = 9'h113;     9'h0f3: temp = 9'h1cd;    
	9'h0f4: temp = 9'h079;     9'h0f5: temp = 9'h161;     9'h0f6: temp = 9'h1a5;     9'h0f7: temp = 9'h179;    
	9'h0f8: temp = 9'h09e;     9'h0f9: temp = 9'h1b4;     9'h0fa: temp = 9'h0cc;     9'h0fb: temp = 9'h022;    
	9'h0fc: temp = 9'h132;     9'h0fd: temp = 9'h01a;     9'h0fe: temp = 9'h0e8;     9'h0ff: temp = 9'h004;    
	9'h100: temp = 9'h187;     9'h101: temp = 9'h1ed;     9'h102: temp = 9'h197;     9'h103: temp = 9'h039;    
	9'h104: temp = 9'h1bf;     9'h105: temp = 9'h1d7;     9'h106: temp = 9'h027;     9'h107: temp = 9'h18b;    
	9'h108: temp = 9'h0c6;     9'h109: temp = 9'h09c;     9'h10a: temp = 9'h0d0;     9'h10b: temp = 9'h14e;    
	9'h10c: temp = 9'h06c;     9'h10d: temp = 9'h034;     9'h10e: temp = 9'h1f2;     9'h10f: temp = 9'h06e;    
	9'h110: temp = 9'h0ca;     9'h111: temp = 9'h025;     9'h112: temp = 9'h0ba;     9'h113: temp = 9'h191;    
	9'h114: temp = 9'h0fe;     9'h115: temp = 9'h013;     9'h116: temp = 9'h106;     9'h117: temp = 9'h02f;    
	9'h118: temp = 9'h1ad;     9'h119: temp = 9'h172;     9'h11a: temp = 9'h1db;     9'h11b: temp = 9'h0c0;    
	9'h11c: temp = 9'h10b;     9'h11d: temp = 9'h1d6;     9'h11e: temp = 9'h0f5;     9'h11f: temp = 9'h1ec;    
	9'h120: temp = 9'h10d;     9'h121: temp = 9'h076;     9'h122: temp = 9'h114;     9'h123: temp = 9'h1ab;    
	9'h124: temp = 9'h075;     9'h125: temp = 9'h10c;     9'h126: temp = 9'h1e4;     9'h127: temp = 9'h159;    
	9'h128: temp = 9'h054;     9'h129: temp = 9'h11f;     9'h12a: temp = 9'h04b;     9'h12b: temp = 9'h0c4;    
	9'h12c: temp = 9'h1be;     9'h12d: temp = 9'h0f7;     9'h12e: temp = 9'h029;     9'h12f: temp = 9'h0a4;    
	9'h130: temp = 9'h00e;     9'h131: temp = 9'h1f0;     9'h132: temp = 9'h077;     9'h133: temp = 9'h04d;    
	9'h134: temp = 9'h17a;     9'h135: temp = 9'h086;     9'h136: temp = 9'h08b;     9'h137: temp = 9'h0b3;    
	9'h138: temp = 9'h171;     9'h139: temp = 9'h0bf;     9'h13a: temp = 9'h10e;     9'h13b: temp = 9'h104;    
	9'h13c: temp = 9'h097;     9'h13d: temp = 9'h15b;     9'h13e: temp = 9'h160;     9'h13f: temp = 9'h168;    
	9'h140: temp = 9'h0d7;     9'h141: temp = 9'h0bb;     9'h142: temp = 9'h066;     9'h143: temp = 9'h1ce;    
	9'h144: temp = 9'h0fc;     9'h145: temp = 9'h092;     9'h146: temp = 9'h1c5;     9'h147: temp = 9'h06f;    
	9'h148: temp = 9'h016;     9'h149: temp = 9'h04a;     9'h14a: temp = 9'h0a1;     9'h14b: temp = 9'h139;    
	9'h14c: temp = 9'h0af;     9'h14d: temp = 9'h0f1;     9'h14e: temp = 9'h190;     9'h14f: temp = 9'h00a;    
	9'h150: temp = 9'h1aa;     9'h151: temp = 9'h143;     9'h152: temp = 9'h17b;     9'h153: temp = 9'h056;    
	9'h154: temp = 9'h18d;     9'h155: temp = 9'h166;     9'h156: temp = 9'h0d4;     9'h157: temp = 9'h1fb;    
	9'h158: temp = 9'h14d;     9'h159: temp = 9'h194;     9'h15a: temp = 9'h19a;     9'h15b: temp = 9'h087;    
	9'h15c: temp = 9'h1f8;     9'h15d: temp = 9'h123;     9'h15e: temp = 9'h0a7;     9'h15f: temp = 9'h1b8;    
	9'h160: temp = 9'h141;     9'h161: temp = 9'h03c;     9'h162: temp = 9'h1f9;     9'h163: temp = 9'h140;    
	9'h164: temp = 9'h02a;     9'h165: temp = 9'h155;     9'h166: temp = 9'h11a;     9'h167: temp = 9'h1a1;    
	9'h168: temp = 9'h198;     9'h169: temp = 9'h0d5;     9'h16a: temp = 9'h126;     9'h16b: temp = 9'h1af;    
	9'h16c: temp = 9'h061;     9'h16d: temp = 9'h12e;     9'h16e: temp = 9'h157;     9'h16f: temp = 9'h1dc;    
	9'h170: temp = 9'h072;     9'h171: temp = 9'h18a;     9'h172: temp = 9'h0aa;     9'h173: temp = 9'h096;    
	9'h174: temp = 9'h115;     9'h175: temp = 9'h0ef;     9'h176: temp = 9'h045;     9'h177: temp = 9'h07b;    
	9'h178: temp = 9'h08d;     9'h179: temp = 9'h145;     9'h17a: temp = 9'h053;     9'h17b: temp = 9'h05f;    
	9'h17c: temp = 9'h178;     9'h17d: temp = 9'h0b2;     9'h17e: temp = 9'h02e;     9'h17f: temp = 9'h020;    
	9'h180: temp = 9'h1d5;     9'h181: temp = 9'h03f;     9'h182: temp = 9'h1c9;     9'h183: temp = 9'h1e7;    
	9'h184: temp = 9'h1ac;     9'h185: temp = 9'h044;     9'h186: temp = 9'h038;     9'h187: temp = 9'h014;    
	9'h188: temp = 9'h0b1;     9'h189: temp = 9'h16b;     9'h18a: temp = 9'h0ab;     9'h18b: temp = 9'h0b5;    
	9'h18c: temp = 9'h05a;     9'h18d: temp = 9'h182;     9'h18e: temp = 9'h1c8;     9'h18f: temp = 9'h1d4;    
	9'h190: temp = 9'h018;     9'h191: temp = 9'h177;     9'h192: temp = 9'h064;     9'h193: temp = 9'h0cf;    
	9'h194: temp = 9'h06d;     9'h195: temp = 9'h100;     9'h196: temp = 9'h199;     9'h197: temp = 9'h130;    
	9'h198: temp = 9'h15a;     9'h199: temp = 9'h005;     9'h19a: temp = 9'h120;     9'h19b: temp = 9'h1bb;    
	9'h19c: temp = 9'h1bd;     9'h19d: temp = 9'h0e0;     9'h19e: temp = 9'h04f;     9'h19f: temp = 9'h0d6;    
	9'h1a0: temp = 9'h13f;     9'h1a1: temp = 9'h1c4;     9'h1a2: temp = 9'h12a;     9'h1a3: temp = 9'h015;    
	9'h1a4: temp = 9'h006;     9'h1a5: temp = 9'h0ff;     9'h1a6: temp = 9'h19b;     9'h1a7: temp = 9'h0a6;    
	9'h1a8: temp = 9'h043;     9'h1a9: temp = 9'h088;     9'h1aa: temp = 9'h050;     9'h1ab: temp = 9'h15f;    
	9'h1ac: temp = 9'h1e8;     9'h1ad: temp = 9'h121;     9'h1ae: temp = 9'h073;     9'h1af: temp = 9'h17e;    
	9'h1b0: temp = 9'h0bc;     9'h1b1: temp = 9'h0c2;     9'h1b2: temp = 9'h0c9;     9'h1b3: temp = 9'h173;    
	9'h1b4: temp = 9'h189;     9'h1b5: temp = 9'h1f5;     9'h1b6: temp = 9'h074;     9'h1b7: temp = 9'h1cc;    
	9'h1b8: temp = 9'h1e6;     9'h1b9: temp = 9'h1a8;     9'h1ba: temp = 9'h195;     9'h1bb: temp = 9'h01f;    
	9'h1bc: temp = 9'h041;     9'h1bd: temp = 9'h00d;     9'h1be: temp = 9'h1ba;     9'h1bf: temp = 9'h032;    
	9'h1c0: temp = 9'h03d;     9'h1c1: temp = 9'h1d1;     9'h1c2: temp = 9'h080;     9'h1c3: temp = 9'h0a8;    
	9'h1c4: temp = 9'h057;     9'h1c5: temp = 9'h1b9;     9'h1c6: temp = 9'h162;     9'h1c7: temp = 9'h148;    
	9'h1c8: temp = 9'h0d9;     9'h1c9: temp = 9'h105;     9'h1ca: temp = 9'h062;     9'h1cb: temp = 9'h07a;    
	9'h1cc: temp = 9'h021;     9'h1cd: temp = 9'h1ff;     9'h1ce: temp = 9'h112;     9'h1cf: temp = 9'h108;    
	9'h1d0: temp = 9'h1c0;     9'h1d1: temp = 9'h0a9;     9'h1d2: temp = 9'h11d;     9'h1d3: temp = 9'h1b0;    
	9'h1d4: temp = 9'h1a6;     9'h1d5: temp = 9'h0cd;     9'h1d6: temp = 9'h0f3;     9'h1d7: temp = 9'h05c;    
	9'h1d8: temp = 9'h102;     9'h1d9: temp = 9'h05b;     9'h1da: temp = 9'h1d9;     9'h1db: temp = 9'h144;    
	9'h1dc: temp = 9'h1f6;     9'h1dd: temp = 9'h0ad;     9'h1de: temp = 9'h0a5;     9'h1df: temp = 9'h03a;    
	9'h1e0: temp = 9'h1cb;     9'h1e1: temp = 9'h136;     9'h1e2: temp = 9'h17f;     9'h1e3: temp = 9'h046;    
	9'h1e4: temp = 9'h0e1;     9'h1e5: temp = 9'h01e;     9'h1e6: temp = 9'h1dd;     9'h1e7: temp = 9'h0e6;    
	9'h1e8: temp = 9'h137;     9'h1e9: temp = 9'h1fa;     9'h1ea: temp = 9'h185;     9'h1eb: temp = 9'h08c;    
	9'h1ec: temp = 9'h08f;     9'h1ed: temp = 9'h040;     9'h1ee: temp = 9'h1b5;     9'h1ef: temp = 9'h0be;    
	9'h1f0: temp = 9'h078;     9'h1f1: temp = 9'h000;     9'h1f2: temp = 9'h0ac;     9'h1f3: temp = 9'h110;    
	9'h1f4: temp = 9'h15e;     9'h1f5: temp = 9'h124;     9'h1f6: temp = 9'h002;     9'h1f7: temp = 9'h1bc;    
	9'h1f8: temp = 9'h0a2;     9'h1f9: temp = 9'h0ea;     9'h1fa: temp = 9'h070;     9'h1fb: temp = 9'h1fc;    
	9'h1fc: temp = 9'h116;     9'h1fd: temp = 9'h15c;     9'h1fe: temp = 9'h04c;     default: temp = 9'h1c2;    
      endcase // case(in)
   endfunction // temp
endmodule // MISTY1_S9

