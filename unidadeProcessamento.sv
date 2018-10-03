module unidadeProcessamento(
	input logic clk, 
	input logic PCSrc, 
	input logic [2:0] ALUFunct, 
	input logic [2:0] ALUSrcB, 
	input logic ALUSrcA, 
	input logic LoadRegA, 
	input logic LoadRegB, 
	input logic LoadALUOut, 
	input logic PCWrite, 
	input logic LoadIR, 
	input logic IMemLoad, 
	input logic DMemLoad, 
	input logic LoadMDR, 
	input logic Reset,
	output logic [31:0] inst);

	wire [63:0] PCIn, PCOut;

	Registrador64 pc(clk, Reset, PCSrc, PCIn, PCOut);

endmodule 