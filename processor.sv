module uc (input logic clock, input logic[31:0] instruction, PCWrite, PCWriteCond, BranchOp, PCSrc, ALUFunct, ALUSrcB, ALUSrcA, LoadRegA, LoadRegB, LoadALUOut, LoadMDR, DMemWrite, IMemWrite, LoadIR, MemToReg, WriteReg)
	output logic PCWrite, PCWriteCond, BranchOp, PCSrc, ALUSrcA, LoadRegA, LoadRegB, LoadALUOut, LoadMDR, DMemWrite, IMemWrite, LoadIR, WriteReg;	
	output logic[1:0] ALUSrcB, MemToReg;
	output logic[2:0] ALUFunct;

	reg [4:0]state;
	parameter init_state = 0;
	parameter decod = 1;
	parameter cal_offset = 2;
	parameter sum_reg = 3;
	parameter sub_reg = 4;
	parameter read_mem = 5;
	parameter write_mem = 6;
	parameter lui = 7;
	parameter beq_wpc = 8;
	parameter bne_wpc = 9;
	parameter ld_wreg = 10;
	parameter add_wreg = 11;

	always_ff@(posedge clk) begin
		case(state)
			init_state: begin
				IMemWrite <= 1;
				ALUSrcA <= 1;
				DMemWrite <= 0;
				ALUSrcB <= 2'b01;
				ALUFunct <= 3'b001
				PCWrite <= 1;
				PCSrc <= 0;
				state <= decod;
			end
			decod: begin
				LoadRegA <= 1;
				LoadRegB <= 1;
				LoadIR <= 1;

				ALUSrcA <= 0;
				ALUSrcB <= 2'b11;
				ALUFunct <= 3'b001;
				LoadALUOut <= 1;
				case([6:0]instruction)
					7'b0110011: //type r
					begin
						case([31:24]instruction)
							7'b0000000: // add
							begin
								ALUSrcA <= 2'b01;
								ALUSrcB <= 0;
								ALUFunct <= 3'b001;
								LoadALUOut <= 1;
								state <= sum_reg; 	
							end
							7'b0100000: // sub
							begin 
								ALUSrcA <= 2'b01;
								ALUSrcB <= 0;
								ALUFunct <= 3'b010;
								LoadALUOut <= 1;
								state <= sub_reg; 	
							end
						endcase
					end
					7'b0100011: //type s
					begin
						ALUSrcA <= 2'b01;
						ALUSrcB <= 2'b10;
						ALUFunct <= 3'b001;
						LoadALUOut <= 1;
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0010011: //type i (ADDI)
					begin
						ALUSrcA <= 2'b01;
						ALUSrcB <= 2'b10;
						ALUFunct <= 3'b001;
						LoadALUOut <= 1;
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0000011: //type i (LD)
					begin
						ALUSrcA <= 2'b01;
						ALUSrcB <= 2'b10;
						ALUFunct <= 3'b001;
						LoadALUOut <= 1;
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					7'b0110111: //type u
					begin
						MemToReg = 2;
						WriteReg = 1;
						state <= lui; 
					end
					7'b1100111: //type sb
					begin
						case([10:7]instruction)
							3'b000: // BEQ
							begin 
								ALUSrcA <= 2'b01;
								ALUSrcB <= 0;
								ALUFunct <= 3'b010;
								PCWriteCond = 1
								PCSrc = 2'b01;
								BranchOp = 0;
								state <= init_state; //volta pro começo 	
							end
							3'b001: // BNE
							begin 
								ALUSrcA <= 2'b01;
								ALUSrcB <= 0;
								ALUFunct <= 3'b010;
								PCWriteCond = 1;
								PCSrc = 2'b01;
								BranchOp = 1;
								state <= init_state; //volta pro começo 	
							end
						endcase
					end		
				endcase
			end //end do decod
			cal_offset: begin

						end 
			sum_reg: begin

					 end	
			sub_reg: begin

					 end	
			read_mem: begin

					  end
			write_mem: begin

					   end
			lui: begin

				 end

		 	beq_wpc: begin

		 			 end
		 			 
		 	bne_wpc: begin
		 			 
		 			 end

		 	ld_wreg: begin
		 			 
		 			 end

		 	add_wreg: begin

		 			  end		 	
		endcase 
	end


endmodule // uc