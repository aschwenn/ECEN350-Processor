`timescale 1ns / 1ps

module ALUControl(ALUCtrl, ALUop, Opcode);

input [1:0] ALUop;
input [10:0] Opcode;
output reg [3:0] ALUCtrl;

always @ (*)
begin
	ALUCtrl <= 4'b1; // initialize
	if (ALUop == 2'b00) // D-types
		ALUCtrl <= #2 4'b0010;
	if (ALUop == 2'b01) // B-types
		ALUCtrl <= #2 4'b0111;
	if (ALUop == 2'b10)
	begin // R-types
		if (Opcode == 11'b10001011000)
			ALUCtrl <= #2 4'b0010;
		if (Opcode == 11'b11001011000)
			ALUCtrl <= #2 4'b0110;
		if (Opcode == 11'b10001010000)
			ALUCtrl <= #2 4'b0000;
		if (Opcode == 11'b10101010000)
			ALUCtrl <= #2 4'b0001;
		if (Opcode[10:1] == 10'b1011001000) // ORRI instruction: grab the first 10 bits
		begin
			ALUCtrl <= #2 4'b0001; // ORR ALUControl
			//$display("we got an ORRI");
		end
		if (Opcode == 11'b11010011011) // LSL instruction
		begin
			ALUCtrl <= #2 4'b0011; // LSL ALUControl
			//$display("we got an LSL");
		end
	end


end

endmodule
