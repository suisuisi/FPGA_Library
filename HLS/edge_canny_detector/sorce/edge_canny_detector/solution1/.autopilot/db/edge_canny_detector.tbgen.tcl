set moduleName edge_canny_detector
set isTopModule 1
set isCombinational 0
set isDatapathOnly 0
set isPipelined 1
set pipeline_type dataflow
set FunctionProtocol ap_ctrl_none
set isOneStateSeq 0
set ProfileFlag 0
set StallSigGenFlag 0
set isEnableWaveformDebug 1
set C_modelName {edge_canny_detector}
set C_modelType { void 0 }
set C_modelArgList {
	{ src_V_data_V int 24 regular {axi_s 0 volatile  { src Data } }  }
	{ src_V_keep_V int 3 regular {axi_s 0 volatile  { src Keep } }  }
	{ src_V_strb_V int 3 regular {axi_s 0 volatile  { src Strb } }  }
	{ src_V_user_V int 1 regular {axi_s 0 volatile  { src User } }  }
	{ src_V_last_V int 1 regular {axi_s 0 volatile  { src Last } }  }
	{ src_V_id_V int 1 regular {axi_s 0 volatile  { src ID } }  }
	{ src_V_dest_V int 1 regular {axi_s 0 volatile  { src Dest } }  }
	{ dst_V_data_V int 24 regular {axi_s 1 volatile  { dst Data } }  }
	{ dst_V_keep_V int 3 regular {axi_s 1 volatile  { dst Keep } }  }
	{ dst_V_strb_V int 3 regular {axi_s 1 volatile  { dst Strb } }  }
	{ dst_V_user_V int 1 regular {axi_s 1 volatile  { dst User } }  }
	{ dst_V_last_V int 1 regular {axi_s 1 volatile  { dst Last } }  }
	{ dst_V_id_V int 1 regular {axi_s 1 volatile  { dst ID } }  }
	{ dst_V_dest_V int 1 regular {axi_s 1 volatile  { dst Dest } }  }
	{ lowthreshold int 8 regular {pointer 0}  }
	{ highthreshold int 8 regular {pointer 0}  }
}
set C_modelArgMapList {[ 
	{ "Name" : "src_V_data_V", "interface" : "axis", "bitwidth" : 24, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "src.V.data.V","cData": "int24","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "src_V_keep_V", "interface" : "axis", "bitwidth" : 3, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "src.V.keep.V","cData": "int3","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "src_V_strb_V", "interface" : "axis", "bitwidth" : 3, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "src.V.strb.V","cData": "int3","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "src_V_user_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "src.V.user.V","cData": "int1","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "src_V_last_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "src.V.last.V","cData": "int1","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "src_V_id_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "src.V.id.V","cData": "int1","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "src_V_dest_V", "interface" : "axis", "bitwidth" : 1, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "src.V.dest.V","cData": "int1","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "dst_V_data_V", "interface" : "axis", "bitwidth" : 24, "direction" : "WRITEONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "dst.V.data.V","cData": "int24","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "dst_V_keep_V", "interface" : "axis", "bitwidth" : 3, "direction" : "WRITEONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "dst.V.keep.V","cData": "int3","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "dst_V_strb_V", "interface" : "axis", "bitwidth" : 3, "direction" : "WRITEONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "dst.V.strb.V","cData": "int3","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "dst_V_user_V", "interface" : "axis", "bitwidth" : 1, "direction" : "WRITEONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "dst.V.user.V","cData": "int1","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "dst_V_last_V", "interface" : "axis", "bitwidth" : 1, "direction" : "WRITEONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "dst.V.last.V","cData": "int1","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "dst_V_id_V", "interface" : "axis", "bitwidth" : 1, "direction" : "WRITEONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "dst.V.id.V","cData": "int1","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "dst_V_dest_V", "interface" : "axis", "bitwidth" : 1, "direction" : "WRITEONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "dst.V.dest.V","cData": "int1","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "lowthreshold", "interface" : "wire", "bitwidth" : 8, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "lowthreshold","cData": "char","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} , 
 	{ "Name" : "highthreshold", "interface" : "wire", "bitwidth" : 8, "direction" : "READONLY", "bitSlice":[{"low":0,"up":0,"cElement": [{"cName": "highthreshold","cData": "char","bit_use": { "low": 0,"up": 0},"cArray": [{"low" : 0,"up" : 0,"step" : 0}]}]}]} ]}
# RTL Port declarations: 
set portNum 24
set portList { 
	{ src_TDATA sc_in sc_lv 24 signal 0 } 
	{ src_TKEEP sc_in sc_lv 3 signal 1 } 
	{ src_TSTRB sc_in sc_lv 3 signal 2 } 
	{ src_TUSER sc_in sc_lv 1 signal 3 } 
	{ src_TLAST sc_in sc_lv 1 signal 4 } 
	{ src_TID sc_in sc_lv 1 signal 5 } 
	{ src_TDEST sc_in sc_lv 1 signal 6 } 
	{ dst_TDATA sc_out sc_lv 24 signal 7 } 
	{ dst_TKEEP sc_out sc_lv 3 signal 8 } 
	{ dst_TSTRB sc_out sc_lv 3 signal 9 } 
	{ dst_TUSER sc_out sc_lv 1 signal 10 } 
	{ dst_TLAST sc_out sc_lv 1 signal 11 } 
	{ dst_TID sc_out sc_lv 1 signal 12 } 
	{ dst_TDEST sc_out sc_lv 1 signal 13 } 
	{ lowthreshold sc_in sc_lv 8 signal 14 } 
	{ highthreshold sc_in sc_lv 8 signal 15 } 
	{ ap_clk sc_in sc_logic 1 clock -1 } 
	{ ap_rst_n sc_in sc_logic 1 reset -1 active_low_sync } 
	{ src_TVALID sc_in sc_logic 1 invld 6 } 
	{ src_TREADY sc_out sc_logic 1 inacc 6 } 
	{ lowthreshold_ap_vld sc_in sc_logic 1 invld 14 } 
	{ highthreshold_ap_vld sc_in sc_logic 1 invld 15 } 
	{ dst_TVALID sc_out sc_logic 1 outvld 13 } 
	{ dst_TREADY sc_in sc_logic 1 outacc 13 } 
}
set NewPortList {[ 
	{ "name": "src_TDATA", "direction": "in", "datatype": "sc_lv", "bitwidth":24, "type": "signal", "bundle":{"name": "src_V_data_V", "role": "default" }} , 
 	{ "name": "src_TKEEP", "direction": "in", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "src_V_keep_V", "role": "default" }} , 
 	{ "name": "src_TSTRB", "direction": "in", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "src_V_strb_V", "role": "default" }} , 
 	{ "name": "src_TUSER", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "src_V_user_V", "role": "default" }} , 
 	{ "name": "src_TLAST", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "src_V_last_V", "role": "default" }} , 
 	{ "name": "src_TID", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "src_V_id_V", "role": "default" }} , 
 	{ "name": "src_TDEST", "direction": "in", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "src_V_dest_V", "role": "default" }} , 
 	{ "name": "dst_TDATA", "direction": "out", "datatype": "sc_lv", "bitwidth":24, "type": "signal", "bundle":{"name": "dst_V_data_V", "role": "default" }} , 
 	{ "name": "dst_TKEEP", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "dst_V_keep_V", "role": "default" }} , 
 	{ "name": "dst_TSTRB", "direction": "out", "datatype": "sc_lv", "bitwidth":3, "type": "signal", "bundle":{"name": "dst_V_strb_V", "role": "default" }} , 
 	{ "name": "dst_TUSER", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "dst_V_user_V", "role": "default" }} , 
 	{ "name": "dst_TLAST", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "dst_V_last_V", "role": "default" }} , 
 	{ "name": "dst_TID", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "dst_V_id_V", "role": "default" }} , 
 	{ "name": "dst_TDEST", "direction": "out", "datatype": "sc_lv", "bitwidth":1, "type": "signal", "bundle":{"name": "dst_V_dest_V", "role": "default" }} , 
 	{ "name": "lowthreshold", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "lowthreshold", "role": "default" }} , 
 	{ "name": "highthreshold", "direction": "in", "datatype": "sc_lv", "bitwidth":8, "type": "signal", "bundle":{"name": "highthreshold", "role": "default" }} , 
 	{ "name": "ap_clk", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "clock", "bundle":{"name": "ap_clk", "role": "default" }} , 
 	{ "name": "ap_rst_n", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "reset", "bundle":{"name": "ap_rst_n", "role": "default" }} , 
 	{ "name": "src_TVALID", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "invld", "bundle":{"name": "src_V_dest_V", "role": "default" }} , 
 	{ "name": "src_TREADY", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "inacc", "bundle":{"name": "src_V_dest_V", "role": "default" }} , 
 	{ "name": "lowthreshold_ap_vld", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "invld", "bundle":{"name": "lowthreshold", "role": "ap_vld" }} , 
 	{ "name": "highthreshold_ap_vld", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "invld", "bundle":{"name": "highthreshold", "role": "ap_vld" }} , 
 	{ "name": "dst_TVALID", "direction": "out", "datatype": "sc_logic", "bitwidth":1, "type": "outvld", "bundle":{"name": "dst_V_dest_V", "role": "default" }} , 
 	{ "name": "dst_TREADY", "direction": "in", "datatype": "sc_logic", "bitwidth":1, "type": "outacc", "bundle":{"name": "dst_V_dest_V", "role": "default" }}  ]}

