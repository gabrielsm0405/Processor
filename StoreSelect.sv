module StoreSelect(
	input logic [31:0]Inst,
	input logic [63:0]MemIn,
	input logic [63:0]RegIn,
	output logic [63:0]Out
	);
	always_comb  begin
		case (Inst[6:0])
			7'b0100011: begin // sd
				case(Inst[14:12])
					3'b111:begin // sd
						Out = RegIn;
					end
					3'b010:begin // sw
						Out[31:0] = RegIn[31:0];
						Out[63:32] = MemIn[63:32];
					end
					3'b001:begin // sh
						Out[15:0] = RegIn[15:0];
						Out[63:16] = MemIn[63:16];
					end
					3'b000:begin // sb
						Out[7:0] = RegIn[7:0];
						Out[63:8] = MemIn[63:8];
					end
				endcase
			end // 7'b0
			default:begin
				Out = RegIn;
			end
		endcase		
	end
endmodule
