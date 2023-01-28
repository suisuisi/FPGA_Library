
    wire reset;
    wire clock;
    assign reset = ap_rst_n;
    assign clock = ap_clk;
    wire [1:0] proc_0_data_FIFO_blk;
    wire [1:0] proc_0_data_PIPO_blk;
    wire [1:0] proc_0_start_FIFO_blk;
    wire [1:0] proc_0_TLF_FIFO_blk;
    wire [1:0] proc_0_input_sync_blk;
    wire [1:0] proc_0_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_0;
    reg [1:0] proc_dep_vld_vec_0_reg;
    wire [1:0] in_chan_dep_vld_vec_0;
    wire [19:0] in_chan_dep_data_vec_0;
    wire [1:0] token_in_vec_0;
    wire [1:0] out_chan_dep_vld_vec_0;
    wire [9:0] out_chan_dep_data_0;
    wire [1:0] token_out_vec_0;
    wire dl_detect_out_0;
    wire dep_chan_vld_1_0;
    wire [9:0] dep_chan_data_1_0;
    wire token_1_0;
    wire dep_chan_vld_7_0;
    wire [9:0] dep_chan_data_7_0;
    wire token_7_0;
    wire [1:0] proc_1_data_FIFO_blk;
    wire [1:0] proc_1_data_PIPO_blk;
    wire [1:0] proc_1_start_FIFO_blk;
    wire [1:0] proc_1_TLF_FIFO_blk;
    wire [1:0] proc_1_input_sync_blk;
    wire [1:0] proc_1_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_1;
    reg [1:0] proc_dep_vld_vec_1_reg;
    wire [1:0] in_chan_dep_vld_vec_1;
    wire [19:0] in_chan_dep_data_vec_1;
    wire [1:0] token_in_vec_1;
    wire [1:0] out_chan_dep_vld_vec_1;
    wire [9:0] out_chan_dep_data_1;
    wire [1:0] token_out_vec_1;
    wire dl_detect_out_1;
    wire dep_chan_vld_0_1;
    wire [9:0] dep_chan_data_0_1;
    wire token_0_1;
    wire dep_chan_vld_2_1;
    wire [9:0] dep_chan_data_2_1;
    wire token_2_1;
    wire [1:0] proc_2_data_FIFO_blk;
    wire [1:0] proc_2_data_PIPO_blk;
    wire [1:0] proc_2_start_FIFO_blk;
    wire [1:0] proc_2_TLF_FIFO_blk;
    wire [1:0] proc_2_input_sync_blk;
    wire [1:0] proc_2_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_2;
    reg [1:0] proc_dep_vld_vec_2_reg;
    wire [1:0] in_chan_dep_vld_vec_2;
    wire [19:0] in_chan_dep_data_vec_2;
    wire [1:0] token_in_vec_2;
    wire [1:0] out_chan_dep_vld_vec_2;
    wire [9:0] out_chan_dep_data_2;
    wire [1:0] token_out_vec_2;
    wire dl_detect_out_2;
    wire dep_chan_vld_1_2;
    wire [9:0] dep_chan_data_1_2;
    wire token_1_2;
    wire dep_chan_vld_3_2;
    wire [9:0] dep_chan_data_3_2;
    wire token_3_2;
    wire [1:0] proc_3_data_FIFO_blk;
    wire [1:0] proc_3_data_PIPO_blk;
    wire [1:0] proc_3_start_FIFO_blk;
    wire [1:0] proc_3_TLF_FIFO_blk;
    wire [1:0] proc_3_input_sync_blk;
    wire [1:0] proc_3_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_3;
    reg [1:0] proc_dep_vld_vec_3_reg;
    wire [1:0] in_chan_dep_vld_vec_3;
    wire [19:0] in_chan_dep_data_vec_3;
    wire [1:0] token_in_vec_3;
    wire [1:0] out_chan_dep_vld_vec_3;
    wire [9:0] out_chan_dep_data_3;
    wire [1:0] token_out_vec_3;
    wire dl_detect_out_3;
    wire dep_chan_vld_2_3;
    wire [9:0] dep_chan_data_2_3;
    wire token_2_3;
    wire dep_chan_vld_4_3;
    wire [9:0] dep_chan_data_4_3;
    wire token_4_3;
    wire [2:0] proc_4_data_FIFO_blk;
    wire [2:0] proc_4_data_PIPO_blk;
    wire [2:0] proc_4_start_FIFO_blk;
    wire [2:0] proc_4_TLF_FIFO_blk;
    wire [2:0] proc_4_input_sync_blk;
    wire [2:0] proc_4_output_sync_blk;
    wire [2:0] proc_dep_vld_vec_4;
    reg [2:0] proc_dep_vld_vec_4_reg;
    wire [2:0] in_chan_dep_vld_vec_4;
    wire [29:0] in_chan_dep_data_vec_4;
    wire [2:0] token_in_vec_4;
    wire [2:0] out_chan_dep_vld_vec_4;
    wire [9:0] out_chan_dep_data_4;
    wire [2:0] token_out_vec_4;
    wire dl_detect_out_4;
    wire dep_chan_vld_3_4;
    wire [9:0] dep_chan_data_3_4;
    wire token_3_4;
    wire dep_chan_vld_5_4;
    wire [9:0] dep_chan_data_5_4;
    wire token_5_4;
    wire dep_chan_vld_6_4;
    wire [9:0] dep_chan_data_6_4;
    wire token_6_4;
    wire [1:0] proc_5_data_FIFO_blk;
    wire [1:0] proc_5_data_PIPO_blk;
    wire [1:0] proc_5_start_FIFO_blk;
    wire [1:0] proc_5_TLF_FIFO_blk;
    wire [1:0] proc_5_input_sync_blk;
    wire [1:0] proc_5_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_5;
    reg [1:0] proc_dep_vld_vec_5_reg;
    wire [1:0] in_chan_dep_vld_vec_5;
    wire [19:0] in_chan_dep_data_vec_5;
    wire [1:0] token_in_vec_5;
    wire [1:0] out_chan_dep_vld_vec_5;
    wire [9:0] out_chan_dep_data_5;
    wire [1:0] token_out_vec_5;
    wire dl_detect_out_5;
    wire dep_chan_vld_4_5;
    wire [9:0] dep_chan_data_4_5;
    wire token_4_5;
    wire dep_chan_vld_7_5;
    wire [9:0] dep_chan_data_7_5;
    wire token_7_5;
    wire [1:0] proc_6_data_FIFO_blk;
    wire [1:0] proc_6_data_PIPO_blk;
    wire [1:0] proc_6_start_FIFO_blk;
    wire [1:0] proc_6_TLF_FIFO_blk;
    wire [1:0] proc_6_input_sync_blk;
    wire [1:0] proc_6_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_6;
    reg [1:0] proc_dep_vld_vec_6_reg;
    wire [1:0] in_chan_dep_vld_vec_6;
    wire [19:0] in_chan_dep_data_vec_6;
    wire [1:0] token_in_vec_6;
    wire [1:0] out_chan_dep_vld_vec_6;
    wire [9:0] out_chan_dep_data_6;
    wire [1:0] token_out_vec_6;
    wire dl_detect_out_6;
    wire dep_chan_vld_4_6;
    wire [9:0] dep_chan_data_4_6;
    wire token_4_6;
    wire dep_chan_vld_7_6;
    wire [9:0] dep_chan_data_7_6;
    wire token_7_6;
    wire [3:0] proc_7_data_FIFO_blk;
    wire [3:0] proc_7_data_PIPO_blk;
    wire [3:0] proc_7_start_FIFO_blk;
    wire [3:0] proc_7_TLF_FIFO_blk;
    wire [3:0] proc_7_input_sync_blk;
    wire [3:0] proc_7_output_sync_blk;
    wire [3:0] proc_dep_vld_vec_7;
    reg [3:0] proc_dep_vld_vec_7_reg;
    wire [3:0] in_chan_dep_vld_vec_7;
    wire [39:0] in_chan_dep_data_vec_7;
    wire [3:0] token_in_vec_7;
    wire [3:0] out_chan_dep_vld_vec_7;
    wire [9:0] out_chan_dep_data_7;
    wire [3:0] token_out_vec_7;
    wire dl_detect_out_7;
    wire dep_chan_vld_0_7;
    wire [9:0] dep_chan_data_0_7;
    wire token_0_7;
    wire dep_chan_vld_5_7;
    wire [9:0] dep_chan_data_5_7;
    wire token_5_7;
    wire dep_chan_vld_6_7;
    wire [9:0] dep_chan_data_6_7;
    wire token_6_7;
    wire dep_chan_vld_8_7;
    wire [9:0] dep_chan_data_8_7;
    wire token_8_7;
    wire [1:0] proc_8_data_FIFO_blk;
    wire [1:0] proc_8_data_PIPO_blk;
    wire [1:0] proc_8_start_FIFO_blk;
    wire [1:0] proc_8_TLF_FIFO_blk;
    wire [1:0] proc_8_input_sync_blk;
    wire [1:0] proc_8_output_sync_blk;
    wire [1:0] proc_dep_vld_vec_8;
    reg [1:0] proc_dep_vld_vec_8_reg;
    wire [1:0] in_chan_dep_vld_vec_8;
    wire [19:0] in_chan_dep_data_vec_8;
    wire [1:0] token_in_vec_8;
    wire [1:0] out_chan_dep_vld_vec_8;
    wire [9:0] out_chan_dep_data_8;
    wire [1:0] token_out_vec_8;
    wire dl_detect_out_8;
    wire dep_chan_vld_7_8;
    wire [9:0] dep_chan_data_7_8;
    wire token_7_8;
    wire dep_chan_vld_9_8;
    wire [9:0] dep_chan_data_9_8;
    wire token_9_8;
    wire [0:0] proc_9_data_FIFO_blk;
    wire [0:0] proc_9_data_PIPO_blk;
    wire [0:0] proc_9_start_FIFO_blk;
    wire [0:0] proc_9_TLF_FIFO_blk;
    wire [0:0] proc_9_input_sync_blk;
    wire [0:0] proc_9_output_sync_blk;
    wire [0:0] proc_dep_vld_vec_9;
    reg [0:0] proc_dep_vld_vec_9_reg;
    wire [0:0] in_chan_dep_vld_vec_9;
    wire [9:0] in_chan_dep_data_vec_9;
    wire [0:0] token_in_vec_9;
    wire [0:0] out_chan_dep_vld_vec_9;
    wire [9:0] out_chan_dep_data_9;
    wire [0:0] token_out_vec_9;
    wire dl_detect_out_9;
    wire dep_chan_vld_8_9;
    wire [9:0] dep_chan_data_8_9;
    wire token_8_9;
    wire [9:0] dl_in_vec;
    wire dl_detect_out;
    wire token_clear;
    reg [9:0] origin;