set RtlHierarchyInfo {[
	{"ID" : "0", "Level" : "0", "Path" : "`AUTOTB_DUT_INST", "Parent" : "", "Child" : ["1", "9", "14", "23", "34", "35", "38", "40", "54", "55", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86"],
		"CDFG" : "edge_canny_detector",
		"Protocol" : "ap_ctrl_none",
		"ControlExist" : "0", "ap_start" : "0", "ap_ready" : "0", "ap_done" : "0", "ap_continue" : "0", "ap_idle" : "0", "real_start" : "0",
		"Pipeline" : "Dataflow", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "1",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "1859948", "EstimateLatencyMax" : "1859948",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "1",
		"InDataflowNetwork" : "0",
		"HasNonBlockingOperation" : "0",
		"InputProcess" : [
			{"ID" : "1", "Name" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0"}],
		"OutputProcess" : [
			{"ID" : "55", "Name" : "xfMat2AXIvideo_24_9_720_1280_1_U0"}],
		"Port" : [
			{"Name" : "src_V_data_V", "Type" : "Axis", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "AXI_video_strm_V_data_V"}]},
			{"Name" : "src_V_keep_V", "Type" : "Axis", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "AXI_video_strm_V_keep_V"}]},
			{"Name" : "src_V_strb_V", "Type" : "Axis", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "AXI_video_strm_V_strb_V"}]},
			{"Name" : "src_V_user_V", "Type" : "Axis", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "AXI_video_strm_V_user_V"}]},
			{"Name" : "src_V_last_V", "Type" : "Axis", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "AXI_video_strm_V_last_V"}]},
			{"Name" : "src_V_id_V", "Type" : "Axis", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "AXI_video_strm_V_id_V"}]},
			{"Name" : "src_V_dest_V", "Type" : "Axis", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "AXI_video_strm_V_dest_V"}]},
			{"Name" : "dst_V_data_V", "Type" : "Axis", "Direction" : "O",
				"SubConnect" : [
					{"ID" : "55", "SubInstance" : "xfMat2AXIvideo_24_9_720_1280_1_U0", "Port" : "AXI_video_strm_V_data_V"}]},
			{"Name" : "dst_V_keep_V", "Type" : "Axis", "Direction" : "O",
				"SubConnect" : [
					{"ID" : "55", "SubInstance" : "xfMat2AXIvideo_24_9_720_1280_1_U0", "Port" : "AXI_video_strm_V_keep_V"}]},
			{"Name" : "dst_V_strb_V", "Type" : "Axis", "Direction" : "O",
				"SubConnect" : [
					{"ID" : "55", "SubInstance" : "xfMat2AXIvideo_24_9_720_1280_1_U0", "Port" : "AXI_video_strm_V_strb_V"}]},
			{"Name" : "dst_V_user_V", "Type" : "Axis", "Direction" : "O",
				"SubConnect" : [
					{"ID" : "55", "SubInstance" : "xfMat2AXIvideo_24_9_720_1280_1_U0", "Port" : "AXI_video_strm_V_user_V"}]},
			{"Name" : "dst_V_last_V", "Type" : "Axis", "Direction" : "O",
				"SubConnect" : [
					{"ID" : "55", "SubInstance" : "xfMat2AXIvideo_24_9_720_1280_1_U0", "Port" : "AXI_video_strm_V_last_V"}]},
			{"Name" : "dst_V_id_V", "Type" : "Axis", "Direction" : "O",
				"SubConnect" : [
					{"ID" : "55", "SubInstance" : "xfMat2AXIvideo_24_9_720_1280_1_U0", "Port" : "AXI_video_strm_V_id_V"}]},
			{"Name" : "dst_V_dest_V", "Type" : "Axis", "Direction" : "O",
				"SubConnect" : [
					{"ID" : "55", "SubInstance" : "xfMat2AXIvideo_24_9_720_1280_1_U0", "Port" : "AXI_video_strm_V_dest_V"}]},
			{"Name" : "lowthreshold", "Type" : "Vld", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "lowthreshold"}]},
			{"Name" : "highthreshold", "Type" : "Vld", "Direction" : "I",
				"SubConnect" : [
					{"ID" : "1", "SubInstance" : "AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Port" : "highthreshold"}]}]},
	{"ID" : "1", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.AXIvideo2xfMat_24_9_720_1280_1_16_U0", "Parent" : "0", "Child" : ["2", "3", "4", "5", "6", "7", "8"],
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
			{"Name" : "rgb_img_src_4206", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "9", "DependentChan" : "63", "DependentChanDepth" : "2", "DependentChanType" : "0",
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
			{"Name" : "lowthreshold_out", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "40", "DependentChan" : "64", "DependentChanDepth" : "7", "DependentChanType" : "2",
				"BlockSignal" : [
					{"Name" : "lowthreshold_out_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "highthreshold_out", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "40", "DependentChan" : "65", "DependentChanDepth" : "7", "DependentChanType" : "2",
				"BlockSignal" : [
					{"Name" : "highthreshold_out_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "2", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.AXIvideo2xfMat_24_9_720_1280_1_16_U0.regslice_both_AXI_video_strm_V_data_V_U", "Parent" : "1"},
	{"ID" : "3", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.AXIvideo2xfMat_24_9_720_1280_1_16_U0.regslice_both_AXI_video_strm_V_keep_V_U", "Parent" : "1"},
	{"ID" : "4", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.AXIvideo2xfMat_24_9_720_1280_1_16_U0.regslice_both_AXI_video_strm_V_strb_V_U", "Parent" : "1"},
	{"ID" : "5", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.AXIvideo2xfMat_24_9_720_1280_1_16_U0.regslice_both_AXI_video_strm_V_user_V_U", "Parent" : "1"},
	{"ID" : "6", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.AXIvideo2xfMat_24_9_720_1280_1_16_U0.regslice_both_AXI_video_strm_V_last_V_U", "Parent" : "1"},
	{"ID" : "7", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.AXIvideo2xfMat_24_9_720_1280_1_16_U0.regslice_both_AXI_video_strm_V_id_V_U", "Parent" : "1"},
	{"ID" : "8", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.AXIvideo2xfMat_24_9_720_1280_1_16_U0.regslice_both_AXI_video_strm_V_dest_V_U", "Parent" : "1"},
	{"ID" : "9", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.xfrgb2gray_720_1280_U0", "Parent" : "0", "Child" : ["10", "11", "12", "13"],
		"CDFG" : "xfrgb2gray_720_1280_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "1",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "921607", "EstimateLatencyMax" : "921607",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"StartSource" : "1",
		"StartFifo" : "start_for_xfrgb2gray_720_1280_U0_U",
		"Port" : [
			{"Name" : "rgb_img_src_4206", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "1", "DependentChan" : "63", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "rgb_img_src_4206_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "gray_img_src_4207", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "14", "DependentChan" : "66", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gray_img_src_4207_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "10", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfrgb2gray_720_1280_U0.call_ret_ExtractPixel_fu_74", "Parent" : "9",
		"CDFG" : "ExtractPixel",
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
			{"Name" : "src_V_read", "Type" : "None", "Direction" : "I"}]},
	{"ID" : "11", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfrgb2gray_720_1280_U0.mul_mul_8ns_15ns_22_4_1_U21", "Parent" : "9"},
	{"ID" : "12", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfrgb2gray_720_1280_U0.mac_muladd_8ns_13ns_22ns_22_4_1_U22", "Parent" : "9"},
	{"ID" : "13", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfrgb2gray_720_1280_U0.mac_muladd_8ns_16ns_22ns_23_4_1_U23", "Parent" : "9"},
	{"ID" : "14", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0", "Parent" : "0", "Child" : ["15", "16", "17", "18", "19", "20", "21", "22"],
		"CDFG" : "xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "1",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "927923", "EstimateLatencyMax" : "927923",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"StartSource" : "9",
		"StartFifo" : "start_for_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0_U",
		"Port" : [
			{"Name" : "gray_img_src_4207", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "9", "DependentChan" : "66", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gray_img_src_4207_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "gaussian_mat_4209", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "23", "DependentChan" : "67", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gaussian_mat_4209_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "15", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.buf_V_0_U", "Parent" : "14"},
	{"ID" : "16", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.buf_V_1_U", "Parent" : "14"},
	{"ID" : "17", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.buf_V_2_U", "Parent" : "14"},
	{"ID" : "18", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.src_buf1_V_2_xfExtractPixels_1_1_0_s_fu_386", "Parent" : "14",
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
	{"ID" : "19", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.src_buf2_V_2_xfExtractPixels_1_1_0_s_fu_391", "Parent" : "14",
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
	{"ID" : "20", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.b2_V_xfExtractPixels_1_1_0_s_fu_396", "Parent" : "14",
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
	{"ID" : "21", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.mux_32_8_1_1_U30", "Parent" : "14"},
	{"ID" : "22", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.mux_32_8_1_1_U31", "Parent" : "14"},
	{"ID" : "23", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0", "Parent" : "0", "Child" : ["24"],
		"CDFG" : "xFSobel_0_2_720_1280_0_3_1_1_5_3_false_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "1",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "931779", "EstimateLatencyMax" : "931779",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"StartSource" : "14",
		"StartFifo" : "start_for_xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0_U",
		"Port" : [
			{"Name" : "gaussian_mat_4209", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "14", "DependentChan" : "67", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"SubConnect" : [
					{"ID" : "24", "SubInstance" : "grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16", "Port" : "gaussian_mat_4209"}]},
			{"Name" : "gradx_mat_4210", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "34", "DependentChan" : "68", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"SubConnect" : [
					{"ID" : "24", "SubInstance" : "grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16", "Port" : "gradx_mat_4210"}]},
			{"Name" : "grady_mat_4213", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "34", "DependentChan" : "69", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"SubConnect" : [
					{"ID" : "24", "SubInstance" : "grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16", "Port" : "grady_mat_4213"}]}]},
	{"ID" : "24", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16", "Parent" : "23", "Child" : ["25", "26", "27", "28", "29", "30", "31", "32", "33"],
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
	{"ID" : "25", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.buf_V_0_U", "Parent" : "24"},
	{"ID" : "26", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.buf_V_1_U", "Parent" : "24"},
	{"ID" : "27", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.buf_V_2_U", "Parent" : "24"},
	{"ID" : "28", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.mux_32_8_1_1_U36", "Parent" : "24"},
	{"ID" : "29", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.mux_32_8_1_1_U37", "Parent" : "24"},
	{"ID" : "30", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.mux_32_8_1_1_U38", "Parent" : "24"},
	{"ID" : "31", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.mux_32_13_1_1_U39", "Parent" : "24"},
	{"ID" : "32", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.mux_32_8_1_1_U40", "Parent" : "24"},
	{"ID" : "33", "Level" : "3", "Path" : "`AUTOTB_DUT_INST.xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.mux_32_8_1_1_U41", "Parent" : "24"},
	{"ID" : "34", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.duplicate_720_1280_U0", "Parent" : "0",
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
		"StartSource" : "23",
		"StartFifo" : "start_for_duplicate_720_1280_U0_U",
		"Port" : [
			{"Name" : "gradx_mat_4210", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "23", "DependentChan" : "68", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx_mat_4210_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady_mat_4213", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "23", "DependentChan" : "69", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady_mat_4213_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "gradx1_mat_4211", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "35", "DependentChan" : "70", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx1_mat_4211_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "gradx2_mat_4212", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "38", "DependentChan" : "71", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx2_mat_4212_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady1_mat_4214", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "35", "DependentChan" : "72", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady1_mat_4214_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady2_mat_4215", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "38", "DependentChan" : "73", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady2_mat_4215_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "35", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0", "Parent" : "0", "Child" : ["36", "37"],
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
		"StartSource" : "34",
		"StartFifo" : "start_for_xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0_U",
		"Port" : [
			{"Name" : "gradx1_mat_4211", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "34", "DependentChan" : "70", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx1_mat_4211_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady1_mat_4214", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "34", "DependentChan" : "72", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady1_mat_4214_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "magnitude_mat_4216", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "40", "DependentChan" : "74", "DependentChanDepth" : "3840", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "magnitude_mat_4216_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "36", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0.mul_mul_16s_16s_32_4_1_U55", "Parent" : "35"},
	{"ID" : "37", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0.mac_muladd_16s_16s_32s_32_4_1_U56", "Parent" : "35"},
	{"ID" : "38", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0", "Parent" : "0", "Child" : ["39"],
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
		"StartSource" : "34",
		"StartFifo" : "start_for_xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0_U",
		"Port" : [
			{"Name" : "gradx2_mat_4212", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "34", "DependentChan" : "71", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "gradx2_mat_4212_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "grady2_mat_4215", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "34", "DependentChan" : "73", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "grady2_mat_4215_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "phase_mat_4217", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "40", "DependentChan" : "75", "DependentChanDepth" : "3840", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "phase_mat_4217_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "39", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0.mul_17s_15ns_32_2_1_U62", "Parent" : "38"},
	{"ID" : "40", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0", "Parent" : "0", "Child" : ["41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53"],
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
		"StartSource" : "1",
		"StartFifo" : "start_for_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0_U",
		"Port" : [
			{"Name" : "magnitude_mat_data", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "35", "DependentChan" : "74", "DependentChanDepth" : "3840", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "magnitude_mat_data_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "phase_mat_data", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "38", "DependentChan" : "75", "DependentChanDepth" : "3840", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "phase_mat_data_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "nms_mat_data", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "54", "DependentChan" : "76", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "nms_mat_data_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "lowthreshold", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "1", "DependentChan" : "64", "DependentChanDepth" : "7", "DependentChanType" : "2",
				"BlockSignal" : [
					{"Name" : "lowthreshold_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "highthreshold", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "1", "DependentChan" : "65", "DependentChanDepth" : "7", "DependentChanType" : "2",
				"BlockSignal" : [
					{"Name" : "highthreshold_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "41", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.angle_V_0_U", "Parent" : "40"},
	{"ID" : "42", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.angle_V_1_U", "Parent" : "40"},
	{"ID" : "43", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.buf_V_0_U", "Parent" : "40"},
	{"ID" : "44", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.buf_V_1_U", "Parent" : "40"},
	{"ID" : "45", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.buf_V_2_U", "Parent" : "40"},
	{"ID" : "46", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.grp_xFFindmax3x3_3_0_0_s_fu_500", "Parent" : "40",
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
	{"ID" : "47", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.l00_buf_V_2_xfExtractPixels_1_5_3_s_fu_526", "Parent" : "40",
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
	{"ID" : "48", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.l10_buf_V_2_xfExtractPixels_1_5_3_s_fu_531", "Parent" : "40",
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
	{"ID" : "49", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.l20_buf_V_2_xfExtractPixels_1_5_3_s_fu_536", "Parent" : "40",
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
	{"ID" : "50", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.angle_buf_V_2_xfExtractPixels_1_1_0_s_fu_541", "Parent" : "40",
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
	{"ID" : "51", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.mux_32_16_1_1_U80", "Parent" : "40"},
	{"ID" : "52", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.mux_32_16_1_1_U81", "Parent" : "40"},
	{"ID" : "53", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.mux_32_16_1_1_U82", "Parent" : "40"},
	{"ID" : "54", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.xfgray2rgb_720_1280_U0", "Parent" : "0",
		"CDFG" : "xfgray2rgb_720_1280_s",
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
		"StartSource" : "40",
		"StartFifo" : "start_for_xfgray2rgb_720_1280_U0_U",
		"Port" : [
			{"Name" : "nms_mat_4218", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "40", "DependentChan" : "76", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "nms_mat_4218_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "rgb_img_dst_4208", "Type" : "Fifo", "Direction" : "O", "DependentProc" : "55", "DependentChan" : "77", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "rgb_img_dst_4208_blk_n", "Type" : "RtlSignal"}]}]},
	{"ID" : "55", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.xfMat2AXIvideo_24_9_720_1280_1_U0", "Parent" : "0", "Child" : ["56", "57", "58", "59", "60", "61", "62"],
		"CDFG" : "xfMat2AXIvideo_24_9_720_1280_1_s",
		"Protocol" : "ap_ctrl_hs",
		"ControlExist" : "1", "ap_start" : "1", "ap_ready" : "1", "ap_done" : "1", "ap_continue" : "1", "ap_idle" : "1", "real_start" : "0",
		"Pipeline" : "None", "UnalignedPipeline" : "0", "RewindPipeline" : "0", "ProcessNetwork" : "0",
		"II" : "0",
		"VariableLatency" : "1", "ExactLatency" : "-1", "EstimateLatencyMin" : "924481", "EstimateLatencyMax" : "924481",
		"Combinational" : "0",
		"Datapath" : "0",
		"ClockEnable" : "0",
		"HasSubDataflow" : "0",
		"InDataflowNetwork" : "1",
		"HasNonBlockingOperation" : "0",
		"StartSource" : "54",
		"StartFifo" : "start_for_xfMat2AXIvideo_24_9_720_1280_1_U0_U",
		"Port" : [
			{"Name" : "rgb_img_dst_4208", "Type" : "Fifo", "Direction" : "I", "DependentProc" : "54", "DependentChan" : "77", "DependentChanDepth" : "2", "DependentChanType" : "0",
				"BlockSignal" : [
					{"Name" : "rgb_img_dst_4208_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "AXI_video_strm_V_data_V", "Type" : "Axis", "Direction" : "O",
				"BlockSignal" : [
					{"Name" : "dst_TDATA_blk_n", "Type" : "RtlSignal"}]},
			{"Name" : "AXI_video_strm_V_keep_V", "Type" : "Axis", "Direction" : "O"},
			{"Name" : "AXI_video_strm_V_strb_V", "Type" : "Axis", "Direction" : "O"},
			{"Name" : "AXI_video_strm_V_user_V", "Type" : "Axis", "Direction" : "O"},
			{"Name" : "AXI_video_strm_V_last_V", "Type" : "Axis", "Direction" : "O"},
			{"Name" : "AXI_video_strm_V_id_V", "Type" : "Axis", "Direction" : "O"},
			{"Name" : "AXI_video_strm_V_dest_V", "Type" : "Axis", "Direction" : "O"}]},
	{"ID" : "56", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfMat2AXIvideo_24_9_720_1280_1_U0.regslice_both_AXI_video_strm_V_data_V_U", "Parent" : "55"},
	{"ID" : "57", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfMat2AXIvideo_24_9_720_1280_1_U0.regslice_both_AXI_video_strm_V_keep_V_U", "Parent" : "55"},
	{"ID" : "58", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfMat2AXIvideo_24_9_720_1280_1_U0.regslice_both_AXI_video_strm_V_strb_V_U", "Parent" : "55"},
	{"ID" : "59", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfMat2AXIvideo_24_9_720_1280_1_U0.regslice_both_AXI_video_strm_V_user_V_U", "Parent" : "55"},
	{"ID" : "60", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfMat2AXIvideo_24_9_720_1280_1_U0.regslice_both_AXI_video_strm_V_last_V_U", "Parent" : "55"},
	{"ID" : "61", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfMat2AXIvideo_24_9_720_1280_1_U0.regslice_both_AXI_video_strm_V_id_V_U", "Parent" : "55"},
	{"ID" : "62", "Level" : "2", "Path" : "`AUTOTB_DUT_INST.xfMat2AXIvideo_24_9_720_1280_1_U0.regslice_both_AXI_video_strm_V_dest_V_U", "Parent" : "55"},
	{"ID" : "63", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.rgb_img_src_data_U", "Parent" : "0"},
	{"ID" : "64", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.lowthreshold_c_U", "Parent" : "0"},
	{"ID" : "65", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.highthreshold_c_U", "Parent" : "0"},
	{"ID" : "66", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.gray_img_src_data_U", "Parent" : "0"},
	{"ID" : "67", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.gaussian_mat_data_U", "Parent" : "0"},
	{"ID" : "68", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.gradx_mat_data_U", "Parent" : "0"},
	{"ID" : "69", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grady_mat_data_U", "Parent" : "0"},
	{"ID" : "70", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.gradx1_mat_data_U", "Parent" : "0"},
	{"ID" : "71", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.gradx2_mat_data_U", "Parent" : "0"},
	{"ID" : "72", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grady1_mat_data_U", "Parent" : "0"},
	{"ID" : "73", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.grady2_mat_data_U", "Parent" : "0"},
	{"ID" : "74", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.magnitude_mat_data_U", "Parent" : "0"},
	{"ID" : "75", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.phase_mat_data_U", "Parent" : "0"},
	{"ID" : "76", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.nms_mat_data_U", "Parent" : "0"},
	{"ID" : "77", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.rgb_img_dst_data_U", "Parent" : "0"},
	{"ID" : "78", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_xfrgb2gray_720_1280_U0_U", "Parent" : "0"},
	{"ID" : "79", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0_U", "Parent" : "0"},
	{"ID" : "80", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0_U", "Parent" : "0"},
	{"ID" : "81", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0_U", "Parent" : "0"},
	{"ID" : "82", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_duplicate_720_1280_U0_U", "Parent" : "0"},
	{"ID" : "83", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0_U", "Parent" : "0"},
	{"ID" : "84", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0_U", "Parent" : "0"},
	{"ID" : "85", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_xfgray2rgb_720_1280_U0_U", "Parent" : "0"},
	{"ID" : "86", "Level" : "1", "Path" : "`AUTOTB_DUT_INST.start_for_xfMat2AXIvideo_24_9_720_1280_1_U0_U", "Parent" : "0"}]}


set ArgLastReadFirstWriteLatency {
	edge_canny_detector {
		src_V_data_V {Type I LastRead 6 FirstWrite -1}
		src_V_keep_V {Type I LastRead 6 FirstWrite -1}
		src_V_strb_V {Type I LastRead 6 FirstWrite -1}
		src_V_user_V {Type I LastRead 6 FirstWrite -1}
		src_V_last_V {Type I LastRead 6 FirstWrite -1}
		src_V_id_V {Type I LastRead 6 FirstWrite -1}
		src_V_dest_V {Type I LastRead 6 FirstWrite -1}
		dst_V_data_V {Type O LastRead -1 FirstWrite 3}
		dst_V_keep_V {Type O LastRead -1 FirstWrite 3}
		dst_V_strb_V {Type O LastRead -1 FirstWrite 3}
		dst_V_user_V {Type O LastRead -1 FirstWrite 3}
		dst_V_last_V {Type O LastRead -1 FirstWrite 3}
		dst_V_id_V {Type O LastRead -1 FirstWrite 3}
		dst_V_dest_V {Type O LastRead -1 FirstWrite 3}
		lowthreshold {Type I LastRead 0 FirstWrite -1}
		highthreshold {Type I LastRead 0 FirstWrite -1}}
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
		highthreshold_out {Type O LastRead -1 FirstWrite 0}}
	xfrgb2gray_720_1280_s {
		rgb_img_src_4206 {Type I LastRead 2 FirstWrite -1}
		gray_img_src_4207 {Type O LastRead -1 FirstWrite 7}}
	ExtractPixel {
		src_V_read {Type I LastRead 0 FirstWrite -1}}
	xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_s {
		gray_img_src_4207 {Type I LastRead 5 FirstWrite -1}
		gaussian_mat_4209 {Type O LastRead -1 FirstWrite 8}}
	xfExtractPixels_1_1_0_s {
		p_read1 {Type I LastRead 0 FirstWrite -1}}
	xfExtractPixels_1_1_0_s {
		p_read1 {Type I LastRead 0 FirstWrite -1}}
	xfExtractPixels_1_1_0_s {
		p_read1 {Type I LastRead 0 FirstWrite -1}}
	xFSobel_0_2_720_1280_0_3_1_1_5_3_false_s {
		gaussian_mat_4209 {Type I LastRead 8 FirstWrite -1}
		gradx_mat_4210 {Type O LastRead -1 FirstWrite 11}
		grady_mat_4213 {Type O LastRead -1 FirstWrite 11}}
	xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s {
		gaussian_mat_4209 {Type I LastRead 8 FirstWrite -1}
		gradx_mat_4210 {Type O LastRead -1 FirstWrite 11}
		grady_mat_4213 {Type O LastRead -1 FirstWrite 11}}
	duplicate_720_1280_s {
		gradx_mat_4210 {Type I LastRead 2 FirstWrite -1}
		grady_mat_4213 {Type I LastRead 2 FirstWrite -1}
		gradx1_mat_4211 {Type O LastRead -1 FirstWrite 2}
		gradx2_mat_4212 {Type O LastRead -1 FirstWrite 2}
		grady1_mat_4214 {Type O LastRead -1 FirstWrite 2}
		grady2_mat_4215 {Type O LastRead -1 FirstWrite 2}}
	xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_s {
		gradx1_mat_4211 {Type I LastRead 3 FirstWrite -1}
		grady1_mat_4214 {Type I LastRead 3 FirstWrite -1}
		magnitude_mat_4216 {Type O LastRead -1 FirstWrite 15}}
	xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_s {
		gradx2_mat_4212 {Type I LastRead 3 FirstWrite -1}
		grady2_mat_4215 {Type I LastRead 3 FirstWrite -1}
		phase_mat_4217 {Type O LastRead -1 FirstWrite 6}}
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
		p_read1 {Type I LastRead 0 FirstWrite -1}}
	xfgray2rgb_720_1280_s {
		nms_mat_4218 {Type I LastRead 2 FirstWrite -1}
		rgb_img_dst_4208 {Type O LastRead -1 FirstWrite 2}}
	xfMat2AXIvideo_24_9_720_1280_1_s {
		rgb_img_dst_4208 {Type I LastRead 3 FirstWrite -1}
		AXI_video_strm_V_data_V {Type O LastRead -1 FirstWrite 3}
		AXI_video_strm_V_keep_V {Type O LastRead -1 FirstWrite 3}
		AXI_video_strm_V_strb_V {Type O LastRead -1 FirstWrite 3}
		AXI_video_strm_V_user_V {Type O LastRead -1 FirstWrite 3}
		AXI_video_strm_V_last_V {Type O LastRead -1 FirstWrite 3}
		AXI_video_strm_V_id_V {Type O LastRead -1 FirstWrite 3}
		AXI_video_strm_V_dest_V {Type O LastRead -1 FirstWrite 3}}}

set hasDtUnsupportedChannel 0

set PerformanceInfo {[
	{"Name" : "Latency", "Min" : "1859948", "Max" : "1859948"}
	, {"Name" : "Interval", "Min" : "932402", "Max" : "932402"}
]}

set PipelineEnableSignalInfo {[
]}

set Spec2ImplPortList { 
	src_V_data_V { axis {  { src_TDATA in_data 0 24 } } }
	src_V_keep_V { axis {  { src_TKEEP in_data 0 3 } } }
	src_V_strb_V { axis {  { src_TSTRB in_data 0 3 } } }
	src_V_user_V { axis {  { src_TUSER in_data 0 1 } } }
	src_V_last_V { axis {  { src_TLAST in_data 0 1 } } }
	src_V_id_V { axis {  { src_TID in_data 0 1 } } }
	src_V_dest_V { axis {  { src_TDEST in_data 0 1 }  { src_TVALID in_vld 0 1 }  { src_TREADY in_acc 1 1 } } }
	dst_V_data_V { axis {  { dst_TDATA out_data 1 24 } } }
	dst_V_keep_V { axis {  { dst_TKEEP out_data 1 3 } } }
	dst_V_strb_V { axis {  { dst_TSTRB out_data 1 3 } } }
	dst_V_user_V { axis {  { dst_TUSER out_data 1 1 } } }
	dst_V_last_V { axis {  { dst_TLAST out_data 1 1 } } }
	dst_V_id_V { axis {  { dst_TID out_data 1 1 } } }
	dst_V_dest_V { axis {  { dst_TDEST out_data 1 1 }  { dst_TVALID out_vld 1 1 }  { dst_TREADY out_acc 0 1 } } }
	lowthreshold { ap_vld {  { lowthreshold in_data 0 8 }  { lowthreshold_ap_vld in_vld 0 1 } } }
	highthreshold { ap_vld {  { highthreshold in_data 0 8 }  { highthreshold_ap_vld in_vld 0 1 } } }
}

set busDeadlockParameterList { 
}

# RTL port scheduling information:
set fifoSchedulingInfoList { 
}

# RTL bus port read request latency information:
set busReadReqLatencyList { 
}

# RTL bus port write response latency information:
set busWriteResLatencyList { 
}

# RTL array port load latency information:
set memoryLoadLatencyList { 
}
