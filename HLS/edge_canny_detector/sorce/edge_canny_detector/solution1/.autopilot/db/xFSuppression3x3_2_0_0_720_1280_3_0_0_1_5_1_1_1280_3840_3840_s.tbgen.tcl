set moduleName xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s
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
set C_modelName {xFSuppression3x3<2, 0, 0, 720, 1280, 3, 0, 0, 1, 5, 1, 1, 1280, 3840, 3840>}
set C_modelType { void 0 }
set C_modelArgList {
	{ magnitude_mat_data int 16 regular {fifo 0 volatile }  }
	{ phase_mat_data int 8 regular {fifo 0 volatile }  }
	{ nms_mat_data int 8 regular {fifo 1 volatile }  }
	{ lowthreshold int 8 regular {fifo 0}  }
	{ highthreshold int 8 regular {fifo 0}  }
}
set C_modelArgMapList {[ 
	{ "Name" : "magnitude_mat_data", "interface" : "fifo", "bitwidth" : 16, "direction" : "READONLY"} , 
 	{ "Name" : "phase_mat_data", "interface" : "fifo", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "nms_mat_data", "interface" : "fifo", "bitwidth" : 8, "direction" : "WRITEONLY"} , 
 	{ "Name" : "lowthreshold", "interface" : "fifo", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "highthreshold", "interface" : "fifo", "bitwidth" : 8, "direction" : "READONLY"} ]}
