module NextPClogic(NextPC, CurrentPC, SignExtImm64, Branch, ALUZero, Uncondbranch); 

   input [63:0] CurrentPC, SignExtImm64; 
   input 	Branch, ALUZero, Uncondbranch; 
   output reg [63:0] NextPC; 
   
   
   // Instructions:
   // SignExtendImm64 is the output of the sign extender
   // branch is true if the current instructon is a condition branch
   // If unconditional is true, the current instruction us Unconditional.
   // Branch and ALUZero is the zero output of the ALU
   
   // Possible Test Cases:
   
   // For B (unconditional branch), UncondBranch == 1 and ALUZero == 1, B == X
      // NextPC = PC + SignExtImm64
   // For CB (conditional branch), UncondBranch == X and ALUZero == 0, B == 1
      // NextPC = PC + SignExtImm64

   // Else 
      // NextPC = PC + 4
      
   // Branch, ALU, UnConditionalBranch
   always @(*) begin 
      if( (Uncondbranch == 1'b1) || (ALUZero == 1'b1 && Branch == 1'b1) ) 
         begin 
            NextPC = CurrentPC + (SignExtImm64);
            //$display("NextPC:%h",NextPC);

         end
      else
         begin 
            NextPC = CurrentPC + 64'b100;
         end
   end
// 110 should not have branched
endmodule
