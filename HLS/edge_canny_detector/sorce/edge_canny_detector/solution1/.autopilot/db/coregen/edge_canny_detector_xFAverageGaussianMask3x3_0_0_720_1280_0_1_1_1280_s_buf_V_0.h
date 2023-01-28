// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2020.2 (64-bit)
// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_H__
#define __edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_H__


#include <systemc>
using namespace sc_core;
using namespace sc_dt;




#include <iostream>
#include <fstream>

struct edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram : public sc_core::sc_module {

  static const unsigned DataWidth = 8;
  static const unsigned AddressRange = 1280;
  static const unsigned AddressWidth = 11;

//latency = 1
//input_reg = 1
//output_reg = 0
sc_core::sc_in <sc_lv<AddressWidth> > address0;
sc_core::sc_in <sc_logic> ce0;
sc_core::sc_out <sc_lv<DataWidth> > q0;
sc_core::sc_in <sc_lv<AddressWidth> > address1;
sc_core::sc_in <sc_logic> ce1;
sc_core::sc_in<sc_logic> we1;
sc_core::sc_in<sc_lv<DataWidth> > d1;
sc_core::sc_in<sc_logic> reset;
sc_core::sc_in<bool> clk;


sc_lv<DataWidth> ram[AddressRange];


   SC_CTOR(edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram) {


SC_METHOD(prc_write_0);
  sensitive<<clk.pos();


SC_METHOD(prc_write_1);
  sensitive<<clk.pos();
   }


void prc_write_0()
{
    if (ce0.read() == sc_dt::Log_1) 
    {
            if(address0.read().is_01() && address0.read().to_uint()<AddressRange)
              q0 = ram[address0.read().to_uint()];
            else
              q0 = sc_lv<DataWidth>();
    }
}


void prc_write_1()
{
    if (ce1.read() == sc_dt::Log_1) 
    {
        if (we1.read() == sc_dt::Log_1) 
        {
           if(address1.read().is_01() && address1.read().to_uint()<AddressRange)
           {
              ram[address1.read().to_uint()] = d1.read(); 
           }
        }
    }
}


}; //endmodule


SC_MODULE(edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0) {


static const unsigned DataWidth = 8;
static const unsigned AddressRange = 1280;
static const unsigned AddressWidth = 11;

sc_core::sc_in <sc_lv<AddressWidth> > address0;
sc_core::sc_in<sc_logic> ce0;
sc_core::sc_out <sc_lv<DataWidth> > q0;
sc_core::sc_in <sc_lv<AddressWidth> > address1;
sc_core::sc_in<sc_logic> ce1;
sc_core::sc_in<sc_logic> we1;
sc_core::sc_in<sc_lv<DataWidth> > d1;
sc_core::sc_in<sc_logic> reset;
sc_core::sc_in<bool> clk;


edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram* meminst;


SC_CTOR(edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0) {
meminst = new edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram("edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0_ram");
meminst->address0(address0);
meminst->ce0(ce0);
meminst->q0(q0);

meminst->address1(address1);
meminst->ce1(ce1);
meminst->we1(we1);
meminst->d1(d1);

meminst->reset(reset);
meminst->clk(clk);
}
~edge_canny_detector_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s_buf_V_0() {
    delete meminst;
}


};//endmodule
#endif
