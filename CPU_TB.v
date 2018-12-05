module CPU_TB;

// Register Declarations
reg [31:0] Address1, Address2;
reg Clock;
reg [2:0] Operation = 3'b000;
reg ClearAll = 1'b0, Reset = 1'b0, CPUEnable = 1'b0;
wire signed [31:0] A3_3, A3_2, A3_1, A3_0,
	A2_3, A2_2, A2_1, A2_0,
	A1_3, A1_2, A1_1, A1_0,
 	A0_3, A0_2, A0_1, A0_0;
wire signed [31:0] B3_3, B3_2, B3_1, B3_0,
	B2_3, B2_2, B2_1, B2_0,
 	B1_3, B1_2, B1_1, B1_0,
  	B0_3, B0_2, B0_1, B0_0;
reg signed [31:0] C3_3, C3_2, C3_1, C3_0,
                C2_3, C2_2, C2_1, C2_0,
                C1_3, C1_2, C1_1, C1_0,
                C0_3, C0_2, C0_1, C0_0;

// Wire Declarations
wire [31:0] MemoryCounter, MatrixACounter, MatrixBCounter, AddressSelect;
wire RAMEnable, AddEnable, SubEnable, TranEnable, MMEnable, SMEnable, ReadWrite, RAMDone, AddDone, SubDone, TranDone, MMDone, SMDone;
wire [2:0] State;
wire signed [31:0] DataIn1, DataIn2, DataIn3, DataIn4;
wire signed [31:0] DataOut1, DataOut2, DataOut3, DataOut4, DataOut5, DataOut6,
	DataOut7, DataOut8;


parameter Add = 3'b001, Subtract = 3'b010, Transpose = 3'b011,
        ScalarMultiply = 3'b100, MatrixMultiply = 3'b101, CustomWrite = 3'b110;


CPU MainCPU(.Clock(Clock), .OperationIn(Operation), .ClearAllIn(ClearAll),
        .Address1(Address1), .Address2(Address2), .Reset(Reset),
        .CPUEnable(CPUEnable),

        .MemoryCounter(MemoryCounter), .MatrixACounter(MatrixACounter),
        .MatrixBCounter(MatrixBCounter),
        .A3_3(A3_3), .A2_3(A2_3), .A1_3(A1_3), .A0_3(A0_3),
        .A3_2(A3_2), .A2_2(A2_2), .A1_2(A1_2), .A0_2(A0_2),
        .A3_1(A3_1), .A2_1(A2_1), .A1_1(A1_1), .A0_1(A0_1),
        .A3_0(A3_0), .A2_0(A2_0), .A1_0(A1_0), .A0_0(A0_0),

        .B3_3(B3_3), .B2_3(B2_3), .B1_3(B1_3), .B0_3(B0_3),
        .B3_2(B3_2), .B2_2(B2_2), .B1_2(B1_2), .B0_2(B0_2),
        .B3_1(B3_1), .B2_1(B2_1), .B1_1(B1_1), .B0_1(B0_1),
        .B3_0(B3_0), .B2_0(B2_0), .B1_0(B1_0), .B0_0(B0_0),

        .C3_3(C3_3), .C2_3(C2_3), .C1_3(C1_3), .C0_3(C0_3),
        .C3_2(C3_2), .C2_2(C2_2), .C1_2(C1_2), .C0_2(C0_2),
        .C3_1(C3_1), .C2_1(C2_1), .C1_1(C1_1), .C0_1(C0_1),
        .C3_0(C3_0), .C2_0(C2_0), .C1_0(C1_0), .C0_0(C0_0),

        .RAMEnable(RAMEnable),
        .AddEnable(AddEnable), .SubEnable(SubEnable), .TranEnable(TranEnable),
        .MMEnable(MMEnable), .SMEnable(SMEnable),
        .ReadWrite(ReadWrite), .RAMDone(RAMDone),
        .AddressSelect(AddressSelect), .State(State),
        .AddDone(AddDone), .SubDone(SubDone), .TranDone(TranDone),
        .MMDone(MMDone), .SMDone(SMDone),

        .DataInSelector1(DataIn1), .DataInSelector2(DataIn2),
        .DataInSelector3(DataIn3), .DataInSelector4(DataIn4),

        .DataOut1(DataOut1), .DataOut2(DataOut2), .DataOut3(DataOut3),
        .DataOut4(DataOut4), .DataOut5(DataOut5), .DataOut6(DataOut6),
        .DataOut7(DataOut7), .DataOut8(DataOut8)
);

initial begin
        Clock = 0;
        forever #1 Clock = !Clock;
end

initial	begin
        C3_3 <= 25;
        C3_2 <= 225;
        C3_1 <= 25;
        C3_0 <= -35;
        C2_3 <= 25;
        C2_2 <= 25;
        C2_1 <= -25;
        C2_0 <= 25;
        C1_3 <= 25;
        C1_2 <= -25;
        C1_1 <= 25;
        C1_0 <= 25;
        C0_3 <= 25;
        C0_2 <= 325;
        C0_1 <= 25;
        C0_0 <= 25;
        Address1 = 0;
        Operation = CustomWrite;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
        #50 C3_3 <= 2;
        C3_2 <= 2;
        C3_1 <= 2;
        C3_0 <= -2;
        C2_3 <= 2;
        C2_2 <= 2;
        C2_1 <= 26;
        C2_0 <= 2;
        C1_3 <= 2;
        C1_2 <= 24;
        C1_1 <= 2;
        C1_0 <= 2;
        C0_3 <= 2;
        C0_2 <= 2;
        C0_1 <= 23;
        C0_0 <= 2;
        Address1 = 1;
        Address2 = 0;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
        #50 C3_3 <= 2;
        C3_2 <= 2;
        C3_1 <= 2;
        C3_0 <= -2;
        C2_3 <= 2;
        C2_2 <= 2;
        C2_1 <= 26;
        C2_0 <= 2;
        C1_3 <= 2;
        C1_2 <= 24;
        C1_1 <= 2;
        C1_0 <= 2;
        C0_3 <= 2;
        C0_2 <= 2;
        C0_1 <= 23;
        C0_0 <= 2;
        Address1 = 2;
        Address2 = 0;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
        #50 C3_3 <= 2;
        C3_2 <= 2;
        C3_1 <= 2;
        C3_0 <= -2;
        C2_3 <= 2;
        C2_2 <= 2;
        C2_1 <= 26;
        C2_0 <= 2;
        C1_3 <= 2;
        C1_2 <= 24;
        C1_1 <= 2;
        C1_0 <= 2;
        C0_3 <= 2;
        C0_2 <= 2;
        C0_1 <= 23;
        C0_0 <= 2;
        Address1 = 3;
        Address2 = 0;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
        Address1 = 1;
        Address2 = 2;
        #50 Operation <= Add;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
        Address1 = 3;
        Address2 = 1;
        #50 Operation <= Subtract;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
        Address1 = 3;
        Address2 = 1;
        #50 Operation <= Transpose;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
        Address1 = 3;
        Address2 = 1;
        #50 Operation <= MatrixMultiply;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
        Address1 = 3;
        Address2 = 1;
        #50 Operation <= ScalarMultiply;
        #10 CPUEnable = 1'b1;
        #20 CPUEnable = 1'b0;
end

endmodule
