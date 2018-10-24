module unidadeProcessamento_test(
	input logic clk,
	input logic rst,
	output logic [63:0] PCOut,
	output logic [2:0] ALUFunct,
	output logic DMemWrite,
	output logic [63:0] ALUOut,
	output logic [4:0] state,
	output logic [63:0] RegALUOutOut,
	output logic [63:0] RegBOut,
	output logic [63:0] MuxAOut,
	output logic [63:0] MuxBOut,
	output logic [1:0] ALUSrcB
);
	
	logic 	[63:0] RegAIn, RegBIn;
	
	logic 	[4:0] Instr19_15;
	logic 	[4:0] Instr24_20;
	logic 	[4:0] Instr11_7;
	logic 	[6:0] Instr6_0;
	logic 	[31:0] Instr31_0;

	logic PCWrite;
	logic PCWriteCond;
	logic 	[31:0] IMemOut;
	logic 	PCSrc; 
	 
	
	logic 	ALUSrcA;
	logic 	LoadRegA;
	logic 	LoadRegB; 
	logic 	LoadALUOut;
	logic 	WriteReg;
	logic 	[2:0]MemToReg;
	logic 	LoadIR; 
	logic 	IMemWrite; 
	 
	logic 	LoadMDR; 
	logic 	Reset;
	logic	BranchOp;
	
	logic 	[63:0] PCIn;
	logic 	[63:0] WriteData;
	logic 	[63:0] RegAOut;
	logic 	[63:0] SignalExtendOut;
	logic 	[63:0] ShiftLeftOut;
	logic 	zero;
	
	
	logic 	[63:0] DataMemoryOut;
	logic 	[63:0] MemDataRegOut;
	logic 	[63:0] BranchOpOut;
	logic	LoadPC;
	
	logic [1:0]tam;
	logic [1:0]lim;
	logic [63:0]limitOut;
	logic [1:0]shift;
	logic [63:0]ShiftModuleOut;

	initial begin
		PCOut = 64'b0;

	end
	
	unidadeControle UC(
		.clk(clk),
		.rst(rst),
		.PCSrc(PCSrc),
		.ALUFunct(ALUFunct),
		.ALUSrcB(ALUSrcB),
		.PCWrite(PCWrite),
		.ALUSrcA(ALUSrcA),
		.LoadRegA(LoadRegA),
		.LoadRegB(LoadRegB),
		.LoadALUOut(LoadALUOut),
		.WriteReg(WriteReg),
		.MemToReg(MemToReg),
		.LoadIR(LoadIR),
		.IMemWrite(IMemWrite),
		.DMemWrite(DMemWrite),
		.LoadMDR(LoadMDR),
		.Reset(Reset),
		.BranchOp(BranchOp),
		.PCWriteCond(PCWriteCond),
		.instruction(IMemOut),
		.state(state),
		.tam(tam),
		.lim(lim),
		.Shift(shift)
	);

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
		.In2(64'b0000000000000000000000000000000000000000000000000000000000000100),
		.In3(SignalExtendOut),
		.In4(ShiftLeftOut),
		.Out(MuxBOut)
	);

	Ula64 ALU(
		.A(MuxAOut),
		.B(MuxBOut),
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

	Memoria64_test DataMemory(
		.raddress(RegALUOutOut),
		.waddress(RegALUOutOut),
		.Clk(clk),
		.Datain(RegBOut),
		.Dataout(DataMemoryOut),
		.Wr(DMemWrite),
		.tam(tam)
	);

	Registrador64 MemDataReg(
		.Clk(clk),
		.Reset(Reset),
		.Load(LoadMDR),
		.Entrada(DataMemoryOut),
		.Saida(MemDataRegOut)
	);
	
	Limitador limita_l(
		.lim(lim),
		.In(MemDataRegOut),
		.Out(limitOut)
	);
	
	Deslocamento ShiftModule(
		.Shift(shift),
		.Entrada(RegAIn),
		.N(Instr31_0),
		.Saida(ShiftLeftOut)
	);
	
	Mux8 MuxMemToReg(
		.Control(MemToReg),
		.In1(RegALUOutOut),
		.In2(limitOut),
		.In3(SignalExtendOut),
		.In4(ShiftModuleOut),
		.Out(WriteData)
	);

	SignalExtend SignExtendModule(
		.Inst(Instr31_0),
		.Out(SignalExtendOut)
	);

	ShiftLeft ShiftLeftModule(
		.In(SignalExtendOut),
		.Out(ShiftLeftOut)
	);

	Mux1 muxBranchOp(
		.Control(BranchOp),
		.In1(zero),
		.In2(~zero),
		.Out(BranchOpOut)
	);
	
	always_comb begin
		LoadPC <= ((BranchOpOut & PCWriteCond) | PCWrite);
	end
	
endmodule 