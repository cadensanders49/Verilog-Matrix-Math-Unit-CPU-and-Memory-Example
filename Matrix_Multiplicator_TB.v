module Matrix_Multiplicator_TB;

// Register Declarations
reg Clock;
reg [2:0] Operation = 3'b000;
reg ClearAll = 1'b0;
// Matrix A Incoming Values
reg signed [31:0] ColumnA1 = 4;
reg signed [31:0] ColumnA2 = 1;
reg signed [31:0] ColumnA3 = 1;
reg signed [31:0] ColumnA4 = 1;
// Matrix B Incoming Values
reg signed [31:0] RowB1 = -5;
reg signed [31:0] RowB2 = 1;
reg signed [31:0] RowB3 = 1;
reg signed [31:0] RowB4 = 1;

// Wire Declarations
wire Error;
wire Done;
wire signed [31:0] Result;

Matrix_Multiplicator ALU5(.Clock(Clock), .Operation(Operation), .ClearAll(ClearAll),
        .ColumnA1(ColumnA1), .ColumnA2(ColumnA2), .ColumnA3(ColumnA3), .ColumnA4(ColumnA4),
        .RowB1(RowB1), .RowB2(RowB2), .RowB3(RowB3), .RowB4(RowB4),
        .Error(Error), .Done(Done), .Result(Result));

initial begin
        Clock = 0;
        forever #10 Clock = !Clock;
end

initial	fork
        #20 Operation <= 3'b101;
join

endmodule
