/////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Mihai Olaru
// 
// Create Date: 02/18/2019 02:52:17 PM
// Design Name: BaseUnit
// Module Name: BaseUnit.sv
// Project Name: AES - Crypto
// Target Devices: 
// Tool Versions: 
// Description: BaseUnit class
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

class BaseUnit;
  
   string name;
   int id;

   function new (string name, int id);
      this.name = name;
      this.id = id;
   endfunction: new

   function void display_name(int id);
     $display("%s",name);
   endfunction: display_name

   virtual task run();
   endtask: run
 
endclass: BaseUnit

 
