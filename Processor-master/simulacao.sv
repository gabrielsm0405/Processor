`timescale 1ps/1ps

module simulacao;
    localparam CLKPERIOD = 1000;
    localparam CLKDELAY = CLKPERIOD / 2;

    logic clk;
    logic rst;
    logic [63:0]Out;

    unidadeProcessamento_test test (
        .clk(clk),        
        .PCOut(Out)
	); 

    initial begin 
        clk = 1'b1;
        rst = 1'b1;
        $monitor($time,"PC - %d", Out);  
    end

    always begin
        #(CLKDELAY) clk = ~clk;
        rst <= 0; // reset só deve mudar depois da primeira mudança de clk, acho que funciona.
    end
                
endmodule

