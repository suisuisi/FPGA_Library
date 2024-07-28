/*-------------------------------------------------------------------------
 SASEBO controller with glitchy-clock generator
 
 File name   : controller_with_glitcher.v
 Version     : Version 1.1
 Created     : AUG/08/2008
 Last update : MAY/05/2011
 Desgined by : Toshihiro Katashita
 Modified by : Sho Endo
 
-----------------------------------------------------------------
 Copyright (C) 2008 - 2011  Tohoku University and AIST.
 
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

module CONTROLLER_WITH_GLITCHER_TOP
  (rs232_tx, rs232_rx,                         // RS-232
   usb_d, usb_rdn, usb_wr, usb_rxfn, usb_txen, usb_pwen, // FT245R
   lbus_a, lbus_dw, lbus_dr, lbus_wr, lbus_rd, // Local bus
   clkin, rstnin, oscx, hrstn, exec_in, led, if_sel, start_enc, 
   clkshift, clk_dcm_sw);
//Clock, reset, glitchy-clock output, led, interface select input, encryption start output.

   //------------------------------------------------
   //For counter
   input exec_in;
   // RS-232
   output        rs232_tx; // TX line
   input         rs232_rx; // RX line
   
   // FT245R
   inout [7:0]  usb_d;
   output       usb_rdn, usb_wr;
   input        usb_rxfn, usb_txen;
   input        usb_pwen;

   // Local bus
   output [15:0] lbus_a;  // Address
   output [15:0] lbus_dw; // Input data  (Controller -> Cryptographic module)
   output        lbus_wr; // Assert input data
   input [15:0]  lbus_dr; // Output data (Cryptographic module -> Controller)
   output        lbus_rd; // Assert output data
   
   // clock, led
   input         clkin, rstnin; // Clock and reset input
   output        oscx, hrstn;   // Clock and reset output to FPGA
   output [3:0]  led;           // LED
   input         if_sel;
   output        start_enc;     //Encryption start

   //Debug
   output        clkshift, clk_dcm_sw;
   //------------------------------------------------
   // Internal clock
   wire         clk, rst;

   // LBUS I/F
   wire [7:0]   wd,             rd;
   wire         we, ful, aful,  re, emp, aemp;
   wire [11:0]  rcnt;
   // UART
   wire [7:0]   uart_wd, uart_rd;
   wire         uart_we, uart_ful, uart_aful, uart_re, uart_emp, uart_aemp;
   wire         uart_err;
   wire [11:0]  uart_rcnt;

   // FT245RL
   wire [7:0]   usb_wd, usb_rd;
   wire         usb_we, usb_ful, usb_aful, usb_re, usb_emp, usb_aemp;
   wire [11:0]  usb_rcnt;

   //Wires between LBUS_TRANSCEIVER and PC_TRANSCEIVER
   wire [15:0]  addr, data_write, data_read, data_param;
   wire         glitch_en;
   wire         start_pc_to_lsi, start_lsi_to_pc;
   wire         start_config_write, start_config_read;
   wire [7:0]   cmd; //Command from PC(0 = read, 1 = write, 2 = FPGA config)

   wire [31:0]  out_counter;
   //wire [1:0]    dcm_locked;
   wire         start_enc; //Asserted when cipher is kicked
   
   //Wires for parameters of glitch
   wire [15:0]  glitch_width, glitch_period, glitch_pos, glitch_pos_fine;

   //Is DLL Locked?, Buffered clock input
   wire dll_locked , clk_orig_buffered;

   //------------------------ Assignments -----------------------

   //Reset signal to FPGA
   assign hrstn  = ~rst;

   //Output the most significant four bits
   assign led[3:0] = ~glitch_width[7:4];
   
   //--------------------------- Modules ------------------------------

   //Count the execution time of cryptographic operation
   CNT_N cnt_n(.clk(clk), .rstn(rstnin), .n(32'hffffffff), 
               .exec(exec_in), .cnt(out_counter));

   //---------------- Communication between FPGA and PC ---------------
   
   //USB driver
   CTRL_FT245RL_BUFFERED ctrl_ft245rl_buffered
     (.usb_d(usb_d), .usb_rdn(usb_rdn), .usb_wr(usb_wr),
      .usb_rxfn(usb_rxfn), .usb_txen(usb_txen), .usb_pwen(usb_pwen),
      .wd(usb_wd), .we(usb_we), .ful(usb_ful), .aful(usb_aful),
      .rd(usb_rd), .re(usb_re), .emp(usb_emp), .aemp(usb_aemp),
      .rcnt(usb_rcnt), .clk(clk), .rst(rst));

   //Serial port driver
   UART_BUFFERED uart_buffered 
     (.tx(rs232_tx), .rx(rs232_rx),
      .wd(uart_wd), .we(uart_we), .ful(uart_ful), .aful(uart_aful),
      .rd(uart_rd), .re(uart_re), .emp(uart_emp), .aemp(uart_aemp),
      .err(uart_err), .rcnt(uart_rcnt), .clk(clk), .rst(rst));

   //Implementation of ommunication protocol
   PC_TRANSCEIVER comm_pc
     (.addr(addr), .data_write(data_write), .data_read(data_read),
      .data_param(data_param), .start_pc_to_lsi(start_pc_to_lsi), 
      .start_lsi_to_pc(start_lsi_to_pc), 
      .start_config_write(start_config_write), 
      .start_config_read(start_config_read), 
      .cmd_out(cmd), .start_enc(start_enc), 
      .wd(wd), .we(we), .ful(ful), .aful(aful),
      .rd(rd), .re(re), .emp(emp), .aemp(aemp), .rcnt(rcnt),
      .clk(clk), .rst(rst));

   //Switch interface (USB or serial)
   SW_INTERFACE sw_interface
     (.wd(wd), .we(we), .ful(ful), .aful(aful),
      .rd(rd), .re(re), .emp(emp), .aemp(aemp), .rcnt(rcnt), 
      .wd0(uart_wd), .we0(uart_we), .ful0(uart_ful), .aful0(uart_aful),
      .rd0(uart_rd), .re0(uart_re), .emp0(uart_emp), .aemp0(uart_aemp),
      .rcnt0(uart_rcnt), 
      .wd1(usb_wd), .we1(usb_we), .ful1(usb_ful), .aful1(usb_aful),
      .rd1(usb_rd), .re1(usb_re), .emp1(usb_emp), .aemp1(usb_aemp),
      .rcnt1(usb_rcnt), 
      .sel(~if_sel));

   //Buffer stores parameters from PC
   PARAMS_IN_BUFFER params_in_buffer 
     (.config_enable(start_config_write), .cmd(cmd), 
      .addr(addr), 
      .data_write(data_write), 
      .glitch_width(glitch_width), .glitch_period(glitch_period), 
      .glitch_pos(glitch_pos), .glitch_pos_fine(glitch_pos_fine), 
      .glitch_en(glitch_en), .clk(clk), .rst(rst));

   //Buffer stores parameters which is sent to PC
   PARAMS_READ_BUFFER params_read_buffer
     (.config_enable(start_config_read), .cmd(cmd), .addr(addr), 
      .exec_time_cnt(out_counter), .data_read(data_param), .clk(clk), 
      .rst(rst));

   //-------- Communication between FPGA and Cryptographic LSI --------
   
   LBUS_TRANSCEIVER comm_lsi
     (.addr_in(addr), .data_write(data_write), .data_read(data_read),
      .start_pc_to_lsi(start_pc_to_lsi), .start_lsi_to_pc(start_lsi_to_pc),
      .cmd_in(cmd), .lbus_a(lbus_a),.lbus_dw(lbus_dw), .lbus_dr(lbus_dr),
      .lbus_wr(lbus_wr), .lbus_rd(lbus_rd), 
      .clk(clk), .rst(rst));

   MK_CLKRST mk_clkrst(.clkin(clkin), .rstnin(rstnin), .dll_locked(dll_locked), 
      .clk_orig_buffered(clk_orig_buffered), .clkout(clk), .rstout(rst));

   //-------------------- Glitchy-clock generator --------------------

   GLITCH_GEN glitch_gen
     (.clk_orig(clk_orig_buffered), .clk(clk), .rstnin(rstnin), 
      .phase(glitch_period[7:0]), 
      .phase_sw(glitch_width[7:0]), .glitch_pos(glitch_pos), 
      .glitch_pos_fine(glitch_pos_fine), 
      .glitch_en(glitch_en), .start_enc(start_enc), 
      .dll_locked(dll_locked), 
      .clkshift(clkshift), .clk_dcm_sw(clk_dcm_sw), .clkout(oscx));

endmodule // CONTROLLER_WITH_GLITCHER

   
//================================================ MK_CLKRST
module MK_CLKRST (clkin, rstnin, dll_locked, clk_orig_buffered, clkout, rstout);

   input     clkin, rstnin, dll_locked;
   output    clk_orig_buffered, clkout, rstout;
   wire      clk_dll_out, rst_dll, locked_u11; 
   
   //------------------------------------------------ dll reset
   MASTER_RST u00 (.clk(clk_orig_buffered), .rst(rst_dll));
   //------------------------------------------------ clock

   IBUFG u10 (.I(clkin), .O(clk_orig_buffered));
   
   DCM   u11 (.CLKIN(clk_orig_buffered), .CLKFB(clkout), .RST(rst_dll),
              .PSEN(1'b0), .PSINCDEC (1'b0), .PSCLK(1'b0), .DSSEN(1'b0),
              .CLK180(),
              .CLK0(clk_dll_out), .STATUS(), .LOCKED(locked_u11), .PSDONE());

   BUFG  u12 (.I(clk_dll_out),   .O(clkout));

   //------------------------------------------------ reset
   MK_RST_BUFG u20 (.locked(dll_locked & locked_u11 & rstnin), 
          .clk(clkout), .rst(rstout));
endmodule // MK_CLKRST


//================================================ MASTER_RST
module MASTER_RST (clk, rst);
   //synthesis attribute keep_hierarchy of MASTER_RST is no;

   //------------------------------------------------
   input  clk;
   output rst;

   //------------------------------------------------
   wire   rst_srl;
   
   //------------------------------------------------
   SRL16 u00 (.D(1'b0), .CLK(clk), .Q(rst_srl), .A3(1'b1), .A2(1'b1), .A1(1'b1), .A0(1'b1));
   //synthesis attribute INIT of u00 is 16'hFFFF;
   defparam u00.INIT = 16'hFFFF;

   SRL16 u01 (.D(rst_srl), .CLK(clk), .Q(rst), .A3(1'b1), .A2(1'b1), .A1(1'b1), .A0(1'b1));
   //synthesis attribute INIT of u01 is 16'hFFFF;
   defparam u01.INIT = 16'hFFFF;
   
endmodule // MASTER_RST



//================================================ MK_RST_BUFG
module MK_RST_BUFG (locked, clk, rst);
   //synthesis attribute keep_hierarchy of MK_RST_BUFG is no;
   
   //------------------------------------------------
   input  locked, clk;
   output rst;

   //------------------------------------------------
   reg [15:0] rst_reg;
   wire       rst0;
   
   //------------------------------------------------
   always @(posedge clk or negedge locked) 
     if (~locked) rst_reg <= 16'hFFFF;
     else         rst_reg <= {1'b0,rst_reg[15:1]};

   assign rst0 = rst_reg[0];
   //synthesis attribute maxdelay of rstn is 1ns;
   
   BUFG u0 (.I(rst0), .O(rst));
endmodule // MK_RST_BUFG

