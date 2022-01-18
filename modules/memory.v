module memory(input         clk, rst,
                            jumpE, RegWriteE, MemWriteE,
              input  [2:0]  MemtoRegE,
              input  [4:0]  WriteRegE,
              input  [31:0] ALUMultOutE, WriteDataE, PCPlus4E,
              output        jumpM, RegWriteM,
              output [2:0]  MemtoRegM,
              output [4:0]  WriteRegM,
              output [31:0] ReadDataM, ALUMultOutM, PCPlus8M);  
  
    // Pipeline registers
    reg        jumpM_, RegWriteM_;
    reg [2:0]  MemtoRegM_;
    reg [4:0]  WriteRegM_;
    reg [31:0] WriteDataM_, PCPlus4M_, ALUMultOutM_;

    wire [31:0] ReadDataM_;

    assign jumpM       = jumpM_;
    assign RegWriteM   = RegWriteM_;
    assign MemtoRegM   = MemtoRegM_;
    assign WriteRegM   = WriteRegM_;
		assign ALUMultOutM = ALUMultOutM_;

    assign PCPlus8M = PCPlus4M_ + 4;
  	data_memory dm(.clk(clk), .WE(MemWriteE), .A(ALUMultOutE), .WD(WriteDataM_), .RD(ReadDataM_));

    assign ReadDataM = ReadDataM_;
    
    always @ (posedge clk or posedge rst) begin

            jumpM_     <= jumpE;
            RegWriteM_ <= RegWriteE;
            MemtoRegM_ <= MemtoRegE;

            ALUMultOutM_ <= ALUMultOutE;
            WriteDataM_  <= WriteDataE;
            WriteRegM_   <= WriteRegE;
            PCPlus4M_    <= PCPlus4E;

    end

endmodule
