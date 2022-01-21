module memory(input             clk, rst,
                                jumpE, RegWriteE, MemWriteE,
              input      [2:0]  MemtoRegE,
              input      [4:0]  WriteRegE,
              input      [31:0] ALUMultOutE, WriteDataE, PCPlus4E,
              output reg        jumpM, RegWriteM,
              output reg [2:0]  MemtoRegM,
              output reg [4:0]  WriteRegM,
              output reg [31:0] ALUMultOutM,
              output reg [31:0] ReadDataM,
              output     [31:0] PCPlus8M);  
  
    reg [31:0]  WriteDataM, PCPlus4M_;
    wire [31:0] ReadDataM_;

    assign PCPlus8M = PCPlus4M_ + 4;

  	data_memory dm(.clk(clk), .WE(MemWriteE), .A(ALUMultOutE), .WD(WriteDataE), .RD(ReadDataM_));
    
    always @ (posedge clk) begin

            jumpM     <= jumpE;
            RegWriteM <= RegWriteE;
            MemtoRegM <= MemtoRegE;

            ALUMultOutM  <= ALUMultOutE;
            WriteRegM    <= WriteRegE;
            PCPlus4M_    <= PCPlus4E;
            ReadDataM    <= ReadDataM_;

    end

endmodule
