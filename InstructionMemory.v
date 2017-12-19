`timescale 1ns / 1ps
/*
 * Module: InstructionMemory
 *
 * Implements read-only instruction memory
 * 
 */
module InstructionMemory(Data, Address);
   parameter T_rd = 20;
   parameter MemSize = 40;
   
   output [31:0] Data;
   input [63:0]  Address;
   reg [31:0] 	 Data;
   
   /*
    * ECEN 350 Processor Test Functions
    * Texas A&M University
    */
   
   always @ (Address) begin
      case(Address)

	/* Test Program 1:
	 * Program loads constants from the data memory. Uses these constants to test
	 * the following instructions: LDUR, ORR, AND, CBZ, ADD, SUB, STUR and B.
	 * 
	 * Assembly code for test:
	 * 
	 * 0: LDUR X9, [XZR, 0x0]    //Load 1 into x9
	 * 4: LDUR X10, [XZR, 0x8]   //Load a into x10
	 * 8: LDUR X11, [XZR, 0x10]  //Load 5 into x11
	 * C: LDUR X12, [XZR, 0x18]  //Load big constant into x12
	 * 10: LDUR X13, [XZR, 0x20]  //load a 0 into X13
	 * 
	 * 14: ORR X10, X10, X11  //Create mask of 0xf
	 * 18: AND X12, X12, X10  //Mask off low order bits of big constant
	 * 
	 * loop:
	 * 1C: CBZ X12, end  //while X12 is not 0
	 * 20: ADD X13, X13, X9  //Increment counter in X13
	 * 24: SUB X12, X12, X9  //Decrement remainder of big constant in X12
	 * 28: B loop  //Repeat till X12 is 0
	 * 2C: STUR X13, [XZR, 0x20]  //store back the counter value into the memory location 0x20
	 */
	

	63'h000: Data = 32'hF84003E9;
	63'h004: Data = 32'hF84083EA;
	63'h008: Data = 32'hF84103EB;
	63'h00c: Data = 32'hF84183EC;
	63'h010: Data = 32'hF84203ED;
	63'h014: Data = 32'hAA0B014A;
	63'h018: Data = 32'h8A0A018C;
	63'h01c: Data = 32'hB400008C;
	63'h020: Data = 32'h8B0901AD;
	63'h024: Data = 32'hCB09018C;
	63'h028: Data = 32'h17FFFFFD;
	63'h02c: Data = 32'hF80203ED;
	63'h030: Data = 32'hF84203ED;  //One last load to place stored value on memdbus for test checking.

	/* Add code for your tests here */
	/* Test Program 2:
	 *
	 * 38: ADD X9, XZR, XZR // zero out X9 => 10001011000 11111 000000 11111 01001
	 * 3c: ORRI X9, X9, 0x123 // load first part => 1011001000 0001 0010 0011 01001 01001
	 * 40: LSL X9, X9, #12 // shift over => 11010011011 11111 001100 01001 01001
	 * 44: ORRI X9, X9, 0x456 => 1011001000 0100 0101 0110 01001 01001
	 * 48: LSL X9, X9, #12 // SAME CODE
	 * 4c: ORRI X9, X9, 0x789 => 1011001000 0111 1000 1001 01001 01001
	 * 50: LSL X9, X9, #12 // SAME CODE
	 * 54: ORRI X9, X9, 0xabc => 1011001000 1010 1011 1100 01001 01001
	 * 58: LSL X9, X9, #12 // SAME CODE
	 * 5c: ORRI X9, X9, 0xdef => 1011001000 1101 1110 1111 01001 01001
	 * 60: LSL X9, X9, #4 // shift over => 11010011011 11111 000100 01001 01001
	 * xx: STUR X9, [XZR, 0x28] // store to memory => 11111000000 000101000 00 11111 01001
	 * xx: LDUR X10, [XZR, 0x28] // to check if correct => 11111000010 000101000 00 11111 01010
	 */
	63'h038: Data = 32'h8B1F03E9; // start of tests
	63'h03c: Data = 32'hB2048D29; // 0x123
	63'h040: Data = 32'hD37F3129; // shift
	63'h044: Data = 32'hB2115929; // 0x456
	63'h048: Data = 32'hD37F3129; // shift
	63'h04c: Data = 32'hB21E2529; // 0x789
	63'h050: Data = 32'hD37F3129; // shift
	63'h054: Data = 32'hB22AF129; // 0xabc
	63'h058: Data = 32'hD37F3129; // shift
	63'h05c: Data = 32'hB237BD29; // 0xdef
	63'h060: Data = 32'hD37F1129; // shift 4

	63'h064: Data = 32'hF80283E9;
	63'h068: Data = 32'hF84283EA;
// */
			
	default: Data = 32'hXXXXXXXX;
      endcase
   end
endmodule