# RTL Port declarations: 
set portNum 25
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
	{ magnitude_mat_data_dout sc_in sc_lv 16 signal 0 } 
	{ magnitude_mat_data_empty_n sc_in sc_logic 1 signal 0 } 
	{ magnitude_mat_data_read sc_out sc_logic 1 signal 0 } 
	{ phase_mat_data_dout sc_in sc_lv 8 signal 1 } 
	{ phase_mat_data_empty_n sc_in sc_logic 1 signal 1 } 
	{ phase_mat_data_read sc_out sc_logic 1 signal 1 } 
	{ nms_mat_data_din sc_out sc_lv 8 signal 2 } 
	{ nms_mat_data_full_n sc_in sc_logic 1 signal 2 } 
	{ nms_mat_data_write sc_out sc_logic 1 signal 2 } 
	{ lowthreshold_dout sc_in sc_lv 8 signal 3 } 
	{ lowthreshold_empty_n sc_in sc_logic 1 signal 3 } 
	{ lowthreshold_read sc_out sc_logic 1 signal 3 } 
	{ highthreshold_dout sc_in sc_lv 8 signal 4 } 
	{ highthreshold_empty_n sc_in sc_logic 1 signal 4 } 
	{ highthreshold_read sc_out sc_logic 1 signal 4 } 
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
 	{ "name": "magnitude_mat_data_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":16, "type": "signal", "bundle":{"name": "magnitude_mat_data", "role": "dout" }} , 
 	{ "name": "magnitude_mat_data_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "magnitude_mat_data", "role": "empty_n" }} , 
 	{ "name": "magnitude_mat_data_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "magnitude_mat_data", "role": "read" }} , 
 	{ "name": "phase_mat_data_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "phase_mat_data", "role": "dout" }} , 
 	{ "name": "phase_mat_data_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "phase_mat_data", "role": "empty_n" }} , 
 	{ "name": "phase_mat_data_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "phase_mat_data", "role": "read" }} , 
 	{ "name": "nms_mat_data_din", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "nms_mat_data", "role": "din" }} , 
 	{ "name": "nms_mat_data_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "nms_mat_data", "role": "full_n" }} , 
 	{ "name": "nms_mat_data_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "nms_mat_data", "role": "write" }} , 
 	{ "name": "lowthreshold_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "lowthreshold", "role": "dout" }} , 
 	{ "name": "lowthreshold_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "lowthreshold", "role": "empty_n" }} , 
 	{ "name": "lowthreshold_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "lowthreshold", "role": "read" }} , 
 	{ "name": "highthreshold_dout", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "highthreshold", "role": "dout" }} , 
 	{ "name": "highthreshold_empty_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "highthreshold", "role": "empty_n" }} , 
 	{ "name": "highthreshold_read", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "highthreshold", "role": "read" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"],
		"CDFG" : "xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "1",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "930083", "EstimateLatencyMax" : "930083",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "magnitude_mat_data", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "3840", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "magnitude_mat_data_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "phase_mat_data", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "3840", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "phase_mat_data_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "nms_mat_data", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "nms_mat_data_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "lowthreshold", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "7", "DependentChanType" : "2",
				"BlockSignal" : [
					{"Name" : "lowthreshold_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "highthreshold", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "7", "DependentChanType" : "2",
				"BlockSignal" : [
					{"Name" : "highthreshold_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.angle_V_0_U", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.angle_V_1_U", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.buf_V_0_U", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.buf_V_1_U", "Parent" : "0"},
	{"ID" : "5", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.buf_V_2_U", "Parent" : "0"},
	{"ID" : "6", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grp_xFFindmax3x3_3_0_0_s_fu_500", "Parent" : "0",
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
			{"Name" : "p_high_threshold", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "7", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.l00_buf_V_2_xfExtractPixels_1_5_3_s_fu_526", "Parent" : "0",
		"CDFG" : "xfExtractPixels_1_5_3_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "1", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "0", "EstimateLatencyMin" : "0", "EstimateLatencyMax" : "0",
		"Combinational" : "1",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "p_read1", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "8", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.l10_buf_V_2_xfExtractPixels_1_5_3_s_fu_531", "Parent" : "0",
		"CDFG" : "xfExtractPixels_1_5_3_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "1", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "0", "EstimateLatencyMin" : "0", "EstimateLatencyMax" : "0",
		"Combinational" : "1",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "p_read1", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "9", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.l20_buf_V_2_xfExtractPixels_1_5_3_s_fu_536", "Parent" : "0",
		"CDFG" : "xfExtractPixels_1_5_3_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "1", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "0", "EstimateLatencyMin" : "0", "EstimateLatencyMax" : "0",
		"Combinational" : "1",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "p_read1", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "10", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.angle_buf_V_2_xfExtractPixels_1_1_0_s_fu_541", "Parent" : "0",
		"CDFG" : "xfExtractPixels_1_1_0_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "1", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "1",
		"VariableLatency" : "0", "ExactLatency" : "0", "EstimateLatencyMin" : "0", "EstimateLatencyMax" : "0",
		"Combinational" : "1",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "p_read1", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "11", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_16_1_1_U80", "Parent" : "0"},
	{"ID" : "12", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_16_1_1_U81", "Parent" : "0"},
	{"ID" : "13", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.mux_32_16_1_1_U82", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_s {
		magnitude_mat_data {Type I LastRead 5 FirstWrite -1}
		phase_mat_data {Type I LastRead 5 FirstWrite -1}
		nms_mat_data {Type O LastRead -1 FirstWrite 10}
		lowthreshold {Type I LastRead 0 FirstWrite -1}
		highthreshold {Type I LastRead 0 FirstWrite -1}}
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
		p_high_threshold {Type I LastRead 0 FirstWrite -1}}
	xfExtractPixels_1_5_3_s {
		p_read1 {Type I LastRead 0 FirstWrite -1}}
	xfExtractPixels_1_5_3_s {
		p_read1 {Type I LastRead 0 FirstWrite -1}}
	xfExtractPixels_1_5_3_s {
		p_read1 {Type I LastRead 0 FirstWrite -1}}
	xfExtractPixels_1_1_0_s {
		p_read1 {Type I LastRead 0 FirstWrite -1}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "930083", "Max" : "930083"}
	, {"Name" : "Interval", "Min" : "930083", "Max" : "930083"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "0", "EnableSignal" : "ap_enable_pp0"}
	{"Pipeline" : "1", "EnableSignal" : "ap_enable_pp1"}
]}

set Spec2ImplPortList { 
	magnitude_mat_data { ap_fifo {  { magnitude_mat_data_dout fifo_data 0 16 }  { magnitude_mat_data_empty_n fifo_status 0 1 }  { magnitude_mat_data_read fifo_update 1 1 } } }
	phase_mat_data { ap_fifo {  { phase_mat_data_dout fifo_data 0 8 }  { phase_mat_data_empty_n fifo_status 0 1 }  { phase_mat_data_read fifo_update 1 1 } } }
	nms_mat_data { ap_fifo {  { nms_mat_data_din fifo_data 1 8 }  { nms_mat_data_full_n fifo_status 0 1 }  { nms_mat_data_write fifo_update 1 1 } } }
	lowthreshold { ap_fifo {  { lowthreshold_dout fifo_data 0 8 }  { lowthreshold_empty_n fifo_status 0 1 }  { lowthreshold_read fifo_update 1 1 } } }
	highthreshold { ap_fifo {  { highthreshold_dout fifo_data 0 8 }  { highthreshold_empty_n fifo_status 0 1 }  { highthreshold_read fifo_update 1 1 } } }
}
