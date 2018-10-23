module unidadeControle (
	input logic clk,
	input logic rst,
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
	output logic Reset,
	output logic BranchOp,
	output logic PCWriteCond,
	input logic[31:0] instruction,
	output logic [4:0] state,
	output logic [1:0] tam,
	output logic [1:0]lim
);
	

	parameter init_state = 0; //estado 0
	parameter decod = 1;  // estado 1
	parameter cal_offset = 2; // 
	parameter sum_reg = 3; //
	parameter sub_reg = 4; //
	parameter read_mem_ld = 5;// 
	parameter read_mem_lw = 15;// 
	parameter read_mem_lh = 16;//  
	parameter lui = 7; //
	parameter beq_wpc = 8;//
	parameter bne_wpc = 9;//
	parameter ld_wreg = 10;//
	parameter add_wreg = 11;//
	parameter write_mem_sd = 6;//
	parameter write_mem_sw = 12;//
	parameter write_mem_sh = 13;//
	parameter write_mem_sb = 14;//
	parameter read_mem_lbu = 17;//

	always_ff@(posedge clk or posedge rst) begin
		if(rst)begin
			Reset <= 1;
			state <= init_state;
		end
		else begin
			Reset <=0;
			case(state)
				init_state: begin
					PCWrite <= 1;
					PCWriteCond <= 0;
					PCSrc <= 0;
					ALUFunct <= 3'b001;
					ALUSrcA <= 0;
					ALUSrcB <= 2'b01;
					LoadRegA <= 0;
					LoadRegB <= 0;
					LoadALUOut <=0;
					WriteReg <= 0;
					MemToReg <= 0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 1;
					tam <= 2'b00;
					lim <= 2'b00;
					////if(~clk)
						state <= decod;
					end
				decod: begin
					PCWrite <= 0;
					PCWriteCond <= 0;
					PCSrc <= 0;
					ALUFunct <= 3'b001;
					ALUSrcA <= 0;
					ALUSrcB <= 2'b11;
					LoadRegA <= 1;
					LoadRegB <= 1;
					LoadALUOut <=1;
					WriteReg <= 0;
					MemToReg <= 0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					tam <= 2'b00;
					lim <= 2'b00;

					case(instruction[6:0])
						7'b0110011: //type r
						begin
							case(instruction[31:25])
								7'b0000000: // add
								begin
									//if(~clk)
										state <= sum_reg; 	
								end
								7'b0100000: // sub
								begin
									//if(~clk)
										state <= sub_reg; 	
								end
							endcase
						end
						7'b0100011: //type s
						begin
							//if(~clk)
								state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
						end
						7'b0010011: //type i (ADDI)
						begin
							//if(~clk)
								state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
						end
						7'b0000011: //type i (LD)
						begin
							//if(~clk)
								state <= cal_offset; //calcula o OFFSET para o LOAD, STORE, E ADDI
						end
						7'b0110111: //type u
						begin
							//if(~clk)
								state <= lui; 
						end
						7'b1100111: //type sb
						begin
							case(instruction[14:12])
								3'b000: // BEQ
								begin
									//if(~clk) 
										state <= beq_wpc; //volta pro comeÃ§o 	
								end
								3'b001: // BNE
								begin
									//if(~clk)
										state <= bne_wpc; //volta pro comeÃ§o 	
								end
							endcase
						end		
						default: begin
							state <= 0;
						end
					endcase
					//state <= 0; //OBS.: se tá chegando aqui nao tá lendo/interpretando a instrução direito
					end

				cal_offset: begin
					PCWrite <= 0;
					PCWriteCond <= 0;
					PCSrc <= 0;
					ALUFunct <= 3'b001;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b10;
					LoadRegA <= 0;
					LoadRegB <= 0;
					LoadALUOut <=1;
					WriteReg <= 0;
					MemToReg <= 0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					tam <= 2'b00;
					lim <= 2'b00;
					case (instruction[6:0]) // sai de offset e vai para umas das funÃ§Ãµes
						7'b0100011: //type s
						begin
							case(instruction[14:12])
								3'b111: // sd
								begin
									state <= write_mem_sd; 							
								end
								3'b010: // sw
								begin
									state <= write_mem_sw;
								end
								3'b001: // sh
								begin
									state <= write_mem_sh;
								end
								3'b000: // sb
								begin
									state <= write_mem_sb;
								end
							endcase
							//if(~clk)
								
						end
						7'b0010011: //type i (ADDI)
						begin
							//if(~clk)
								state <= add_wreg; //calcula o OFFSET para o LOAD, STORE, E ADDI
						end
						7'b0000011: //type i (LD)
						begin
							case(instruction[14:12])
								3'b011: // ld
								begin
									state <= read_mem_ld;
								end
								3'b010: // lw
								begin
									state <= read_mem_lw;
								end
								3'b001: // lh
								begin
									state <= read_mem_lh;
								end
								3'b100: // lbu
								begin
									state <= read_mem_lbu;
								end
							endcase								
						end
						default: begin  
							state <= 0;
						end
							
						endcase
					end 
				sum_reg: begin
					PCWrite <= 0;
					PCWriteCond <= 0;
					PCSrc <= 0;
					ALUFunct <= 3'b001;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b00;
					LoadRegA <= 0;
					LoadRegB <= 0;
					LoadALUOut <= 1;
					WriteReg <= 0;
					MemToReg <= 0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					//if(~clk)
						state <= add_wreg;
						tam <= 2'b00;
						lim <= 2'b00;
					end	
				sub_reg: begin
					PCWrite <= 0;
					PCWriteCond <= 0;
					PCSrc <= 0;
					ALUFunct <= 3'b010;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b00;
					LoadRegA <= 0;
					LoadRegB <= 0;
					LoadALUOut <=1;
					WriteReg <= 0;
					MemToReg <= 0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					lim <= 2'b00;
					//if(~clk)
						state <= add_wreg;
						tam <= 2'b00;
					end	
				read_mem_ld: begin
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
					LoadMDR <= 1;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					lim <= 2'b00;
					//if(~clk)
						state <= ld_wreg;
						tam <= 2'b00;
					end // ld
				read_mem_lw: begin
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
					LoadMDR <= 1;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					lim <= 2'b01;
					//if(~clk)
						state <= ld_wreg;
						tam <= 2'b00;
					end // lw
				read_mem_lh: begin
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
					LoadMDR <= 1;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					lim <= 2'b10;
					//if(~clk)
					state <= ld_wreg;
					tam <= 2'b00;
					end // lh
				read_mem_lbu: begin
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
					LoadMDR <= 1;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					lim <= 2'b11;
					state <= ld_wreg;
					tam <= 2'b00;
					end // lbu
				write_mem_sd: begin
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
					DMemWrite <= 1;
					IMemWrite <= 0;
					LoadIR <= 0;
					state<=init_state;
					tam <= 2'b00;
					lim <= 2'b00;
					end // end sd					
				write_mem_sw: begin
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
					DMemWrite <= 1;
					IMemWrite <= 0;
					LoadIR <= 0;
					state<=init_state;
					tam <= 2'b01;
					lim <= 2'b00;
					end // end sw
				write_mem_sh: begin
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
					DMemWrite <= 1;
					IMemWrite <= 0;
					LoadIR <= 0;
					state<=init_state;
					tam <= 2'b10;
					lim <= 2'b00;
					end // end sh
				write_mem_sb: begin
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
					DMemWrite <= 1;
					IMemWrite <= 0;
					LoadIR <= 0;
					state<=init_state;
					tam <= 2'b11;
					lim <= 2'b00;
					end // end sb
				lui: begin
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
					MemToReg <= 2'b10;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					state <=init_state;
					tam <= 2'b00;
					lim <= 2'b00;
					 end
			 	beq_wpc: begin
			 		PCWrite <= 0;
					PCWriteCond <= 1;
					PCSrc <= 1;
					ALUFunct <= 3'b010;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b00;
					LoadRegA <= 0;
					LoadRegB <= 0;
					LoadALUOut <=0;
					WriteReg <= 0;
					MemToReg <= 0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					BranchOp <= 0;
					state <= init_state;
					tam <= 2'b00;
					lim <= 2'b00;
			 			 end	 
			 	bne_wpc: begin
			 		PCWrite <= 0;
					PCWriteCond <= 1;
					PCSrc <= 1;
					ALUFunct <= 3'b010;
					ALUSrcA <= 1;
					ALUSrcB <= 2'b00;
					LoadRegA <= 0;
					LoadRegB <= 0;
					LoadALUOut <=0;
					WriteReg <= 0;
					MemToReg <= 0;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					BranchOp <= 1;
					state <= init_state;
					tam <= 2'b00;
					lim <= 2'b00;
			 			end
			 	ld_wreg: begin
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
					MemToReg <= 1;
					LoadMDR <= 0;
					DMemWrite <= 0;
					IMemWrite <= 0;
					LoadIR <= 0;
					BranchOp <= 0;
					state<= init_state;
					tam <= 2'b00;
					lim <= 2'b00;
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
					state<= init_state;
					tam <= 2'b00;
					lim <= 2'b00;
			 			  end		 	
			endcase
		end 
	end


endmodule // uc.
