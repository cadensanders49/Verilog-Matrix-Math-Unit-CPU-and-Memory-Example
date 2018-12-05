/*
File Name: Matrix_Multiplicator.v
Date of Creation: November 25, 2018
Author: Caden Sanders
Project: Matrix Math Unit for Final Assignment
Course: Digital System Design using HDL [EE4321]
Professor: Mr. Mark Welker
School: Texas State University - San Marcos

Verilog sequential file for a 4-bit row-by-row version of a matrix
multiplicator. This module will receive input, one row at a time, from
ALU_Control to be processed.

IO Visualization
	Input from ALU_Control:
		RowX from Matrix A - [ColumnA1, ColumnA2, ColumnA3, ColumnA4]
		ColumnX from Matrix B -  __        __
					|   RowB1   |
					|   RowB2   |
					|   RowB3   |
					|__ RowB4 __|

	Output to ALU_Control:
		RowX for New Matrix - [NewColumn1, NewColumn2, NewColumn3, NewColumn4]
*/

module Matrix_Multiplicator(

	Clock, Operation, ClearAll, ColumnA1, ColumnA2, ColumnA3, ColumnA4,
	RowB1, RowB2, RowB3, RowB4, Enable,

	Error, Done, Result
);

// INPUT PORT DECLARATIONS
//
input Clock, ClearAll, Enable;
input [2:0] Operation;
input [31:0] ColumnA1,
	ColumnA2, ColumnA3, ColumnA4;	// Incoming ROW from Matrix A
input [31:0] RowB1,
	RowB2, RowB3, RowB4;		// Incoming COLUMN from Matrix B


// OUPUT PORT DECLARATIONS
//
output Error, Done;
output [31:0] Result;	// Outgoing element to New Matrix


// WIRE DECLARATIONS
//
wire Clock, ClearAll, Enable;           //inputs
wire [2:0] Operation;   		//input
wire signed [31:0] ColumnA1,
	ColumnA2, ColumnA3, ColumnA4;  	//inputs
wire signed [31:0] RowB1,
	RowB2, RowB3, RowB4;  		//inputs


// REGISTER DECLARATIONS
//
reg Error = 1'b0, Done = 1'b0;	//outputs
reg signed [31:0] Result;  	//output


// BEHAVIORAL CODE
//
always @(posedge Clock, posedge ClearAll) begin
 	if (ClearAll) begin
   		Result <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		Done <= 1'b0;
    		Error <= 1'b0;
  	end else if (Operation==3'b101 && Enable) begin
    		Result <= (ColumnA1 * RowB1) + (ColumnA2 * RowB2) +
        		(ColumnA3 * RowB3) + (ColumnA4 * RowB4);
    		Done <= 1'b1;
  	end else begin
    		#2 Done <= 1'b0;
  	end
end

//
// END OF MODULE
endmodule
