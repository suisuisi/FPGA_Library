/*-------------------------------------------------------------------------
 Buffered LBUS controller
 
 File name   : ctrl_lbus_with_buffer.v
 Version     : Version 1.0
 Created     : SEP/03/2010
 Last update : MAR/25/2011
 Designed by : Sho Endo 
 
-----------------------------------------------------------------
 Copyright (C) 2010 - 2011 Tohoku University and AIST.
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by Tohoku University and AIST ("us").
 
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

module PC_TRANSCEIVER
  (addr, data_write, data_read, data_param,                //
   start_pc_to_lsi, start_lsi_to_pc, start_config_write, start_config_read, 
   cmd_out, start_enc,   //
   wd, we, ful, aful, rd, re, emp, aemp, rcnt, // Control signals of UART FIFO
   clk, rst);                                  // Clock and reset
   
   //------------------------------------------------
   //Input
   input [15:0]  data_read, data_param; // Output data (Cryptographic module -> Controller)
   input start_lsi_to_pc;
   
   // Output
   output [15:0] addr;  // Address
   output [15:0] data_write; // Input data  (Controller -> Cryptographic module)
   output [7:0]  cmd_out;
   output    start_pc_to_lsi, start_config_write, start_config_read;
   output    start_enc;
   
   //output [15:0] received_value;
   

   // Control signals of UART FIFO
   output [7:0]  wd;
   output        we;
   input         ful, aful;
   input [7:0]   rd;
   output        re;
   input         emp, aemp;
   input [11:0]  rcnt;

   // Clock and reset
   input         clk, rst;

   //------------------------------------------------
   reg [4:0]     state;
   reg [3:0]     cnt;
   reg [7:0]     wd;
   reg           we, re;
   wire          wr_busy, rd_busy;
   reg [7:0]   cmd_out;    
   reg [15:0]    addr;
   reg [15:0]    data_write;
   reg [15:0]    fetched;
   reg     start_pc_to_lsi, start_config_write, start_config_read;
   reg     config_mode;
   reg     start_enc;
   
   //------------------------------------------------
   parameter [7:0] CMD_READ   = 8'h00,
           CMD_WRITE  = 8'h01,
           CMD_CONFIG_READ = 8'h02,
                   CMD_CONFIG_WRITE = 8'h03;
   
   parameter [4:0]
                WAIT = 5'h00,
                CMD0 = 5'h01,
                CMD1 = 5'h02,
                RD0  = 5'h03,
                RD1  = 5'h04,
                RD2  = 5'h05,
                RD3  = 5'h06,
                RD4  = 5'h07,
                RD5  = 5'h08,
                RD6  = 5'h09,
                RD7  = 5'h0A,
                RD8  = 5'h0B,
                RD9  = 5'h0C,
                WR0  = 5'h0D,
                WR1  = 5'h0E,
                WR2  = 5'h0F,
                WR3  = 5'h10,
                WR4  = 5'h11,
                WR5  = 5'h12,
                TRAP = 5'h17;

   parameter [15:0] ADDR_CONT = 16'h0002;
   //------------------------------------------------
   assign wr_busy = ful | (aful & we);
   assign rd_busy = emp | (aemp & re);

   always @(posedge clk or posedge rst) begin
      if (rst) begin
         state <= WAIT; cnt <= 4'h0;
         we <= 0; wd <= 8'h0; re <= 0;
         addr <= 16'h0; data_write <= 16'h0;
     start_pc_to_lsi <= 0;
     start_config_write <= 0; start_config_read <= 0;
     config_mode <= 0;
     start_enc <= 0;
      end else
        case (state)
          WAIT: begin
             if (~rd_busy) begin state <= CMD0; re <= 1; end
             else          begin state <= WAIT; re <= 0; end
             we <= 0;
       start_pc_to_lsi <= 0;
       start_config_write <= 0; start_config_read <= 0;
       config_mode <= 0; start_enc <= 0;
          end
          CMD0: begin state <= CMD1; re <= 0; end
          CMD1: begin
             if (rd==CMD_READ)       state <= RD0;
             else if (rd==CMD_WRITE) state <= WR0;
             else if (rd==CMD_CONFIG_READ)  begin
        state <= RD0;
        config_mode <= 1;
       end
             else if (rd==CMD_CONFIG_WRITE) begin
        state <= WR0;
        config_mode <= 1;
       end else begin state <= TRAP; end
             re  <= 0;
       cmd_out <= rd;
          end

          RD0: begin
             if (rcnt>=12'h2) begin state <= RD1; re <= 1; end
             else             begin state <= RD0; re <= 0; end
          end
          RD1: begin state <= RD2; re <= 1; end
          RD2: begin state <= RD3; re <= 0; addr[15:8] <= rd; end
          RD3: begin state <= RD4; addr[7:0] <= rd; end
          RD4: begin
       if (config_mode == 0) begin
        start_pc_to_lsi  <= 1;
        state <= RD5;
       end else begin
        start_config_read <= 1;
        fetched <= data_param; state <= RD7;
       end
      end
          RD5: begin
       if (start_lsi_to_pc) begin state <= RD6; end
       start_pc_to_lsi <= 0;
          end
          RD6: begin state <= RD7; fetched <= data_read; end
          RD7: begin
             if (~wr_busy) begin state <= RD8; we <= 1; end
             wd <= fetched[15:8];
       start_config_read <= 0;
          end
          RD8: begin
             if (~wr_busy) begin state <= WAIT; we <= 1; end
             else          begin state <= RD8;  we <= 0; end
             wd <= fetched[7:0];
          end
          WR0: begin
             if (rcnt>=12'h4) begin state <= WR1; re <= 1; end
             else             begin state <= WR0; re <= 0; end
          end
          WR1: begin state <= WR2; re <= 1; end
          WR2: begin state <= WR3; re <= 1; addr[15:8] <= rd; end
          WR3: begin state <= WR4; re <= 1; addr[7:0]  <= rd; end
          WR4: begin
       state <= WR5; re <= 0; data_write[15:8]<= rd; 
      end
          WR5: begin 
       state <= WAIT;
       if (config_mode == 0) begin
         start_pc_to_lsi <= 1;
       end else begin
        start_config_write <= 1;
       end
       data_write[7:0] <= rd;
       //If cipher is kicked, assert start_enc
       if (addr == ADDR_CONT && rd[0] == 1) begin
        start_enc <= 1;
       end
      end

          TRAP: begin state <= TRAP; end
        endcase // case (state)
   end // always @ (posedge clk or posedge rst)
   
endmodule // PC_TRANSCEIVER

module LBUS_TRANSCEIVER
  (addr_in, data_write, data_read, //Address, writing data and read data
   start_pc_to_lsi, start_lsi_to_pc, cmd_in,  
   lbus_a, lbus_dw, lbus_dr, lbus_wr, lbus_rd, // Local bus
   clk, rst);                                  // Clock and reset
   //Input
   input [15:0] addr_in, data_write;//Address and writing data
   input [15:0] lbus_dr; // Read data (Cryptographic module -> Controller)
   input  start_pc_to_lsi;
   input [7:0]  cmd_in;
   
   //Output
   output [15:0] data_read;       //Read data
   output [15:0] lbus_a;
   output [15:0] lbus_dw; // Write data (Controller -> Cryptographic module)
   output    lbus_wr, lbus_rd;
   output    start_lsi_to_pc;
   
   //------------------------------------------------

   // Clock and reset
   input         clk, rst;

   //------------------------------------------------
   reg [4:0]     state;
   reg [3:0]     cnt;
   reg [7:0]     wd;
   reg           we, re;
   wire          wr_busy, rd_busy;
   reg [7:0]   cmd;

   //Output latches
   reg [15:0]    lbus_a, lbus_dw;
   reg           lbus_rd, lbus_wr;
   reg [15:0]    data_read;
   
   //------------------------------------------------
   parameter [4:0]
                WAIT = 5'h00,
                ADDR = 5'h01,
                CMD  = 5'h02,
                RD0  = 5'h03,
                RD1  = 5'h04,
                RD2  = 5'h05,
                RD3  = 5'h06,
                RD4  = 5'h07,
                RD5  = 5'h08,
                RD6  = 5'h09,
                RD7  = 5'h0A,
                RD8  = 5'h0B,
                RD9  = 5'h0C,
                WR0  = 5'h0D,
                WR1  = 5'h0E,
                WR2  = 5'h0F,
                WR3  = 5'h10,
                WR4  = 5'h11,
                WR5  = 5'h12,
                WR6  = 5'h13,
                WR7  = 5'h14,
                WR8  = 5'h15,
                WR9  = 5'h16,
                TRAP = 5'h17;
                
   //------------------------------------------------

   always @(posedge clk or posedge rst) begin
      if (rst) begin
         state <= WAIT; cnt <= 4'h0;
         we <= 0; wd <= 8'h0; re <= 0;
         lbus_a <= 16'h0; lbus_dw <= 16'h0; lbus_rd <= 1; lbus_wr <= 1;
     data_read <= 0;
      end else
        case (state)
          WAIT: begin
       if (start_pc_to_lsi) begin
    state <= ADDR; re <= 1;
    lbus_a <= addr_in;
    lbus_dw <= data_write;
    cmd <= cmd_in;
    cnt <= 0;
       end
          end
          ADDR: begin
       if (cnt == 7) begin state <= CMD; end
       cnt <= cnt + 1;
    end
      CMD: begin
         if      (cmd == 8'h00) state <= RD0;
         else if (cmd == 8'h01) state <= WR0;
         else                   state <= TRAP;
      end
      RD0: begin
       lbus_rd <= 0; cnt <= 0; state <= RD1;
    end
    RD1: begin
       if (cnt == 7) begin state <= RD2; end
       cnt <= cnt + 1;
          end
    RD2: begin
       data_read <= lbus_dr; lbus_rd <= 1; state <= RD3;
    end
      RD3: begin state <= WAIT; end
      WR0: begin
       lbus_wr <= 0; cnt <= 0; state <= WR1;
    end
    WR1: begin
       if (cnt == 7) begin state <= WR2; end
       cnt <= cnt + 1;
      end
    WR2: begin
       lbus_wr <= 1; state <= WAIT;
    end
      TRAP: begin state <= TRAP; end
      endcase // case (state)
   end // always @ (posedge clk or posedge rst)
   assign start_lsi_to_pc = (state == RD3);
   
   
endmodule // LBUS_TRANSCEIVER



//================================================ SW_INTERFACE
module SW_INTERFACE
  (wd, we, ful, aful, rd, re, emp, aemp, rcnt, 
   wd0, we0, ful0, aful0, rd0, re0, emp0, aemp0, rcnt0, 
   wd1, we1, ful1, aful1, rd1, re1, emp1, aemp1, rcnt1, 
   sel);

   //------------------------------------------------
   //
   input [7:0]   wd;
   input         we;
   output        ful, aful;
   output [7:0]  rd;
   input         re;
   output        emp, aemp;
   output [11:0] rcnt;
   // 
   output [7:0]  wd0,          wd1;
   output        we0,          we1;
   input         ful0, aful0,  ful1, aful1;
   input [7:0]   rd0,          rd1;
   output        re0,          re1;
   input         emp0, aemp0,  emp1, aemp1;
   input [11:0]  rcnt0,        rcnt1;
   //
   input         sel;
   
   //------------------------------------------------
   assign wd0  = (sel)? 8'h0  : wd;
   assign we0  = (sel)? 0     : we;
   assign wd1  = (sel)? wd    : 8'h0;
   assign we1  = (sel)? we    : 0;
   assign ful  = (sel)? ful1  : ful0;
   assign aful = (sel)? aful1 : aful0;

   assign rd   = (sel)? rd1   : rd0;
   assign re0  = (sel)? 0     : re;
   assign re1  = (sel)? re    : 0;
   assign emp  = (sel)? emp1  : emp0;
   assign aemp = (sel)? aemp1 : aemp0;
   assign rcnt = (sel)? rcnt1 : rcnt0;
   
endmodule // SW_INTERFACE

