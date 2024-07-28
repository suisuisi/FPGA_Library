/*-------------------------------------------------------------------------
 Wrapper module of variable-phase DCM
 
 File name   : dcm_vphase_wrapper.v
 Version     : Version 1.0
 Created     : OCT/28/2010
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

module DCM_WRAPPER(clkin, rst, phase, clk_shifted, locked_out);
    input clkin, rst;
    input [7:0] phase;
    output clk_shifted, locked_out;

   wire    clkadj_tmp, clkadj_bufd, psdone;
   wire    out1, out2, out3, out4;
   
   reg [7:0] offset_glitch;
   reg 	     shift_enable, incdec, phase_adjustable;
   
   // synthesis attribute CLKOUT_PHASE_SHIFT of u31 is VARIABLE
   DCM  u31
	 (.CLKIN(clkin), .CLKFB(clkadj_bufd), .RST(rst | config_rst),
      .PSEN(shift_enable), .PSINCDEC (incdec), .PSCLK(clkin), .DSSEN(1'b0),
      .CLK0(clkadj_tmp), .STATUS(), .LOCKED(locked), .PSDONE(psdone));

   assign locked_out = phase_adjustable;
   
   // This is the actual reset circuit that outputs config_rst. It is a four-cycle shift register. 
   FDS flop1 (.D(1'b0), .C(clkin), .Q(out1), .S(1'b0));  
   FD flop2 (.D(out1), .C(clkin), .Q(out2));  
   FD flop3 (.D(out2), .C(clkin), .Q(out3));  
   FD flop4 (.D(out3), .C(clkin), .Q(out4));  

   //config_rst will be asserted for 3 clock cycles. 
   assign config_rst = (out2 | out3 | out4);

   BUFG  u32 (.I(clkadj_tmp), .O(clkadj_bufd));
   assign clk_shifted = clkadj_bufd;
   
   //phase shift
   //If the phase is larger than the target value, 
   // decrease 1 and vice versa
  always @(posedge clkin) begin
    if (rst) begin
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
    if (!rst & !phase_adjustable & psdone) begin
      phase_adjustable <= 1'b1;
    end
  end

endmodule
