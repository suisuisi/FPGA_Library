/*-------------------------------------------------------------------------
 Local bus controller on SASEBO 
 
 File name   : params_read_buffer.v
 Version     : Version 1.0
 Created     : SEP/06/2010
 Last update : OCT/29/2010
 Desgined by : Sho Endo
 
-----------------------------------------------------------------
 Copyright (C) 2010 Tohoku University
 
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
 (http://www.rcis.aist.go.jp/special/SASEBO/).
 -------------------------------------------------------------------------*/ 

//================================================ PARAMS_READ_BUFFER
module PARAMS_READ_BUFFER(config_enable, cmd, addr, exec_time_cnt, 
                          data_read, clk, rst);
   input config_enable;
   input [7:0] cmd;
   input [15:0] addr;
   input [31:0] exec_time_cnt;
   output [15:0] data_read;
   input         clk;
   input         rst;
   
   parameter [7:0] CMD_READ         = 8'h00,
                   CMD_WRITE        = 8'h01,
                   CMD_CONFIG_READ  = 8'h02,
                   CMD_CONFIG_WRITE = 8'h03;
   
   parameter [15:0] ADDR_CNT0 = 16'h0005,
                    ADDR_CNT1 = 16'h0006;


   reg [15:0]    data_read;

   always @(posedge clk) begin
      if (rst) begin
         data_read <= 0;
      end else begin
         if (config_enable && cmd == CMD_CONFIG_READ) begin
            case (addr)
              ADDR_CNT0: begin data_read <= exec_time_cnt[15:0]; end
              ADDR_CNT1: begin data_read <= exec_time_cnt[31:16]; end
            endcase
         end
      end
   end // always @ (posedge clk)
   
endmodule
