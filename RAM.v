/*
File Name: RAM.v
Date of Creation: November 25, 2018
Author: Caden Sanders
Project: Matrix Math Unit for Final Assignment
Course: Digital System Design using HDL [EE4321]
Professor: Mr. Mark Welker
School: Texas State University - San Marcos

Read and write operations for memory. Memory size is 256 words of

        *** Read when (ReadWrite==0) ***
        *** Write when (ReadWrite==1) ***

IO Visualization
	Input from ALU_Control:
		RowX from Matrix - [InColumn1, InColumn2, InColumn3, InColumn4]

	Output to ALU_Control:
		RowX for Matrix - [OutColumn1, OutColumn2, OutColumn3, OutColumn4]
*/


module RAM(
        Clock, Enable, ReadWrite, AddressSelect, InColumn1, InColumn2,
        InColumn3, InColumn4,

        OutColumn1, OutColumn2, OutColumn3, OutColumn4, Done
);


// INPUT PORT DECLARATIONS
//
input Clock, Enable, ReadWrite;
input [31:0] AddressSelect;
input [31:0] InColumn1,
        InColumn2, InColumn3, InColumn4;        // Incoming Word


// OUPUT PORT DECLARATIONS
//
output [31:0] OutColumn1,
        OutColumn2, OutColumn3, OutColumn4;     // Outgoing Word
output Done;


// WIRE DECLARATIONS
//
wire Clock, Enable, ReadWrite;                  // inputs
wire [31:0] AddressSelect;                       // input
wire signed [31:0] InColumn1,
        InColumn2, InColumn3, InColumn4;        // inputs


// REGISTER DECLARATIONS
//
reg signed [31:0] OutColumn1,
        OutColumn2, OutColumn3, OutColumn4;     // outputs
// 2D Memory of 32-bit signed integers.
// Each word is 4 integers and represents a row of a matrix.
reg signed [31:0] Memory [3:0] [255:0];
reg Done;


// BEHAVIORAL CODE
//
always @(posedge Clock) begin
        if (Enable==1'b1) begin
                if(ReadWrite==1'b1) begin
                        // Write
                        Memory[0][AddressSelect*4] <= InColumn1;
                        Memory[1][(AddressSelect*4)+1] <= InColumn2;
                        Memory[2][(AddressSelect*4)+2] <= InColumn3;
                        Memory[3][(AddressSelect*4)+3] <= InColumn4;
                        Done <= 1'b1;
                end else if(ReadWrite==1'b0) begin
                        //Read
                        OutColumn1 <= Memory[0][AddressSelect*4];
                        OutColumn2 <= Memory[1][(AddressSelect*4)+1];
                        OutColumn3 <= Memory[2][(AddressSelect*4)+2];
                        OutColumn4 <= Memory[3][(AddressSelect*4)+3];
                        Done <= 1'b1;
                end
        end else begin
                Done <= 1'b0;
        end
end

//
// END OF MODULE
endmodule
