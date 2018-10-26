module StoreSelect(input logic [31:0]Inst, output logic [63:0] Out, input logic [63:0] In);
	always_comb  begin
		case (Inst[6:0])
			7'b0000011: begin // ld
				case(Inst[14:12])
					3'b111:begin // sd

					end
					3'b111:begin // sw
						
					end
					3'b111:begin // sh
						
					end
					3'b111:begin // sb
						
					end
				endcase
			end // 7'b0000011:end
		endcase		
	end
endmodule
