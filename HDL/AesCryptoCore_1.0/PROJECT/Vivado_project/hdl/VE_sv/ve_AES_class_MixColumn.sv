class agent_MixColumn extends BaseUnit;
    virtual mix_column_intf.drv drv;
	virtual mix_column_intf.rcv rcv;
	
	AesCore aes;
	
	extern function new(	virtual mix_column_intf.drv intf_drv,
							virtual mix_column_intf.rcv intf_rcv,
							string name, 
							int id,
							const ref AesCore aes_core);
	extern function void check_mix_column_result;
	
	extern task run();

endclass : agent_MixColumn

function agent_MixColumn :: new(
								virtual mix_column_intf.drv intf_drv,
								virtual mix_column_intf.rcv intf_rcv,
								string name, 
								int id,
								const ref AesCore aes_core);
	super.new(name,id);
	this.aes		 = aes_core;
	this.drv = intf_drv;
	this.rcv = intf_rcv;
	
endfunction : new

function void agent_MixColumn:: check_mix_column_result();

	word8 test_matrix[4][`MAXBC];
	test_matrix[0][0] = rcv.b3;
	test_matrix[1][0] = rcv.b2;
	test_matrix[2][0] = rcv.b1;
	test_matrix[3][0] = rcv.b0;
	aes.MixColumn(test_matrix);
	//compare results for encryption
	
	check_mix_c_byte0: assert (test_matrix[0][0] == rcv.a3) 
		else begin
			$display("[%0t] %s:  **ERROR** MixColumn Byte0: %0d(found)!=%0d(expected) ", $time, super.name, rcv.a0,test_matrix[0][0]);	
	    end
	check_mix_c_byte1: assert (test_matrix[1][0] == rcv.a2)
		else begin
			$display("[%0t] %s:  **ERROR** MixColumn Byte1: %0d(found)!=%0d(expected) ", $time, super.name, rcv.a1,test_matrix[1][0]);	
	    end
	check_mix_c_byte2: assert (test_matrix[2][0] == rcv.a1)
		else begin
			$display("[%0t] %s:  **ERROR** MixColumn Byte2: %0d(found)!=%0d(expected) ", $time, super.name, rcv.a2,test_matrix[2][0]);	
	    end
	check_mix_c_byte3: assert (test_matrix[3][0] == rcv.a0)
		else begin
			$display("[%0t] %s:  **ERROR** MixColumn Byte3: %0d(found)!=%0d(expected) ", $time, super.name, rcv.a3,test_matrix[3][0]);	
	    end

endfunction: check_mix_column_result

task agent_MixColumn :: run();

	
	int unsigned i;

	$display("[%0t] %s Start Run", $time, super.name);
	
	for ( i = 0; i <= 20; i++) begin
		drv.b0 <= i[7:0];
		drv.b1 <= i[15:8];
		drv.b2 <= i[23:16];
		drv.b3 <= i[31:24];
		#10;
		check_mix_column_result();
	end
	$display("[%0t] %s End Run", $time, super.name);
endtask: run