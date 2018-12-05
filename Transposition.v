/*
File Name: Transposition.v
Date of Creation: November 25, 2018
Author: Caden Sanders
Project: Matrix Math Unit for Final Assignment
Course: Digital System Design using HDL [EE4321]
Professor: Mr. Mark Welker
School: Texas State University - San Marcos

Verilog sequential file for transposition. This module will receive input
from ALU_Control.v to be processed.

IO Visualization
	Input from ALU_Control:
		RowX from Matrix A - [Column1, Column2, Column3, Column4]

	Output to ALU_Control:
		RowX for New Matrix - [NewColumn1, NewColumn2, NewColumn3, NewColumn4]

	Output to ALU_Control:
		Element for New Matrix - [Result]
*/

module Transposition(

	Clock, Operation, ClearAll, Column1, Column2, Column3, Column4, Enable,

	Error, Done, NewRow1, NewRow2, NewRow3, NewRow4
);


// INPUT PORT DECLARATIONS
//
input Clock, ClearAll, Enable;
input [2:0] Operation;
input [31:0] Column1,
	Column2, Column3, Column4;	// Incoming ROW from Matrix A


// OUPUT PORT DECLARATIONS
//
output Error, Done;
output [31:0] NewRow1,
	NewRow2, NewRow3, NewRow4;	//Outgoing Column to New Matrix


// WIRE DECLARATIONS
//
wire Clock, ClearAll, Enable;			//inputs
wire [2:0] Operation;   		//input
wire signed [31:0] Column1,
	Column2, Column3, Column4;  //inputs


// REGISTER DECLARATIONS
//
reg Error = 1'b0, Done = 1'b0;		//outputs
reg signed [31:0] NewRow1,
	NewRow2, NewRow3, NewRow4;	//outputs


// BEHAVIORAL CODE
//
always @(posedge Clock, posedge ClearAll) begin
  	if (ClearAll) begin
    		NewRow1 <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		NewRow2 <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		NewRow3 <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		NewRow4 <= 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
    		Done <= 1'b0;
    		Error <= 1'b0;
  	end else if (Operation==3'b100 && Enable) begin
    		NewRow1 <= Column1;
    		NewRow2 <= Column2;
    		NewRow3 <= Column3;
    		NewRow4 <= Column4;
    		Done <= 1'b1;

  	end else begin
    		#2 Done <= 1'b0;
  	end
end

//
// END OF MODULE
endmodule
