module Transposition_TB;


// REGISTER DECLARATIONS
//
reg Clock, ClearAll = 1'b0;
reg [2:0] Operation = 3'b000;
// Matrix A Incoming Values
reg signed [31:0] Column1 = 4,
        Column2 = 1, Column3 = 1, Column4 = 1;   // Outgoing ROW for Matrix A


// WIRE DECLARATIONS
//
wire Error, Done;
wire signed [31:0] NewRow1, NewRow2, NewRow3, NewRow4;

Transposition ALU6(.Clock(Clock), .Operation(Operation), .ClearAll(ClearAll),
        .Column1(Column1), .Column2(Column2), .Column3(Column3), .Column4(Column4),
        .Error(Error), .Done(Done), .NewRow1(NewRow1), .NewRow2(NewRow2), .NewRow3(NewRow3), .NewRow4(NewRow4));

initial begin
        Clock = 0;
        forever #10 Clock = !Clock;
end

initial	fork
        #20 Operation <= 3'b100;
join

endmodule
