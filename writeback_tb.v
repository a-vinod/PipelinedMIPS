`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module writeback_tb;
    reg 		clk, rst;
	reg         jumpM, RegWriteM;
  	reg  [1:0]  MemtoRegM;
  	reg  [4:0]  WriteRegM;
  	reg  [31:0] ReadDataM, ALUMultOutM, PCPlus8M;
    reg         PCSrcD, jumpD;
  	reg  [27:0] jumpDstD;
  	reg  [31:0] PCPlus4F, PCBranchD;
	wire        RegWriteW;
  	wire [4:0] WriteRegW;
  	wire [31:0] ResultW;
  	wire [31:0] PC;
    integer i;
  
  	writeback dut(clk, rst, jumpM, RegWriteM, MemtoRegM, WriteRegM, ReadDataM, ALUMultOutM, PCPlus8M, PCSrcD, jumpD, jumpDstD, PCPlus4F, PCBranchD, RegWriteW, WriteRegW, ResultW, PC);
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1);
      	clk = 0;
      	rst = 0;
        #5 clk = !clk;
        rst = 0;
        #5 clk = !clk;
        rst = 1;
        #5 clk = !clk;
        rst = 0;
 
      
      	for (i = 0; i < 10; i = i + 1) begin
            #5 clk = !clk;
        end
    end
endmodule
