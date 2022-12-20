//iverilog -o SingleCycleProcTest SingleCycleProcTest.v SingleCycleProc.v ALU.v DataMemory.v InstructionMemory.v NextPClogic.v RegisterFile.v SignExtender.v SingleCycleControl.v

module singlecycle(
		   input 	     resetl,
		   input [63:0]      startpc,
		   output reg [63:0] currentpc,
		   output [63:0]     MemtoRegOut,  // this should be
						   // attached to the
						   // output of the
						   // MemtoReg Mux
		   input 	     CLK
		   );

   // Next PC connections
   wire [63:0] 			     nextpc;       // The next PC, to be updated on clock cycle

   // Instruction Memory connections
   wire [31:0] 			     instruction;  // The current instruction

   // Parts of instruction
   wire [4:0] 			     rd;            // The destination register
   wire [4:0] 			     rm;            // Operand 1
   wire [4:0] 			     rn;            // Operand 2
   wire [10:0] 			     opcode;

   // Control wires
   wire 			     reg2loc;
   wire 			     alusrc;
   wire 			     mem2reg;
   wire 			     regwrite;
   wire 			     memread;
   wire 			     memwrite;
   wire 			     branch;
   wire 			     uncond_branch;
   wire [3:0] 			     aluctrl;
   wire [2:0] 			     signop;

   // Register file output connections
   wire [63:0] 			     regoutA;     // Output A
   wire [63:0] 			     regoutB;     // Output B

   // ALU connections
   wire [63:0] 			     aluout;
   wire 			     zero;

   // Sign Extender connections
   wire [63:0] 			     extimm;

   // PC update logic
   always @(negedge CLK)
     begin
        if (resetl)
          currentpc <= #3 nextpc;
        else
          currentpc <= #3 startpc;
     end

   // Parts of instruction
   assign rd = instruction[4:0];
   assign rm = instruction[9:5];
   assign rn = reg2loc ? instruction[4:0] : instruction[20:16]; // Multiplexor function built in
   assign opcode = instruction[31:21];

   InstructionMemory InstructionMemory(
			  .Data(instruction),
			  .Address(currentpc)
			  );

   control control(
		   .reg2loc(reg2loc),
		   .alusrc(alusrc),
		   .mem2reg(mem2reg),
		   .regwrite(regwrite),
		   .memread(memread),
		   .memwrite(memwrite),
		   .branch(branch),
		   .uncond_branch(uncond_branch),
		   .aluop(aluctrl),
		   .signop(signop),
		   .opcode(opcode)
		   );

   /*
    * Connect the remaining datapath elements below.
    * Do not forget any additional multiplexers that may be required.
    */
  
  /* Modules to Use */

  // RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
  RegisterFile RegisterFile(
    .BusA(regoutA),
    .BusB(regoutB),
    .RA(rm), // Read register 1
    .RB(rn), // Read register 2
    .RW(rd), // Instructon [4:0] always goes to RW

    .BusW(MemtoRegOut), // 64-bits from the mux connexted to ALU and Data Memory

    .RegWr(regwrite),
    .Clk(CLK)
  );

  // SignExtender(BusImm, Imm25, Ctrl); 
  SignExtender SignExtender(
    .BusImm(extimm), // 64-bit output
    .Imm25(instruction[25:0]),  // 24-bit input
    .Ctrl(signop)    // 3-bit input
  );

  // Multiplexor Operation
  wire [63:0] to_ALU_mux;
  assign to_ALU_mux = alusrc ? extimm[63:0] : regoutB [63:0]; 
  // select: alusrc
  // input 0: regoutB
  // input 1: signextended value

  // ALU(BusW, BusA, BusB, ALUCtrl, Zero);
  ALU ALU(
    .BusW(aluout), // 64-bit output as ALU Result
    .BusA(regoutA), // BusA from register file
    .BusB(to_ALU_mux),  // Multiplexed output from reg file and sign extender into ALU
    .ALUCtrl(aluctrl), // ALUop
    .Zero(zero) // 1-bit output
  );

  // NextPClogic NextPClogic(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch);
  // Accounts for AND and OR gates, as well as multiplexor in module
  NextPClogic NextPClogic(
    .NextPC(nextpc), // 64-bit output
    .CurrentPC(currentpc),
    .SignExtImm64(extimm), // output from sign extender
    .Branch(branch),
    .ALUZero(zero), // Output from ALU
    .Uncondbranch(uncond_branch)
  );

  // DataMemory(ReadData , Address , WriteData , MemoryRead , MemoryWrite , Clock);
  wire [63:0] from_data_mem;

  DataMemory DataMemory(
    .ReadData(from_data_mem), // 64-bit output
    .Address(aluout), // ALU result
    .WriteData(regoutB), // BusB from register file
    .MemoryRead(memread),
    .MemoryWrite(memwrite),
    .Clock(CLK)
  );

  assign MemtoRegOut = mem2reg ? from_data_mem [63:0] : aluout[63:0] ; 

endmodule

