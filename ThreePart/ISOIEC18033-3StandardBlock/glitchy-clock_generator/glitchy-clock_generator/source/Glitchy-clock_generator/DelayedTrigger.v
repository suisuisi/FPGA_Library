/*-------------------------------------------------------------------------
 Delayed trigger
 
 File name   : DelayedTrigger.v
 Version     : Version 1.0
 Created     : JUL/30/2010
 Last update : MAY/05/2011
 Desgined by : Sho Endo
 
-----------------------------------------------------------------
 Copyright (C) 2010 - 2011 Tohoku University
 
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
//rst_in is positive
//switches are positive
//segled_out are positive
//sel_segled_out are negative

module DELAYED_TRIGGER (clk, rst_in, max_cnt, max_cnt_fine, trig_in, trig_out);
   input        clk, rst_in, trig_in;
   input [15:0] max_cnt, max_cnt_fine;
   output       trig_out;
   wire         trig_coarse;

   //Fine adjustment of delay
   CNT1TIME DELAY_FINE(clk, rst_in, trig_in, max_cnt_fine, trig_coarse);
   //Adjustment in the number of montmult blocks
   CNT_PULSE DELAY_COARSE(clk, rst_in, trig_coarse, max_cnt, trig_out);
   
endmodule

//Delay counter
//Counts the number of clk
module CNT_DELAY(clk, rst, trig_in, cnt_max, trig_out);
   input        clk, rst, trig_in;
   input [15:0] cnt_max;
   output       trig_out;
   
   reg          trig_out;
   reg [15:0]   cnt;
   
   always @(posedge clk) begin
      if (rst || trig_in) begin
         cnt <= 16'h0000;
         trig_out <= 0;
      end else begin
         if (cnt < cnt_max) begin
            cnt <= cnt + 16'h0001;
            trig_out <= 0;
         end else begin
            cnt <= 16'h0000;
            trig_out <= 1;
         end
      end
   end
endmodule

//One-time counter
//Starts with a rising edge of trig_in
//Setops when the counter reaches maximum value
//When trig_in = 0, resets
module CNT1TIME(clk, rst, trig_in, cnt_max, trig_out);
   input        clk, rst, trig_in;
   input [15:0] cnt_max;
   output       trig_out;

   wire         trig_edge;
   reg          trig_out;
   reg [15:0]   cnt;

   POSITIVE_EDGE positive_edge(clk, trig_in, trig_edge);
   
   always @(posedge clk) begin
      if (rst) begin
         cnt <= 16'h0000;
         trig_out <= 0;
      end else begin
         if (trig_edge) cnt <= 16'h0001;
         else if (cnt == 16'h0000) trig_out <= 0;
         else if (cnt > 16'h0000) begin
            if (cnt < cnt_max) begin
               cnt <= cnt + 16'h0001;
               trig_out <= 0;
            end else begin
               cnt <= 16'h0000;
               trig_out <= 1;
            end
         end
      end
   end
endmodule

//Pulse counter
//Counts the number of pulse on trig_in
module CNT_PULSE(clk, rst, start_in, cnt_max, trig_out);
   input        clk, rst, start_in;
   input [15:0] cnt_max;
   output       trig_out;
   
   parameter CLK_1MONT = 16'h0241;//16'h0241;
   
   reg          counting;
   reg          trig_out;
   reg [15:0]   cnt;
   wire         clk_1mont_out;
   
   //Counts clock pulses for 577 cycles
   CNT_DELAY CNT_1MONT(clk, rst, start_in, CLK_1MONT, clk_1mont_out);
   
   always @(posedge clk) begin
      if (rst) begin
         cnt <= 16'h0000;
         trig_out <= 0;
         counting <= 0;
      end else begin
         if (start_in) begin
            counting <= 1;
            trig_out <= 0;
         end else if (counting) begin
            if (clk_1mont_out) begin
               if (cnt < cnt_max) begin
                  cnt <= cnt + 16'h0001;
               end else begin
                  cnt <= 16'h0000;
                  trig_out <= 1;
                  counting <= 0;
               end
            end else begin
               trig_out <= 0;
            end
         end
      end
   end
endmodule

