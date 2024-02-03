module round_constants(i,Rcon);
input [3:0] i;
wire [7:0] b;
output [7:0] Rcon;

assign b[0] = (~i[2])&(~i[1])&(~i[0]);
assign b[1] = (i[3] & (~i[2]) & (~i[1])) | ((~i[2]) & (~i[1]) & i[0]);
assign b[2] = ((i[3] & (~i[1]) & i[0]) | ((~i[2]) & i[1] & (~i[0])));
assign b[3] = ((i[3] & (~i[2]) & (~i[0])) | (i[3] & (~i[2]) & i[1]) | ((~i[2]) & i[1] & i[0])); 
assign b[4] = ((i[3] & i[0]) | (i[3] & (~i[1])) | (i[2] & (~i[1]) & (~i[0])));
assign b[5] = ((i[2] & (~i[1]) & i[0]) | (i[3] &(~i[1]) & i[0]) | (i[3] & i[1] & (~i[0])));
assign b[6] = ((i[3] & i[1]) | (i[2] & i[1] & (~i[0])));
assign b[7] = (i[2] & i[1] & i[0]) | (i[3] & i[1] & i[0]);

assign Rcon = b;
endmodule
