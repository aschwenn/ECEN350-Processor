`timescale 1ns/1ps

module PipelinedProc(CLK, Reset_L, startPC, dMemOut, FetchedPC);
	input wire CLK;
	input wire Reset_L;
	input wire [63:0] startPC;
	output wire [63:0] dMemOut; //for testing results
	wire invCLK;
	output wire [63:0] FetchedPC; //for testing results
	
	/* Stage 1 - Instruction Fetch (IF) connections */
	wire [63:0] currentPCPlus4;
	wire [63:0] nextPC;
	reg [63:0] currentPC;
	wire [31:0] instruction;
	
	/* Stage 1/2 - IF/ID Registers */
	reg [63:0] currentPC2;
	reg [31:0] instruction2;
	
	/* Stage 2 - Instruction Decode (ID) connections */
	wire [4:0] RB;
	wire [4:0] RW;
	wire [63:0] BusW;
	wire [63:0] BusA;
	wire [63:0] BusB;
	wire [63:0] SignExtendedImm;
	wire dummyWire; //want to reuse single cycle control, will put output of Reg2Loc here b/c not used
	wire ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, Uncondbranch;
	wire [1:0] ALUOp;
	
	/* Stage 2/3 - ID/EX Registers */
	reg ALUSrc3, MemToReg3, RegWrite3, MemRead3, MemWrite3, Branch3, Uncondbranch3;
	reg [1:0] ALUOp3;
	reg [63:0] currentPC3;
	reg [63:0] BusA3;
	reg [63:0] BusB3;
	reg [63:0] SignExtendedImm3;
	reg [10:0] Opcode3;
	reg [4:0] Rd3; 
	
	/* Stage 3 - EX Connections */
	wire [63:0] shiftedImm;
	wire [63:0] branchAddr;
	wire [63:0] ALUBusB;
	wire [3:0] ALUControlBits;
	wire [63:0] ALUBusW;
	wire ALUZero;
	
	/* Stage 3/4 EX/MEM Registers */
	reg [63:0] branchAddr4;
	reg [63:0] ALUBusW4;
	reg ALUZero4;
	reg [63:0] BusB4;
	reg [4:0] Rd4;
	reg MemToReg4, RegWrite4, MemRead4, MemWrite4, Branch4, Uncondbranch4;
	
	/* Stage 4 - MEM Connections */
	wire [63:0] MemReadBus;
	wire PCSrc;
	
	/* Stage 4/5 MEM/WB Registers */
	reg [63:0] MemReadBus5;
	reg [63:0] ALUBusW5;
	reg [4:0] Rd5;
	reg MemToReg5, RegWrite5;
	
	/* Stage 5 WB Connections */
	wire [63:0] RegBusW;
	
	/* Do some small assignments */
	assign invCLK = ~CLK; //Need Inverted Clock for RegisterFile
	assign dMemOut = MemReadBus5; //look at mem out at the end of the pipeline
	assign FetchedPC = currentPC; //used for testing
	
	/* Stage 1 - IF Logic */
	assign nextPC = PCSrc ? branchAddr4 : currentPCPlus4;
	assign currentPCPlus4 = currentPC + 64'd4;
	always@(negedge CLK)
	begin
		if(~Reset_L)
			currentPC <= startPC;
		else
			currentPC <= nextPC;
	end
	
	InstructionMemory InstMem(.Data(instruction), 
							  .Address(currentPC));
							 
	/* Stage 1/2 - IF/ID Registers */
	
	always@(negedge CLK or negedge Reset_L)
	begin
		if(~Reset_L) /* Reset_L has been deasserted */
		begin
			currentPC2 <= 64'd0;
			instruction2 <= 64'd0;
		end
		else
		begin
			currentPC2 <= currentPC;
			instruction2 <= instruction;
		end
	end
	
	/* Stage 2 - ID Logic */
	
	assign RB = instruction2[28] ? instruction2[4:0] : instruction2[20:16];
	
	RegisterFile RegFile(.BusA(BusA), 
						 .BusB(BusB), 
						 .BusW(RegBusW), 
						 .RA(instruction2[9:5]), 
						 .RB(RB), 
						 .RW(Rd5), 
						 .RegWr(RegWrite5), 
						 .Clk(invCLK));
	
	/* Instantiate and Hook Up your SignExtender */				 
	SignExtender SignExt(.BusImm(SignExtendedImm), .Inst(instruction2));
//********************				  
	SingleCycleControl Control(.Reg2Loc(dummyWire), //Notice using a dummyWire to reuse the single cycle control module 
	                           .ALUSrc(ALUSrc), 
	                           .MemToReg(MemToReg), 
	                           .RegWrite(RegWrite), 
	                           .MemRead(MemRead), 
	                           .MemWrite(MemWrite), 
	                           .Branch(Branch), 
	                           .Uncondbranch(Uncondbranch), 
	                           .ALUOp(ALUOp), 
	                           .Opcode(instruction2[31:21]));
	                           
	/* Stage 2/3 - ID/EX Registers */
	always@(negedge CLK or negedge Reset_L)
	begin
		if(~Reset_L) /* Reset_L has been deasserted */
		begin
			ALUSrc3 <= 1'b0;
			MemToReg3 <= 1'b0;
			RegWrite3 <= 1'b0;
			MemRead3 <= 1'b0;
			MemWrite3 <= 1'b0;
			Branch3 <= 1'b0;
			Uncondbranch3 <= 1'b0;
			ALUOp3 <= 2'b00;
	        currentPC3 <= 64'b0;
	        BusA3 <= 64'd0;
	        BusB3 <= 64'd0;
	        SignExtendedImm3 <= 64'd0;
	        Opcode3 <= 10'b0;
	        Rd3 <= 5'b0; 
		end
		else
		begin
			ALUSrc3 <= ALUSrc;
			MemToReg3 <= MemToReg;
			RegWrite3 <= RegWrite;
			MemRead3 <= MemRead;
			MemWrite3 <= MemWrite;
			Branch3 <= Branch;
			Uncondbranch3 <= Uncondbranch;
			ALUOp3 <= ALUOp;
	        currentPC3 <= currentPC2;
	        BusA3 <= BusA;
	        BusB3 <= BusB;
	        SignExtendedImm3 <= SignExtendedImm;
	        Opcode3 <= instruction2[31:21];
	        Rd3 <= instruction2[4:0]; 
		end
	end
	
	/* Stage 3 - EX Logic */
	
	assign shiftedImm = SignExtendedImm3 << 2;
	assign branchAddr = currentPC3 + shiftedImm;
	assign ALUBusB = ALUSrc3 ? SignExtendedImm3 : BusB3;
	
	/* Instantiate and Hook Up ALU control unit */
	ALUControl ALUCont(.ALUCtrl(ALUControlBits), .ALUop(ALUOp3), .Opcode(Opcode3));
//********************		                   
	ALU ALUunit(.BusW(ALUBusW), 
	            .BusA(BusA3), 
	            .BusB(ALUBusB), 
	            .ALUCtrl(ALUControlBits), 
	            .Zero(ALUZero));
	
	/* Stage 3/4 - EX/MEM Registers */
	always@(negedge CLK or negedge Reset_L)
	begin
	    if(~Reset_L)
	    begin
	        branchAddr4 <= 64'b0;
	        ALUBusW4 <= 64'b0;
	        ALUZero4 <= 1'b0;
	        BusB4 <= 63'b0;
	        Rd4 <= 5'b0;
	        MemToReg4 <= 1'b0;
	        RegWrite4 <= 1'b0;
	        MemRead4 <= 1'b0;
	        MemWrite4 <= 1'b0;
	        Branch4 <= 1'b0;
	        Uncondbranch4 <= 1'b0;
	    end
	    else
	    begin
	        branchAddr4 <= branchAddr;
	        ALUBusW4 <= ALUBusW;
	        ALUZero4 <= ALUZero;
	        BusB4 <= BusB3;
	        Rd4 <= Rd3;
	        MemToReg4 <= MemToReg3;
	        RegWrite4 <= RegWrite3;
	        MemRead4 <= MemRead3;
	        MemWrite4 <= MemWrite3;
	        Branch4 <= Branch3;
	        Uncondbranch4 <= Uncondbranch3;
	    end
	end
	
	/* Stage 4 - MEM Logic */
	
	/* Define PCSrc with an assign statment and a logic expression.
	   You will need to add support for unconditional branches to the processor
	   (The diagram does not have this in it.) */
	assign PCSrc = ((ALUZero4 & Branch4) | Uncondbranch4);
//********************	
	DataMemory DMem(.ReadData(MemReadBus),
	                .Address(ALUBusW4), 
	                .WriteData(BusB4), 
	                .MemoryRead(MemRead4), 
	                .MemoryWrite(MemWrite4), 
	                .Clock(CLK));
	
	/* Stage 4/5 - MEM/WB Registers */
	
	/* Put logic for the MEM/WB Registers. Use previous interstage registers as examples */
	
	always@(negedge CLK or negedge Reset_L)
	begin
	    if(~Reset_L)
	    begin
		MemReadBus5 <= 64'b0;
		ALUBusW5 <= 64'b0;
		Rd5 <= 5'b0;
		MemToReg5 <= 1'b0;
		RegWrite5 <= 1'b0;
	    end
	    else
	    begin
		MemReadBus5 <= MemReadBus;
		ALUBusW5 <= ALUBusW4;
		Rd5 <= Rd4;
		MemToReg5 <= MemToReg4;
		RegWrite5 <= RegWrite4;
	    end
	end
//********************	
	/* Stage 5 - WB Logic */
	
	assign RegBusW = MemToReg5 ? MemReadBus5 : ALUBusW5;
	
endmodule
