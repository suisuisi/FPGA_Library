set moduleName xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_s
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
set C_modelName {xFAngleKernel<2, 0, 720, 1280, 3, 0, 1, 5, 1, 1280, 3840>}
set C_modelType { void 0 }
set C_modelArgList {
	{ gradx2_mat_4212 int 16 regular {fifo 0 volatile }  }
	{ grady2_mat_4215 int 16 regular {fifo 0 volatile }  }
	{ phase_mat_4217 int 8 regular {fifo 1 volatile }  }
}
set C_modelArgMapList {[ 
	{ "Name" : "gradx2_mat_4212", "interface" : "fifo", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "grady2_mat_4215", "interface" : "fifo", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "phase_mat_4217", "interface" : "fifo", "bitwidth" : 8, "direction" : "WRITEONLY"} ]}
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
	{ gradx2_mat_4212_dout sc_in sc_lv 16 signal 0 } 
	{ gradx2_mat_4212_empty_n sc_in sc_logic 1 signal 0 } 
	{ gradx2_mat_4212_read sc_out sc_logic 1 signal 0 } 
	{ grady2_mat_4215_dout sc_in sc_lv 16 signal 1 } 
	{ grady2_mat_4215_empty_n sc_in sc_logic 1 signal 1 } 
	{ grady2_mat_4215_read sc_out sc_logic 1 signal 1 } 
	{ phase_mat_4217_din sc_out sc_lv 8 signal 2 } 
	{ phase_mat_4217_full_n sc_in sc_logic 1 signal 2 } 
	{ phase_mat_4217_write sc_out sc_logic 1 signal 2 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_continue", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "continue", "bundle":{"name": "ap_continue", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "gradx2_mat_4212_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "gradx2_mat_4212", "role": "dout" }} , 
 	{ "name": "gradx2_mat_4212_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx2_mat_4212", "role": "empty_n" }} , 
 	{ "name": "gradx2_mat_4212_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx2_mat_4212", "role": "read" }} , 
 	{ "name": "grady2_mat_4215_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "grady2_mat_4215", "role": "dout" }} , 
 	{ "name": "grady2_mat_4215_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady2_mat_4215", "role": "empty_n" }} , 
 	{ "name": "grady2_mat_4215_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady2_mat_4215", "role": "read" }} , 
 	{ "name": "phase_mat_4217_din", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "phase_mat_4217", "role": "din" }} , 
 	{ "name": "phase_mat_4217_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "phase_mat_4217", "role": "full_n" }} , 
 	{ "name": "phase_mat_4217_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "phase_mat_4217", "role": "write" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1"],
		"CDFG" : "xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "925921", "EstimateLatencyMax" : "925921",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "gradx2_mat_4212", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx2_mat_4212_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady2_mat_4215", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady2_mat_4215_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "phase_mat_4217", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "3840", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "phase_mat_4217_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mul_17s_15ns_32_2_1_U62", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_s {
		gradx2_mat_4212 {Type I LastRead 3 FirstWrite -1}
		grady2_mat_4215 {Type I LastRead 3 FirstWrite -1}
		phase_mat_4217 {Type O LastRead -1 FirstWrite 6}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "925921", "Max" : "925921"}
	, {"Name" : "Interval", "Min" : "925921", "Max" : "925921"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	gradx2_mat_4212 { ap_fifo {  { gradx2_mat_4212_dout fifo_data 0 16 }  { gradx2_mat_4212_empty_n fifo_status 0 1 }  { gradx2_mat_4212_read fifo_update 1 1 } } }
	grady2_mat_4215 { ap_fifo {  { grady2_mat_4215_dout fifo_data 0 16 }  { grady2_mat_4215_empty_n fifo_status 0 1 }  { grady2_mat_4215_read fifo_update 1 1 } } }
	phase_mat_4217 { ap_fifo {  { phase_mat_4217_din fifo_data 1 8 }  { phase_mat_4217_full_n fifo_status 0 1 }  { phase_mat_4217_write fifo_update 1 1 } } }
}
