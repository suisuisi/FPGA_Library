//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: GF(2^4) squarer and scalar.
// Module Name: aes_top
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: Multiplexor
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`ifndef KEY_SIZE
    `define KEY_SIZE      128
`endif

`ifndef DATA_SIZE
    `define DATA_SIZE	  128
`endif

`ifndef R_ACTIV
 `define R_ACTIV     1'b1
`endif

`ifndef NO_OF_ROUNDS
    `define NO_OF_ROUNDS 10
`endif

`ifndef u8_MSB
 `define u8_MSB(x)  8*(x+1) - 1
`endif

`ifndef u8_LSB
    `define u8_LSB(x)  8*x1
`endif

module aes_top (clk, reset, text_in, key, encrypt, text_out);
	input clk;
	input reset;
	input [`DATA_SIZE -1:0] text_in;
	input [`KEY_SIZE -1:0]  key;
	
	//ToDo Update encryption signal just when Pipeline is empty
	input encrypt;
	
	output [`DATA_SIZE -1:0] text_out;
	
	wire [1:0] 			     selection;
	
	reg  [`DATA_SIZE -1:0] reg_data_in_lvl;
	     
	reg  [`DATA_SIZE -1:0] reg_sub_byte_lvl;
	     
	reg  [`DATA_SIZE -1:0] reg_mix_col_lvl;
	     
	reg  [`DATA_SIZE -1:0] reg_inv_mix_col_lvl;
	
	reg  [3:0] round_counter;
	
	reg  [`KEY_SIZE-1 : 0] round_key;
	wire [`KEY_SIZE-1 : 0] round_key_out;
	
	reg  [`DATA_SIZE -1:0] SB_input;
	wire [`DATA_SIZE -1:0] SB_output;
	
	wire [`DATA_SIZE -1:0] SH_out;
	
	wire [`DATA_SIZE -1:0] MC_input;
	
	wire [`DATA_SIZE -1:0] MC_output_e;
	wire [`DATA_SIZE -1:0] MC_output_d;
	
	assign text_out = SH_out ^ round_key;
	
	wire r_cnt_zero;
	
	assign r_cnt_zero = (round_counter == 0 || round_counter == 1)? 1:0;
	
	assign MC_input = (encrypt) ? SH_out : SH_out ^ round_key;
	
	// data in selection
	assign selection[0] = encrypt & (~ r_cnt_zero);
	assign selection[1] = r_cnt_zero;
	
	always @(selection, reg_data_in_lvl, reg_mix_col_lvl, reg_inv_mix_col_lvl) begin	
		case(selection) 
			2'b00 : SB_input <= reg_inv_mix_col_lvl;
			2'b01 : SB_input <= reg_mix_col_lvl;
			2'b10 : SB_input <= reg_data_in_lvl;
		endcase
	end
	
	always @(posedge clk) begin
		if (reset == `R_ACTIV) begin
			round_counter <= 0;
			round_key <= key;
			
			reg_data_in_lvl  	<= key ^ text_in;
			reg_sub_byte_lvl 	<= SB_output;
			reg_mix_col_lvl  	<= MC_output_e ^ round_key;
			reg_inv_mix_col_lvl <= MC_output_d; 
		end
		else begin
			if (round_counter < `NO_OF_ROUNDS) begin
				round_counter <= round_counter + 1'b1;
				round_key <= round_key_out;
			end
			else begin
				round_counter <= 0;
				round_key <= key;
			end
			
		
		end
	end
	
	aes_s_box128 	sbox_inst(SB_input, encrypt, SB_output);
	
	aes_shift_rows  shift_row_inst(reg_sub_byte_lvl, encrypt, SH_out); 
	
	key_schedule 	key_schedule_inst(round_key, encrypt, round_counter, round_key_out);
	
	MixColumns		mix_inst0(MC_input[`u8_MSB(0):`u8_LSB(0)],
							  MC_input[`u8_MSB(1):`u8_LSB(1)],
							  MC_input[`u8_MSB(2):`u8_LSB(2)],
							  MC_input[`u8_MSB(3):`u8_LSB(3)],
							  MC_output_e[`u8_MSB(0):`u8_LSB(0)],
							  MC_output_e[`u8_MSB(1):`u8_LSB(1)],
							  MC_output_e[`u8_MSB(2):`u8_LSB(2)],
							  MC_output_e[`u8_MSB(3):`u8_LSB(3)],
							  MC_output_d[`u8_MSB(0):`u8_LSB(0)],
							  MC_output_d[`u8_MSB(1):`u8_LSB(1)],
							  MC_output_d[`u8_MSB(2):`u8_LSB(2)],
							  MC_output_d[`u8_MSB(3):`u8_LSB(3)]);
							  
							  
	MixColumns		mix_inst1(MC_input[`u8_MSB(4):`u8_LSB(4)],
							  MC_input[`u8_MSB(5):`u8_LSB(5)],
							  MC_input[`u8_MSB(6):`u8_LSB(6)],
							  MC_input[`u8_MSB(7):`u8_LSB(7)],
							  MC_output_e[`u8_MSB(4):`u8_LSB(4)],
							  MC_output_e[`u8_MSB(5):`u8_LSB(5)],
							  MC_output_e[`u8_MSB(6):`u8_LSB(6)],
							  MC_output_e[`u8_MSB(7):`u8_LSB(7)],
							  MC_output_d[`u8_MSB(4):`u8_LSB(4)],
							  MC_output_d[`u8_MSB(5):`u8_LSB(5)],
							  MC_output_d[`u8_MSB(6):`u8_LSB(6)],
							  MC_output_d[`u8_MSB(7):`u8_LSB(7)]);
							  
							  
	MixColumns		mix_inst2(MC_input[`u8_MSB(8) :`u8_LSB(8)],
							  MC_input[`u8_MSB(9) :`u8_LSB(9)],
							  MC_input[`u8_MSB(10):`u8_LSB(10)],
							  MC_input[`u8_MSB(11):`u8_LSB(11)],
							  MC_output_e[`u8_MSB(8) :`u8_LSB(8)],
							  MC_output_e[`u8_MSB(9) :`u8_LSB(9)],
							  MC_output_e[`u8_MSB(10):`u8_LSB(10)],
							  MC_output_e[`u8_MSB(11):`u8_LSB(11)],
							  MC_output_d[`u8_MSB(8) :`u8_LSB(8)],
							  MC_output_d[`u8_MSB(9) :`u8_LSB(9)],
							  MC_output_d[`u8_MSB(10):`u8_LSB(10)],
							  MC_output_d[`u8_MSB(11):`u8_LSB(11)]);
							  
	MixColumns		mix_inst3(MC_input[`u8_MSB(12):`u8_LSB(12)],
							  MC_input[`u8_MSB(13):`u8_LSB(13)],
							  MC_input[`u8_MSB(14):`u8_LSB(14)],
							  MC_input[`u8_MSB(15):`u8_LSB(15)],
							  MC_output_e[`u8_MSB(12):`u8_LSB(12)],
							  MC_output_e[`u8_MSB(13):`u8_LSB(13)],
							  MC_output_e[`u8_MSB(14):`u8_LSB(14)],
							  MC_output_e[`u8_MSB(15):`u8_LSB(15)],
							  MC_output_d[`u8_MSB(12):`u8_LSB(12)],
							  MC_output_d[`u8_MSB(13):`u8_LSB(13)],
							  MC_output_d[`u8_MSB(14):`u8_LSB(14)],
							  MC_output_d[`u8_MSB(15):`u8_LSB(15)]);
	
	
endmodule