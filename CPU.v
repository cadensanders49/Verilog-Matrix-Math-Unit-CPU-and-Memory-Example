/*
File Name: CPU.v
Date of Creation: November 25, 2018
Author: Caden Sanders
Project: Matrix Math Unit for Final Assignment
Course: Digital System Design using HDL [EE4321]
Professor: Mr. Mark Welker
School: Texas State University - San Marcos

Verilog sequential file for a CPU. This module will organize commands4
between multiple ALUs and process information to and from memory.

        Operations
                000 - No Opertion
                001 - Add
                010 - Subtract
                011 - Transpose
                100 - Scalar Multiply
                101 - Matrix Multiply

IO Visualization
	?????? NEEDS TO BE ADDED
*/

module CPU(

        Address1, Address2, Clock, Reset, CPUEnable, ClearAllIn, OperationIn,
        C3_3, C3_2, C3_1, C3_0,
      	C2_3, C2_2, C2_1, C2_0,
      	C1_3, C1_2, C1_1, C1_0,
      	C0_3, C0_2, C0_1, C0_0,


	A3_3, A3_2, A3_1, A3_0,
	A2_3, A2_2, A2_1, A2_0,
 	A1_3, A1_2, A1_1, A1_0,
 	A0_3, A0_2, A0_1, A0_0,

	B3_3, B3_2, B3_1, B3_0,
	B2_3, B2_2, B2_1, B2_0,
	B1_3, B1_2, B1_1, B1_0,
	B0_3, B0_2, B0_1, B0_0,

  MemoryCounter, MatrixACounter, MatrixBCounter, RAMEnable, ReadWrite, RAMDone,
  AddDone, SubDone, TranDone, MMDone, SMDone, AddEnable, SubEnable, TranEnable,
  MMEnable, SMEnable, AddressSelect, State, DataInSelector1, DataInSelector2,
  DataInSelector3, DataInSelector4, DataOut1, DataOut2, DataOut3, DataOut4,
  DataOut5, DataOut6, DataOut7, DataOut8

);

// INPUT DECLARATIONS
//
input [31:0] Address1, Address2;
input [2:0] OperationIn;
input Clock, Reset, CPUEnable, ClearAllIn;
input [31:0] C3_3, C3_2, C3_1, C3_0,
                C2_3, C2_2, C2_1, C2_0,
                C1_3, C1_2, C1_1, C1_0,
                C0_3, C0_2, C0_1, C0_0;

// OUTPUT DECLARATIONS
//
output [31:0] MemoryCounter, MatrixACounter, MatrixBCounter, AddressSelect;
output RAMEnable, AddEnable, SubEnable, TranEnable, MMEnable, SMEnable,
  ReadWrite, RAMDone, AddDone, SubDone, TranDone, MMDone, SMDone;
output [2:0] State;
output [31:0] A3_3, A3_2, A3_1, A3_0,
                A2_3, A2_2, A2_1, A2_0,
                A1_3, A1_2, A1_1, A1_0,
                A0_3, A0_2, A0_1, A0_0;
output [31:0] B3_3, B3_2, B3_1, B3_0,
                B2_3, B2_2, B2_1, B2_0,
                B1_3, B1_2, B1_1, B1_0,
                B0_3, B0_2, B0_1, B0_0;
output signed [31:0] DataInSelector1, DataInSelector2, DataInSelector3, DataInSelector4;
output [31:0] DataOut1, DataOut2, DataOut3, DataOut4, DataOut5, DataOut6,
	DataOut7, DataOut8;

// WIRE DECLARATIONS
//
wire [31:0] Address1, Address2;
wire [2:0] OperationIn;
wire Clock, Reset, Error, RAMDoneIn,
AddDoneIn, SubDoneIn, TranDoneIn, MMDoneIn, SMDoneIn, CPUEnable, ClearAllIn;
wire signed [31:0] AddDataIn1, AddDataIn2, AddDataIn3, AddDataIn4,
	SubDataIn1, SubDataIn2, SubDataIn3, SubDatIn4,
	MemDataIn1, MemDataIn2, MemDataIn3, MemDataIn4,
	SMDataIn1, SMDataIn2, SMDataIn3,SMMDataIn4,
	TranDataIn1, TranDataIn2, TranDataIn3, TranDataIn4,
	MMDataIn1;
wire signed [31:0] A3_3, A3_2, A3_1, A3_0,
	A2_3, A2_2, A2_1, A2_0,
	A1_3, A1_2, A1_1, A1_0,
 	A0_3, A0_2, A0_1, A0_0;
wire signed [31:0] B3_3, B3_2, B3_1, B3_0,
	B2_3, B2_2, B2_1, B2_0,
 	B1_3, B1_2, B1_1, B1_0,
  	B0_3, B0_2, B0_1, B0_0;
wire signed [31:0] C3_3, C3_2, C3_1, C3_0,
        C2_3, C2_2, C2_1, C2_0,
        C1_3, C1_2, C1_1, C1_0,
        C0_3, C0_2, C0_1, C0_0;

