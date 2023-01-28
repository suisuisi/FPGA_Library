set moduleName xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s
set isTopModule 0
set isCombinational 0
set isDatapathOnly 0
set isPipelined 0
set pipeline_type none
set FunctionProtocol ap_ctrl_hs
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set C_modelName {xFSobel3x3<0, 2, 720, 1280, 0, 3, 1, 1, 5, 1281, 3, 9, false>}
set C_modelType { void 0 }
set C_modelArgList {
	{ gaussian_mat_4209 int 8 regular {fifo 0 volatile }  }
	{ gradx_mat_4210 int 16 regular {fifo 1 volatile }  }
	{ grady_mat_4213 int 16 regular {fifo 1 volatile }  }
}
set C_modelArgMapList {[ 
	{ "Name" : "gaussian_mat_4209", "interface" : "fifo", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "gradx_mat_4210", "interface" : "fifo", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "grady_mat_4213", "interface" : "fifo", "bitwidth" : 16, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 15
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ gaussian_mat_4209_dout sc_in sc_lv 8 signal 0 } 
	{ gaussian_mat_4209_empty_n sc_in sc_logic 1 signal 0 } 
	{ gaussian_mat_4209_read sc_out sc_logic 1 signal 0 } 
	{ gradx_mat_4210_din sc_out sc_lv 16 signal 1 } 
	{ gradx_mat_4210_full_n sc_in sc_logic 1 signal 1 } 
	{ gradx_mat_4210_write sc_out sc_logic 1 signal 1 } 
	{ grady_mat_4213_din sc_out sc_lv 16 signal 2 } 
	{ grady_mat_4213_full_n sc_in sc_logic 1 signal 2 } 
	{ grady_mat_4213_write sc_out sc_logic 1 signal 2 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "gaussian_mat_4209_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "gaussian_mat_4209", "role": "dout" }} , 
 	{ "name": "gaussian_mat_4209_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gaussian_mat_4209", "role": "empty_n" }} , 
 	{ "name": "gaussian_mat_4209_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gaussian_mat_4209", "role": "read" }} , 
 	{ "name": "gradx_mat_4210_din", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "gradx_mat_4210", "role": "din" }} , 
 	{ "name": "gradx_mat_4210_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx_mat_4210", "role": "full_n" }} , 
 	{ "name": "gradx_mat_4210_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx_mat_4210", "role": "write" }} , 
 	{ "name": "grady_mat_4213_din", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "grady_mat_4213", "role": "din" }} , 
 	{ "name": "grady_mat_4213_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady_mat_4213", "role": "full_n" }} , 
 	{ "name": "grady_mat_4213_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady_mat_4213", "role": "write" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
		"CDFG" : "xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "0", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "931778", "EstimateLatencyMax" : "931778",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "gaussian_mat_4209", "Type" : "Fifo", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "gaussian_mat_4209_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "gradx_mat_4210", "Type" : "Fifo", "Direction" : "O",
				"BlockSignal" : [
					{"Name" : "gradx_mat_4210_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady_mat_4213", "Type" : "Fifo", "Direction" : "O",
				"BlockSignal" : [
					{"Name" : "grady_mat_4213_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.buf_V_0_U", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.buf_V_1_U", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.buf_V_2_U", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_8_1_1_U36", "Parent" : "0"},
	{"ID" : "5", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_8_1_1_U37", "Parent" : "0"},
	{"ID" : "6", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_8_1_1_U38", "Parent" : "0"},
	{"ID" : "7", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_13_1_1_U39", "Parent" : "0"},
	{"ID" : "8", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_8_1_1_U40", "Parent" : "0"},
	{"ID" : "9", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_8_1_1_U41", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s {
		gaussian_mat_4209 {Type I LastRead 8 FirstWrite -1}
		gradx_mat_4210 {Type O LastRead -1 FirstWrite 11}
		grady_mat_4213 {Type O LastRead -1 FirstWrite 11}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "931778", "Max" : "931778"}
	, {"Name" : "Interval", "Min" : "931778", "Max" : "931778"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "1", "EnableSignal" : "ap_enable_pp1"}
	{"Pipeline" : "2", "EnableSignal" : "ap_enable_pp2"}
	{"Pipeline" : "3", "EnableSignal" : "ap_enable_pp3"}
]}

set Spec2ImplPortList { 
	gaussian_mat_4209 { ap_fifo {  { gaussian_mat_4209_dout fifo_data 0 8 }  { gaussian_mat_4209_empty_n fifo_status 0 1 }  { gaussian_mat_4209_read fifo_update 1 1 } } }
	gradx_mat_4210 { ap_fifo {  { gradx_mat_4210_din fifo_data 1 16 }  { gradx_mat_4210_full_n fifo_status 0 1 }  { gradx_mat_4210_write fifo_update 1 1 } } }
	grady_mat_4213 { ap_fifo {  { grady_mat_4213_din fifo_data 1 16 }  { grady_mat_4213_full_n fifo_status 0 1 }  { grady_mat_4213_write fifo_update 1 1 } } }
}
