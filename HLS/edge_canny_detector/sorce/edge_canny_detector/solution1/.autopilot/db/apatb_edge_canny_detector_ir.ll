; ModuleID = 'C:/Users/suisuisi/Desktop/OpenZYNQ_K/example/Vivado_ip/myip/edge_canny_detector/edge_canny_detector/edge_canny_detector/solution1/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

%"class.hls::stream" = type { %"struct.hls::axis" }
%"struct.hls::axis" = type { %struct.ap_uint, %struct.ap_uint.20, %struct.ap_uint.20, %struct.ap_uint.23, %struct.ap_uint.23, %struct.ap_uint.23, %struct.ap_uint.23 }
%struct.ap_uint = type { %struct.ap_int_base }
%struct.ap_int_base = type { %struct.ssdm_int }
%struct.ssdm_int = type { i24 }
%struct.ap_uint.20 = type { %struct.ap_int_base.21 }
%struct.ap_int_base.21 = type { %struct.ssdm_int.22 }
%struct.ssdm_int.22 = type { i3 }
%struct.ap_uint.23 = type { %struct.ap_int_base.24 }
%struct.ap_int_base.24 = type { %struct.ssdm_int.25 }
%struct.ssdm_int.25 = type { i1 }
%struct.ap_uint.0 = type { %struct.ap_int_base.1 }
%struct.ap_int_base.1 = type { %struct.ssdm_int.2 }
%struct.ssdm_int.2 = type { i8 }

; Function Attrs: noinline
define void @apatb_edge_canny_detector_ir(%"class.hls::stream"* %src, %"class.hls::stream"* %dst, %struct.ap_uint.0* %lowthreshold, %struct.ap_uint.0* %highthreshold) local_unnamed_addr #0 {
entry:
  %src_copy = alloca [16 x %"class.hls::stream"], align 512
  %dst_copy = alloca [16 x %"class.hls::stream"], align 512
  %lowthreshold_copy1 = alloca %struct.ap_uint.0, align 512
  %highthreshold_copy2 = alloca %struct.ap_uint.0, align 512
  %0 = bitcast %"class.hls::stream"* %src to [16 x %"class.hls::stream"]*
  %1 = bitcast %"class.hls::stream"* %dst to [16 x %"class.hls::stream"]*
  call fastcc void @copy_in([16 x %"class.hls::stream"]* %0, [16 x %"class.hls::stream"]* nonnull align 512 %src_copy, [16 x %"class.hls::stream"]* %1, [16 x %"class.hls::stream"]* nonnull align 512 %dst_copy, %struct.ap_uint.0* %lowthreshold, %struct.ap_uint.0* nonnull align 512 %lowthreshold_copy1, %struct.ap_uint.0* %highthreshold, %struct.ap_uint.0* nonnull align 512 %highthreshold_copy2)
  %2 = getelementptr inbounds [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %src_copy, i32 0, i32 0
  %3 = getelementptr inbounds [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %dst_copy, i32 0, i32 0
  call void @apatb_edge_canny_detector_hw(%"class.hls::stream"* %2, %"class.hls::stream"* %3, %struct.ap_uint.0* %lowthreshold_copy1, %struct.ap_uint.0* %highthreshold_copy2)
  call fastcc void @copy_out([16 x %"class.hls::stream"]* %0, [16 x %"class.hls::stream"]* nonnull align 512 %src_copy, [16 x %"class.hls::stream"]* %1, [16 x %"class.hls::stream"]* nonnull align 512 %dst_copy, %struct.ap_uint.0* %lowthreshold, %struct.ap_uint.0* nonnull align 512 %lowthreshold_copy1, %struct.ap_uint.0* %highthreshold, %struct.ap_uint.0* nonnull align 512 %highthreshold_copy2)
  ret void
}

; Function Attrs: noinline
define internal fastcc void @copy_in([16 x %"class.hls::stream"]*, [16 x %"class.hls::stream"]* noalias align 512, [16 x %"class.hls::stream"]*, [16 x %"class.hls::stream"]* noalias align 512, %struct.ap_uint.0*, %struct.ap_uint.0* noalias align 512, %struct.ap_uint.0*, %struct.ap_uint.0* noalias align 512) unnamed_addr #1 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a16class.hls::stream"([16 x %"class.hls::stream"]* align 512 %1, [16 x %"class.hls::stream"]* %0)
  call fastcc void @"onebyonecpy_hls.p0a16class.hls::stream"([16 x %"class.hls::stream"]* align 512 %3, [16 x %"class.hls::stream"]* %2)
  call fastcc void @onebyonecpy_hls.p0struct.ap_uint.0(%struct.ap_uint.0* align 512 %5, %struct.ap_uint.0* %4)
  call fastcc void @onebyonecpy_hls.p0struct.ap_uint.0(%struct.ap_uint.0* align 512 %7, %struct.ap_uint.0* %6)
  ret void
}

