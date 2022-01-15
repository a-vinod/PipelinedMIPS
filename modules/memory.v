module memory(input             clk,
                                RegWriteM, jumpM,
              input      [1:0]  MemWriteM,
              input      [4:0]  WriteRegM,
              input      [31:0] ALUOutM, WriteDataM, PCPlus4M,
              output reg        RegWriteW, jumpW,
              output reg [1:0]  MemWriteW,
              output reg [4:0]  WriteRegW,
              output reg [31:0] ALUOutW, ReadDataW, PCPlus8W);
    data_memory dm(.clk(clk), .WE(MemWriteM), .A(ALUOutM), .WD(WriteDataM), .RD(ReadDataW));

    assign ALUOutW   = ALUOutM;
    assign WriteRegW = WriteRegM;
    assign RegWriteW = RegWriteM;
    assign RegWriteW = RegWriteM;
    assign jumpW     = jumpM;
    assign MemWriteW = MemWriteM;

    assign PCPlus8W  = PCPlus4M + 4;
endmodule
