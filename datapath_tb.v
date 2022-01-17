`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module datapath_tb;
    reg  clk, rst;
    reg  stallF, stallD;
    reg  forwardAD, forwardBD;
    wire branchD;
    reg  flushE, forwardAE, forwardBE;
    wire MemtoRegE, RegWriteE;
    wire MemToRegM, RegWriteM;
    wire RegWriteW;
    integer i;
  
  	datapath dut(clk, rst, stallF, stallD, forwardAD, forwardBD, branchD, flushE, forwardAE, forwardBE, MemtoRegE, RegWriteE, MemToRegM,RegWriteM, RegWriteW);
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