// REGISTER DECLARATIONS
//
reg signed [31:0] DataOut1, DataOut2, DataOut3, DataOut4, DataOut5, DataOut6,
	DataOut7, DataOut8;
reg [31:0] MemoryCounter = 0, MatrixACounter = 0, MatrixBCounter = 0;
reg ClearAll, RAMEnable = 1'b0, ReadWrite, RAMDone = 1'b0,
	ALUDone = 1'b0,
	AddEnable = 1'b0, SubEnable = 1'b0, TranEnable = 1'b0,
	MMEnable = 1'b0, SMEnable = 1'b0;
reg [31:0] AddressSelect;
reg signed [31:0] MatrixA [3:0] [3:0];
reg signed [31:0] MatrixB [3:0] [3:0];
reg signed [31:0] NewMatrix [3:0] [3:0];
reg [2:0] Operation = 3'b000, State = 3'b000;
reg signed [31:0] DataInSelector1, DataInSelector2, DataInSelector3, DataInSelector4;

// PARAMETER DECLARATIONS
//
parameter Idle = 3'b000, RequestMemory = 3'b001, ReceiveMemory = 3'b010,
        SendALU = 3'b011, ReceiveALU = 3'b100, SendMemory = 3'b101,
        Stage1 = 0, Stage2 = 1, Stage3 = 2, Stage4 = 3,
        Stage5 = 4, Stage6 = 5, Stage7 = 6, Stage8 = 7,
        Stage9 = 8, Stage10 = 9, Stage11 = 10, Stage12 = 11,
        Stage13 = 12, Stage14 = 13, Stage15 = 14, Stage16 = 15,
        Stage17 = 16, Add = 3'b001, Subtract = 3'b010, Transpose = 3'b011,
        ScalarMultiply = 3'b100, MatrixMultiply = 3'b101, CustomWrite = 3'b110;


//INSTANSIATIONS
//
Adder ALU1(
        .Clock(Clock), .Operation(Operation), .ClearAll(ClearAll),
        .ColumnA1(DataOut1), .ColumnA2(DataOut2), .ColumnA3(DataOut3),
        .ColumnA4(DataOut4), .ColumnB1(DataOut5), .ColumnB2(DataOut6),
        .ColumnB3(DataOut7), .ColumnB4(DataOut8), .Enable(AddEnable),

        .Error(Error), .Done(AddDoneIn),
        .NewColumn1(AddDataIn1), .NewColumn2(AddDataIn2), .NewColumn3(AddDataIn3),
        .NewColumn4(AddDataIn4)
);

Matrix_Multiplicator ALU5(
        .Clock(Clock), .Operation(Operation), .ClearAll(ClearAll),
        .ColumnA1(DataOut1), .ColumnA2(DataOut2), .ColumnA3(DataOut3),
        .ColumnA4(DataOut4), .RowB1(DatOut5), .RowB2(DataOut6),
        .RowB3(DataOut7), .RowB4(DataOut8), .Enable(MMEnable),

        .Error(Error), .Done(MMDoneIn), .Result(MMDataIn1)
);

RAM Memory1(
        .Clock(Clock), .Enable(RAMEnable), .ReadWrite(ReadWrite),
        .AddressSelect(AddressSelect), .InColumn1(DataOut1),
        .InColumn2(DataOut2), .InColumn3(DataOut3), .InColumn4(DataOut4),

        .OutColumn1(MemDataIn1), .OutColumn2(MemDataIn2), .OutColumn3(MemDataIn3),
        .OutColumn4(MemDataIn4), .Done(RAMDoneIn)
);

Scalar_Multiplicator ALU3(
        .Clock(Clock), .Operation(Operation), .ClearAll(ClearAll),
        .ColumnA1(DataOut1), .ColumnA2(DataOut2), .ColumnA3(DataOut3),
        .ColumnA4(DataOut4), .ColumnB1(DataOut5), .ColumnB2(DataOut6),
        .ColumnB3(DataOut7), .ColumnB4(DataOut8), .Enable(SMEnable),

        .Error(Error), .Done(SMDoneIn), .NewColumn1(SMDataIn1), .NewColumn2(SMDataIn2),
        .NewColumn3(SMDataIn3), .NewColumn4(SMDataIn4)
);

Subtractor ALU2(
        .Clock(Clock), .Operation(Operation), .ClearAll(ClearAll),
        .ColumnA1(DataOut1), .ColumnA2(DataOut2), .ColumnA3(DataOut3),
        .ColumnA4(DataOut4), .ColumnB1(DataOut5), .ColumnB2(DataOut6),
        .ColumnB3(DataOut7), .ColumnB4(DataOut8), .Enable(SubEnable),

        .Error(Error), .Done(SubDoneIn), .NewColumn1(SubDataIn1), .NewColumn2(SubDataIn2),
        .NewColumn3(SubDataIn3), .NewColumn4(SubDataIn4)
);

