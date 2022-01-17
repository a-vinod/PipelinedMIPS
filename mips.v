module mips(input clk, rst);
    wire clk, rst, stallF;

    wire        stallD;
    wire        forwardAD, forwardBD;
    wire [1:0]  branchD;
    wire [4:0]  RsD, RtD;
    
    wire        flushE;
    wire [1:0]  forwardAE, forwardBE;
    wire        RegWriteE, MultStartE, MultDoneE;
    wire [2:0]  WBSrcE;
    wire [4:0]  RsE, RtE, WriteRegE;
    
    wire        RegWriteM;
    wire [2:0]  WBSrcM;
    wire [4:0]  WriteRegM;

    wire        RegWriteW;
    wire [4:0]  WriteRegW;
    datapath dp(clk, rst, stallF, stallD, forwardAD, forwardBD, branchD, RsD, RtD, flushE, forwardAE, forwardBE, RegWriteE, MultStartE, MultDoneE, WBSrcE, RsE, RtE, WriteRegE, RegWriteM, WBSrcM, WriteRegM, RegWriteW, WriteRegW);

    hazard hz(branchD, WBSrcE, WBSrcM, RegWriteE, RegWriteM, RegWriteW, MultStartE, MultDoneE, RtD, RsD, RsE, RtE, WriteRegE, WriteRegW, WriteRegM, stallF, stallD, flushE, forwardAD, forwardBD, forwardAE, forwardBE);
endmodule
