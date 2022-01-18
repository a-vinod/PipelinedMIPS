module writeback(input             clk, rst,
                 input             jumpM, RegWriteM,
                 input      [1:0]  MemtoRegM,
                 input      [4:0]  WriteRegM,
                 input      [31:0] ReadDataM, ALUMultOutM, PCPlus8M,

                 input             PCSrcD, jumpD,
                 input      [27:0] jumpDstD,
                 input      [31:0] PCPlus4F, PCBranchD,
                 
                 output            RegWriteW,
                 output     [4:0]  WriteRegW,
                 output     [31:0] ResultW, PC);
    // Pipeline registers
    reg RegWriteW_, jumpW_;
    reg [4:0]  WriteRegW_;
    reg [31:0] ReadDataW_, ALUMultOutW_, PCPlus8W_;

    assign RegWriteW = RegWriteW_;
    assign ResultW = MemtoRegM[1] ? (MemtoRegM[0] ? (ReadDataW_) : (ALUMultOutW_)) : (PCPlus8W_);
    assign WriteRegW = jumpW_     ? (WriteRegW_) : (5'b11111);
    assign PC = jumpD ? ({PCPlus4F[31:28], jumpDstD}) : (PCSrcD ? (PCBranchD) : (PCPlus4F));

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            RegWriteW_   <= 0;
            jumpW_       <= 0;
            WriteRegW_   <= 0;
            ReadDataW_   <= 0; 
            ALUMultOutW_ <= 0;
            PCPlus8W_    <= 0;
        end else begin
            RegWriteW_   <= RegWriteM;
            jumpW_       <= jumpM;
            WriteRegW_   <= WriteRegM;
            ReadDataW_   <= ReadDataM; 
            ALUMultOutW_ <= ALUMultOutM;
            PCPlus8W_    <= PCPlus8M;
        end
    end


endmodule
