// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __edge_canny_detector_mac_muladd_8ns_13ns_22ns_22_4_1__HH__
#define __edge_canny_detector_mac_muladd_8ns_13ns_22ns_22_4_1__HH__
#include "simcore_mac_0.h"
#include <systemc>

template<
    int ID,
    int NUM_STAGE,
    int din0_WIDTH,
    int din1_WIDTH,
    int din2_WIDTH,
    int dout_WIDTH>
SC_MODULE(edge_canny_detector_mac_muladd_8ns_13ns_22ns_22_4_1) {
    sc_core::sc_in_clk clk;
    sc_core::sc_in<sc_dt::sc_logic> reset;
    sc_core::sc_in<sc_dt::sc_logic> ce;
    sc_core::sc_in< sc_dt::sc_lv<din0_WIDTH> >   din0;
    sc_core::sc_in< sc_dt::sc_lv<din1_WIDTH> >   din1;
    sc_core::sc_in< sc_dt::sc_lv<din2_WIDTH> >   din2;
    sc_core::sc_out< sc_dt::sc_lv<dout_WIDTH> >   dout;



    simcore_mac_0<ID, 4, din0_WIDTH, din1_WIDTH, din2_WIDTH, dout_WIDTH> simcore_mac_0_U;

    SC_CTOR(edge_canny_detector_mac_muladd_8ns_13ns_22ns_22_4_1):  simcore_mac_0_U ("simcore_mac_0_U") {
        simcore_mac_0_U.clk(clk);
        simcore_mac_0_U.reset(reset);
        simcore_mac_0_U.ce(ce);
        simcore_mac_0_U.din0(din0);
        simcore_mac_0_U.din1(din1);
        simcore_mac_0_U.din2(din2);
        simcore_mac_0_U.dout(dout);

    }

};

#endif //
