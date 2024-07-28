/*-------------------------------------------------------------------------
 RSA Encryption/Decryption Macro (ASIC version)
                                   
 File name   : RSA1024_RAM.v
 Version     : Version 1.0
 Created     : OCT/05/200
 Last update : APL/04/2008
 Desgined by : Atsushi Miyamoto
 
 
 Copyright (C) 2008 AIST and Tohoku Univ.
 
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

// top module for RSA macro
module RSA ( Kin, Min, Din, Dout, Krdy, Mrdy, Drdy, RSTn, EN, CLK, BSY, Kvld, Mvld, Dvld );   
   
   input           CLK, RSTn, EN;
   input [31:0]    Kin, Min, Din;
   input 	   Krdy, Mrdy, Drdy;
   output 	   BSY;
   output [31:0]   Dout;
   output 	   Kvld, Mvld, Dvld;
   
   reg [1023:0]    Krg;

   wire [4:0] 	   count;
   
   wire [1:0] 	   InOutMem;
   wire [2:0] 	   state;

   wire [31:0] 	   w_data, d_out, r_data_m, r_data_s, r_data0, r_data1, d_in;
   wire [30:16]    MBCon;
   wire [8:0] 	   MemCon_m, MemCon_s, MemCon0, MemCon1, MemCon_i, MemCon_o;
   wire 	   MemSel;
   
   wire [1:0] 	   DSel;
   wire 	   v, sign;
   wire 	   EnKey;
   wire 	   key_bit;
   
   parameter 	   INIT     = 3'h1;
   parameter       IDLE     = 3'h2;
   parameter       KEY_GET  = 3'h3;
   parameter       MOD_GET  = 3'h4;
   parameter       DATA_GET = 3'h5;
   parameter       DATA_OUT = 3'h6;
   parameter       ENCRYPT  = 3'h7;

   always @(posedge CLK) begin
      if (RSTn == 1'b0)
	Krg <= 1024'h0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000;
      else if (state == KEY_GET)
	Krg <= {Kin, Krg[1023:32]};
      else if (EnKey == 1'b1)
        Krg <= {Krg[1022:0], Krg[1023]};
   end

   assign key_bit = Krg[1023];
   
   assign Dout = r_data_m;

   function [31:0] mux2_1_32;
      input [31:0] a, b;
      input Sel;
      case (Sel)
        1'b0: mux2_1_32 = a;
        1'b1: mux2_1_32 = b;
      endcase
   endfunction // mux2_1_32

   function [8:0] mux3_1_9;
      input [8:0] a, b, c, d;
      input [2:0] Sel;
      case (Sel)
        3'b000: mux3_1_9 = a;
        3'b100: mux3_1_9 = b;
	3'b010: mux3_1_9 = c;
	3'b110: mux3_1_9 = c;
	3'b001: mux3_1_9 = d;
	3'b101: mux3_1_9 = d;
        default: mux3_1_9 = a;
      endcase
   endfunction // mux3_1_9

   function [31:0] mux3_1_32;
      input [31:0] a, b, c;
      input [1:0] Sel;
      case (Sel)
        2'b00: mux3_1_32 = a;
        2'b01: mux3_1_32 = b;
        2'b10: mux3_1_32 = c;
        default: mux3_1_32 = a;
      endcase
   endfunction // mux3_1_32

   assign d_in = (state == MOD_GET) ? Min : Din;
   assign w_data = mux3_1_32(d_out, r_data_m, d_in, DSel);
   assign v = r_data_s[0];
   
   RSA_MultiplicationBlock  MULT_BLK     (CLK, RSTn, MBCon, r_data_m, r_data_s, d_out, sign);
   RSA_SequencerBlock       SEQ_BLK    
     (CLK, RSTn, EN, Krdy, Mrdy, Drdy, key_bit, sign, v, MBCon, MemCon_m, MemCon_s, EnKey, MemSel, DSel, count, InOutMem, state, BSY, Kvld, Mvld, Dvld);

   assign MemCon_i = (state == MOD_GET) ? {2'b11, 2'b10, count}:{2'b11, 2'b01, count};
   assign MemCon_o = {2'b01, 2'b00, count};
   assign MemCon0 = mux3_1_9(MemCon_m, MemCon_s, MemCon_i, MemCon_o, {MemSel, InOutMem});
   assign MemCon1 = mux3_1_9(MemCon_s, MemCon_m, MemCon_i, MemCon_o, {MemSel, InOutMem});
   assign r_data_m = mux2_1_32(r_data0, r_data1, MemSel);
   assign r_data_s = mux2_1_32(r_data1, r_data0, MemSel);

   // memory simulation model
   RSA_Memory MEM0 (r_data0, CLK, ~MemCon0[7], ~MemCon0[8], MemCon0[6:0], w_data);
   RSA_Memory MEM1 (r_data1, CLK, ~MemCon1[7], ~MemCon1[8], MemCon1[6:0], w_data);

   
endmodule // top


// single port synchronous memory simulation model
//  Memory    X: 0-31 , Y: 32-63, N: 64-95 , 
//            W: 96 ,   t: 97 ,   V: 98 ,  Zm: 99
module RSA_Memory ( Q, CLK, CEN, WEN, A, D);
   input         CLK;
   input  [31:0] D;         // data inputs 
   input  [6:0]  A;         // addresses 
   input 	 CEN, WEN;  // chip enable & write enable
   output [31:0] Q;         // data outputs
   
   reg [31:0] 	 mem [0:127];
   reg [31:0]	 Q;
   wire 	 MemW, MemR;  // write & read signal
   
   assign MemW = (WEN == 0) & (CEN == 0);
   assign MemR = (WEN == 1) & (CEN == 0);
		 
   always @(posedge CLK) begin
      if (MemW) begin
	 mem[A] <= D;
      end
      else if (MemR)
	Q <= mem[A];
   end

endmodule // RSA_Memory


// sequencer module for RSA macro
module RSA_SequencerBlock (CLK, RSTn, EN, Krdy, Mrdy, Drdy, key_bit, sign, v, MBCon, MemCon_m, MemCon_s, EnKey, MemSel, DSel, count, InOutMem, state, BSY, Kvld, Mvld, Dvld);
   input          CLK, RSTn, EN, Krdy, Mrdy, Drdy;
   input          key_bit;
   input 	  sign;
   input 	  v;
   output [30:16] MBCon;
   output [8:0]   MemCon_m, MemCon_s;
   output 	  EnKey;
   output 	  MemSel;
   output [1:0]   DSel;
   output [4:0]   count;
   output [1:0]   InOutMem;
   output [2:0]   state;
   output 	  BSY, Kvld, Mvld, Dvld;

   wire [30:0] 	  Con, Con_MM, Con_MR, Con_IN, Con_C, Con_O; // control signal
   wire [9:0] 	  i;
   wire [4:0] 	  j, jj, jp1;
   wire 	  Cy_mr, Cy_m, Cy_r, sign;
   wire 	  Hlt_MM, Hlt_MR, Hlt_IN, Hlt_C, Hlt_O; // halt signal
   wire 	  Start_MM, Start_MR, Start_IN, Start_C, Start_O; // start signal
   wire [6:0] 	  ad_m, ad_s;
   wire [11:0] 	  Pc;
   wire 	  Pc_MM, Fin, Hlt;
   
   reg 		  exp, msb, s;
   
   reg [4:0] 	  count;
   
   reg 		  Rst, BSYrg, Kvldrg, Dvldrg, Mvldrg, Start;
   reg 		  Kvldrg_tmp, Mvldrg_tmp;
   reg [1:0] 	  InOutMem;
   reg [2:0] 	  state;
   
   parameter 	   INIT     = 3'h1;
   parameter       IDLE     = 3'h2;
   parameter       KEY_GET  = 3'h3;
   parameter       MOD_GET  = 3'h4;
   parameter       DATA_GET = 3'h5;
   parameter       DATA_OUT = 3'h6;
   parameter       ENCRYPT  = 3'h7;
   
   always @(posedge CLK) begin
      if (RSTn == 1'b0) begin
         state <= INIT;
	 Rst <= 1'b0;
         Dvldrg <= 1'b0;
         Kvldrg <= 1'b0;
	 Mvldrg <= 1'b0;
	 Kvldrg_tmp <= 1'b0;
	 Mvldrg_tmp <= 1'b0;
	 count <= 5'b00000;
	 InOutMem <= 2'b00;
	 Start <= 1'b0;
      end
      else if (EN == 1'b1) begin
	 case(state)
           INIT:
	     if (Krdy ==  1'b1)     state <= KEY_GET;
	     else if (Mrdy == 1'b1) begin
		state <= MOD_GET;
		InOutMem <= 2'b10;
	     end
	   
	   KEY_GET: begin
	      if (count == 5'b11111) begin
		 state <= IDLE;
		 Kvldrg <= 1'b1;
		 Kvldrg_tmp <= 1'b1;
		 count <= 5'b00000;
	      end
	      else 
		count <= count + 1; 
	   end

	   MOD_GET: begin
	      if (count == 5'b11111) begin
		 state <= IDLE;
		 Mvldrg <= 1'b1;
		 Mvldrg_tmp <= 1'b1;
		 InOutMem <= 2'b00;
		 count <= 5'b00000;
	      end
	      else
		count <= count + 1;
	   end
	    
	   DATA_GET: begin
	      if (count == 5'b11111) begin
		 state <= ENCRYPT;
		 InOutMem <= 2'b00;
		 count <= 5'b00000;
		 Start <= 1'b1;
	      end
	      else
		count <= count + 1;
	   end

	   ENCRYPT: begin
	      if (Hlt == 1'b1) begin
		 state <= DATA_OUT;
		 Dvldrg <= 1'b1;
		 InOutMem <= 2'b01;
		 count <= 5'b00000;
	      end
	      else
		Start <= 1'b0;
	   end

	   DATA_OUT: begin
	      if (Dvldrg == 1'b1) begin
		 Dvldrg <= 1'b0;
		 count <= count + 1;
	      end
	      else if (count == 5'b11111) begin
		 state <= IDLE;
		 InOutMem <= 2'b00;
		 count <= 5'b00000;
		 Rst <= 1'b1;
	      end
	      else
		count <= count + 1;
	   end

	   IDLE: begin
	      if (Krdy == 1'b1) begin
		 state <= KEY_GET;
		 Dvldrg <= 1'b0;
		 Kvldrg_tmp <= 1'b0;
		 Mvldrg_tmp <= 1'b0;
		 Rst <= 1'b0;
	      end
	      else if (Mrdy == 1'b1) begin
		 state <= MOD_GET;
		 InOutMem <= 2'b10;
		 Dvldrg <= 1'b0;
		 Kvldrg_tmp <= 1'b0;
		 Mvldrg_tmp <= 1'b0;
		 Rst <= 1'b0;	      
	      end
	      else if (Mvldrg == 1'b1 && Kvldrg == 1'b1 && Drdy == 1'b1) begin
		 state <= DATA_GET;
		 InOutMem <= 2'b10;
		 Dvldrg <= 1'b0;
		 Kvldrg_tmp <= 1'b0;
		 Mvldrg_tmp <= 1'b0;
		 Rst <= 1'b0;
	      end
	      else begin
		 Dvldrg <= 1'b0;
		 Kvldrg_tmp <= 1'b0;
		 Mvldrg_tmp <= 1'b0;
		 Rst <= 1'b0;	
	      end 
	   end 
	   
	   default: state <= IDLE;
	   
	 endcase
	 end 
   end 

   always @(state) begin
      if (state == INIT || state == IDLE)
	BSYrg <= 1'b0;
      else
	BSYrg <= 1'b1;
   end

   assign BSY = BSYrg;    
   
   assign Kvld = Kvldrg_tmp;
   assign Mvld = Mvldrg_tmp;
   assign Dvld = Dvldrg;

   // register S
   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       s <= 1'b0;
     else if (Pc[0] == 1'b1)
       s <= 1'b0;
     else if (Hlt_MM == 1'b1)
       s <= ~((sign ^ v) ^ s);
   end

   assign MemSel = s | Pc[3];

   // register exp
   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       exp <= 1'b0;
     else if (Pc[0] == 1'b1)
       exp <= 1'b0;
     else if (Pc[4] == 1'b1)
       exp <= key_bit;
   end

   // Register msb
   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       msb <= 1'b0;
     else if (Pc[0] == 1'b1)
       msb <= 1'b0;
     else if (Pc[7] == 1'b1)
       msb <= exp;
   end
   
   // selector of control signal 
   function [30:0] mux5_1;
      input [30:0] a, b, c, d, e;
      input [4:0] Sel;
      case (Sel)
	5'b00000: mux5_1 = 31'b0000000000000000000000000000000;
	5'b00001: mux5_1 = a;  // MontMult Pc[5] or Pc[6] or Pc[10]
        5'b00010: mux5_1 = b;  // MontRedc Pc[2]
        5'b00100: mux5_1 = c;  // InvN     Pc[1]
	5'b01000: mux5_1 = d;  // Cp       Pc[3]
	5'b10000: mux5_1 = e;  // One      Pc[9]
 	default: mux5_1 = 31'b0000000000000000000000000000000;
      endcase
   endfunction 
 		 
   assign Pc_MM = Pc[5] | Pc[6] | Pc[10];
   assign Con = mux5_1(Con_MM, Con_MR, Con_IN, Con_C, Con_O,
                       {Pc[9], Pc[3], Pc[1], Pc[2], Pc_MM});

   
   assign Fin = Hlt_MM | Hlt_MR | Hlt_IN | Hlt_C | Hlt_O | Start;

   RSA_MemoryAddressController MEM_CON      (i[4:0], j, jj, jp1, Pc[5], Con[5:0], ad_m, ad_s);
   RSA_LoopController          LOOP_CON     (CLK, RSTn, Con[11:6], {Pc[8],Pc[0]}, i, j, jj, jp1, Cy_mr, Cy_m, Cy_r);
   
   RSA_ModExpSequencer         MODEXP_SEQ   (CLK, RSTn, Rst, msb, exp, Cy_mr, Fin, Pc);
   RSA_StartGen                START_MM     (CLK, RSTn, Rst, Hlt_MM, Pc_MM, Start_MM);   
   RSA_MontMultSequencer       MONTMULT_SEQ (CLK, RSTn, Start_MM, i, Cy_m, Pc[5], Con_MM, Hlt_MM);
   RSA_StartGen                START_MR     (CLK, RSTn, Rst, Hlt_MR, Pc[2], Start_MR);
   RSA_MontRedcSequencer       MONTREDC_SEQ (CLK, RSTn, Start_MR, i, sign, Cy_m, Cy_mr, Con_MR, Hlt_MR);
   RSA_StartGen                START_IN     (CLK, RSTn, Rst, Hlt_IN, Pc[1], Start_IN);
   RSA_InvNSequencer           INVN_SEQ     (CLK, RSTn, Start_IN, Cy_r, Con_IN, Hlt_IN);
   RSA_StartGen                START_C      (CLK, RSTn, Rst, Hlt_C, Pc[3], Start_C);
   RSA_CpSequencer             Cp_SEQ       (CLK, RSTn, Start_C, Cy_m, Con_C, Hlt_C);
   RSA_StartGen                START_O      (CLK, RSTn, Rst, Hlt_O, Pc[9], Start_O);
   RSA_OneSequencer            ONE_SEQ      (CLK, RSTn, Start_O, Cy_m, Con_O, Hlt_O);
   
   assign MBCon = Con[30:16];
   assign MemCon_m = {Con[15:14], ad_m};
   assign MemCon_s = {Con[13:12], ad_s};

   assign Hlt = Pc[11];
   assign DSel = {Pc[0], Pc[3]};
   assign EnKey = Pc[8];

endmodule // SequencerBlock


// differential circuit
module RSA_StartGen (CLK, RSTn, Rst, Hlt, Pc, Start);
   input  CLK, RSTn, Rst, Hlt, Pc;
   output Start;

   reg 	  rgt;

   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       rgt <= 1'b0;
     else if (Rst == 1'b1)
       rgt <= 1'b0;
     else if (Hlt == 1'b1)
       rgt <= 1'b0;
     else
       rgt <= rgt | Pc;
   end

   assign Start = ~rgt & Pc;

endmodule // StartGen


// sequencer module for moduler exponentiation X^E mod N
// left-to-right binay method
module RSA_ModExpSequencer (CLK, RSTn, Rst, Msb, Exp, Cy_mr, Fin, pc);
   input         CLK, RSTn, Rst;
   input 	 Msb, Exp;
   input         Cy_mr;
   input 	 Fin;	 
   output [11:0] pc;
   
   reg    [11:0] pc;

   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       pc <= 12'b000000000001;
     else if (Rst == 1'b1)
       pc <= 12'b000000000001;
     else if (pc[0])
       if (Fin == 1) pc <= {pc[10:0],1'b0};      //  0 to 1
       else       pc <= pc;                      //  0 to 0
     else if (pc[1] || pc[2] || pc[3] || pc[9] || pc[10])  
       if (Fin == 1) pc <= {pc[10:0],1'b0};      //  1 to 2
       else          pc <= pc;                   //  1 to 1
     else if (pc[4])
       if (Msb == 1) pc <= {pc[10:0],1'b0};      //  4 to 5
       else          pc <= 12'b000010000000;     //  4 to 7
     else if (pc[5])
       if (Fin == 1) 
	 if (Exp == 1) pc <= {pc[10:0],1'b0};    //  5 to 6
	 else          pc <= 12'b000100000000;   //  5 to 8
       else            pc <= pc;                 //  5 to 5
     else if (pc[6])
       if (Fin == 1) pc <= 12'b000100000000;     //  6 to 8
       else          pc <= pc;                   //  6 to 6
     else if (pc[8])
       if (Cy_mr == 1) pc <= {pc[10:0],1'b0};    //  8 to 9
       else            pc <= 12'b000000010000;   //  8 to 4
     else
       pc <= {pc[10:0],1'b0};                    //  to next state
   end
   
endmodule // ModExpSequencer


// sequencer module for montgomery multiplication X * Y * R^(-1) mod N 
// ModExpSequencer pc[5]=1(squring)，pc[6]=1(multiplication)  
// number of cycle of 1 time MM operation : 4578  
module RSA_MontMultSequencer (CLK, RSTn, Start, i, Cy_m, Sel, Con, Hlt);
   input         CLK, RSTn, Start;
   input  [9:0]  i;        
   input 	 Cy_m, Sel;     
   output [30:0] Con;
   output 	 Hlt;

   reg    [27:0] pc;

   wire 	 zero;

   assign zero = ~(|(i ^ 10'b0000000000));

   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       pc <= 28'b0000000000000000000000000000;
     else if(Start == 1'b1)
       pc <= 28'b0000000000000000000000000001;
     else if (pc[1])
       pc <= 28'b0000000000000000000000001000;      //  1 to 3
     else if (pc[5])
       if (zero == 1'b1)
	 pc <= {pc[26:0],1'b0};                     //  5 to 6
       else 
	 pc <= 28'b0000000000000000000100000000;    //  5 to 8  
     else if (pc[7])
       if (Cy_m == 1'b1)
	 pc <= 28'b0000000000000001000000000000;    //  7 to 12
       else
	 pc <= 28'b0000000000000000000001000000;    //  7 to 6
     else if (pc[9])
       pc <= 28'b0000000000000000100000000000;
     else if (pc[11])
       if (Cy_m == 1'b1)
	 pc <= {pc[26:0],1'b0};                     //  11 to 12
       else
	 pc <= 28'b0000000000000000010000000000;    //  11 to 10
     else if (pc[17])
       if (Cy_m == 1'b1)
	 pc <= {pc[26:0],1'b0};                     //  17 to 18
       else
	 pc <= 28'b0000000000010000000000000000;    //  17 to 16
     else if (pc[21])
       if (Cy_m == 1'b1)
	 pc <= {pc[26:0],1'b0};                     //  21 to 22
       else
	 pc <= 28'b0000000000000000000000000100;    //  21 to 2
     else if (pc[23])
       pc <= 28'b0010000000000000000000000000;      //  23 to 25
     else if (pc[25])
       if (Cy_m == 1'b1)
	 pc <= {pc[26:0],1'b0};                     //  25 to 26
       else
	 pc <= 28'b0000010000000000000000000000;    //  25 to 22
     else
       pc <= {pc[26:0],1'b0};
   end

   // Sel = 1 squaring      Sel = 0 multiplication
   function [30:0] decoder;
      input [27:0] pc;
      input Sel, zero;
      case(pc)
	28'b0000000000000000000000000001: if (Sel == 1'b0) decoder = {15'b010100000000000, 4'b0100, 6'b010100, 6'b001000}; // 0 m
	                                 else             decoder = {15'b010100000000000, 4'b0100, 6'b010100, 6'b100000}; // 0 s
	28'b0000000000000000000000000010: decoder = {15'b000010100001000, 4'b0111, 6'b000000, 6'b000101}; // 1
	28'b0000000000000000000000000100: decoder = {15'b000000000000000, 4'b0101, 6'b000000, 6'b000000}; // 2
	28'b0000000000000000000000001000: if (zero == 1'b1) decoder = {15'b010110000000000, 4'b0100, 6'b000000, 6'b011000}; // 3
	                                  else              decoder = {15'b011010000000000, 4'b0100, 6'b000000, 6'b011000}; // 3
	28'b0000000000000000000000010000: decoder = {15'b000110100100000, 4'b0100, 6'b000000, 6'b000000}; // 4
	28'b0000000000000000000000100000: if (Sel == 1'b0) decoder = {15'b000010000000000, 4'b0111, 6'b000100, 6'b001100}; // 5 m
	                                 else              decoder = {15'b000010000000000, 4'b0111, 6'b000100, 6'b100100}; // 5 s
	28'b0000000000000000000001000000: decoder = {15'b000100100000000, 4'b0000, 6'b000000, 6'b000000}; // 6
	28'b0000000000000000000010000000: decoder = {15'b100000000000000, 4'b0111, 6'b001000, 6'b101000}; // 7 m s
	28'b0000000000000000000100000000: if (Sel == 1'b0) decoder = {15'b000000000000000, 4'b0101, 6'b000000, 6'b001000}; // 8 m
	                                 else              decoder = {15'b000000000000000, 4'b0101, 6'b000000, 6'b100000}; // 8 s
	28'b0000000000000000001000000000: decoder = {15'b001000100000000, 4'b0001, 6'b000000, 6'b000110}; // 9
	28'b0000000000000000010000000000: decoder = {15'b000000100000000, 4'b0001, 6'b000000, 6'b000110}; // 10
	28'b0000000000000000100000000000: decoder = {15'b101000000000000, 4'b0111, 6'b001000, 6'b101000}; // 11
	28'b0000000000000001000000000000: decoder = {15'b000000000001000, 4'b1101, 6'b000100, 6'b110100}; // 12
	28'b0000000000000010000000000000: decoder = {15'b010010001100000, 4'b0101, 6'b000000, 6'b010000}; // 13
	28'b0000000000000100000000000000: decoder = {15'b011000100000000, 4'b0001, 6'b000000, 6'b000110}; // 14
	28'b0000000000001000000000000000: decoder = {15'b101000000000000, 4'b0100, 6'b001000, 6'b111000}; // 15
	28'b0000000000010000000000000000: decoder = {15'b000000100000000, 4'b0001, 6'b000000, 6'b000110}; // 16
	28'b0000000000100000000000000000: decoder = {15'b101000000000000, 4'b0111, 6'b001000, 6'b111111}; // 17
	28'b0000000001000000000000000000: decoder = {15'b000000000000000, 4'b0101, 6'b000100, 6'b110101}; // 18
	28'b0000000010000000000000000000: decoder = {15'b001010101000000, 4'b0000, 6'b000000, 6'b000000}; // 19
	28'b0000000100000000000000000000: if (Sel == 1'b0) decoder = {15'b100000000000000, 4'b0111, 6'b000000, 6'b001111}; // 20 m
	                                 else              decoder = {15'b100000000000000, 4'b0111, 6'b000000, 6'b100111}; // 20 s
	28'b0000001000000000000000000000: decoder = {15'b100000100011000, 4'b0011, 6'b100101, 6'b000101}; // 21
	28'b0000010000000000000000000000: decoder = {15'b000000000000000, 4'b0101, 6'b000000, 6'b010000}; // 22
	28'b0000100000000000000000000000: decoder = {15'b001010101000001, 4'b0000, 6'b000000, 6'b000000}; // 23
	28'b0001000000000000000000000000: decoder = {15'b001010001000000, 4'b0100, 6'b000000, 6'b111000}; // 24
	28'b0010000000000000000000000000: decoder = {15'b100000100000001, 4'b1101, 6'b001000, 6'b100110}; // 25
	28'b0100000000000000000000000000: decoder = {15'b000000000000000, 4'b0001, 6'b010100, 6'b000101}; // 26
	28'b0100000000000000000000000000: decoder = {15'b000000000000000, 4'b0000, 6'b000000, 6'b000000}; // 27
	default: decoder = 31'b0000000000000000000000000000000;
      endcase
   endfunction

   assign Con = decoder(pc, Sel, zero);
   assign Hlt = pc[27];
	
endmodule // MontMult_Sequencer


// sequencer module for motgomery reduction X * R mod N 
// ModExpSequencer pc[2]=1  
// number of cycle : 99427  
module RSA_MontRedcSequencer (CLK, RSTn, Start, i, sign, Cy_m, Cy_mr, Con, Hlt);
   input         CLK, RSTn, Start;
   input  [9:0]  i;  
   input 	 sign;	 
   input 	 Cy_m, Cy_mr;     
   output [30:0] Con;
   output 	 Hlt;

   reg    [10:0] pc;
   reg 		op;

   wire 	a;
   wire  [32:0] Contmp;
   
   assign a = ~(op ^ sign);
   
   // register Op
   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       op <= 1'b0;
     else if(Contmp[31] == 1'b1)
       op <= 1'b0;
     else if (Contmp[32] == 1'b1)
       op <= a;
   end

   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       pc <= 11'b00000000000;
     else if (Start == 1'b1)
       pc <= 11'b00000000001;
     else if (pc[2])
       if (op == 1'b0)
	 pc <= {pc[9:0],1'b0};        // 2 to 3
       else
	 pc <= 11'b00000010000;       // 2 to 4
     else if (pc[3] || pc[4])  
       pc <= 11'b00000100000;         // 3, 4 to 5
     else if (pc[5]) begin
       if (Cy_m == 1'b1) 
	 pc <= {pc[9:0],1'b0};        // 5 to 6
       else 
	 pc <= 10'b0000000100;        // 5 to 2
     end
     else if (pc[6]) begin
       if (Cy_mr == 1'b1)
	 if (a == 1'b0)
	   pc <= {pc[9:0],1'b0};      // 6 to 7
	 else
	   pc <= 11'b10000000000;     // 6 to 10
       else
	 pc <= 11'b00000000100;       // 6 to 2
     end
     else if (pc[9]) begin
       if (Cy_m == 1'b1)
	 pc <= {pc[9:0],1'b0};        // 9 to 10
       else
	 pc <= 11'b00010000000;       // 9 to 7
     end
     else
       pc <= {pc[9:0],1'b0};          // shift 
   end
   
   function [32:0] decoder;
      input [10:0] pc;
      input a;
      case(pc)
	11'b00000000001: decoder = {2'b01, 15'b010101010000000, 4'b0000, 6'b010100, 6'b000000}; // 0
	11'b00000000010: decoder = {2'b10, 15'b100000000010000, 4'b0101, 6'b000000, 6'b010001}; // 1
	11'b00000000100: decoder = {2'b00, 15'b000000000000000, 4'b0101, 6'b000000, 6'b010001}; // 2
	11'b00000001000: decoder = {2'b00, 15'b001010101000000, 4'b0000, 6'b000000, 6'b000000}; // 3
	11'b00000010000: decoder = {2'b00, 15'b001010101010001, 4'b0000, 6'b000000, 6'b000000}; // 4
	11'b00000100000: decoder = {2'b00, 15'b100000000000010, 4'b1111, 6'b001000, 6'b001001}; // 5
	11'b00001000000:
	  if (a == 1'b0)
	    decoder = {2'b10, 15'b010000000000000, 4'b0000, 6'b100101, 6'b000000}; // 6 
	  else
	    decoder = {2'b10, 15'b100000000010000, 4'b0000, 6'b100101, 6'b000000}; // 6 
	11'b00010000000: decoder = {2'b00, 15'b000000000000000, 4'b0101, 6'b000000, 6'b010001}; // 7
	11'b00100000000: decoder = {2'b00, 15'b001010101000000, 4'b0000, 6'b000000, 6'b000000}; // 8
	11'b01000000000: decoder = {2'b00, 15'b100000000000000, 4'b1111, 6'b001000, 6'b001001}; // 9
	11'b10000000000: decoder = {2'b00, 15'b000000000000000, 4'b0000, 6'b010100, 6'b000000}; // 10
	default: decoder = 33'b000000000000000000000000000000000;
      endcase
   endfunction

   assign Contmp = decoder(pc, a);
   assign Con = Contmp[30:0];
   assign Hlt = pc[10];
	
endmodule // MontRedcSequencer


// sequencer module for pre-computation -N^(-1) mod N
// ModExpSequencer pc[1]=1  
// number of cycle : 69   
module RSA_InvNSequencer (CLK, RSTn, Start, Cy_r, Con, Hlt);
   input         CLK, RSTn, Start;
   input 	 Cy_r;     
   output [30:0] Con;
   output 	 Hlt;

   reg    [6:0] pc;

   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       pc <= 7'b0000000;
     else if (Start == 1'b1)
       pc <= 7'b0000001;
     else if (pc[3])
       if (Cy_r == 1'b1) pc <= {pc[5:0],1'b0};   // 3 to 4
       else              pc <=  7'b0000100;      // 3 to 2
     else
       pc <= {pc[5:0],1'b0};   // shift 
   end
   
   function [30:0] decoder;
      input [6:0] pc;
      case(pc)
	7'b0000001: decoder = {15'b010100000000000, 4'b0100, 6'b010100, 6'b010000}; // 0	
	7'b0000010: decoder = {15'b000010100000000, 4'b0001, 6'b100001, 6'b000010}; // 1
	7'b0000100: decoder = {15'b000010101100100, 4'b0000, 6'b000000, 6'b000000}; // 2
	7'b0001000: decoder = {15'b000010100100100, 4'b1101, 6'b100001, 6'b011010}; // 3
	7'b0010000: decoder = {15'b000000000000000, 4'b0100, 6'b000000, 6'b011000}; // 4
	7'b0100000: decoder = {15'b100110101010001, 4'b0000, 6'b000000, 6'b000000}; // 5
	7'b1000000: decoder = {15'b000000000000000, 4'b1111, 6'b010100, 6'b011011}; // 6
	default: decoder = 31'b0000000000000000000000000000000;
      endcase
   endfunction

   assign Con = decoder(pc);
   assign Hlt = pc[6];
	
endmodule // InvNSequencer


// sequencer module for data transfer
// ModExpSequencerの pc[3]=1  
// number of cycle : 66
module RSA_CpSequencer (CLK, RSTn, Start, Cy_m, Con, Hlt);
   input         CLK, RSTn, Start;
   input         Cy_m;
   output [30:0] Con;
   output        Hlt;

   reg    [3:0] pc;

   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       pc <= 4'b0000;
     else if (Start == 1'b1)
       pc <= 4'b0001;
     else if (pc[2])
       if (Cy_m == 1'b1) pc <= {pc[2:0],1'b0};
       else              pc <= 4'b0010;
     else 
       pc <= {pc[2:0],1'b0};  // shift
   end
   
   function [30:0] decoder;
      input [3:0] pc;
      case(pc)
	4'b0001: decoder = {15'b000000000000000, 4'b0000, 6'b010100, 6'b000000}; // 0
	4'b0010: decoder = {15'b000000000000000, 4'b0100, 6'b000000, 6'b001000}; // 1
	4'b0100: decoder = {15'b000000000000000, 4'b0011, 6'b101000, 6'b000000}; // 2
	4'b1000: decoder = {15'b000000000000000, 4'b0000, 6'b010100, 6'b000000}; // 3
	default: decoder = 31'b0000000000000000000000000000000;
      endcase
   endfunction

   assign Con = decoder(pc);
   assign Hlt = pc[3];
   
endmodule // CpSequencer


// sequencer module for setting '1' to memory   
// ModExpSequencer pc[9]=1 
// number of cycle :34
module RSA_OneSequencer (CLK, RSTn, Start, Cy_m, Con, Hlt);
   input         CLK, RSTn, Start;
   input         Cy_m;
   output [30:0] Con;
   output        Hlt;

   reg    [4:0] pc;

   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       pc <= 5'b00000;
     else if (Start == 1'b1) 
       pc <= 5'b00001;
     else if (pc[3])
       if (Cy_m == 1'b1) pc <= {pc[3:0],1'b0};
       else              pc <= pc;
     else 
       pc <= {pc[3:0],1'b0};  // shift
   end
   
   function [30:0] decoder;
      input [4:0] pc;
      case(pc)
	5'b00001: decoder = {15'b100000000010000, 4'b0000, 6'b000100, 6'b000000}; // 0
	5'b00010: decoder = {15'b000000000001000, 4'b1100, 6'b001000, 6'b001000}; // 1
	5'b00100: decoder = {15'b010000000000000, 4'b0000, 6'b000000, 6'b000000}; // 2
	5'b01000: decoder = {15'b000000000001000, 4'b1100, 6'b001000, 6'b001000}; // 3
	5'b10000: decoder = {15'b000000000000000, 4'b0000, 6'b000000, 6'b000000}; // 4
	default: decoder = 31'b0000000000000000000000000000000;
      endcase
   endfunction

   assign Con = decoder(pc);
   assign Hlt = pc[4];
   
endmodule // OneSequencer


// counter module 
module RSA_LoopController (CLK, RSTn, Con, Pc, i, j, jj, jp1, Cy_mr, Cy_m, Cy_r);
   input        CLK, RSTn; 
   input  [5:0] Con;
   input  [1:0] Pc;
   output [9:0] i;
   output [4:0] j, jj, jp1;
   output 	Cy_mr, Cy_m, Cy_r;
   
   reg [9:0] 	i, i_me;
   reg [4:0] 	j, jj;

   // control signal
   // En_i   <= Con[5]       Rst_i <= Con[4]
   // En_j   <= Con[3]       Rst_j <= Con[2]
   // En_jp1 <= Con[1]
   // IJSel  <= Con[0]
   // En_i_me <= Pc[1](Pc[8])  Rst_i_me <= Pc[0](Pc[0])

   wire [9:0] 	add_in;
   wire [10:0] 	q;
   
   function [9:0] mux3_1;
      input [4:0] a;
      input [9:0] b, c;
      input [1:0] Sel;
      case (Sel)
        2'b00: mux3_1 = {5'b00000, a};
        2'b01: mux3_1 = b;
	2'b10: mux3_1 = c;
	default: mux3_1 = c;
      endcase
   endfunction

   assign add_in = mux3_1(j, i, i_me, {Pc[1], Con[0]});     // 0:j, 1:i, 2:i_me
   
   assign q = add_in + 10'b0000000001;
     
   assign Cy_r = q[5];
   assign Cy_m = q[5];
   assign Cy_mr = q[10];	       

   // register i     
   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       i <= 10'b0000000000;
     else if (Con[4] == 1'b1)
       i <= 10'b0000000000;
     else if (Con[5] == 1'b1)
       i <= q;
   end

   // register j    
   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       j <= 5'b00000;
     else if (Con[2] == 1'b1)
       j <= 5'b00000;
     else if (Con[3] == 1'b1)
       j <= q[4:0];
   end

   // register jj    
   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       jj <= 5'b00000;
     else if (Con[3] == 1'b1)
       jj <= j;
   end
 
   // register i_me    
   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       i_me <= 10'b0000000000;
     else if (Pc[0] == 1'b1)
       i_me <= 10'b0000000000;
     else if (Pc[1] == 1'b1)
       i_me <= q;      
   end

   assign jp1 = q[4:0];
   
endmodule // LoopController


// memory address controller
module RSA_MemoryAddressController (i, j, jj, jp1, Sel, Con, ad_m, ad_s);
   input  [4:0] i, j, jj, jp1;
   input 	Sel;
   input  [5:0] Con;
   output [6:0] ad_m;
   output [6:0] ad_s;

   // function for main memory address
   function [6:0] adg_m;
      input [4:0] i, j, jp1;
      input [2:0] Con;
      input Sel;
      case (Con)
        3'b000: adg_m = {2'b00, i};    // xi
        3'b001: adg_m = {2'b01, j};    // yj
        3'b010: adg_m = {2'b10, j};    // nj
	3'b011: adg_m = 7'b1100000;    // W
        3'b100: adg_m = {2'b00, j};    // xj or zj
        3'b101: adg_m = (Sel == 1'b0)? {2'b01, jp1} : {2'b00, jp1};  // yj+1 xj+1
        3'b110: adg_m = 7'b1100011;    // zm
        3'b111: adg_m = {2'b10, jp1};  // nj+1
        default: adg_m = 7'b0000000;
      endcase
   endfunction

   assign ad_m = adg_m(i, j, jp1, Con[5:3], Sel);

   // function for sub memory address
   function [6:0] adg_s;
      input [4:0] i, j, jj, jp1;
      input [2:0] Con;
      case (Con)
        3'b000: adg_s = {2'b00, j};    // zj
        3'b001: adg_s = {2'b01, j};    // yj
        3'b010: adg_s = {2'b10, j};    // nj
	3'b011: adg_s = 7'b1100000;    // W
        3'b100: adg_s = 7'b1100001;    // t
        3'b101: adg_s = 7'b1100010;    // V
        3'b110: adg_s = {2'b00, jp1};  // zj+1
        3'b111: adg_s = {2'b00, jj};   // zj-1
        default: adg_s = 7'b0000000;
      endcase
   endfunction

   assign ad_s = adg_s(i, j, jj, jp1, Con[2:0]);

endmodule // MemoryAddressController



// multiplicaiton block 
//  32bit register（C, Z, X, Y）and  arithmetic core (ArithCore)
module RSA_MultiplicationBlock (CLK, RSTn, Con, d_in0, d_in1, d_out, sign);
   input          CLK, RSTn;
   input  [30:16] Con;            // control signal
   input  [31:0]  d_in0, d_in1;   // data inuput
   output [31:0]  d_out;          // data output
   output         sign;            

   // control signal
   // En_C   <= Con[30]    Rst_C   <= Con[29]
   // En_Z   <= Con[28]    Rst_Z   <= Con[27]
   // En_X   <= Con[26]    Rst_X   <= Con[25]
   // En_Y   <= Con[24]    Rst_Y   <= Con[23]
   // Sel1   <= Con[22:21]
   // Sel2   <= Con[20]
   // Sel3   <= Con[19]
   // Sel4   <= Con[18]   
   // Sel5   <= Con[17]
   // Inv    <= Con[16]
   
   wire [31:0]  c, x, y;
   wire [32:0] 	z;
   wire [31:0]  regc_in, regx_in, regy_in, regz_out;
   wire [63:0]  q;

   function [31:0] mux4_1;
      input [31:0] a, b, c, d;
      input [1:0] Sel;
      case (Sel)
        2'b00: mux4_1 = a;
        2'b01: mux4_1 = b;
        2'b10: mux4_1 = c;
	2'b11: mux4_1 = d;
      endcase
   endfunction // mux4_1
   
   function [31:0] mux3_1;
      input [31:0] a, b, c;
      input [1:0] Sel;
      case (Sel)
        2'b00: mux3_1 = a;
        2'b01: mux3_1 = b;
        2'b10: mux3_1 = c;
        default: mux3_1 = a;
      endcase
   endfunction // mux3_1

   function [31:0] mux2_1;
      input [31:0] a, b;
      input Sel;
      case (Sel)
        1'b0: mux2_1 = a;
        1'b1: mux2_1 = b;
      endcase
   endfunction // mux2_1

   function [32:0] mux2_1_shift;
      input [31:0] a;
      input Sel;
      case (Sel)
        1'b0: mux2_1_shift = {1'b0,a};      
        1'b1: mux2_1_shift = {a,1'b0};      // shift
      endcase
   endfunction // mux2_1_shift

   // !d 
   function  [31:0] exor;
      input [31:0] d;
      input Inv;
      integer i;

      for (i = 0; i <= 31; i = i + 1) begin
        exor[i] = d[i] ^ Inv;
      end
   endfunction // exor

   assign regx_in = mux4_1(d_in0, q[31:0], 32'h00000001, d_in1, Con[22:21]);
   assign d_out = mux2_1(q[31:0], c, Con[19]);
   assign regc_in = mux2_1(q[63:32], 32'h00000001, Con[20]);
   assign regy_in = mux2_1(exor(d_in0, Con[16]), q[31:0], Con[18]);
   assign z = mux2_1_shift(regz_out, Con[17]);
   assign sign = c[0];

   RSA_Register32 REG_C (CLK, RSTn, Con[30], Con[29], regc_in, c);
   RSA_Register32 REG_Z (CLK, RSTn, Con[28], Con[27], d_in1, regz_out);
   RSA_Register32 REG_X (CLK, RSTn, Con[26], Con[25], regx_in, x);
   RSA_Register32 REG_Y (CLK, RSTn, Con[24], Con[23], regy_in, y);

   RSA_ArithCore ArithCore (x, y, z, c, q);

endmodule // MultiplicationBlock


// 32bit-register
module RSA_Register32 (CLK, RSTn, En, Rst, d, q);
   input  CLK, RSTn, En, Rst;
   input  [31:0] d;
   output [31:0] q;

   reg    [31:0] q;

   always @(posedge CLK) begin
     if (RSTn == 1'b0)
       q <= 32'h00000000;
     else if (Rst == 1'b1)
       q <= 32'h00000000;
     else if (En == 1'b1)
       q <= d;
   end

endmodule // Register32


// aritmetic core
//  Q = Z + C +XY  32bit multiply-accumulator
module RSA_ArithCore (x, y, z, c, q);
   input  [31:0] x, y, c;
   input  [32:0] z;
   output [63:0] q;

   assign q = z + c + x * y;

endmodule // ArithCore



