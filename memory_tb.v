`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module memory_tb;
    reg 		clk, rst;
  	reg			jumpE, RegWriteE, MemWriteE;
  	reg  [1:0]  MemtoRegE;
  	reg  [4:0]  WriteRegE;
  	reg  [31:0] ALUMultOutE, WriteDataE, PCPlus4E;
    wire        jumpM, RegWriteM;
  	wire [1:0]  MemtoRegM;
  	wire [4:0]  WriteRegM;
  	wire [31:0] ReadDataM, ALUMultOutM, PCPlus8M;

    memory dut(clk, rst, jumpE, RegWriteE, MemWriteE, MemtoRegE, WriteRegE, ALUMultOutE, WriteDataE, PCPlus4E, jumpM, RegWriteM, MemtoRegM, WriteRegM, ReadDataM, ALUMultOutM, PCPlus8M);
  
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
 
      
      	for (i = 0; i < 10; i = i + 1) begin
            #5 clk = !clk;
        end
    end
endmodule
