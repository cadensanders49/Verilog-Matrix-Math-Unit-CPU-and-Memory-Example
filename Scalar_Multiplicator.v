/*
File Name: Scalar_Multiplicator.v
Date of Creation: November 25, 2018
Author: Caden Sanders
Project: Matrix Math Unit for Final Assignment
Course: Digital System Design using HDL [EE4321]
Professor: Mr. Mark Welker
School: Texas State University - San Marcos

Verilog sequential file for a 4-bit multiplicator. This module will receive
input from ALU_Control.v to be processed.

IO Visualization
	Input from ALU_Control:
		RowX from Matrix A - [ColumnA1, ColumnA2, ColumnA3, ColumnA4]
		RowX from Matrix B - [ColumnB1, ColumnB2, ColumnB3, ColumnB4]

	Output to ALU_Control:
		RowX for New Matrix - [NewColumn1, NewColumn2, NewColumn3, NewColumn4]
*/

module Scalar_Multiplicator(

	Clock, Operation, ClearAll, ColumnA1, ColumnA2, ColumnA3, ColumnA4,
	ColumnB1, ColumnB2, ColumnB3, ColumnB4, Enable,

	Error, Done, NewColumn1, NewColumn2, NewColumn3, NewColumn4
);


// INPUT PORT DECLARATIONS
//
input Clock, ClearAll, Enable;
input [2:0] Operation;
input [31:0] ColumnA1,
	ColumnA2, ColumnA3, ColumnA4;	// Incoming ROW from Matrix A
input [31:0] ColumnB1,
	ColumnB2, ColumnB3, ColumnB4;	// Incoming ROW from Matrix B


// OUPUT PORT DECLARATIONS
//
output Error, Done;
output [31:0] NewColumn1,
	NewColumn2, NewColumn3, NewColumn4;	//Outgoing Row to New Matrix


// WIRE DECLARATIONS
//
wire Clock, ClearAll, Enable;			//inputs
wire [2:0] Operation;   		//input
wire signed [31:0] ColumnA1,
	ColumnA2, ColumnA3, ColumnA4,
	ColumnB1, ColumnB2, ColumnB3,
	ColumnB4;  			//inputs


// REGISTER DECLARATIONS
//
reg Error = 1'b0, Done = 1'b0;             	//outputs
reg signed [31:0] NewColumn1,
	NewColumn2, NewColumn3, NewColumn4;  	//outputs


// BEHAVIORAL CODE
//
always @(posedge Clock, posedge ClearAll) begin
	if (ClearAll) begin
   		NewColumn1 <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		NewColumn2 <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		NewColumn3 <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		NewColumn4 <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		Done <= 1'b0;
    		Error <= 1'b0;
  	end else if (Operation==3'b100 && Enable) begin
    		NewColumn1 <= ColumnA1 * ColumnB1;
    		NewColumn2 <= ColumnA2 * ColumnB2;
    		NewColumn3 <= ColumnA3 * ColumnB3;
    		NewColumn4 <= ColumnA4 * ColumnB4;
    		Done <= 1'b1;
  	end else begin
    		#2 Done <= 1'b0;
  	end
end

//
// END OF MODULE
endmodule
