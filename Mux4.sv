module SignalExtend(Inst, Out);
	input logic [3:0]Control, logic [63:0]In1, logic [63:0]In2;
	output logic [63:0]Out;
	always_comb begin
		if(Control == 3'b000) 
			Out = In1;
		else if(Control == 3'b001)
			Out = In2;
		else if(Control == 3'b010)
			Out = In3;
		else if(Control == 3'b011)
			Out = In4;
	end

endmodule // mux