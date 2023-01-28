set moduleName xFFindmax3x3_3_0_0_s
set isTopModule 0
set isCombinational 0
set isDatapathOnly 1
set isPipelined 1
set pipeline_type function
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set C_modelName {xFFindmax3x3<3, 0, 0>}
set C_modelType { int 8 }
set C_modelArgList {
	{ p_i00 int 16 regular  }
	{ p_i01 int 16 regular  }
	{ p_i02 int 16 regular  }
	{ p_i10 int 16 regular  }
	{ p_i11 int 16 regular  }
	{ p_i12 int 16 regular  }
	{ p_i20 int 16 regular  }
	{ p_i21 int 16 regular  }
	{ p_i22 int 16 regular  }
	{ angle int 8 regular  }
	{ p_low_threshold uint 8 regular  }
	{ p_high_threshold uint 8 regular  }
}
set C_modelArgMapList {[ 
	{ "Name" : "p_i00", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "p_i01", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "p_i02", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "p_i10", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "p_i11", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "p_i12", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "p_i20", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "p_i21", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "p_i22", "interface" : "wire", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "angle", "interface" : "wire", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "p_low_threshold", "interface" : "wire", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "p_high_threshold", "interface" : "wire", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "ap_return", "interface" : "wire", "bitwidth" : 8} ]}
# RTL Port declarations: 
set portNum 16
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ p_i00 sc_in sc_lv 16 signal 0 } 
	{ p_i01 sc_in sc_lv 16 signal 1 } 
	{ p_i02 sc_in sc_lv 16 signal 2 } 
	{ p_i10 sc_in sc_lv 16 signal 3 } 
	{ p_i11 sc_in sc_lv 16 signal 4 } 
	{ p_i12 sc_in sc_lv 16 signal 5 } 
	{ p_i20 sc_in sc_lv 16 signal 6 } 
	{ p_i21 sc_in sc_lv 16 signal 7 } 
	{ p_i22 sc_in sc_lv 16 signal 8 } 
	{ angle sc_in sc_lv 8 signal 9 } 
	{ p_low_threshold sc_in sc_lv 8 signal 10 } 
	{ p_high_threshold sc_in sc_lv 8 signal 11 } 
	{ ap_return sc_out sc_lv 8 signal -1 } 
	{ ap_ce sc_in sc_logic 1 ce -1 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "p_i00", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i00", "role": "default" }} , 
 	{ "name": "p_i01", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i01", "role": "default" }} , 
 	{ "name": "p_i02", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i02", "role": "default" }} , 
 	{ "name": "p_i10", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i10", "role": "default" }} , 
 	{ "name": "p_i11", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i11", "role": "default" }} , 
 	{ "name": "p_i12", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i12", "role": "default" }} , 
 	{ "name": "p_i20", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i20", "role": "default" }} , 
 	{ "name": "p_i21", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i21", "role": "default" }} , 
 	{ "name": "p_i22", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "p_i22", "role": "default" }} , 
 	{ "name": "angle", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "angle", "role": "default" }} , 
 	{ "name": "p_low_threshold", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "p_low_threshold", "role": "default" }} , 
 	{ "name": "p_high_threshold", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "p_high_threshold", "role": "default" }} , 
 	{ "name": "ap_return", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "ap_return", "role": "default" }} , 
 	{ "name": "ap_ce", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "ce", "bundle":{"name": "ap_ce", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "",
		"CDFG" : "xFFindmax3x3_3_0_0_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "0", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "Aligned", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "1", "EstimateLatencyMin" : "1", "EstimateLatencyMax" : "1",
		"Combinational" : "0",
		"Datapath" : "1",
		"ClockEnable" : "1",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "p_i00", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_i01", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_i02", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_i10", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_i11", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_i12", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_i20", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_i21", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_i22", "Type" : "None", "Direction" : "I"},
			{"Name" : "angle", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_low_threshold", "Type" : "None", "Direction" : "I"},
			{"Name" : "p_high_threshold", "Type" : "None", "Direction" : "I"}]}]}


set ArgLastReadFirstWriteLatency {
	xFFindmax3x3_3_0_0_s {
		p_i00 {Type I LastRead 0 FirstWrite -1}
		p_i01 {Type I LastRead 0 FirstWrite -1}
		p_i02 {Type I LastRead 0 FirstWrite -1}
		p_i10 {Type I LastRead 0 FirstWrite -1}
		p_i11 {Type I LastRead 0 FirstWrite -1}
		p_i12 {Type I LastRead 0 FirstWrite -1}
		p_i20 {Type I LastRead 0 FirstWrite -1}
		p_i21 {Type I LastRead 0 FirstWrite -1}
		p_i22 {Type I LastRead 0 FirstWrite -1}
		angle {Type I LastRead 0 FirstWrite -1}
		p_low_threshold {Type I LastRead 0 FirstWrite -1}
		p_high_threshold {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "1", "Max" : "1"}
	, {"Name" : "Interval", "Min" : "1", "Max" : "1"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	p_i00 { ap_none {  { p_i00 in_data 0 16 } } }
	p_i01 { ap_none {  { p_i01 in_data 0 16 } } }
	p_i02 { ap_none {  { p_i02 in_data 0 16 } } }
	p_i10 { ap_none {  { p_i10 in_data 0 16 } } }
	p_i11 { ap_none {  { p_i11 in_data 0 16 } } }
	p_i12 { ap_none {  { p_i12 in_data 0 16 } } }
	p_i20 { ap_none {  { p_i20 in_data 0 16 } } }
	p_i21 { ap_none {  { p_i21 in_data 0 16 } } }
	p_i22 { ap_none {  { p_i22 in_data 0 16 } } }
	angle { ap_none {  { angle in_data 0 8 } } }
	p_low_threshold { ap_none {  { p_low_threshold in_data 0 8 } } }
	p_high_threshold { ap_none {  { p_high_threshold in_data 0 8 } } }
}
