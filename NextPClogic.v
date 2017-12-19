`timescale 1ns / 1ps

module NextPClogic(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);

input [63:0] CurrentPC, SignExtImm64;
input Branch, ALUZero, Uncondbranch;
output reg [63:0] NextPC;

// additions with constants should have a delay of 1
// general addition should have a delay of 2
// multiplexers should have a delay of 1 (including statements inside if/else statements

always @ (*)
begin
	#1; // for using mux
	if (Uncondbranch)
		NextPC <= #2 CurrentPC + (SignExtImm64<<2);
	else if (Branch)
	begin
		if (ALUZero) // CBZ = true, add immediate
			NextPC <= #2 CurrentPC + (SignExtImm64<<2);
		else
			NextPC <= #1 CurrentPC + 4;
	end
	else NextPC <= #1 CurrentPC + 4;
end

endmodule
