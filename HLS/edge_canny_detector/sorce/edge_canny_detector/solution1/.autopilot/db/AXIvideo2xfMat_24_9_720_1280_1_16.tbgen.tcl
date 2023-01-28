set moduleName AXIvideo2xfMat_24_9_720_1280_1_16
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
set C_modelName {AXIvideo2xfMat<24, 9, 720, 1280, 1>16}
set C_modelType { void 0 }
set C_modelArgList {
	{ rgb_img_src_4206 int 24 regular {fifo 1 volatile }  }
	{ AXI_video_strm_V_data_V int 24 regular {axi_s 0 volatile  { src Data } }  }
	{ AXI_video_strm_V_keep_V int 3 regular {axi_s 0 volatile  { src Keep } }  }
	{ AXI_video_strm_V_strb_V int 3 regular {axi_s 0 volatile  { src Strb } }  }
	{ AXI_video_strm_V_user_V int 1 regular {axi_s 0 volatile  { src User } }  }
	{ AXI_video_strm_V_last_V int 1 regular {axi_s 0 volatile  { src Last } }  }
	{ AXI_video_strm_V_id_V int 1 regular {axi_s 0 volatile  { src ID } }  }
	{ AXI_video_strm_V_dest_V int 1 regular {axi_s 0 volatile  { src Dest } }  }
	{ lowthreshold int 8 regular {pointer 0}  }
	{ highthreshold int 8 regular {pointer 0}  }
	{ lowthreshold_out int 8 regular {fifo 1}  }
	{ highthreshold_out int 8 regular {fifo 1}  }
}
set C_modelArgMapList {[ 
	{ "Name" : "rgb_img_src_4206", "interface" : "fifo", "bitwidth" : 24, "direction" : "WRITEONLY"} , 
 	{ "Name" : "AXI_video_strm_V_data_V", "interface" : "axis", "bitwidth" : 24, "direction" : "READONLY"} , 
 	{ "Name" : "AXI_video_strm_V_keep_V", "interface" : "axis", "bitwidth" : 3, "direction" : "READONLY"} , 
 	{ "Name" : "AXI_video_strm_V_strb_V", "interface" : "axis", "bitwidth" : 3, "direction" : "READONLY"} , 
 	{ "Name" : "AXI_video_strm_V_user_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY"} , 
 	{ "Name" : "AXI_video_strm_V_last_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY"} , 
 	{ "Name" : "AXI_video_strm_V_id_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY"} , 
 	{ "Name" : "AXI_video_strm_V_dest_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY"} , 
 	{ "Name" : "lowthreshold", "interface" : "wire", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "highthreshold", "interface" : "wire", "bitwidth" : 8, "direction" : "READONLY"} , 
 	{ "Name" : "lowthreshold_out", "interface" : "fifo", "bitwidth" : 8, "direction" : "WRITEONLY"} , 
 	{ "Name" : "highthreshold_out", "interface" : "fifo", "bitwidth" : 8, "direction" : "WRITEONLY"} ]}
