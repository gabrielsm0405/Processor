module unidadeProcessamento(input clk, PCSrc, ALUFunct, ALUSrcB, ALUSrcA, LoadRegA, LoadRegB, LoadALUOut, PCWrite, LoadIR, IMemLoad, DMemLoad, LoadMDR, inst);
	logic clk, PCSrc, ALUSrcA, LoadRegA, LoadRegB, LoadALUOut, PCWrite, LoadIR, IMemLoad, DMemLoad, LoadMDR;
	logic [2:0] ALUFunct, ALUSrcB;
	logic [31:0] inst;

	reg [63:0] PC;
		
endmodule 