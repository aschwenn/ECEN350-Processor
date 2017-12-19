`timescale 1ns/ 1ps

module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
	output [63:0] BusA;
	output [63:0] BusB;
	input [63:0] BusW;
	input [4:0] RA, RB, RW; // 5-bits to represent which register
	input RegWr;
	input Clk;
	reg [63:0] registers [31:0]; // 32 separate 64-bit registers

	// assign bus outputs
	assign #2 BusA = registers[RA];
	assign #2 BusB = registers[RB];

	initial
	begin
		registers[31] <= 64'b0;
	end
     
	always @ (negedge Clk)
	begin
		if(RegWr && RW != 5'b11111) // checks if reg writing is allowed
		registers[RW] <= #3 BusW;
	end

	always @ (*)
	begin
		registers[31] <= {64{1'b0}}; // set register 31 equal to 0
	end
endmodule