# RTL Port declarations: 
set portNum 32
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
	{ rgb_img_src_4206_din sc_out sc_lv 24 signal 0 } 
	{ rgb_img_src_4206_full_n sc_in sc_logic 1 signal 0 } 
	{ rgb_img_src_4206_write sc_out sc_logic 1 signal 0 } 
	{ src_TDATA sc_in sc_lv 24 signal 1 } 
	{ src_TVALID sc_in sc_logic 1 invld 7 } 
	{ src_TREADY sc_out sc_logic 1 inacc 7 } 
	{ src_TKEEP sc_in sc_lv 3 signal 2 } 
	{ src_TSTRB sc_in sc_lv 3 signal 3 } 
	{ src_TUSER sc_in sc_lv 1 signal 4 } 
	{ src_TLAST sc_in sc_lv 1 signal 5 } 
	{ src_TID sc_in sc_lv 1 signal 6 } 
	{ src_TDEST sc_in sc_lv 1 signal 7 } 
	{ lowthreshold sc_in sc_lv 8 signal 8 } 
	{ lowthreshold_ap_vld sc_in sc_logic 1 invld 8 } 
	{ highthreshold sc_in sc_lv 8 signal 9 } 
	{ highthreshold_ap_vld sc_in sc_logic 1 invld 9 } 
	{ lowthreshold_out_din sc_out sc_lv 8 signal 10 } 
	{ lowthreshold_out_full_n sc_in sc_logic 1 signal 10 } 
	{ lowthreshold_out_write sc_out sc_logic 1 signal 10 } 
	{ highthreshold_out_din sc_out sc_lv 8 signal 11 } 
	{ highthreshold_out_full_n sc_in sc_logic 1 signal 11 } 
	{ highthreshold_out_write sc_out sc_logic 1 signal 11 } 
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
 	{ "name": "rgb_img_src_4206_din", "direction": "out", "datatype": "sc_lv", "bitwidth":24, "type": "signal", "bundle":{"name": "rgb_img_src_4206", "role": "din" }} , 
 	{ "name": "rgb_img_src_4206_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "rgb_img_src_4206", "role": "full_n" }} , 
 	{ "name": "rgb_img_src_4206_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "rgb_img_src_4206", "role": "write" }} , 
 	{ "name": "src_TDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":24, "type": "signal", "bundle":{"name": "AXI_video_strm_V_data_V", "role": "default" }} , 
 	{ "name": "src_TVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "invld", "bundle":{"name": "AXI_video_strm_V_dest_V", "role": "default" }} , 
 	{ "name": "src_TREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "inacc", "bundle":{"name": "AXI_video_strm_V_dest_V", "role": "default" }} , 
 	{ "name": "src_TKEEP", "direction": "in", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "AXI_video_strm_V_keep_V", "role": "default" }} , 
 	{ "name": "src_TSTRB", "direction": "in", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "AXI_video_strm_V_strb_V", "role": "default" }} , 
 	{ "name": "src_TUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "AXI_video_strm_V_user_V", "role": "default" }} , 
 	{ "name": "src_TLAST", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "AXI_video_strm_V_last_V", "role": "default" }} , 
 	{ "name": "src_TID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "AXI_video_strm_V_id_V", "role": "default" }} , 
 	{ "name": "src_TDEST", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "AXI_video_strm_V_dest_V", "role": "default" }} , 
 	{ "name": "lowthreshold", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "lowthreshold", "role": "default" }} , 
 	{ "name": "lowthreshold_ap_vld", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "invld", "bundle":{"name": "lowthreshold", "role": "ap_vld" }} , 
 	{ "name": "highthreshold", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "highthreshold", "role": "default" }} , 
 	{ "name": "highthreshold_ap_vld", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "invld", "bundle":{"name": "highthreshold", "role": "ap_vld" }} , 
 	{ "name": "lowthreshold_out_din", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "lowthreshold_out", "role": "din" }} , 
 	{ "name": "lowthreshold_out_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "lowthreshold_out", "role": "full_n" }} , 
 	{ "name": "lowthreshold_out_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "lowthreshold_out", "role": "write" }} , 
 	{ "name": "highthreshold_out_din", "direction": "out", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "highthreshold_out", "role": "din" }} , 
 	{ "name": "highthreshold_out_full_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "highthreshold_out", "role": "full_n" }} , 
 	{ "name": "highthreshold_out_write", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "signal", "bundle":{"name": "highthreshold_out", "role": "write" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "2", "3", "4", "5", "6", "7"],
		"CDFG" : "AXIvideo2xfMat_24_9_720_1280_1_16",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "1",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "925203", "EstimateLatencyMax" : "925924",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"Port" : [
			{"Name" : "rgb_img_src_4206", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "rgb_img_src_4206_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "AXI_video_strm_V_data_V", "Type" : "Axis", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "src_TDATA_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "AXI_video_strm_V_keep_V", "Type" : "Axis", "Direction" : "I"},
			{"Name" : "AXI_video_strm_V_strb_V", "Type" : "Axis", "Direction" : "I"},
			{"Name" : "AXI_video_strm_V_user_V", "Type" : "Axis", "Direction" : "I"},
			{"Name" : "AXI_video_strm_V_last_V", "Type" : "Axis", "Direction" : "I"},
			{"Name" : "AXI_video_strm_V_id_V", "Type" : "Axis", "Direction" : "I"},
			{"Name" : "AXI_video_strm_V_dest_V", "Type" : "Axis", "Direction" : "I"},
			{"Name" : "lowthreshold", "Type" : "Vld", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "lowthreshold_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "highthreshold", "Type" : "Vld", "Direction" : "I",
				"BlockSignal" : [
					{"Name" : "highthreshold_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "lowthreshold_out", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "7", "DependentChanType" : "2",
				"BlockSignal" : [
					{"Name" : "lowthreshold_out_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "highthreshold_out", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "0", "DependentChan" : "0", "DependentChanDepth" : "7", "DependentChanType" : "2",
				"BlockSignal" : [
					{"Name" : "highthreshold_out_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_AXI_video_strm_V_data_V_U", "Parent" : "0"},
	{"ID" : "2", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_AXI_video_strm_V_keep_V_U", "Parent" : "0"},
	{"ID" : "3", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_AXI_video_strm_V_strb_V_U", "Parent" : "0"},
	{"ID" : "4", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_AXI_video_strm_V_user_V_U", "Parent" : "0"},
	{"ID" : "5", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_AXI_video_strm_V_last_V_U", "Parent" : "0"},
	{"ID" : "6", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_AXI_video_strm_V_id_V_U", "Parent" : "0"},
	{"ID" : "7", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.regslice_both_AXI_video_strm_V_dest_V_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	AXIvideo2xfMat_24_9_720_1280_1_16 {
		rgb_img_src_4206 {Type O LastRead -1 FirstWrite 5}
		AXI_video_strm_V_data_V {Type I LastRead 6 FirstWrite -1}
		AXI_video_strm_V_keep_V {Type I LastRead 6 FirstWrite -1}
		AXI_video_strm_V_strb_V {Type I LastRead 6 FirstWrite -1}
		AXI_video_strm_V_user_V {Type I LastRead 6 FirstWrite -1}
		AXI_video_strm_V_last_V {Type I LastRead 6 FirstWrite -1}
		AXI_video_strm_V_id_V {Type I LastRead 6 FirstWrite -1}
		AXI_video_strm_V_dest_V {Type I LastRead 6 FirstWrite -1}
		lowthreshold {Type I LastRead 0 FirstWrite -1}
		highthreshold {Type I LastRead 0 FirstWrite -1}
		lowthreshold_out {Type O LastRead -1 FirstWrite 0}
		highthreshold_out {Type O LastRead -1 FirstWrite 0}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "925203", "Max" : "925924"}
	, {"Name" : "Interval", "Min" : "925203", "Max" : "925924"}
]}

set PipelineEnableSignalInfo {[
	{"Pipeline" : "1", "EnableSignal" : "ap_enable_pp1"}
]}

set Spec2ImplPortList { 
	rgb_img_src_4206 { ap_fifo {  { rgb_img_src_4206_din fifo_data 1 24 }  { rgb_img_src_4206_full_n fifo_status 0 1 }  { rgb_img_src_4206_write fifo_update 1 1 } } }
	AXI_video_strm_V_data_V { axis {  { src_TDATA in_data 0 24 } } }
	AXI_video_strm_V_keep_V { axis {  { src_TKEEP in_data 0 3 } } }
	AXI_video_strm_V_strb_V { axis {  { src_TSTRB in_data 0 3 } } }
	AXI_video_strm_V_user_V { axis {  { src_TUSER in_data 0 1 } } }
	AXI_video_strm_V_last_V { axis {  { src_TLAST in_data 0 1 } } }
	AXI_video_strm_V_id_V { axis {  { src_TID in_data 0 1 } } }
	AXI_video_strm_V_dest_V { axis {  { src_TVALID in_vld 0 1 }  { src_TREADY in_acc 1 1 }  { src_TDEST in_data 0 1 } } }
	lowthreshold { ap_vld {  { lowthreshold in_data 0 8 }  { lowthreshold_ap_vld in_vld 0 1 } } }
	highthreshold { ap_vld {  { highthreshold in_data 0 8 }  { highthreshold_ap_vld in_vld 0 1 } } }
	lowthreshold_out { ap_fifo {  { lowthreshold_out_din fifo_data 1 8 }  { lowthreshold_out_full_n fifo_status 0 1 }  { lowthreshold_out_write fifo_update 1 1 } } }
	highthreshold_out { ap_fifo {  { highthreshold_out_din fifo_data 1 8 }  { highthreshold_out_full_n fifo_status 0 1 }  { highthreshold_out_write fifo_update 1 1 } } }
}
