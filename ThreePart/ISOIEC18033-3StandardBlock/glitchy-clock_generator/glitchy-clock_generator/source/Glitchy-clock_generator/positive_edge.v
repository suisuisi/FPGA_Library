/*-------------------------------------------------------------------------
 Pulse edge detector
 
 File name   : positive_edge.v
 Version     : Version 1.0
 Created     : MAY/05/2011
 Last update : MAY/05/2011
 Modified by : Sho Endo
 
-----------------------------------------------------------------
 Copyright (C) 2011  Tohoku University.
 
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

//Outputs the positive edge of signal 
module POSITIVE_EDGE(clk, trig_in, trig_out);
   input clk, trig_in;
   output trig_out;
   
   reg    trig_in_prev;
   reg    trig_out;
   
   always @(posedge clk) begin
      trig_out <= trig_in & !trig_in_prev;
      trig_in_prev <= trig_in;
   end
endmodule // POSITIVE_EDGE