; Function Attrs: noinline
define internal fastcc void @"onebyonecpy_hls.p0a16class.hls::stream"([16 x %"class.hls::stream"]* noalias align 512, [16 x %"class.hls::stream"]* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq [16 x %"class.hls::stream"]* %0, null
  %3 = icmp eq [16 x %"class.hls::stream"]* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  br label %for.loop

for.loop:                                         ; preds = %for.loop.head, %copy
  %for.loop.idx73 = phi i64 [ 0, %copy ], [ %for.loop.idx.next, %for.loop.head ]
  %dst.addr = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73
  %src.addr = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73
  %5 = bitcast %"class.hls::stream"* %src.addr to i8*
  %6 = call i1 @fpga_fifo_exist_12(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %for.loop
  call fastcc void @"streamcpy_hls.p0class.hls::stream"(%"class.hls::stream"* %dst.addr, %"class.hls::stream"* %src.addr)
  br label %for.loop.head

; <label>:8:                                      ; preds = %for.loop
  %src.addr.0.03 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 0
  %dst.addr.0.04 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 0
  %9 = bitcast %struct.ap_uint* %src.addr.0.03 to i8*
  %10 = call i1 @fpga_fifo_exist_4(i8* %9)
  br i1 %10, label %11, label %12

; <label>:11:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_uint(%struct.ap_uint* %dst.addr.0.04, %struct.ap_uint* %src.addr.0.03)
  br label %23

; <label>:12:                                     ; preds = %8
  %src.addr.0.0.05 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 0, i32 0
  %dst.addr.0.0.06 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 0, i32 0
  %13 = bitcast %struct.ap_int_base* %src.addr.0.0.05 to i8*
  %14 = call i1 @fpga_fifo_exist_4(i8* %13)
  br i1 %14, label %15, label %16

; <label>:15:                                     ; preds = %12
  call fastcc void @streamcpy_hls.p0struct.ap_int_base(%struct.ap_int_base* %dst.addr.0.0.06, %struct.ap_int_base* %src.addr.0.0.05)
  br label %23

; <label>:16:                                     ; preds = %12
  %src.addr.0.0.0.07 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 0, i32 0, i32 0
  %dst.addr.0.0.0.08 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 0, i32 0, i32 0
  %17 = bitcast %struct.ssdm_int* %src.addr.0.0.0.07 to i8*
  %18 = call i1 @fpga_fifo_exist_4(i8* %17)
  br i1 %18, label %19, label %20

; <label>:19:                                     ; preds = %16
  call fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* %dst.addr.0.0.0.08, %struct.ssdm_int* %src.addr.0.0.0.07)
  br label %23

; <label>:20:                                     ; preds = %16
  %dst.addr.0.0.0.0.010.gep59 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 0, i32 0, i32 0, i32 0
  %21 = bitcast i24* %dst.addr.0.0.0.0.010.gep59 to i8*
  %src.addr.0.0.0.0.09.gep60 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 0, i32 0, i32 0, i32 0
  %22 = bitcast i24* %src.addr.0.0.0.0.09.gep60 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %21, i8* align 1 %22, i64 4, i1 false)
  br label %23

; <label>:23:                                     ; preds = %20, %19, %15, %11
  %src.addr.0.111 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 1
  %dst.addr.0.112 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 1
  %24 = bitcast %struct.ap_uint.20* %src.addr.0.111 to i8*
  %25 = call i1 @fpga_fifo_exist_1(i8* %24)
  br i1 %25, label %26, label %27

; <label>:26:                                     ; preds = %23
  call fastcc void @streamcpy_hls.p0struct.ap_uint.20(%struct.ap_uint.20* %dst.addr.0.112, %struct.ap_uint.20* %src.addr.0.111)
  br label %38

; <label>:27:                                     ; preds = %23
  %src.addr.0.1.013 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 1, i32 0
  %dst.addr.0.1.014 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 1, i32 0
  %28 = bitcast %struct.ap_int_base.21* %src.addr.0.1.013 to i8*
  %29 = call i1 @fpga_fifo_exist_1(i8* %28)
  br i1 %29, label %30, label %31

; <label>:30:                                     ; preds = %27
  call fastcc void @streamcpy_hls.p0struct.ap_int_base.21(%struct.ap_int_base.21* %dst.addr.0.1.014, %struct.ap_int_base.21* %src.addr.0.1.013)
  br label %38

; <label>:31:                                     ; preds = %27
  %src.addr.0.1.0.015 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 1, i32 0, i32 0
  %dst.addr.0.1.0.016 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 1, i32 0, i32 0
  %32 = bitcast %struct.ssdm_int.22* %src.addr.0.1.0.015 to i8*
  %33 = call i1 @fpga_fifo_exist_1(i8* %32)
  br i1 %33, label %34, label %35

; <label>:34:                                     ; preds = %31
  call fastcc void @streamcpy_hls.p0struct.ssdm_int.22(%struct.ssdm_int.22* %dst.addr.0.1.0.016, %struct.ssdm_int.22* %src.addr.0.1.0.015)
  br label %38

