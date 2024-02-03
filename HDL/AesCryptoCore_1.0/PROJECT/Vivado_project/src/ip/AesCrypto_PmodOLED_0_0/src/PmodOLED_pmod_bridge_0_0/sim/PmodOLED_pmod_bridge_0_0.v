// (c) Copyright 1995-2019 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: digilentinc.com:ip:pmod_bridge:1.0
// IP Revision: 12

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module PmodOLED_pmod_bridge_0_0 (
  in_bottom_bus_I,
  in_bottom_bus_O,
  in_bottom_bus_T,
  in0_I,
  in1_I,
  in2_I,
  in3_I,
  in0_O,
  in1_O,
  in2_O,
  in3_O,
  in0_T,
  in1_T,
  in2_T,
  in3_T,
  out0_I,
  out1_I,
  out2_I,
  out3_I,
  out4_I,
  out5_I,
  out6_I,
  out7_I,
  out0_O,
  out1_O,
  out2_O,
  out3_O,
  out4_O,
  out5_O,
  out6_O,
  out7_O,
  out0_T,
  out1_T,
  out2_T,
  out3_T,
  out4_T,
  out5_T,
  out6_T,
  out7_T
);

(* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 GPIO_Bottom_Row TRI_I" *)
output wire [3 : 0] in_bottom_bus_I;
(* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 GPIO_Bottom_Row TRI_O" *)
input wire [3 : 0] in_bottom_bus_O;
(* X_INTERFACE_INFO = "xilinx.com:interface:gpio:1.0 GPIO_Bottom_Row TRI_T" *)
input wire [3 : 0] in_bottom_bus_T;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row SS_I" *)
output wire in0_I;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row IO0_I" *)
output wire in1_I;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row IO1_I" *)
output wire in2_I;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row SCK_I" *)
output wire in3_I;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row SS_O" *)
input wire in0_O;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row IO0_O" *)
input wire in1_O;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row IO1_O" *)
input wire in2_O;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row SCK_O" *)
input wire in3_O;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row SS_T" *)
input wire in0_T;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row IO0_T" *)
input wire in1_T;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row IO1_T" *)
input wire in2_T;
(* X_INTERFACE_INFO = "xilinx.com:interface:spi:1.0 SPI_Top_Row SCK_T" *)
input wire in3_T;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN1_I" *)
input wire out0_I;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN2_I" *)
input wire out1_I;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN3_I" *)
input wire out2_I;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN4_I" *)
input wire out3_I;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN7_I" *)
input wire out4_I;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN8_I" *)
input wire out5_I;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN9_I" *)
input wire out6_I;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN10_I" *)
input wire out7_I;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN1_O" *)
output wire out0_O;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN2_O" *)
output wire out1_O;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN3_O" *)
output wire out2_O;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN4_O" *)
output wire out3_O;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN7_O" *)
output wire out4_O;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN8_O" *)
output wire out5_O;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN9_O" *)
output wire out6_O;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN10_O" *)
output wire out7_O;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN1_T" *)
output wire out0_T;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN2_T" *)
output wire out1_T;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN3_T" *)
output wire out2_T;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN4_T" *)
output wire out3_T;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN7_T" *)
output wire out4_T;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN8_T" *)
output wire out5_T;
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN9_T" *)
output wire out6_T;
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME Pmod_out, BOARD.ASSOCIATED_PARAM PMOD" *)
(* X_INTERFACE_INFO = "digilentinc.com:interface:pmod:1.0 Pmod_out PIN10_T" *)
output wire out7_T;

  pmod_concat #(
    .Top_Row_Interface("SPI"),
    .Bottom_Row_Interface("GPIO")
  ) inst (
    .in_top_bus_I(),
    .in_top_bus_O(4'B0),
    .in_top_bus_T(4'B0),
    .in_top_uart_gpio_bus_I(),
    .in_top_uart_gpio_bus_O(2'B1),
    .in_top_uart_gpio_bus_T(2'B1),
    .in_top_i2c_gpio_bus_I(),
    .in_top_i2c_gpio_bus_O(2'B1),
    .in_top_i2c_gpio_bus_T(2'B1),
    .in_bottom_bus_I(in_bottom_bus_I),
    .in_bottom_bus_O(in_bottom_bus_O),
    .in_bottom_bus_T(in_bottom_bus_T),
    .in_bottom_uart_gpio_bus_I(),
    .in_bottom_uart_gpio_bus_O(2'B1),
    .in_bottom_uart_gpio_bus_T(2'B1),
    .in_bottom_i2c_gpio_bus_I(),
    .in_bottom_i2c_gpio_bus_O(2'B1),
    .in_bottom_i2c_gpio_bus_T(2'B1),
    .in0_I(in0_I),
    .in1_I(in1_I),
    .in2_I(in2_I),
    .in3_I(in3_I),
    .in4_I(),
    .in5_I(),
    .in6_I(),
    .in7_I(),
    .in0_O(in0_O),
    .in1_O(in1_O),
    .in2_O(in2_O),
    .in3_O(in3_O),
    .in4_O(1'B1),
    .in5_O(1'B1),
    .in6_O(1'B1),
    .in7_O(1'B1),
    .in0_T(in0_T),
    .in1_T(in1_T),
    .in2_T(in2_T),
    .in3_T(in3_T),
    .in4_T(1'B1),
    .in5_T(1'B1),
    .in6_T(1'B1),
    .in7_T(1'B1),
    .out0_I(out0_I),
    .out1_I(out1_I),
    .out2_I(out2_I),
    .out3_I(out3_I),
    .out4_I(out4_I),
    .out5_I(out5_I),
    .out6_I(out6_I),
    .out7_I(out7_I),
    .out0_O(out0_O),
    .out1_O(out1_O),
    .out2_O(out2_O),
    .out3_O(out3_O),
    .out4_O(out4_O),
    .out5_O(out5_O),
    .out6_O(out6_O),
    .out7_O(out7_O),
    .out0_T(out0_T),
    .out1_T(out1_T),
    .out2_T(out2_T),
    .out3_T(out3_T),
    .out4_T(out4_T),
    .out5_T(out5_T),
    .out6_T(out6_T),
    .out7_T(out7_T)
  );
endmodule
