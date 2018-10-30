module unidadeProcessamento_test(
	input logic clk,
	input logic Reset,
	output logic [63:0] PCOut,
	output logic [2:0] ALUFunct,
	output logic DMemWrite,
	output logic [63:0] ALUOut,
	output logic [5:0] state,
	output logic [63:0] RegALUOutOut,
	output logic [63:0] RegBOut,
	output logic [63:0] DataMemoryOut,
	output logic [63:0] MemDataRegOut,
	output logic 	[6:0] Instr6_0,
	output logic 	LoadMDR,
	output logic 	[63:0] SignalExtendOut,
	output logic 	[31:0] Instr31_0,
	output logic 	[63:0] LimitadorOut,
	output logic 	[63:0] StoreSelectOut
	);
	
	logic 	[63:0] RegAIn, RegBIn;
	
	logic 	[4:0] Instr19_15;
	logic 	[4:0] Instr24_20;
	logic 	[4:0] Instr11_7;

	logic PCWrite;
	logic PCWriteCond;
	logic 	[31:0] IMemOut;
	logic 	[1:0]PCSrc; 
	 
	logic 	[1:0] ALUSrcB;
	logic 	ALUSrcA;
	logic 	LoadRegA;
	logic 	LoadRegB; 
	logic 	LoadALUOut;
	logic 	WriteReg;
	logic 	[3:0]MemToReg;
	logic 	LoadIR; 
	logic 	IMemWrite; 
	
	logic [63:0]EPC;
	logic [31:0]MuxSrcExcOut;
	logic [1:0]SrcExc;
	logic LoadExc;

	logic	[1:0]BranchOp;
	
	logic 	[63:0] PCIn;
	logic 	[63:0] WriteData;
	logic 	[63:0] RegAOut;
	logic 	[63:0] ShiftLeftOut;
	logic 	zero;
	logic   Menor;
	logic   Overflow;
	logic 	[63:0] MuxAOut;
	logic 	[63:0] MuxBOut;
	logic 	[1:0] tam;
	
	logic [1:0]ShiftControl;
	logic [63:0]DeslocamentoOut;
	logic [5:0] ShiftN;
	
	logic 	[63:0] BranchOpOut;
	logic	LoadPC;
	
	initial begin
		PCOut = 64'b0;

	end
	
	unidadeControle UC(
		.clk(clk),
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
		.BranchOp(BranchOp),
		.PCWriteCond(PCWriteCond),
		.instruction(Instr31_0),
		.state(state),
		.tam(tam),
		.Reset(Reset),
		.ShiftControl(ShiftControl),
		.LoadExc(LoadExc),
		.SrcExc(SrcExc)
	);

	Registrador64 pc(
		.Clk(clk), 
		.Reset(Reset), 
		.Load(LoadPC), 
		.Entrada(PCIn), 
		.Saida(PCOut)
	);

	Mux4 MuxSrcExc(
		.Control(SrcExc),
		.In1(PCOut[63:0]),
		.In2(64'b0000000000000000000000000000000000000000000000000000000011111110),
		.In3(64'b0000000000000000000000000000000000000000000000000000000011111111),	
		.Out(MuxSrcExcOut)
	);

	Memoria32 IMem(
		.raddress(MuxSrcExcOut), 
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
		.z(zero),
		.Menor(Menor),
		.Overflow(Overflow)
	);

	Registrador64 RegALUOut(
		.Clk(clk),
		.Reset(Reset),
		.Load(LoadALUOut),
		.Entrada(ALUOut),
		.Saida(RegALUOutOut)
	);

	Mux4 MuxPCSrc(
		.Control(PCSrc),
		.In1(ALUOut),
		.In2(RegALUOutOut),
		.In3(IMemOut),
		.Out(PCIn)
	);

	Registrador64 SEPC(
		.Clk(clk),
		.Reset(Reset),
		.Load(LoadExc),
		.Entrada(PCOut),
		.Saida(EPC)
	);

	Memoria64 DataMemory(
		.raddress(RegALUOutOut),
		.waddress(RegALUOutOut),
		.Clk(clk),
		.Datain(StoreSelectOut),
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

	Limitador Limitador(
		.instrucao(Instr31_0),
		.mdr(MemDataRegOut),
		.Out(LimitadorOut)
	);

	StoreSelect StoreSelect(
		.Inst(Instr31_0),
		.MemIn(MemDataRegOut),
		.RegIn(RegBOut),
		.Out(StoreSelectOut)
	);

	Mux8 MuxMemToReg(
		.Control(MemToReg),
		.In1(RegALUOutOut),
		.In2(LimitadorOut),
		.In3(SignalExtendOut),
		.In4(PCOut),
		.In5(DeslocamentoOut),
		.In6(Menor),
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

	Mux3 muxBranchOp(
		.Control(BranchOp),
		.In1(zero),
		.In2(!zero),
		.In3(ALUOut),
		.Out(BranchOpOut)
	);
	DivImm DivImm(
		.Inst(Instr31_0),
		.Out(ShiftN)
	);

	Deslocamento ModuloDeslocamento(
		.Shift(ShiftControl),
		.Entrada(RegAIn),
		.N(ShiftN),
		.Saida(DeslocamentoOut)
	);
	always_comb begin
		LoadPC <= ((BranchOpOut & PCWriteCond) | PCWrite);
	end
	
endmodule 