; <label>:35:                                     ; preds = %31
  %dst.addr.0.1.0.0.018.gep61 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 1, i32 0, i32 0, i32 0
  %36 = bitcast i3* %dst.addr.0.1.0.0.018.gep61 to i8*
  %src.addr.0.1.0.0.017.gep62 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 1, i32 0, i32 0, i32 0
  %37 = bitcast i3* %src.addr.0.1.0.0.017.gep62 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %36, i8* align 1 %37, i64 1, i1 false)
  br label %38

; <label>:38:                                     ; preds = %35, %34, %30, %26
  %src.addr.0.219 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 2
  %dst.addr.0.220 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 2
  %39 = bitcast %struct.ap_uint.20* %src.addr.0.219 to i8*
  %40 = call i1 @fpga_fifo_exist_1(i8* %39)
  br i1 %40, label %41, label %42

; <label>:41:                                     ; preds = %38
  call fastcc void @streamcpy_hls.p0struct.ap_uint.20(%struct.ap_uint.20* %dst.addr.0.220, %struct.ap_uint.20* %src.addr.0.219)
  br label %53

; <label>:42:                                     ; preds = %38
  %src.addr.0.2.021 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 2, i32 0
  %dst.addr.0.2.022 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 2, i32 0
  %43 = bitcast %struct.ap_int_base.21* %src.addr.0.2.021 to i8*
  %44 = call i1 @fpga_fifo_exist_1(i8* %43)
  br i1 %44, label %45, label %46

; <label>:45:                                     ; preds = %42
  call fastcc void @streamcpy_hls.p0struct.ap_int_base.21(%struct.ap_int_base.21* %dst.addr.0.2.022, %struct.ap_int_base.21* %src.addr.0.2.021)
  br label %53

; <label>:46:                                     ; preds = %42
  %src.addr.0.2.0.023 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 2, i32 0, i32 0
  %dst.addr.0.2.0.024 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 2, i32 0, i32 0
  %47 = bitcast %struct.ssdm_int.22* %src.addr.0.2.0.023 to i8*
  %48 = call i1 @fpga_fifo_exist_1(i8* %47)
  br i1 %48, label %49, label %50

; <label>:49:                                     ; preds = %46
  call fastcc void @streamcpy_hls.p0struct.ssdm_int.22(%struct.ssdm_int.22* %dst.addr.0.2.0.024, %struct.ssdm_int.22* %src.addr.0.2.0.023)
  br label %53

; <label>:50:                                     ; preds = %46
  %dst.addr.0.2.0.0.026.gep63 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 2, i32 0, i32 0, i32 0
  %51 = bitcast i3* %dst.addr.0.2.0.0.026.gep63 to i8*
  %src.addr.0.2.0.0.025.gep64 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 2, i32 0, i32 0, i32 0
  %52 = bitcast i3* %src.addr.0.2.0.0.025.gep64 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %51, i8* align 1 %52, i64 1, i1 false)
  br label %53

; <label>:53:                                     ; preds = %50, %49, %45, %41
  %src.addr.0.327 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 3
  %dst.addr.0.328 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 3
  %54 = bitcast %struct.ap_uint.23* %src.addr.0.327 to i8*
  %55 = call i1 @fpga_fifo_exist_1(i8* %54)
  br i1 %55, label %56, label %57

; <label>:56:                                     ; preds = %53
  call fastcc void @streamcpy_hls.p0struct.ap_uint.23(%struct.ap_uint.23* %dst.addr.0.328, %struct.ap_uint.23* %src.addr.0.327)
  br label %68

; <label>:57:                                     ; preds = %53
  %src.addr.0.3.029 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 3, i32 0
  %dst.addr.0.3.030 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 3, i32 0
  %58 = bitcast %struct.ap_int_base.24* %src.addr.0.3.029 to i8*
  %59 = call i1 @fpga_fifo_exist_1(i8* %58)
  br i1 %59, label %60, label %61

; <label>:60:                                     ; preds = %57
  call fastcc void @streamcpy_hls.p0struct.ap_int_base.24(%struct.ap_int_base.24* %dst.addr.0.3.030, %struct.ap_int_base.24* %src.addr.0.3.029)
  br label %68

; <label>:61:                                     ; preds = %57
  %src.addr.0.3.0.031 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 3, i32 0, i32 0
  %dst.addr.0.3.0.032 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 3, i32 0, i32 0
  %62 = bitcast %struct.ssdm_int.25* %src.addr.0.3.0.031 to i8*
  %63 = call i1 @fpga_fifo_exist_1(i8* %62)
  br i1 %63, label %64, label %65

; <label>:64:                                     ; preds = %61
  call fastcc void @streamcpy_hls.p0struct.ssdm_int.25(%struct.ssdm_int.25* %dst.addr.0.3.0.032, %struct.ssdm_int.25* %src.addr.0.3.0.031)
  br label %68

; <label>:65:                                     ; preds = %61
  %dst.addr.0.3.0.0.034.gep65 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 3, i32 0, i32 0, i32 0
  %66 = bitcast i1* %dst.addr.0.3.0.0.034.gep65 to i8*
  %src.addr.0.3.0.0.033.gep66 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 3, i32 0, i32 0, i32 0
  %67 = bitcast i1* %src.addr.0.3.0.0.033.gep66 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %66, i8* align 1 %67, i64 1, i1 false)
  br label %68

