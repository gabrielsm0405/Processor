module unidadeControle (
	input logic clk,
	output logic PCSrc,
	output logic [2:0] ALUFunct,
	output logic [1:0] ALUSrcB,
	output logic PCWrite,
	output logic ALUSrcA,
	output logic LoadRegA,
	output logic LoadRegB,
	output logic LoadALUOut,
	output logic WriteReg,
	output logic [1:0] MemToReg,
	output logic LoadIR,
	output logic IMemWrite,
	output logic DMemWrite,
	output logic LoadMDR,
	output logic BranchOp,
	output logic PCWriteCond,
	input logic[31:0] instruction,
	output logic [4:0] state
);
	

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

	parameter Rtype = 7'b0110011;
	parameter Stype = 7'b0100011;
	parameter SBtype = 7'b1100111;
	parameter Addi = 7'b0010011;
	parameter Ld = 7'b0000011;
	parameter Utype = 7'b0110111;
	parameter Add = 7'b0000000;
	parameter Sub = 7'b0100000;

	always @(posedge clk) begin	
		case(state)
			init_state: begin
				PCWrite <= 1;
				PCSrc <= 0;
				ALUFunct <= 3'b001;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b01;
				LoadIR <= 1;

				PCWriteCond <= 0;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;

				state <= decod;
			end
			decod: begin
				LoadRegA <= 1;
				LoadRegB <= 1;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b11;
				ALUFunct <= 3'b001;
				LoadALUOut <=1;

				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;				
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;

				case(instruction[6:0])
					Rtype: //type r
					begin
						case(instruction[31:25])
							Add: // add
							begin
								state <= sum_reg; 	
							end
							Sub: // sub
							begin
								state <= sub_reg; 	
							end
						endcase
					end
					Stype: //type s
					begin
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					Addi: //type i (ADDI)
					begin
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					Ld: //type i (LD)
					begin
						state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					Utype: //type u
					begin
						state <= lui; 
					end
					SBtype: //type sb
					begin
						case(instruction[14:12]) // funct3
							3'b000: // BEQ
							begin
								state <= beq_wpc; //volta pro comeÃ§o 	
							end
							3'b001: // BNE
							begin
								state <= bne_wpc; //volta pro comeÃ§o 	
							end
						endcase
					end		
					default: begin
						state <= 0; // TODO - tratar excessão
					end
				endcase
			end
			cal_offset: begin
				ALUFunct <= 3'b001;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b10;
				LoadALUOut <=1;

				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				LoadRegA <= 0;
				LoadRegB <= 0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 1; // obs
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;

				case (instruction[6:0]) // sai de offset e vai para umas das funÃ§Ãµes
					Stype: //type sd
					begin
						state <= write_mem; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					Addi: //type i (ADDI)
					begin
						state <= add_wreg; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					Ld: //type i (LD)
					begin
						state <= read_mem; //calcula o OFFSET para o LOAD, STORE, E ADDI
					end
					default: begin  
						state <= 0; // TODO - tratar excessão
					end		
				endcase
			end
			sum_reg: begin
				ALUFunct <= 3'b001;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b00;
				LoadALUOut <= 1;

				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				LoadRegA <= 0;
				LoadRegB <= 0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;

				state <= add_wreg;
			end	
			sub_reg: begin
				ALUFunct <= 3'b010;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b00;
				LoadALUOut <=1;

				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				LoadRegA <= 0;
				LoadRegB <= 0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;

				state <= add_wreg;
			end
			read_mem: begin
				LoadMDR <= 0; // obs
				DMemWrite <= 0;

				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;				
				IMemWrite <= 0;
				LoadIR <= 0;

				state <= ld_wreg;
			end
			write_mem: begin
				DMemWrite <= 1;

				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				state<=init_state;
			end
			lui: begin
				MemToReg <= 2'b10;
				WriteReg <= 1;

				PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;

				state <=init_state;
			end
		 	beq_wpc: begin
		 		ALUFunct <= 3'b010;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b00;
				PCWriteCond <= 1;
				BranchOp <= 0;
				PCSrc <= 1;

		 		PCWrite <= 0;	
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				
				state <= init_state;
		 	end	 
		 	bne_wpc: begin
		 		ALUFunct <= 3'b010;
				ALUSrcA <= 1;
				ALUSrcB <= 2'b00;
				BranchOp <= 1;
		 		
				PCWriteCond <= 1;
				PCSrc <= 1;
				PCWrite <= 0;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 0;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				
				state <= init_state;
		 	end
		 	ld_wreg: begin
		 		WriteReg <= 1;
				MemToReg <= 1;

		 		PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				BranchOp <= 0;

				state <= init_state;
		 	end
		 	add_wreg: begin
		 		PCWrite <= 0;
				PCWriteCond <= 0;
				PCSrc <= 0;
				ALUFunct <= 3'b000;
				ALUSrcA <= 0;
				ALUSrcB <= 2'b00;
				LoadRegA <= 0;
				LoadRegB <= 0;
				LoadALUOut <=0;
				WriteReg <= 1;
				MemToReg <= 0;
				LoadMDR <= 0;
				DMemWrite <= 0;
				IMemWrite <= 0;
				LoadIR <= 0;
				BranchOp <= 0;

				state <= init_state;
		 	end		 
		 	default: begin
		 		state <= 0;
		 	end
		endcase
	end 



endmodule // uc.
