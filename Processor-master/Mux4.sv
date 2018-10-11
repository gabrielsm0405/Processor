module Mux4(input logic [1:0]Control,input logic [63:0]In1, input logic [63:0] In2, input logic [63:0]In3, In4,output logic [63:0] Out);
	always_comb begin
		case(Control)
			2'b00:		begin
			Out <= In1;
			end
			2'b01:		begin
			Out <= In2;
			end
			2'b10:		begin
			Out <= In3;
			end
			2'b11:		begin
			Out <= In4;
			end
	endcase
	end

endmodule // mux