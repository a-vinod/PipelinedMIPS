module fetch(input clk, reset, stallF, pcsrcD1, pcsrcD2, 
							input [1:0] branchD1, branchD2,
							input [31:0] pc, pcbranchD1, pcbranchD2,
							output hit,
							input dependency, dependency_prev,
							output [1:0] predict_taken,
							output [31:0] instrF1, instrF2, pcplus4F, pcF_pred
							);

	reg  [31:0] pcF;
	wire [31:0] instrF2_;
	wire [1:0] branchD;
	wire [511:0] instr_memory_RD;
	wire         instr_memory_ready;

	
	assign branchD = branchD1 || branchD2;
	assign pcplus4F = pcF + 8; // Add 8 since we're reading two instructions at a time

	branch_predictor_local bp_local(clk, reset, pcsrcD1, pcsrcD2, stallF, dependency, dependency_prev, pcF, pcbranchD1, pcbranchD2, pcF_pred, predict_taken);
	i_cache icache(clk, reset, pcF, instr_memory_RD, instr_memory_ready, hit, instrF1, instrF2_); //Instruction cache
	imem imem(clk, reset, pcF, pcsrcD1, pcsrcD2, branchD, hit, instr_memory_ready, instr_memory_RD); //Instruction memory

	// Check if instrF1 is branch predict taken
	assign instrF2 = pcF_pred[0] ? (32'b0) : (instrF2_);

	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			pcF <= 32'b0;
		end else if (!stallF) begin
			pcF <= pc;
		end
	end

endmodule
