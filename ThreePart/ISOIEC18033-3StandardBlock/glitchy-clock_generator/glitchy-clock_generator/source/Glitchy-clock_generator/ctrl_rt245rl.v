/*-------------------------------------------------------------------------
 SASEBO-G controller (for FPGA cryptographic module)
 
 File name   : ctrl_ft245rl.v
 Version     : Version 1.0
 Created     : Aug/08/2008
 Last update : Aig/08/2008
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


//================================================ CTRL_FT245RL_BUFFERED
module CTRL_FT245RL_BUFFERED
  (// FT245RL
   usb_d, usb_rdn, usb_wr, usb_rxfn, usb_txen, usb_pwen,
   // Control signals of FT245RL FIFO
   rd, re, emp, aemp, wd, we, ful, aful, rcnt,
   // Clock and reset
   clk, rst);

   //------------------------------------------------
   // FT245RL
   inout [7:0]   usb_d;
   output        usb_rdn, usb_wr;
   input         usb_rxfn, usb_txen;
   input         usb_pwen;
   // Control signals of FT245RL FIFO
   input [7:0]   wd;
   input         we;
   output        ful, aful;
   output [7:0]  rd;
   input         re;
   output        emp, aemp;
   output [11:0] rcnt;
   // Clock and reset
   input        clk, rst;

   //------------------------------------------------
   wire [7:0]   sf_wd,                   sf_rd;
   wire         sf_we, sf_ful, sf_aful,  sf_re, sf_emp, sf_aemp;

   //------------------------------------------------
   SYNCFIFO_8x4095 tx_fifo
     (.wd(wd), .we(we), .ful(ful), .aful(aful),
      .rd(sf_rd), .re(sf_re), .emp(sf_emp), .aemp(sf_aemp),
      .cnt(), .clk(clk), .rst(rst));

   SYNCFIFO_8x4095 rx_fifo
     (.wd(sf_wd), .we(sf_we), .ful(sf_ful), .aful(sf_aful),
      .rd(rd), .re(re), .emp(emp), .aemp(aemp),
      .cnt(rcnt), .clk(clk), .rst(rst));

   CTRL_FT245RL ctrl_ft245rl
     (// FT245RL
      .usb_d(usb_d), .usb_rdn(usb_rdn), .usb_wr(usb_wr),
      .usb_rxfn(usb_rxfn), .usb_txen(usb_txen), .usb_pwen(usb_pwen),
      // Control signals of FT245RL FIFO
      .wd(sf_wd), .we(sf_we), .ful(sf_ful), .aful(sf_aful),
      .rd(sf_rd), .re(sf_re), .emp(sf_emp), .aemp(sf_aemp),
      // Clock and reset
      .clk(clk), .rst(rst));

endmodule // CTRL_FT245RL_BUFFERED



//================================================ CTRL_FT245RL
module CTRL_FT245RL
  (// FT245RL
   usb_d, usb_rdn, usb_wr, usb_rxfn, usb_txen, usb_pwen,
   // Control signals of FT245RL FIFO
   wd, we, ful, aful, rd, re, emp, aemp,
   // Clock and reset
   clk, rst);

   //------------------------------------------------
   // FT245RL
   inout [7:0]  usb_d;
   output       usb_rdn, usb_wr;
   input        usb_rxfn, usb_txen;
   input        usb_pwen;
   // Control signals of FT245RL FIFO
   input [7:0]  rd;
   output       re;
   input        emp, aemp;
   output [7:0] wd;
   output       we;
   input        ful, aful;
   // clock, reset
   input        clk, rst;
   
   //------------------------------------------------
   reg [3:0]    state;
   reg          pwen_reg, txen_reg, rxfn_reg;
   reg [7:0]    usb_wd;
   reg          usb_wdt;
   wire [7:0]   usb_rd;
   reg          usb_wr, usb_rdn;
   reg [7:0]    wd;
   reg          we, re;
   wire         rd_busy, wr_busy;
   
   //------------------------------------------------
   parameter [3:0] WAIT  = 4'h0,
                   IDLE0 = 4'h1,
                   WR0   = 4'h2,
                   WR1   = 4'h3,
                   WR2   = 4'h4,
                   WR3   = 4'h5,
                   WR4   = 4'h6,
                   WR5   = 4'h7,
                   WR6   = 4'h8,
                   IDLE1 = 4'h9,
                   RD0   = 4'hA,
                   RD1   = 4'hB,
                   RD2   = 4'hC,
                   RD3   = 4'hD,
                   RD4   = 4'hE,
                   RD5   = 4'hF;
                
   //------------------------------------------------
   assign rd_busy = emp | (aemp & re);
   assign wr_busy = ful | (aful & we);

   always @(posedge clk) pwen_reg <= usb_pwen;
   always @(posedge clk) txen_reg <= usb_txen;
   always @(posedge clk) rxfn_reg <= usb_rxfn;

   assign usb_d = (usb_wdt)? 8'hzz : usb_wd;
   assign usb_rd = usb_d;
   
   //------------------------------------------------
   always @(posedge clk or posedge rst) begin
      if (rst) begin
         state <= WAIT;
         usb_wd <= 8'h00; usb_wdt <= 1; usb_wr <= 0; usb_rdn <= 1;
         wd <= 8'h00; we <= 0; re <= 0;
      end else 
        case (state)
          //--------
          WAIT: begin
             if (pwen_reg) state <= WAIT;
             else          state <= IDLE0;
          end

          //-------- write
          IDLE0: begin // IDLE_WR
             if (rd_busy|txen_reg) begin state <= IDLE1; re <= 0; end
             else                  begin state <= WR0;   re <= 1; end
          end
          
          WR0: begin state <= WR1; re <= 0; usb_wr <= 1; end
          WR1: begin state <= WR2; usb_wd <= rd; usb_wdt <= 0; end
          WR2: begin state <= WR3; end
          WR3: begin state <= WR4; usb_wr <= 0; end
          WR4: begin state <= WR5; usb_wdt <= 1; end
          WR5: begin state <= WR6; end
          WR6: begin state <= IDLE0; end
          
          //-------- read
          IDLE1: begin // IDLE_RD
             if (wr_busy|rxfn_reg) begin state <= IDLE0; usb_rdn <= 1; end
             else                  begin state <= RD0;   usb_rdn <= 0; end
          end
          
          RD0: begin state <= RD1; end
          RD1: begin state <= RD2; wd <= usb_rd; we <= 1; end
          RD2: begin state <= RD3; we <= 0; usb_rdn <= 1; end
          RD3: begin state <= RD4; end
          RD4: begin state <= RD5; end
          RD5: begin state <= IDLE1; end
        endcase // case IDLE0
   end // always @ (posedge clk or posedge rst)
      
endmodule // CTRL_RT245RL
