`timescale 1ps/1ps

module simulacao;
    localparam CLKPERIOD = 1000;
    localparam CLKDELAY = CLKPERIOD / 2;

    logic clk;
    logic [63:0]Out;
	logic PCWrite;
	logic PCWriteCond;
    logic [31:0] IMemOut;

    unidadeProcessamento_test test (
        .clk(clk),        
        .PCOut(Out),
        .PCWrite(PCWrite),
        .PCWriteCond(PCWriteCond),
        .IMemOut(IMemOut)
	); 

    initial begin 
        clk = 1'b1;
        $monitor($time,"IMemOut - %b   PCWRITE - %b   PCWRITECOND - %b", IMemOut, PCWrite, PCWriteCond);  
    end

    always #(CLKDELAY) clk = ~clk;
    
                
endmodule

