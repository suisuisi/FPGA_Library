////////////////////////////////////////////////////////////////
//
// 512 bit RSA macro verilog code
//
// File name    : RSA.v
//
// Created      : JUN/10/2008
// Last updated : May/28/2009
// Designed by  : Atsushi MIYAMOTO
//
// Copyright (C) 2008-2009 Tohoku Univ.
//
// 右+dummyのバグを修正 08/12/11
// 乗算(X*Y)，ダミー乗算(Y*X)となっていたのをメモリマップの修正により訂正
// moduloのバグを修正 09/5/28
////////////////////////////////////////////////////////////////


module RSA ( Kin, Min, Din, Dout, Krdy, Mrdy, Drdy, RSTn, EN, CRT, MODE, CLK, BSY, EXEC, Kvld, Mvld, Dvld );

   // global parameter
   parameter P_KLEN  = 512;  // key length
   parameter P_RADIX = 32;   // radix size (r bit)
   parameter P_WORD  = 32;   // word size (w bit)
   parameter P_IBUS  = 32;   // interface bus width (= radix)

   // counter parameter
   parameter P_k_CNTLEN = 9;  // k counter length 0-511
   parameter P_i_CNTLEN = 9;  // i counter length 0-511
   parameter P_j_CNTLEN = 4;  // j counter length 0-15

   // address size parameter
   parameter P_MAIN_AD_BIT = 7;     // 0-127   
   parameter P_TMP_AD_BIT = 4;      // 0-15
   
   input  [P_IBUS-1:0] Kin, Min, Din;        // key / modulo / plaintext data input
   output [P_IBUS-1:0] Dout;                 // ciphertext data output
   input 	       Krdy, Mrdy, Drdy;     // key / modulo / plaintext data ready signal
   input 	       RSTn;                 // negative reset signal 
   input 	       EN;                   // chip enable signal 
   input 	       CRT;                  // CRT mode signal CRT=1 on / CRT=0 off
   input [2:0] 	       MODE;                 // modular exponentiation mode signal
                                             // MODE=0 left-to-right binary method 
                                             // MODE=1 right-to-left binary method
                                             // MODE=2 left-to-right binary method with dummy
                                             // MODE=3 right-to-left binary method with dummy
                                             // MODE=4 Montgomery Powering Ladder
                                             // MODE=5 Marc's right-to-left binary method
   input 	       CLK;                  // system clock
   output 	       BSY;                  // busy signal
   output 	       EXEC;                 // execution signal
   output 	       Kvld, Mvld, Dvld;     // key / modulo / plaintext data valid signal

   wire 	       EnKey, KeyShift;      // control signals for key register
   wire 	       key_bit;              // exponet

   wire [20:0]         MBCon;                // control signals for multiplication block
   wire [8:0] 	       CntCon;               // control signals for counter module
   wire [4:0] 	       MemCon;               // control signals for register array
   wire [18:0] 	       AdCon;                // control signals for memory address generator
   
   wire [P_k_CNTLEN-1:0]    k_count;         // k count value
   wire [P_i_CNTLEN-1:0]    i_count;         // i count value
   wire [P_j_CNTLEN-1:0]    j_count;         // j count value
   wire [P_j_CNTLEN-1:0]    j_minus_1_count; // j-1 count value
   wire [P_j_CNTLEN-1:0]    plus_1_count;    // +1 count value
   
   wire [P_MAIN_AD_BIT-1:0] wad, ad_0, ad_1; // addresses of main register arrary
   wire [P_TMP_AD_BIT-1:0]  ad_t;            // address of temporary register array

   wire [P_RADIX-1:0] 	    dout;            // r bit output of multiplication block
   wire 		    sign;            // sign (qh(LSB))
   
   wire [P_RADIX-1:0] 	    din;             // r bit input of memory
   wire [P_RADIX-1:0] 	    d_0;             // r bit output of memory for multiplier x
   wire [P_WORD-1:0] 	    d_1;             // w bit output of memory for multiplicand y
   wire [P_WORD-1:0] 	    d_t;             // w bit output of memory for temporary data z

   wire [2:0]		    DSel;            // memory input select signal
   wire [2:0] 		    Cset_value;
   
   // key register
   key_register    KEY_REG (.CLK (CLK), 
			    .RSTn (RSTn),
			    .Kin (Kin),
			    .EnKey (EnKey), 
			    .KeyShift (KeyShift),
			    .CRT (CRT),
			    .MODE (MODE[0]),
			    .key_bit (key_bit));
   
   // sequencer
   sequencer_block SEQ_BLK (.CLK (CLK), 
			    .RSTn (RSTn), 
			    .EN (EN), 
			    .Krdy (Krdy), 
			    .Mrdy (Mrdy), 
			    .Drdy (Drdy), 
			    .CRT (CRT), 
			    .MODE (MODE),
			    .key_bit (key_bit),
			    .k_count (k_count),
			    .i_count (i_count),
			    .j_count (j_count),
			    .sign (sign),
			    .d_0 (d_0),
			    .BSY (BSY),
				.EnEnc(EXEC), 
			    .Kvld (Kvld), 
			    .Mvld (Mvld), 
			    .Dvld (Dvld), 
			    .EnKey (EnKey), 
			    .KeyShift (KeyShift), 
			    .MBCon (MBCon), 
			    .MemCon (MemCon), 
			    .CntCon (CntCon), 
			    .AdCon (AdCon),
			    .DSel (DSel),
			    .Cset_value (Cset_value));
   
   // counter 
   counter         CNT_BLK (.CLK (CLK),
			    .RSTn (RSTn), 
			    .CntCon (CntCon), 
			    .k_count (k_count), 
			    .i_count (i_count), 
			    .j_count (j_count),
			    .j_minus_1_count (j_minus_1_count),
			    .plus_1_count (plus_1_count));
   
   // memorys
   FF_arrays       MEMORYS (.CLK (CLK),
			    .RSTn (RSTn), 
			    .din (din), 
			    .MemCon (MemCon), 
			    .wad (wad), 
			    .ad_0 (ad_0), 
			    .ad_1 (ad_1), 
			    .ad_t (ad_t), 
			    .d_0 (d_0), 
			    .d_1 (d_1), 
			    .d_t (d_t));

   // address controller
   address_controller AD_GEN (.CRT (CRT),
			      .k_count (k_count[P_j_CNTLEN-1:0]),
			      .i_count (i_count[P_j_CNTLEN-1:0]), 
			      .j_count (j_count),
			      .j_minus_1_count (j_minus_1_count),
			      .plus_1_count (plus_1_count),
			      .AdCon (AdCon), 
			      .wad (wad), 
			      .ad_0 (ad_0), 
			      .ad_1 (ad_1), 
			      .ad_t (ad_t));

   // multiplicaiton block
   multiplication_block MB_BLK (.CLK (CLK),
				.RSTn (RSTn), 
				.MBCon (MBCon),
				.Cset_value (Cset_value),
				.d_0 (d_0), 
				.d_1 (d_1), 
				.d_t (d_t), 
				.dout (dout),
				.sign (sign));

   function [P_RADIX-1:0] din_select;
      input [P_RADIX-1:0] Min, Din, d_0, d_1, d_t, dout;
      input [2:0] Dsel;
      case (Dsel)
	3'b000: din_select = dout;
	3'b001: din_select = Min;
	3'b010: din_select = Din;
	3'b011: din_select = d_0;
	3'b100: din_select = d_1;
	3'b101: din_select = d_t;
	default: din_select = dout;
      endcase
   endfunction
   
   assign din = din_select(Min, Din, d_0, d_1, d_t, dout, DSel);
   assign Dout = d_0;
   
endmodule // top



