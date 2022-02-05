module memory(input         clk, rst, stallM,
                            jumpE, RegWriteE, MemWriteE,
              input  [3:0]  MemtoRegE,
              input  [4:0]  WriteRegE,
              input  [31:0] ALUMultOutE, WriteDataE, PCPlus4E,
              output        jumpM, RegWriteM, hitM,
              output [3:0]  MemtoRegM,
              output [4:0]  WriteRegM,
              output [31:0] ALUMultOutM,
              output [31:0] ReadDataM,
              output [31:0] PCPlus8M); 

    wire         data_memory_ready;
    wire [127:0] data_memory_RD;
    
		// Pipeline registers updated on the rising edge
    reg        jumpE_, RegWriteE_, MemWriteE_;
    reg [3:0]  MemtoRegE_;
    reg [4:0]  WriteRegE_;
    reg [31:0] ALUMultOutE_, WriteDataE_, PCPlus4E_;
    
    assign jumpM = jumpE_;
    assign RegWriteM = RegWriteE_;
    assign MemtoRegM = MemtoRegE_;
    assign WriteRegM = WriteRegE_;
    assign ALUMultOutM = ALUMultOutE_;
    assign PCPlus8M = PCPlus4E_ + 4;

		d_cache     dc (clk, rst, MemWriteE_, MemtoRegE_, ALUMultOutE_, WriteDataE_, data_memory_RD, data_memory_ready, hitM, ReadDataM);
		data_memory dm (clk, rst, MemWriteE_, MemtoRegE_, ALUMultOutE_, WriteDataE_, data_memory_ready, data_memory_RD);
		always @ (posedge clk) begin
				if (!stallM) begin
        		jumpE_       <= jumpE;
        		RegWriteE_   <= RegWriteE;
       		  MemtoRegE_   <= MemtoRegE;
        		WriteRegE_   <= WriteRegE;
        		ALUMultOutE_ <= ALUMultOutE;
        		PCPlus4E_    <= PCPlus4E;

        		WriteDataE_  <= WriteDataE;
        		MemWriteE_   <= MemWriteE;
				end
		end
endmodule
