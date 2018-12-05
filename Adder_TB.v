module Adder_TB;

// reg Declarations
reg Clock;
reg [2:0] Operation = 3'b000;
reg ClearAll = 1'b0;
// Matrix A Incoming Values
reg signed [31:0] ColumnA1 = -4;
reg signed [31:0] ColumnA2 = -4;
reg signed [31:0] ColumnA3 = -4;
reg signed [31:0] ColumnA4 = -4;
// Matrix B Incoming Values
reg signed [31:0] ColumnB1 = 10;
reg signed [31:0] ColumnB2 = 10;
reg signed [31:0] ColumnB3 = 10;
reg signed [31:0] ColumnB4 = 10;

// Register Declarations
wire Error;
wire Done;
wire signed [31:0] NewColumn1;
wire signed [31:0] NewColumn2;
wire signed [31:0] NewColumn3;
wire signed [31:0] NewColumn4;

Adder ALU1(.Clock(Clock), .Operation(Operation), .ClearAll(ClearAll),
        .ColumnA1(ColumnA1), .ColumnA2(ColumnA2), .ColumnA3(ColumnA3), .ColumnA4(ColumnA4),
        .ColumnB1(ColumnB1), .ColumnB2(ColumnB2), .ColumnB3(ColumnB3), .ColumnB4(ColumnB4),
        .Error(Error), .Done(Done), .NewColumn1(NewColumn1), .NewColumn2(NewColumn2),
        .NewColumn3(NewColumn3), .NewColumn4(NewColumn4));

initial begin
        Clock = 0;
        forever #10 Clock = !Clock;
end

initial	fork
        #20 Operation <= 3'b010;
join

endmodule
