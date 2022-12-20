module SignExtender(BusImm, Imm25, Ctrl); 
   output [63:0] BusImm; 
   input [25:0]  Imm25; 
   input [2:0]Ctrl; 
   
   reg 	 extBit; 
   reg    [63:0] RegBusImm;
   //assign extBit = (Ctrl ? 1'b0 : Imm16[15]); // if Ctrl is 0, then 16 zeros are appendded to the leftmost bits
   //assign BusImm = {{16{extBit}}, Imm16}; 
   
   always @(*)begin
         case(Ctrl)
         
            // B-type
            
            3'b000:
            begin
               extBit = (Imm25[25]); 

               RegBusImm = { {36{extBit}}, Imm25[25:0], 2'b0 }; // Is not adding the right value if negative
               //$display("Imm25[25:0]:%b",Imm25[25:0]);

               //$display("BusImm:%b",RegBusImm);
               //$display("extBit:%b",extBit);

            end
            
            // CB-type
            
            3'b001:
            begin
               //$display("CB Type at PC:%h",Imm25);
               extBit = (Imm25[23]); 
               RegBusImm = { {43{extBit}}, {Imm25[23:5]}, 2'b0 };
            end
            
            // D-type
            
            3'b010:
            begin
               //$display("D Type at PC:%h",Imm25);
               extBit = (Imm25[20]); 
               RegBusImm = {{55{extBit}}, {Imm25[20:12]}}; 
            end
            
            // I-type
            
            3'b011:
            begin
               //$display("I Type at PC:%h",Imm25);
               extBit = (Imm25[21]); 
               RegBusImm = {{52'b0}, {Imm25[21:10]}};
            end   

            // MI-types for MOVZ instruction

            3'b100: // left shift by 0 bits
            begin
               //extBit = 1'bx;
               RegBusImm = {48'b0, Imm25[20:5]};
            end

            3'b101: // left shift by 16 bits
            begin
               //extBit = 1'bx;
               RegBusImm = {32'b0, Imm25[20:5], 16'b0};
            end

            3'b110: // left shift by 32 bits
            begin
               //extBit = 1'bx;
               RegBusImm = {16'b0, Imm25[20:5], 32'b0};
            end

            3'b111: // left shift by 48 bits
            begin
               //extBit = 1'bx;
               RegBusImm = {Imm25[20:5], 48'b0};
            end

            default:
            begin
               //$display("default at PC:%h",Imm25);
               extBit = 1'bx;
               RegBusImm = 64'bx; 
            end

         endcase
      //$display("Ctrl:%h",Ctrl);
      //$display("extBit:%h",extBit);

   end  
   
   assign BusImm = RegBusImm;
endmodule
