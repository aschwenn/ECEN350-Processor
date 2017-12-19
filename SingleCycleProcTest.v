`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:43:49 03/10/2009
// Design Name:   SingleCycleProc
// Module Name:   E:/350/Lab10/SingleCycleProc/SingleCycleProcTest.v
// Project Name:  SingleCycleProc
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SingleCycleProc
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2
module SingleCycleProcTest_v;

   // These tasks are used to check if a given test has passed and
   // confirm that all tests passed.
   task passTest;
      input [63:0] actualOut, expectedOut;
      input [`STRLEN*8:0] testType;
      inout [7:0] 	  passed;
      
      if(actualOut == expectedOut) begin $display ("%s passed", testType); passed = passed + 1; end
      else $display ("%s failed: 0x%x should be 0x%x", testType, actualOut, expectedOut);
   endtask
   
   task allPassed;
      input [7:0] passed;
      input [7:0] numTests;
      
      if(passed == numTests) $display ("All tests passed");
      else $display("Some tests failed: %d of %d passed", passed, numTests);
   endtask
   
   // Inputs
   reg 		  CLK;
   reg 		  Reset_L;
   reg [63:0] 	  startPC;
   reg [7:0] 	  passed;
   reg [15:0] 	  watchdog;
 	  

   
   // Outputs
   wire [63:0] 	  dMemOut;
   wire [63:0] 	  currentPC;
 	  
   
   // Instantiate the Unit Under Test (UUT)
   SingleCycleProc uut (
			.CLK(CLK), 
			.Reset_L(Reset_L), 
			.startPC(startPC),
			.currentPC(currentPC),
			.dMemOut(dMemOut)
			);
   
   initial begin
      // Initialize Inputs
      Reset_L = 1;
      startPC = 0;
      passed = 0;

      // Initialize Watchdog timer
      watchdog = 0;
      
      
      // Wait for global reset
      #(1 * `ClockPeriod);
      
      // Program 1
      #1
	Reset_L = 0; startPC = 0;
      #(1 * `ClockPeriod);
      Reset_L = 1;

      // ***********************************************************
      // This while loop will continue cycling the processor until the
      // PC reaches the final instruction in the first test.  If the
      // program forms an infinite loop, never reaching the end, the
      // watchdog timer will kick in and kill simulation after 64K
      // cycles.
      // ***********************************************************

      while (currentPC < 64'h30)
	begin
	   #(1 * `ClockPeriod);
	   $display("CurrentPC:%h",currentPC);
	   
	end
      #(1 * `ClockPeriod);	// One more cycle to load the pass
				// code from the DataMemory.
      passTest(dMemOut, 64'hF, "Results of Program 1", passed);

      // ***********************************************************
      // Add your new tests here
      // ***********************************************************
	while (currentPC < 64'h68)
	begin
		#(1 * `ClockPeriod);
		$display("CurrentPC:%h",currentPC);
	end
	#(1 * `ClockPeriod);
	passTest(dMemOut, 64'h123456789abcdef0, "Results of Program 2", passed);
      // ...

      
      // Done
      allPassed(passed, 2); 	// Be sure to change the one to match
				// the number of tests you add.
      $finish;
   end
   
   initial begin
      CLK = 0;
   end
   
   // The following is correct if clock starts at LOW level at StartTime //
   always begin
      #`HalfClockPeriod CLK = ~CLK;
      #`HalfClockPeriod CLK = ~CLK;
      watchdog = watchdog +1;
     
   end

   // Kill the simulation if the watchdog hits 64K cycles
   always @*
     if (watchdog == 16'hFFFF)
     begin
     	$display("Watchdog Timer Expired.");
       $finish;
     end
   
   
endmodule