module key_register ( CLK, RSTn, Kin, EnKey, KeyShift, CRT, MODE, key_bit );

   // global parameter
   parameter P_KLEN  = 512;  // key kength
   parameter P_RADIX = 32;   // radix size (r bit)
   parameter P_WORD  = 32;   // word size (w bit)
   parameter P_IBUS  = 32;   // interface bus width 

   // fixed number
   parameter P_KEY_ZERO = 512'h00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000;
   
   input              CLK, RSTn;
   input [P_IBUS-1:0] Kin;            // Key input
   input 	      EnKey;          // key input enable
   input 	      KeyShift;       // key shift enable
   input 	      CRT;            // CRT mode signal CRT=1 on / CRT=0 off
   input 	      MODE;           // MODE=0 left-to-right / MODE=1 right-to-left algorithm     
   output 	      key_bit;        // key bit output
   
   reg [P_KLEN-1:0]   Krg;            // key register

   always @(posedge CLK) begin
      if (RSTn == 1'b0)
	Krg <= P_KEY_ZERO;
      else if (EnKey == 1'b1)
	if  (CRT == 1'b1 && MODE == 1'b0)
	  Krg <= {Krg[P_IBUS-1:0], Krg[P_KLEN-1:P_KLEN/2+P_IBUS], Kin, Krg[P_KLEN/2-1:P_IBUS]};         
	else
	  Krg <= {Kin, Krg[P_KLEN-1:P_IBUS]};         
      else if (KeyShift == 1'b1)
	if (MODE == 1 'b0)         // key 1-bit left shift for left-to-right algorithm
	  Krg <= {Krg[P_KLEN-2:0], Krg[P_KLEN-1]};
	else         // MODE == 1'b1  key 1-bit right shift for right-to-left algorithm
	  Krg <= {Krg[0], Krg[P_KLEN-1:1]};
   end 
   
   assign key_bit = (MODE == 1'b0) ? Krg[P_KLEN-1] : Krg[0];
   
endmodule // key_register



module sequencer_block ( CLK, RSTn, EN, Krdy, Mrdy, Drdy, CRT, MODE, key_bit, k_count, i_count, j_count, sign, d_0, BSY, EnEnc, Kvld, Mvld, Dvld, EnKey, KeyShift, MBCon, MemCon, CntCon, AdCon, DSel, Cset_value);

   parameter P_RADIX = 32;   // radix size (r bit)
   
   // counter size parameter
   parameter P_k_CNTLEN = 9;  // k counter length 0-511
   parameter P_i_CNTLEN = 9;  // i counter length 0-511
   parameter P_j_CNTLEN = 4;  // j counter length 0-15

   // fixed number
   parameter P_j_ENDCNT = 4'hf;  // m-1 = 15
   parameter P_i_ENDCNT = 9'h017; // 23
      
   input                  CLK, RSTn;
   input 		  EN;                // chip enable signal
   input 		  Krdy, Mrdy, Drdy;  // key / modulo / plaintext data ready signal
   input 		  CRT;               // CRT mode signal CRT=1 on / CRT=0 off
   input [2:0] 		  MODE;              // modular exponentiation mode signal
   input 		  key_bit;           // exponent
   input [P_k_CNTLEN-1:0] k_count;           // k count value
   input [P_i_CNTLEN-1:0] i_count;           // i_count value
   input [P_j_CNTLEN-1:0] j_count;           // j_count value
   input 		  sign;              // sign qh(LSB) flag signal form multiplicaiton block
   input [P_RADIX-1:0] 	  d_0;
   output 		  BSY;               // busy signal
   output 		  EnEnc;               // execution signal
   output 		  Kvld, Mvld, Dvld;  // key / modulo / plaintext data valid signal
   output [2:0]		  DSel;              // select signals of  memory (FF arrays) input
   
   // control signals
   output 		  EnKey, KeyShift;   // control signals for key register
   output [20:0] 	  MBCon;             // control signals for multiplication block
   output [4:0] 	  MemCon;            // control signals for memory (FF arrays)
   output [8:0] 	  CntCon;            // control signals for counter
   output [18:0] 	  AdCon;             // control signals for memory address generator
   output [2:0]		  Cset_value;

   reg [2:0]    top_state;                   // top state
   reg 		dvldrg, kvldrg, mvldrg;      // valid register
   reg 		kvldrg_t, mvldrg_t;          // valid tmp register
   reg 		inU_state;
   
   wire 	EnEnc;                       // function enable   
   wire 	EncEnd;                      // encription end flag
   
   wire [20:0] 	MBCon_low;                   // control signals for multiplication block (from low-level function)
   wire [4:0] 	MemCon_low;                  // control signals for memory (FF arrays) (from low-level function)
   wire [8:0] 	CntCon_low;                  // control signals for counter (from low-level function)
   wire [18:0] 	AdCon_low;                   // control signals for memory address generator (from low-level function)
   wire [2:0]	DataMv;                      // control signal for data mv
   
   // top sequencer state parameter
   parameter IDLE     = 3'h0;
   parameter KEY_GET  = 3'h1;
   parameter MOD_GET  = 3'h2;
   parameter DATA_GET = 3'h3;
   parameter DATA_OUT = 3'h4;
   parameter ENCRYPT  = 3'h5;
   
   // top sequencer
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         top_state <= IDLE;
	 inU_state <= 1'b0;
         dvldrg <= 1'b0; kvldrg <= 1'b0; mvldrg <= 1'b0;
      end
      else if (EN == 1'b1) begin
	 case (top_state)
	   IDLE: begin
	      if (Krdy == 1'b1) begin
		 top_state <= KEY_GET;
		 dvldrg <= 1'b0; kvldrg <= 1'b0;
	      end
	      else if (Mrdy == 1'b1) begin
		 top_state <= MOD_GET;
		 dvldrg <= 1'b0;  mvldrg <= 1'b0;
	      end
	      else if (mvldrg == 1'b1 && kvldrg == 1'b1 && Drdy == 1'b1) begin
		 top_state <= DATA_GET;
		 dvldrg <= 1'b0;
	      end
	   end 
	   
	   KEY_GET:
	     if (j_count == P_j_ENDCNT) begin
		top_state <= IDLE;
		kvldrg <= 1'b1;
	     end
	   
	   MOD_GET: begin
	      if (j_count == P_j_ENDCNT) begin
		 if (CRT == 1'b0) begin
		    top_state <= IDLE;
		    mvldrg <= 1'b1;
		 end
		 else
		   inU_state <= 1'b1;
	      end
	      else if (inU_state == 1'b1)
		if (i_count == P_i_ENDCNT) begin
		   top_state <= IDLE;
		   mvldrg <= 1'b1;
		end
	   end
	   
	   DATA_GET: begin
	      if (j_count == P_j_ENDCNT) 
		 top_state <= ENCRYPT;
	   end

	   ENCRYPT: begin
	      if (EncEnd == 1'b1) begin
		 top_state <= DATA_OUT;
		 dvldrg <= 1'b1;
	      end
	   end

	   DATA_OUT: begin
	      if (dvldrg == 1'b1)
		 dvldrg <= 1'b0;
	      else if (j_count == P_j_ENDCNT)
		 top_state <= IDLE;
	   end

	   default: top_state <= IDLE;
	   
	 endcase
	 end 
   end 

   // control signals
   assign EnKey = (top_state == KEY_GET) ? 1'b1 : 1'b0;

   function [2:0] dsel_gen;
      input [2:0] top_state;
      input [2:0] DataMv;
      case (top_state)
	MOD_GET: dsel_gen = 3'b001;
	DATA_GET: dsel_gen = 3'b010;
	ENCRYPT: if (DataMv == 3'b100) dsel_gen = 3'b011;
	         else if (DataMv == 3'b010) dsel_gen = 3'b100;
	         else if (DataMv == 3'b001) dsel_gen = 3'b101;
	         else dsel_gen = 3'b000;
	default: dsel_gen = 3'b000;
      endcase
   endfunction 

   assign DSel = dsel_gen(top_state, DataMv);
   
   // {WtM, WtT, Rd0, Rd1, Rdt}   
   function [4:0] memcon_select_top;
      input [2:0] top_state;
      input dvldrg;
      input [4:0] MemCon_low;
      case (top_state)
	MOD_GET:  memcon_select_top = 5'b10000;
	DATA_GET: memcon_select_top = 5'b11000;
	ENCRYPT:  memcon_select_top = MemCon_low;
	DATA_OUT:          
	  if (dvldrg == 1'b1)
	    memcon_select_top = 5'b00000;
	  else
	    memcon_select_top = 5'b00100;
	default:  memcon_select_top = 5'b00000;
      endcase
   endfunction

   // {Rst_k, En_k, Rst_i, En_i, Rst_j, En_j, SelCNT}
   function [8:0] cntcon_select_top;
      input [2:0] top_state;
      input dvldrg;
      input [P_j_CNTLEN-1:0] j_count;
      input [8:0] CntCon_low;      
      case (top_state)
	KEY_GET, DATA_GET: 
	  if (j_count == P_j_ENDCNT)
	    cntcon_select_top = {4'b0000, 2'b10, 3'b000};
	  else
	    cntcon_select_top = {4'b0000, 2'b01, 3'b001};
	MOD_GET:
	  if (i_count == P_i_ENDCNT)
	    cntcon_select_top = {4'b0010, 2'b10, 3'b000};
	  else
	    cntcon_select_top = {4'b0001, 2'b01, 3'b010};
	ENCRYPT: cntcon_select_top = CntCon_low;
	DATA_OUT:          
	  if (dvldrg == 1'b1)
	    cntcon_select_top = {4'b0000, 2'b10, 3'b000};
	  else
	    if (j_count == P_j_ENDCNT)
	      cntcon_select_top = {4'b0000, 2'b10, 3'b000};
	    else
	      cntcon_select_top = {4'b0000, 2'b01, 3'b001};
	default: cntcon_select_top = 9'b000000000;
      endcase
   endfunction

   // {AdCon_w, AdCon_0, AdCon_1, AdCon_t}
   function [18:0] adcon_select_top;
      input [2:0] top_state;
      input [18:0] AdCon_low;
      input inU_state;
      case (top_state)
        MOD_GET:  
	  if (inU_state == 1'b1) 
	    adcon_select_top = {1'b1, AdCon_low[17:11], 3'b101, 8'b00000000};
	  else
	    adcon_select_top = {1'b1, AdCon_low[17:11], 3'b100, 8'b00000000};
	DATA_GET: adcon_select_top = {1'b0, AdCon_low[17:11], 3'b000, 8'b00000000};
	DATA_OUT: adcon_select_top = {1'b0, AdCon_low[17:11], 3'b000, 3'b010, 5'b00000};
        ENCRYPT:  adcon_select_top = AdCon_low;
        default:  adcon_select_top = {AdCon_low[18:11], 11'b00000000000};
      endcase
   endfunction

   assign MemCon = memcon_select_top(top_state, dvldrg, MemCon_low);
   assign CntCon = cntcon_select_top(top_state, dvldrg, j_count, CntCon_low);
   assign AdCon = adcon_select_top(top_state, AdCon_low, inU_state);
   assign MBCon = MBCon_low;

   assign EnEnc = (top_state == ENCRYPT) ? 1'b1 : 1'b0;

   // low-level sequencer 
   encription_sequencer ENC_SEQ ( CLK, RSTn, CRT, MODE, Drdy, EnEnc, key_bit, k_count, i_count, j_count, sign, d_0, MBCon_low, MemCon_low, CntCon_low, AdCon_low, KeyShift, DataMv, Cset_value, EncEnd );
   
   // outputs (BSY, EXECKvld, Mvld, Dvld)  
   assign BSY = (top_state != IDLE) ? 1'b1 : 1'b0; // busy signal

   always @(posedge CLK) begin // differential circuit for kvld signal 
      if (RSTn == 1'b0 || top_state == KEY_GET)
	kvldrg_t <= 1'b0;
      else
	kvldrg_t <= kvldrg_t | kvldrg;
   end
   assign Kvld = ~kvldrg_t & kvldrg; // key valid signal

   always @(posedge CLK) begin // differential circuit for mvld signal  
      if (RSTn == 1'b0 || top_state == MOD_GET)
	mvldrg_t <= 1'b0;
      else
	mvldrg_t <= mvldrg_t | mvldrg;
   end
   assign Mvld = ~mvldrg_t & mvldrg; // mod valid signal
   
   assign Dvld = dvldrg; // data valid signal
   
endmodule



module counter ( CLK, RSTn, CntCon, k_count, i_count, j_count, j_minus_1_count, plus_1_count );

   // counter size parameter
   parameter P_k_CNTLEN = 9;  // k counter length 0-511
   parameter P_i_CNTLEN = 9;  // i counter length 0-511
   parameter P_j_CNTLEN = 4;  // j counter length 0-15

   // fixed number
   parameter P_k_ZERO = 9'b000000000;
   parameter P_i_ZERO = 9'b000000000;
   parameter P_j_ZERO = 4'b0000;
   
   input                   CLK, RSTn;
   input [8:0] 		   CntCon;           // control signals for counter module
   output [P_k_CNTLEN-1:0] k_count;          // k count value
   output [P_i_CNTLEN-1:0] i_count;          // i count value
   output [P_j_CNTLEN-1:0] j_count;          // j count value
   output [P_j_CNTLEN-1:0] j_minus_1_count;  // j-1 count value
   output [P_j_CNTLEN-1:0] plus_1_count;     // +1 count value

   // count registers
   reg [P_k_CNTLEN-1:0]    k_count;
   reg [P_i_CNTLEN-1:0]    i_count;
   reg [P_j_CNTLEN-1:0]    j_count;
   reg [P_j_CNTLEN-1:0]    j_minus_1_count;

   // control signals 
   wire 		   Rst_k, Rst_i, Rst_j;  // reset
   wire 		   En_k, En_i, En_j;     // enable
   wire [2:0] 		   SelCnt;               // select
   
   wire [P_k_CNTLEN-1:0]   count_in;   // count adder input 
   wire [P_k_CNTLEN:0] 	   count_out;  // count adder output

   // k count register
   always @(posedge CLK) begin
      if (!RSTn)        k_count <= P_k_ZERO; 
      else if (Rst_k)	k_count <= P_k_ZERO; 
      else if (En_k)	k_count <= count_out[P_k_CNTLEN-1:0];
      else              k_count <= k_count;
   end

   // i count register
   always @(posedge CLK) begin
      if (!RSTn)       i_count <= P_i_ZERO;
      else if (Rst_i)  i_count <= P_i_ZERO;
      else if (En_i)   i_count <= count_out[P_i_CNTLEN-1:0];
      else             i_count <= i_count;
   end 

   // j count register
   always @(posedge CLK) begin
      if (!RSTn)       j_count <= P_j_ZERO;
      else if (Rst_j)  begin 
	 j_count <= P_j_ZERO;
	 j_minus_1_count <= P_j_ZERO;
      end
      else if (En_j)   begin
	 j_count <= count_out[P_j_CNTLEN-1:0];
	 j_minus_1_count <= j_count;
      end
      else begin 
	 j_count <= j_count;
	 j_minus_1_count <= j_minus_1_count;
      end
   end
   
   // function for counter input
   function [P_k_CNTLEN-1:0] count_selector;
      input [P_k_CNTLEN-1:0] k_count;
      input [P_i_CNTLEN-1:0] i_count;
      input [P_j_CNTLEN-1:0] j_count;
      input [2:0] SelCNT;
      case (SelCNT)
	3'b100: count_selector = k_count;
	3'b010: count_selector = i_count;  
       	3'b001: count_selector = j_count;  // {5'b00000, j_count}
	default: count_selector = j_count; // {5'b00000, j_count}
      endcase
   endfunction // count_selector

   assign {Rst_k, En_k, Rst_i, En_i, Rst_j, En_j, SelCnt} = CntCon;
   assign count_in = count_selector(k_count, i_count, j_count, SelCnt);

   assign count_out = count_in + 1;
   
   assign plus_1_count = count_out[P_j_CNTLEN-1:0];
   
endmodule


// case r = w 
module FF_arrays ( CLK, RSTn, din, MemCon, wad, ad_0, ad_1, ad_t, d_0, d_1, d_t );

   // global parameter
   parameter P_RADIX = 32;  // radix size (r bit)
   parameter P_WORD = 32;   // word size (w bit)

   // memory & address size parameter 
   parameter P_MAIN_MEM_SIZE = 128;  // 16 * 5  16 = 512/32
   parameter P_TEM_MEM_SIZE = 16;   // 16 * 1
   parameter P_MAIN_AD_BIT = 7;     // 0-127   
   parameter P_TMP_AD_BIT = 4;      // 0-15

   // fixed number
   parameter P_r_FFFF =  32'hffffffff;  // radix size zero
     
   input                     CLK, RSTn;
   input [P_RADIX-1:0] 	     din;              // r bit input 
   input [4:0] 		     MemCon;           // control signals for register array
   input [P_MAIN_AD_BIT-1:0] wad, ad_0, ad_1;  // write & read addresses of main register arrary
   input [P_TMP_AD_BIT-1:0]  ad_t;             // read address of temporary register array
   output [P_RADIX-1:0]      d_0;              // r bit output for multiplier x
   output [P_WORD-1:0] 	     d_1;              // w bit output for multiplicand y
   output [P_WORD-1:0] 	     d_t;              // w bit output for temporary data z

   reg [P_RADIX-1:0] 	     MrgAry [0:P_MAIN_MEM_SIZE-1];  // main register array
   reg [P_RADIX-1:0] 	     TrgAry [0:P_TEM_MEM_SIZE-1];   // temporary register array
   
   wire 		     WtM, WtT, Rd0, Rd1, Rdt;  // control signals
   wire [P_TMP_AD_BIT-1:0]   wad_t;                    // write address of temporary register  
      
   assign {WtM, WtT, Rd0, Rd1, Rdt} = MemCon;
   assign wad_t = wad[P_TMP_AD_BIT-1:0];

   always @(posedge CLK) begin
      if (WtM)
	MrgAry[wad] <= din;
   end
   
   always @(posedge CLK) begin
      if (WtT)
	TrgAry[wad_t] <= din;
   end

   assign d_0 = (Rd0) ? MrgAry[ad_0]: P_r_FFFF;
   assign d_1 = (Rd1) ? MrgAry[ad_1]: P_r_FFFF;
   assign d_t = (Rdt) ? TrgAry[ad_t]: P_r_FFFF;

endmodule // FF_arrays


module address_controller ( CRT, k_count, i_count, j_count, j_minus_1_count, plus_1_count, AdCon, wad, ad_0, ad_1, ad_t );

   // counter size parameter
   parameter P_k_CNTLEN = 9;  // k counter length 0-511
   parameter P_j_CNTLEN = 4;  // j counter length 0-15

   // address size parameter
   parameter P_MAIN_AD_BIT = 7;     // 0-127   
   parameter P_TMP_AD_BIT = 4;      // 0-15

   // fixed address
   parameter P_W_ADDRESS = 7'b1000000;   // 64 W
   parameter P_t_ADDRESS = 7'b1000001;   // 65 t
   parameter P_V_ADDRESS = 7'b1000010;   // 66 V
   parameter P_MAIN_AD_BITSIZE_ZERO = 7'b0000000;
   parameter P_TMP_AD_BITSIZE_ZERO = 4'b0000;
   parameter P_R_NUM = 4'b1001;          // r = a - b + 1

   // fixed number
   parameter P_j_ENDCNT = 4'hf;         // l-1 = 15
   parameter P_CRT_j_ENDCNT = 4'h7;     // (1/2)l-1 = 7
   parameter P_CRT_j_ENDCNT_M = 4'h8;   // msb 8

   input                  CRT;
   input [P_j_CNTLEN-1:0] k_count;                   // k count value (j size)
   input [P_j_CNTLEN-1:0] i_count;                   // i count value (j size)
   input [P_j_CNTLEN-1:0] j_count, j_minus_1_count;  // j count value
   input [P_j_CNTLEN-1:0] plus_1_count;              // count + 1
   input [18:0] 	  AdCon;                     // control signals for memory address controller          
   
   output [P_MAIN_AD_BIT-1:0] wad, ad_0, ad_1;       // write & read addresses of main register arrary
   output [P_TMP_AD_BIT-1:0]  ad_t;                  // read addresses of temporary register arrary

   wire [2:0] 	  MemMap;                            // memory map state 000: XYT, 001:XTY, 010:YXT, 011:YTX, 100:TXY, 101:TYX
   wire 	  SquareOn, DummyOn;                 // squaring $ dummy multiplicaiton activate signals
   wire [2:0] 	  AdCon_w, AdCon_0, AdCon_1;         // control signals
   wire [1:0] 	  AdCon_t;                           // control signal

   wire 	  j_cntend_true, j_cntend_m_true;

   wire [2:0] 	  x_region, y_region, z_region;

   wire 	  ZZSet, QAct, CAd;

   wire [P_j_CNTLEN-1:0] i_plus_j, i_plus_j_1, r_plus_j_count;
   
   assign i_plus_j = i_count + j_count;
   assign i_plus_j_1 = i_plus_j + 1;
   assign r_plus_j_count = j_count + P_R_NUM;

   assign {CAd, ZZSet, QAct, MemMap, DummyOn, SquareOn, AdCon_w, AdCon_0, AdCon_1, AdCon_t} = AdCon;

   assign j_cntend_true = (CRT) ? (j_count == P_CRT_j_ENDCNT) : (j_count == P_j_ENDCNT);
   assign j_cntend_m_true = (j_count == P_CRT_j_ENDCNT_M);

   function [2:0] x_region_detector;
      input [2:0] MemMap;
      case (MemMap)
	3'b000, 3'b001: x_region_detector = 3'b000;
	3'b010, 3'b100: x_region_detector = 3'b001;
	3'b011, 3'b101: x_region_detector = 3'b010;
	default: x_region_detector = 3'b000;
      endcase
   endfunction // x_region_detector

   function [2:0] y_region_detector;
      input [2:0] MemMap;
      case (MemMap)
	3'b010, 3'b011: y_region_detector = 3'b000;
	3'b000, 3'b101: y_region_detector = 3'b001;
	3'b001, 3'b100: y_region_detector = 3'b010;
	default: y_region_detector = 3'b010;
      endcase
   endfunction // y_region_detector

   function [2:0] z_region_detector;
      input [2:0] MemMap;
      case (MemMap)
	3'b100, 3'b101: z_region_detector = 3'b000;
	3'b001, 3'b011: z_region_detector = 3'b001;
	3'b000, 3'b010: z_region_detector = 3'b010;
	default: z_region_detector = 3'b010;
      endcase
   endfunction // z_region_detector

   assign x_region = x_region_detector(MemMap);
   assign y_region = y_region_detector(MemMap);
   assign z_region = z_region_detector(MemMap);
   
   // wad generator
   function [P_MAIN_AD_BIT-1:0] wad_generator;
      input [P_j_CNTLEN-1:0] j_count, j_minus_1_count, i_plus_j;
      input [2:0] x_region, y_region, z_region;
      input QAct, DummyOn;
      input [3:0] AdCon;
      case ({QAct, AdCon}) 
	5'b00000: if (DummyOn) wad_generator = {z_region, j_count};     // 16-31  zj      -Z dummy out 
                 else         wad_generator = {x_region, j_count};      // 0-15   zj      -Z 
  	5'b00001: wad_generator = {z_region, j_minus_1_count};          // 16-31  z(j-1)  +Z
	5'b00010: wad_generator = {z_region, j_count};                  // 16-31  zj      +Z 
	5'b00011: wad_generator = {y_region, j_count};                  // 32-47  yj
	5'b00100, 5'b10100: wad_generator = {z_region, i_plus_j};       // 0-16  z(i+j)
	5'b01000, 5'b11000: wad_generator = {3'b000, j_count}; // xj
	5'b01001, 5'b11001: wad_generator = {3'b001, j_count}; // tj
	5'b01010, 5'b11010: wad_generator = {3'b010, j_count}; // yj
	5'b01100, 5'b11100: wad_generator = {3'b011, j_count}; // nj
	5'b01101, 5'b11101: wad_generator = {3'b100, 1'b1, j_count[P_j_CNTLEN-2:0]}; // U
	5'b01110, 5'b01110: wad_generator = {3'b000, 1'b1, j_count[P_j_CNTLEN-2:0]}; // 8-15
	5'b10000: if (DummyOn) wad_generator = {z_region, 1'b1, j_count[P_j_CNTLEN-2:0]};  // 24-31  zj      -Z dummy out 
                  else         wad_generator = {x_region, 1'b1, j_count[P_j_CNTLEN-2:0]};  // 8-15   zj      -Z 
	5'b10001: wad_generator = {z_region, 1'b1, j_minus_1_count[P_j_CNTLEN-2:0]};       // 24-31  z(j-1)  +Z
	5'b10010: wad_generator = {z_region, 1'b1, j_count[P_j_CNTLEN-2:0]};               // 24-31  zj      +Z 
	5'b10011: wad_generator = {y_region, 1'b1, j_count[P_j_CNTLEN-2:0]};               // 40-47  yj
	5'b00101, 5'b10101: wad_generator = P_W_ADDRESS;                // 64 W
	5'b00110, 5'b10110: wad_generator = P_t_ADDRESS;                // 65 t
	5'b00111, 5'b10111: wad_generator = P_V_ADDRESS;                // 66 V
	default: wad_generator = P_MAIN_AD_BITSIZE_ZERO;
      endcase // 
   endfunction // wad_generator

   function [P_MAIN_AD_BIT-1:0] ad_0_generator;  // x, t
      input [P_j_CNTLEN-1:0] k_count, i_count, plus_1_count, r_plus_j_count;
      input [2:0] x_region;
      input ZZSet, QAct;
      input [2:0] AdCon;
      if (ZZSet)
	case (k_count)
	  4'h8: ad_0_generator = 7'h00;
	  4'h7: ad_0_generator = 7'h01;
	  4'h6: ad_0_generator = 7'h02;
	  4'h5: ad_0_generator = 7'h03;
	  4'h4: ad_0_generator = 7'h04;
	  4'h3: ad_0_generator = 7'h05;
	  4'h2: ad_0_generator = 7'h06;
	  4'h1: ad_0_generator = 7'h07;
	  4'h0: ad_0_generator = 7'h08;
	endcase 
      else
	case ({QAct, AdCon})
	  4'b0000: ad_0_generator = {x_region, i_count};        // 0-15  xi
	  4'b0001: ad_0_generator = {x_region, plus_1_count};   // 1-15  x(i+1) SelCnt=010 (i)
	  4'b0010: ad_0_generator = {x_region, j_count};        // 0-15  xj
	  4'b0011: ad_0_generator = {x_region, plus_1_count};   // 1-15  x(j+1) SelCnt=001 (j)
	  4'b1000: ad_0_generator = {x_region, 1'b1, i_count[P_j_CNTLEN-2:0]};        // 8-15  xi
	  4'b1001: ad_0_generator = {x_region, 1'b1, plus_1_count[P_j_CNTLEN-2:0]};   // 9-16  x(i+1) SelCnt=010 (i)
	  4'b1010: ad_0_generator = {x_region, 1'b1, j_count[P_j_CNTLEN-2:0]};        // 8-15  xj
	  4'b1011: ad_0_generator = {x_region, 1'b1, plus_1_count[P_j_CNTLEN-2:0]};   // 9-16  x(j+1) SelCnt=001 (j)
	  4'b0100, 4'b1100: ad_0_generator = {x_region, r_plus_j_count}; // 0-15  x(9+j) x(1+j) for modulo data_mv 
	  4'b0110, 4'b1110: ad_0_generator = P_t_ADDRESS;       // 65 t
	  default: ad_0_generator = P_MAIN_AD_BITSIZE_ZERO;
	endcase // 
   endfunction // ad0_generator
   
   function [P_MAIN_AD_BIT-1:0] ad_1_generator;  // y, n, W, V    
      input [P_j_CNTLEN-1:0] j_count, plus_1_count;
      input [2:0] x_region, y_region;
      input QAct, SquareOn;
      input [2:0] ADCon;
      case ({QAct, ADCon})
	4'b0000: if (SquareOn) ad_1_generator = {x_region, j_count};    // 0-15   yj (squaring)
	         else          ad_1_generator = {y_region, j_count};    // 32-47  yj
	4'b0001: if (SquareOn)
	           ad_1_generator = (j_cntend_true) ? {x_region, P_TMP_AD_BITSIZE_ZERO} : {x_region, plus_1_count};   // 0-15  y(j+1) SelCnt=001 (j) (squaring)
	         else
		   ad_1_generator = (j_cntend_true) ? {y_region, P_TMP_AD_BITSIZE_ZERO} : {y_region, plus_1_count};   // 33-47  y(j+1) SelCnt=001 (j)
	4'b0010: ad_1_generator = {3'b011, j_count};                    // 48-63  nj
	4'b0011: ad_1_generator = (j_cntend_true) ? {3'b011, P_TMP_AD_BITSIZE_ZERO} : {3'b011, plus_1_count};        // 48-63  n(j+1) SelCnt=001 (j)
	4'b0100: ad_1_generator = (j_cntend_m_true) ? {3'b100, 1'b1, 3'b000} : {3'b100, 1'b1, plus_1_count[P_j_CNTLEN-2:0]};  // u(j+1)
	4'b0110: ad_1_generator = (j_cntend_m_true) ? {3'b100, 1'b1, 3'b000} : {3'b100, 1'b1, j_count[P_j_CNTLEN-2:0]};  // u(j)
	4'b1000: if (SquareOn) ad_1_generator = {x_region, 1'b1, j_count[P_j_CNTLEN-2:0]};    // 0-15   yj (squaring)
                 else          ad_1_generator = {y_region, 1'b1, j_count[P_j_CNTLEN-2:0]};    // 32-47  yj
	4'b1001: if (SquareOn)
	          ad_1_generator = (j_cntend_true) ? {x_region, 1'b1, 3'b000} : {x_region, 1'b1, plus_1_count[P_j_CNTLEN-2:0]};   // 0-15  y(j+1) SelCnt=001 (j) (squaring)
	         else
		  ad_1_generator = (j_cntend_true) ? {y_region, 1'b1, 3'b000} : {y_region, 1'b1, plus_1_count[P_j_CNTLEN-2:0]};   // 33-47  y(j+1) SelCnt=001 (j)
	4'b1010: ad_1_generator = {3'b011, 1'b1, j_count[P_j_CNTLEN-2:0]};          // 48-63  nj
	4'b1011: ad_1_generator = (j_cntend_true) ? {3'b011, 1'b1, 3'b000} : {3'b011, 1'b1, plus_1_count[P_j_CNTLEN-2:0]};        // 48-63  n(j+1) SelCnt=001 (j)
	4'b0101, 4'b1101: ad_1_generator = P_W_ADDRESS;                // 64 W
	4'b0111, 4'b1111: ad_1_generator = P_V_ADDRESS;                // 66 V
	default: ad_1_generator = P_MAIN_AD_BITSIZE_ZERO;
      endcase // case(ADCon)
   endfunction // ad1_generator
   
   function [P_TMP_AD_BIT-1:0] ad_t_generator;
      input [P_j_CNTLEN-1:0] j_count, plus_1_count, i_plus_j;
      input QAct;
      input [1:0] ADCon;
      case ({QAct, ADCon})
	3'b000: ad_t_generator = (j_cntend_true) ? P_TMP_AD_BITSIZE_ZERO : plus_1_count;   // 1-15  z(j+1) SelCnt=001 (j)
	3'b001: ad_t_generator = j_count;                     // 0-15  zj
	3'b010: ad_t_generator = P_TMP_AD_BITSIZE_ZERO;       // z0
	3'b011: ad_t_generator = (j_cntend_m_true) ? plus_1_count : i_plus_j_1;   // z(i+1) , z(i+j+1)
	3'b100: ad_t_generator = (j_cntend_true) ? {1'b1, 3'b000} : {1'b1, plus_1_count[P_j_CNTLEN-2:0]};   // 1-15  z(j+1) SelCnt=001 (j)
	3'b101: ad_t_generator = {1'b1, j_count[P_j_CNTLEN-2:0]};  // 0-15  zj
	3'b110: ad_t_generator = {1'b1, 3'b000};       // z0
	default: ad_t_generator = P_TMP_AD_BITSIZE_ZERO;
      endcase // case(ADCon)
   endfunction // ad_t_generator

   // memory addresses
   assign wad = wad_generator(j_count, j_minus_1_count, i_plus_j, x_region, y_region, z_region, QAct, DummyOn, {CAd, AdCon_w});
   assign ad_0 = ad_0_generator(k_count, i_count, plus_1_count, r_plus_j_count, x_region, ZZSet, QAct, AdCon_0);
   assign ad_1 = ad_1_generator(j_count, plus_1_count, x_region, y_region, QAct, SquareOn, AdCon_1);
   assign ad_t = ad_t_generator(j_count, plus_1_count, i_plus_j, QAct, AdCon_t);
   
endmodule // address_controller



module encription_sequencer ( CLK, RSTn, CRT, MODE, Drdy, EnEnc, key_bit, k_count, i_count, j_count, sign, d_0, MBCon, MemCon, CntCon, AdCon, KeyShift, DataMv, Cset_value, EncEnd );

   parameter P_RADIX = 32;   // radix size (r bit)
   
   // counter parameter
   parameter P_k_CNTLEN = 9;  // k counter length 0-511
   parameter P_i_CNTLEN = 9;  // i counter length 0-511
   parameter P_j_CNTLEN = 4;  // j counter length 0-15

   input                  CLK, RSTn;
   input 		  CRT;
   input [2:0] 		  MODE;
   input 		  Drdy;
   input 		  EnEnc;      // encrition enable
   input 		  key_bit;    // exponent
   input [P_k_CNTLEN-1:0] k_count;    // k count value
   input [P_i_CNTLEN-1:0] i_count;    // i count value
   input [P_j_CNTLEN-1:0] j_count;    // j count value
   input 		  sign;       // sign qh(LSB)
   input [P_RADIX-1:0] 	  d_0;        // r bit output of memory for multiplier x
   output [20:0] 	  MBCon;      // control signals for multiplication block
   output [8:0] 	  CntCon;     // control signals for counter module
   output [4:0] 	  MemCon;     // control signals for register array
   output [18:0] 	  AdCon;      // control signals for memory address generator
   output 		  KeyShift;   // control signal for key shift
   output [2:0]		  DataMv;     // control singal for data mv
   output [2:0]		  Cset_value;
   output 		  EncEnd;     // encription end flag

   reg [4:0] 	enc_state;
   
   wire 	EnModExp, EnCRTPreProcessing, EnModSub, EnMult, EnMultiAdd;       // function enable
   wire 	EnModulo, EnDataMvZp, EnDataMvZq, EnDataMvT1, EnDataMvT2;         // function enable
   wire 	EnDataMvZq2, EnDataMvAns, EnDataMvNq;                             // function enable
   wire 	ModExpEnd, CRTPreProcessingEnd, ModSubEnd, MultEnd, MultiAddEnd;  // function end flag
   wire 	ModuloEnd, DataMvEnd;                                             // function end flag
   
   wire [20:0]  MBCon_ModExp, MBCon_Modulo, MBCon_ModSub;         // control signals for multiplication block (from low-level function)
   wire [20:0]  MBCon_Mult;                                       // control signals for multiplication block (from low-level function)
   wire [4:0] 	MemCon_ModExp, MemCon_Modulo, MemCon_ModSub;      // control signals for memory (FF arrays) (from low-level function)
   wire [4:0] 	MemCon_Mult;                                      // control signals for memory (FF arrays) (from low-level function)
   wire [8:0]   CntCon_ModExp, CntCon_Modulo;                     // control signals for counter (from low-level function)
   wire [5:0] 	CntCon_ModSub, CntCon_Mult;                       // control signals for counter (from low-level function)
   wire [15:0]  AdCon_ModExp;                                     // control signals for memory address generator (from low-level function)
   wire [11:0]  AdCon_Modulo;                                     // control signals for memory address generator (from low-level function)
   wire [10:0] 	AdCon_ModSub, AdCon_Mult;                         // control signals for memory address generator (from low-level function)
   wire [15:0]	AdCon_t;                                          // temporary wire
   wire 	DataMv_Modulo;
   
   wire 	QAct;
   
   // Non-CRT fixed number
   parameter P_k_ENDCNT = 9'h1ff;   // k-1 = 511
   parameter P_i_ENDCNT = 9'h00f;   // m-1 = 15
   parameter P_j_ENDCNT = 4'hf;     // l-1 = 15
   parameter P_i_ZERO   = 9'h000;     // 0
   parameter P_j_ZERO   = 4'h0;     // 0
   parameter P_r_MINUS_2 = 9'h01e;  // r-2 = 32 - 2 = 30
   parameter P_m_MINUS_2 = 4'he;    // m-2
   parameter P_i_ENDCNT_L = 9'h1ff; // m*r-1 = 511
   parameter P_k_ENDCNT_S = 9'h009;   // 9
   parameter P_i_ENDCNT_W = 9'h01f;  // 31 wordsize
   // CRT fixed number
   parameter P_CRT_k_ENDCNT = 9'h0ff;   // (1/2)k-1 = 255
   parameter P_CRT_i_ENDCNT = 9'h007;   // (1/2)m-1 = 7
   parameter P_CRT_j_ENDCNT = 4'h7;     // (1/2)l-1 = 7
   parameter P_CRT_m_MINUS_2 = 4'h6;    // (1/2)m-2 = 6
   parameter P_CRT_i_ENDCNT_L = 9'h0ff; // (1/2)m*r-1 = 255
   
   
   // conditional branching parameters
   wire [10:0] param;
   wire       k_cntend_true;
   wire       i_cntend_true;
   wire       j_cntend_true;
   wire       i_cntzero_true;
   wire       j_cntzero_true;
   wire       i_cntend_s_true;
   wire       i_cntend_l_true;
   wire       j_cntend_s_true;
   wire       k_cntend_s_true;
   wire       i_cntend_w_true;
   wire       j_cntend_dl_true;

   assign k_cntend_true = (CRT) ? (k_count == P_CRT_k_ENDCNT) : (k_count == P_k_ENDCNT);
   assign i_cntend_true = (CRT) ? (i_count == P_CRT_i_ENDCNT) : (i_count == P_i_ENDCNT);
   assign j_cntend_true = (CRT) ? (j_count == P_CRT_j_ENDCNT) : (j_count == P_j_ENDCNT);
   assign i_cntzero_true = (i_count == P_i_ZERO);
   assign j_cntzero_true = (j_count == P_j_ZERO);
   assign i_cntend_s_true = (i_count == P_r_MINUS_2);
   assign i_cntend_l_true = (CRT) ? (i_count == P_CRT_i_ENDCNT_L) : (i_count == P_i_ENDCNT_L);
   assign j_cntend_s_true = (CRT) ? (j_count == P_CRT_m_MINUS_2) : (j_count == P_m_MINUS_2);
   assign k_cntend_s_true = (k_count == P_k_ENDCNT_S);
   assign i_cntend_w_true = (i_count == P_i_ENDCNT_W);
   assign j_cntend_dl_true = (j_count == P_j_ENDCNT);
   assign param = {j_cntend_dl_true, i_cntend_w_true, k_cntend_s_true, k_cntend_true, i_cntend_true, j_cntend_true, i_cntzero_true, j_cntzero_true, 
		   i_cntend_s_true, i_cntend_l_true, j_cntend_s_true};

   // encription state
   parameter ENC_INIT = 5'h00;
   // Non-CRT
   parameter ENC_NONCRT_MODEXP = 5'h01;
   // CRT
   parameter ENC_CRT_MODULO_NP = 5'h02;        // Xp = X mod Np
   parameter ENC_CRT_MODULO_NQ = 5'h03;        // Xq = X mod Nq
   parameter ENC_CRT_MODEXP_P = 5'h04;         // Zp = Xp^Ep mod Np
   parameter ENC_CRT_DATAMV_ZP = 5'h05;        // Zp
   parameter ENC_CRT_MODEXP_Q = 5'h06;         // Zq = Xq^Eq mod Nq
   parameter ENC_CRT_DATAMV_ZQ = 5'h07;        // Zq 
   parameter ENC_CRT_MODSUB = 5'h08;           // T = (Zp - Zq) mod Np
   parameter ENC_CRT_MULT = 5'h09;             // T = T * U
   parameter ENC_CRT_DATAMV_T_TO_M_T1 = 5'h0a; // T Tmp -> Main 
   parameter ENC_CRT_MODULO_T = 5'h0b;         // T = T mod Np
   parameter ENC_CRT_DATAMV_T_TO_M_T2 = 5'h0c; // T Tmp -> Main
   parameter ENC_CRT_DATAMV_M_TO_T_ZQ = 5'h0d; // Zq Main -> Tmp
   parameter ENC_CRT_DATAMV_M_TO_M_NQ = 5'h0e; // Nq Main -> Tmp
   parameter ENC_CRT_MULTIADD = 5'h0f;         // Z = Zq + T * Nq
   parameter ENC_CRT_DATAMV_T_TO_M_ANS = 5'h10;// ANS Tmp -> Main
   
   parameter ENC_END = 5'h11;

   // encription sequencer
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         enc_state <= ENC_INIT;
      end
      else if (EnEnc == 1'b1) begin
         case (enc_state)
	   ENC_INIT: begin
	      if (CRT == 1'b0) enc_state <= ENC_NONCRT_MODEXP;   // non-CRT mode
	      else             enc_state <= ENC_CRT_MODULO_NP;   // CRT mode
	   end

	   // non-CRT 
	   ENC_NONCRT_MODEXP: if (ModExpEnd == 1'b1) enc_state <= ENC_END; 

	   // CRT
	   ENC_CRT_MODULO_NP:        if (ModuloEnd == 1'b1)   enc_state <= ENC_CRT_MODULO_NQ;
	   ENC_CRT_MODULO_NQ:        if (ModuloEnd == 1'b1)   enc_state <= ENC_CRT_MODEXP_P;
	   ENC_CRT_MODEXP_P:         if (ModExpEnd == 1'b1)   enc_state <= ENC_CRT_DATAMV_ZP;
	   ENC_CRT_DATAMV_ZP:        if (j_cntend_true)       enc_state <= ENC_CRT_MODEXP_Q;
	   ENC_CRT_MODEXP_Q:         if (ModExpEnd == 1'b1)   enc_state <= ENC_CRT_DATAMV_ZQ;
	   ENC_CRT_DATAMV_ZQ:        if (j_cntend_true)       enc_state <= ENC_CRT_MODSUB;
	   ENC_CRT_MODSUB:           if (ModSubEnd == 1'b1)   enc_state <= ENC_CRT_MULT;
	   ENC_CRT_MULT:             if (MultEnd == 1'b1)     enc_state <= ENC_CRT_DATAMV_T_TO_M_T1;
	   ENC_CRT_DATAMV_T_TO_M_T1: if (j_cntend_dl_true)    enc_state <= ENC_CRT_MODULO_T;
	   ENC_CRT_MODULO_T:         if (ModuloEnd == 1'b1)   enc_state <= ENC_CRT_DATAMV_T_TO_M_T2;
	   ENC_CRT_DATAMV_T_TO_M_T2: if (j_cntend_true)       enc_state <= ENC_CRT_DATAMV_M_TO_T_ZQ;
	   ENC_CRT_DATAMV_M_TO_T_ZQ: if (j_cntend_true)       enc_state <= ENC_CRT_DATAMV_M_TO_M_NQ;
	   ENC_CRT_DATAMV_M_TO_M_NQ: if (j_cntend_true)       enc_state <= ENC_CRT_MULTIADD;
	   ENC_CRT_MULTIADD:         if (MultEnd == 1'b1)     enc_state <= ENC_CRT_DATAMV_T_TO_M_ANS;
	   ENC_CRT_DATAMV_T_TO_M_ANS:if (j_cntend_dl_true)    enc_state <= ENC_END; 
	   
	   ENC_END: enc_state <= ENC_INIT;
	   default: enc_state <= enc_state;
	 endcase
      end
   end
   
   // control signals    
   assign QAct = (enc_state == ENC_CRT_MODEXP_Q || enc_state == ENC_CRT_MODULO_NQ || enc_state == ENC_CRT_DATAMV_ZQ || 
		  enc_state == ENC_CRT_DATAMV_M_TO_M_NQ) ? 1'b1 : 1'b0;
   assign DataMv[2] = DataMv_Modulo | EnDataMvZp | EnDataMvZq;  // d_0
   assign DataMv[1] = EnDataMvZq2 | EnDataMvNq; // d_1
   assign DataMv[0] = EnDataMvT1 | EnDataMvT2 | EnDataMvAns; // d_t

   assign DataMvEnd = (((enc_state == ENC_CRT_DATAMV_ZP) || (enc_state == ENC_CRT_DATAMV_ZQ)) && (j_cntend_true == 1'b1)) ? 1'b1 : 1'b0;
   
   assign MBCon = (EnModExp) ? MBCon_ModExp : 
		  (EnModulo) ? MBCon_Modulo : 
		  (EnModSub) ? MBCon_ModSub : 
		  (EnMult | EnMultiAdd) ? MBCon_Mult : MBCon_ModExp;
   assign MemCon = (EnModExp) ? MemCon_ModExp :
		   (EnModulo) ? MemCon_Modulo : 
		   (EnDataMvZp | EnDataMvZq) ? 5'b10100 :
		   (EnDataMvT1 | EnDataMvT2 | EnDataMvAns) ? 5'b10001 :
		   (EnDataMvZq2) ? 5'b01010 :
		   (EnDataMvNq) ? 5'b10010 :
		   (EnModSub) ? MemCon_ModSub : 
		   (EnMult | EnMultiAdd) ? MemCon_Mult : MemCon_ModExp;
   assign CntCon = (EnModExp) ? CntCon_ModExp : 
		   (EnModulo) ? CntCon_Modulo : 
		   (EnDataMvZp | EnDataMvZq | EnDataMvT2 | EnDataMvZq2 | EnDataMvNq) ? (j_cntend_true) ? 9'b001010000 : 9'b000001001 :
		   (EnDataMvT1 | EnDataMvAns) ? (j_cntend_dl_true) ? 9'b001010000 : 9'b000001001 :
		   (EnModSub) ? {2'b00, CntCon_ModSub[5:2], 1'b0, CntCon_ModSub[1:0]} : 
		   (EnMult | EnMultiAdd) ? {2'b00, CntCon_Mult[5:2], 1'b0, CntCon_Mult[1:0]} : CntCon_ModExp; 
   assign AdCon_t = (EnModExp) ? AdCon_ModExp :
		    (EnModulo) ? {AdCon_ModExp[15:11], AdCon_Modulo[10:0]} : 
		    (EnDataMvZp) ? {AdCon_ModExp[15:11], 11'b00001000000} : 
		    (EnDataMvZq) ? {AdCon_ModExp[15:11], 11'b01001000000} :
		    (EnDataMvT1 | EnDataMvT2 | EnDataMvAns) ? {AdCon_ModExp[15:11], 11'b00000000001} :
		    (EnDataMvZq2) ? {AdCon_ModExp[15:11], 11'b00000000000} :
		    (EnDataMvNq) ? {AdCon_ModExp[15:11], 11'b01000001000} :
		    (EnModSub) ? {AdCon_ModExp[15:11], AdCon_ModSub} :
		    (EnMult | EnMultiAdd) ? {AdCon_ModExp[15:11], AdCon_Mult}: AdCon_ModExp;
   assign AdCon = {(EnDataMvZp | EnDataMvZq | EnDataMvNq), AdCon_Modulo[11], QAct, AdCon_t};
   
   assign EnDataMvZp = (enc_state == ENC_CRT_DATAMV_ZP) ? 1'b1 : 1'b0;
   assign EnDataMvZq = (enc_state == ENC_CRT_DATAMV_ZQ) ? 1'b1 : 1'b0;
   assign EnModExp = (enc_state == ENC_NONCRT_MODEXP || enc_state == ENC_CRT_MODEXP_P || enc_state == ENC_CRT_MODEXP_Q) ? 1'b1 : 1'b0;
   assign EnModSub = (enc_state == ENC_CRT_MODSUB) ? 1'b1 : 1'b0;
   assign EnMult = (enc_state == ENC_CRT_MULT) ? 1'b1 : 1'b0;
   assign EnMultiAdd = (enc_state == ENC_CRT_MULTIADD) ? 1'b1 : 1'b0;
   assign EnModulo = (enc_state == ENC_CRT_MODULO_NP || enc_state == ENC_CRT_MODULO_NQ || enc_state == ENC_CRT_MODULO_T) ? 1'b1 : 1'b0;
   assign EnDataMvT1 = (enc_state == ENC_CRT_DATAMV_T_TO_M_T1) ? 1'b1 : 1'b0;
   assign EnDataMvT2 = (enc_state == ENC_CRT_DATAMV_T_TO_M_T2) ? 1'b1 : 1'b0;
   assign EnDataMvZq2 = (enc_state == ENC_CRT_DATAMV_M_TO_T_ZQ) ? 1'b1 : 1'b0;
   assign EnDataMvNq = (enc_state == ENC_CRT_DATAMV_M_TO_M_NQ) ? 1'b1 : 1'b0;
   assign EnDataMvAns = (enc_state == ENC_CRT_DATAMV_T_TO_M_ANS) ? 1'b1 : 1'b0;
   
   // low-level function
   modexp_sequencer MODEXP ( CLK, RSTn, MODE, Drdy, EnModExp, key_bit, param[7:0], DataMvEnd, sign, MBCon_ModExp, MemCon_ModExp, CntCon_ModExp, AdCon_ModExp, KeyShift, ModExpEnd );
   modulo_sequencer MODULO ( CLK, RSTn, EnModulo, {param[9:8], param[5], param[0]}, sign, d_0, MBCon_Modulo, MemCon_Modulo, CntCon_Modulo, AdCon_Modulo, DataMv_Modulo, Cset_value, ModuloEnd );
   modsub_sequencer MODSUB ( CLK, RSTn, EnModSub, param[5], sign, MBCon_ModSub, MemCon_ModSub, CntCon_ModSub, AdCon_ModSub, ModSubEnd );
   mult_sequencer   MULT   ( CLK, RSTn, EnMult, EnMultiAdd, param[6:4], sign, MBCon_Mult, MemCon_Mult, CntCon_Mult, AdCon_Mult, MultEnd );
   
   // encription end flag
   assign EncEnd = (enc_state == ENC_END) ? 1'b1 : 1'b0;
   
endmodule


		   
module modulo_sequencer ( CLK, RSTn, EnModulo, param, sign, x, MBCon, MemCon, CntCon, AdCon, DataMv, Cset_value, ModuloEnd );

   // global parameter
   parameter P_RADIX = 32;   // radix size (r bit)

   // fixed number
   parameter P_r_ZERO = 32'h00000000; // r bit zero

   input                  CLK, RSTn;
   input 		  EnModulo;    // Modulo enable
   input [3:0] 		  param;       // conditional branching parameters
   input 		  sign;        // sign qh(LSB)
   input [P_RADIX-1:0] 	  x;           // x[s] 
   output [20:0] 	  MBCon;       // control signals for multiplication block
   output [8:0] 	  CntCon;      // control signals for counter module
   output [4:0] 	  MemCon;      // control signals for register array
   output [11:0] 	  AdCon;       // control signals for memory address generator
   output 		  DataMv;      // data mv flag
   output [2:0] 	  Cset_value;  // C value & set signal
   output 		  ModuloEnd;   // ModExp end flag

   reg [3:0] 		  modulo_state; // modulo state
   reg [P_RADIX-1:0] 	  ZZrg;         // ZZ register
   reg 			  op;

   wire 		  k_cntend_s_true, j_cntend_s_true, j_cntend_true, i_cntend_w_true, op_add_true;
//   wire 		  k_cntend_s_true, j_cntend_s_true, j_cntend_true, i_cntend_w_true;
   wire 		  Cset;
   wire [1:0] 		  c_value;
   
   // Modulo state parameter
   parameter       MODULO_INIT       = 4'h0;
   parameter       MODULO_DATA_MV    = 4'h1;  // z[j] <= x[r+j] 
   parameter 	   MODULO_Z_MSB      = 4'h2;  // z[b-1] <= 0
   parameter 	   MODULO_ZZ_SET     = 4'h3;  // ZZ <= x[s]
   parameter 	   MODULO_OP_SET     = 4'h4;  // op <= 	~(op^sign)   
   parameter 	   MODULO_SUB        = 4'h5;  // Q = 2z[j] + !n[j] + C
   parameter 	   MODULO_SUB_MSB    = 4'h6;  // Q = 2z[j] + !n[j] + C (MSB)
   parameter 	   MODULO_ADD        = 4'h7;  // Q = 2z[j] + n[j] + C
   parameter 	   MODULO_ADD_MSB    = 4'h8;  // Q = 2z[j] + n[j] + C (MSB)
   parameter 	   MODULO_EXTRA_ADD  = 4'h9;  // Q = z[j] + n[j] + C
   parameter 	   MODULO_END        = 4'ha;  

   // conditional branching
   assign k_cntend_s_true = param[2]; // 8
   assign i_cntend_w_true = param[3]; // 0-31
   assign j_cntend_s_true = param[0]; // 0-6
   assign j_cntend_true = param[1]; 
   assign op_add_true = op^sign;

   
   // MontMult state machine
   always @(posedge CLK) begin
      if (!RSTn) begin
         modulo_state <= MODULO_INIT;
         op <= 1'b0;
      end
      else if (EnModulo) begin
         case (modulo_state)
           MODULO_INIT:        begin modulo_state <= MODULO_DATA_MV; op <= 1'b0; end	      
           MODULO_DATA_MV:     if (j_cntend_s_true) modulo_state <= MODULO_Z_MSB;
           MODULO_Z_MSB:       modulo_state <= MODULO_ZZ_SET;
           MODULO_ZZ_SET:  
	     if (k_cntend_s_true)
	       if (op^sign) begin modulo_state <= MODULO_EXTRA_ADD; op <= 1'b0; end
	       else         begin modulo_state <= MODULO_END; op <= 1'b0; end
	     else
	       modulo_state <= MODULO_OP_SET;
	   MODULO_OP_SET:      if (op^sign) begin modulo_state <= MODULO_ADD; op <= ~op^sign; end
	                       else         begin modulo_state <= MODULO_SUB; op <= ~op^sign; end
           MODULO_SUB:         if (j_cntend_s_true) modulo_state <= MODULO_SUB_MSB;
           MODULO_ADD:         if (j_cntend_s_true) modulo_state <= MODULO_ADD_MSB;
	   MODULO_SUB_MSB, MODULO_ADD_MSB: 
	      if (i_cntend_w_true)
	       modulo_state <= MODULO_ZZ_SET;
	     else
	       modulo_state <= MODULO_OP_SET;
	   MODULO_EXTRA_ADD:    if (j_cntend_true) modulo_state <= MODULO_END;
	   MODULO_END:           modulo_state <= MODULO_INIT;
         endcase
      end
   end
   
   
   always @(posedge CLK) begin
      if (!RSTn)
	ZZrg <= P_r_ZERO;
      else if (modulo_state == MODULO_ZZ_SET)
	ZZrg <= x;
      else if (modulo_state == MODULO_SUB_MSB || modulo_state == MODULO_ADD_MSB)
	ZZrg <= {ZZrg[P_RADIX-2:0], 1'b0};
   end
   
   
   assign Cset = (modulo_state == MODULO_OP_SET);
   assign c_value = {(~op^sign)&ZZrg[P_RADIX-1], (op^sign)&ZZrg[P_RADIX-1]|(~op^sign)&~ZZrg[P_RADIX-1]};
   assign Cset_value = {Cset, c_value};
     
   // control signal decoder
   function [46:0] modulo_decoder;
      input [3:0] modulo_state;        // modulo state
      input k_cntend_s_true, op_add_true;
      case (modulo_state)
	MODULO_INIT:       modulo_decoder = {21'b100101001010000000000, 9'b101010000, 5'b00000, 1'b0, 11'b00000000000}; 
	MODULO_DATA_MV:    modulo_decoder = {21'b100101001010000000000, 9'b101001001, 5'b01100, 1'b0, 11'b00010000000};
	MODULO_Z_MSB:      modulo_decoder = {21'b100101001010000000000, 9'b101010000, 5'b01000, 1'b0, 11'b00000000000};           
	MODULO_ZZ_SET:     if (k_cntend_s_true) modulo_decoder = {21'b101100100101000001000, 9'b000000000, 5'b00011, 1'b0, 11'b00000001001};    
	                   else      modulo_decoder = {21'b000000000000000001000, 9'b011010100, 5'b00100, 1'b1, 11'b00000001001};    
	MODULO_OP_SET:     if (op_add_true) modulo_decoder = {21'b001100100101000001000, 9'b000000000, 5'b00011, 1'b0, 11'b00000001001};    
	                   else             modulo_decoder = {21'b001100100101000001001, 9'b000000000, 5'b00011, 1'b0, 11'b00000001001};
	MODULO_SUB:        modulo_decoder = {21'b001100100101000001001, 9'b000001001, 5'b01011, 1'b0, 11'b00000001100};          
	MODULO_SUB_MSB:    modulo_decoder = {21'b000000000000000001000, 9'b000110010, 5'b01011, 1'b0, 11'b00000001100};
	MODULO_ADD:        modulo_decoder = {21'b001100100101000001000, 9'b000001001, 5'b01011, 1'b0, 11'b00000001100};           
	MODULO_ADD_MSB:    modulo_decoder = {21'b000000000000000001000, 9'b000110010, 5'b01011, 1'b0, 11'b00000001100};	
	MODULO_EXTRA_ADD:  modulo_decoder = {21'b001100100101000000000, 9'b101001001, 5'b01011, 1'b0, 11'b00000001100};         
	MODULO_END:        modulo_decoder = {21'b100101001010000000000, 9'b101010000, 5'b00000, 1'b0, 11'b00000000000}; 
	default:           modulo_decoder = {21'b100101001010000000000, 9'b101010000, 5'b00000, 1'b0, 11'b00000000000};          
      endcase
   endfunction

     // control signals
   assign {MBCon, CntCon, MemCon, AdCon} = modulo_decoder(modulo_state, k_cntend_s_true, op_add_true);
   assign DataMv = (modulo_state == MODULO_DATA_MV);
   
    
   // Modulo end flag
   assign ModuloEnd = (modulo_state == MODULO_END) ? 1'b1 : 1'b0;
    
    
endmodule



module modsub_sequencer ( CLK, RSTn, EnModSub, param, sign, MBCon, MemCon, CntCon, AdCon, ModSubEnd );

   input                  CLK, RSTn;
   input                  EnModSub;     // ModSub enable
   input                  param;        // conditional branching parameters
   input 		  sign;
   output [20:0]          MBCon;        // control signals for multiplication block
   output [5:0]           CntCon;       // control signals for counter module
   output [4:0]           MemCon;       // control signals for register array
   output [10:0]          AdCon;        // control signals for memory address generator
   output                 ModSubEnd;    // ModSub end flag

   reg [1:0]              modsub_state;

   wire                   j_cntend_true;

   // modsubstate parameter
   parameter              MODSUB_INIT  = 2'b00;
   parameter              MODSUB_W_SUB = 2'b01;
   parameter              MODSUB_W_ADD = 2'b10;
   parameter              MODSUB_END   = 2'b11;

   // conditional branching
   assign j_cntend_true = param;

   // ModSub state machine
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         modsub_state <= MODSUB_INIT;
      end
      else if (EnModSub == 1'b1) begin
         case (modsub_state)
           MODSUB_INIT :  modsub_state <= MODSUB_W_SUB;
           MODSUB_W_SUB : 
	     if (j_cntend_true)
	       if (sign == 1'b0)
		 modsub_state <= MODSUB_W_ADD;
	       else
		 modsub_state <= MODSUB_END;
	   MODSUB_W_ADD : if (j_cntend_true) modsub_state <= MODSUB_END;
           MODSUB_END :   modsub_state <= MODSUB_INIT;
         endcase
      end
   end

   // control signal decoder
   
   function [42:0] modsub_decoder;
      input [1:0] modsub_state;        // modsub state
      input j_cntend_true;
      case (modsub_state)
        MODSUB_INIT :  modsub_decoder = {21'b010100100101000110001, 6'b101000, 5'b00110, 11'b00001000000};
        MODSUB_W_SUB : if (j_cntend_true) modsub_decoder = {21'b100100100101000000001, 6'b001000, 5'b11011, 11'b00000001110};
                       else               modsub_decoder = {21'b001100100101000110001, 6'b000101, 5'b11110, 11'b00001100100};        
        MODSUB_W_ADD : modsub_decoder = {21'b001100100101000000000, 6'b000101, 5'b11011, 11'b00000001100};
	MODSUB_END :   modsub_decoder = {21'b100101001010000000000, 6'b101000, 5'b00000, 11'b00000000000};
        default:       modsub_decoder = 43'b0000000000000000000000000000000000000000000;
      endcase
   endfunction
      
   // control signals
   assign {MBCon, CntCon, MemCon, AdCon} = modsub_decoder(modsub_state, j_cntend_true);

   // ModSub end flag
   assign ModSubEnd = (modsub_state == MODSUB_END) ? 1'b1 : 1'b0;

endmodule


module mult_sequencer ( CLK, RSTn, EnMult, EnMultiAdd, param, sign, MBCon, MemCon, CntCon, AdCon, MultEnd );

   input                  CLK, RSTn;
   input                  EnMult;       // Mult enable
   input 		  EnMultiAdd;
   input [2:0] 		  param;        // conditional branching parameters
   input 		  sign;
   output [20:0]          MBCon;        // control signals for multiplication block
   output [5:0]           CntCon;       // control signals for counter module
   output [4:0]           MemCon;       // control signals for register array
   output [10:0]          AdCon;        // control signals for memory address generator
   output                 MultEnd;      // Mult end flag

   reg [1:0]              mult_state;

   wire                   j_cntend_true, i_cntend_true, i_zero_true;

   // multstate parameter
   parameter              MULT_INIT  = 2'b00;
   parameter              MULT_W_MULT_ADD = 2'b01;
   parameter              MULT_I_INC = 2'b10;
   parameter 		  MULT_END = 2'b11;

   // conditional branching
   assign i_cntend_true = param[2];
   assign j_cntend_true = param[1];
   assign i_zero_true = param[0];

   // Mult state machine
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         mult_state <= MULT_INIT;
      end
      else if ((EnMult | EnMultiAdd) == 1'b1) begin
         case (mult_state)
           MULT_INIT :  mult_state <= MULT_W_MULT_ADD;
           MULT_W_MULT_ADD : if (j_cntend_true) mult_state <= MULT_I_INC;
	   MULT_I_INC : if (i_cntend_true) mult_state <= MULT_END;
	                else               mult_state <= MULT_W_MULT_ADD;
           MULT_END :   mult_state <= MULT_INIT;
         endcase
      end
   end

   // control signal decoder
   function [42:0] mult_decoder;
      input [1:0] mult_state;        // mult state
      input EnMult, EnMultiAdd;
      input i_zero_true;
      if (EnMult)
	case (mult_state)
	  MULT_INIT :   mult_decoder = {21'b100100010110000000000, 6'b101000, 5'b00110, 11'b00000011000};
	  MULT_W_MULT_ADD : if (i_zero_true) mult_decoder = {21'b100010000110000000100, 6'b000101, 5'b11011, 11'b10000010011};
	  else             mult_decoder = {21'b100010000101000000100, 6'b000101, 5'b11011, 11'b10000010011};            
	  MULT_I_INC :  mult_decoder = {21'b100100010101000000010, 6'b011010, 5'b11111, 11'b10000110011};
	  MULT_END :    mult_decoder = {21'b100101001010000000000, 6'b101000, 5'b00000, 11'b00000000000};  
	  default:      mult_decoder = 43'b0000000000000000000000000000000000000000000;
	endcase 
      else if (EnMultiAdd)
	case (mult_state)
	  MULT_INIT :   mult_decoder = {21'b100100010101000000000, 6'b101000, 5'b00111, 11'b00000000001};
	  MULT_W_MULT_ADD : mult_decoder = {21'b100010000101000000100, 6'b000101, 5'b11011, 11'b10000000111};            
	  MULT_I_INC :  mult_decoder = {21'b100100010001000000010, 6'b011010, 5'b11111, 11'b10000100111};
	  MULT_END :    mult_decoder = {21'b100101001010000000000, 6'b101000, 5'b00000, 11'b00000000000};  
	  default:      mult_decoder = 43'b0000000000000000000000000000000000000000000;
	endcase
      else
	mult_decoder = 43'b0000000000000000000000000000000000000000000;
   endfunction
      
   // control signals
   assign {MBCon, CntCon, MemCon, AdCon} = mult_decoder(mult_state, EnMult, EnMultiAdd, i_zero_true);

   // Mult end flag
   assign MultEnd = (mult_state == MULT_END) ? 1'b1 : 1'b0;

endmodule


module modexp_sequencer ( CLK, RSTn, MODE, Drdy, EnModExp, key_bit, param, DataMvEnd, sign, MBCon, MemCon, CntCon, AdCon, KeyShift, ModExpEnd );

   input                  CLK, RSTn;
   input [2:0] 		  MODE;
   input 		  Drdy;
   input 		  EnModExp;   // ModExp enable
   input 		  key_bit;    // exponent
   input [7:0] 		  param;      // conditional branching parameters
   input 		  DataMvEnd;
   input 		  sign;       // sign qh(LSB)
   output [20:0] 	  MBCon;      // control signals for multiplication block
   output [8:0] 	  CntCon;     // control signals for counter module
   output [4:0] 	  MemCon;     // control signals for register array
   output [15:0] 	  AdCon;      // control signals for memory address generator
   output 		  KeyShift;   // control signal for key shift  
   output 		  ModExpEnd;  // ModExp end flag

   reg [4:0] 		  modexp_state; // modexp state
   reg [2:0] 		  memmap_rg;    // memry map state 000: XYT, 001:XTY, 010:YXT, 011:YTX, 100:TXY, 101:TYX

   wire 		  Rst_k, En_k;             // reset & enable signal for k counter
   wire 		  SquareOn, DummyOn;       // squaring & dummy multiplication flag
   wire 		  EnPreProcessing, EnMontRedc, EnOneSet, EnMontMult, EnRmodN;       // function enable flag
   wire 		  PreProcessingEnd, MontRedcEnd, OneSetEnd, MontMultEnd, RmodNEnd;  // function end flag
   wire 		  AnsSelect;               // AnsSelect=1 -Z / AnsSelect=0 +Z (@MONTMULT_MULT or MONTMULT_SQUARE)
   
   wire 		  k_cntend_true;

   wire [20:0] 		  MBCon_PreProcessing, MBCon_MontRedc, MBCon_MontMult, MBCon_OneSet, MBCon_RmodN;      // control signals for multiplication block (from low-level function)
   wire [5:0] 		  CntCon_PreProcessing, CntCon_MontRedc, CntCon_MontMult, CntCon_OneSet, CntCon_RmodN; // control signals for counter (from low-level function)
   wire [4:0] 		  MemCon_PreProcessing, MemCon_MontRedc, MemCon_MontMult, MemCon_OneSet, MemCon_RmodN; // control signals for memory (FF arrays) (from low-level function)
   wire [10:0] 		  AdCon_PreProcessing, AdCon_MontRedc, AdCon_MontMult, AdCon_OneSet, AdCon_RmodN;      // control signals for memory address generator (from low-level function)
   wire [5:0] 		  CntCon_t; // temporary wire
   wire [10:0] 		  AdCon_t;  // temporary wire
   
   // modular exponentiation state
   parameter MODEXP_INIT = 5'h00;
   parameter MODEXP_PREPROCESSING = 5'h01;               // W = -N^(-1) mod R
   parameter MODEXP_MONTREDC = 5'h02;                    // xR mod N
   parameter MODEXP_MODE = 5'h03;                        // mode select
   // left-to-right 
   parameter MODEXP_LTOR_KEY_MSB_GET = 5'h04;            // msb check
   parameter MODEXP_LTOR_MONTMULT_SQUARE = 5'h05;        // Z = X*X/R mod N
   parameter MODEXP_LTOR_MONTMULT_MULT = 5'h06;          // Z = X*Y/R mod N
   parameter MODEXP_LTOR_MONTMULT_DUMMYMULT = 5'h07;     // Z = X*Y/R mod N (dummy)
   // right-to-left
   parameter MODEXP_RTOL_R_MODULO_N = 5'h08;             // Z = R mod N
   parameter MODEXP_RTOL_MONTMULT_MULT = 5'h09;          // Z = X*Y/R mod N
   parameter MODEXP_RTOL_MONTMULT_SQUARE = 5'h0a;        // Z = X*X/R mod N
   parameter MODEXP_RTOL_MONTMULT_DUMMYMULT = 5'h0b;     // Z = X*Y/R mod N (dummy)
   // Montgomery Powering Ladder (MPL)
   parameter MODEXP_MPL_R_MODULO_N = 5'h10;              // Z = R mod N
   parameter MODEXP_MPL_MONTMULT_MULT_0 = 5'h12;         // Z = X*X/R mod N
   parameter MODEXP_MPL_MONTMULT_SQUARE_0 = 5'h13;       // Z = X*Y/R mod N
   parameter MODEXP_MPL_MONTMULT_MULT_1 = 5'h14;         // Z = X*X/R mod N
   parameter MODEXP_MPL_MONTMULT_SQUARE_1 = 5'h15;       // Z = X*Y/R mod N
   // Marc's right-to-left
   parameter MODEXP_MRTOL_R_MODULO_N = 5'h16;            // Z = R mod N
   parameter MODEXP_MRTOL_MONTMULT_MULT_0 = 5'h17;       // Z = X*X/R mod N
   parameter MODEXP_MRTOL_MONTMULT_SQUARE_0 = 5'h18;     // Z = X*Y/R mod N
   parameter MODEXP_MRTOL_MONTMULT_MULT_1 = 5'h19;       // Z = X*X/R mod N
   parameter MODEXP_MRTOL_MONTMULT_SQUARE_1 = 5'h1a;     // Z = X*Y/R mod N
   
   parameter MODEXP_ONESET = 5'h0c;                      // Y=1
   parameter MODEXP_FINAL_MONTMULT = 5'h0d;              // Z = X*Y/R mod N
   parameter MODEXP_END = 5'h0e;

   // conditional branching
   assign k_cntend_true = param[7];
		      
   // modexp sequencer
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         modexp_state <= MODEXP_INIT;
      end
      else if (EnModExp == 1'b1) begin
	 case (modexp_state)
	   MODEXP_INIT:            modexp_state <= MODEXP_PREPROCESSING;
	   MODEXP_PREPROCESSING:   if (PreProcessingEnd == 1'b1) modexp_state <= MODEXP_MONTREDC;
	   MODEXP_MONTREDC:        if (MontRedcEnd == 1'b1)      modexp_state <= MODEXP_MODE;
	   MODEXP_MODE: begin
	      case (MODE)
		 3'b000, 3'b010 : modexp_state <= MODEXP_LTOR_KEY_MSB_GET; // left-to-right algorithm
		 3'b001, 3'b011 : modexp_state <= MODEXP_RTOL_R_MODULO_N;  // right-to-left algorithm
		 3'b100 :         modexp_state <= MODEXP_MPL_R_MODULO_N;   // Montogmery Powering Ladder
		 3'b101 :         modexp_state <= MODEXP_MRTOL_R_MODULO_N; // Marc's roght-to-left
		 default:         modexp_state <= MODEXP_LTOR_KEY_MSB_GET; // left-to-right algorithm
	      endcase
	   end
	   
	   // left-to-right algorithm
	   MODEXP_LTOR_KEY_MSB_GET: begin
	      if (key_bit == 1'b1) 
		if (k_cntend_true) 
		  modexp_state <= MODEXP_ONESET; 
		else
		  modexp_state <= MODEXP_LTOR_MONTMULT_SQUARE; 
	      else                 modexp_state <= MODEXP_LTOR_KEY_MSB_GET;
	   end
	   MODEXP_LTOR_MONTMULT_SQUARE: begin
	      if (MontMultEnd == 1'b1)
		if (key_bit == 1'b1) begin
		   modexp_state <= MODEXP_LTOR_MONTMULT_MULT;
		end
		else begin // key_bit == 1'b0
		   if (MODE[1] == 1'b1)  // dummy multiplication on 
		     modexp_state <= MODEXP_LTOR_MONTMULT_DUMMYMULT;
		   else                  // dummy multiplicaition off
		     if (k_cntend_true)
		       modexp_state <= MODEXP_ONESET;
		     else
		       modexp_state <= MODEXP_LTOR_MONTMULT_SQUARE;
		end
	   end
	   MODEXP_LTOR_MONTMULT_MULT, MODEXP_LTOR_MONTMULT_DUMMYMULT: begin
	      if (MontMultEnd == 1'b1) begin
		 if (k_cntend_true)
		   modexp_state <= MODEXP_ONESET;
		 else
		   modexp_state <= MODEXP_LTOR_MONTMULT_SQUARE;
	      end
	   end
	   
	   // right-to-left algorithm
	   MODEXP_RTOL_R_MODULO_N: begin
		  if (RmodNEnd == 1'b1) 
		    if (key_bit == 1'b1) begin
		       modexp_state <= MODEXP_RTOL_MONTMULT_MULT; 
		    end
		    else begin
		       if (MODE[1] == 1'b1) // dummy multiplication on
			 modexp_state <= MODEXP_RTOL_MONTMULT_DUMMYMULT;
		       else                 // dummy multiplication off
			 modexp_state <= MODEXP_RTOL_MONTMULT_SQUARE; 
		    end
	   end 
	   MODEXP_RTOL_MONTMULT_MULT, MODEXP_RTOL_MONTMULT_DUMMYMULT: 
	      if (MontMultEnd == 1'b1)  modexp_state <= MODEXP_RTOL_MONTMULT_SQUARE;
	   MODEXP_RTOL_MONTMULT_SQUARE: begin
	      if (MontMultEnd == 1'b1)
		if (k_cntend_true) begin
		  modexp_state <= MODEXP_ONESET;
		end
		else begin
		   if (key_bit == 1'b1)
		     modexp_state <= MODEXP_RTOL_MONTMULT_MULT;
		   else   // key_bit == 1'b0
		     if (MODE[1] == 1'b1)  // dummy multiplication on 
		       modexp_state <= MODEXP_RTOL_MONTMULT_DUMMYMULT;
		     else                  // dummy multiplicaition off
		       modexp_state <= MODEXP_RTOL_MONTMULT_SQUARE;
		end 
	   end

	   // Montgomery Powering Ladder
	   MODEXP_MPL_R_MODULO_N: begin
	      if (RmodNEnd == 1'b1)
		if (key_bit == 1'b1) modexp_state <= MODEXP_MPL_MONTMULT_MULT_1; 
		else                 modexp_state <= MODEXP_MPL_MONTMULT_MULT_0;
	   end
	   MODEXP_MPL_MONTMULT_MULT_0: if (MontMultEnd == 1'b1) modexp_state <= MODEXP_MPL_MONTMULT_SQUARE_0;
	   MODEXP_MPL_MONTMULT_SQUARE_0: begin
	      if (MontMultEnd == 1'b1) 
		if (k_cntend_true) begin
		  modexp_state <= MODEXP_ONESET;
		end
		else begin
		   if (key_bit == 1'b1)
		     modexp_state <= MODEXP_MPL_MONTMULT_MULT_1;
		   else // key_bit == 1'b0
		     modexp_state <= MODEXP_MPL_MONTMULT_MULT_0;
		end
	   end
	   MODEXP_MPL_MONTMULT_MULT_1: if (MontMultEnd == 1'b1) modexp_state <= MODEXP_MPL_MONTMULT_SQUARE_1;
	   MODEXP_MPL_MONTMULT_SQUARE_1: begin
	      if (MontMultEnd == 1'b1) 
		if (k_cntend_true) begin
		  modexp_state <= MODEXP_ONESET;
		end
		else begin
		   if (key_bit == 1'b1)
		     modexp_state <= MODEXP_MPL_MONTMULT_MULT_1;
		   else // key_bit == 1'b0
		     modexp_state <= MODEXP_MPL_MONTMULT_MULT_0;
		end
	   end

	   // Marc's right-to-left
	   MODEXP_MRTOL_R_MODULO_N: begin
	       if (RmodNEnd == 1'b1)
		 if (key_bit == 1'b1) modexp_state <= MODEXP_MRTOL_MONTMULT_SQUARE_1; 
		 else                 modexp_state <= MODEXP_MRTOL_MONTMULT_SQUARE_0;
	   end
	   MODEXP_MRTOL_MONTMULT_SQUARE_0: if (MontMultEnd == 1'b1) modexp_state <= MODEXP_MRTOL_MONTMULT_MULT_0;
	   MODEXP_MRTOL_MONTMULT_MULT_0: begin
	      if (MontMultEnd == 1'b1) 
		if (k_cntend_true) begin
		  modexp_state <= MODEXP_ONESET;
		end
		else begin
		   if (key_bit == 1'b1)
		     modexp_state <= MODEXP_MRTOL_MONTMULT_SQUARE_1;
		   else // key_bit == 1'b0
		     modexp_state <= MODEXP_MRTOL_MONTMULT_SQUARE_0;
		end
	   end
	   MODEXP_MRTOL_MONTMULT_SQUARE_1: if (MontMultEnd == 1'b1) modexp_state <= MODEXP_MRTOL_MONTMULT_MULT_1;
	   MODEXP_MRTOL_MONTMULT_MULT_1: begin
	      if (MontMultEnd == 1'b1) 
		if (k_cntend_true) begin
		  modexp_state <= MODEXP_ONESET;
		end
		else begin
		   if (key_bit == 1'b1)
		     modexp_state <= MODEXP_MRTOL_MONTMULT_SQUARE_1;
		   else // key_bit == 1'b0
		     modexp_state <= MODEXP_MRTOL_MONTMULT_SQUARE_0;
		end
	   end
	   
	   MODEXP_ONESET:         if (OneSetEnd == 1'b1)    modexp_state <= MODEXP_FINAL_MONTMULT;
	   MODEXP_FINAL_MONTMULT: if (MontMultEnd == 1'b1)  modexp_state <= MODEXP_END;
	   MODEXP_END:            modexp_state <= MODEXP_INIT;
	   default:               modexp_state <= MODEXP_INIT;
	 endcase
      end
   end 
   
      // memry map state 000: XYT, 001:XTY, 010:YXT, 011:YTX, 100:TXY, 101:TYX
   always @(posedge CLK) begin
      if (RSTn == 1'b0 || Drdy == 1'b1) begin
	 memmap_rg <= 3'b001;
      end
//      else if (DummyOn == 1'b1)
//	memmap_rg <= memmap_rg;
      else if (RmodNEnd == 1'b1) begin // right-to-left algorithm & Montgomery Powering Ladder & Marc's r-to-l
	 if (key_bit == 1'b0)
	   memmap_rg <= 3'b011;
	 else
	   memmap_rg <= 3'b001;
      end
      else if (MontMultEnd == 1'b1) begin
	if (modexp_state == MODEXP_LTOR_MONTMULT_SQUARE || modexp_state == MODEXP_LTOR_MONTMULT_MULT ||
	    ((!k_cntend_true) && key_bit == 1'b0 && MODE[1] == 1'b0 && modexp_state == MODEXP_RTOL_MONTMULT_SQUARE) ||
	    ((!k_cntend_true) && key_bit == 1'b1 && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_0) ||
	    ((!k_cntend_true) && key_bit == 1'b0 && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_1) ||
	    (k_cntend_true && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_0) ||
	    modexp_state == MODEXP_MRTOL_MONTMULT_SQUARE_0 || modexp_state == MODEXP_MRTOL_MONTMULT_SQUARE_1 ||
	    ((!k_cntend_true) && key_bit == 1'b0 && modexp_state == MODEXP_MRTOL_MONTMULT_MULT_0) ||
	    ((!k_cntend_true) && key_bit == 1'b1 && modexp_state == MODEXP_MRTOL_MONTMULT_MULT_1) ||
	    (k_cntend_true && modexp_state == MODEXP_MRTOL_MONTMULT_MULT_1) ||
	    modexp_state == MODEXP_FINAL_MONTMULT) begin
	  case (memmap_rg)
	    3'b000:  memmap_rg <= (AnsSelect) ? 3'b000 : 3'b101;
	    3'b001:  memmap_rg <= (AnsSelect) ? 3'b001 : 3'b100;
	    3'b010:  memmap_rg <= (AnsSelect) ? 3'b010 : 3'b011;
	    3'b011:  memmap_rg <= (AnsSelect) ? 3'b011 : 3'b010;
	    3'b100:  memmap_rg <= (AnsSelect) ? 3'b100 : 3'b001;
	    3'b101:  memmap_rg <= (AnsSelect) ? 3'b101 : 3'b000;
	    default: memmap_rg <= memmap_rg;
	  endcase
	end
	else if (modexp_state == MODEXP_RTOL_MONTMULT_MULT ||
		 ((k_cntend_true || key_bit == 1'b1) && modexp_state == MODEXP_RTOL_MONTMULT_SQUARE) ||
		 ((!k_cntend_true) && key_bit == 1'b0 && MODE[1] == 1'b1 && modexp_state == MODEXP_RTOL_MONTMULT_SQUARE) ||
		 modexp_state == MODEXP_MPL_MONTMULT_MULT_0 || modexp_state == MODEXP_MPL_MONTMULT_MULT_1 ||
		 ((!k_cntend_true) && key_bit == 1'b0 && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_0) ||
		 ((!k_cntend_true) && key_bit == 1'b1 && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_1) || 
		 (k_cntend_true && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_1) ||
		 ((!k_cntend_true) && key_bit == 1'b1 && modexp_state == MODEXP_MRTOL_MONTMULT_MULT_0) ||
		 ((!k_cntend_true) && key_bit == 1'b0 && modexp_state == MODEXP_MRTOL_MONTMULT_MULT_1) ||
		 (k_cntend_true && modexp_state == MODEXP_MRTOL_MONTMULT_MULT_0)
		 ) begin
	   case (memmap_rg)
	     3'b000:  memmap_rg <= (AnsSelect) ? 3'b010 : 3'b100;
	     3'b001:  memmap_rg <= (AnsSelect) ? 3'b011 : 3'b101;
	     3'b010:  memmap_rg <= (AnsSelect) ? 3'b000 : 3'b001;
	     3'b011:  memmap_rg <= (AnsSelect) ? 3'b001 : 3'b000;
	     3'b100:  memmap_rg <= (AnsSelect) ? 3'b101 : 3'b011;
	     3'b101:  memmap_rg <= (AnsSelect) ? 3'b100 : 3'b010;
	     default: memmap_rg <= memmap_rg;
	   endcase
	end
	else if (modexp_state == MODEXP_RTOL_MONTMULT_DUMMYMULT) begin // right-to-left algorithm with dummy
	   case (memmap_rg)
	     3'b000:  memmap_rg <= 3'b010;
	     3'b001:  memmap_rg <= 3'b011;
	     3'b010:  memmap_rg <= 3'b000;
	     3'b011:  memmap_rg <= 3'b001;
	     3'b100:  memmap_rg <= 3'b101;
	     3'b101:  memmap_rg <= 3'b100;
	     default: memmap_rg <= memmap_rg;
	   endcase
	end
	else begin
	  memmap_rg <= memmap_rg; // left-to-right algorithm with dummy
	end
      end
      else begin
	 memmap_rg <= memmap_rg;
      end
   end

   // control signals
   /*
   assign En_k = (modexp_state == MODEXP_LTOR_KEY_MSB_GET ||
		  (key_bit != 1'b1 && (!k_cntend_true) && MODE[1] != 1'b1 && MontMultEnd == 1'b1 && modexp_state == MODEXP_LTOR_MONTMULT_SQUARE) ||
//		  ((!k_cntend_true) && MontMultEnd == 1'b1 && modexp_state == MODEXP_LTOR_MONTMULT_MULT) ||
//		  ((!k_cntend_true) && MontMultEnd == 1'b1 && modexp_state == MODEXP_LTOR_MONTMULT_DUMMYMULT) ||
		  (MontMultEnd == 1'b1 && modexp_state == MODEXP_LTOR_MONTMULT_MULT) ||
		  (MontMultEnd == 1'b1 && modexp_state == MODEXP_LTOR_MONTMULT_DUMMYMULT) || 
		  ((!k_cntend_true) && MontMultEnd == 1'b1 && modexp_state == MODEXP_RTOL_MONTMULT_SQUARE) ||
		  ((!k_cntend_true) && MontMultEnd == 1'b1 && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_0) ||
		  ((!k_cntend_true) && MontMultEnd == 1'b1 && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_1)
		  );
   assign Rst_k = (modexp_state == MODEXP_END) ? 1'b1 : 1'b0;
   assign KeyShift = En_k || (RmodNEnd == 1'b1 && modexp_state == MODEXP_RTOL_R_MODULO_N) || (RmodNEnd == 1'b1 && modexp_state == MODEXP_MPL_R_MODULO_N);
    */
   
   assign En_k = (modexp_state == MODEXP_LTOR_KEY_MSB_GET ||
                  (key_bit != 1'b1 && MODE[1] != 1'b1 && MontMultEnd == 1'b1 && modexp_state == MODEXP_LTOR_MONTMULT_SQUARE) ||
                  (MontMultEnd == 1'b1 && modexp_state == MODEXP_LTOR_MONTMULT_MULT) ||
                  (MontMultEnd == 1'b1 && modexp_state == MODEXP_LTOR_MONTMULT_DUMMYMULT) ||
                  (MontMultEnd == 1'b1 && modexp_state == MODEXP_RTOL_MONTMULT_SQUARE) ||
                  (RmodNEnd == 1'b1 && modexp_state == MODEXP_RTOL_R_MODULO_N) ||
		  ((!k_cntend_true) && MontMultEnd == 1'b1 && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_0) ||
		  ((!k_cntend_true) && MontMultEnd == 1'b1 && modexp_state == MODEXP_MPL_MONTMULT_SQUARE_1) ||
		  (RmodNEnd == 1'b1 && modexp_state == MODEXP_MRTOL_R_MODULO_N) ||
		  (MontMultEnd == 1'b1 && modexp_state == MODEXP_MRTOL_MONTMULT_MULT_0) ||
		  (MontMultEnd == 1'b1 && modexp_state == MODEXP_MRTOL_MONTMULT_MULT_1)
		  );
   assign Rst_k = (modexp_state == MODEXP_END) ? 1'b1 : 1'b0;
   assign KeyShift = En_k || (RmodNEnd == 1'b1 && modexp_state == MODEXP_MPL_R_MODULO_N);


   assign SquareOn = (modexp_state == MODEXP_LTOR_MONTMULT_SQUARE || modexp_state == MODEXP_RTOL_MONTMULT_SQUARE ||
		      modexp_state == MODEXP_MPL_MONTMULT_SQUARE_0 || modexp_state == MODEXP_MPL_MONTMULT_SQUARE_1 ||
		      modexp_state == MODEXP_MRTOL_MONTMULT_SQUARE_0 || modexp_state == MODEXP_MRTOL_MONTMULT_SQUARE_1
		      );
   assign DummyOn = (modexp_state == MODEXP_LTOR_MONTMULT_DUMMYMULT || modexp_state == MODEXP_RTOL_MONTMULT_DUMMYMULT);
   
   assign MBCon = (EnPreProcessing) ? MBCon_PreProcessing : 
		  (EnMontRedc) ? MBCon_MontRedc : 
		  (EnMontMult) ? MBCon_MontMult : 
		  (EnOneSet) ? MBCon_OneSet : 
		  (EnRmodN) ? MBCon_RmodN : 21'b000000000000000000000;
   
   assign CntCon_t = (EnPreProcessing) ? CntCon_PreProcessing : 
		     (EnMontRedc) ? CntCon_MontRedc : 
		     (EnMontMult) ? CntCon_MontMult : 
		     (EnOneSet) ? CntCon_OneSet : 
		     (EnRmodN) ? CntCon_RmodN : 6'b000000;
   assign CntCon = {Rst_k, En_k, CntCon_t[5:2], En_k, CntCon_t[1:0]};
   
   assign MemCon = (EnPreProcessing) ? MemCon_PreProcessing : 
		   (EnMontRedc) ? MemCon_MontRedc : 
		   (EnMontMult) ? MemCon_MontMult : 
		   (EnOneSet) ? MemCon_OneSet : 
		   (EnRmodN) ? MemCon_RmodN : 5'b00000;
   
   assign AdCon_t = (EnPreProcessing) ? AdCon_PreProcessing : 
		    (EnMontRedc) ? AdCon_MontRedc : 
		    (EnMontMult) ? AdCon_MontMult : 
		    (EnOneSet) ? AdCon_OneSet : 
		    (EnRmodN) ? AdCon_RmodN : 11'b00000000000;
   assign AdCon = {memmap_rg, DummyOn, SquareOn, AdCon_t};
   
   assign EnPreProcessing = (modexp_state == MODEXP_PREPROCESSING) ? 1'b1 : 1'b0;
   assign EnMontRedc = (modexp_state == MODEXP_MONTREDC) ? 1'b1 : 1'b0;
   assign EnMontMult = (modexp_state == MODEXP_LTOR_MONTMULT_SQUARE || modexp_state == MODEXP_LTOR_MONTMULT_MULT ||
			modexp_state == MODEXP_RTOL_MONTMULT_SQUARE || modexp_state == MODEXP_RTOL_MONTMULT_MULT ||
			modexp_state == MODEXP_LTOR_MONTMULT_DUMMYMULT || modexp_state == MODEXP_RTOL_MONTMULT_DUMMYMULT ||
			modexp_state == MODEXP_MPL_MONTMULT_SQUARE_0 || modexp_state == MODEXP_MPL_MONTMULT_MULT_0 ||
			modexp_state == MODEXP_MPL_MONTMULT_SQUARE_1 || modexp_state == MODEXP_MPL_MONTMULT_MULT_1 ||
			modexp_state == MODEXP_MRTOL_MONTMULT_SQUARE_0 || modexp_state == MODEXP_MRTOL_MONTMULT_MULT_0 ||
			modexp_state == MODEXP_MRTOL_MONTMULT_SQUARE_1 || modexp_state == MODEXP_MRTOL_MONTMULT_MULT_1 ||
			modexp_state == MODEXP_FINAL_MONTMULT);
   assign EnOneSet = (modexp_state == MODEXP_ONESET) ? 1'b1 : 1'b0;
   assign EnRmodN = (modexp_state == MODEXP_RTOL_R_MODULO_N || modexp_state == MODEXP_MPL_R_MODULO_N || modexp_state == MODEXP_MRTOL_R_MODULO_N) ? 1'b1 : 1'b0;
   
   // low-level sequencer 
   inv_n_sequencer PREPROCESSING ( CLK, RSTn, EnPreProcessing, param[2], MBCon_PreProcessing, MemCon_PreProcessing, CntCon_PreProcessing, AdCon_PreProcessing, PreProcessingEnd );
   montredc_sequencer MONTREDC ( CLK, RSTn, EnMontRedc, {param[5], param[1:0]},sign, MBCon_MontRedc, MemCon_MontRedc, CntCon_MontRedc, AdCon_MontRedc, MontRedcEnd );
   montmult_sequencer MONTMULT ( CLK, RSTn, EnMontMult, param[6:3], sign, MBCon_MontMult, MemCon_MontMult, CntCon_MontMult, AdCon_MontMult, AnsSelect, MontMultEnd );
   oneset_sequencer ONESET ( CLK, RSTn, EnOneSet, param[5], MBCon_OneSet, MemCon_OneSet, CntCon_OneSet, AdCon_OneSet, OneSetEnd );
   r_mod_n_sequencer R_MODULO_N ( CLK, RSTn, EnRmodN, param[5], MBCon_RmodN, MemCon_RmodN, CntCon_RmodN, AdCon_RmodN, RmodNEnd );
   
   // ModExp end flag
   assign ModExpEnd = (modexp_state == MODEXP_END) ? 1'b1 : 1'b0;
      
endmodule



module montmult_sequencer ( CLK, RSTn, EnMontMult, param, sign, MBCon, MemCon, CntCon, AdCon, AnsSelect, MontMultEnd );
      
   input                  CLK, RSTn;
   input 		  EnMontMult;  // MontMult enable
   input [3:0] 		  param;       // conditional branching parameters
   input 		  sign;        // sign bit qh(LSB)
   output [20:0] 	  MBCon;       // control signals for multiplication block
   output [5:0] 	  CntCon;      // control signals for counter module
   output [4:0] 	  MemCon;      // control signals for register array
   output [10:0] 	  AdCon;       // control signals for memory address generator
   output 		  AnsSelect;   // AnsSelect=1 -Z / AnsSelect=0 +Z
   output 		  MontMultEnd; // MontMult end flag

   reg [2:0] 		  montmult_state;
   reg 			  ans_select_rg, sign_rg;

   wire 		  i_cntend_true, j_cntend_true;
   wire 		  i_cntzero_true, j_cntzero_true;
   
   // MontMult state parameter
   parameter 	   MONTMULT_INIT       = 3'h0;  
   parameter 	   MONTMULT_T_CAL1     = 3'h1;  // t = z0 + xi * y0
   parameter 	   MONTMULT_T_CAL2     = 3'h2;  // t = t * W
   parameter 	   MONTMULT_MULT_STEP  = 3'h3;  // q = z + x * y + c0
   parameter 	   MONTMULT_REDC_STEP  = 3'h4;  // q = z + n * t + c1
   parameter 	   MONTMULT_CARRY_ADD  = 3'h5;  // z(m-1) = c0 + c1 + v
   parameter 	   MONTMULT_EXTRA_REDC = 3'h6;  // q = z + !n + c
   parameter 	   MONTMULT_END        = 3'h7;

   // conditional branching
   assign i_cntend_true = param[3];
   assign j_cntend_true = param[2];
   assign i_cntzero_true = param[1];
   assign j_cntzero_true = param[0];
   
   // MontMult state machine 
   always @(posedge CLK) begin
      if (!RSTn) begin
	 montmult_state <= MONTMULT_INIT;
	 ans_select_rg <= 1'b0;
	 sign_rg <= 1'b0;
      end
      else if (EnMontMult) begin 
	 case (montmult_state)
	   MONTMULT_INIT:       begin montmult_state <= MONTMULT_T_CAL1; sign_rg <= 1'b0; ans_select_rg <= 1'b0; end
	   MONTMULT_T_CAL1:     montmult_state <= MONTMULT_T_CAL2;
      	   MONTMULT_T_CAL2:     montmult_state <= MONTMULT_MULT_STEP;
	   MONTMULT_MULT_STEP:  montmult_state <= MONTMULT_REDC_STEP;
	   MONTMULT_REDC_STEP:  if (j_cntend_true) montmult_state <= MONTMULT_CARRY_ADD;
	                        else               montmult_state <= MONTMULT_MULT_STEP;
	   MONTMULT_CARRY_ADD:  if (i_cntend_true) begin montmult_state <= MONTMULT_EXTRA_REDC; sign_rg <= sign; end
	                        else               montmult_state <= MONTMULT_T_CAL1;
	   MONTMULT_EXTRA_REDC: if (j_cntend_true) begin montmult_state <= MONTMULT_END; ans_select_rg <= sign | sign_rg; end
	                        else               montmult_state <= MONTMULT_EXTRA_REDC;
	   MONTMULT_END:        montmult_state <= MONTMULT_INIT;
	 endcase
      end 
   end
   
   //{RstC0, Set1C0, EnC0, RstC1, EnC1, RstX, Set1X, EnX, RstY, EnY, RstZ, EnZ, SelXI, SelYI, SelZI, SelZO, SelCO, SelWD, BitInv} = MBCon
   //{WtM, WtT, Rd0, Rd1, Rdt} = MEMCon
   //{Rst_i, En_i, Rst_j, En_j, SelCNT[1:0]} = CNTCon

   // control signal decoder
   function [42:0] montmule_decoder;
      input [2:0] montmult_state;
      input i_cntend_true, j_cntend_true;
      input i_cntzero_true, j_cntzero_true;
      case (montmult_state)
	MONTMULT_INIT:       montmule_decoder = {21'b100100010110000000000, 6'b101000, 5'b00110, 11'b00000000000}; 
	MONTMULT_T_CAL1:     montmule_decoder = {21'b100100010110100000010, 6'b001000, 5'b10010, 11'b11100010100};
	MONTMULT_T_CAL2:     if (i_cntzero_true)   montmule_decoder = {21'b100100010110000000000, 6'b001000, 5'b10110, 11'b11000000000}; 
	                     else                  montmule_decoder = {21'b100100010101000000000, 6'b001000, 5'b10111, 11'b11000000001}; 
	MONTMULT_MULT_STEP:  montmule_decoder = {21'b001000010101000100000, 6'b000000, 5'b00110, 11'b00011001000}; 
	MONTMULT_REDC_STEP:  if (j_cntend_true)    montmule_decoder = {21'b000010100101000010100, 6'b000000, 5'b11010, 11'b00100011100}; 
	                     else 
			       if (i_cntzero_true) montmule_decoder = {21'b000010010110000000100, 6'b000101, 5'b11110, 11'b00100000100}; 
			       else                montmule_decoder = {21'b000010010101000000100, 6'b000101, 5'b11111, 11'b00100000100}; 
	MONTMULT_CARRY_ADD:  if (i_cntend_true)    montmule_decoder = {21'b010100100101000000101, 6'b101000, 5'b11011, 11'b01000001100}; 
	                     else                  montmule_decoder = {21'b100010010101000000100, 6'b011010, 5'b11111, 11'b01000100100}; 
	MONTMULT_EXTRA_REDC: montmule_decoder = {21'b001100100101000000001, 6'b000101, 5'b11011, 11'b00000001100}; 
	MONTMULT_END:        montmule_decoder = {21'b100101001010000000000, 6'b101000, 5'b00000, 11'b00000000000}; 
	default:             montmule_decoder = 43'b0000000000000000000000000000000000000000000;
      endcase
   endfunction

   // control signals 
   assign {MBCon, CntCon, MemCon, AdCon} = montmule_decoder(montmult_state, i_cntend_true, j_cntend_true, i_cntzero_true, j_cntzero_true);

   // MontMult end flag
   assign MontMultEnd = (montmult_state == MONTMULT_END) ? 1'b1: 1'b0;
   assign AnsSelect = ans_select_rg; // AnsSelect=1 -Z / AnsSelect=0 +Z
	 
endmodule // montmult_sequencer



module inv_n_sequencer ( CLK, RSTn, EnInvN, param, MBCon, MemCon, CntCon, AdCon, InvNEnd );

   input                  CLK, RSTn;
   input 		  EnInvN;     // Function enable
   input 		  param;      // conditional branching parameters
   output [20:0] 	  MBCon;      // control signals for multiplication block
   output [5:0] 	  CntCon;     // control signals for counter module
   output [4:0] 	  MemCon;     // control signals for register array
   output [10:0] 	  AdCon;      // control signals for memory address generator
   output 		  InvNEnd;    // Inv(n) end flag

   reg [2:0] 		  inv_n_state;

   wire 		  i_cntend_s_true;
       
   // inv(n) function state parameter
   parameter 		  INVN_INIT = 3'h0;
   parameter 		  INVN_CAL1 = 3'h1;   // W = W * W
   parameter 		  INVN_CAL2 = 3'h2;   // W = W * N0
   parameter 		  INVN_CAL3 = 3'h3;   // !W + 1
   parameter 		  INVN_END  = 3'h4;

   // conditional branching
   assign i_cntend_s_true = param;
   
   // inv(n) state machine
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         inv_n_state <= INVN_INIT;
      end
      else if (EnInvN == 1'b1) begin
	 case (inv_n_state)
	   INVN_INIT: inv_n_state <= INVN_CAL1;
	   INVN_CAL1: inv_n_state <= INVN_CAL2;
	   INVN_CAL2: if (i_cntend_s_true) inv_n_state <= INVN_CAL3;
	              else                 inv_n_state <= INVN_CAL1;
	   INVN_CAL3: inv_n_state <= INVN_END;
	   INVN_END:  inv_n_state <= INVN_INIT;
	 endcase 
      end
   end 

   // control signal decoder
   function [42:0] inv_n_decoder;
      input [2:0] inv_n_state;           // inv(n) state
      input i_cntend_s_true;
      case (inv_n_state)
	INVN_INIT: inv_n_decoder = {21'b100100010110010000000, 6'b101000, 5'b00010,11'b00000001000};
	INVN_CAL1: inv_n_decoder = {21'b000000010100100000000, 6'b000000, 5'b00010,11'b00000001000};
	INVN_CAL2: begin
	           if (i_cntend_s_true)
		   inv_n_decoder = {21'b010100100110001000001, 6'b100000, 5'b10000,11'b10100000000};
                   else
	           inv_n_decoder = {21'b100100010110101000000, 6'b010010, 5'b10000,11'b10100000000};
	           end
	INVN_CAL3: inv_n_decoder = {21'b000000000000000000000, 6'b000000, 5'b10000,11'b10100000000};
	INVN_END:  inv_n_decoder = {21'b100101001010000000000, 6'b101000, 5'b00000,11'b00000000000};
	default:   inv_n_decoder = 43'b0000000000000000000000000000000000000000000;
      endcase
   endfunction

   assign {MBCon, CntCon, MemCon, AdCon} = inv_n_decoder(inv_n_state, i_cntend_s_true);
   
   // Inv(n) end flag
   assign InvNEnd = (inv_n_state == INVN_END) ? 1'b1 : 1'b0;
   
endmodule 



module montredc_sequencer ( CLK, RSTn, EnMontRedc, param, sign, MBCon, MemCon, CntCon, AdCon, MontRedcEnd );

   input                  CLK, RSTn;
   input 		  EnMontRedc;  // MontRedc enable
   input [2:0] 		  param;       // conditional branching parameters
   input 		  sign;        // sign (qh(LSB))
   output [20:0] 	  MBCon;       // control signals for multiplication block
   output [5:0] 	  CntCon;      // control signals for counter module
   output [4:0] 	  MemCon;      // control signals for register array
   output [10:0] 	  AdCon;       // control signals for memory address generator
   output 		  MontRedcEnd; // MontRedc end flag

   reg [3:0] 		  montredc_state;
   reg 			  op;

   wire 		  i_cntend_l_true, j_cntend_s_true, j_cntend_true;
   wire 		  op_add_true, op_sub_true;
   
   // MontRedc state parameter
   parameter 		  MONTREDC_INIT = 4'h0;       
   parameter 		  MONTREDC_SUB = 4'h1;       // q = 2zj + !nj + c (0 <= j < m-1)
   parameter 		  MONTREDC_SUB_MSB  = 4'h2;  // q = 2zj + !nj + c (j=m-1)
   parameter 		  MONTREDC_ADD = 4'h3;       // q = 2zj + nj + c (0 <= j < m-1)
   parameter 		  MONTREDC_ADD_MSB = 4'h4;   // q = 2zj + nj + c (j=m-1)
   parameter 		  MONTREDC_EXTRA_ADD = 4'h5; // q = zj + nj + c
   parameter 		  MONTREDC_END = 4'h6;
   parameter 		  MONTREDC_CP = 4'h7;        // mem[47:32] <- mem[15:0] data copy  
   parameter 		  MONTREDC_CP_PRE = 4'h8;    
   
   // conditional branching
   assign i_cntend_l_true = param[1];
   assign j_cntend_s_true = param[0];
   assign j_cntend_true = param[2];
   assign op_add_true = op^sign;
   assign op_sub_true = ~(op^sign);
   
   // MontRedc state machine
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         montredc_state <= MONTREDC_INIT;
      end
      else if (EnMontRedc == 1'b1) begin
	 case (montredc_state)
	   MONTREDC_INIT: begin montredc_state <= MONTREDC_SUB; op <= 1'b1; end
  	   MONTREDC_SUB: if (j_cntend_s_true) montredc_state <= MONTREDC_SUB_MSB;
	                 else montredc_state <= MONTREDC_SUB;
	   MONTREDC_SUB_MSB: 
	     if (i_cntend_l_true)  
	       if (op_add_true) begin montredc_state <= MONTREDC_EXTRA_ADD; op <= 1'b0; end
	       else begin montredc_state <= MONTREDC_CP_PRE; op <= 1'b0; end
	     else
	       if (op_sub_true) begin montredc_state <= MONTREDC_SUB; op <= ~(op^sign); end
	       else begin montredc_state <= MONTREDC_ADD; op <= ~(op^sign); end
	   MONTREDC_ADD: if (j_cntend_s_true) montredc_state <= MONTREDC_ADD_MSB;
	                 else montredc_state <= MONTREDC_ADD;
	   MONTREDC_ADD_MSB:
	     if (i_cntend_l_true)  
	       if (op_add_true) begin montredc_state <= MONTREDC_EXTRA_ADD; op <= 1'b0; end
	       else begin montredc_state <= MONTREDC_CP_PRE; op <= 1'b0; end
	     else
	       if (op_sub_true) begin montredc_state <= MONTREDC_SUB; op <= ~(op^sign); end
	       else begin montredc_state <= MONTREDC_ADD; op <= ~(op^sign); end
	   MONTREDC_EXTRA_ADD: if (j_cntend_true) montredc_state <= MONTREDC_CP_PRE;
	                       else montredc_state <= MONTREDC_EXTRA_ADD;
	   MONTREDC_CP_PRE: montredc_state <= MONTREDC_CP;
	   MONTREDC_CP: if (j_cntend_true) montredc_state <= MONTREDC_END;
	                else montredc_state <= MONTREDC_CP;
	   MONTREDC_END:  montredc_state <= MONTREDC_INIT;
	 endcase
      end
   end 

   // control signal decoder
   function [42:0] montredc_decoder;
      input [3:0] montredc_state;        // MontRedc state
      input op_sub_true;
      case (montredc_state)
	MONTREDC_INIT:      montredc_decoder = {21'b010100100101000000001, 6'b101000, 5'b00011, 11'b00000001001};
	MONTREDC_SUB:       montredc_decoder = {21'b001100100101000001001, 6'b000101, 5'b11011, 11'b00000001100};
	MONTREDC_SUB_MSB:   if (op_sub_true) montredc_decoder = {21'b010100100101000001001, 6'b011010, 5'b11011, 11'b00000001100};
	                    else             montredc_decoder = {21'b100100100101000001000, 6'b011010, 5'b11011, 11'b00000001100};
	MONTREDC_ADD:       montredc_decoder = {21'b001100100101000001000, 6'b000101, 5'b11011, 11'b00000001100};
	MONTREDC_ADD_MSB:   if (op_sub_true) montredc_decoder = {21'b010100100101000001001, 6'b011010, 5'b11011, 11'b00000001100};
	                    else             montredc_decoder = {21'b100100100101000001000, 6'b011010, 5'b11011, 11'b00000001100};
	MONTREDC_EXTRA_ADD: montredc_decoder = {21'b001100100101000000000, 6'b000101, 5'b11011, 11'b00000001100};
	MONTREDC_CP_PRE:    montredc_decoder = {21'b100101001001000000000, 6'b101000, 5'b00001, 11'b00000000010};
	MONTREDC_CP:        montredc_decoder = {21'b100101001001000000000, 6'b100101, 5'b10001, 11'b01100000000};
	MONTREDC_END:       montredc_decoder = {21'b100101001010000000000, 6'b101000, 5'b00000, 11'b00000000000};
	default:            montredc_decoder = 43'b0000000000000000000000000000000000000000000;
      endcase
   endfunction

   // control signals
   assign {MBCon, CntCon, MemCon, AdCon} = montredc_decoder(montredc_state, op_sub_true);
   
   // MontRedc end flag
   assign MontRedcEnd = (montredc_state == MONTREDC_END) ? 1'b1 : 1'b0;
   
endmodule



module oneset_sequencer ( CLK, RSTn, EnOneSet, param, MBCon, MemCon, CntCon, AdCon, OneSetEnd );
   
   input                  CLK, RSTn;
   input 		  EnOneSet ;   // OneSet enable
   input 		  param;       // conditional branching parameter
   output [20:0] 	  MBCon;       // control signals for multiplication block
   output [5:0] 	  CntCon;      // control signals for counter module
   output [4:0] 	  MemCon;      // control signals for register array
   output [10:0] 	  AdCon;       // control signals for memory address generator
   output 		  OneSetEnd;   // OneSet end flag

   reg [1:0] 		  oneset_state;

   wire 		  j_cntend_true;
   
   // OneSet state parameter
   parameter 		  ONESET_INIT = 2'b00;       
   parameter 		  ONESET_SET = 2'b01;
   parameter 		  ONESET_END = 2'b10;       
   
   // conditional branching
   assign j_cntend_true = param;
   
   // OneSet state machine
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         oneset_state <= ONESET_INIT;
      end
      else if (EnOneSet == 1'b1) begin
	 case (oneset_state)
	   ONESET_INIT: oneset_state <= ONESET_SET;
	   ONESET_SET:  if (j_cntend_true) oneset_state <= ONESET_END;
	                else               oneset_state <= ONESET_SET;
	   ONESET_END: oneset_state <= ONESET_INIT;
	 endcase
      end
   end 

   // control signal decoder
   function [42:0] oneset_decoder;
      input [1:0] oneset_state;        // OneSet state
      case (oneset_state)
	ONESET_INIT: oneset_decoder = {21'b010101001010000000000, 6'b101000, 5'b00000, 11'b00000000000};
	ONESET_SET:  oneset_decoder = {21'b100101001010000000000, 6'b000101, 5'b10000, 11'b01100000000};
	ONESET_END:  oneset_decoder = {21'b100101001010000000000, 6'b101000, 5'b00000, 11'b00000000000};
	default:     oneset_decoder = 43'b0000000000000000000000000000000000000000000;
      endcase
   endfunction

   // control signals
   assign {MBCon, CntCon, MemCon, AdCon} = oneset_decoder(oneset_state);
   
   // OneSet end flag
   assign OneSetEnd = (oneset_state == ONESET_END) ? 1'b1 : 1'b0;
   
endmodule



module r_mod_n_sequencer ( CLK, RSTn, EnRmodN, param, MBCon, MemCon, CntCon, AdCon, RmodNEnd );

   input                  CLK, RSTn;
   input 		  EnRmodN;     // R mod N enable
   input 		  param;       // conditional branching parameters 
   output [20:0] 	  MBCon;       // control signals for multiplication block
   output [5:0] 	  CntCon;      // control signals for counter module
   output [4:0] 	  MemCon;      // control signals for register array
   output [10:0] 	  AdCon;       // control signals for memory address generator
   output 		  RmodNEnd;    // R mod N end flag

   reg [1:0] 		  r_mod_n_state;

   wire 		  j_cntend_true;
   
   // R mod N state parameter
   parameter 		  R_MODULO_N_INIT = 2'b00;       
   parameter 		  R_MODULO_N_CAL = 2'b01;
   parameter 		  R_MODULO_N_END = 2'b10;       
   
   // conditional branching
   assign j_cntend_true = param;
   
   // R mod N state machine
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         r_mod_n_state <= R_MODULO_N_INIT;
      end
      else if (EnRmodN == 1'b1) begin
	 case (r_mod_n_state)
	   R_MODULO_N_INIT: r_mod_n_state <= R_MODULO_N_CAL;
	   R_MODULO_N_CAL : if (j_cntend_true) r_mod_n_state <= R_MODULO_N_END;
	                    else               r_mod_n_state <= R_MODULO_N_CAL;
	   R_MODULO_N_END : r_mod_n_state <= R_MODULO_N_INIT;
	 endcase
      end
   end 

   // control signal decoder
   function [42:0] r_mod_n_decoder;
      input [1:0] r_mod_n_state;        // R mod N state
      case (r_mod_n_state)
	R_MODULO_N_INIT: r_mod_n_decoder = {21'b010100100110000000001, 6'b101000, 5'b00010, 11'b00000001000};
	R_MODULO_N_CAL:  r_mod_n_decoder = {21'b001100100110000000001, 6'b000101, 5'b10010, 11'b00000001100};
	R_MODULO_N_END:  r_mod_n_decoder = {21'b100101001010000000000, 6'b101000, 5'b00000, 11'b00000000000};
	default:         r_mod_n_decoder = 43'b0000000000000000000000000000000000000000000;
      endcase
   endfunction

   // control signals
   assign {MBCon, CntCon, MemCon, AdCon} = r_mod_n_decoder(r_mod_n_state);
   
   // R mod N end flag
   assign RmodNEnd = (r_mod_n_state == R_MODULO_N_END) ? 1'b1 : 1'b0;
   
endmodule



module multiplication_block ( CLK, RSTn, MBCon, Cset_value, d_0, d_1, d_t, dout, sign );

   // global parameter
   parameter P_RADIX = 32;   // radix size (r bit)
   parameter P_WORD  = 32;   // word size (w bit)

   // fixed number
   parameter P_r_ZERO = 32'h00000000; // r bit zero
   parameter P_r_ONE  = 32'h00000001; // r bit one
   parameter P_w_ZERO = 32'h00000000; // w bit zero

   // inputs & output
   input                CLK, RSTn;  
   input [20:0] 	MBCon;        // control signals for multiplicaiton block
   input [2:0] 		Cset_value;
   input [P_RADIX-1:0] 	d_0;          // r bit input for multiplier x
   input [P_WORD-1:0] 	d_1;          // w bit input for multiplicand y, n
   input [P_WORD-1:0]   d_t;          // w bit input for temporary data z
   output [P_WORD-1:0]  dout;         // data output
   output 		sign;         // sign (qh(LSB))

   // registers
   reg [P_RADIX-1:0] 	Xrg;          // r bit register for X, t, 1
   reg [P_WORD-1:0]     Zrg, Yrg;     // w bit register for Z | w bit register for Y, N, W, V
   reg [P_RADIX-1:0] 	C0rg, C1rg;   // r bit register C0, C1

   // wires
   wire [P_RADIX-1:0] 	x, xin, zin;
   wire [P_WORD-1:0] 	y, yin, yin_t;
   wire [P_RADIX-1:0] 	c;
   wire [P_RADIX:0] 	z;
   wire [P_RADIX+P_WORD-1:0] q;

   // control signals
   wire               RstC0, RstC1, RstX, RstY, RstZ, Set1C0, Set1X; // reset signals of registers
   wire               EnC0, EnC1, EnX, EnY, EnZ;                     // enable signals of registers
   wire [1:0]         SelXI, SelZI;                                  // select signals
   wire               SelYI, SelZO, SelCO, SelWD;
   wire               BitInv;                                        // bit inverse enable

   // function definition
   function [P_WORD-1:0] bit_inverse;
      input [P_WORD-1:0] d;
      input Inv;
      integer i;
      for (i=0; i<=P_WORD-1; i=i+1)  bit_inverse[i] = d[i] ^ Inv;
   endfunction // bit_inverse

   function [P_RADIX-1:0] selector_x_input;
      input [P_RADIX-1:0] d_0, d_1, ql, d_t;
      input [1:0] SelXI;
      case (SelXI)
        2'b00: selector_x_input = d_0;
        2'b01: selector_x_input = d_1;
        2'b10: selector_x_input = ql;
        2'b11: selector_x_input = d_t;
      endcase
   endfunction // selector_x_input

   function [P_RADIX-1:0] selector_z_input;
      input [P_RADIX-1:0] d_t, c0, ql, d_0;
      input [1:0] SelZI;
      case (SelZI)
        2'b00: selector_z_input = d_t;
        2'b01: selector_z_input = c0;
        2'b10: selector_z_input = ql;
        2'b11: selector_z_input = d_0;
      endcase
   endfunction // selector_z_input

   // control signals
   assign {RstC0, Set1C0, EnC0, RstC1, EnC1, RstX, Set1X, EnX, RstY, EnY, RstZ, EnZ, SelXI, SelYI, SelZI, SelZO, SelCO, SelWD, BitInv} = MBCon;

   assign xin = selector_x_input(d_0, d_1, q[P_RADIX-1:0], d_t, SelXI); 
   assign yin_t = (SelYI) ? q[P_WORD-1:0] : d_1;        
   assign yin = bit_inverse(yin_t, BitInv);
   assign zin = selector_z_input(d_t, C0rg, q[P_WORD-1:0], d_0, SelZI);

   // registers
   always @(posedge CLK)
     if (!RSTn || RstC0) C0rg <= P_r_ZERO;
     else if (Cset_value[2]) C0rg <= {29'h00000000, Cset_value[1:0]};
     else if (Set1C0)    C0rg <= P_r_ONE;
     else if (EnC0)      C0rg <= q[P_RADIX+P_WORD-1:P_WORD];

   always @(posedge CLK)
     if (!RSTn || RstC1) C1rg <= P_r_ZERO;
     else if (EnC1)      C1rg <= q[P_RADIX+P_WORD-1:P_WORD];

   always @(posedge CLK)
     if (!RSTn || RstX)  Xrg <= P_r_ZERO;
     else if (Set1X)     Xrg <= P_r_ONE;
     else if (EnX)       Xrg <= xin;

   always @(posedge CLK)
     if (!RSTn || RstY) Yrg <= P_w_ZERO;
     else if (EnY)      Yrg <= yin;

   always @(posedge CLK)
     if (!RSTn || RstZ) Zrg <= P_w_ZERO;
     else if (EnZ)      Zrg <= zin;

   assign x = Xrg;
   assign y = Yrg;
   assign c = (SelCO) ? C1rg : C0rg;
   assign z = (SelZO) ? {Zrg, 1'b0} : {1'b0, Zrg};

   // arithmetic core (multiply accumulator)
   arithmetic_core ARITH_CORE (x, y, z, c, q);

   // output
   assign dout = (SelWD) ? C1rg : q[P_WORD-1:0];
   assign sign = q[P_WORD];

endmodule // multiplication_block



module arithmetic_core (x, y, z, c, q);

   // global parameter
   parameter P_RADIX = 32;   // radix size (r bit)
   parameter P_WORD  = 32;   // word size (w bit)

   input  [P_RADIX-1:0]    x;      // r bit input
   input  [P_WORD-1:0]    y;       // w bit input
   input  [P_RADIX:0]      z;      // w+1 bit input
   input  [P_RADIX-1:0]    c;      // r bit input
   output [P_RADIX+P_WORD-1:0] q;  // r+w bit output

   assign q = z + c + x * y;

endmodule // arithmetic_core
