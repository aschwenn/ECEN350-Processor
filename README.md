# ECEN350-Processor
Simple ARMv8 processor implemented using Verilog (single cycle and pipelined)

The master branch contains the single cycle implementation of this datapath. Each functional unit has its own file. A test bench file SingleCycleProcTest.v is included which runs two programs to test the datapath. The instructions are saved in the InstructionMemory.v file, which contains a list of hexadecimal instructions "saved" at different addresses in memory (comments are included showing the actual instructions). Similarly, the pipeline branch contains the pipelined implementation of this datapath, which cuts down on the total number of cycles required because of the pipelined approach. It does not include data forwarding or hazard detection, so NOP instructions are used to prevent data hazards. These NOP instructions are defined as ADD XZR, XZR, XZR.

Code is based on files provided from Dr. Sprintson and TAs.

PLEASE NOTE: This work was completed by myself in Fall 2017. I am uploading this for educational purposes only. Remember, an Aggie does not lie, cheat, or steal, or tolerate those that do. Do not attempt to copy my code.
