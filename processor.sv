module uc (input logic clock, input reg[31:0] instruction, PCWrite, PCWriteCond, BranchOp, PCSrc, ALUFunct, ALUSrcB, ALUSrcA, LoadRegA, LoadRegB, LoadALUOut, LoadMDR, DMemLoad, IMemLoad, LoadIR, MemToReg, WriteReg)
	output logic PCWrite, PCWriteCond, BranchOp, PCSrc, ALUSrcA, LoadRegA, LoadRegB, LoadALUOut, LoadMDR, DMemLoad, IMemLoad, LoadIR, WriteReg;	
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
						
						end
			decod: begin

				   end
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