module memory(input             clk, rst,
                                jumpE, RegWriteE, MemWriteE,
              input      [3:0]  MemtoRegE,
              input      [4:0]  WriteRegE,
              input      [31:0] ALUMultOutE, WriteDataE, PCPlus4E,
              output reg        jumpM, RegWriteM,
              output reg [3:0]  MemtoRegM,
              output reg [4:0]  WriteRegM,
              output reg [31:0] ALUMultOutM,
              output     [31:0] ReadDataM,
              output reg [31:0] PCPlus8M);  

  	data_memory dm(.clk(clk), .WE(MemWriteE), .A(ALUMultOutE), .WD(WriteDataE), .RD(ReadDataM));
		always @ (posedge clk) begin
				ALUMultOutM <= ALUMultOutE;
				WriteRegM <= WriteRegE;
				MemtoRegM <= MemtoRegE;
				jumpM <= jumpE;
				RegWriteM <= RegWriteE;
				PCPlus8M <= PCPlus4E + 4;
		end

endmodule
