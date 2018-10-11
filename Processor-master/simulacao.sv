`timescale 1ps/1ps
//oi
module simulacao;
    localparam CLKPERIOD = 1000;
    localparam CLKDELAY = CLKPERIOD / 2;

    logic clk;
    logic rst;
    logic [63:0]Out;

    unidadeProcessamento_test test (
        .clk(clk),        
        .PCOut(Out),
	.rst(rst)
	); 

    initial begin 
        clk = 1'b1;
        rst = 1'b1;
        $monitor($time,"PC - %d, rst - %b", Out,rst);  
    end

    always #(CLKDELAY) clk = ~clk;
    
    always @ (posedge clk) rst <= 0;	            

endmodule

