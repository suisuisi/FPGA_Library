//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           ov5640_capture_data
// Last modified Date:  2019/6/21 14:26:05
// Last Version:        V1.0
// Descriptions:       ov5640数据采集模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/6/21 14:26:05
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module  ov5640_capture_data(
    input                 rst_n           ,  //复位信号

	//摄像头接口
    input                 cam_pclk        ,  //cam 数据像素时钟
    input                 cam_vsync       ,  //cam 场同步信号
    input                 cam_href        ,  //cam 行同步信号
    input        [7:0]    cam_data        ,  //cam 数据
    output                cam_rst_n       ,  //cmos 复位信号，低电平有效
    output                cam_pwdn        ,  //电源休眠模式选择

	//RGB888接口
    output                cmos_frame_clk,    //时钟信号
    output                cmos_frame_ce,     //时钟使能信号

	output                cmos_frame_vsync,  //帧有效信号
    output                cmos_frame_href ,  //行有效信号
    output                cmos_frame_de ,    //数据有效
    output       [23:0]   cmos_frame_data    //有效数据
);

//parameter define

//寄存器全部配置完成后，先等待10帧数据
//待寄存器配置生效后再开始采集图像
localparam  WAIT_FRAME = 4'd10  ;            //寄存器数据稳定等待的帧个数

//reg define
reg          rst_n_d0 =1;
reg          rst_n_syn =1;
reg          cam_vsync_d0 ;
reg          cam_vsync_d1 ;
reg          cam_href_d0 ;
reg          cam_href_d1 ;
reg   [3:0]  cmos_ps_cnt ;                  //等待帧数稳定计数器
reg          wait_done ;
reg          byte_flag ;
reg   [7:0]  cam_data_d0 ;
reg  [15:0]  cmos_data_16b ;                //用于8位转16位的临时寄存器
reg          byte_flag_d0 ;

//wire define
wire  pos_vsync ;

//*****************************************************
//**                    main code
//*****************************************************

//采输入场同步信号的上升沿
assign  pos_vsync  = (~cam_vsync_d1) & cam_vsync_d0 ;

//不对摄像头硬件复位,固定高电平
assign  cam_rst_n = 1'b1;

//电源休眠模式选择 0：正常模式 1：电源休眠模式
assign  cam_pwdn  = 1'b0;

assign  cmos_frame_clk   = cam_pclk;
//由于摄像头输入接口的两个时钟周期对应于RGB888输出接口的一个有效时钟周期
//所以要给出数据有效标志即RGB888输出接口的时钟使能信号
assign  cmos_frame_ce    = wait_done  ?  (byte_flag_d0 & cmos_frame_href) || (!cmos_frame_href) : 1'b0;
assign  cmos_frame_vsync = wait_done  ?  cam_vsync_d1  :  1'b0; //输出帧有效信号
assign  cmos_frame_href  = wait_done  ?  cam_href_d1   :  1'b0; //输出行有效信号
assign  cmos_frame_de    = cmos_frame_href ;
assign  cmos_frame_data  = wait_done  ?
	{ cmos_data_16b[15:11],3'd0 , cmos_data_16b[10:5],2'd0 , cmos_data_16b[4:0],3'd0 }
	:  24'd0; //输出数据

//复位信号的异步复位、同步释放处理
always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        rst_n_d0 <= 1'b0;
        rst_n_d0 <= 1'b0;
    end
    else begin
        rst_n_d0  <= 1'b1;
        rst_n_syn <= rst_n_d0;
    end
end

//对行、场同步信号的延迟打拍
always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;

        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;

        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;
    end
end

//寄存器全部配置完成后，先等待10帧数据
//待寄存器配置生效后再开始采集图像
always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn)
        cmos_ps_cnt <= 4'd0;
    else if(pos_vsync && (cmos_ps_cnt < WAIT_FRAME))
        cmos_ps_cnt <= cmos_ps_cnt + 4'd1;  //对帧数进行计数
end

//等待完成后 给出 等待完成信号
always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn)
        wait_done <= 1'b0;
    else if((cmos_ps_cnt == WAIT_FRAME) && pos_vsync)
        wait_done <= 1'b1;
end


//8位数据转16位RGB565数据
always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn) begin
        cmos_data_16b <= 16'd0;
        cam_data_d0 <= 8'd0;
        byte_flag <= 1'b0;
    end
    else if( cam_href ) begin  //cam 行同步信号
        byte_flag   <= ~byte_flag;
        cam_data_d0 <= cam_data;
        if(byte_flag)
            cmos_data_16b <= {cam_data_d0,cam_data};
    end
    else begin
        byte_flag <= 1'b0;
        cam_data_d0 <= 8'b0;
    end
end

always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn)
        byte_flag_d0 <= 1'b0;
    else
        byte_flag_d0 <= byte_flag;
end

endmodule
