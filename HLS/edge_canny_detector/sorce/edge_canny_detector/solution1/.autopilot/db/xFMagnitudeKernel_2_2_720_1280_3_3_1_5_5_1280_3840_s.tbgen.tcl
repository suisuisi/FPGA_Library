set moduleName xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_s
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
set C_modelName {xFMagnitudeKernel<2, 2, 720, 1280, 3, 3, 1, 5, 5, 1280, 3840>}
set C_modelType { void 0 }
set C_modelArgList {
	{ gradx1_mat_4211 int 16 regular {fifo 0 volatile }  }
	{ grady1_mat_4214 int 16 regular {fifo 0 volatile }  }
	{ magnitude_mat_4216 int 16 regular {fifo 1 volatile }  }
}
set C_modelArgMapList {[ 
	{ "Name" : "gradx1_mat_4211", "interface" : "fifo", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "grady1_mat_4214", "interface" : "fifo", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "magnitude_mat_4216", "interface" : "fifo", "bitwidth" : 16, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 16
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_continue sc_in sc_logic 1 continue -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ gradx1_mat_4211_dout sc_in sc_lv 16 signal 0 } 
	{ gradx1_mat_4211_empty_n sc_in sc_logic 1 signal 0 } 
	{ gradx1_mat_4211_read sc_out sc_logic 1 signal 0 } 
	{ grady1_mat_4214_dout sc_in sc_lv 16 signal 1 } 
	{ grady1_mat_4214_empty_n sc_in sc_logic 1 signal 1 } 
	{ grady1_mat_4214_read sc_out sc_logic 1 signal 1 } 
	{ magnitude_mat_4216_din sc_out sc_lv 16 signal 2 } 
	{ magnitude_mat_4216_full_n sc_in sc_logic 1 signal 2 } 
	{ magnitude_mat_4216_write sc_out sc_logic 1 signal 2 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_continue", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "continue", "bundle":{"name": "ap_continue", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "gradx1_mat_4211_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "gradx1_mat_4211", "role": "dout" }} , 
 	{ "name": "gradx1_mat_4211_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx1_mat_4211", "role": "empty_n" }} , 
 	{ "name": "gradx1_mat_4211_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx1_mat_4211", "role": "read" }} , 
 	{ "name": "grady1_mat_4214_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "grady1_mat_4214", "role": "dout" }} , 
 	{ "name": "grady1_mat_4214_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady1_mat_4214", "role": "empty_n" }} , 
 	{ "name": "grady1_mat_4214_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady1_mat_4214", "role": "read" }} , 
 	{ "name": "magnitude_mat_4216_din", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "magnitude_mat_4216", "role": "din" }} , 
 	{ "name": "magnitude_mat_4216_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "magnitude_mat_4216", "role": "full_n" }} , 
 	{ "name": "magnitude_mat_4216_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "magnitude_mat_4216", "role": "write" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2"],
		"CDFG" : "xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "932401", "EstimateLatencyMax" : "932401",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "gradx1_mat_4211", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx1_mat_4211_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady1_mat_4214", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady1_mat_4214_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "magnitude_mat_4216", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "3840", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "magnitude_mat_4216_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mul_mul_16s_16s_32_4_1_U55", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mac_muladd_16s_16s_32s_32_4_1_U56", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_s {
		gradx1_mat_4211 {Type I LastRead 3 FirstWrite -1}
		grady1_mat_4214 {Type I LastRead 3 FirstWrite -1}
		magnitude_mat_4216 {Type O LastRead -1 FirstWrite 15}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "932401", "Max" : "932401"}
	, {"Name" : "Interval", "Min" : "932401", "Max" : "932401"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	gradx1_mat_4211 { ap_fifo {  { gradx1_mat_4211_dout fifo_data 0 16 }  { gradx1_mat_4211_empty_n fifo_status 0 1 }  { gradx1_mat_4211_read fifo_update 1 1 } } }
	grady1_mat_4214 { ap_fifo {  { grady1_mat_4214_dout fifo_data 0 16 }  { grady1_mat_4214_empty_n fifo_status 0 1 }  { grady1_mat_4214_read fifo_update 1 1 } } }
	magnitude_mat_4216 { ap_fifo {  { magnitude_mat_4216_din fifo_data 1 16 }  { magnitude_mat_4216_full_n fifo_status 0 1 }  { magnitude_mat_4216_write fifo_update 1 1 } } }
}
