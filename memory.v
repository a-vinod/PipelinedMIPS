module memory(input             clk,
                                jumpE, RegWriteE, MemWriteE,
              input      [1:0]  MemtoRegE,
              input      [4:0]  WriteRegE,
              input      [31:0] ALUMultOutE, WriteDataE, PCPlus4E,
              output reg        jumpM, RegWriteM,
              output reg [1:0]  MemtoRegM,
              output reg [4:0]  WriteRegM,
              output reg [31:0] ReadDataM, ALUMultOutM, PCPlus8M);
    data_memory dm(.clk(clk), .WE(MemWriteE), .A(ALUMultOutE), .WD(WriteDataE), .RD(ReadDataM));

    // Pipeline registers
    reg        jumpM_, RegWriteM_;
    reg [1:0]  MemtoRegM_;
    reg [4:0]  WriteRegM_;
    reg [31:0] ALUMultOutM_, WriteDataM_, PCPlus4M_;

    assign jumpM      = jumpM_;
    assign RegWriteM  = RegWriteM_;
    assign MemtoRegM  = MemtoRegM_;
    assign WriteRegM  = WriteRegM_;
    assign WriteDataM = WriteDataM_;
    assign PCPlus4M   = PCPlus4M_;

    assign PCPlus8M = PCPlus4M_ + 4;
    
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            jumpM_     <= 0;
            RegWriteM_ <= 0;
            MemtoRegM_ <= 0;

            ALUMultOutM_ <= 0;
            WriteDataM_  <= 0;
            WriteRegM_   <= 0;
            PCPlus4M_    <= 0;
        end else begin
            jumpM_     <= jumpE;
            RegWriteM_ <= RegWriteE;
            MemtoRegM_ <= MemtoRegE;

            ALUMultOutM_ <= ALUMultOutE;
            WriteDataM_  <= WriteDataE;
            WriteRegM_   <= WriteRegE;
            PCPlus4M_    <= PCPlus4E;
        end
    end

endmodule