; <label>:68:                                     ; preds = %65, %64, %60, %56
  %src.addr.0.435 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 4
  %dst.addr.0.436 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 4
  %69 = bitcast %struct.ap_uint.23* %src.addr.0.435 to i8*
  %70 = call i1 @fpga_fifo_exist_1(i8* %69)
  br i1 %70, label %71, label %72

; <label>:71:                                     ; preds = %68
  call fastcc void @streamcpy_hls.p0struct.ap_uint.23(%struct.ap_uint.23* %dst.addr.0.436, %struct.ap_uint.23* %src.addr.0.435)
  br label %83

; <label>:72:                                     ; preds = %68
  %src.addr.0.4.037 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 4, i32 0
  %dst.addr.0.4.038 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 4, i32 0
  %73 = bitcast %struct.ap_int_base.24* %src.addr.0.4.037 to i8*
  %74 = call i1 @fpga_fifo_exist_1(i8* %73)
  br i1 %74, label %75, label %76

; <label>:75:                                     ; preds = %72
  call fastcc void @streamcpy_hls.p0struct.ap_int_base.24(%struct.ap_int_base.24* %dst.addr.0.4.038, %struct.ap_int_base.24* %src.addr.0.4.037)
  br label %83

; <label>:76:                                     ; preds = %72
  %src.addr.0.4.0.039 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 4, i32 0, i32 0
  %dst.addr.0.4.0.040 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 4, i32 0, i32 0
  %77 = bitcast %struct.ssdm_int.25* %src.addr.0.4.0.039 to i8*
  %78 = call i1 @fpga_fifo_exist_1(i8* %77)
  br i1 %78, label %79, label %80

; <label>:79:                                     ; preds = %76
  call fastcc void @streamcpy_hls.p0struct.ssdm_int.25(%struct.ssdm_int.25* %dst.addr.0.4.0.040, %struct.ssdm_int.25* %src.addr.0.4.0.039)
  br label %83

; <label>:80:                                     ; preds = %76
  %dst.addr.0.4.0.0.042.gep67 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 4, i32 0, i32 0, i32 0
  %81 = bitcast i1* %dst.addr.0.4.0.0.042.gep67 to i8*
  %src.addr.0.4.0.0.041.gep68 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 4, i32 0, i32 0, i32 0
  %82 = bitcast i1* %src.addr.0.4.0.0.041.gep68 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %81, i8* align 1 %82, i64 1, i1 false)
  br label %83

; <label>:83:                                     ; preds = %80, %79, %75, %71
  %src.addr.0.543 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 5
  %dst.addr.0.544 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 5
  %84 = bitcast %struct.ap_uint.23* %src.addr.0.543 to i8*
  %85 = call i1 @fpga_fifo_exist_1(i8* %84)
  br i1 %85, label %86, label %87

; <label>:86:                                     ; preds = %83
  call fastcc void @streamcpy_hls.p0struct.ap_uint.23(%struct.ap_uint.23* %dst.addr.0.544, %struct.ap_uint.23* %src.addr.0.543)
  br label %98

; <label>:87:                                     ; preds = %83
  %src.addr.0.5.045 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 5, i32 0
  %dst.addr.0.5.046 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 5, i32 0
  %88 = bitcast %struct.ap_int_base.24* %src.addr.0.5.045 to i8*
  %89 = call i1 @fpga_fifo_exist_1(i8* %88)
  br i1 %89, label %90, label %91

; <label>:90:                                     ; preds = %87
  call fastcc void @streamcpy_hls.p0struct.ap_int_base.24(%struct.ap_int_base.24* %dst.addr.0.5.046, %struct.ap_int_base.24* %src.addr.0.5.045)
  br label %98

; <label>:91:                                     ; preds = %87
  %src.addr.0.5.0.047 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 5, i32 0, i32 0
  %dst.addr.0.5.0.048 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 5, i32 0, i32 0
  %92 = bitcast %struct.ssdm_int.25* %src.addr.0.5.0.047 to i8*
  %93 = call i1 @fpga_fifo_exist_1(i8* %92)
  br i1 %93, label %94, label %95

; <label>:94:                                     ; preds = %91
  call fastcc void @streamcpy_hls.p0struct.ssdm_int.25(%struct.ssdm_int.25* %dst.addr.0.5.0.048, %struct.ssdm_int.25* %src.addr.0.5.0.047)
  br label %98

; <label>:95:                                     ; preds = %91
  %dst.addr.0.5.0.0.050.gep69 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 5, i32 0, i32 0, i32 0
  %96 = bitcast i1* %dst.addr.0.5.0.0.050.gep69 to i8*
  %src.addr.0.5.0.0.049.gep70 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 5, i32 0, i32 0, i32 0
  %97 = bitcast i1* %src.addr.0.5.0.0.049.gep70 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %96, i8* align 1 %97, i64 1, i1 false)
  br label %98

