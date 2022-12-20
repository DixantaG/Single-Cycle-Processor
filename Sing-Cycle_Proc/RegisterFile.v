module RegisterFile(BusA, BusB, BusW, RA, RB, RW, RegWr, Clk);
    // Register Values Read
    output [63:0] BusA;
    output [63:0] BusB;

    input [4:0] RA; // Register to Read from
    input [4:0] RB; // Register to Read from
    input [4:0] RW; // Specifies register to write to 

    input [63:0] BusW; // Data to write

    input RegWr; // when set to 1, data on BusW is stored in the register specified by RW on the falling clock edge

    input Clk;
    
    // 32, 64-bit registers
    reg [63:0] registers [31:0]; 

    // Data from registers specified by RA and RB is sent on these busses after a delay of 2 tics
    assign #2 BusA = RA == 31 ? 0:registers[RA];
    assign #2 BusB = RB == 31 ? 0:registers[RB];

    // When RegWr is set to 1, data in BusW is stored on NEGATIVE clock edge
    always @ (negedge Clk) begin
        if(RegWr) begin
            // Writes to register file must have 3 tics of delay
            registers[RW] <= #3 BusW; 
            registers[31] <= #3 64'h0; // Bit 31 must always be zero
        end
    end
    
endmodule
