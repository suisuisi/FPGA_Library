/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: Class with all the matrix computed
// Module Name: AesVE.sv
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: aes_calculator
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "ve_AES_BaseUnit.sv"
`include "ve_AES_AlreadyComputed.sv"
`include "ve_AES_Core.sv"
`include "ve_AES_class_MixColumn.sv"
class AesEnvironment extends BaseUnit;

 	AlreadyComputed computed_val;
    BaseUnit units[$];
	AesCore aes; 
	
	virtual mix_column_intf.drv intf_drv;
	virtual mix_column_intf.rcv intf_rcv;
	
	agent_MixColumn mix_column_inst;
	
	function new(string name, int id, virtual mix_column_intf.drv intf_drv_i, virtual mix_column_intf.rcv intf_rcv_i);
		super.new(name, id);
 		computed_val = new;
 		this.intf_drv = intf_drv_i;
		this.intf_rcv = intf_rcv_i;
		
		aes = new ("AES CORE", 0, computed_val);
		units.push_back(aes);
		mix_column_inst = new(this.intf_drv, this.intf_rcv, "AGENT MIX COLUMN", 1, aes);
		units.push_back(mix_column_inst);
		
	endfunction

    task end_of_simulation_mechanism();  
		#100;
		$display("[%0t] %s End of simulation", $time, super.name);
		$finish;
    endtask: end_of_simulation_mechanism

    task run();
		$display("UNITS SIZE %0d", units.size());
		for(int i=0;i<units.size();i++) 
		  fork
			automatic int k=i;
			begin
				units[k].run();
			end
		  join_any
      end_of_simulation_mechanism();
	endtask: run
endclass : AesEnvironment