; <label>:98:                                     ; preds = %95, %94, %90, %86
  %src.addr.0.651 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 6
  %dst.addr.0.652 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 6
  %99 = bitcast %struct.ap_uint.23* %src.addr.0.651 to i8*
  %100 = call i1 @fpga_fifo_exist_1(i8* %99)
  br i1 %100, label %101, label %102

; <label>:101:                                    ; preds = %98
  call fastcc void @streamcpy_hls.p0struct.ap_uint.23(%struct.ap_uint.23* %dst.addr.0.652, %struct.ap_uint.23* %src.addr.0.651)
  br label %for.loop.head

; <label>:102:                                    ; preds = %98
  %src.addr.0.6.053 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 6, i32 0
  %dst.addr.0.6.054 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 6, i32 0
  %103 = bitcast %struct.ap_int_base.24* %src.addr.0.6.053 to i8*
  %104 = call i1 @fpga_fifo_exist_1(i8* %103)
  br i1 %104, label %105, label %106

; <label>:105:                                    ; preds = %102
  call fastcc void @streamcpy_hls.p0struct.ap_int_base.24(%struct.ap_int_base.24* %dst.addr.0.6.054, %struct.ap_int_base.24* %src.addr.0.6.053)
  br label %for.loop.head

; <label>:106:                                    ; preds = %102
  %src.addr.0.6.0.055 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 6, i32 0, i32 0
  %dst.addr.0.6.0.056 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 6, i32 0, i32 0
  %107 = bitcast %struct.ssdm_int.25* %src.addr.0.6.0.055 to i8*
  %108 = call i1 @fpga_fifo_exist_1(i8* %107)
  br i1 %108, label %109, label %110

; <label>:109:                                    ; preds = %106
  call fastcc void @streamcpy_hls.p0struct.ssdm_int.25(%struct.ssdm_int.25* %dst.addr.0.6.0.056, %struct.ssdm_int.25* %src.addr.0.6.0.055)
  br label %for.loop.head

; <label>:110:                                    ; preds = %106
  %dst.addr.0.6.0.0.058.gep71 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %0, i64 0, i64 %for.loop.idx73, i32 0, i32 6, i32 0, i32 0, i32 0
  %111 = bitcast i1* %dst.addr.0.6.0.0.058.gep71 to i8*
  %src.addr.0.6.0.0.057.gep72 = getelementptr [16 x %"class.hls::stream"], [16 x %"class.hls::stream"]* %1, i64 0, i64 %for.loop.idx73, i32 0, i32 6, i32 0, i32 0, i32 0
  %112 = bitcast i1* %src.addr.0.6.0.0.057.gep72 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %111, i8* align 1 %112, i64 1, i1 false)
  br label %for.loop.head

for.loop.head:                                    ; preds = %110, %109, %105, %101, %7
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx73, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, 16
  br i1 %exitcond, label %for.loop, label %ret

ret:                                              ; preds = %for.loop.head, %entry
  ret void
}

declare i1 @fpga_fifo_exist_12(i8*) local_unnamed_addr

; Function Attrs: argmemonly noinline
define internal fastcc void @"streamcpy_hls.p0class.hls::stream"(%"class.hls::stream"* noalias nocapture, %"class.hls::stream"* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %"class.hls::stream"
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %"class.hls::stream"* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_12(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %"class.hls::stream"* %2 to i8*
  %6 = bitcast %"class.hls::stream"* %1 to i8*
  call void @fpga_fifo_pop_12(i8* %5, i8* %6)
  %7 = load volatile %"class.hls::stream", %"class.hls::stream"* %2
  %8 = bitcast %"class.hls::stream"* %2 to i8*
  %9 = bitcast %"class.hls::stream"* %0 to i8*
  call void @fpga_fifo_push_12(i8* %8, i8* %9)
  br label %empty, !llvm.loop !5

ret:                                              ; preds = %empty
  %10 = bitcast %"class.hls::stream"* %1 to i8*
  %11 = bitcast %"class.hls::stream"* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 12, i1 false)
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1) #4