Transposition ALU6(
        .Clock(Clock), .Operation(Operation), .ClearAll(ClearAll),
        .Column1(DataOut1), .Column2(DataOut2), .Column3(DataOut3),
        .Column4(DataOut4), .Enable(TranEnable),

        .Error(Error), .Done(TranDoneIn), .NewRow1(TranDataIn1), .NewRow2(TranDataIn2),
        .NewRow3(TranDataIn3), .NewRow4(TranDataIn4)
);



assign A3_3 = MatrixA[3][3];
assign A3_2 = MatrixA[3][2];
assign A3_1 = MatrixA[3][1];
assign A3_0 = MatrixA[3][0];
assign A2_3 = MatrixA[2][3];
assign A2_2 = MatrixA[2][2];
assign A2_1 = MatrixA[2][1];
assign A2_0 = MatrixA[2][0];
assign A1_3 = MatrixA[1][3];
assign A1_2 = MatrixA[1][2];
assign A1_1 = MatrixA[1][1];
assign A1_0 = MatrixA[1][0];
assign A0_3 = MatrixA[0][3];
assign A0_2 = MatrixA[0][2];
assign A0_1 = MatrixA[0][1];
assign A0_0 = MatrixA[0][0];

assign B3_3 = MatrixB[3][3];
assign B3_2 = MatrixB[3][2];
assign B3_1 = MatrixB[3][1];
assign B3_0 = MatrixB[3][0];
assign B2_3 = MatrixB[2][3];
assign B2_2 = MatrixB[2][2];
assign B2_1 = MatrixB[2][1];
assign B2_0 = MatrixB[2][0];
assign B1_3 = MatrixB[1][3];
assign B1_2 = MatrixB[1][2];
assign B1_1 = MatrixB[1][1];
assign B1_0 = MatrixB[1][0];
assign B0_3 = MatrixB[0][3];
assign B0_2 = MatrixB[0][2];
assign B0_1 = MatrixB[0][1];
assign B0_0 = MatrixB[0][0];

assign AddDone = AddDoneIn;
assign SubDone = SubDoneIn;
assign TranDone = TranDoneIn;
assign MMDone = MMDoneIn;
assign SMDone = SMDoneIn;

