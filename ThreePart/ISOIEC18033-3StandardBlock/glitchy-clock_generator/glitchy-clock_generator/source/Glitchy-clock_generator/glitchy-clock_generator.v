/*-------------------------------------------------------------------------
 An on-chip glitchy-clock generator
 
 File name   : glitchy-clock_generator.v
 Version     : Version 1.0
 Created     : MAY/05/2011
 Last update : MAY/05/2011
 Desgined by : Sho Endo
 
-----------------------------------------------------------------
 Copyright (C) 2011 Tohoku University
 
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

//================================================ 
module GLITCH_GEN (clk_orig, clk, rstnin, phase, phase_sw, glitch_pos, 
glitch_pos_fine, glitch_en, start_enc, dll_locked, clkshift, 
clk_dcm_sw, clkout);
   
   //------------------------------------------------
   input        clk_orig, clk, rstnin, glitch_en, start_enc;
   input  [7:0] phase, phase_sw;
   input [15:0] glitch_pos, glitch_pos_fine;
   output       clkshift, clk_dcm_sw, dll_locked, clkout;
   //------------------------------------------------
   wire   clkadj_tmp, clkadj_buf;

   wire   locked_adjust, psdone;
   wire   selclk_latched, clk_dcm_sw;
   wire   trigger_out, trigger_edge;
   wire   dll_locked;

   reg [7:0] offset_glitch;
   reg       shift_enable, incdec, phase_adjustable;

  assign dll_locked = locked_adjust;

   assign clkshift = clkadj_buf;

   // The third DCM generates clock with variable phase shift
   // *** The comment below is attribute for ISE: don't erase
   // synthesis attribute CLKOUT_PHASE_SHIFT of u23 is VARIABLE
   DCM  u23 
   (.CLKIN(clk), .CLKFB(clkadj_buf), .RST(1'b0),
      .PSEN(shift_enable), .PSINCDEC (incdec), .PSCLK(clk_orig), .DSSEN(1'b0),
      .CLK0(clkadj_tmp), .STATUS(), .LOCKED(locked_adjust), .PSDONE(psdone));
   // I/O buffer for u23
   BUFG  u24 (.I(clkadj_tmp), .O(clkadj_buf));

   // Making the timing of switching clock
   DCM_WRAPPER vdcm(clk_orig, ~rstnin, phase_sw, clk_dcm_sw, );

   DELAYED_TRIGGER delayed_trigger 
   (.clk(clk), .rst_in(~rstnin), .max_cnt(glitch_pos), .max_cnt_fine(glitch_pos_fine), 
    .trig_in(start_enc), .trig_out(trigger_out));


   POSITIVE_EDGE positive_edge(clk, trigger_out, trigger_edge);
   assign selclk_latched = trigger_edge & clk_dcm_sw;
   assign clkout = (glitch_en == 0 || selclk_latched == 0) ? clk : clkshift;
   
  always @(posedge clk_orig) begin
    if (~rstnin) begin
      offset_glitch <= 0;
      shift_enable <= 1'b0;
      incdec <= 1'b0;
      phase_adjustable <= 1'b1;
    end else if (phase_adjustable) begin
      if (offset_glitch < phase) begin
        offset_glitch <= offset_glitch + 1;
        shift_enable <= 1'b1;
        phase_adjustable <= 1'b0;
        incdec <= 1'b1;
      end else if (offset_glitch > phase) begin
        offset_glitch <= offset_glitch - 1;
        shift_enable <= 1'b1;
        incdec <= 1'b0;
        phase_adjustable <= 1'b0;
      end else begin
        shift_enable <= 1'b0;
        incdec <= 1'b0;
      end
    end else begin
      shift_enable <= 1'b0;
      incdec <= 1'b0;
    end
    if (rstnin & !phase_adjustable & psdone) begin
      phase_adjustable <= 1'b1;
    end
  end
   
endmodule // GLITCH_GEN
