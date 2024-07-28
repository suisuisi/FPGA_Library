/*-------------------------------------------------------------------------
 RSA Wrapper for SASEBO and SASEBO-G
                                   
 File name   : RSA_SASEBOG.v
 Version     : Version 1.0
 Created     : AUG/19/2010
 Last update : MAY/02/2011
 Desgined by : Atsushi Miyamoto
 
 
 Copyright (C) 2008 Tohoku University
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by Tohoku University ("us").
 
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

`timescale 1ns / 1ps

module RSA_SASEBOG(clkin, rstnin, led, start_n, end_n, exec, clk_mon, lbus_a, 
lbus_di, lbus_do, lbus_rd, lbus_wr, RSV);

    //Length of key
    parameter RSA_LEN = 16'h01ff; //512 bits
   
    //------------------------------------------------
    //Interfaces
    input clkin; // Clock and reset input
    input rstnin;
    output [7:0] led;
    output start_n;
    output end_n;
    output exec;
    output  clk_mon;
    input [15:0] lbus_a;
    input [15:0] lbus_di;
    output [15:0] lbus_do;
    input lbus_rd;
    input lbus_wr;
    input [3:0] RSV;    
   
   //------------------------------------------------
   //Internal signals
   // Internal clock
   wire         clk, rst;

   // Block cipher
   wire [127:0] blk_kin, blk_din, blk_dout;
   wire         blk_krdy, blk_drdy, blk_kvld, blk_dvld, blk_mvld;
   wire         blk_encdec, blk_en, blk_rstn, blk_busy;
   wire         vld_output;
   
   // RSA
   wire [RSA_LEN:0] exp_in, mod_in, idata, odata_to_pc;
   wire [255:0]     predat_in;
   
   wire [31:0] exp_to_rsa, mod_to_rsa, idata_to_rsa, odata;
   wire        rsa_krdy, rsa_mrdy, rsa_drdy, rsa_kvld, rsa_mvld;
   wire        crt;
   wire [2:0]  rsa_mode;
   
   // etc
   wire         run, start_enc, dout_valid;
   reg [23:0]   cnt;

   assign led = {3'h7, ~crt, ~rsa_mode, ~run};
   assign start_n = 0;
   assign end_n = 0;
   assign clk_mon = clkin;
   
   //------------------------------------------------   
   LBUS_IF lbus_if
     (.lbus_a(lbus_a), .lbus_di(lbus_di), .lbus_do(lbus_do),
      .lbus_wr(lbus_wr), .lbus_rd(lbus_rd),
      .blk_kin(blk_kin), .blk_din(blk_din), .blk_dout(blk_dout),
      .blk_krdy(blk_krdy), .blk_drdy(), 
      .blk_kvld(blk_kvld), .blk_dvld(blk_dvld),
      .blk_encdec(blk_encdec), .blk_en(blk_en), .blk_rstn(blk_rstn),
      .exp_in(exp_in), .mod_in(mod_in), .predat_in(predat_in), .idata(idata), .odata(odata_to_pc),
          .rsa_krdy(rsa_krdy), .rsa_mrdy(rsa_mrdy), .rsa_drdy(rsa_drdy), 
          .rsa_kvld(rsa_kvld), .rsa_mvld(rsa_mvld),
      .crt(crt), .rsa_mode(rsa_mode), .dout_valid(dout_valid), .run(run), .start_enc(start_enc), 
          .clk(clk), .rst(rst));

    //------------------------------------------------   
    RSA U_RSA 
     (.Kin(exp_to_rsa), .Min(mod_to_rsa), .Din(idata_to_rsa), .Dout(odata),
      .Krdy(rsa_krdy), .Mrdy(rsa_mrdy), .Drdy(start_enc), 
      .RSTn(blk_rstn), .EN(blk_en), .CRT(crt), .MODE(rsa_mode), .CLK(clk), .BSY(blk_busy), 
      .EXEC(exec), .Kvld(blk_kvld), .Mvld(blk_mvld), .Dvld(vld_output));

    para_to_seq EXP_PARASEQ(.clk(clk), .rst(rst), .rdy(rsa_krdy),
                           .data_in(exp_in), .data_out(exp_to_rsa));

    para_to_seq_mod MOD_PARASEQ(.clk(clk), .rst(rst), .rdy(rsa_mrdy), .crt(crt), 
                           .mod_in(mod_in), .predat_in(predat_in), .data_out(mod_to_rsa));

    para_to_seq IDATA_PARASEQ(.clk(clk), .rst(rst), .rdy(start_enc),
                           .data_in(idata), .data_out(idata_to_rsa));

    seq_to_para ODATA_SEQPARA(.clk(clk), .rst(rst), .rdy(vld_output),
                           .data_in(odata), .data_out(odata_to_pc), .vld(dout_valid));
   
    //------------------------------------------------

    assign clk = clkin;
    assign rst = ~rstnin;

endmodule
