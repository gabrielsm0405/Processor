module Limitador(input logic [1:0]lim, output logic [63:0] Out, input logic [63:0] In);
	always_comb  begin
		case (lim)
			2'b00: begin // ld
				Out <= In;
			end
			2'b01: begin // lw
				Out[31:0] <= In[31:0];
				case(In[31]) 
					1:
					begin	
						Out[63:32] <= 32'b11111111111111111111111111111111;
					end
				
					default:
					begin
						Out[63:32] <= 32'b00000000000000000000000000000000;
					end
				endcase			
			end
			2'b10: begin // lh
				Out[15:0] <= In[15:0];
				case(In[15]) 
					1:
					begin	
						Out[63:16] <= 48'b111111111111111111111111111111111111111111111111;
					end
					
					default:
					begin
						Out[63:16] <= 48'b000000000000000000000000000000000000000000000000;
					end
				endcase			
			end
			2'b11: begin // lbu
				Out[7:0] <= In[7:0];
				Out[63:8] <= 48'b00000000000000000000000000000000000000000000000000000000;			
			end
			default:begin
				Out <= In;
			end
		endcase		
	end
endmodule
