module SignalExtendExc(input logic[31:0]Inst, output logic[63:0]Out);
		always_comb begin	
			Out[63:32] <= 32'b00000000000000000000000000000000;
			Out[31:0] <= Inst[31:0];
		end
endmodule