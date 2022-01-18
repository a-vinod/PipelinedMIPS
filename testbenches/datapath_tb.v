`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module datapath_tb;
    reg        clk, rst;
    reg        stallF, stallD;
    reg        forwardAD, forwardBD;
  	wire [1:0] branchD;
  	wire [4:0] RsD, RtD;
    reg        flushE;
    reg  [1:0] forwardAE, forwardBE;
    wire [2:0] WBSrcE;
    wire       RegWriteE, MultStartE, MultDoneE;
    wire [4:0] RsE, RtE, WriteRegE;
    wire       RegWriteM;
    wire [2:0] WBSrcM;
    wire       RegWriteW;
  	wire [4:0] WriteRegW;
    integer i;
  
  	datapath dp(clk, rst, stallF, stallD, forwardAD, forwardBD, branchD, RsD, RtD, flushE, forwardAE, forwardBE, RegWriteE, MultStartE, MultDoneE, WBSrcE, RsE, RtE, WriteRegE, RegWriteM, WBSrcM, RegWriteW, WriteRegW);
  
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