declare i1 @fpga_fifo_exist_4(i8*) local_unnamed_addr

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_uint(%struct.ap_uint* noalias nocapture, %struct.ap_uint* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_uint
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_uint* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_4(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_uint* %2 to i8*
  %6 = bitcast %struct.ap_uint* %1 to i8*
  call void @fpga_fifo_pop_4(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_uint, %struct.ap_uint* %2
  %8 = bitcast %struct.ap_uint* %2 to i8*
  %9 = bitcast %struct.ap_uint* %0 to i8*
  call void @fpga_fifo_push_4(i8* %8, i8* %9)
  br label %empty, !llvm.loop !7

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ap_uint* %1 to i8*
  %11 = bitcast %struct.ap_uint* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 4, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_int_base(%struct.ap_int_base* noalias nocapture, %struct.ap_int_base* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_int_base
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_int_base* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_4(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_int_base* %2 to i8*
  %6 = bitcast %struct.ap_int_base* %1 to i8*
  call void @fpga_fifo_pop_4(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_int_base, %struct.ap_int_base* %2
  %8 = bitcast %struct.ap_int_base* %2 to i8*
  %9 = bitcast %struct.ap_int_base* %0 to i8*
  call void @fpga_fifo_push_4(i8* %8, i8* %9)
  br label %empty, !llvm.loop !8

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ap_int_base* %1 to i8*
  %11 = bitcast %struct.ap_int_base* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 4, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ssdm_int(%struct.ssdm_int* noalias nocapture, %struct.ssdm_int* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ssdm_int
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ssdm_int* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_4(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ssdm_int* %2 to i8*
  %6 = bitcast %struct.ssdm_int* %1 to i8*
  call void @fpga_fifo_pop_4(i8* %5, i8* %6)
  %7 = load volatile %struct.ssdm_int, %struct.ssdm_int* %2
  %8 = bitcast %struct.ssdm_int* %2 to i8*
  %9 = bitcast %struct.ssdm_int* %0 to i8*
  call void @fpga_fifo_push_4(i8* %8, i8* %9)
  br label %empty, !llvm.loop !9

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ssdm_int* %1 to i8*
  %11 = bitcast %struct.ssdm_int* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 4, i1 false)
  ret void
}

declare i1 @fpga_fifo_exist_1(i8*) local_unnamed_addr

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_uint.20(%struct.ap_uint.20* noalias nocapture, %struct.ap_uint.20* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_uint.20
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_uint.20* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_uint.20* %2 to i8*
  %6 = bitcast %struct.ap_uint.20* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_uint.20, %struct.ap_uint.20* %2
  %8 = bitcast %struct.ap_uint.20* %2 to i8*
  %9 = bitcast %struct.ap_uint.20* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !10

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ap_uint.20* %1 to i8*
  %11 = bitcast %struct.ap_uint.20* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_int_base.21(%struct.ap_int_base.21* noalias nocapture, %struct.ap_int_base.21* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_int_base.21
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_int_base.21* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_int_base.21* %2 to i8*
  %6 = bitcast %struct.ap_int_base.21* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_int_base.21, %struct.ap_int_base.21* %2
  %8 = bitcast %struct.ap_int_base.21* %2 to i8*
  %9 = bitcast %struct.ap_int_base.21* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !11

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ap_int_base.21* %1 to i8*
  %11 = bitcast %struct.ap_int_base.21* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ssdm_int.22(%struct.ssdm_int.22* noalias nocapture, %struct.ssdm_int.22* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ssdm_int.22
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ssdm_int.22* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ssdm_int.22* %2 to i8*
  %6 = bitcast %struct.ssdm_int.22* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ssdm_int.22, %struct.ssdm_int.22* %2
  %8 = bitcast %struct.ssdm_int.22* %2 to i8*
  %9 = bitcast %struct.ssdm_int.22* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !12

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ssdm_int.22* %1 to i8*
  %11 = bitcast %struct.ssdm_int.22* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_uint.23(%struct.ap_uint.23* noalias nocapture, %struct.ap_uint.23* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_uint.23
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_uint.23* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_uint.23* %2 to i8*
  %6 = bitcast %struct.ap_uint.23* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_uint.23, %struct.ap_uint.23* %2
  %8 = bitcast %struct.ap_uint.23* %2 to i8*
  %9 = bitcast %struct.ap_uint.23* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !13

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ap_uint.23* %1 to i8*
  %11 = bitcast %struct.ap_uint.23* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_int_base.24(%struct.ap_int_base.24* noalias nocapture, %struct.ap_int_base.24* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_int_base.24
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_int_base.24* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_int_base.24* %2 to i8*
  %6 = bitcast %struct.ap_int_base.24* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_int_base.24, %struct.ap_int_base.24* %2
  %8 = bitcast %struct.ap_int_base.24* %2 to i8*
  %9 = bitcast %struct.ap_int_base.24* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !14

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ap_int_base.24* %1 to i8*
  %11 = bitcast %struct.ap_int_base.24* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ssdm_int.25(%struct.ssdm_int.25* noalias nocapture, %struct.ssdm_int.25* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ssdm_int.25
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ssdm_int.25* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ssdm_int.25* %2 to i8*
  %6 = bitcast %struct.ssdm_int.25* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ssdm_int.25, %struct.ssdm_int.25* %2
  %8 = bitcast %struct.ssdm_int.25* %2 to i8*
  %9 = bitcast %struct.ssdm_int.25* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !15

ret:                                              ; preds = %empty
  %10 = bitcast %struct.ssdm_int.25* %1 to i8*
  %11 = bitcast %struct.ssdm_int.25* %0 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: noinline
define internal fastcc void @onebyonecpy_hls.p0struct.ap_uint.0(%struct.ap_uint.0* noalias align 512, %struct.ap_uint.0* noalias) unnamed_addr #2 {
entry:
  %2 = icmp eq %struct.ap_uint.0* %0, null
  %3 = icmp eq %struct.ap_uint.0* %1, null
  %4 = or i1 %2, %3
  br i1 %4, label %ret, label %copy

copy:                                             ; preds = %entry
  %5 = getelementptr %struct.ap_uint.0, %struct.ap_uint.0* %1, i32 0, i32 0, i32 0, i32 0
  %6 = call i1 @fpga_fifo_exist_1(i8* %5)
  br i1 %6, label %7, label %8

; <label>:7:                                      ; preds = %copy
  call fastcc void @streamcpy_hls.p0struct.ap_uint.0(%struct.ap_uint.0* nonnull align 512 %0, %struct.ap_uint.0* nonnull %1)
  br label %ret

; <label>:8:                                      ; preds = %copy
  %.0 = getelementptr %struct.ap_uint.0, %struct.ap_uint.0* %1, i32 0, i32 0
  %.01 = getelementptr %struct.ap_uint.0, %struct.ap_uint.0* %0, i32 0, i32 0
  %9 = call i1 @fpga_fifo_exist_1(i8* %5)
  br i1 %9, label %10, label %11

; <label>:10:                                     ; preds = %8
  call fastcc void @streamcpy_hls.p0struct.ap_int_base.1(%struct.ap_int_base.1* align 512 %.01, %struct.ap_int_base.1* %.0)
  br label %ret

; <label>:11:                                     ; preds = %8
  %.0.02 = getelementptr %struct.ap_uint.0, %struct.ap_uint.0* %1, i32 0, i32 0, i32 0
  %.01.03 = getelementptr %struct.ap_uint.0, %struct.ap_uint.0* %0, i32 0, i32 0, i32 0
  %12 = call i1 @fpga_fifo_exist_1(i8* %5)
  br i1 %12, label %13, label %14

; <label>:13:                                     ; preds = %11
  call fastcc void @streamcpy_hls.p0struct.ssdm_int.2(%struct.ssdm_int.2* align 512 %.01.03, %struct.ssdm_int.2* %.0.02)
  br label %ret

; <label>:14:                                     ; preds = %11
  %.01.0.05 = getelementptr %struct.ap_uint.0, %struct.ap_uint.0* %0, i32 0, i32 0, i32 0, i32 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %.01.0.05, i8* align 1 %5, i64 1, i1 false)
  br label %ret

ret:                                              ; preds = %14, %13, %10, %7, %entry
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_uint.0(%struct.ap_uint.0* noalias nocapture align 512, %struct.ap_uint.0* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_uint.0
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_uint.0* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_uint.0* %2 to i8*
  %6 = bitcast %struct.ap_uint.0* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_uint.0, %struct.ap_uint.0* %2
  %8 = bitcast %struct.ap_uint.0* %2 to i8*
  %9 = bitcast %struct.ap_uint.0* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !16

ret:                                              ; preds = %empty
  %10 = getelementptr inbounds %struct.ap_uint.0, %struct.ap_uint.0* %1, i32 0, i32 0, i32 0, i32 0
  %11 = getelementptr inbounds %struct.ap_uint.0, %struct.ap_uint.0* %0, i32 0, i32 0, i32 0, i32 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ap_int_base.1(%struct.ap_int_base.1* noalias nocapture align 512, %struct.ap_int_base.1* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ap_int_base.1
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ap_int_base.1* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ap_int_base.1* %2 to i8*
  %6 = bitcast %struct.ap_int_base.1* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ap_int_base.1, %struct.ap_int_base.1* %2
  %8 = bitcast %struct.ap_int_base.1* %2 to i8*
  %9 = bitcast %struct.ap_int_base.1* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !17

ret:                                              ; preds = %empty
  %10 = getelementptr inbounds %struct.ap_int_base.1, %struct.ap_int_base.1* %1, i32 0, i32 0, i32 0
  %11 = getelementptr inbounds %struct.ap_int_base.1, %struct.ap_int_base.1* %0, i32 0, i32 0, i32 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: argmemonly noinline
define internal fastcc void @streamcpy_hls.p0struct.ssdm_int.2(%struct.ssdm_int.2* noalias nocapture align 512, %struct.ssdm_int.2* noalias nocapture) unnamed_addr #3 {
entry:
  %2 = alloca %struct.ssdm_int.2
  br label %empty

empty:                                            ; preds = %push, %entry
  %3 = bitcast %struct.ssdm_int.2* %1 to i8*
  %4 = call i1 @fpga_fifo_not_empty_1(i8* %3)
  br i1 %4, label %push, label %ret

push:                                             ; preds = %empty
  %5 = bitcast %struct.ssdm_int.2* %2 to i8*
  %6 = bitcast %struct.ssdm_int.2* %1 to i8*
  call void @fpga_fifo_pop_1(i8* %5, i8* %6)
  %7 = load volatile %struct.ssdm_int.2, %struct.ssdm_int.2* %2
  %8 = bitcast %struct.ssdm_int.2* %2 to i8*
  %9 = bitcast %struct.ssdm_int.2* %0 to i8*
  call void @fpga_fifo_push_1(i8* %8, i8* %9)
  br label %empty, !llvm.loop !18

ret:                                              ; preds = %empty
  %10 = getelementptr inbounds %struct.ssdm_int.2, %struct.ssdm_int.2* %1, i32 0, i32 0
  %11 = getelementptr inbounds %struct.ssdm_int.2, %struct.ssdm_int.2* %0, i32 0, i32 0
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* align 1 %11, i8* align 1 %10, i64 1, i1 false)
  ret void
}

; Function Attrs: noinline
define internal fastcc void @copy_out([16 x %"class.hls::stream"]*, [16 x %"class.hls::stream"]* noalias align 512, [16 x %"class.hls::stream"]*, [16 x %"class.hls::stream"]* noalias align 512, %struct.ap_uint.0*, %struct.ap_uint.0* noalias align 512, %struct.ap_uint.0*, %struct.ap_uint.0* noalias align 512) unnamed_addr #5 {
entry:
  call fastcc void @"onebyonecpy_hls.p0a16class.hls::stream"([16 x %"class.hls::stream"]* %0, [16 x %"class.hls::stream"]* align 512 %1)
  call fastcc void @"onebyonecpy_hls.p0a16class.hls::stream"([16 x %"class.hls::stream"]* %2, [16 x %"class.hls::stream"]* align 512 %3)
  call fastcc void @onebyonecpy_hls.p0struct.ap_uint.0(%struct.ap_uint.0* %4, %struct.ap_uint.0* align 512 %5)
  call fastcc void @onebyonecpy_hls.p0struct.ap_uint.0(%struct.ap_uint.0* %6, %struct.ap_uint.0* align 512 %7)
  ret void
}

declare void @apatb_edge_canny_detector_hw(%"class.hls::stream"*, %"class.hls::stream"*, %struct.ap_uint.0*, %struct.ap_uint.0*)

define void @edge_canny_detector_hw_stub_wrapper(%"class.hls::stream"*, %"class.hls::stream"*, %struct.ap_uint.0*, %struct.ap_uint.0*) #6 {
entry:
  %4 = bitcast %"class.hls::stream"* %0 to [16 x %"class.hls::stream"]*
  %5 = bitcast %"class.hls::stream"* %1 to [16 x %"class.hls::stream"]*
  call void @copy_out([16 x %"class.hls::stream"]* null, [16 x %"class.hls::stream"]* %4, [16 x %"class.hls::stream"]* null, [16 x %"class.hls::stream"]* %5, %struct.ap_uint.0* null, %struct.ap_uint.0* %2, %struct.ap_uint.0* null, %struct.ap_uint.0* %3)
  %6 = bitcast [16 x %"class.hls::stream"]* %4 to %"class.hls::stream"*
  %7 = bitcast [16 x %"class.hls::stream"]* %5 to %"class.hls::stream"*
  call void @edge_canny_detector_hw_stub(%"class.hls::stream"* %6, %"class.hls::stream"* %7, %struct.ap_uint.0* %2, %struct.ap_uint.0* %3)
  call void @copy_in([16 x %"class.hls::stream"]* null, [16 x %"class.hls::stream"]* %4, [16 x %"class.hls::stream"]* null, [16 x %"class.hls::stream"]* %5, %struct.ap_uint.0* null, %struct.ap_uint.0* %2, %struct.ap_uint.0* null, %struct.ap_uint.0* %3)
  ret void
}

declare void @edge_canny_detector_hw_stub(%"class.hls::stream"*, %"class.hls::stream"*, %struct.ap_uint.0*, %struct.ap_uint.0*)

declare i1 @fpga_fifo_not_empty_12(i8*)

declare i1 @fpga_fifo_not_empty_4(i8*)

declare i1 @fpga_fifo_not_empty_1(i8*)

declare void @fpga_fifo_pop_4(i8*, i8*)

declare void @fpga_fifo_pop_1(i8*, i8*)

declare void @fpga_fifo_pop_12(i8*, i8*)

declare void @fpga_fifo_push_4(i8*, i8*)

declare void @fpga_fifo_push_1(i8*, i8*)

declare void @fpga_fifo_push_12(i8*, i8*)

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { noinline "fpga.wrapper.func"="copyin" }
attributes #2 = { noinline "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline "fpga.wrapper.func"="streamcpy_hls" }
attributes #4 = { argmemonly nounwind }
attributes #5 = { noinline "fpga.wrapper.func"="copyout" }
attributes #6 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}
!llvm.module.flags = !{!1, !2, !3}
!blackbox_cfg = !{!4}

!0 = !{!"clang version 7.0.0 "}
!1 = !{i32 2, !"Dwarf Version", i32 4}
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 4}
!4 = !{}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.rotate.disable"}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}
!9 = distinct !{!9, !6}
!10 = distinct !{!10, !6}
!11 = distinct !{!11, !6}
!12 = distinct !{!12, !6}
!13 = distinct !{!13, !6}
!14 = distinct !{!14, !6}
!15 = distinct !{!15, !6}
!16 = distinct !{!16, !6}
!17 = distinct !{!17, !6}
!18 = distinct !{!18, !6}
