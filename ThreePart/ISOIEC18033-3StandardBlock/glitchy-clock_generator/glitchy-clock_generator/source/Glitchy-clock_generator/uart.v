/*-------------------------------------------------------------------------
 UART (RS-232) transeiver for SASEBO 
 
 File name   : uart.v
 Version     : Version 1.0
 Created     : MAR/05/2008
 Last update : JUL/25/2008
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


//================================================ UART_BUFFERED
module UART_BUFFERED 
  (tx, rx,                  // UART tx/rx
   wd, we, ful, aful,       // Control signal of tx FIFO
   rd, re, emp, aemp, rcnt, // Control signal of rx FIFO
   err,                     // FIFO overrun
   clk, rst);               // Clock and reset

   //------------------------------------------------
   //UART tx/rx
   output        tx;        // UART tx
   input         rx;        // UART rx
   // Control signal of tx FIFO
   input [7:0]   wd;        // Write data
   input         we;        // Write enable
   output        ful, aful; // FIFO full / almost full
   // control signal of rx FIFO
   output [7:0]  rd;        // Read data
   input         re;        // Data available
   output        emp, aemp; // FIFO empty / almost empty
   output [11:0] rcnt;      // Data count
   output        err;       // FIFO overrun
   input         clk, rst;  // Clock and reset

   UART_TX_BUFFERED uart_tx 
     (.tx(tx), .wd(wd), .we(we), .ful(ful), .aful(aful),
      .clk(clk), .rst(rst));
   
   UART_RX_BUFFERED uart_rx
     (.rx(rx), .rd(rd), .re(re), .emp(emp), .aemp(aemp), .err(err), .rcnt(rcnt),
      .clk(clk), .rst(rst));
endmodule // UART_BUFFERED



//================================================ UART_TX_BUFFERED
module UART_TX_BUFFERED 
  (tx,                // UART tx
   wd, we, ful, aful, // Control signal of tx FIFO
   clk, rst);         // Clock and reset
   
   //------------------------------------------------
   output      tx; // UART tx
   // Control signal of tx FIFO
   input [7:0] wd;        // Write data
   input       we;        // Write enable
   output      ful, aful; // FIFO full / almost full
   input       clk, rst;  // FIFO empty / almost empty

   //------------------------------------------------
   wire [7:0]  rd;
   reg         re, re1;
   wire        emp, aemp, rd_busy;
   wire        rdy;

   //------------------------------------------------
   SYNCFIFO_8x4095 u0
     (.wd(wd), .we(we), .ful(ful), .aful(aful),
      .rd(rd), .re(re), .emp(emp), .aemp(aemp),
      .cnt(), .clk(clk), .rst(rst));

   assign rd_busy = emp | (aemp & re);

   always @(posedge clk or posedge rst)
     if (rst)                              re <= 0;
     else if (~rd_busy & ~re & ~re1 & rdy) re <= 1;
     else                                  re <= 0;
   
   always @(posedge clk or posedge rst)
     if (rst) re1 <= 0;
     else     re1 <= re;
   
   UART_TX u1 (.tx(tx), .wd(rd), .we(re1), .rdy(rdy), .clk(clk), .rst(rst));
   
endmodule // UART_TX_BUFFERED



//================================================ UART_TX
module UART_TX 
  (tx,          // UART tx
   wd, we, rdy, // Control transmitter
   clk, rst);   // Clock and reset
   parameter   CLK_SCALE = 12'h4E2; // 24MHz -> 19200bps, 19200x1250=24x10^6
   
   //------------------------------------------------
   output      tx; // UART tx
   // Control transmitter
   input [7:0] wd;  // Write data
   input       we;  // Write enable
   output      rdy; // Ready to transmit
   input       clk, rst; // Clock ant reset
   
   //------------------------------------------------
   wire        trig, en, rdy;
   reg [11:0]  cnt;
   reg [8:0]   dat;
   reg         tx;
   reg [3:0]   st;
   
   //------------------------------------------------
   assign trig = we & rdy;

   always @(posedge clk or posedge rst)
     if (rst)                 cnt <= 12'h1;
     else if (rdy)            cnt <= 12'h1;
     else if (cnt==CLK_SCALE) cnt <= 12'h1;
     else                     cnt <= cnt + 12'h1;
   assign en = (cnt==CLK_SCALE);

   always @(posedge clk or posedge rst)
     if (rst)       dat <= 9'b111111111;
     else if (trig) dat <= {wd, 1'b0};
     else if (en)   dat <= {1'b1, dat[8:1]};
   
   always @(posedge clk or posedge rst)
     if (rst) tx <= 1;
     else     tx <= dat[0];

   always @(posedge clk or posedge rst)
     if (rst)             st <= 4'h0;
     else if (trig)       st <= 4'h1;
     else if (en)
       if (st==4'hA)      st <= 4'h0;
       else if (st!=4'h0) st <= st + 4'h1;
   assign rdy = (st==4'h0);
   
endmodule // UART_TX



//================================================ UART_RX_BUFFERED
module UART_RX_BUFFERED 
  (rx,                      // UART rx 
   rd, re, emp, aemp, rcnt, // Control signal of rx FIFO
   err,                     // FIFO overrun
   clk, rst);               // Clock and reset
   
   //------------------------------------------------
   input         rx; // UART rx
   // Control signal of rx FIFO   
   output [7:0]  rd;        // Read data
   input         re;        // Read enable
   output        emp, aemp; // FIFO empty / almost empty
   output [11:0] rcnt;      // Data count
   output        err;       // FIFO overrun
   input         clk, rst;  // Clock and reset
   
   //------------------------------------------------
   wire [7:0]   wd;
   wire         we, ful, aful;
   reg          wd_busy, err;
   
   //------------------------------------------------
   UART_RX u0 (.rx(rx), .rd(wd), .re(we), .clk(clk), .rst(rst));

   SYNCFIFO_8x4095 u1
     (.wd(wd), .we(we), .ful(ful), .aful(aful),
      .rd(rd), .re(re), .emp(emp), .aemp(aemp),
      .cnt(rcnt), .clk(clk), .rst(rst));

   always @(posedge clk or posedge rst)
     if (rst) wd_busy <= 0;
     else     wd_busy <= ful | (aful & we);
   
   always @(posedge clk or posedge rst)
     if (rst)               err <= 0;
     else if (wd_busy & we) err <= 1;

endmodule // UART_RX_BUFFERED



//================================================ UART_RX
module UART_RX 
  (rx,        // UART rx
   rd, re,    // Control signal from receiver
   clk, rst); // Clock and reset
   parameter   CLK_SCALE = 12'h4E2; // 24MHz -> 19200bps, 19200x1250=24x10^6
   
   //------------------------------------------------
   input        rx; // UART rx
   // Control signal from receiver
   output [7:0] rd; // Read data
   output       re; // Data available
   input        clk, rst; // Clock and reset
   
   //------------------------------------------------
   reg          rx1;
   reg [3:0]    rx_buf;
   wire         trig0, en, rdy;
   reg [95:0]   trig1;
   reg          trig;
   reg [11:0]   cnt;
   reg [7:0]    rd;
   reg          re;
   reg [3:0]    st;
   
   //------------------------------------------------
   always @(posedge clk or posedge rst)
     if (rst) rx1 <= 1;
     else     rx1 <= rx;
   
   always @(posedge clk or posedge rst)
     if (rst) rx_buf <= 4'b1111;
     else     rx_buf <= {rx_buf[2:0],rx1};
   assign trig0 = (rx_buf[3:2]==2'b10) & rdy;

   always @(posedge clk) trig1 = {trig0,trig1[95:1]};
   always @(posedge clk) trig = trig1[0];
   
   always @(posedge clk or posedge rst)
     if (rst)                 cnt <= 12'h1;
     else if (rdy)            cnt <= 12'h1;
     else if (cnt==CLK_SCALE) cnt <= 12'h1;
     else                     cnt <= cnt + 12'h1;
   assign en = (cnt==CLK_SCALE);

   always @(posedge clk or posedge rst)
     if (rst)                rd <= 8'h0;
     else if (en&(st<=4'h8)) rd <= {rx1,rd[7:1]};

   always @(posedge clk or posedge rst)
     if (rst)        st <= 4'h0;
     else if (trig)  st <= 4'h1;
     else if (en)
       if (st==4'h9) st <= 4'h0;
       else          st <= st + 4'h1;
   assign rdy = (st==4'h0);

   always @(posedge clk or posedge rst)
     if (rst)                re <= 0;
     else if (en&(st==4'h8)) re <= 1;
     else                    re <= 0;
   
endmodule // UART_RX
