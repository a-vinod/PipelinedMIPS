module writeback(input             RegWriteW, jumpW, 
                 input      [1:0]  MemWriteW,
                 input      [4:0]  WriteRegW_in,
                 input      [31:0] ReadDataW, ALUOutW, PCPlus8W,
                 output reg [4:0]  WriteRegW,
                 output reg [31:0] ResultW);
    assign ResultW   = MemWriteW[1] ? (MemWriteW[0] ? ReadDataW : ALUOutW) : (PCPlus8W);
    assign WriteRegW = jumpW        ? (5'b11111)                           : WriteRegW_in;
endmodule
