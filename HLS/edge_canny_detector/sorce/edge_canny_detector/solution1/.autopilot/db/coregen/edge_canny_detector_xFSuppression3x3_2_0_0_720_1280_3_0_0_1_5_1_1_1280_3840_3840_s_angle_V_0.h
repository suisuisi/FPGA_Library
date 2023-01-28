// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0_H__
#define __edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0_H__


#include <systemc>
using namespace sc_core;
using namespace sc_dt;




#include <iostream>
#include <fstream>

struct edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0_ram : public sc_core::sc_module {

  static const unsigned DataWidth = 8;
  static const unsigned AddressRange = 1280;
  static const unsigned AddressWidth = 11;

//latency = 1
//input_reg = 1
//output_reg = 0
sc_core::sc_in <sc_lv<AddressWidth> > address0;
sc_core::sc_in <sc_logic> ce0;
sc_core::sc_in<sc_logic> we0;
sc_core::sc_in<sc_lv<DataWidth> > d0;
sc_core::sc_in <sc_lv<AddressWidth> > address1;
sc_core::sc_in <sc_logic> ce1;
sc_core::sc_out <sc_lv<DataWidth> > q1;
sc_core::sc_in<sc_logic> reset;
sc_core::sc_in<bool> clk;


sc_lv<DataWidth> ram[AddressRange];


   SC_CTOR(edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0_ram) {


SC_METHOD(prc_write_0);
  sensitive<<clk.pos();


SC_METHOD(prc_write_1);
  sensitive<<clk.pos();
   }


void prc_write_0()
{
    if (ce0.read() == sc_dt::Log_1) 
    {
        if (we0.read() == sc_dt::Log_1) 
        {
           if(address0.read().is_01() && address0.read().to_uint()<AddressRange)
           {
              ram[address0.read().to_uint()] = d0.read(); 
           }
        }
    }
}


void prc_write_1()
{
    if (ce1.read() == sc_dt::Log_1) 
    {
            if(address1.read().is_01() && address1.read().to_uint()<AddressRange)
              q1 = ram[address1.read().to_uint()];
            else
              q1 = sc_lv<DataWidth>();
    }
}


}; //endmodule


SC_MODULE(edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0) {


static const unsigned DataWidth = 8;
static const unsigned AddressRange = 1280;
static const unsigned AddressWidth = 11;

sc_core::sc_in <sc_lv<AddressWidth> > address0;
sc_core::sc_in<sc_logic> ce0;
sc_core::sc_in<sc_logic> we0;
sc_core::sc_in<sc_lv<DataWidth> > d0;
sc_core::sc_in <sc_lv<AddressWidth> > address1;
sc_core::sc_in<sc_logic> ce1;
sc_core::sc_out <sc_lv<DataWidth> > q1;
sc_core::sc_in<sc_logic> reset;
sc_core::sc_in<bool> clk;


edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0_ram* meminst;


SC_CTOR(edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0) {
meminst = new edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0_ram("edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0_ram");
meminst->address0(address0);
meminst->ce0(ce0);
meminst->we0(we0);
meminst->d0(d0);

meminst->address1(address1);
meminst->ce1(ce1);
meminst->q1(q1);

meminst->reset(reset);
meminst->clk(clk);
}
~edge_canny_detector_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s_angle_V_0() {
    delete meminst;
}


};//endmodule
#endif
