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
			7'b1100111: begin //tipo i e tipo sb
				/*case(Inst[14:12])
					3'b000: begin //jalr
						Out[11:0] <= Inst[31:20];
						case(Inst[31])
							1: begin
								Out[63:12] <=  52'b1111111111111111111111111111111111111111111111111111;
							end
							default:
							begin
								Out[63:12] <= 52'b0000000000000000000000000000000000000000000000000000;
							end
						endcase
					end // 3'b000:*/
					//default: begin 
						Out[11] <= Inst[7];
						Out[4:1] <= Inst[11:8];
						Out[10:5] <= Inst[30:25];
						Out[12] <= Inst[31];
						Out[0] <= 1'b0;
						case(Inst[31])
							1: begin
								Out[63:13] <=  51'b111111111111111111111111111111111111111111111111111;
							end
							default:
							begin
								Out[63:13] <= 51'b000000000000000000000000000000000000000000000000000;
							end
						endcase
					//end
				//endcase // Inst[14:12]
					
			end
			7'b0110111: begin
				Out[11:0] <= 12'b000000000000;
				Out[31:12] <= Inst[31:12];
				case(Inst[31]) 
					1: begin
						Out[63:32] <= 32'b11111111111111111111111111111111;
					end
					default:
					begin
						Out[63:32] <= 32'b00000000000000000000000000000000;
					end
				endcase
			end
			7'b1101111: begin //jal
				case(Inst[31])
					1: begin
						Out[63:21] <= 43'b1111111111111111111111111111111111111111111;
					end
					default:
					begin
						Out[63:21] <= 43'b0000000000000000000000000000000000000000000;
					end
				endcase

				Out[20] <= Inst[31];
				Out[10:1] <= Inst[30:21];
				Out[11] <= Inst[20];
				Out[19:12] <= Inst[19:12];

				Out[0] <=1'b0;
			end
		endcase
		
	end


endmodule
