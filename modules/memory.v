module memory(input             clk, rst,
                                jumpE, RegWriteE, MemWriteE,
              input      [2:0]  MemtoRegE,
              input      [4:0]  WriteRegE,
              input      [31:0] ALUMultOutE, WriteDataE, PCPlus4E,
              output reg        jumpM, RegWriteM,
              output reg [2:0]  MemtoRegM,
              output reg [4:0]  WriteRegM,
              output reg [31:0] ALUMultOutM,
              output     [31:0] PCPlus8M, ReadDataM);  
  
    reg [31:0]  WriteDataM, PCPlus4M_;

    assign PCPlus8M = PCPlus4M_ + 4;

  	data_memory dm(.clk(clk), .WE(MemWriteE), .A(ALUMultOutE), .WD(WriteDataM), .RD(ReadDataM));
    
    always @ (posedge clk or posedge rst) begin

            jumpM     <= jumpE;
            RegWriteM <= RegWriteE;
            MemtoRegM <= MemtoRegE;

            ALUMultOutM <= ALUMultOutE;
            WriteDataM  <= WriteDataE;
            WriteRegM   <= WriteRegE;
            PCPlus4M_    <= PCPlus4E;

    end

endmodule
