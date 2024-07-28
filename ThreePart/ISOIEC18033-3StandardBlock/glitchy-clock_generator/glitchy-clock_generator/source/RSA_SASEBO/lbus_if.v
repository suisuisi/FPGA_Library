//August 23, 2010 Modified by Sho Endo


/*-------------------------------------------------------------------------
 Local bus interface for AES_Comp on FPGA of SASEBO 
 *** WARNING *** 
 This circuit works only with AES_Comp.
 Compatibility for another cipher module may be provided in future release.
 
 File name   : lbus_if.v
 Version     : Version 1.0
 Created     : SEP/01/2008
 Last update : SEP/01/2008
 Desgined by : Toshihiro Katashita
 
 
 Copyright (C) 2008 AIST
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by AIST ("us").
 
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
 (http://www.rcis.aist.go.jp/special/SASEBO/).
 -------------------------------------------------------------------------*/ 

`timescale 1ns/1ps

//================================================ LBUS_IF
module LBUS_IF
  (lbus_a, lbus_di, lbus_do, lbus_wr, lbus_rd, // Local bus
   blk_kin, blk_din, blk_dout, blk_krdy, blk_drdy, blk_kvld, blk_dvld,
   blk_encdec, blk_en, blk_rstn,
   exp_in, mod_in, predat_in, idata, odata, rsa_krdy, rsa_mrdy, rsa_drdy, rsa_kvld, rsa_mvld, //for RSA
   crt, rsa_mode, dout_valid, run, start_enc, clk, rst);                                  // Clock and reset
   //Length of key
   parameter RSA_LEN = 16'h01ff; //512 bits
   
   //------------------------------------------------
   // Local bus
   input [15:0]   lbus_a;  // Address
   input [15:0]   lbus_di; // Input data  (Controller -> Cryptographic module)
   input          lbus_wr; // Assert input data
   input          lbus_rd; // Assert output data
   output [15:0]  lbus_do; // Output data (Cryptographic module -> Controller)
	  
   // Block cipher
   output [127:0] blk_kin;
   output [127:0] blk_din;
   input [127:0]  blk_dout;
   output         blk_krdy, blk_drdy;
   input          blk_kvld, blk_dvld;
   output         blk_encdec, blk_en;
   output         blk_rstn;

   // RSA
   output         rsa_krdy, rsa_mrdy, rsa_drdy;
   input          rsa_kvld, rsa_mvld;
   
   output [RSA_LEN:0] exp_in;
   output [RSA_LEN:0] mod_in;
   output [RSA_LEN:0] idata;
   input  [RSA_LEN:0] odata;
   output [255:0] 	  predat_in;
   output 			  crt;
   output [2:0] 	  rsa_mode;
   //Others
   input 			  dout_valid;
   output 			  run, start_enc;

   // Clock and reset
   input         clk, rst;

   //------------------------------------------------
   reg [15:0]    lbus_do;

   reg [127:0]   blk_kin,  blk_din;
   reg           blk_krdy;
   wire          blk_drdy;
   reg           blk_encdec;
   wire          blk_en = 1;
   reg           blk_rstn;
   reg 			 start_enc; 			 
   reg 			 run;
			    
   reg [1:0]     wr;
   reg           trig_wr;
   wire          ctrl_wr;
   reg [2:0]     ctrl;
   reg [15:0]    blk_trig;

   //for RSA
   reg [RSA_LEN:0] exp_in;
   reg [RSA_LEN:0] mod_in;
   reg [RSA_LEN:0] idata;
   reg [255:0] predat_in;
   reg         rsa_krdy, rsa_mrdy, rsa_drdy;
   reg 			  crt;
   reg [2:0] 	  rsa_mode;
   

  // Addresses for control registers
   parameter ADDR_CONT    = 16'h0002;
   parameter ADDR_IPSEL   = 16'h0004;
   parameter ADDR_OUTSEL  = 16'h0008;
   parameter ADDR_MODE    = 16'h000C;
   parameter ADDR_RSEL    = 16'h000E;
   parameter ADDR_KEY0    = 16'h0100;
   parameter ADDR_ITEXT0  = 16'h0140;
   parameter ADDR_OTEXT0  = 16'h0180;
   parameter ADDR_EXP00   = 16'h0200;
   parameter ADDR_MOD00   = 16'h0300;
   parameter ADDR_PREDAT00 = 16'h0340;
   parameter ADDR_IDATA00 = 16'h0400;
   parameter ADDR_ODATA00 = 16'h0500;
   parameter ADDR_VERSION = 16'hFFFC;

   //------------------------------------------------
   always @(posedge clk or posedge rst)
     if (rst) wr <= 2'b00;
     else     wr <= {wr[0],lbus_wr};
   
   always @(posedge clk or posedge rst)
     if (rst)            trig_wr <= 0;
     else if (wr==2'b01) trig_wr <= 1;
     else                trig_wr <= 0;
   
   assign ctrl_wr = (trig_wr & (lbus_a == ADDR_CONT));
   
   always @(posedge clk or posedge rst) 
     if (rst) ctrl <= 3'b000;
     else begin
        if (blk_drdy)       ctrl[0] <= 1;
        else if (blk_trig)  ctrl[0] <= 1;
        else if (blk_dvld)  ctrl[0] <= 0;

        if (blk_krdy)      ctrl[1] <= 1;
        else if (blk_kvld) ctrl[1] <= 0;
        
        ctrl[2] <= ~blk_rstn;
     end
   
   always @(posedge clk or posedge rst) 
     if (rst)          blk_trig <= 16'h0;
     else if (ctrl_wr) blk_trig <= {lbus_di[0],15'h0};
     else              blk_trig <= {1'h0,blk_trig[15:1]};
   assign blk_drdy = blk_trig[0];

   always @(posedge clk or posedge rst) 
     if (rst)          blk_krdy <= 0;
     else if (ctrl_wr) blk_krdy <= lbus_di[1]; //If kset == 1, krdy = 1
     else              blk_krdy <= 0;

   always @(posedge clk or posedge rst) 
     if (rst)          blk_rstn <= 1;
     else if (ctrl_wr) blk_rstn <= ~lbus_di[2];
     else              blk_rstn <= 1;

   // RSA control signals
   
   always @(posedge clk or posedge rst) 
     if (rst) begin
		rsa_krdy <= 0;
		rsa_mrdy <= 0;
		rsa_drdy <= 0;
     end else begin
		if (trig_wr && lbus_a == 16'h023E) rsa_krdy <= 1;
		else rsa_krdy <= 0;
		if (trig_wr && lbus_a==16'h033E) rsa_mrdy <= 1;
		else rsa_mrdy <= 0;
		if (trig_wr && lbus_a==16'h43E) rsa_drdy <= 1;
		else rsa_drdy <= 0;
	 end // else: !if(rst)
   
   //------------------------------------------------
   always @(posedge clk or posedge rst) begin
      if (rst) begin
         blk_encdec <= 0;
         blk_kin <= 128'h0;
         blk_din <= 128'h0;
		 exp_in <= 0;
		 mod_in <= 0;
		 idata <= 0;
		 predat_in <= 0;
		 crt <= 0;
		 rsa_mode <= 0;
		 run <= 1'b0;
		 start_enc <= 1'b0;
      end else if (trig_wr) begin // if (rst)
		 if (lbus_a == ADDR_CONT) begin
			run <= lbus_di[0];
			start_enc <= lbus_di[0];
         end else begin 
			start_enc <= 0;
		 end
		 if (lbus_a == ADDR_MODE) begin
			crt <= lbus_di[6];
			rsa_mode <= lbus_di[5:3];
			blk_encdec <= lbus_di[0];
         end
		 
         if (lbus_a==16'h0100) blk_kin[127:112] <= lbus_di;
         if (lbus_a==16'h0102) blk_kin[111: 96] <= lbus_di;
         if (lbus_a==16'h0104) blk_kin[ 95: 80] <= lbus_di;
         if (lbus_a==16'h0106) blk_kin[ 79: 64] <= lbus_di;
         if (lbus_a==16'h0108) blk_kin[ 63: 48] <= lbus_di;
         if (lbus_a==16'h010A) blk_kin[ 47: 32] <= lbus_di;
         if (lbus_a==16'h010C) blk_kin[ 31: 16] <= lbus_di;
         if (lbus_a==16'h010E) blk_kin[ 15:  0] <= lbus_di;

         if (lbus_a==16'h0140) blk_din[127:112] <= lbus_di;
         if (lbus_a==16'h0142) blk_din[111: 96] <= lbus_di;
         if (lbus_a==16'h0144) blk_din[ 95: 80] <= lbus_di;
         if (lbus_a==16'h0146) blk_din[ 79: 64] <= lbus_di;
         if (lbus_a==16'h0148) blk_din[ 63: 48] <= lbus_di;
         if (lbus_a==16'h014A) blk_din[ 47: 32] <= lbus_di;
         if (lbus_a==16'h014C) blk_din[ 31: 16] <= lbus_di;
         if (lbus_a==16'h014E) blk_din[ 15:  0] <= lbus_di;
	 //for 512-bit RSA
	 //Exponent
		 if (lbus_a==16'h0200) exp_in[511:496] <= lbus_di;
        if (lbus_a==16'h0202) exp_in[495:480] <= lbus_di;
        if (lbus_a==16'h0204) exp_in[479:464] <= lbus_di;
        if (lbus_a==16'h0206) exp_in[463:448] <= lbus_di;
        if (lbus_a==16'h0208) exp_in[447:432] <= lbus_di;
        if (lbus_a==16'h020A) exp_in[431:416] <= lbus_di;
        if (lbus_a==16'h020C) exp_in[415:400] <= lbus_di;
        if (lbus_a==16'h020E) exp_in[399:384] <= lbus_di;
        if (lbus_a==16'h0210) exp_in[383:368] <= lbus_di;
        if (lbus_a==16'h0212) exp_in[367:352] <= lbus_di;
        if (lbus_a==16'h0214) exp_in[351:336] <= lbus_di;
        if (lbus_a==16'h0216) exp_in[335:320] <= lbus_di;
        if (lbus_a==16'h0218) exp_in[319:304] <= lbus_di;
        if (lbus_a==16'h021A) exp_in[303:288] <= lbus_di;
        if (lbus_a==16'h021C) exp_in[287:272] <= lbus_di;
        if (lbus_a==16'h021E) exp_in[271:256] <= lbus_di;
        if (lbus_a==16'h0220) exp_in[255:240] <= lbus_di;
        if (lbus_a==16'h0222) exp_in[239:224] <= lbus_di;
        if (lbus_a==16'h0224) exp_in[223:208] <= lbus_di;
        if (lbus_a==16'h0226) exp_in[207:192] <= lbus_di;
        if (lbus_a==16'h0228) exp_in[191:176] <= lbus_di;
        if (lbus_a==16'h022A) exp_in[175:160] <= lbus_di;
        if (lbus_a==16'h022C) exp_in[159:144] <= lbus_di;
        if (lbus_a==16'h022E) exp_in[143:128] <= lbus_di;
        if (lbus_a==16'h0230) exp_in[127:112] <= lbus_di;
        if (lbus_a==16'h0232) exp_in[111:96]  <= lbus_di;
        if (lbus_a==16'h0234) exp_in[95:80]   <= lbus_di;
        if (lbus_a==16'h0236) exp_in[79:64]   <= lbus_di;
        if (lbus_a==16'h0238) exp_in[63:48]   <= lbus_di;
        if (lbus_a==16'h023A) exp_in[47:32]   <= lbus_di;
        if (lbus_a==16'h023C) exp_in[31:16]   <= lbus_di;
        if (lbus_a==16'h023E) exp_in[15:0]    <= lbus_di;
	 //Modulus
		 if (lbus_a==16'h0300) mod_in[511:496] <= lbus_di;
        if (lbus_a==16'h0302) mod_in[495:480] <= lbus_di;
        if (lbus_a==16'h0304) mod_in[479:464] <= lbus_di;
        if (lbus_a==16'h0306) mod_in[463:448] <= lbus_di;
        if (lbus_a==16'h0308) mod_in[447:432] <= lbus_di;
        if (lbus_a==16'h030A) mod_in[431:416] <= lbus_di;
        if (lbus_a==16'h030C) mod_in[415:400] <= lbus_di;
        if (lbus_a==16'h030E) mod_in[399:384] <= lbus_di;
        if (lbus_a==16'h0310) mod_in[383:368] <= lbus_di;
        if (lbus_a==16'h0312) mod_in[367:352] <= lbus_di;
        if (lbus_a==16'h0314) mod_in[351:336] <= lbus_di;
        if (lbus_a==16'h0316) mod_in[335:320] <= lbus_di;
        if (lbus_a==16'h0318) mod_in[319:304] <= lbus_di;
        if (lbus_a==16'h031A) mod_in[303:288] <= lbus_di;
        if (lbus_a==16'h031C) mod_in[287:272] <= lbus_di;
        if (lbus_a==16'h031E) mod_in[271:256] <= lbus_di;
        if (lbus_a==16'h0320) mod_in[255:240] <= lbus_di;
        if (lbus_a==16'h0322) mod_in[239:224] <= lbus_di;
        if (lbus_a==16'h0324) mod_in[223:208] <= lbus_di;
        if (lbus_a==16'h0326) mod_in[207:192] <= lbus_di;
        if (lbus_a==16'h0328) mod_in[191:176] <= lbus_di;
        if (lbus_a==16'h032A) mod_in[175:160] <= lbus_di;
        if (lbus_a==16'h032C) mod_in[159:144] <= lbus_di;
        if (lbus_a==16'h032E) mod_in[143:128] <= lbus_di;
        if (lbus_a==16'h0330) mod_in[127:112] <= lbus_di;
        if (lbus_a==16'h0332) mod_in[111:96] <= lbus_di;
        if (lbus_a==16'h0334) mod_in[95:80] <= lbus_di;
        if (lbus_a==16'h0336) mod_in[79:64] <= lbus_di;
        if (lbus_a==16'h0338) mod_in[63:48] <= lbus_di;
        if (lbus_a==16'h033A) mod_in[47:32] <= lbus_di;
        if (lbus_a==16'h033C) mod_in[31:16] <= lbus_di;
        if (lbus_a==16'h033E) mod_in[15:0] <= lbus_di;
		 //Preprocessed data
        if (lbus_a== 16'h340) predat_in[255:240] <= lbus_di;
        if (lbus_a== 16'h342) predat_in[239:224] <= lbus_di;
        if (lbus_a== 16'h344) predat_in[223:208] <= lbus_di;
        if (lbus_a== 16'h346) predat_in[207:192] <= lbus_di;
        if (lbus_a== 16'h348) predat_in[191:176] <= lbus_di;
        if (lbus_a== 16'h34A) predat_in[175:160] <= lbus_di;
        if (lbus_a== 16'h34C) predat_in[159:144] <= lbus_di;
        if (lbus_a== 16'h34E) predat_in[143:128] <= lbus_di;
        if (lbus_a== 16'h350) predat_in[127:112] <= lbus_di;
        if (lbus_a== 16'h352) predat_in[111:96] <= lbus_di;
        if (lbus_a== 16'h354) predat_in[95:80] <= lbus_di;
        if (lbus_a== 16'h356) predat_in[79:64] <= lbus_di;
        if (lbus_a== 16'h358) predat_in[63:48] <= lbus_di;
        if (lbus_a== 16'h35A) predat_in[47:32] <= lbus_di;
        if (lbus_a== 16'h35C) predat_in[31:16] <= lbus_di;
        if (lbus_a== 16'h35E) predat_in[15:0] <= lbus_di;

		 //Input data
		if (lbus_a==16'h400) idata[511:496] <= lbus_di;
        if (lbus_a==16'h402) idata[495:480] <= lbus_di;
        if (lbus_a==16'h404) idata[479:464] <= lbus_di;
        if (lbus_a==16'h406) idata[463:448] <= lbus_di;
        if (lbus_a==16'h408) idata[447:432] <= lbus_di;
        if (lbus_a==16'h40A) idata[431:416] <= lbus_di;
        if (lbus_a==16'h40C) idata[415:400] <= lbus_di;
        if (lbus_a==16'h40E) idata[399:384] <= lbus_di;
        if (lbus_a==16'h410) idata[383:368] <= lbus_di;
        if (lbus_a==16'h412) idata[367:352] <= lbus_di;
        if (lbus_a==16'h414) idata[351:336] <= lbus_di;
        if (lbus_a==16'h416) idata[335:320] <= lbus_di;
        if (lbus_a==16'h418) idata[319:304] <= lbus_di;
        if (lbus_a==16'h41A) idata[303:288] <= lbus_di;
        if (lbus_a==16'h41C) idata[287:272] <= lbus_di;
        if (lbus_a==16'h41E) idata[271:256] <= lbus_di;
        if (lbus_a==16'h420) idata[255:240] <= lbus_di;
        if (lbus_a==16'h422) idata[239:224] <= lbus_di;
        if (lbus_a==16'h424) idata[223:208] <= lbus_di;
        if (lbus_a==16'h426) idata[207:192] <= lbus_di;
        if (lbus_a==16'h428) idata[191:176] <= lbus_di;
        if (lbus_a==16'h42A) idata[175:160] <= lbus_di;
        if (lbus_a==16'h42C) idata[159:144] <= lbus_di;
        if (lbus_a==16'h42E) idata[143:128] <= lbus_di;
        if (lbus_a==16'h430) idata[127:112] <= lbus_di;
        if (lbus_a==16'h432) idata[111:96] <= lbus_di;
        if (lbus_a==16'h434) idata[95:80] <= lbus_di;
        if (lbus_a==16'h436) idata[79:64] <= lbus_di;
        if (lbus_a==16'h438) idata[63:48] <= lbus_di;
        if (lbus_a==16'h43A) idata[47:32] <= lbus_di;
        if (lbus_a==16'h43C) idata[31:16] <= lbus_di;
        if (lbus_a==16'h43E) idata[15:0] <= lbus_di;
      end else begin // if (trig_wr)
		 if (dout_valid) run <= 0;
		 start_enc <= 0;
	  end // else: !if(trig_wr)
   end // always @ (posedge clk or posedge rst)
                
   //------------------------------------------------
   always @(posedge clk or posedge rst)
     if (rst) 
       lbus_do <= 16'h0;
     else if (~lbus_rd)
       lbus_do <= mux_lbus_do(lbus_a, {ctrl[2:1], run}, blk_encdec, blk_dout, odata);
   
   function  [15:0] mux_lbus_do;
      input [15:0]   lbus_a;
      input [2:0]    ctrl;
      input          blk_encdec;
      input [127:0]  blk_dout;
      input [RSA_LEN:0] odata;
      
      case(lbus_a)
        16'h0002: mux_lbus_do = {5'h00, ctrl};
        16'h000C: mux_lbus_do = {1'b0, crt, rsa_mode, 2'b00, blk_encdec};
        16'h0180: mux_lbus_do = blk_dout[127:112];
        16'h0182: mux_lbus_do = blk_dout[111:96];
        16'h0184: mux_lbus_do = blk_dout[95:80];
        16'h0186: mux_lbus_do = blk_dout[79:64];
        16'h0188: mux_lbus_do = blk_dout[63:48];
        16'h018A: mux_lbus_do = blk_dout[47:32];
        16'h018C: mux_lbus_do = blk_dout[31:16];
        16'h018E: mux_lbus_do = blk_dout[15:0];
       16'h0500: mux_lbus_do = odata[511:496];
       16'h0502: mux_lbus_do = odata[495:480];
       16'h0504: mux_lbus_do = odata[479:464];
       16'h0506: mux_lbus_do = odata[463:448];
       16'h0508: mux_lbus_do = odata[447:432];
       16'h050A: mux_lbus_do = odata[431:416];
       16'h050C: mux_lbus_do = odata[415:400];
       16'h050E: mux_lbus_do = odata[399:384];
       16'h0510: mux_lbus_do = odata[383:368];
       16'h0512: mux_lbus_do = odata[367:352];
       16'h0514: mux_lbus_do = odata[351:336];
       16'h0516: mux_lbus_do = odata[335:320];
       16'h0518: mux_lbus_do = odata[319:304];
       16'h051A: mux_lbus_do = odata[303:288];
       16'h051C: mux_lbus_do = odata[287:272];
       16'h051E: mux_lbus_do = odata[271:256];
       16'h0520: mux_lbus_do = odata[255:240];
       16'h0522: mux_lbus_do = odata[239:224];
       16'h0524: mux_lbus_do = odata[223:208];
       16'h0526: mux_lbus_do = odata[207:192];
       16'h0528: mux_lbus_do = odata[191:176];
       16'h052A: mux_lbus_do = odata[175:160];
       16'h052C: mux_lbus_do = odata[159:144];
       16'h052E: mux_lbus_do = odata[143:128];
       16'h0530: mux_lbus_do = odata[127:112];
       16'h0532: mux_lbus_do = odata[111:96];
       16'h0534: mux_lbus_do = odata[95:80];
       16'h0536: mux_lbus_do = odata[79:64];
       16'h0538: mux_lbus_do = odata[63:48];
       16'h053A: mux_lbus_do = odata[47:32];
       16'h053C: mux_lbus_do = odata[31:16];
       16'h053E: mux_lbus_do = odata[15:0];

        16'hFFFC: mux_lbus_do = 16'h4522;
        default:  mux_lbus_do = 16'h0000;
      endcase
   endfunction
   
endmodule // LBUS_IF
