module RAM_TB;

// reg Declarations
reg Clock, Enable = 1'b0, ReadWrite;
reg [31:0] AddressSelect;
// Matrix A Incoming Values
reg signed [31:0] OutColumn1 = -4, OutColumn2 = 2, OutColumn3 = -4,
    OutColumn4 = 7;

// Register Declarations
wire signed [31:0] InColumn1, InColumn2, InColumn3, InColumn4;

RAM Memory1(
        .Clock(Clock), .Enable(Enable), .ReadWrite(ReadWrite),
        .AddressSelect(AddressSelect), .InColumn1(OutColumn1),
        .InColumn2(OutColumn2), .InColumn3(OutColumn3), .InColumn4(OutColumn4),

        .OutColumn1(InColumn1), .OutColumn2(InColumn2), .OutColumn3(InColumn3),
        .OutColumn4(InColumn4)
);

initial begin
        Clock = 0;
        forever #5 Clock = !Clock;
end

initial	fork
        //Write
        ReadWrite <= 1'b1;
        AddressSelect <= 0;
        #10 Enable <= 1'b1;
        #20 Enable <= 1'b0;
        #30 AddressSelect <= 4;
        #30 OutColumn1 <= 3;
        #30 OutColumn2 <= 83;
        #30 OutColumn3 <= -88;
        #30 OutColumn4 <= 92;
        //Write
        #40 Enable = 1'b1;
        #50 Enable = 1'b0;
        #60 ReadWrite <= 1'b0;
        #60 AddressSelect <= 0;
        //Read
        #70 Enable = 1'b1;
        #80 Enable = 1'b0;
        //Read
        #90 AddressSelect <= 4;
        #100 Enable = 1'b1;
        #110 Enable = 1'b0;
join

initial
    $monitor($stime, Enable, ReadWrite);

endmodule
