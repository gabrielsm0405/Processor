module Mux2(input logic Control, input logic [63:0] In1, In2, output logic [63:0]Out);
	always_comb begin
		case(Control)
		0:begin
			Out = In1;
		end
		1:begin
			Out = In2;
		end
		endcase // Control
	end

endmodule // mux