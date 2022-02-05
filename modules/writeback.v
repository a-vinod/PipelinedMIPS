module writeback(input         clk, rst, stallW,
                 input         jumpM, RegWriteM,
                 input  [3:0]  MemtoRegM,
                 input  [4:0]  WriteRegM,
                 input  [31:0] ReadDataM, ALUMultOutM, PCPlus8M,

                 input         PCSrcD, jumpD,
                 input  [27:0] jumpDstD,
                 input  [31:0] PCPlus4F, PCBranchD,
                 
                 output        RegWriteW,
                 output [4:0]  WriteRegW,
				         output [31:0] ResultW,
                 output [31:0] PC);

		// Pipeline registers that are updated on the clock rising edge
	  reg 			 jumpM_, RegWriteM_;
    reg [3:0]  MemtoRegM_;
    reg [4:0]  WriteRegM_;
    reg [31:0] ReadDataM_, ALUMultOutM_, PCPlus8M_;
		

    assign RegWriteW = RegWriteM_;
    assign WriteRegW = jumpM_        ?  (5'b11111) : (WriteRegM_);
    assign ResultW = MemtoRegM_[1] ? (MemtoRegM_[0] ? (ReadDataM_) : (ALUMultOutM_)) : (PCPlus8M_);

	  assign PC = jumpD        ? {PCPlus4F[31:28], jumpDstD} : (PCSrcD ? (PCBranchD) : (PCPlus4F));
    always @ (posedge clk, posedge rst) begin
				if (rst) begin
						RegWriteM_ <= 0;
				end else if (!stallW) begin
						RegWriteM_ <= RegWriteM;
						jumpM_ <= jumpM;
						WriteRegM_ <= WriteRegM;
						MemtoRegM_ <= MemtoRegM;
						ReadDataM_ <= ReadDataM;
						ALUMultOutM_ <= ALUMultOutM;
						PCPlus8M_ <= PCPlus8M;
				end
    end

endmodule

