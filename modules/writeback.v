module writeback(input             clk, rst,
                 input             jumpM, RegWriteM,
                 input      [3:0]  MemtoRegM,
                 input      [4:0]  WriteRegM,
                 input      [31:0] ReadDataM, ALUMultOutM, PCPlus8M,

                 input             PCSrcD, jumpD,
                 input      [27:0] jumpDstD,
                 input      [31:0] PCPlus4F, PCBranchD,
                 
                 output  reg       RegWriteW,
                 output  reg [4:0]  WriteRegW,
				         output  reg [31:0] ResultW,
                 output   [31:0] PC);
		//assign RegWriteW = RegWriteM;
		//assign WriteRegW = jumpM        ?  (5'b11111) : (WriteRegM);
		//assign ResultW = MemtoRegM[1] ? (MemtoRegM[0] ? (ReadDataM) : (ALUMultOutM)) : (PCPlus8M); 
		assign PC = jumpD        ? {PCPlus4F[31:28], jumpDstD} : (PCSrcD ? (PCBranchD) : (PCPlus4F));
    always @ (posedge clk, posedge rst) begin
				if (rst) begin
						RegWriteW <= 0;
						WriteRegW <= 0;
    				ResultW   <= 0; 
						//PC        <= 0;
				end else begin
						RegWriteW <= RegWriteM;
						WriteRegW <= jumpM        ?  (5'b11111) : (WriteRegM);
    				ResultW   <= MemtoRegM[1] ? (MemtoRegM[0] ? (ReadDataM) : (ALUMultOutM)) : (PCPlus8M); 
						//PC        <= jumpD        ? {PCPlus4F[31:28], jumpDstD} : (PCSrcD ? (PCBranchD) : (PCPlus4F));
				end
    end

endmodule

