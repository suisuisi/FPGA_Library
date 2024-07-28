/*-------------------------------------------------------------------------
 n-adic counter
 
 File name   : cnt_n.v
 Version     : Version 1.0
 Created     : JUN/30/2010
 Last update : OCT/05/2010
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

module CNT_N(clk, rstn, n, exec, cnt);
   input clk, rstn, exec;
   input  [31:0] n;
   output [31:0] cnt;
   reg    [31:0] cnt;
   reg           counting;

   always @(posedge clk) begin
      if (rstn == 1'b0) begin
         cnt <= 0;
         counting <= 1'b0;
      end else begin
         if (exec) begin
            if (!counting) begin
               counting <= 1'b1;
               cnt <= 0;
            end
         end else begin
            if (counting) begin
               counting <= 1'b0;
            end
         end
         if (counting) begin
            cnt <= cnt + 1;
            if (cnt >= n) begin
               cnt <= 0;
            end
         end
      end
   end

endmodule
