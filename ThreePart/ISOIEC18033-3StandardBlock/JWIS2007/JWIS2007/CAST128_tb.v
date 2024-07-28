/*-------------------------------------------------------------------------
 Testbench for CAST-128 Macro
                                   
 File name   : CAST128_tb.v
 Version     : Version 1.0
 Created     : OCT/06/2006
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


`define PERIOD 10
module top_tb;

  reg clk, nreset;
  reg data_rdy, key_rdy, en_de;
  reg [63:0]  data_in;
  reg [127:0] key_in;

  wire 	busy, data_valid, key_valid;
  wire [63:0] data_out;
  
  top top( .clk(clk), .nreset(nreset), 
	   .data_rdy(data_rdy),
	   .key_rdy(key_rdy),
	   .en_de(en_de),
	   .data_in(data_in),
	   .key_in(key_in),
	   .busy(busy),
	   .data_valid(data_valid),
	   .key_valid(key_valid),
	   .data_out(data_out) );

  always #(`PERIOD/2) clk <= ~clk;
  
  initial begin
    clk      <= 1'b1;
    nreset   <= 1'b0;
    data_rdy <= 1'b0;
    key_rdy  <= 1'b0;
    en_de    <= 1'b0;
    key_in   <= 128'h01_23_45_67_12_34_56_78_23_45_67_89_34_56_78_9a;
    data_in  <= 128'h01_23_45_67_89_ab_cd_ef;
    // the ciphertext is expected to be
    // 23 8B 4F E5 84 7E 44 B2
    #(`PERIOD*10)  nreset <= 1'b1;
    #(`PERIOD/2)   key_rdy <= 1'b1;
    #(`PERIOD)     key_rdy <= 1'b0;
    #(`PERIOD*140) data_rdy <= 1'b1;
    #(`PERIOD )    data_rdy <= 1'b0;
    #(`PERIOD*20) $finish;
  end

  always @(posedge clk)
    $display( "state=%x, round:%x, data_out = %x", top.state, top.round, data_out );

endmodule // top_tb
