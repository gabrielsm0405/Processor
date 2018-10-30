module Limitador(input logic [31:0]instrucao, output logic [63:0] Out, input logic [63:0] mdr);
	always_comb  begin
		case (instrucao[6:0])
			7'b0000011: begin // Tipo I
				case (instrucao[14:12])
					3'b011: begin //Ld
						Out = mdr;
					end
					3'b010: begin //Lw
						Out[31:0] = mdr[31:0];
						case(mdr[31])
							1: begin
								Out[63:32] = 32'b11111111111111111111111111111111;
							end
						
							default: begin
								Out[63:32] = 32'b00000000000000000000000000000000;
							end
						endcase
					end
					3'b100: begin //Lbu
						Out[7:0] = mdr[7:0];
						Out[63:8] = 56'b00000000000000000000000000000000000000000000000000000000;
					end
					3'b001: begin //Lh
						Out[15:0] = mdr[15:0];
						case(mdr[15])
							1:
							begin
								Out[63:16] = 48'b111111111111111111111111111111111111111111111111;
							end
							
							default:
							begin
								Out[63:16] = 48'b000000000000000000000000000000000000000000000000;
							end
						endcase
					end
					default: begin
						Out = mdr;
					end
				endcase
			end
			default:begin
				Out = mdr;
			end
		endcase
	end
endmodule
