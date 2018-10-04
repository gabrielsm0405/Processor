module unidadeProcessamento(
	input logic 	clk, 
	input logic 	PCSrc, 
	input logic 	[2:0] ALUFunct, 
	input logic 	[2:0] ALUSrcB, 
	input logic 	ALUSrcA, 
	input logic 	LoadRegA, 
	input logic 	LoadRegB, 
	input logic 	LoadALUOut,
	input logic 	WriteReg, 
	input logic 	MemToReg,
	input logic 	LoadIR, 
	input logic 	IMemWrite, 
	input logic 	DMemWrite, 
	input logic 	LoadMDR, 
	input logic 	Reset,
	input logic		BranchOp,
	input logic		PCWriteCond,
	input logic 	PCWrite,
	output logic 	[31:0] inst
);

	logic [63:0]	PCIn, PCOut;
	logic [31:0] 	IMemOut;
	logic [4:0]  	Instr19_15;
	logic [4:0]		Instr24_20;
	logic [4:0]		Instr11_7;
	logic [6:0]		Instr6_0;
	logic [31:0]	Instr31_0;
	logic [63:0]	WriteData;
	logic [63:0]	RegAIn, RegBIn;
	logic [63:0]	RegAOut, RegBOut;
	logic [63:0]	SignalExtendOut;
	logic [63:0]	ShiftLeftOut;
	logic [63:0]	ALUOut;
	logic 			zero;
	logic [63:0]	MuxAOut;
	logic [63:0]	MuxBOut;
	logic [63:0]	RegALUOutOut;
	logic [63:0]	DataMemoryOut;
	logic [63:0]	MemDataRegOut;
	logic [63:0]	BranchOpOut;
	logic 			LoadPC;

	Registrador64 pc(
		.Clk(clk), 
		.Reset(Reset), 
		.Load(LoadPC), 
		.Entrada(PCIn), 
		.Saida(PCOut)
	);

	Memoria32 IMem(
		.raddress(PCOut[31:0]), 
		.Clk(clk), 
		.Dataout(IMemOut), 
		.Wr(IMemWrite)
	);

	Instr_Reg_RISC_V InstructionRegister(
		.Clk(clk), 
		.Reset(Reset), 
		.Load_ir(LoadIR), 
		.Entrada(IMemOut),
		.Instr19_15(Instr19_15),
		.Instr24_20(Instr24_20),
		.Instr11_7(Instr11_7),
		.Instr6_0(Instr6_0),
		.Instr31_0(Instr31_0)
	);

	Banco_reg64 Registers(
		.Clk(clk),
		.Reset(Reset),
		.RegWrite(WriteReg),
		.ReadReg1(Instr19_15),
		.ReadReg2(Instr24_20),
		.WriteReg(Instr11_7),
		.WriteData(WriteData),
		.ReadData1(RegAIn),
		.ReadData2(RegBIn)
	);

	Registrador64 RegA(
		.Clk(clk),
		.Reset(Reset),
		.Load(LoadRegA),
		.Entrada(RegAIn),
		.Saida(RegAOut)
	);

	Registrador64 RegB(
		.Clk(clk),
		.Reset(Reset),
		.Load(LoadRegB),
		.Entrada(RegBIn),
		.Saida(RegBOut)
	);

	Mux2 MuxA(
		.Control(ALUSrcA),
		.In1(PCOut),
		.In2(RegAOut),
		.Out(MuxAOut)
	);

	Mux4 MuxB(
		.Control(ALUSrcB),
		.In1(RegBOut),
		.In2(64'd4),
		.In3(SignalExtendOut),
		.In4(ShiftLeftOut),
		.Out(MuxBOut)
	);

	Ula64 ALU(
		.A(RegAOut),
		.B(RegBOut),
		.Seletor(ALUFunct),
		.S(ALUOut),
		.z(zero)
	);

	Registrador64 RegALUOut(
		.Clk(clk),
		.Reset(Reset),
		.Load(LoadALUOut),
		.Entrada(ALUOut),
		.Saida(RegALUOutOut)
	);

	Mux2 MuxPCSrc(
		.Control(PCSrc),
		.In1(ALUOut),
		.In2(RegALUOutOut),
		.Out(PCIn)
	);

	Memoria64 DataMemory(
		.raddress(RegALUOutOut),
		.waddress(RegALUOutOut),
		.Clk(clk),
		.Datain(RegBOut),
		.Dataout(DataMemoryOut),
		.Wr(DMemWrite)
	);

	Registrador64 MemDataReg(
		.Clk(clk),
		.Reset(Reset),
		.Load(LoadMDR),
		.Entrada(DataMemoryOut),
		.Saida(MemDataRegOut)
	);

	Mux4 MuxMemToReg(
		.Control(MemToReg),
		.In1(RegALUOutOut),
		.In2(MemDataRegOut),
		.In3(SignalExtendOut),
		.Out(WriteData)
	);

	SignalExtend SignExtend(
		.In(Instr31_0),
		.Out(SignalExtendOut)
	);

	ShiftLeft ShiftLeft(
		.In(SignalExtendOut),
		.Out(ShiftLeftOut)
	);

	Mux1 muxBranchOp(
		.Control(BranchOp),
		.In1(zero),
		.In2(!zero),
		.Out(BranchOpOut)
	);

	always_comb
		LoadPC = ((BranchOpOut & PCWriteCond) | PCWrite);

endmodule 