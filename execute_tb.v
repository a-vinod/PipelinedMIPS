`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module execute_tb;
    reg         clk, rst, RegWriteE, MemToRegE, MemWriteE, jumpE, ALUSrcE, RegDstE, RsE, RtE, RdE, SignImmE;
    reg  [1:0] forwardAE, forwardBE;
    reg  [2:0]  ALUControlE;
  	reg  [31:0] rd1, rd2, ALUOutM, ResultW;
    wire        RegWriteM, MemToRegM, MemWriteM, jumpM;
    wire [4:0]  WriteRegE;
    wire [31:0] WriteDataE, ALUOutE;
  
    execute dut(.clk(clk), .rst(rst), .forwardAE(forwardAE), .forwardBE(forwardBE), .rd1(rd1), .rd2(rd2), .ALUOutM(ALUOutM), .ResultW(ResultW), .RegWriteE(RegWriteE), .MemToRegE(MemToRegE), .MemWriteE(MemWriteE), .jumpE(jumpE), .ALUControlE(ALUControlE), .ALUSrcE(ALUSrcE), .RegDstE(RegDstE), .RsE(RsE), .RtE(RtE), .RdE(RdE), .SignImmE(SignImmE), .RegWriteM(RegWriteM), .MemToRegM(MemToRegM), .MemWriteM(MemWriteM), .jumpM(jumpM),.WriteRegE(WriteRegE), .WriteDataE(WriteDataE), .ALUOutE(ALUOutE));
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
    clk = 0;
    rst = 0;
    
    
  end
endmodule