// BEHAVIORAL CODE
//
always @(posedge Clock) begin
	Operation <= OperationIn;
	ClearAll <= ClearAllIn;
        case(State)
                Idle:
                        if(CPUEnable) begin
				if(Operation==CustomWrite) begin
					NewMatrix[3][3] <= C3_3;
					NewMatrix[3][2] <= C3_2;
					NewMatrix[3][1] <= C3_1;
					NewMatrix[3][0] <= C3_0;
					NewMatrix[2][3] <= C2_3;
					NewMatrix[2][2] <= C2_2;
					NewMatrix[2][1] <= C2_1;
					NewMatrix[2][0] <= C2_0;
					NewMatrix[1][3] <= C1_3;
					NewMatrix[1][2] <= C1_2;
					NewMatrix[1][1] <= C1_1;
					NewMatrix[1][0] <= C1_0;
					NewMatrix[0][3] <= C0_3;
					NewMatrix[0][2] <= C0_2;
					NewMatrix[0][1] <= C0_1;
					NewMatrix[0][0] <= C0_0;
					State <= SendMemory;
				end else begin
					State <= RequestMemory;
				end
                        end

                RequestMemory:
		begin
			RAMDone <= RAMDoneIn;
                        if(RAMDone==1'b0) begin
				if(MatrixACounter!=Stage5) begin
					AddressSelect <= Address1;
				end else begin
					AddressSelect <= Address2;
				end
				ReadWrite <= 1'b0;
                                RAMEnable <= 1'b1;
                        end

			if(RAMDone==1'b1 && RAMEnable==1'b1) begin
				RAMEnable <= 1'b0;
				State <= ReceiveMemory;
                        end
		end
                ReceiveMemory:
		begin
			DataInSelector1 <= MemDataIn1;
			DataInSelector2 <= MemDataIn2;
			DataInSelector3 <= MemDataIn3;
			DataInSelector4 <= MemDataIn4;
                        // The first matrix has been read from memory
                        if(MatrixACounter==Stage5) begin

                                // Transpose only needs one matrix, move on
                                if(Operation==Transpose) begin
					MatrixACounter <= Stage1;
                                        State <= SendALU;
                                end else begin

                                        // The second matrix has been read
                                        // into memory, move on
                                        if(MatrixBCounter==Stage5) begin
                                                MatrixACounter <= Stage1;
                                                MatrixBCounter <= Stage1;
                                                State <= SendALU;
                                        end else begin
                                                if(MatrixBCounter==Stage1) begin
                                                        MatrixB [3][3] <= DataInSelector1;
                                                        MatrixB [3][2] <= DataInSelector2;
                                                        MatrixB [3][1] <= DataInSelector3;
                                                        MatrixB [3][0] <= DataInSelector4;
                                                        MatrixBCounter <= Stage2;
                                                end else if(MatrixBCounter==Stage2) begin
                                                        MatrixB [2][3] <= DataInSelector1;
                                                        MatrixB [2][2] <= DataInSelector2;
                                                        MatrixB [2][1] <= DataInSelector3;
                                                        MatrixB [2][0] <= DataInSelector4;
                                                        MatrixBCounter <= Stage3;
                                                end else if(MatrixBCounter==Stage3) begin
                                                        MatrixB [1][3] <= DataInSelector1;
                                                        MatrixB [1][2] <= DataInSelector2;
                                                        MatrixB [1][1] <= DataInSelector3;
                                                        MatrixB [1][0] <= DataInSelector4;
                                                        MatrixBCounter <= Stage4;
                                                end else if(MatrixBCounter==Stage4) begin
                                                        MatrixB [0][3] <= DataInSelector1;
                                                        MatrixB [0][2] <= DataInSelector2;
                                                        MatrixB [0][1] <= DataInSelector3;
                                                        MatrixB [0][0] <= DataInSelector4;
                                                        MatrixBCounter <= Stage5;
                                                end
                                                State <= RequestMemory;
                                        end
                                end
                        end else begin
                                if(MatrixACounter==Stage1) begin
                                        MatrixA [3][3] <= DataInSelector1;
                                        MatrixA [3][2] <= DataInSelector2;
                                        MatrixA [3][1] <= DataInSelector3;
                                        MatrixA [3][0] <= DataInSelector4;
                                        MatrixACounter <= Stage2;
                                end else if(MatrixACounter==Stage2) begin
                                        MatrixA [2][3] <= DataInSelector1;
                                        MatrixA [2][2] <= DataInSelector2;
                                        MatrixA [2][1] <= DataInSelector3;
                                        MatrixA [2][0] <= DataInSelector4;
                                        MatrixACounter <= Stage3;
                                end else if(MatrixACounter==Stage3) begin
                                        MatrixA [1][3] <= DataInSelector1;
                                        MatrixA [1][2] <= DataInSelector2;
                                        MatrixA [1][1] <= DataInSelector3;
                                        MatrixA [1][0] <= DataInSelector4;
                                        MatrixACounter <= Stage4;
                                end else if(MatrixACounter==Stage4) begin
                                        MatrixA [0][3] <= DataInSelector1;
                                        MatrixA [0][2] <= DataInSelector2;
                                        MatrixA [0][1] <= DataInSelector3;
                                        MatrixA [0][0] <= DataInSelector4;
                                        MatrixACounter <= Stage5;
                                end
                                State <= RequestMemory;
                        end
		end

                SendALU:
		begin
			case(Operation)
				Add:
				begin
					ALUDone <= AddDoneIn;
				end
				Subtract:
				begin
					ALUDone <= SubDoneIn;
				end
				Transpose:
				begin
					ALUDone <= TranDoneIn;
				end
				ScalarMultiply:
				begin
					ALUDone <= SMDoneIn;
				end
				MatrixMultiply:
				begin
					ALUDone <= MMDoneIn;
				end
			endcase
                        if(ALUDone==1'b0) begin
                                if(Operation==Transpose) begin
                                        if(MatrixACounter==Stage1) begin
                                                DataOut1 <= MatrixA [3][3];
                                                DataOut2 <= MatrixA [3][2];
                                                DataOut3 <= MatrixA [3][1];
                                                DataOut4 <= MatrixA [3][0];
                                        end else if(MatrixACounter==Stage2) begin
                                                DataOut1 <= MatrixA [2][3];
                                                DataOut2 <= MatrixA [2][2];
                                                DataOut3 <= MatrixA [2][1];
                                                DataOut4 <= MatrixA [2][0];
                                        end else if(MatrixACounter==Stage3) begin
                                                DataOut1 <= MatrixA [1][3];
                                                DataOut2 <= MatrixA [1][2];
                                                DataOut3 <= MatrixA [1][1];
                                                DataOut4 <= MatrixA [1][0];
                                        end else if(MatrixACounter==Stage4) begin
                                                DataOut1 <= MatrixA [0][3];
                                                DataOut2 <= MatrixA [0][2];
                                                DataOut3 <= MatrixA [0][1];
                                                DataOut4 <= MatrixA [0][0];
                                        end
                                end else if(Operation==MatrixMultiply) begin
                                        if(MatrixACounter==Stage1) begin
                                                DataOut1 <= MatrixA [3][3];
                                                DataOut2 <= MatrixA [3][2];
                                                DataOut3 <= MatrixA [3][1];
                                                DataOut4 <= MatrixA [3][0];
                                                DataOut5 <= MatrixB [3][3];
                                                DataOut6 <= MatrixB [2][3];
                                                DataOut7 <= MatrixB [1][3];
                                                DataOut8 <= MatrixB [0][3];
                                        end else if(MatrixACounter==Stage2) begin
                                                DataOut1 <= MatrixA [3][3];
                                                DataOut2 <= MatrixA [3][2];
                                                DataOut3 <= MatrixA [3][1];
                                                DataOut4 <= MatrixA [3][0];
                                                DataOut5 <= MatrixB [3][2];
                                                DataOut6 <= MatrixB [2][2];
                                                DataOut7 <= MatrixB [1][2];
                                                DataOut8 <= MatrixB [0][2];
                                        end else if(MatrixACounter==Stage3) begin
                                                DataOut1 <= MatrixA [3][3];
                                                DataOut2 <= MatrixA [3][2];
                                                DataOut3 <= MatrixA [3][1];
                                                DataOut4 <= MatrixA [3][0];
                                                DataOut5 <= MatrixB [3][1];
                                                DataOut6 <= MatrixB [2][1];
                                                DataOut7 <= MatrixB [1][1];
                                                DataOut8 <= MatrixB [0][1];
                                        end else if(MatrixACounter==Stage4) begin
                                                DataOut1 <= MatrixA [3][3];
                                                DataOut2 <= MatrixA [3][2];
                                                DataOut3 <= MatrixA [3][1];
                                                DataOut4 <= MatrixA [3][0];
                                                DataOut5 <= MatrixB [3][0];
                                                DataOut6 <= MatrixB [2][0];
                                                DataOut7 <= MatrixB [1][0];
                                                DataOut8 <= MatrixB [0][0];
                                        end else if(MatrixACounter==Stage5) begin
                                                DataOut1 <= MatrixA [2][3];
                                                DataOut2 <= MatrixA [2][2];
                                                DataOut3 <= MatrixA [2][1];
                                                DataOut4 <= MatrixA [2][0];
                                                DataOut5 <= MatrixB [3][3];
                                                DataOut6 <= MatrixB [2][3];
                                                DataOut7 <= MatrixB [1][3];
                                                DataOut8 <= MatrixB [0][3];
                                        end else if(MatrixACounter==Stage6) begin
                                                DataOut1 <= MatrixA [2][3];
                                                DataOut2 <= MatrixA [2][2];
                                                DataOut3 <= MatrixA [2][1];
                                                DataOut4 <= MatrixA [2][0];
                                                DataOut5 <= MatrixB [3][2];
                                                DataOut6 <= MatrixB [2][2];
                                                DataOut7 <= MatrixB [1][2];
                                                DataOut8 <= MatrixB [0][2];
                                        end else if(MatrixACounter==Stage7) begin
                                                DataOut1 <= MatrixA [2][3];
                                                DataOut2 <= MatrixA [2][2];
                                                DataOut3 <= MatrixA [2][1];
                                                DataOut4 <= MatrixA [2][0];
                                                DataOut5 <= MatrixB [3][1];
                                                DataOut6 <= MatrixB [2][1];
                                                DataOut7 <= MatrixB [1][1];
                                                DataOut8 <= MatrixB [0][1];
                                        end else if(MatrixACounter==Stage8) begin
                                                DataOut1 <= MatrixA [2][3];
                                                DataOut2 <= MatrixA [2][2];
                                                DataOut3 <= MatrixA [2][1];
                                                DataOut4 <= MatrixA [2][0];
                                                DataOut5 <= MatrixB [3][0];
                                                DataOut6 <= MatrixB [2][0];
                                                DataOut7 <= MatrixB [1][0];
                                                DataOut8 <= MatrixB [0][0];
                                        end else if(MatrixACounter==Stage9) begin
                                                DataOut1 <= MatrixA [1][3];
                                                DataOut2 <= MatrixA [1][2];
                                                DataOut3 <= MatrixA [1][1];
                                                DataOut4 <= MatrixA [1][0];
                                                DataOut5 <= MatrixB [3][3];
                                                DataOut6 <= MatrixB [2][3];
                                                DataOut7 <= MatrixB [1][3];
                                                DataOut8 <= MatrixB [0][3];
                                        end else if(MatrixACounter==Stage10) begin
                                                DataOut1 <= MatrixA [1][3];
                                                DataOut2 <= MatrixA [1][2];
                                                DataOut3 <= MatrixA [1][1];
                                                DataOut4 <= MatrixA [1][0];
                                                DataOut5 <= MatrixB [3][2];
                                                DataOut6 <= MatrixB [2][2];
                                                DataOut7 <= MatrixB [1][2];
                                                DataOut8 <= MatrixB [0][2];
                                        end else if(MatrixACounter==Stage11) begin
                                                DataOut1 <= MatrixA [1][3];
                                                DataOut2 <= MatrixA [1][2];
                                                DataOut3 <= MatrixA [1][1];
                                                DataOut4 <= MatrixA [1][0];
                                                DataOut5 <= MatrixB [3][1];
                                                DataOut6 <= MatrixB [2][1];
                                                DataOut7 <= MatrixB [1][1];
                                                DataOut8 <= MatrixB [0][1];
                                        end else if(MatrixACounter==Stage12) begin
                                                DataOut1 <= MatrixA [1][3];
                                                DataOut2 <= MatrixA [1][2];
                                                DataOut3 <= MatrixA [1][1];
                                                DataOut4 <= MatrixA [1][0];
                                                DataOut5 <= MatrixB [3][0];
                                                DataOut6 <= MatrixB [2][0];
                                                DataOut7 <= MatrixB [1][0];
                                                DataOut8 <= MatrixB [0][0];
                                        end else if(MatrixACounter==Stage13) begin
                                                DataOut1 <= MatrixA [0][3];
                                                DataOut2 <= MatrixA [0][2];
                                                DataOut3 <= MatrixA [0][1];
                                                DataOut4 <= MatrixA [0][0];
                                                DataOut5 <= MatrixB [3][3];
                                                DataOut6 <= MatrixB [2][3];
                                                DataOut7 <= MatrixB [1][3];
                                                DataOut8 <= MatrixB [0][3];
                                        end else if(MatrixACounter==Stage14) begin
                                                DataOut1 <= MatrixA [0][3];
                                                DataOut2 <= MatrixA [0][2];
                                                DataOut3 <= MatrixA [0][1];
                                                DataOut4 <= MatrixA [0][0];
                                                DataOut5 <= MatrixB [3][2];
                                                DataOut6 <= MatrixB [2][2];
                                                DataOut7 <= MatrixB [1][2];
                                                DataOut8 <= MatrixB [0][2];
                                        end else if(MatrixACounter==Stage15) begin
                                                DataOut1 <= MatrixA [0][3];
                                                DataOut2 <= MatrixA [0][2];
                                                DataOut3 <= MatrixA [0][1];
                                                DataOut4 <= MatrixA [0][0];
                                                DataOut5 <= MatrixB [3][1];
                                                DataOut6 <= MatrixB [2][1];
                                                DataOut7 <= MatrixB [1][1];
                                                DataOut8 <= MatrixB [0][1];
                                        end else if(MatrixACounter==Stage16) begin
                                                DataOut1 <= MatrixA [0][3];
                                                DataOut2 <= MatrixA [0][2];
                                                DataOut3 <= MatrixA [0][1];
                                                DataOut4 <= MatrixA [0][0];
                                                DataOut5 <= MatrixB [3][0];
                                                DataOut6 <= MatrixB [2][0];
                                                DataOut7 <= MatrixB [1][0];
                                                DataOut8 <= MatrixB [0][0];
                                        end
                                end else begin
                                        if(MatrixACounter==Stage1) begin
                                                DataOut1 <= MatrixA [3][3];
                                                DataOut2 <= MatrixA [3][2];
                                                DataOut3 <= MatrixA [3][1];
                                                DataOut4 <= MatrixA [3][0];
                                                DataOut5 <= MatrixB [3][3];
                                                DataOut6 <= MatrixB [3][2];
                                                DataOut7 <= MatrixB [3][1];
                                                DataOut8 <= MatrixB [3][0];
                                        end else if(MatrixACounter==Stage2) begin
                                                DataOut1 <= MatrixA [2][3];
                                                DataOut2 <= MatrixA [2][2];
                                                DataOut3 <= MatrixA [2][1];
                                                DataOut4 <= MatrixA [2][0];
                                                DataOut5 <= MatrixB [2][3];
                                                DataOut6 <= MatrixB [2][2];
                                                DataOut7 <= MatrixB [2][1];
                                                DataOut8 <= MatrixB [2][0];
                                        end else if(MatrixACounter==Stage3) begin
                                                DataOut1 <= MatrixA [1][3];
                                                DataOut2 <= MatrixA [1][2];
                                                DataOut3 <= MatrixA [1][1];
                                                DataOut4 <= MatrixA [1][0];
                                                DataOut5 <= MatrixB [1][3];
                                                DataOut6 <= MatrixB [1][2];
                                                DataOut7 <= MatrixB [1][1];
                                                DataOut8 <= MatrixB [1][0];
                                        end else if(MatrixACounter==Stage4) begin
                                                DataOut1 <= MatrixA [0][3];
                                                DataOut2 <= MatrixA [0][2];
                                                DataOut3 <= MatrixA [0][1];
                                                DataOut4 <= MatrixA [0][0];
                                                DataOut5 <= MatrixB [0][3];
                                                DataOut6 <= MatrixB [0][2];
                                                DataOut7 <= MatrixB [0][1];
                                                DataOut8 <= MatrixB [0][0];
                                        end
                                end
				case(Operation)
					Add:
					begin
						AddEnable <= 1'b1;
					end
					Subtract:
					begin
						SubEnable <= 1'b1;
					end
					Transpose:
					begin
						TranEnable <= 1'b1;
					end
					ScalarMultiply:
					begin
						SMEnable <= 1'b1;
					end
					MatrixMultiply:
					begin
						MMEnable <= 1'b1;
					end
				endcase
                        end else if(ALUDone==1'b1) begin
				if(MatrixACounter==Stage5 && Operation!=MatrixMultiply) begin
					AddressSelect = MemoryCounter + 1;
					MatrixACounter <= Stage1;
					State <= SendMemory;
				end else if(MatrixACounter==Stage17) begin
					AddressSelect = MemoryCounter + 1;
					MatrixACounter <= Stage1;
					State <= SendMemory;
				end else begin
					case(Operation)
						Add:
						begin
							AddEnable <= 1'b0;
						end
						Subtract:
						begin
							SubEnable <= 1'b0;
						end
						Transpose:
						begin
							TranEnable <= 1'b0;
						end
						ScalarMultiply:
						begin
							SMEnable <= 1'b0;
						end
						MatrixMultiply:
						begin
							MMEnable <= 1'b0;
						end
					endcase
                                	State <= ReceiveALU;
				end
			end
		end

                ReceiveALU:
		begin
                        if(Operation==MatrixMultiply) begin
                                case (MatrixACounter)
                                        Stage1:
					begin
                                                NewMatrix [3][3] <= MMDataIn1;
                                                MatrixACounter <= Stage2;
                                        end
                                        Stage2:
					begin
                                                NewMatrix [3][2] <= MMDataIn1;
                                                MatrixACounter <= Stage3;
                                        end
                                        Stage3:
					begin
                                                NewMatrix [3][1] <= MMDataIn1;
                                                MatrixACounter <= Stage4;
                                        end
                                        Stage4:
					begin
                                                NewMatrix [3][0] <= MMDataIn1;
                                                MatrixACounter <= Stage5;
                                        end
                                        Stage5:
					begin
                                                NewMatrix [2][3] <= MMDataIn1;
                                                MatrixACounter <= Stage6;
                                        end
                                        Stage6:
					begin
                                                NewMatrix [2][2] <= MMDataIn1;
                                                MatrixACounter <= Stage7;
                                        end
                                        Stage7:
					begin
                                                NewMatrix [2][1] <= MMDataIn1;
                                                MatrixACounter <= Stage8;
                                        end
                                        Stage8:
					begin
                                                NewMatrix [2][0] <= MMDataIn1;
                                                MatrixACounter <= Stage9;
                                        end
                                        Stage9:
					begin
                                                NewMatrix [1][3] <= MMDataIn1;
                                                MatrixACounter <= Stage10;
                                        end
                                        Stage10:
					begin
                                                NewMatrix [1][2] <= MMDataIn1;
                                                MatrixACounter <= Stage11;
                                        end
                                        Stage11:
					begin
                                                NewMatrix [1][1] <= MMDataIn1;
                                                MatrixACounter <= Stage12;
                                        end
                                        Stage12:
					begin
                                                NewMatrix [1][0] <= MMDataIn1;
                                                MatrixACounter <= Stage13;
                                        end
                                        Stage13:
					begin
                                                NewMatrix [0][3] <= MMDataIn1;
                                                MatrixACounter <= Stage14;
                                        end
                                        Stage14:
					begin
                                                NewMatrix [0][2] <= MMDataIn1;
                                                MatrixACounter <= Stage15;
                                        end
                                        Stage15:
					begin
                                                NewMatrix [0][1] <= MMDataIn1;
                                                MatrixACounter <= Stage16;
                                        end
                                        Stage16:
					begin
                                                NewMatrix [0][0] <= MMDataIn1;
                                                MatrixACounter <= Stage17;
                                        end
                                endcase

                        end else if(Operation==Transpose) begin
				ALUDone <= TranDoneIn;
				DataInSelector1 <= TranDataIn1;
				DataInSelector2 <= TranDataIn2;
				DataInSelector3 <= TranDataIn3;
				DataInSelector4 <= TranDataIn4;
                                if(MatrixACounter==Stage1) begin
                                        NewMatrix [3][3] <= DataInSelector1;
                                        NewMatrix [2][3] <= DataInSelector2;
                                        NewMatrix [1][3] <= DataInSelector3;
                                        NewMatrix [0][3] <= DataInSelector4;
                                        MatrixACounter <= Stage2;
                                end else if(MatrixACounter==Stage2) begin
                                        NewMatrix [3][2] <= DataInSelector1;
                                        NewMatrix [2][2] <= DataInSelector2;
                                        NewMatrix [1][2] <= DataInSelector3;
                                        NewMatrix [0][2] <= DataInSelector4;
                                        MatrixACounter <= Stage3;
                                end else if(MatrixACounter==Stage3) begin
                                        NewMatrix [3][1] <= DataInSelector3;
                                        NewMatrix [2][1] <= DataInSelector2;
                                        NewMatrix [1][1] <= DataInSelector3;
                                        NewMatrix [0][1] <= DataInSelector4;
                                        MatrixACounter <= Stage4;
                                end else if(MatrixACounter==Stage4) begin
                                        NewMatrix [3][0] <= DataInSelector4;
                                        NewMatrix [2][0] <= DataInSelector2;
                                        NewMatrix [1][0] <= DataInSelector3;
                                        NewMatrix [0][0] <= DataInSelector4;
                                        MatrixACounter <= Stage5;
                                end
                        end else begin
				case(Operation)
					Add:
					begin
						DataInSelector1 <= AddDataIn1;
						DataInSelector2 <= AddDataIn2;
						DataInSelector3 <= AddDataIn3;
						DataInSelector4 <= AddDataIn4;
					end
					Subtract:
					begin
						DataInSelector1 <= SubDataIn1;
						DataInSelector2 <= SubDataIn2;
						DataInSelector3 <= SubDataIn3;
						DataInSelector4 <= SubDataIn4;
					end
					ScalarMultiply:
					begin
						DataInSelector1 <= SMDataIn1;
						DataInSelector2 <= SMDataIn2;
						DataInSelector3 <= SMDataIn3;
						DataInSelector4 <= SMDataIn4;
					end
				endcase
				if(MatrixACounter==Stage1) begin
	                                NewMatrix [3][3] <= DataInSelector1;
	                                NewMatrix [3][2] <= DataInSelector2;
	                                NewMatrix [3][1] <= DataInSelector3;
	                                NewMatrix [3][0] <= DataInSelector4;
	                                MatrixACounter <= Stage2;
	                        end else if(MatrixACounter==Stage2) begin
	                                NewMatrix [2][3] <= DataInSelector1;
	                                NewMatrix [2][2] <= DataInSelector2;
	                                NewMatrix [2][1] <= DataInSelector3;
	                                NewMatrix [2][0] <= DataInSelector4;
	                                MatrixACounter <= Stage3;
	                        end else if(MatrixACounter==Stage3) begin
	                                NewMatrix [1][3] <= DataInSelector1;
	                                NewMatrix [1][2] <= DataInSelector2;
	                                NewMatrix [1][1] <= DataInSelector3;
	                                NewMatrix [1][0] <= DataInSelector4;
	                                MatrixACounter <= Stage4;
	                        end else if(MatrixACounter==Stage4) begin
	                                NewMatrix [0][3] <= DataInSelector1;
	                                NewMatrix [0][2] <= DataInSelector2;
	                                NewMatrix [0][1] <= DataInSelector3;
	                                NewMatrix [0][0] <= DataInSelector4;
	                                MatrixACounter <= Stage5;
	                        end
			end
			State <= SendALU;
		end

                SendMemory:
		begin
			RAMDone <= RAMDoneIn;
			ReadWrite <= 1'b1;

			if(RAMDone==1'b0) begin
				AddressSelect <= MemoryCounter + 1;
				if(MatrixACounter==Stage5) begin
					MemoryCounter = MemoryCounter + 1;
					MatrixACounter <= Stage1;
					State <= Idle;
				end else if(MatrixACounter==Stage1) begin
					DataOut1 <= NewMatrix [3][3];
					DataOut2 <= NewMatrix [3][2];
					DataOut3 <= NewMatrix [3][1];
					DataOut4 <= NewMatrix [3][0];
					RAMEnable <= 1'b1;
				end else if(MatrixACounter==Stage2) begin
					DataOut1 <= NewMatrix [2][3];
					DataOut2 <= NewMatrix [2][2];
					DataOut3 <= NewMatrix [2][1];
					DataOut4 <= NewMatrix [2][0];
					RAMEnable <= 1'b1;
				end else if(MatrixACounter==Stage3) begin
					DataOut1 <= NewMatrix [1][3];
					DataOut2 <= NewMatrix [1][2];
					DataOut3 <= NewMatrix [1][1];
					DataOut4 <= NewMatrix [1][0];
					RAMEnable <= 1'b1;
				end else if(MatrixACounter==Stage4) begin
					DataOut1 <= NewMatrix [0][3];
					DataOut2 <= NewMatrix [0][2];
					DataOut3 <= NewMatrix [0][1];
					DataOut4 <= NewMatrix [0][0];
					RAMEnable <= 1'b1;
				end
			end

			if(RAMDone==1'b1 && RAMEnable==1'b1) begin
				RAMEnable <= 1'b0;
				if(MatrixACounter==Stage1) begin
	                                MatrixACounter <= Stage2;
	                        end else if(MatrixACounter==Stage2) begin
	                                MatrixACounter <= Stage3;
	                        end else if(MatrixACounter==Stage3) begin
					MatrixACounter <= Stage4;
	                        end else if(MatrixACounter==Stage4) begin
					MatrixACounter <= Stage5;
	                        end
			end

		end
        endcase
end

//
// END OF MODULE
endmodule
