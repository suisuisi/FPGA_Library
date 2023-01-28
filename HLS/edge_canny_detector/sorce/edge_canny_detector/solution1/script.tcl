############################################################
## This file is generated automatically by Vitis HLS.
## Please DO NOT edit it.
## Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
############################################################
open_project edge_canny_detector
set_top edge_canny_detector
add_files source/edge_canny_detector.cpp -cflags "-IE:/FILE/HLS/Vitis_Libraries/vision/L1/include -std=c++0x -IE:/FILE/HLS/vitis_hls_tutorialV0/edge_canny_detector/source -I./. -D__SDSVHLS__ -std=c++0x" -csimflags "-IE:/FILE/HLS/Vitis_Libraries/vision/L1/include -std=c++0x -IE:/FILE/HLS/vitis_hls_tutorialV0/edge_canny_detector/source -I./. -D__SDSVHLS__ -std=c++0x"
open_solution "solution1" -flow_target vivado
set_part {xc7z020clg400-2}
create_clock -period 10 -name default
config_export -format ip_catalog -rtl verilog
source "./edge_canny_detector/solution1/directives.tcl"
#csim_design
csynth_design
#cosim_design
export_design -rtl verilog -format ip_catalog
