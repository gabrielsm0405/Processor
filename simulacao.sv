`timescale 1ps/1ps
//oi
module simulacao;
    localparam CLKPERIOD = 1000;
    localparam CLKDELAY = CLKPERIOD / 2;

    logic clk;
    logic Reset;
    logic [63:0]Out;
    logic [63:0]ALUOut;
    logic [63:0] RegALUOutOut;
    logic DMemWrite;
    logic [2:0]ALUFunct;
    logic[5:0] state;
    logic[63:0]RegBOut;
    logic [63:0] DataMemoryOut;
    logic [63:0] MemDataRegOut;
    logic [6:0] Instr6_0;
    logic [63:0] SignalExtendOut;
    logic [31:0] Instr31_0;
    logic [63:0] SelectStoreOut;
    logic [63:0]RegStoreOut;

    unidadeProcessamento_test test (
        .clk(clk),        
        .PCOut(Out),
        .Reset(Reset),
        .ALUOut(ALUOut),
        .DMemWrite(DMemWrite),
        .ALUFunct(ALUFunct),
        .state(state),
        .RegALUOutOut(RegALUOutOut),
        .RegBOut(RegBOut),
        .DataMemoryOut(DataMemoryOut),
        .MemDataRegOut(MemDataRegOut),
        .Instr6_0(Instr6_0),
	.SignalExtendOut(SignalExtendOut),
	.Instr31_0(Instr31_0),
    .SelectStoreOut(SelectStoreOut),
    .RegStoreOut(RegStoreOut)
	); 

    initial begin 
        clk = 1'b1;
        $monitor($time,"PC: %d, Estado: %d, SelectOut: %b, MemOut: %b, Alu: %d, RegStoreOut: %b", Out, state, SelectStoreOut, MemDataRegOut, RegALUOutOut, RegStoreOut);  
        Reset = 1'b0;
        #(CLKPERIOD)
        Reset = 1'b1;
        #(CLKPERIOD)
        Reset = 1'b0; 
    end

    always #(CLKDELAY) clk = ~clk;            

endmodule

