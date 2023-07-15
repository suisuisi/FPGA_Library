/*
------------------------------------------------------------------
   rgb2hsv component
------------------------------------------------------------------

This module convert the RGB values of the input to its HSV.

The processing is divided in a 6 stages pipeline, in order to optimize
the hardware, as the system works in streaming i.e. one pixel is
processed at each clk cycle.

NOTE: The Hue is the H component from the HSV image format,
the Saturation is the S component,
and the Brightness is the V component.
*/
module rgbhsv(
        input clk,
        input rst_l,
        // Data input
        input in_valid,
        input [7:0] in_red,
        input [7:0] in_green,
        input [7:0] in_blue,
        input in_visual,
        input in_done,
        // Data output
        output out_valid,
        output [7:0] out_red,
        output [7:0] out_green,
        output [7:0] out_blue,
        output [7:0] out_hue,
        output [7:0] out_saturation,
        output [7:0] out_brightness,
        output out_visual,
        output out_done);
       
    // STAGE 1
    // For the current pixel, determine which are the highest and lowest
    // compoments. 
    // In case that they are equal, the priority for setting the highest value
    // is red > blue > green. For the lowest value, it is green < blue < red.
    // It also stores the identifier of the max and min components.
    // 1 for red, 2 for green or 3 for blue.
    reg valid1;
    reg [7:0] red1;
    reg [7:0] green1;
    reg [7:0] blue1;
    reg visual1;
    reg done1;
    // Max-Min
    reg [7:0] max_value1;
    reg [1:0] max_index1;
    reg [7:0] min_value1;
    reg [1:0] min_index1;
    always @(posedge clk)
    begin
        if (rst_l) begin
            valid1 <= in_valid;
            red1[7:0] <= in_red[7:0];
            green1[7:0] <= in_green[7:0];
            blue1[7:0] <= in_blue[7:0];
            visual1 <= in_visual;
            done1 <= in_done;
            // Max component calculation.
            if (in_red >= in_green) begin
                if (in_red >= in_blue) begin
                    max_value1[7:0] <= in_red[7:0];
                    max_index1[1:0] <= 1;
                end
                else begin
                    max_value1[7:0] <= in_blue[7:0];
                    max_index1[1:0] <= 3;
                end
            end
            else begin
                if (in_blue >= in_green) begin
                    max_value1[7:0] <= in_blue[7:0];
                    max_index1[1:0] <= 3;
                end
                else begin
                    max_value1[7:0] <= in_green[7:0];
                    max_index1[1:0] <= 2;
                end
            end
            // Min component calculation.
            if (in_red < in_green) begin
                if (in_red < in_blue) begin
                    min_value1[7:0] <= in_red[7:0];
                    min_index1[1:0] <= 1;
                end
                else begin
                    min_value1[7:0] <= in_blue[7:0];
                    min_index1[1:0] <= 3;
                end
            end
            else begin
                if (in_blue < in_green) begin
                    min_value1[7:0] <= in_blue[7:0];
                    min_index1[1:0] <= 3;
                end
                else begin
                    min_value1[7:0] <= in_green[7:0];
                    min_index1[1:0] <= 2;
                end
            end
        end 
        else begin
            valid1 <= 1'b0;
            red1[7:0] <= 8'b0;
            green1[7:0] <= 8'b0;
            blue1[7:0] <= 8'b0;
            visual1 <= 1'b0;
            done1 <= 1'b0;
            // Max - Min
            max_value1[7:0] <= 8'd0;
            max_index1[1:0] <= 2'd0; 
            min_value1[7:0] <= 8'd0; 
            min_index1[1:0] <= 2'd0;
        end
    end
    
    // STAGE 2
    // Calculates the difference between the highest and lowest components.
    // Propagates as well the rest of the values used in the previous stage.
    reg valid2;
    reg [7:0] red2;
    reg [7:0] green2;
    reg [7:0] blue2;
    reg visual2;
    reg done2;
    // Diference
    reg [7:0] dif2;
    reg [7:0] max_value2;
    reg [1:0] max_index2;
    reg [7:0] min_value2;
    reg [1:0] min_index2;
    always @(posedge clk)
    begin
        if (rst_l) begin
            valid2 <= valid1;
            red2[7:0] <= red1[7:0];
            green2[7:0] <= green1[7:0];
            blue2[7:0] <= blue1[7:0];
            visual2 <= visual1;
            done2 <= done1;
            // Diference
            dif2[7:0] <= max_value1[7:0] - min_value1[7:0];
            // Max
            max_value2[7:0] <= max_value1[7:0];
            max_index2[1:0] <= max_index1[1:0];
            // Min
            min_value2[7:0] <= min_value1[7:0];
            min_index2[1:0] <= min_index1[1:0];
        end 
        else begin
            valid2 <= 1'b0;
            red2[7:0] <= 8'b0;
            green2[7:0] <= 8'b0;
            blue2[7:0] <= 8'b0;
            visual2 <= 1'b0;
            done2 <= 1'b0;
            // Max - Min
            dif2[7:0] <= 8'd0;
            max_value2[7:0] <= 8'd0;
            max_index2[1:0] <= 2'd0;
            min_value2[7:0] <= 8'd0; 
            min_index2[1:0] <= 2'd0;
        end
    end
    
    // STAGE 3
    // Calculates a new parameter (hue3) with the current pixel.
    // It is the positive difference between the 2 lowest components values.
    // The result is left-shifted 4 position, as the HUE component is a 12-bit
    // value and the original components are 8-bit.
    // Propagates as well the rest of the values used in the previous stages.
    reg valid3;
    reg [7:0] red3;
    reg [7:0] green3;
    reg [7:0] blue3;
    reg visual3;
    reg done3;
    // Color
    reg [11:0] hue3;
    reg [7:0] dif3;
    reg [7:0] max_value3;
    reg [1:0] max_index3;
    reg [7:0] min_value3;
    reg [1:0] min_index3;
    always @(posedge clk)
    begin
        if (rst_l) begin
            valid3 <= valid2;
            red3[7:0] <= red2[7:0];
            green3[7:0] <= green2[7:0];
            blue3[7:0] <= blue2[7:0];
            visual3 <= visual2;
            done3 <= done2;
            // Diference
            dif3[7:0] <= dif2[7:0];
            max_value3[7:0] <= max_value2[7:0];
            max_index3[1:0] <= max_index2[1:0];
            min_value3[7:0] <= min_value2[7:0];
            min_index3[1:0] <= min_index2[1:0];
            // Color
            if (dif2 > 0) begin
                if (max_index2 == 1) begin
                    if (green2 < blue2) begin
                        hue3[11:0] = ((blue2 - green2) << 4);
                    end
                    else begin
                        hue3[11:0] = ((green2 - blue2) << 4);
                    end
                end
                if (max_index2 == 2) begin
                    if (blue2 < red2) begin
                        hue3[11:0] = ((red2 - blue2) << 4);
                    end
                    else begin
                        hue3[11:0] = ((blue2 - red2) << 4);
                    end
                end
                if (max_index2 == 3) begin
                    if (red2 < green2) begin
                        hue3[11:0] = ((green2 - red2) << 4);
                    end
                    else begin
                        hue3[11:0] = ((red2 - green2) << 4);
                    end
                end
            end
            else begin
                hue3[11:0] <= 12'd0;             
            end
        end
        else begin
            valid3 <= 1'b0;
            red3[7:0] <= 8'b0;
            green3[7:0] <= 8'b0;
            blue3[7:0] <= 8'b0;
            visual3 <= 1'b0;
            done3 <= 1'b0;
            // Color
            hue3[11:0] <= 12'd0;
            dif3[7:0] <= 8'd0;
            max_value3[7:0] <= 8'd0;
            max_index3[1:0] <= 2'd0;
            min_value3[7:0] <= 8'd0;
            min_index3[1:0] <= 2'd0;
        end
    end
    
    // STAGE 4
    // Calculates a new parameter (hue4) with the current pixel.
    // It is the result of dividing the result from the previous stage (hue3)
    // by the difference between the maximum and minimum value.
    // Propagates as well the rest of the values used in the previous stages.
    reg valid4;
    reg [7:0] red4;
    reg [7:0] green4;
    reg [7:0] blue4;
    reg visual4;
    reg done4;
    // Color
    reg [11:0] hue4;
    reg [7:0] dif4;
    reg [7:0] max_value4;
    reg [1:0] max_index4;
    always @(posedge clk)
    begin
        if (rst_l) begin
            valid4 <= valid3;
            red4[7:0] <= red3[7:0];
            green4[7:0] <= green3[7:0];
            blue4[7:0] <= blue3[7:0];
            visual4 <= visual3;
            done4 <= done3;          
            dif4[7:0] <= dif3[7:0];
            max_value4[7:0] <= max_value3[7:0];
            max_index4 <= max_index3;
            // Division
            hue4[11:0] <= (hue3 / dif3);
        end
        else begin
            valid4 <= 1'b0;
            red4[7:0] <= 8'b0;
            green4[7:0] <= 8'b0;
            blue4[7:0] <= 8'b0;
            visual4 <= 1'b0;
            done4 <= 1'b0;
            hue4[11:0] <= 12'd0;
            dif4[7:0] <= 8'd0;
            max_value4 <= 8'd0;
            max_index4[1:0] <= 2'd0;
        end
    end
       
    // STAGE 5
    // Calculates a new parameter (hue5) with the current pixel.
    // Depending on which are the highest and lowest components, performs an
    // arithmetical operation to the result from the previous stage (hue4).
    // Propagates as well the rest of the values used in the previous stages.
    reg valid5;
    reg [7:0] red5;
    reg [7:0] green5;
    reg [7:0] blue5;
    reg visual5;
    reg done5;
    // Color
    reg [11:0] hue5;
    reg [7:0] dif5;
    reg [7:0] max_value5;
    always @(posedge clk)
    begin
        if (rst_l) begin
            valid5 <= valid4;
            red5[7:0] <= red4[7:0];
            green5[7:0] <= green4[7:0];
            blue5[7:0] <= blue4[7:0];
            visual5 <= visual4;
            done5 <= done4;
            dif5[7:0] <= dif4[7:0];
            max_value5[7:0] <= max_value4[7:0];
            if (dif4 > 0) begin
                if (max_index4 == 1) begin
                    if (green4 < blue4) begin
                        hue5[11:0] = 96 - hue4;
                    end
                    else begin
                        hue5[11:0] = 0 + hue4;
                    end
                end
                if (max_index4 == 2) begin
                    if (blue4 < red4) begin
                        hue5[11:0] = 32 - hue4;
                    end
                    else begin
                        hue5[11:0] = 32 + hue4;
                    end
                end
                if (max_index4 == 3) begin
                    if (red4 < green4) begin
                        hue5[11:0] = 64 - hue4;
                    end
                    else begin
                        hue5[11:0] = 64 + hue4;
                    end
                end
            end
            else begin
                hue5[11:0] <= 12'd0;             
            end
        end
        else begin
            valid5 <= 1'b0;
            red5[7:0] <= 8'b0;
            green5[7:0] <= 8'b0;
            blue5[7:0] <= 8'b0;
            visual5 <= 1'b0;
            done5 <= 1'b0;
            dif5[7:0] <= 8'd0;
            max_value5[7:0] <= 8'd0;
            hue5[11:0] <= 12'd0;
        end
    end
    
    // STAGE 6
    // Calculates the final hue value of the current pixel.
    // It is the product of the result of the previous stage (hue5) and 85.
    //
    // Calculates the pixel saturation, defined as the coefficient between the
    // difference of the 2 smallest components and the highest component value.
    //
    // Assigns the brightness output value, corresponding to the highest
    // component value.
    //
    // Propagates as well the rest of the values used in the previous stages.
    // The result register has a size of 18 bits, and it is cropped to 8.
    reg valid;
    reg [7:0] red;
    reg [7:0] green;
    reg [7:0] blue;
    reg visual;
    reg done;
    // Color
    reg [18:0] hue;
    reg [7:0] saturation;
    reg [7:0] max_value;
    always @(posedge clk)
    begin
        if (rst_l) begin
            valid <= valid5;
            red[7:0] <= red5[7:0];
            green[7:0] <= green5[7:0];
            blue[7:0] <= blue5[7:0];
            visual <= visual5;
            done <= done5;
            max_value[7:0] <= max_value5[7:0];
            hue[18:0] <= (85 * hue5);
            if (max_value5 == 0) begin
                saturation[7:0] = 8'd0;
            end
            else begin
                saturation[7:0] = 255 * dif5 / max_value5;
            end
        end
        else begin 
            valid <= 1'b0;
            red[7:0] <= 8'b0;
            green[7:0] <= 8'b0;
            blue[7:0] <= 8'b0;
            visual <= 1'b0;
            done <= 1'b0;
            max_value[7:0] <= 8'd0;
            hue[18:0] <= 19'd0;
            saturation [7:0] <= 8'd0;
        end
    end
    assign out_valid = valid;
    assign out_red[7:0] = red[7:0];
    assign out_green[7:0] = green[7:0];  
    assign out_blue[7:0] = blue[7:0];
    assign out_hue[7:0] = hue[12:5];
    assign out_saturation[7:0] = saturation[7:0];
    assign out_brightness[7:0] = max_value[7:0];
    assign out_visual = visual;
    assign out_done = done;
    
endmodule