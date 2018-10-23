module Mux8 (input logic [2:0]Control, logic [63:0]In1,logic [63:0]In2,logic [63:0]In3,logic [63:0]In4,logic [63:0]In5, output logic [63:0] Out);
	always_comb begin
		case(Control)
			3'b000: begin
				Out <= In1;
			end
			3'b001: begin
				Out <= In2;
			end
			3'b010: begin
				Out <= In3;
			end
			3'b011: begin
				Out <= In4;
			end
			3'b100: begin
				Out <= In5;
			end
		endcase
	end
endmodule