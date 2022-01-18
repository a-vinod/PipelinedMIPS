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
                 output reg [31:0] ResultW, PC);
    // Pipeline registers
    reg RegWriteW_, jumpW_;
    reg [4:0]  WriteRegW_;
    reg [31:0] ReadDataW_, ALUMultOutW_, PCPlus8W_;

    assign RegWriteW = RegWriteW_;
    assign ResultW = MemtoRegM[1] ? (MemtoRegM[0] ? (ReadDataW_) : (ALUMultOutW_)) : (PCPlus8W_);
    assign WriteRegW = jumpW_     ?  (5'b11111) : (WriteRegW_);
    assign PC = jumpD ? ({PCPlus4F[31:28], jumpDstD}) : (PCSrcD ? (PCBranchD) : (PCPlus4F));

    always @ (posedge clk or posedge rst) begin
            RegWriteW_   <= RegWriteM;
            jumpW_       <= jumpM;
            WriteRegW_   <= WriteRegM;
            ReadDataW_   <= ReadDataM; 
            ALUMultOutW_ <= ALUMultOutM;
            PCPlus8W_    <= PCPlus8M;
        end

endmodule
