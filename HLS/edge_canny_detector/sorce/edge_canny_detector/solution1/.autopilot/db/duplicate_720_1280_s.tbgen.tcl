set moduleName duplicate_720_1280_s
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
set C_modelName {duplicate<720, 1280>}
set C_modelType { void 0 }
set C_modelArgList {
	{ gradx_mat_4210 int 16 regular {fifo 0 volatile }  }
	{ grady_mat_4213 int 16 regular {fifo 0 volatile }  }
	{ gradx1_mat_4211 int 16 regular {fifo 1 volatile }  }
	{ gradx2_mat_4212 int 16 regular {fifo 1 volatile }  }
	{ grady1_mat_4214 int 16 regular {fifo 1 volatile }  }
	{ grady2_mat_4215 int 16 regular {fifo 1 volatile }  }
}
set C_modelArgMapList {[ 
	{ "Name" : "gradx_mat_4210", "interface" : "fifo", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "grady_mat_4213", "interface" : "fifo", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "gradx1_mat_4211", "interface" : "fifo", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "gradx2_mat_4212", "interface" : "fifo", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "grady1_mat_4214", "interface" : "fifo", "bitwidth" : 16, "direction" : "WRITEONLY"} , 
 	{ "Name" : "grady2_mat_4215", "interface" : "fifo", "bitwidth" : 16, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 28
set portList { 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst sc_in sc_logic 1 reset -1 active_high_sync } 
	{ ap_start sc_in sc_logic 1 start -1 } 
	{ start_full_n sc_in sc_logic 1 signal -1 } 
	{ ap_done sc_out sc_logic 1 predone -1 } 
	{ ap_continue sc_in sc_logic 1 continue -1 } 
	{ ap_idle sc_out sc_logic 1 done -1 } 
	{ ap_ready sc_out sc_logic 1 ready -1 } 
	{ start_out sc_out sc_logic 1 signal -1 } 
	{ start_write sc_out sc_logic 1 signal -1 } 
	{ gradx_mat_4210_dout sc_in sc_lv 16 signal 0 } 
	{ gradx_mat_4210_empty_n sc_in sc_logic 1 signal 0 } 
	{ gradx_mat_4210_read sc_out sc_logic 1 signal 0 } 
	{ grady_mat_4213_dout sc_in sc_lv 16 signal 1 } 
	{ grady_mat_4213_empty_n sc_in sc_logic 1 signal 1 } 
	{ grady_mat_4213_read sc_out sc_logic 1 signal 1 } 
	{ gradx1_mat_4211_din sc_out sc_lv 16 signal 2 } 
	{ gradx1_mat_4211_full_n sc_in sc_logic 1 signal 2 } 
	{ gradx1_mat_4211_write sc_out sc_logic 1 signal 2 } 
	{ gradx2_mat_4212_din sc_out sc_lv 16 signal 3 } 
	{ gradx2_mat_4212_full_n sc_in sc_logic 1 signal 3 } 
	{ gradx2_mat_4212_write sc_out sc_logic 1 signal 3 } 
	{ grady1_mat_4214_din sc_out sc_lv 16 signal 4 } 
	{ grady1_mat_4214_full_n sc_in sc_logic 1 signal 4 } 
	{ grady1_mat_4214_write sc_out sc_logic 1 signal 4 } 
	{ grady2_mat_4215_din sc_out sc_lv 16 signal 5 } 
	{ grady2_mat_4215_full_n sc_in sc_logic 1 signal 5 } 
	{ grady2_mat_4215_write sc_out sc_logic 1 signal 5 } 
}
set NewPortList {[ 
	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst", "role": "default" }} , 
 	{ "name": "ap_start", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "start", "bundle":{"name": "ap_start", "role": "default" }} , 
 	{ "name": "start_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "start_full_n", "role": "default" }} , 
 	{ "name": "ap_done", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "predone", "bundle":{"name": "ap_done", "role": "default" }} , 
 	{ "name": "ap_continue", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "continue", "bundle":{"name": "ap_continue", "role": "default" }} , 
 	{ "name": "ap_idle", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "done", "bundle":{"name": "ap_idle", "role": "default" }} , 
 	{ "name": "ap_ready", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "ready", "bundle":{"name": "ap_ready", "role": "default" }} , 
 	{ "name": "start_out", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "start_out", "role": "default" }} , 
 	{ "name": "start_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "start_write", "role": "default" }} , 
 	{ "name": "gradx_mat_4210_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "gradx_mat_4210", "role": "dout" }} , 
 	{ "name": "gradx_mat_4210_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx_mat_4210", "role": "empty_n" }} , 
 	{ "name": "gradx_mat_4210_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx_mat_4210", "role": "read" }} , 
 	{ "name": "grady_mat_4213_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "grady_mat_4213", "role": "dout" }} , 
 	{ "name": "grady_mat_4213_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady_mat_4213", "role": "empty_n" }} , 
 	{ "name": "grady_mat_4213_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady_mat_4213", "role": "read" }} , 
 	{ "name": "gradx1_mat_4211_din", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "gradx1_mat_4211", "role": "din" }} , 
 	{ "name": "gradx1_mat_4211_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx1_mat_4211", "role": "full_n" }} , 
 	{ "name": "gradx1_mat_4211_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx1_mat_4211", "role": "write" }} , 
 	{ "name": "gradx2_mat_4212_din", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "gradx2_mat_4212", "role": "din" }} , 
 	{ "name": "gradx2_mat_4212_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx2_mat_4212", "role": "full_n" }} , 
 	{ "name": "gradx2_mat_4212_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "gradx2_mat_4212", "role": "write" }} , 
 	{ "name": "grady1_mat_4214_din", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "grady1_mat_4214", "role": "din" }} , 
 	{ "name": "grady1_mat_4214_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady1_mat_4214", "role": "full_n" }} , 
 	{ "name": "grady1_mat_4214_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady1_mat_4214", "role": "write" }} , 
 	{ "name": "grady2_mat_4215_din", "direction": "out", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "grady2_mat_4215", "role": "din" }} , 
 	{ "name": "grady2_mat_4215_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady2_mat_4215", "role": "full_n" }} , 
 	{ "name": "grady2_mat_4215_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "grady2_mat_4215", "role": "write" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "",
		"CDFG" : "duplicate_720_1280_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "1",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "921602", "EstimateLatencyMax" : "921602",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "gradx_mat_4210", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx_mat_4210_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady_mat_4213", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady_mat_4213_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "gradx1_mat_4211", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx1_mat_4211_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "gradx2_mat_4212", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx2_mat_4212_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady1_mat_4214", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady1_mat_4214_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady2_mat_4215", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady2_mat_4215_blk_n", "Type" : "RtlSignal"}]}]}]}


set ArgLastReadFirstWriteLatency {
	duplicate_720_1280_s {
		gradx_mat_4210 {Type I LastRead 2 FirstWrite -1}
		grady_mat_4213 {Type I LastRead 2 FirstWrite -1}
		gradx1_mat_4211 {Type O LastRead -1 FirstWrite 2}
		gradx2_mat_4212 {Type O LastRead -1 FirstWrite 2}
		grady1_mat_4214 {Type O LastRead -1 FirstWrite 2}
		grady2_mat_4215 {Type O LastRead -1 FirstWrite 2}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "921602", "Max" : "921602"}
	, {"Name" : "Interval", "Min" : "921602", "Max" : "921602"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
]}

set Spec2ImplPortList { 
	gradx_mat_4210 { ap_fifo {  { gradx_mat_4210_dout fifo_data 0 16 }  { gradx_mat_4210_empty_n fifo_status 0 1 }  { gradx_mat_4210_read fifo_update 1 1 } } }
	grady_mat_4213 { ap_fifo {  { grady_mat_4213_dout fifo_data 0 16 }  { grady_mat_4213_empty_n fifo_status 0 1 }  { grady_mat_4213_read fifo_update 1 1 } } }
	gradx1_mat_4211 { ap_fifo {  { gradx1_mat_4211_din fifo_data 1 16 }  { gradx1_mat_4211_full_n fifo_status 0 1 }  { gradx1_mat_4211_write fifo_update 1 1 } } }
	gradx2_mat_4212 { ap_fifo {  { gradx2_mat_4212_din fifo_data 1 16 }  { gradx2_mat_4212_full_n fifo_status 0 1 }  { gradx2_mat_4212_write fifo_update 1 1 } } }
	grady1_mat_4214 { ap_fifo {  { grady1_mat_4214_din fifo_data 1 16 }  { grady1_mat_4214_full_n fifo_status 0 1 }  { grady1_mat_4214_write fifo_update 1 1 } } }
	grady2_mat_4215 { ap_fifo {  { grady2_mat_4215_din fifo_data 1 16 }  { grady2_mat_4215_full_n fifo_status 0 1 }  { grady2_mat_4215_write fifo_update 1 1 } } }
}