reg [15:0] trans_in_cnt_0;// for process AXIvideo2xfMat_24_9_720_1280_1_16_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_in_cnt_0 <= 16'h0;
    end
    else if (AXIvideo2xfMat_24_9_720_1280_1_16_U0.start_write == 1'b1) begin
        trans_in_cnt_0 <= trans_in_cnt_0 + 16'h1;
    end
    else begin
        trans_in_cnt_0 <= trans_in_cnt_0;
    end
end

reg [15:0] trans_out_cnt_0;// for process AXIvideo2xfMat_24_9_720_1280_1_16_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_out_cnt_0 <= 16'h0;
    end
    else if (AXIvideo2xfMat_24_9_720_1280_1_16_U0.ap_done == 1'b1 && AXIvideo2xfMat_24_9_720_1280_1_16_U0.ap_continue == 1'b1) begin
        trans_out_cnt_0 <= trans_out_cnt_0 + 16'h1;
    end
    else begin
        trans_out_cnt_0 <= trans_out_cnt_0;
    end
end

reg [15:0] trans_in_cnt_1;// for process xfrgb2gray_720_1280_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_in_cnt_1 <= 16'h0;
    end
    else if (xfrgb2gray_720_1280_U0.start_write == 1'b1) begin
        trans_in_cnt_1 <= trans_in_cnt_1 + 16'h1;
    end
    else begin
        trans_in_cnt_1 <= trans_in_cnt_1;
    end
end

reg [15:0] trans_out_cnt_1;// for process xfrgb2gray_720_1280_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_out_cnt_1 <= 16'h0;
    end
    else if (xfrgb2gray_720_1280_U0.ap_done == 1'b1 && xfrgb2gray_720_1280_U0.ap_continue == 1'b1) begin
        trans_out_cnt_1 <= trans_out_cnt_1 + 16'h1;
    end
    else begin
        trans_out_cnt_1 <= trans_out_cnt_1;
    end
end

reg [15:0] trans_in_cnt_2;// for process xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_in_cnt_2 <= 16'h0;
    end
    else if (xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.start_write == 1'b1) begin
        trans_in_cnt_2 <= trans_in_cnt_2 + 16'h1;
    end
    else begin
        trans_in_cnt_2 <= trans_in_cnt_2;
    end
end

reg [15:0] trans_out_cnt_2;// for process xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_out_cnt_2 <= 16'h0;
    end
    else if (xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.ap_done == 1'b1 && xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.ap_continue == 1'b1) begin
        trans_out_cnt_2 <= trans_out_cnt_2 + 16'h1;
    end
    else begin
        trans_out_cnt_2 <= trans_out_cnt_2;
    end
end

reg [15:0] trans_in_cnt_3;// for process xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_in_cnt_3 <= 16'h0;
    end
    else if (xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.start_write == 1'b1) begin
        trans_in_cnt_3 <= trans_in_cnt_3 + 16'h1;
    end
    else begin
        trans_in_cnt_3 <= trans_in_cnt_3;
    end
end

reg [15:0] trans_out_cnt_3;// for process xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_out_cnt_3 <= 16'h0;
    end
    else if (xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.ap_done == 1'b1 && xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.ap_continue == 1'b1) begin
        trans_out_cnt_3 <= trans_out_cnt_3 + 16'h1;
    end
    else begin
        trans_out_cnt_3 <= trans_out_cnt_3;
    end
end

reg [15:0] trans_in_cnt_4;// for process duplicate_720_1280_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_in_cnt_4 <= 16'h0;
    end
    else if (duplicate_720_1280_U0.start_write == 1'b1) begin
        trans_in_cnt_4 <= trans_in_cnt_4 + 16'h1;
    end
    else begin
        trans_in_cnt_4 <= trans_in_cnt_4;
    end
end

reg [15:0] trans_out_cnt_4;// for process duplicate_720_1280_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_out_cnt_4 <= 16'h0;
    end
    else if (duplicate_720_1280_U0.ap_done == 1'b1 && duplicate_720_1280_U0.ap_continue == 1'b1) begin
        trans_out_cnt_4 <= trans_out_cnt_4 + 16'h1;
    end
    else begin
        trans_out_cnt_4 <= trans_out_cnt_4;
    end
end

reg [15:0] trans_in_cnt_5;// for process xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_in_cnt_5 <= 16'h0;
    end
    else if (xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.start_write == 1'b1) begin
        trans_in_cnt_5 <= trans_in_cnt_5 + 16'h1;
    end
    else begin
        trans_in_cnt_5 <= trans_in_cnt_5;
    end
end

reg [15:0] trans_out_cnt_5;// for process xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_out_cnt_5 <= 16'h0;
    end
    else if (xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.ap_done == 1'b1 && xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.ap_continue == 1'b1) begin
        trans_out_cnt_5 <= trans_out_cnt_5 + 16'h1;
    end
    else begin
        trans_out_cnt_5 <= trans_out_cnt_5;
    end
end

reg [15:0] trans_in_cnt_6;// for process xfgray2rgb_720_1280_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_in_cnt_6 <= 16'h0;
    end
    else if (xfgray2rgb_720_1280_U0.start_write == 1'b1) begin
        trans_in_cnt_6 <= trans_in_cnt_6 + 16'h1;
    end
    else begin
        trans_in_cnt_6 <= trans_in_cnt_6;
    end
end

reg [15:0] trans_out_cnt_6;// for process xfgray2rgb_720_1280_U0
always @(negedge reset or posedge clock) begin
    if (~reset) begin
         trans_out_cnt_6 <= 16'h0;
    end
    else if (xfgray2rgb_720_1280_U0.ap_done == 1'b1 && xfgray2rgb_720_1280_U0.ap_continue == 1'b1) begin
        trans_out_cnt_6 <= trans_out_cnt_6 + 16'h1;
    end
    else begin
        trans_out_cnt_6 <= trans_out_cnt_6;
    end
end

    // Process: AXIvideo2xfMat_24_9_720_1280_1_16_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 0, 2, 2) edge_canny_detector_hls_deadlock_detect_unit_0 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_0),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_0),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_0),
        .token_in_vec(token_in_vec_0),
        .dl_detect_in(dl_detect_out),
        .origin(origin[0]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_0),
        .out_chan_dep_data(out_chan_dep_data_0),
        .token_out_vec(token_out_vec_0),
        .dl_detect_out(dl_in_vec[0]));

    assign proc_0_data_FIFO_blk[0] = 1'b0 | (~AXIvideo2xfMat_24_9_720_1280_1_16_U0.rgb_img_src_4206_blk_n);
    assign proc_0_data_PIPO_blk[0] = 1'b0;
    assign proc_0_start_FIFO_blk[0] = 1'b0 | (~start_for_xfrgb2gray_720_1280_U0_U.if_full_n & AXIvideo2xfMat_24_9_720_1280_1_16_U0.ap_start & ~AXIvideo2xfMat_24_9_720_1280_1_16_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~start_for_xfrgb2gray_720_1280_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[0] = 1'b0;
    assign proc_0_input_sync_blk[0] = 1'b0;
    assign proc_0_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_0[0] = dl_detect_out ? proc_dep_vld_vec_0_reg[0] : (proc_0_data_FIFO_blk[0] | proc_0_data_PIPO_blk[0] | proc_0_start_FIFO_blk[0] | proc_0_TLF_FIFO_blk[0] | proc_0_input_sync_blk[0] | proc_0_output_sync_blk[0]);
    assign proc_0_data_FIFO_blk[1] = 1'b0 | (~AXIvideo2xfMat_24_9_720_1280_1_16_U0.lowthreshold_out_blk_n) | (~AXIvideo2xfMat_24_9_720_1280_1_16_U0.highthreshold_out_blk_n);
    assign proc_0_data_PIPO_blk[1] = 1'b0;
    assign proc_0_start_FIFO_blk[1] = 1'b0 | (~start_for_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0_U.if_full_n & AXIvideo2xfMat_24_9_720_1280_1_16_U0.ap_start & ~AXIvideo2xfMat_24_9_720_1280_1_16_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~start_for_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0_U.if_read);
    assign proc_0_TLF_FIFO_blk[1] = 1'b0;
    assign proc_0_input_sync_blk[1] = 1'b0;
    assign proc_0_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_0[1] = dl_detect_out ? proc_dep_vld_vec_0_reg[1] : (proc_0_data_FIFO_blk[1] | proc_0_data_PIPO_blk[1] | proc_0_start_FIFO_blk[1] | proc_0_TLF_FIFO_blk[1] | proc_0_input_sync_blk[1] | proc_0_output_sync_blk[1]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_0_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_0_reg <= proc_dep_vld_vec_0;
        end
    end
    assign in_chan_dep_vld_vec_0[0] = dep_chan_vld_1_0;
    assign in_chan_dep_data_vec_0[9 : 0] = dep_chan_data_1_0;
    assign token_in_vec_0[0] = token_1_0;
    assign in_chan_dep_vld_vec_0[1] = dep_chan_vld_7_0;
    assign in_chan_dep_data_vec_0[19 : 10] = dep_chan_data_7_0;
    assign token_in_vec_0[1] = token_7_0;
    assign dep_chan_vld_0_1 = out_chan_dep_vld_vec_0[0];
    assign dep_chan_data_0_1 = out_chan_dep_data_0;
    assign token_0_1 = token_out_vec_0[0];
    assign dep_chan_vld_0_7 = out_chan_dep_vld_vec_0[1];
    assign dep_chan_data_0_7 = out_chan_dep_data_0;
    assign token_0_7 = token_out_vec_0[1];

    // Process: xfrgb2gray_720_1280_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 1, 2, 2) edge_canny_detector_hls_deadlock_detect_unit_1 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_1),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_1),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_1),
        .token_in_vec(token_in_vec_1),
        .dl_detect_in(dl_detect_out),
        .origin(origin[1]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_1),
        .out_chan_dep_data(out_chan_dep_data_1),
        .token_out_vec(token_out_vec_1),
        .dl_detect_out(dl_in_vec[1]));

    assign proc_1_data_FIFO_blk[0] = 1'b0 | (~xfrgb2gray_720_1280_U0.rgb_img_src_4206_blk_n);
    assign proc_1_data_PIPO_blk[0] = 1'b0;
    assign proc_1_start_FIFO_blk[0] = 1'b0 | (~start_for_xfrgb2gray_720_1280_U0_U.if_empty_n & xfrgb2gray_720_1280_U0.ap_idle & ~start_for_xfrgb2gray_720_1280_U0_U.if_write);
    assign proc_1_TLF_FIFO_blk[0] = 1'b0;
    assign proc_1_input_sync_blk[0] = 1'b0;
    assign proc_1_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_1[0] = dl_detect_out ? proc_dep_vld_vec_1_reg[0] : (proc_1_data_FIFO_blk[0] | proc_1_data_PIPO_blk[0] | proc_1_start_FIFO_blk[0] | proc_1_TLF_FIFO_blk[0] | proc_1_input_sync_blk[0] | proc_1_output_sync_blk[0]);
    assign proc_1_data_FIFO_blk[1] = 1'b0 | (~xfrgb2gray_720_1280_U0.gray_img_src_4207_blk_n);
    assign proc_1_data_PIPO_blk[1] = 1'b0;
    assign proc_1_start_FIFO_blk[1] = 1'b0 | (~start_for_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0_U.if_full_n & xfrgb2gray_720_1280_U0.ap_start & ~xfrgb2gray_720_1280_U0.real_start & (trans_in_cnt_1 == trans_out_cnt_1) & ~start_for_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0_U.if_read);
    assign proc_1_TLF_FIFO_blk[1] = 1'b0;
    assign proc_1_input_sync_blk[1] = 1'b0;
    assign proc_1_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_1[1] = dl_detect_out ? proc_dep_vld_vec_1_reg[1] : (proc_1_data_FIFO_blk[1] | proc_1_data_PIPO_blk[1] | proc_1_start_FIFO_blk[1] | proc_1_TLF_FIFO_blk[1] | proc_1_input_sync_blk[1] | proc_1_output_sync_blk[1]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_1_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_1_reg <= proc_dep_vld_vec_1;
        end
    end
    assign in_chan_dep_vld_vec_1[0] = dep_chan_vld_0_1;
    assign in_chan_dep_data_vec_1[9 : 0] = dep_chan_data_0_1;
    assign token_in_vec_1[0] = token_0_1;
    assign in_chan_dep_vld_vec_1[1] = dep_chan_vld_2_1;
    assign in_chan_dep_data_vec_1[19 : 10] = dep_chan_data_2_1;
    assign token_in_vec_1[1] = token_2_1;
    assign dep_chan_vld_1_0 = out_chan_dep_vld_vec_1[0];
    assign dep_chan_data_1_0 = out_chan_dep_data_1;
    assign token_1_0 = token_out_vec_1[0];
    assign dep_chan_vld_1_2 = out_chan_dep_vld_vec_1[1];
    assign dep_chan_data_1_2 = out_chan_dep_data_1;
    assign token_1_2 = token_out_vec_1[1];

    // Process: xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 2, 2, 2) edge_canny_detector_hls_deadlock_detect_unit_2 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_2),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_2),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_2),
        .token_in_vec(token_in_vec_2),
        .dl_detect_in(dl_detect_out),
        .origin(origin[2]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_2),
        .out_chan_dep_data(out_chan_dep_data_2),
        .token_out_vec(token_out_vec_2),
        .dl_detect_out(dl_in_vec[2]));

    assign proc_2_data_FIFO_blk[0] = 1'b0 | (~xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.gray_img_src_4207_blk_n);
    assign proc_2_data_PIPO_blk[0] = 1'b0;
    assign proc_2_start_FIFO_blk[0] = 1'b0 | (~start_for_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0_U.if_empty_n & xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.ap_idle & ~start_for_xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0_U.if_write);
    assign proc_2_TLF_FIFO_blk[0] = 1'b0;
    assign proc_2_input_sync_blk[0] = 1'b0;
    assign proc_2_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_2[0] = dl_detect_out ? proc_dep_vld_vec_2_reg[0] : (proc_2_data_FIFO_blk[0] | proc_2_data_PIPO_blk[0] | proc_2_start_FIFO_blk[0] | proc_2_TLF_FIFO_blk[0] | proc_2_input_sync_blk[0] | proc_2_output_sync_blk[0]);
    assign proc_2_data_FIFO_blk[1] = 1'b0 | (~xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.gaussian_mat_4209_blk_n);
    assign proc_2_data_PIPO_blk[1] = 1'b0;
    assign proc_2_start_FIFO_blk[1] = 1'b0 | (~start_for_xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0_U.if_full_n & xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.ap_start & ~xFAverageGaussianMask3x3_0_0_720_1280_0_1_1_1280_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~start_for_xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0_U.if_read);
    assign proc_2_TLF_FIFO_blk[1] = 1'b0;
    assign proc_2_input_sync_blk[1] = 1'b0;
    assign proc_2_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_2[1] = dl_detect_out ? proc_dep_vld_vec_2_reg[1] : (proc_2_data_FIFO_blk[1] | proc_2_data_PIPO_blk[1] | proc_2_start_FIFO_blk[1] | proc_2_TLF_FIFO_blk[1] | proc_2_input_sync_blk[1] | proc_2_output_sync_blk[1]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_2_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_2_reg <= proc_dep_vld_vec_2;
        end
    end
    assign in_chan_dep_vld_vec_2[0] = dep_chan_vld_1_2;
    assign in_chan_dep_data_vec_2[9 : 0] = dep_chan_data_1_2;
    assign token_in_vec_2[0] = token_1_2;
    assign in_chan_dep_vld_vec_2[1] = dep_chan_vld_3_2;
    assign in_chan_dep_data_vec_2[19 : 10] = dep_chan_data_3_2;
    assign token_in_vec_2[1] = token_3_2;
    assign dep_chan_vld_2_1 = out_chan_dep_vld_vec_2[0];
    assign dep_chan_data_2_1 = out_chan_dep_data_2;
    assign token_2_1 = token_out_vec_2[0];
    assign dep_chan_vld_2_3 = out_chan_dep_vld_vec_2[1];
    assign dep_chan_data_2_3 = out_chan_dep_data_2;
    assign token_2_3 = token_out_vec_2[1];

    // Process: xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 3, 2, 2) edge_canny_detector_hls_deadlock_detect_unit_3 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_3),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_3),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_3),
        .token_in_vec(token_in_vec_3),
        .dl_detect_in(dl_detect_out),
        .origin(origin[3]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_3),
        .out_chan_dep_data(out_chan_dep_data_3),
        .token_out_vec(token_out_vec_3),
        .dl_detect_out(dl_in_vec[3]));

    assign proc_3_data_FIFO_blk[0] = 1'b0 | (~xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.gaussian_mat_4209_blk_n);
    assign proc_3_data_PIPO_blk[0] = 1'b0;
    assign proc_3_start_FIFO_blk[0] = 1'b0 | (~start_for_xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0_U.if_empty_n & xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.ap_idle & ~start_for_xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0_U.if_write);
    assign proc_3_TLF_FIFO_blk[0] = 1'b0;
    assign proc_3_input_sync_blk[0] = 1'b0;
    assign proc_3_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_3[0] = dl_detect_out ? proc_dep_vld_vec_3_reg[0] : (proc_3_data_FIFO_blk[0] | proc_3_data_PIPO_blk[0] | proc_3_start_FIFO_blk[0] | proc_3_TLF_FIFO_blk[0] | proc_3_input_sync_blk[0] | proc_3_output_sync_blk[0]);
    assign proc_3_data_FIFO_blk[1] = 1'b0 | (~xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.gradx_mat_4210_blk_n) | (~xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_720_1280_0_3_1_1_5_1281_3_9_false_s_fu_16.grady_mat_4213_blk_n);
    assign proc_3_data_PIPO_blk[1] = 1'b0;
    assign proc_3_start_FIFO_blk[1] = 1'b0 | (~start_for_duplicate_720_1280_U0_U.if_full_n & xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.ap_start & ~xFSobel_0_2_720_1280_0_3_1_1_5_3_false_U0.real_start & (trans_in_cnt_3 == trans_out_cnt_3) & ~start_for_duplicate_720_1280_U0_U.if_read);
    assign proc_3_TLF_FIFO_blk[1] = 1'b0;
    assign proc_3_input_sync_blk[1] = 1'b0;
    assign proc_3_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_3[1] = dl_detect_out ? proc_dep_vld_vec_3_reg[1] : (proc_3_data_FIFO_blk[1] | proc_3_data_PIPO_blk[1] | proc_3_start_FIFO_blk[1] | proc_3_TLF_FIFO_blk[1] | proc_3_input_sync_blk[1] | proc_3_output_sync_blk[1]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_3_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_3_reg <= proc_dep_vld_vec_3;
        end
    end
    assign in_chan_dep_vld_vec_3[0] = dep_chan_vld_2_3;
    assign in_chan_dep_data_vec_3[9 : 0] = dep_chan_data_2_3;
    assign token_in_vec_3[0] = token_2_3;
    assign in_chan_dep_vld_vec_3[1] = dep_chan_vld_4_3;
    assign in_chan_dep_data_vec_3[19 : 10] = dep_chan_data_4_3;
    assign token_in_vec_3[1] = token_4_3;
    assign dep_chan_vld_3_2 = out_chan_dep_vld_vec_3[0];
    assign dep_chan_data_3_2 = out_chan_dep_data_3;
    assign token_3_2 = token_out_vec_3[0];
    assign dep_chan_vld_3_4 = out_chan_dep_vld_vec_3[1];
    assign dep_chan_data_3_4 = out_chan_dep_data_3;
    assign token_3_4 = token_out_vec_3[1];

    // Process: duplicate_720_1280_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 4, 3, 3) edge_canny_detector_hls_deadlock_detect_unit_4 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_4),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_4),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_4),
        .token_in_vec(token_in_vec_4),
        .dl_detect_in(dl_detect_out),
        .origin(origin[4]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_4),
        .out_chan_dep_data(out_chan_dep_data_4),
        .token_out_vec(token_out_vec_4),
        .dl_detect_out(dl_in_vec[4]));

    assign proc_4_data_FIFO_blk[0] = 1'b0 | (~duplicate_720_1280_U0.gradx_mat_4210_blk_n) | (~duplicate_720_1280_U0.grady_mat_4213_blk_n);
    assign proc_4_data_PIPO_blk[0] = 1'b0;
    assign proc_4_start_FIFO_blk[0] = 1'b0 | (~start_for_duplicate_720_1280_U0_U.if_empty_n & duplicate_720_1280_U0.ap_idle & ~start_for_duplicate_720_1280_U0_U.if_write);
    assign proc_4_TLF_FIFO_blk[0] = 1'b0;
    assign proc_4_input_sync_blk[0] = 1'b0;
    assign proc_4_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_4[0] = dl_detect_out ? proc_dep_vld_vec_4_reg[0] : (proc_4_data_FIFO_blk[0] | proc_4_data_PIPO_blk[0] | proc_4_start_FIFO_blk[0] | proc_4_TLF_FIFO_blk[0] | proc_4_input_sync_blk[0] | proc_4_output_sync_blk[0]);
    assign proc_4_data_FIFO_blk[1] = 1'b0 | (~duplicate_720_1280_U0.gradx1_mat_4211_blk_n) | (~duplicate_720_1280_U0.grady1_mat_4214_blk_n);
    assign proc_4_data_PIPO_blk[1] = 1'b0;
    assign proc_4_start_FIFO_blk[1] = 1'b0 | (~start_for_xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0_U.if_full_n & duplicate_720_1280_U0.ap_start & ~duplicate_720_1280_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~start_for_xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0_U.if_read);
    assign proc_4_TLF_FIFO_blk[1] = 1'b0;
    assign proc_4_input_sync_blk[1] = 1'b0;
    assign proc_4_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_4[1] = dl_detect_out ? proc_dep_vld_vec_4_reg[1] : (proc_4_data_FIFO_blk[1] | proc_4_data_PIPO_blk[1] | proc_4_start_FIFO_blk[1] | proc_4_TLF_FIFO_blk[1] | proc_4_input_sync_blk[1] | proc_4_output_sync_blk[1]);
    assign proc_4_data_FIFO_blk[2] = 1'b0 | (~duplicate_720_1280_U0.gradx2_mat_4212_blk_n) | (~duplicate_720_1280_U0.grady2_mat_4215_blk_n);
    assign proc_4_data_PIPO_blk[2] = 1'b0;
    assign proc_4_start_FIFO_blk[2] = 1'b0 | (~start_for_xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0_U.if_full_n & duplicate_720_1280_U0.ap_start & ~duplicate_720_1280_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~start_for_xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0_U.if_read);
    assign proc_4_TLF_FIFO_blk[2] = 1'b0;
    assign proc_4_input_sync_blk[2] = 1'b0;
    assign proc_4_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_4[2] = dl_detect_out ? proc_dep_vld_vec_4_reg[2] : (proc_4_data_FIFO_blk[2] | proc_4_data_PIPO_blk[2] | proc_4_start_FIFO_blk[2] | proc_4_TLF_FIFO_blk[2] | proc_4_input_sync_blk[2] | proc_4_output_sync_blk[2]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_4_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_4_reg <= proc_dep_vld_vec_4;
        end
    end
    assign in_chan_dep_vld_vec_4[0] = dep_chan_vld_3_4;
    assign in_chan_dep_data_vec_4[9 : 0] = dep_chan_data_3_4;
    assign token_in_vec_4[0] = token_3_4;
    assign in_chan_dep_vld_vec_4[1] = dep_chan_vld_5_4;
    assign in_chan_dep_data_vec_4[19 : 10] = dep_chan_data_5_4;
    assign token_in_vec_4[1] = token_5_4;
    assign in_chan_dep_vld_vec_4[2] = dep_chan_vld_6_4;
    assign in_chan_dep_data_vec_4[29 : 20] = dep_chan_data_6_4;
    assign token_in_vec_4[2] = token_6_4;
    assign dep_chan_vld_4_3 = out_chan_dep_vld_vec_4[0];
    assign dep_chan_data_4_3 = out_chan_dep_data_4;
    assign token_4_3 = token_out_vec_4[0];
    assign dep_chan_vld_4_5 = out_chan_dep_vld_vec_4[1];
    assign dep_chan_data_4_5 = out_chan_dep_data_4;
    assign token_4_5 = token_out_vec_4[1];
    assign dep_chan_vld_4_6 = out_chan_dep_vld_vec_4[2];
    assign dep_chan_data_4_6 = out_chan_dep_data_4;
    assign token_4_6 = token_out_vec_4[2];

    // Process: xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 5, 2, 2) edge_canny_detector_hls_deadlock_detect_unit_5 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_5),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_5),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_5),
        .token_in_vec(token_in_vec_5),
        .dl_detect_in(dl_detect_out),
        .origin(origin[5]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_5),
        .out_chan_dep_data(out_chan_dep_data_5),
        .token_out_vec(token_out_vec_5),
        .dl_detect_out(dl_in_vec[5]));

    assign proc_5_data_FIFO_blk[0] = 1'b0 | (~xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0.gradx1_mat_4211_blk_n) | (~xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0.grady1_mat_4214_blk_n);
    assign proc_5_data_PIPO_blk[0] = 1'b0;
    assign proc_5_start_FIFO_blk[0] = 1'b0 | (~start_for_xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0_U.if_empty_n & xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0.ap_idle & ~start_for_xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0_U.if_write);
    assign proc_5_TLF_FIFO_blk[0] = 1'b0;
    assign proc_5_input_sync_blk[0] = 1'b0;
    assign proc_5_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_5[0] = dl_detect_out ? proc_dep_vld_vec_5_reg[0] : (proc_5_data_FIFO_blk[0] | proc_5_data_PIPO_blk[0] | proc_5_start_FIFO_blk[0] | proc_5_TLF_FIFO_blk[0] | proc_5_input_sync_blk[0] | proc_5_output_sync_blk[0]);
    assign proc_5_data_FIFO_blk[1] = 1'b0 | (~xFMagnitudeKernel_2_2_720_1280_3_3_1_5_5_1280_3840_U0.magnitude_mat_4216_blk_n);
    assign proc_5_data_PIPO_blk[1] = 1'b0;
    assign proc_5_start_FIFO_blk[1] = 1'b0;
    assign proc_5_TLF_FIFO_blk[1] = 1'b0;
    assign proc_5_input_sync_blk[1] = 1'b0;
    assign proc_5_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_5[1] = dl_detect_out ? proc_dep_vld_vec_5_reg[1] : (proc_5_data_FIFO_blk[1] | proc_5_data_PIPO_blk[1] | proc_5_start_FIFO_blk[1] | proc_5_TLF_FIFO_blk[1] | proc_5_input_sync_blk[1] | proc_5_output_sync_blk[1]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_5_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_5_reg <= proc_dep_vld_vec_5;
        end
    end
    assign in_chan_dep_vld_vec_5[0] = dep_chan_vld_4_5;
    assign in_chan_dep_data_vec_5[9 : 0] = dep_chan_data_4_5;
    assign token_in_vec_5[0] = token_4_5;
    assign in_chan_dep_vld_vec_5[1] = dep_chan_vld_7_5;
    assign in_chan_dep_data_vec_5[19 : 10] = dep_chan_data_7_5;
    assign token_in_vec_5[1] = token_7_5;
    assign dep_chan_vld_5_4 = out_chan_dep_vld_vec_5[0];
    assign dep_chan_data_5_4 = out_chan_dep_data_5;
    assign token_5_4 = token_out_vec_5[0];
    assign dep_chan_vld_5_7 = out_chan_dep_vld_vec_5[1];
    assign dep_chan_data_5_7 = out_chan_dep_data_5;
    assign token_5_7 = token_out_vec_5[1];

    // Process: xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 6, 2, 2) edge_canny_detector_hls_deadlock_detect_unit_6 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_6),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_6),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_6),
        .token_in_vec(token_in_vec_6),
        .dl_detect_in(dl_detect_out),
        .origin(origin[6]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_6),
        .out_chan_dep_data(out_chan_dep_data_6),
        .token_out_vec(token_out_vec_6),
        .dl_detect_out(dl_in_vec[6]));

    assign proc_6_data_FIFO_blk[0] = 1'b0 | (~xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0.gradx2_mat_4212_blk_n) | (~xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0.grady2_mat_4215_blk_n);
    assign proc_6_data_PIPO_blk[0] = 1'b0;
    assign proc_6_start_FIFO_blk[0] = 1'b0 | (~start_for_xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0_U.if_empty_n & xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0.ap_idle & ~start_for_xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0_U.if_write);
    assign proc_6_TLF_FIFO_blk[0] = 1'b0;
    assign proc_6_input_sync_blk[0] = 1'b0;
    assign proc_6_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_6[0] = dl_detect_out ? proc_dep_vld_vec_6_reg[0] : (proc_6_data_FIFO_blk[0] | proc_6_data_PIPO_blk[0] | proc_6_start_FIFO_blk[0] | proc_6_TLF_FIFO_blk[0] | proc_6_input_sync_blk[0] | proc_6_output_sync_blk[0]);
    assign proc_6_data_FIFO_blk[1] = 1'b0 | (~xFAngleKernel_2_0_720_1280_3_0_1_5_1_1280_3840_U0.phase_mat_4217_blk_n);
    assign proc_6_data_PIPO_blk[1] = 1'b0;
    assign proc_6_start_FIFO_blk[1] = 1'b0;
    assign proc_6_TLF_FIFO_blk[1] = 1'b0;
    assign proc_6_input_sync_blk[1] = 1'b0;
    assign proc_6_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_6[1] = dl_detect_out ? proc_dep_vld_vec_6_reg[1] : (proc_6_data_FIFO_blk[1] | proc_6_data_PIPO_blk[1] | proc_6_start_FIFO_blk[1] | proc_6_TLF_FIFO_blk[1] | proc_6_input_sync_blk[1] | proc_6_output_sync_blk[1]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_6_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_6_reg <= proc_dep_vld_vec_6;
        end
    end
    assign in_chan_dep_vld_vec_6[0] = dep_chan_vld_4_6;
    assign in_chan_dep_data_vec_6[9 : 0] = dep_chan_data_4_6;
    assign token_in_vec_6[0] = token_4_6;
    assign in_chan_dep_vld_vec_6[1] = dep_chan_vld_7_6;
    assign in_chan_dep_data_vec_6[19 : 10] = dep_chan_data_7_6;
    assign token_in_vec_6[1] = token_7_6;
    assign dep_chan_vld_6_4 = out_chan_dep_vld_vec_6[0];
    assign dep_chan_data_6_4 = out_chan_dep_data_6;
    assign token_6_4 = token_out_vec_6[0];
    assign dep_chan_vld_6_7 = out_chan_dep_vld_vec_6[1];
    assign dep_chan_data_6_7 = out_chan_dep_data_6;
    assign token_6_7 = token_out_vec_6[1];

    // Process: xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 7, 4, 4) edge_canny_detector_hls_deadlock_detect_unit_7 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_7),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_7),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_7),
        .token_in_vec(token_in_vec_7),
        .dl_detect_in(dl_detect_out),
        .origin(origin[7]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_7),
        .out_chan_dep_data(out_chan_dep_data_7),
        .token_out_vec(token_out_vec_7),
        .dl_detect_out(dl_in_vec[7]));

    assign proc_7_data_FIFO_blk[0] = 1'b0 | (~xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.magnitude_mat_data_blk_n);
    assign proc_7_data_PIPO_blk[0] = 1'b0;
    assign proc_7_start_FIFO_blk[0] = 1'b0;
    assign proc_7_TLF_FIFO_blk[0] = 1'b0;
    assign proc_7_input_sync_blk[0] = 1'b0;
    assign proc_7_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_7[0] = dl_detect_out ? proc_dep_vld_vec_7_reg[0] : (proc_7_data_FIFO_blk[0] | proc_7_data_PIPO_blk[0] | proc_7_start_FIFO_blk[0] | proc_7_TLF_FIFO_blk[0] | proc_7_input_sync_blk[0] | proc_7_output_sync_blk[0]);
    assign proc_7_data_FIFO_blk[1] = 1'b0 | (~xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.phase_mat_data_blk_n);
    assign proc_7_data_PIPO_blk[1] = 1'b0;
    assign proc_7_start_FIFO_blk[1] = 1'b0;
    assign proc_7_TLF_FIFO_blk[1] = 1'b0;
    assign proc_7_input_sync_blk[1] = 1'b0;
    assign proc_7_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_7[1] = dl_detect_out ? proc_dep_vld_vec_7_reg[1] : (proc_7_data_FIFO_blk[1] | proc_7_data_PIPO_blk[1] | proc_7_start_FIFO_blk[1] | proc_7_TLF_FIFO_blk[1] | proc_7_input_sync_blk[1] | proc_7_output_sync_blk[1]);
    assign proc_7_data_FIFO_blk[2] = 1'b0 | (~xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.nms_mat_data_blk_n);
    assign proc_7_data_PIPO_blk[2] = 1'b0;
    assign proc_7_start_FIFO_blk[2] = 1'b0 | (~start_for_xfgray2rgb_720_1280_U0_U.if_full_n & xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.ap_start & ~xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.real_start & (trans_in_cnt_5 == trans_out_cnt_5) & ~start_for_xfgray2rgb_720_1280_U0_U.if_read);
    assign proc_7_TLF_FIFO_blk[2] = 1'b0;
    assign proc_7_input_sync_blk[2] = 1'b0;
    assign proc_7_output_sync_blk[2] = 1'b0;
    assign proc_dep_vld_vec_7[2] = dl_detect_out ? proc_dep_vld_vec_7_reg[2] : (proc_7_data_FIFO_blk[2] | proc_7_data_PIPO_blk[2] | proc_7_start_FIFO_blk[2] | proc_7_TLF_FIFO_blk[2] | proc_7_input_sync_blk[2] | proc_7_output_sync_blk[2]);
    assign proc_7_data_FIFO_blk[3] = 1'b0 | (~xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.lowthreshold_blk_n) | (~xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.highthreshold_blk_n);
    assign proc_7_data_PIPO_blk[3] = 1'b0;
    assign proc_7_start_FIFO_blk[3] = 1'b0 | (~start_for_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0_U.if_empty_n & xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0.ap_idle & ~start_for_xFSuppression3x3_2_0_0_720_1280_3_0_0_1_5_1_1_1280_3840_3840_U0_U.if_write);
    assign proc_7_TLF_FIFO_blk[3] = 1'b0;
    assign proc_7_input_sync_blk[3] = 1'b0;
    assign proc_7_output_sync_blk[3] = 1'b0;
    assign proc_dep_vld_vec_7[3] = dl_detect_out ? proc_dep_vld_vec_7_reg[3] : (proc_7_data_FIFO_blk[3] | proc_7_data_PIPO_blk[3] | proc_7_start_FIFO_blk[3] | proc_7_TLF_FIFO_blk[3] | proc_7_input_sync_blk[3] | proc_7_output_sync_blk[3]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_7_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_7_reg <= proc_dep_vld_vec_7;
        end
    end
    assign in_chan_dep_vld_vec_7[0] = dep_chan_vld_0_7;
    assign in_chan_dep_data_vec_7[9 : 0] = dep_chan_data_0_7;
    assign token_in_vec_7[0] = token_0_7;
    assign in_chan_dep_vld_vec_7[1] = dep_chan_vld_5_7;
    assign in_chan_dep_data_vec_7[19 : 10] = dep_chan_data_5_7;
    assign token_in_vec_7[1] = token_5_7;
    assign in_chan_dep_vld_vec_7[2] = dep_chan_vld_6_7;
    assign in_chan_dep_data_vec_7[29 : 20] = dep_chan_data_6_7;
    assign token_in_vec_7[2] = token_6_7;
    assign in_chan_dep_vld_vec_7[3] = dep_chan_vld_8_7;
    assign in_chan_dep_data_vec_7[39 : 30] = dep_chan_data_8_7;
    assign token_in_vec_7[3] = token_8_7;
    assign dep_chan_vld_7_5 = out_chan_dep_vld_vec_7[0];
    assign dep_chan_data_7_5 = out_chan_dep_data_7;
    assign token_7_5 = token_out_vec_7[0];
    assign dep_chan_vld_7_6 = out_chan_dep_vld_vec_7[1];
    assign dep_chan_data_7_6 = out_chan_dep_data_7;
    assign token_7_6 = token_out_vec_7[1];
    assign dep_chan_vld_7_8 = out_chan_dep_vld_vec_7[2];
    assign dep_chan_data_7_8 = out_chan_dep_data_7;
    assign token_7_8 = token_out_vec_7[2];
    assign dep_chan_vld_7_0 = out_chan_dep_vld_vec_7[3];
    assign dep_chan_data_7_0 = out_chan_dep_data_7;
    assign token_7_0 = token_out_vec_7[3];

    // Process: xfgray2rgb_720_1280_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 8, 2, 2) edge_canny_detector_hls_deadlock_detect_unit_8 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_8),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_8),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_8),
        .token_in_vec(token_in_vec_8),
        .dl_detect_in(dl_detect_out),
        .origin(origin[8]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_8),
        .out_chan_dep_data(out_chan_dep_data_8),
        .token_out_vec(token_out_vec_8),
        .dl_detect_out(dl_in_vec[8]));

    assign proc_8_data_FIFO_blk[0] = 1'b0 | (~xfgray2rgb_720_1280_U0.nms_mat_4218_blk_n);
    assign proc_8_data_PIPO_blk[0] = 1'b0;
    assign proc_8_start_FIFO_blk[0] = 1'b0 | (~start_for_xfgray2rgb_720_1280_U0_U.if_empty_n & xfgray2rgb_720_1280_U0.ap_idle & ~start_for_xfgray2rgb_720_1280_U0_U.if_write);
    assign proc_8_TLF_FIFO_blk[0] = 1'b0;
    assign proc_8_input_sync_blk[0] = 1'b0;
    assign proc_8_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_8[0] = dl_detect_out ? proc_dep_vld_vec_8_reg[0] : (proc_8_data_FIFO_blk[0] | proc_8_data_PIPO_blk[0] | proc_8_start_FIFO_blk[0] | proc_8_TLF_FIFO_blk[0] | proc_8_input_sync_blk[0] | proc_8_output_sync_blk[0]);
    assign proc_8_data_FIFO_blk[1] = 1'b0 | (~xfgray2rgb_720_1280_U0.rgb_img_dst_4208_blk_n);
    assign proc_8_data_PIPO_blk[1] = 1'b0;
    assign proc_8_start_FIFO_blk[1] = 1'b0 | (~start_for_xfMat2AXIvideo_24_9_720_1280_1_U0_U.if_full_n & xfgray2rgb_720_1280_U0.ap_start & ~xfgray2rgb_720_1280_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~start_for_xfMat2AXIvideo_24_9_720_1280_1_U0_U.if_read);
    assign proc_8_TLF_FIFO_blk[1] = 1'b0;
    assign proc_8_input_sync_blk[1] = 1'b0;
    assign proc_8_output_sync_blk[1] = 1'b0;
    assign proc_dep_vld_vec_8[1] = dl_detect_out ? proc_dep_vld_vec_8_reg[1] : (proc_8_data_FIFO_blk[1] | proc_8_data_PIPO_blk[1] | proc_8_start_FIFO_blk[1] | proc_8_TLF_FIFO_blk[1] | proc_8_input_sync_blk[1] | proc_8_output_sync_blk[1]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_8_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_8_reg <= proc_dep_vld_vec_8;
        end
    end
    assign in_chan_dep_vld_vec_8[0] = dep_chan_vld_7_8;
    assign in_chan_dep_data_vec_8[9 : 0] = dep_chan_data_7_8;
    assign token_in_vec_8[0] = token_7_8;
    assign in_chan_dep_vld_vec_8[1] = dep_chan_vld_9_8;
    assign in_chan_dep_data_vec_8[19 : 10] = dep_chan_data_9_8;
    assign token_in_vec_8[1] = token_9_8;
    assign dep_chan_vld_8_7 = out_chan_dep_vld_vec_8[0];
    assign dep_chan_data_8_7 = out_chan_dep_data_8;
    assign token_8_7 = token_out_vec_8[0];
    assign dep_chan_vld_8_9 = out_chan_dep_vld_vec_8[1];
    assign dep_chan_data_8_9 = out_chan_dep_data_8;
    assign token_8_9 = token_out_vec_8[1];

    // Process: xfMat2AXIvideo_24_9_720_1280_1_U0
    edge_canny_detector_hls_deadlock_detect_unit #(10, 9, 1, 1) edge_canny_detector_hls_deadlock_detect_unit_9 (
        .reset(reset),
        .clock(clock),
        .proc_dep_vld_vec(proc_dep_vld_vec_9),
        .in_chan_dep_vld_vec(in_chan_dep_vld_vec_9),
        .in_chan_dep_data_vec(in_chan_dep_data_vec_9),
        .token_in_vec(token_in_vec_9),
        .dl_detect_in(dl_detect_out),
        .origin(origin[9]),
        .token_clear(token_clear),
        .out_chan_dep_vld_vec(out_chan_dep_vld_vec_9),
        .out_chan_dep_data(out_chan_dep_data_9),
        .token_out_vec(token_out_vec_9),
        .dl_detect_out(dl_in_vec[9]));

    assign proc_9_data_FIFO_blk[0] = 1'b0 | (~xfMat2AXIvideo_24_9_720_1280_1_U0.rgb_img_dst_4208_blk_n);
    assign proc_9_data_PIPO_blk[0] = 1'b0;
    assign proc_9_start_FIFO_blk[0] = 1'b0 | (~start_for_xfMat2AXIvideo_24_9_720_1280_1_U0_U.if_empty_n & xfMat2AXIvideo_24_9_720_1280_1_U0.ap_idle & ~start_for_xfMat2AXIvideo_24_9_720_1280_1_U0_U.if_write);
    assign proc_9_TLF_FIFO_blk[0] = 1'b0;
    assign proc_9_input_sync_blk[0] = 1'b0;
    assign proc_9_output_sync_blk[0] = 1'b0;
    assign proc_dep_vld_vec_9[0] = dl_detect_out ? proc_dep_vld_vec_9_reg[0] : (proc_9_data_FIFO_blk[0] | proc_9_data_PIPO_blk[0] | proc_9_start_FIFO_blk[0] | proc_9_TLF_FIFO_blk[0] | proc_9_input_sync_blk[0] | proc_9_output_sync_blk[0]);
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            proc_dep_vld_vec_9_reg <= 'b0;
        end
        else begin
            proc_dep_vld_vec_9_reg <= proc_dep_vld_vec_9;
        end
    end
    assign in_chan_dep_vld_vec_9[0] = dep_chan_vld_8_9;
    assign in_chan_dep_data_vec_9[9 : 0] = dep_chan_data_8_9;
    assign token_in_vec_9[0] = token_8_9;
    assign dep_chan_vld_9_8 = out_chan_dep_vld_vec_9[0];
    assign dep_chan_data_9_8 = out_chan_dep_data_9;
    assign token_9_8 = token_out_vec_9[0];


`include "edge_canny_detector_hls_deadlock_report_unit.vh"
