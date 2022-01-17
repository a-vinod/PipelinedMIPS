`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module testbench;
    reg 		clk, rst;
  	reg 		MultStartD, MultSgnD, RegWriteD, MemWriteD;
  	reg 		BranchD, RegDstD, jumpD;
    reg  [1:0] 	MemtoRegD, ALUSrcD;
  	reg  [2:0] 	ALUControlD;
  	reg  [4:0] 	RsD, RtD, RdD;
    reg  [31:0] rd1D, rd2D, SignImmD, UnsignedImmD, PCPlus4D;
    reg  [31:0] ALUOutM;
    reg  [31:0] ResultW;
    reg 		FlushE;
  	reg  [1:0] 	ForwardAE, ForwardBE;
  	reg  [4:0] 	RsE, RtE, RdE;
  
  	wire [31:0] ALUMultOut, WriteDataE, PCPlus4E;
  	wire 		jumpE, RegWriteE, MemWriteE;
    wire [1:0] 	MemtoRegE;
    wire [4:0] 	WriteRegE;
    wire 		MultStartE, MultDoneE;
  
    execute dut(clk, rst, MultStartD, MultSgnD, RegWriteD, MemWriteD, BranchD, RegDstD, jumpD,ALUSrcD, MemtoRegD, ALUControlD, RsD, RtD, RdD, rd1D, rd2D, SignImmD, UnsignedImmD, PCPlus4D, jumpE, RegWriteE, MemWriteE, MemtoRegE, WriteRegE, ALUOutM, ALUMultOut, WriteDataE, PCPlus4E, ResultW, FlushE, ForwardAE, ForwardBE, MultStartE, MultDoneE, RsE, RtE, RdE);

    integer i;
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
      	
      	// Testing multiply operation
      	MultStartD = 1;
        MultSgnD = 0;
        RegWriteD = 0;
        MemWriteD = 0;
        BranchD = 0;
        RegDstD = 0;
        jumpD = 0;
      	ALUSrcD = 2'b00;
        MemtoRegD = 2'b10;
        ALUControlD = 3'b010;
        RsD = 0;
        RtD = 0;
        RdD = 0;
        rd1D = 3'b111;
      	rd2D = 3'b101;
        SignImmD = 0;
        UnsignedImmD = 0;
        PCPlus4D = 0;
        ALUOutM = 0;
        ResultW = 0;
        FlushE = 0;
        ForwardAE = 0;
        ForwardBE = 0;
      
        for (i = 0; i < 70; i = i + 1) begin
            #5 clk = !clk;
        end
    end
endmodule
