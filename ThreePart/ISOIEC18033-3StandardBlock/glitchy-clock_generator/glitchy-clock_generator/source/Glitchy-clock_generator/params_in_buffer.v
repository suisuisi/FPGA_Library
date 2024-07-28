/*-------------------------------------------------------------------------
 Local bus controller on SASEBO 
 
 File name   : params_in_buffer.v
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


//================================================ PARAMS_IN_BUFFER
module PARAMS_IN_BUFFER(config_enable, cmd, addr, data_write, glitch_width, 
                        glitch_period, glitch_pos, glitch_pos_fine, glitch_en, clk, rst);
   input config_enable;
   input [7:0] cmd;
   input [15:0] addr;
   input [15:0] data_write;
   output [15:0] glitch_width, glitch_period, glitch_pos, glitch_pos_fine;
   output        glitch_en;
   input         clk, rst;
   
   parameter [7:0] CMD_READ         = 8'h00,
                   CMD_WRITE        = 8'h01,
                   CMD_CONFIG_READ  = 8'h02,
                   CMD_CONFIG_WRITE = 8'h03;
   
   parameter [15:0] ADDR_WIDTH     = 16'h0000,
                    ADDR_PERIOD    = 16'h0001,
                    ADDR_POS       = 16'h0002,
                    ADDR_POS_FINE  = 16'h0003,
                    ADDR_GLITCH_EN = 16'h0004;

   //Output latches
   reg [15:0]    glitch_width, glitch_period, glitch_pos, glitch_pos_fine;
   reg           glitch_en;
   
   always @(posedge clk) begin
      if (rst) begin
         glitch_width    <= 0;
         glitch_period   <= 0;
         glitch_pos      <= 14;
         glitch_pos_fine <= 280;
         glitch_en       <= 0;
      end else begin
         if (config_enable && cmd == CMD_CONFIG_WRITE) begin
            case (addr)
              ADDR_WIDTH:    begin glitch_width    <= data_write; end
              ADDR_PERIOD:   begin glitch_period   <= data_write; end
              ADDR_POS:      begin glitch_pos      <= data_write; end
              ADDR_POS_FINE: begin glitch_pos_fine <= data_write; end
              ADDR_GLITCH_EN: begin glitch_en <= data_write[0]; end
              default: begin end
            endcase // case (addr)
         end
      end
   end
   
endmodule
