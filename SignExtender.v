`timescale 1ns / 1ps

module SignExtender(BusImm, Inst);

input [31:0] Inst; // 32-bit instruction
output reg [63:0] BusImm;

always @ (*)
begin
	// B-types
	if (Inst[31:26] == 6'b000101 || Inst[31:26] == 6'b100101)
		BusImm = {{38{Inst[25]}}, Inst[25:0]}; // sign extends
	// CB-types
	else if (Inst[31:24] == 8'b01010100) // B.cond
		BusImm = {{45{Inst[23]}}, Inst[23:5]};
	else if (Inst[31:24] == 8'b10110100 || Inst[31:24] == 8'b10110101) // CBZ/CBNZ
		BusImm = {{45{Inst[23]}}, Inst[23:5]};
	// D-types
	else if (Inst[31:21] == 11'b00111_000000 || // STURB
		Inst[31:21] == 11'b00111_000010 || // LDURB
		Inst[31:21] == 11'b01111_000000 || // STURH
		Inst[31:21] == 11'b01111_000010 || // LDURH
		Inst[31:21] == 11'b10111_000000 || // STURW
		Inst[31:21] == 11'b10111_000100 || // LDURSW
		Inst[31:21] == 11'b11001_000000 || // STXR
		Inst[31:21] == 11'b11001_000010 || // LDXR
		Inst[31:21] == 11'b11111_000000 || // STUR
		Inst[31:21] == 11'b11111_000010) // LDUR
		BusImm = {{55{Inst[20]}}, Inst[20:12]};
	// ORRI	
	else if (Inst[31:22] == 10'b1011001000)
		BusImm = {{52{1'b0}}, Inst[21:10]};
	// LSL
	else if (Inst[31:21] == 11'b11010011011)
	begin
		BusImm = {{58{1'b0}}, Inst[15:10]};
		//$display("LSL BUS: %d", BusImm); // just checking
	end
	else
		BusImm = {64{1'b0}}; // else case, fill with zeros
end

endmodule
