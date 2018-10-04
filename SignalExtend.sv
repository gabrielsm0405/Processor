module SignalExtend(input [31:0] Inst, output [63:0] Out)
	always_comb begin
		
		if([6:0]Inst == 0010011 || [6:0]Inst == 0000011) begin
			
			[11:0]Out = [20:31]Inst;
			if(Inst[31] == 1) begin	
				[63:12]Out = 52'b1111111111111111111111111111111111111111111111111111;
			end else
				[63:12]Out = 52'b0000000000000000000000000000000000000000000000000000;
		
		end else if([6:0]Inst == 0100011) begin
			
			[4:0]Out = Inst[11:7];
			[11:5]Out = Inst[31:25];		
			if(Inst[31] == 1) begin
				[63:12]Out = 52'd1;
			end else
				[63:12]Out = 52'd0;
				
		end else if([6:0]Inst == 1100111) begin
			
			[10]Out = Inst[7];
			[3:0]Out = Inst[11:8];
			[9:4]Out = Inst[30:25];
			[11]Out = Inst[31];
			if(Inst[31] == 1) begin
				[63:12]Out = 52'd1;
			end else
				[63:12]Out = 52'd0;
				
		end else if([6:0]Inst == 0110111) begin
			[19:0]Out = [31:12]Inst;
			if(Inst[31] == 1) begin
				[63:20]Out = 46'd1;
			end else 
				[63]Out = 46'd0;
		end

	end


endmodule