module Mux2(input logic Control, input logic [63:0] In1, In2, output logic [63:0]Out);
	always_comb begin
		if(Control == 0) 
			Out = In1;
		else
			Out = In2;
	end

endmodule // mux