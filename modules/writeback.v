module writeback(input             clk, rst,
                 input             jumpM, RegWriteM,
                 input      [2:0]  MemtoRegM,
                 input      [4:0]  WriteRegM,
                 input      [31:0] ReadDataM, ALUMultOutM, PCPlus8M,

                 input             PCSrcD, jumpD,
                 input      [27:0] jumpDstD,
                 input      [31:0] PCPlus4F, PCBranchD,
                 
                 output reg        RegWriteW,
                 output reg [4:0]  WriteRegW,
				 output     [31:0] ResultW,
                 output     [31:0] PC);

    assign PC = jumpD ? ({PCPlus4F[31:28], jumpDstD}) : (PCSrcD ? (PCBranchD) : (PCPlus4F));
    reg        jumpW;
    reg [2:0]  MemtoRegW;
    reg [31:0] ReadDataW, ALUMultOutW;

    assign ResultW = MemtoRegW[1] ? (MemtoRegW[0] ? (ReadDataW) : (ALUMultOutW)) : (PCPlus8M); 
    always @ (posedge clk) begin
        MemtoRegW <= MemtoRegM;
        ReadDataW <= ReadDataM;
        ALUMultOutW <= ALUMultOutM;
        RegWriteW <= RegWriteM;
        jumpW <= jumpM;

        WriteRegW <= jumpM     ?  (5'b11111) : (WriteRegM);
    end

endmodule
