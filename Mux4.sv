module Mux4(input logic [3:0]Control,input logic [63:0]In1,input logic [63:0] In2,input logic [63:0] In3,input logic [63:0] In4,output logic [63:0] Out);
	//input logic [3:0]Control, [63:0]In1, [63:0]In2, [63:0]In3, [63:0]In4;
	//output logic [63:0]Out;
	always_comb begin
		if(Control == 3'b00) 
			Out = In1;
		else if(Control == 3'b01)
			Out = In2;
		else if(Control == 3'b10)
			Out = In3;
		else if(Control == 3'b11)
			Out = In4;
	end

endmodule // mux