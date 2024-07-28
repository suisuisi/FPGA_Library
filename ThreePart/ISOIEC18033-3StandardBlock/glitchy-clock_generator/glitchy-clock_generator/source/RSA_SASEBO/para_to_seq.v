`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:34:26 08/24/2010 
// Design Name: 
// Module Name:    para_to_seq 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module para_to_seq(clk, rst, rdy, data_in, data_out);
   parameter RSA_LEN = 512;
    parameter BUS_W   = 32;
   
    input                clk, rst, rdy; //Clock, reset, ready
    input  [RSA_LEN-1:0] data_in;
    output [BUS_W-1  :0] data_out;
 //   reg    [BUS_W-1  :0] data_out;
   reg [RSA_LEN-1:0] 	 data;
   

   reg [3:0] 		 cnt;

    always @(posedge clk) begin
        if (rst == 1'b1) begin
		   data <= 0;
		end else begin
		   /*
	   case (cnt)
             4'h1: data_out <= data_in[511:480];
             4'h2: data_out <= data_in[479:448];
             4'h3: data_out <= data_in[447:416];
             4'h4: data_out <= data_in[415:384];
             4'h5: data_out <= data_in[383:352];
             4'h6: data_out <= data_in[351:320];
             4'h7: data_out <= data_in[319:288];
             4'h8: data_out <= data_in[287:256];
             4'h9: data_out <= data_in[255:224];
             4'hA: data_out <= data_in[223:192];
             4'hB: data_out <= data_in[191:160];
             4'hC: data_out <= data_in[159:128];
             4'hD: data_out <= data_in[127:96];
             4'hE: data_out <= data_in[95:64];
             4'hF: data_out <= data_in[63:32];
             4'h0: data_out <= data_in[31:0];
	   endcase // case (cnt)
			*/
	   if (cnt) begin
		  cnt <= cnt + 1;
		  data <= {32'h0, data[RSA_LEN-1:BUS_W]};
	   end else if (rdy) begin
		  cnt <= 1;
		  data <= data_in;
	   end
	end // else: !if(rst == 1'b1)
    end // always @ (posedge clk)
   assign data_out = data[BUS_W-1:0];
   
endmodule
