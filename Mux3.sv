module Mux3(input logic [1:0]Control,input logic In1, input logic In2, input logic [63:0]In3, output logic Out);
	always_comb begin
		case(Control)
			2'b00:		begin
			Out <= In1;
			end
			2'b01:		begin
			Out <= In2;
			end
			2'b10:		begin
				if(In3[63]==0)
					Out <= 1;
				else
					Out <= 0;
			end
			2'b11:		begin
				if(In3[63]==1)
					Out <= 1;
				else
					Out <= 0;
			end
	endcase
	end

endmodule // mux