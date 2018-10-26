module unidadeControle (
	input logic clk,
	input logic Reset,
	output logic PCSrc,
	output logic [2:0] ALUFunct,
	output logic [1:0] ALUSrcB,
	output logic PCWrite,
	output logic ALUSrcA,
	output logic LoadRegA,
	output logic LoadRegB,
	output logic LoadALUOut,
	output logic WriteReg,
	output logic [2:0] MemToReg,
	output logic LoadIR,
	output logic IMemWrite,
	output logic DMemWrite,
	output logic LoadMDR,
	output logic [1:0]BranchOp,
	output logic PCWriteCond,
	input logic[31:0] instruction,
	output logic [4:0] state,
	output logic [1:0] tam,
	output logic [1:0]ShiftControl
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
	parameter the_next_episode = 12; //estado de espera pós beq
	parameter blt_wpc = 13;
	parameter bge_wpc = 14;
	parameter and_reg = 15;
	parameter slli = 19;
	parameter srli = 20;
	parameter srai = 21;
	parameter nothing = 22;
	parameter excecao = 23;
	parameter jal_jalr_register = 24;
	parameter jal_jalr_offset = 25;
	parameter jalr_loadReg = 26;
	parameter jalr_opImmReg = 27;
	parameter slti=28;
	parameter slt=29;

	parameter Rtype = 7'b0110011;
	parameter Stype = 7'b0100011;
	parameter SBtype = 7'b1100111;
	parameter SBBeq = 7'b1100011;
	parameter Addi = 7'b0010011;
	parameter Ld = 7'b0000011;
	parameter Utype = 7'b0110111;
	parameter Add = 7'b0000000;
	parameter Sub = 7'b0100000;
	parameter Break = 7'b1110011;
	parameter Jal = 7'b1101111;

	always @(posedge clk or posedge Reset) begin	
		if(Reset) begin
			PCWrite <= 0;
			PCSrc <= 0;
			ALUFunct <= 3'b000;
			ALUSrcA <= 0;
			ALUSrcB <= 2'b00;
			LoadIR <= 1;

			PCWriteCond <= 0;
			LoadRegA <= 0;
			LoadRegB <= 0;
			LoadALUOut <= 0;
			WriteReg <= 0;
			MemToReg <= 0;
			LoadMDR <= 0;
			DMemWrite <= 0;
			IMemWrite <= 0;

			state <= init_state;
		end
		else begin
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
					tam <= 2'b00;
					case(instruction[6:0])
						Break:
						begin
							state <= nothing;
						end
						Rtype: //type r
						begin
							case(instruction[31:25])
								Add: // add
								begin
									case(instruction[14:12])
										3'b000: begin
											state <= sum_reg;
										end
										3'b111: begin
											state <= and_reg;
										end // and
										3'b010: begin
											state <= slt;
										end
										default: begin
											state <= excecao;
										end
									endcase
								end
								Sub: // sub
								begin
									state <= sub_reg; 	
								end
								default: begin
									state <= excecao;
								end
							endcase
						end
						Stype: //type s
						begin
							state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
						end
						Addi: //type i (ADDI)
						begin
							case(instruction[11:7])
								5'b00000: begin //Nop
									PCWrite <= 0;
									PCSrc <= 0;
									ALUFunct <= 3'b000;
									ALUSrcA <= 0;
									ALUSrcB <= 2'b00;
									LoadIR <= 0;

									PCWriteCond <= 0;
									LoadRegA <= 0;
									LoadRegB <= 0;
									LoadALUOut <=0;
									WriteReg <= 0;
									MemToReg <= 0;
									LoadMDR <= 0;
									DMemWrite <= 0;
									IMemWrite <= 0;

									state <= init_state;
								end
								default: begin
									case(instruction[14:12])//verifica os shifts
										3'b101: begin
											case(instruction[31:26])
												6'b000000: begin
													state<=srli;
												end // 6'b000000:
												6'b01000: begin
													state<=srai;
												end // 6'b01000:
												default: begin
													state <= excecao;
												end
											endcase
										end // 3'b101:
										3'b001: begin
											state <= slli;
										end 
										3'b000: begin
											state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
										end 
										default: begin
											state <= excecao;
										end
										3'b010: begin
											state <= slti;
										end
									endcase 
								end
							endcase
						end
						Ld: //type i (LD)
						begin
							state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
						end
						Utype: //type u
						begin
							state <= lui; 
						end
						SBBeq: //sb type, beq opcode
						begin
							state <= beq_wpc;
						end
						SBtype: //outros branchs - type sb
						begin
							case(instruction[14:12]) // funct3
								3'b000: begin// JALR
									state <= jal_jalr_register;
								end
								3'b001: // BNE
								begin
									state <= bne_wpc; //volta pro comeÃ§o 	
								end
								3'b101:
								begin //BGE
									state <= bge_wpc;
								end
								3'b100:
								begin //BLT
									state <= blt_wpc;
								end
								default: begin
									state <= excecao;
								end
							endcase
						end
						Jal: begin
							state <= jal_jalr_register;
						end	
						default: begin
							state <= excecao;
						end
					endcase
				end
				cal_offset: begin
					ALUFunct <= 3'b001;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b10;
					LoadALUOut <=1;
					LoadMDR <= 0; // obs

					PCWrite <= 0;
					PCWriteCond <= 0;
					PCSrc <= 0;
					LoadRegA <= 0;
					LoadRegB <= 0;
					WriteReg <= 0;
					MemToReg <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					tam <= 2'b00;
					case (instruction[6:0]) // sai de offset e vai para umas das funÃ§Ãµes
						Stype: //type sd
						begin
							state <= read_mem; //calcula o OFFSET para o LOAD, STORE, E ADDI
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
							state <= excecao; // TODO - tratar excessão
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
					tam <= 2'b00;
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
					tam <= 2'b00;
					state <= add_wreg;
				end
				and_reg: begin
					ALUFunct <= 3'b011;
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
					tam <= 2'b00;
					state <= add_wreg;
				end
				read_mem: begin
					LoadMDR <= 1; // obs
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
					tam <= 2'b00;
					state <= 30;
				end
				30:begin
					case (instruction[6:0])
						Ld: begin
							state <= ld_wreg;
						end
						Stype: begin
							state <= write_mem;
						end
					endcase
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
					tam <= 2'b00;
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
					tam <= 2'b00;
					state <=init_state;
				end 
			 	beq_wpc: begin
			 		ALUFunct <= 3'b010;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b00;
					PCWriteCond <= 1;
					BranchOp <= 2'b00;
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
					tam <= 2'b00;
					state <= the_next_episode;
			 	end // beq_wpc:
			 	the_next_episode: begin
			 		state <= init_state;
			 	end // the_next_episode:end	 
			 	bne_wpc: begin
			 		ALUFunct <= 3'b010;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b00;
					BranchOp <= 2'b01;
			 		
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
					tam <= 2'b00;
					state <= the_next_episode;
			 	end // bne_wpc:
			 	blt_wpc: begin
			 		ALUFunct <= 3'b010;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b00;
					BranchOp <= 2'b11;
			 		
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
					tam <= 2'b00;
					state <= the_next_episode;
			 	end // blt_wpc:
			 	bge_wpc: begin
			 		ALUFunct <= 3'b010;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b00;
					BranchOp <= 2'b10;
			 		
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
					tam <= 2'b00;
					state <= the_next_episode;
			 	end // bge_wpc:
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
					tam <= 2'b00;
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
					tam <= 2'b00;
					state <= init_state;
			 	end
			 	slli: begin
			 		ShiftControl <= 2'b00;
			 		MemToReg <= 3'b100;
			 		WriteReg <= 1;
			 		state<=init_state;
			 	end
			 	srli: begin
			 		ShiftControl <= 2'b01;
			 		MemToReg <= 3'b100;
			 		WriteReg <= 1;
			 		state<=init_state;
			 	end
			 	srai: begin
			 		ShiftControl <= 2'b10;
			 		MemToReg <= 3'b100;
			 		WriteReg <= 1;
			 		state<=init_state;
			 	end
				nothing: begin
					//Faz nada
				end
				jal_jalr_register: begin
					MemToReg <= 3'b011;
					WriteReg <= 1;

					PCWrite <= 0;
					PCSrc <= 0;
					PCWriteCond <= 0;
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
					
					case(instruction[6:0])
						SBtype: begin
							state <= jalr_loadReg;
						end
						default begin
							state <=jal_jalr_offset;
						end
					endcase		
				end
				jal_jalr_offset: begin
					PCWrite <= 1;
					PCSrc <= 1'b1;

					MemToReg <= 0;
					WriteReg <= 0;
					PCWriteCond <= 0;
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

					state <= the_next_episode;
				end
				jalr_loadReg: begin
					LoadRegA <= 1;


					MemToReg <= 0;
					WriteReg <= 0;
					PCWriteCond <= 0;
					ALUFunct <= 3'b000;
					ALUSrcA <= 0;
					ALUSrcB <= 2'b00;
					PCWrite <= 0;
					PCSrc <= 0;
					LoadRegB <= 0;
					LoadALUOut <=0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					BranchOp <= 0;

					state <= jalr_opImmReg;
				end
				jalr_opImmReg: begin
					ALUSrcA <= 1;
					ALUSrcB <= 2'b11;
					ALUFunct <= 3'b001;
					LoadALUOut <= 1;
					

					LoadRegA <= 0;
					MemToReg <= 0;
					WriteReg <= 0;
					PCWriteCond <= 0;
					PCWrite <= 0;
					PCSrc <= 0;
					LoadRegB <= 0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					BranchOp <= 0;

					state <= jal_jalr_offset;
				end
				slti: begin
					PCWrite <= 0;
					PCWriteCond <= 0;
					LoadRegA <= 0;
					LoadRegB <= 0;
					LoadALUOut <=0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					BranchOp <= 0;
					
					ALUSrcA<=2'b01;
					ALUSrcB<=2'b10;
					ALUFunct<=3'b010;
					MemToReg<=3'b101;
					WriteReg<=1;
					state <= init_state;
				end
				slt: begin
					PCWrite <= 0;
					PCWriteCond <= 0;
					LoadRegA <= 0;
					LoadRegB <= 0;
					LoadALUOut <=0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					BranchOp <= 0;
					
					ALUSrcA<=2'b01;
					ALUSrcB<=2'b00;
					ALUFunct<=3'b010;
					MemToReg<=3'b101;
					WriteReg<=1;
					state <= init_state;
				end
				excecao: begin
					
				end
			 	default: begin
			 		state <= 0;
			 	end
				
			endcase	
		end // else
	end 
endmodule // uc.
