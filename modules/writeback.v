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
				 output reg [31:0] ResultW,
                 output     [31:0] PC);

    assign PC = jumpD ? ({PCPlus4F[31:28], jumpDstD}) : (PCSrcD ? (PCBranchD) : (PCPlus4F));
    always @ (posedge clk) begin
        ResultW <= MemtoRegM[1] ? (MemtoRegM[0] ? (ReadDataM) : (ALUMultOutM)) : (PCPlus8M); 
        RegWriteW <= RegWriteM;
        WriteRegW <= jumpM     ?  (5'b11111) : (WriteRegM);
    end

endmodule
