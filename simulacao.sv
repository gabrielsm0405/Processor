`timescale 1ps/1ps
//oi
module simulacao;
    localparam CLKPERIOD = 1000;
    localparam CLKDELAY = CLKPERIOD / 2;

    logic clk;
    logic rst;
    logic [63:0]Out;
    logic [63:0]ALUOut;
    logic [63:0] RegALUOutOut;
    logic DMemWrite;
    logic [2:0]ALUFunct;
    logic[4:0] state;
    logic[63:0]RegBOut;
    unidadeProcessamento_test test (
        .clk(clk),        
        .PCOut(Out),
	   .rst(rst),
        .ALUOut(ALUOut),
        .DMemWrite(DMemWrite),
	   .ALUFunct(ALUFunct),
	   .state(state),
        .RegALUOutOut(RegALUOutOut),
        .RegBOut(RegBOut)
	); 

    initial begin 
        clk = 1'b1;
        rst = 1'b1;
        $monitor($time,"PC - %d, Regb - %d, Aluout - %d, Dmem- %b, State- %d, RegAlu - %d", Out,RegBOut, ALUOut, DMemWrite, state, RegALUOutOut);  
    end

    always #(CLKDELAY) clk = ~clk;
    
    always @ (posedge clk) rst <= 0;	            

endmodule

