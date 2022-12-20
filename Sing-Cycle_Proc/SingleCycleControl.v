`define OPCODE_ANDREG 11'b?0001010???
`define OPCODE_ORRREG 11'b?0101010???
`define OPCODE_ADDREG 11'b?0?01011???
`define OPCODE_SUBREG 11'b?1?01011???

`define OPCODE_ADDIMM 11'b?0?10001???
`define OPCODE_SUBIMM 11'b?1?10001???

`define OPCODE_MOVZ   11'b110100101??

`define OPCODE_B      11'b?00101?????
`define OPCODE_CBZ    11'b?011010????

`define OPCODE_LDUR   11'b??111000010
`define OPCODE_STUR   11'b??111000000


module control(
	       output reg 	reg2loc,
	       output reg 	alusrc,
	       output reg 	mem2reg,
	       output reg 	regwrite,
	       output reg 	memread,
	       output reg 	memwrite,
	       output reg 	branch,
	       output reg 	uncond_branch,
	       output reg [3:0] aluop,
	       output reg [2:0] signop,
	       input [10:0] 	opcode
	       );

   always @(*)
     begin
	casez (opcode)

          /* Add cases here for each instruction your processor supports */
          
          // MOVZ
	     `OPCODE_MOVZ: // Modified the ADD instruction
               begin
                    reg2loc       = 1'bx; // changed
                    uncond_branch = 1'b0; 
                    branch        = 1'b0;
                    memread       = 1'b0;
                    mem2reg       = 1'b0;
                    memwrite      = 1'b0;
                    alusrc        = 1'b1; // changed
                    regwrite      = 1'b1;
                    aluop         = 4'b0111; // passb

                    signop        = opcode[2:0]; // changed
               end

          //11'b10001010000: // AND
	     `OPCODE_ANDREG:
               begin
                    reg2loc       = 1'b0;
                    uncond_branch = 1'b0;
                    branch        = 1'b0;
                    memread       = 1'b0;
                    mem2reg       = 1'b0;
                    memwrite      = 1'b0;
                    alusrc        = 1'b0;
                    regwrite      = 1'b1;
                    aluop         = 4'b0000;

                    signop        = 3'bxxx; 
               end

          //11'b10101010000: // OR
	     `OPCODE_ORRREG:
               begin
                    reg2loc       = 1'b0;
                    uncond_branch = 1'b0;
                    branch        = 1'b0;
                    memread       = 1'b0;
                    mem2reg       = 1'b0;
                    memwrite      = 1'b0;
                    alusrc        = 1'b0;
                    regwrite      = 1'b1;
                    aluop         = 4'b0001;

                    signop        = 3'bxxx; 
               end

          //11'b10001011000: // ADD
	     `OPCODE_ADDREG:
               begin
                    reg2loc       = 1'b0;
                    uncond_branch = 1'b0;
                    branch        = 1'b0;
                    memread       = 1'b0;
                    mem2reg       = 1'b0;
                    memwrite      = 1'b0;
                    alusrc        = 1'b0;
                    regwrite      = 1'b1;
                    aluop         = 4'b0010;

                    signop        = 3'bxxx; 
               end

          //11'b11001011000: // SUB
	     `OPCODE_SUBREG:
               begin
                    reg2loc       = 1'b0;
                    uncond_branch = 1'b0;
                    branch        = 1'b0;
                    memread       = 1'b0;
                    mem2reg       = 1'b0;
                    memwrite      = 1'b0;
                    alusrc        = 1'b0;
                    regwrite      = 1'b1;
                    aluop         = 4'b0110;

                    signop        = 3'bxxx; 
               end

          //11'b11111000010: // LDUR
	     `OPCODE_LDUR:
               begin
                    reg2loc       = 1'bx;
                    uncond_branch = 1'b0;
                    branch        = 1'b0;
                    memread       = 1'b1;
                    mem2reg       = 1'b1;
                    memwrite      = 1'b0;
                    alusrc        = 1'b1;
                    regwrite      = 1'b1;
                    aluop         = 4'b0010;

                    signop        = 3'b010; 
               end

          //11'b11111000000: // STUR
	     `OPCODE_STUR:
               begin
                    reg2loc       = 1'b1;
                    uncond_branch = 1'b0;
                    branch        = 1'b0;
                    memread       = 1'b0;
                    mem2reg       = 1'bx;
                    memwrite      = 1'b1;
                    alusrc        = 1'b1;
                    regwrite      = 1'b0;
                    aluop         = 4'b0010;

                    signop        = 3'b010; //00 or 01
               end

          //11'b10110100111 | 11'b10110100000: // CBZ
	     `OPCODE_CBZ:       
               begin
                    reg2loc       = 1'b1;
                    uncond_branch = 1'b0;
                    branch        = 1'b1;
                    memread       = 1'b0;
                    mem2reg       = 1'bx;
                    memwrite      = 1'b0;
                    alusrc        = 1'b0;
                    regwrite      = 1'b0;
                    aluop         = 4'b0111; 

                    signop        = 3'b001; 
               end   

          //11'b00010100000 | 11'b00010111111: // B
	     `OPCODE_B: // branch is having issues, as the control is going to 'default', thus the loop is not operating
               begin
                    reg2loc       = 1'bx;
                    uncond_branch = 1'b1;
                    branch        = 1'bx;
                    memread       = 1'b0;
                    mem2reg       = 1'bx;
                    memwrite      = 1'b0;
                    alusrc        = 1'bx;
                    regwrite      = 1'b0;
                    aluop         = 4'b0111;

                    signop        = 3'b000; 
               end   
          
          default:
               begin
                    reg2loc       = 1'bx;
                    alusrc        = 1'bx;
                    mem2reg       = 1'bx;
                    regwrite      = 1'b0;
                    memread       = 1'b0;
                    memwrite      = 1'b0;
                    branch        = 1'b0;
                    uncond_branch = 1'b0;
                    aluop         = 4'bxxxx;
                    signop        = 3'bxxx;
               end
          
	endcase
     end

endmodule

