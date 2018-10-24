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
    logic[4:0] state;
    logic[63:0]RegBOut;
    logic [63:0] DataMemoryOut;
    logic [63:0] MemDataRegOut;
    logic [6:0] Instr6_0;

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
        .Instr6_0(Instr6_0)
	); 

    initial begin 
        clk = 1'b1;
        $monitor($time,"PC: %d, Estado: %d, Sinal da Mem Dados: %d, Saída da Mem Dados: %d, Saída do MDR: %d, OPCode: %b", Out, state, DMemWrite, DataMemoryOut, MemDataRegOut, Instr6_0);  
        Reset = 1'b0;
        #(CLKPERIOD)
        Reset = 1'b1;
        #(CLKPERIOD)
        Reset = 1'b0; 
    end

    always #(CLKDELAY) clk = ~clk;            

endmodule

