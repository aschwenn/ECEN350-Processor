`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 30
`define ClockPeriod `HalfClockPeriod * 2

module PipelinedProcTest_v;

	task passTest;
		input [31:0] actualOut, expectedOut;
		input [`STRLEN*8:0] testType;
		inout [7:0] passed;
	
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
	reg CLK;
	reg Reset_L;
	reg [63:0] startPC;
	reg [7:0] passed;

	// Outputs
	wire [63:0] dMemOut;
	wire [63:0] FetchedPC;
	
	// Watchdog timer to make sure no loop
	reg [15:0] 	  watchdog;
	
	// Instantiate the Unit Under Test (UUT)
	PipelinedProc uut (
		.CLK(CLK), 
		.Reset_L(Reset_L), 
		.startPC(startPC), 
		.dMemOut(dMemOut),
		.FetchedPC(FetchedPC)
	);

	initial begin
		// Initialize Inputs
		Reset_L = 1'b0;
		startPC = 64'b0;
		passed = 8'b0;
		watchdog = 16'b0;
		
		// Wait for some cycles for reset
		#(5 * `ClockPeriod);

		Reset_L = 1'b1; //let the processor go
		
		$display("Current FetchedPC: 0x%H", FetchedPC);
		#(1 * `ClockPeriod); //wait a period
		while(FetchedPC < 64'h058)
		begin
			$display("Current FetchedPC: 0x%H", FetchedPC);
			#(1 * `ClockPeriod);	
		end
		
		/* Load instruction to check if it is correct is in the Fetch Stage.
		   Need to wait for it to be in the WB Stage */
		#(4 * `ClockPeriod);
		passTest(dMemOut, 64'hF, "Results of Program 1", passed);
		
        /* Insert your test here */
        while (FetchedPC < 64'h100)
	begin
		#(1 * `ClockPeriod);
		$display("CurrentPC:%h",FetchedPC);
	end
	#(4 * `ClockPeriod);
	passTest(dMemOut, 64'h123456789abcdef0, "Results of Program 2", passed);
        
        /* Update the number to incorporate your test */
        allPassed(passed, 2);
		$finish;
	end
	  
   initial begin
      CLK = 0;
   end
   
   /* Generate the clock Signal and keep track of the watch dog */
   always
   begin
      #`HalfClockPeriod CLK = ~CLK;
      watchdog = watchdog + 1;
   end

    always@(*)
    begin
        if(watchdog >= 16'hFFFF)
        begin
            $display("Watchdog Timer Expired - Possible Infinite Loop");
            $finish;
        end
    end
endmodule
