module SignalExtend(input logic [31:0] Inst, output logic [63:0] Out);
	always_comb  begin
		case (Inst[6:0])
			7'b0010011: begin
				Out[11:0] <= Inst[31:20];
				case(Inst[31])
					1:
					begin
						Out[63:12] <= 52'b1111111111111111111111111111111111111111111111111111;	
					end
					default:
					begin
						Out[63:12] <= 52'b0000000000000000000000000000000000000000000000000000;
					end
				endcase
			end
			7'b0000011: begin
				Out[11:0] <= Inst[31:20];
				case(Inst[31]) 
					1:
					begin	
						Out[63:12] <= 52'b1111111111111111111111111111111111111111111111111111;
					end
				
					default:
					begin
						Out[63:12] <= 52'b0000000000000000000000000000000000000000000000000000;
					end
				endcase
			end
			7'b0100011: begin
				Out[4:0] <= Inst[11:7];
				Out[11:5] <= Inst[31:25];		
				case(Inst[31])
					1: 
					begin
						Out[63:12] <= 52'b1111111111111111111111111111111111111111111111111111;
					end
					default:
					begin
						Out[63:12] <= 52'b0000000000000000000000000000000000000000000000000000;
					end
				endcase
			end
			7'b1100111: begin
				Out[10] <= Inst[7];
				Out[3:0] <= Inst[11:8];
				Out[9:4] <= Inst[30:25];
				Out[11] <= Inst[31];
				case(Inst[31])
					1: begin
						Out[63:12] <=  52'b1111111111111111111111111111111111111111111111111111;
					end
					default:
					begin
						Out[63:12] <= 52'b0000000000000000000000000000000000000000000000000000;
					end
				endcase
			end
			7'b0110111: begin
				Out[19:0] <= Inst[31:12];
				case(Inst[31]) 
					1: begin
						Out[63:20] <=  44'b11111111111111111111111111111111111111111111;
					end
					default:
					begin
						Out[63:20] <= 44'b00000000000000000000000000000000000000000000;
					end
				endcase
			end
		endcase
		
	end


endmodule
