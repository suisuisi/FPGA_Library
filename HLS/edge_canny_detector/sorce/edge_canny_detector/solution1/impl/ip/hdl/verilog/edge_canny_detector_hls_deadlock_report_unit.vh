   
    parameter PROC_NUM = 10;
    parameter ST_IDLE = 2'b0;
    parameter ST_DL_DETECTED = 2'b1;
    parameter ST_DL_REPORT = 2'b10;
   

    reg find_df_deadlock = 0;
    reg [1:0] CS_fsm;
    reg [1:0] NS_fsm;
    reg [PROC_NUM - 1:0] dl_detect_reg;
    reg [PROC_NUM - 1:0] dl_done_reg;
    reg [PROC_NUM - 1:0] origin_reg;
    reg [PROC_NUM - 1:0] dl_in_vec_reg;
    integer i;
    integer fp;

    // FSM State machine
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            CS_fsm <= ST_IDLE;
        end
        else begin
            CS_fsm <= NS_fsm;
        end
    end
    always @ (CS_fsm or dl_in_vec or dl_detect_reg or dl_done_reg or dl_in_vec or origin_reg) begin
        NS_fsm = CS_fsm;
        case (CS_fsm)
            ST_IDLE : begin
                if (|dl_in_vec) begin
                    NS_fsm = ST_DL_DETECTED;
                end
            end
            ST_DL_DETECTED: begin
                // has unreported deadlock cycle
                if (dl_detect_reg != dl_done_reg) begin
                    NS_fsm = ST_DL_REPORT;
                end
            end
            ST_DL_REPORT: begin
                if (|(dl_in_vec & origin_reg)) begin
                    NS_fsm = ST_DL_DETECTED;
                end
            end
        endcase
    end

    // dl_detect_reg record the procs that first detect deadlock
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            dl_detect_reg <= 'b0;
        end
        else begin
            if (CS_fsm == ST_IDLE) begin
                dl_detect_reg <= dl_in_vec;
            end
        end
    end

    // dl_detect_out keeps in high after deadlock detected
    assign dl_detect_out = |dl_detect_reg;

    // dl_done_reg record the cycles has been reported
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            dl_done_reg <= 'b0;
        end
        else begin
            if ((CS_fsm == ST_DL_REPORT) && (|(dl_in_vec & dl_detect_reg) == 'b1)) begin
                dl_done_reg <= dl_done_reg | dl_in_vec;
            end
        end
    end

    // clear token once a cycle is done
    assign token_clear = (CS_fsm == ST_DL_REPORT) ? ((|(dl_in_vec & origin_reg)) ? 'b1 : 'b0) : 'b0;

    // origin_reg record the current cycle start id
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            origin_reg <= 'b0;
        end
        else begin
            if (CS_fsm == ST_DL_DETECTED) begin
                origin_reg <= origin;
            end
        end
    end
   
    // origin will be valid for only one cycle
    always @ (CS_fsm or dl_detect_reg or dl_done_reg) begin
        if (CS_fsm == ST_DL_DETECTED) begin
            for (i = 0; i < PROC_NUM; i = i + 1) begin
                if (dl_detect_reg[i] & ~dl_done_reg[i] & ~(|origin)) begin
                    origin = 'b1 << i;
                end
            end
        end
        else begin
            origin = 'b0;
        end
    end
    
    // dl_in_vec_reg record the current cycle dl_in_vec
    always @ (negedge reset or posedge clock) begin
        if (~reset) begin
            dl_in_vec_reg <= 'b0;
        end
        else begin
            if (CS_fsm == ST_DL_DETECTED) begin
                dl_in_vec_reg <= origin;
            end
            else if (CS_fsm == ST_DL_REPORT) begin
                dl_in_vec_reg <= dl_in_vec;
            end
        end
    end
    
    // get the first valid proc index in dl vector
    function integer proc_index(input [PROC_NUM - 1:0] dl_vec);
        begin
            proc_index = 0;
            for (i = 0; i < PROC_NUM; i = i + 1) begin
                if (dl_vec[i]) begin
                    proc_index = i;
                end
            end
        end
    endfunction

    // get the proc path based on dl vector
    function [872:0] proc_path(input [PROC_NUM - 1:0] dl_vec);
        integer index;
        begin
            index = proc_index(dl_vec);
            case (index)
                0 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0";
                end
                1 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.xfrgb2gray_1080_1920_U0";
                end
                2 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0";
                end
                3 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0";
                end
                4 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0";
                end
                5 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0";
                end
                6 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0";
                end
                7 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0";
                end
                8 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.xfgray2rgb_1080_1920_U0";
                end
                9 : begin
                    proc_path = "edge_canny_detector_edge_canny_detector.xfMat2AXIvideo_24_9_1080_1920_1_U0";
                end
                default : begin
                    proc_path = "unknown";
                end
            endcase
        end
    endfunction

    // print the headlines of deadlock detection
    task print_dl_head;
        begin
            $display("\n//////////////////////////////////////////////////////////////////////////////");
            $display("// ERROR!!! DEADLOCK DETECTED at %0t ns! SIMULATION WILL BE STOPPED! //", $time);
            $display("//////////////////////////////////////////////////////////////////////////////");
            fp = $fopen("deadlock_db.dat", "w");
        end
    endtask

    // print the start of a cycle
    task print_cycle_start(input reg [872:0] proc_path, input integer cycle_id);
        begin
            $display("/////////////////////////");
            $display("// Dependence cycle %0d:", cycle_id);
            $display("// (1): Process: %0s", proc_path);
            $fdisplay(fp, "Dependence_Cycle_ID %0d", cycle_id);
            $fdisplay(fp, "Dependence_Process_ID 1");
            $fdisplay(fp, "Dependence_Process_path %0s", proc_path);
        end
    endtask

    // print the end of deadlock detection
    task print_dl_end(input integer num, input integer record_time);
        begin
            $display("////////////////////////////////////////////////////////////////////////");
            $display("// Totally %0d cycles detected!", num);
            $display("////////////////////////////////////////////////////////////////////////");
            $display("// ERROR!!! DEADLOCK DETECTED at %0t ns! SIMULATION WILL BE STOPPED! //", record_time);
            $display("//////////////////////////////////////////////////////////////////////////////");
            $fdisplay(fp, "Dependence_Cycle_Number %0d", num);
            $fclose(fp);
        end
    endtask

    // print one proc component in the cycle
    task print_cycle_proc_comp(input reg [872:0] proc_path, input integer cycle_comp_id);
        begin
            $display("// (%0d): Process: %0s", cycle_comp_id, proc_path);
            $fdisplay(fp, "Dependence_Process_ID %0d", cycle_comp_id);
            $fdisplay(fp, "Dependence_Process_path %0s", proc_path);
        end
    endtask

    // print one channel component in the cycle
    task print_cycle_chan_comp(input [PROC_NUM - 1:0] dl_vec1, input [PROC_NUM - 1:0] dl_vec2);
        reg [968:0] chan_path;
        integer index1;
        integer index2;
        begin
            index1 = proc_index(dl_vec1);
            index2 = proc_index(dl_vec2);
            case (index1)
                0 : begin
                    case(index2)
                    1: begin
                        if (~AXIvideo2xfMat_24_9_1080_1920_1_16_U0.rgb_img_src_4206_blk_n) begin
                            if (~rgb_img_src_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.rgb_img_src_data_U' written by process 'edge_canny_detector_edge_canny_detector.xfrgb2gray_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.rgb_img_src_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~rgb_img_src_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.rgb_img_src_data_U' read by process 'edge_canny_detector_edge_canny_detector.xfrgb2gray_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.rgb_img_src_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xfrgb2gray_1080_1920_U0_U.if_full_n & AXIvideo2xfMat_24_9_1080_1920_1_16_U0.ap_start & ~AXIvideo2xfMat_24_9_1080_1920_1_16_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~start_for_xfrgb2gray_1080_1920_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xfrgb2gray_1080_1920_U0_U' read by process 'edge_canny_detector_edge_canny_detector.xfrgb2gray_1080_1920_U0',");
                        end
                    end
                    7: begin
                        if (~AXIvideo2xfMat_24_9_1080_1920_1_16_U0.lowthreshold_out_blk_n) begin
                            if (~lowthreshold_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.lowthreshold_c_U' written by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.lowthreshold_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~lowthreshold_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.lowthreshold_c_U' read by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.lowthreshold_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~AXIvideo2xfMat_24_9_1080_1920_1_16_U0.highthreshold_out_blk_n) begin
                            if (~highthreshold_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.highthreshold_c_U' written by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.highthreshold_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~highthreshold_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.highthreshold_c_U' read by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.highthreshold_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0_U.if_full_n & AXIvideo2xfMat_24_9_1080_1920_1_16_U0.ap_start & ~AXIvideo2xfMat_24_9_1080_1920_1_16_U0.real_start & (trans_in_cnt_0 == trans_out_cnt_0) & ~start_for_xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0_U' read by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0',");
                        end
                    end
                    endcase
                end
                1 : begin
                    case(index2)
                    0: begin
                        if (~xfrgb2gray_1080_1920_U0.rgb_img_src_4206_blk_n) begin
                            if (~rgb_img_src_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.rgb_img_src_data_U' written by process 'edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.rgb_img_src_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~rgb_img_src_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.rgb_img_src_data_U' read by process 'edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.rgb_img_src_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xfrgb2gray_1080_1920_U0_U.if_empty_n & xfrgb2gray_1080_1920_U0.ap_idle & ~start_for_xfrgb2gray_1080_1920_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xfrgb2gray_1080_1920_U0_U' written by process 'edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0',");
                        end
                    end
                    2: begin
                        if (~xfrgb2gray_1080_1920_U0.gray_img_src_4207_blk_n) begin
                            if (~gray_img_src_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gray_img_src_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gray_img_src_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gray_img_src_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gray_img_src_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gray_img_src_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0_U.if_full_n & xfrgb2gray_1080_1920_U0.ap_start & ~xfrgb2gray_1080_1920_U0.real_start & (trans_in_cnt_1 == trans_out_cnt_1) & ~start_for_xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0_U' read by process 'edge_canny_detector_edge_canny_detector.xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0',");
                        end
                    end
                    endcase
                end
                2 : begin
                    case(index2)
                    1: begin
                        if (~xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0.gray_img_src_4207_blk_n) begin
                            if (~gray_img_src_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gray_img_src_data_U' written by process 'edge_canny_detector_edge_canny_detector.xfrgb2gray_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gray_img_src_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gray_img_src_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gray_img_src_data_U' read by process 'edge_canny_detector_edge_canny_detector.xfrgb2gray_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gray_img_src_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0_U.if_empty_n & xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0.ap_idle & ~start_for_xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0_U' written by process 'edge_canny_detector_edge_canny_detector.xfrgb2gray_1080_1920_U0',");
                        end
                    end
                    3: begin
                        if (~xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0.gaussian_mat_4209_blk_n) begin
                            if (~gaussian_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gaussian_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gaussian_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gaussian_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gaussian_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gaussian_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0_U.if_full_n & xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0.ap_start & ~xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0.real_start & (trans_in_cnt_2 == trans_out_cnt_2) & ~start_for_xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0_U' read by process 'edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0',");
                        end
                    end
                    endcase
                end
                3 : begin
                    case(index2)
                    2: begin
                        if (~xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_1080_1920_0_3_1_1_5_1921_3_9_false_s_fu_16.gaussian_mat_4209_blk_n) begin
                            if (~gaussian_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gaussian_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gaussian_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gaussian_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gaussian_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gaussian_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0_U.if_empty_n & xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0.ap_idle & ~start_for_xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0_U' written by process 'edge_canny_detector_edge_canny_detector.xFAverageGaussianMask3x3_0_0_1080_1920_0_1_1_1920_U0',");
                        end
                    end
                    4: begin
                        if (~xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_1080_1920_0_3_1_1_5_1921_3_9_false_s_fu_16.gradx_mat_4210_blk_n) begin
                            if (~gradx_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gradx_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gradx_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gradx_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0.grp_xFSobel3x3_0_2_1080_1920_0_3_1_1_5_1921_3_9_false_s_fu_16.grady_mat_4213_blk_n) begin
                            if (~grady_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.grady_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grady_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.grady_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_duplicate_1080_1920_U0_U.if_full_n & xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0.ap_start & ~xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0.real_start & (trans_in_cnt_3 == trans_out_cnt_3) & ~start_for_duplicate_1080_1920_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_duplicate_1080_1920_U0_U' read by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0',");
                        end
                    end
                    endcase
                end
                4 : begin
                    case(index2)
                    3: begin
                        if (~duplicate_1080_1920_U0.gradx_mat_4210_blk_n) begin
                            if (~gradx_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gradx_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gradx_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gradx_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~duplicate_1080_1920_U0.grady_mat_4213_blk_n) begin
                            if (~grady_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.grady_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grady_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.grady_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_duplicate_1080_1920_U0_U.if_empty_n & duplicate_1080_1920_U0.ap_idle & ~start_for_duplicate_1080_1920_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_duplicate_1080_1920_U0_U' written by process 'edge_canny_detector_edge_canny_detector.xFSobel_0_2_1080_1920_0_3_1_1_5_3_false_U0',");
                        end
                    end
                    5: begin
                        if (~duplicate_1080_1920_U0.gradx1_mat_4211_blk_n) begin
                            if (~gradx1_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gradx1_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx1_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gradx1_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gradx1_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx1_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~duplicate_1080_1920_U0.grady1_mat_4214_blk_n) begin
                            if (~grady1_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.grady1_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady1_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grady1_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.grady1_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady1_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0_U.if_full_n & duplicate_1080_1920_U0.ap_start & ~duplicate_1080_1920_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~start_for_xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0_U' read by process 'edge_canny_detector_edge_canny_detector.xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0',");
                        end
                    end
                    6: begin
                        if (~duplicate_1080_1920_U0.gradx2_mat_4212_blk_n) begin
                            if (~gradx2_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gradx2_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx2_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gradx2_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gradx2_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx2_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~duplicate_1080_1920_U0.grady2_mat_4215_blk_n) begin
                            if (~grady2_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.grady2_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady2_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grady2_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.grady2_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady2_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0_U.if_full_n & duplicate_1080_1920_U0.ap_start & ~duplicate_1080_1920_U0.real_start & (trans_in_cnt_4 == trans_out_cnt_4) & ~start_for_xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0_U' read by process 'edge_canny_detector_edge_canny_detector.xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0',");
                        end
                    end
                    endcase
                end
                5 : begin
                    case(index2)
                    4: begin
                        if (~xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0.gradx1_mat_4211_blk_n) begin
                            if (~gradx1_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gradx1_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx1_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gradx1_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gradx1_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx1_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0.grady1_mat_4214_blk_n) begin
                            if (~grady1_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.grady1_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady1_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grady1_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.grady1_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady1_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0_U.if_empty_n & xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0.ap_idle & ~start_for_xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0_U' written by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0',");
                        end
                    end
                    7: begin
                        if (~xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0.magnitude_mat_4216_blk_n) begin
                            if (~magnitude_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.magnitude_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.magnitude_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~magnitude_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.magnitude_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.magnitude_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    endcase
                end
                6 : begin
                    case(index2)
                    4: begin
                        if (~xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0.gradx2_mat_4212_blk_n) begin
                            if (~gradx2_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.gradx2_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx2_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~gradx2_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.gradx2_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.gradx2_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0.grady2_mat_4215_blk_n) begin
                            if (~grady2_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.grady2_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady2_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~grady2_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.grady2_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.grady2_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0_U.if_empty_n & xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0.ap_idle & ~start_for_xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0_U' written by process 'edge_canny_detector_edge_canny_detector.duplicate_1080_1920_U0',");
                        end
                    end
                    7: begin
                        if (~xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0.phase_mat_4217_blk_n) begin
                            if (~phase_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.phase_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.phase_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~phase_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.phase_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.phase_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    endcase
                end
                7 : begin
                    case(index2)
                    5: begin
                        if (~xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0.magnitude_mat_data_blk_n) begin
                            if (~magnitude_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.magnitude_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.magnitude_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~magnitude_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.magnitude_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFMagnitudeKernel_2_2_1080_1920_3_3_1_5_5_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.magnitude_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    6: begin
                        if (~xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0.phase_mat_data_blk_n) begin
                            if (~phase_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.phase_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.phase_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~phase_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.phase_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFAngleKernel_2_0_1080_1920_3_0_1_5_1_1920_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.phase_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                    end
                    8: begin
                        if (~xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0.nms_mat_data_blk_n) begin
                            if (~nms_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.nms_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xfgray2rgb_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.nms_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~nms_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.nms_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xfgray2rgb_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.nms_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xfgray2rgb_1080_1920_U0_U.if_full_n & xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0.ap_start & ~xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0.real_start & (trans_in_cnt_5 == trans_out_cnt_5) & ~start_for_xfgray2rgb_1080_1920_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xfgray2rgb_1080_1920_U0_U' read by process 'edge_canny_detector_edge_canny_detector.xfgray2rgb_1080_1920_U0',");
                        end
                    end
                    0: begin
                        if (~xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0.lowthreshold_blk_n) begin
                            if (~lowthreshold_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.lowthreshold_c_U' written by process 'edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.lowthreshold_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~lowthreshold_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.lowthreshold_c_U' read by process 'edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.lowthreshold_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0.highthreshold_blk_n) begin
                            if (~highthreshold_c_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.highthreshold_c_U' written by process 'edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.highthreshold_c_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~highthreshold_c_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.highthreshold_c_U' read by process 'edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.highthreshold_c_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0_U.if_empty_n & xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0.ap_idle & ~start_for_xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0_U' written by process 'edge_canny_detector_edge_canny_detector.AXIvideo2xfMat_24_9_1080_1920_1_16_U0',");
                        end
                    end
                    endcase
                end
                8 : begin
                    case(index2)
                    7: begin
                        if (~xfgray2rgb_1080_1920_U0.nms_mat_4218_blk_n) begin
                            if (~nms_mat_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.nms_mat_data_U' written by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.nms_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~nms_mat_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.nms_mat_data_U' read by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.nms_mat_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xfgray2rgb_1080_1920_U0_U.if_empty_n & xfgray2rgb_1080_1920_U0.ap_idle & ~start_for_xfgray2rgb_1080_1920_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xfgray2rgb_1080_1920_U0_U' written by process 'edge_canny_detector_edge_canny_detector.xFSuppression3x3_2_0_0_1080_1920_3_0_0_1_5_1_1_1920_3840_3840_U0',");
                        end
                    end
                    9: begin
                        if (~xfgray2rgb_1080_1920_U0.rgb_img_dst_4208_blk_n) begin
                            if (~rgb_img_dst_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.rgb_img_dst_data_U' written by process 'edge_canny_detector_edge_canny_detector.xfMat2AXIvideo_24_9_1080_1920_1_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.rgb_img_dst_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~rgb_img_dst_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.rgb_img_dst_data_U' read by process 'edge_canny_detector_edge_canny_detector.xfMat2AXIvideo_24_9_1080_1920_1_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.rgb_img_dst_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xfMat2AXIvideo_24_9_1080_1920_1_U0_U.if_full_n & xfgray2rgb_1080_1920_U0.ap_start & ~xfgray2rgb_1080_1920_U0.real_start & (trans_in_cnt_6 == trans_out_cnt_6) & ~start_for_xfMat2AXIvideo_24_9_1080_1920_1_U0_U.if_read) begin
                            $display("//      Blocked by full output start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xfMat2AXIvideo_24_9_1080_1920_1_U0_U' read by process 'edge_canny_detector_edge_canny_detector.xfMat2AXIvideo_24_9_1080_1920_1_U0',");
                        end
                    end
                    endcase
                end
                9 : begin
                    case(index2)
                    8: begin
                        if (~xfMat2AXIvideo_24_9_1080_1920_1_U0.rgb_img_dst_4208_blk_n) begin
                            if (~rgb_img_dst_data_U.if_empty_n) begin
                                $display("//      Blocked by empty input FIFO 'edge_canny_detector_edge_canny_detector.rgb_img_dst_data_U' written by process 'edge_canny_detector_edge_canny_detector.xfgray2rgb_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.rgb_img_dst_data_U");
                                $fdisplay(fp, "Dependence_Channel_status EMPTY");
                            end
                            else if (~rgb_img_dst_data_U.if_full_n) begin
                                $display("//      Blocked by full output FIFO 'edge_canny_detector_edge_canny_detector.rgb_img_dst_data_U' read by process 'edge_canny_detector_edge_canny_detector.xfgray2rgb_1080_1920_U0'");
                                $fdisplay(fp, "Dependence_Channel_path edge_canny_detector_edge_canny_detector.rgb_img_dst_data_U");
                                $fdisplay(fp, "Dependence_Channel_status FULL");
                            end
                        end
                        if (~start_for_xfMat2AXIvideo_24_9_1080_1920_1_U0_U.if_empty_n & xfMat2AXIvideo_24_9_1080_1920_1_U0.ap_idle & ~start_for_xfMat2AXIvideo_24_9_1080_1920_1_U0_U.if_write) begin
                            $display("//      Blocked by missing 'ap_start' from start propagation FIFO 'edge_canny_detector_edge_canny_detector.start_for_xfMat2AXIvideo_24_9_1080_1920_1_U0_U' written by process 'edge_canny_detector_edge_canny_detector.xfgray2rgb_1080_1920_U0',");
                        end
                    end
                    endcase
                end
            endcase
        end
    endtask

    // report
    initial begin : report_deadlock
        integer cycle_id;
        integer cycle_comp_id;
        integer record_time;
        wait (reset == 1);
        cycle_id = 1;
        record_time = 0;
        while (1) begin
            @ (negedge clock);
            case (CS_fsm)
                ST_DL_DETECTED: begin
                    cycle_comp_id = 2;
                    if (dl_detect_reg != dl_done_reg) begin
                        if (dl_done_reg == 'b0) begin
                            print_dl_head;
                            record_time = $time;
                        end
                        print_cycle_start(proc_path(origin), cycle_id);
                        cycle_id = cycle_id + 1;
                    end
                    else begin
                        print_dl_end((cycle_id - 1),record_time);
                        find_df_deadlock = 1;
                        @(negedge clock);
                        $finish;
                    end
                end
                ST_DL_REPORT: begin
                    if ((|(dl_in_vec)) & ~(|(dl_in_vec & origin_reg))) begin
                        print_cycle_chan_comp(dl_in_vec_reg, dl_in_vec);
                        print_cycle_proc_comp(proc_path(dl_in_vec), cycle_comp_id);
                        cycle_comp_id = cycle_comp_id + 1;
                    end
                    else begin
                        print_cycle_chan_comp(dl_in_vec_reg, dl_in_vec);
                    end
                end
            endcase
        end
    end
 
