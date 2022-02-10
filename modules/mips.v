module mips(input clk, rst);
    wire stallF, hitF;

    wire        stallD, jumpD, pcsrcD;
    wire        forwardAD, forwardBD;
    wire [1:0]  branchD;
    wire [4:0]  RsD, RtD;
    
    wire        flushE, stallE;
    wire [1:0]  forwardAE, forwardBE;
    wire        RegWriteE, MultStartE, MultDoneE;
    wire [3:0]  WBSrcE;
    wire [4:0]  RsE, RtE, WriteRegE;
    
    wire        RegWriteM, hitM, stallM;
    wire [3:0]  WBSrcM;
    wire [4:0]  WriteRegM;

    wire        RegWriteW, stallW;
    wire [4:0]  WriteRegW;
    datapath dp(clk, rst, stallF, hitF, stallD, forwardAD, forwardBD, branchD, RsD, RtD, jumpD, pcsrcD, flushE, stallE, forwardAE, forwardBE, RegWriteE, MultStartE, MultDoneE, WBSrcE, RsE, RtE, WriteRegE, stallM, RegWriteM, hitM, WBSrcM, WriteRegM, stallW, RegWriteW, WriteRegW);

    hazard hz(branchD, jumpD, pcsrcD, WBSrcE, WBSrcM, RegWriteE, RegWriteM, RegWriteW, hitM, hitF, MultStartE, MultDoneE, RtD, RsD, RsE, RtE, WriteRegE, WriteRegW, WriteRegM, stallF, stallD, flushE, stallE, stallM, stallW, forwardAD, forwardBD, forwardAE, forwardBE);
endmodule

