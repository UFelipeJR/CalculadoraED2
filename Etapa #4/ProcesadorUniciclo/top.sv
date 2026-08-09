/*
 * This module is the TOP of the ARM single-cycle processor
 */ 
module top(input logic clk, nreset,
			  input logic [9:0] switches,
			  output logic [9:0] leds);
	
	logic clk_slow;
	logic MemWrite, nSyncReset, syncReset;
	logic [31:0] PCNext, Instr, ReadData;
	logic [31:0] WriteData, DataAdr;	
	
	assign syncReset = ~nSyncReset;
	
	cntdiv_n #(8) clk_divider(clk, ~nreset, clk_slow);
	
	mem mem(clk_slow, syncReset, MemWrite, PCNext, DataAdr, WriteData, Instr, ReadData, switches, leds);
	
	arm arm(clk_slow, syncReset, PCNext, Instr, MemWrite, DataAdr, WriteData, ReadData);
	
	flopr #(1) resetReg(clk_slow, ~nreset, 1'b1, nSyncReset);

endmodule