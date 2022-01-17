module mips(input             clk, rst, 
                              stallF, stallD,
                              forwardAD, forwardBD
            );

    wire [31:0] PC, InstrF, PCPlus4F;
    fetch f(clk, rst, stallF, PC, InstrF, PCPlus4F);

    wire [4:0] writeregW;
    wire [31:0] resultW, ALUMultOutM;
    wire regwriteW;
    wire [31:0] pcplus4D, pcbranchD;
    wire [1:0] branchD, alusrcD;
    wire [2:0] wbsrcD, alucontrolD;
    wire [4:0] rsD, rtD, reD;
    wire [31:0] signimmD, unsignimmD;
    wire multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD;
    wire pcsrcD;
    wire [31:0] rd1d, rd2d;
    wire [27:0] jumpdstD;
    decode d(clk, rst, stallD, InstrF, PCPlus4F, forwardAD, forwardBD, writeregW, resultW, ALUMultOutM, regwriteW, pcplus4D, pcbranchD, branchD, alusrcD, wbsrcD, alucontrolD, rsD, rtD, reD, signimmD, unsignimmD, multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD, pcsrcD, rd1d, rd2d, jumpdstD);

    wire        jumpE, RegWriteE, MemWriteE;
    wire [1:0]  MemtoRegE;
    wire [4:0]  WriteRegE;
    wire [31:0] ALUMultOutE, WriteDataE, PCPlus4E;
    wire        FlushE;
    wire [1:0]  ForwardAE, ForwardBE;
    wire        MultStartE, MultDoneE;
    wire [4:0]  RsE, RtE;
    execute e(clk, rst,  multstartD, multsgnD, regwriteD, memwriteD, branchD, regdstD, jumpD, alusrcD, wbsrcD, alucontrolD, rsD, rtD, reD, rd1d, rd2d, signimmD, unsignimmD, pcplus4D,  jumpE, RegWriteE, MemWriteE, MemtoRegE, WriteRegE, ALUMultOutM, ALUMultOutE, WriteDataE, PCPlus4E, resultW,  FlushE, ForwardAE, ForwardBE, MultStartE, MultDoneE, RsE, RtE);

    wire        jumpM, RegWriteM;
    wire [1:0]  MemtoRegM;
    wire [4:0]  WriteRegM;
    wire [31:0] ReadDataM, PCPlus8M;
    memory m(clk, rst, jumpE, RegWriteE, MemWriteE, MemtoRegE, WriteRegE, ALUMultOutE, WriteDataE, PCPlus4E, jumpM, RegWriteM, MemtoRegM, WriteRegM, ReadDataM, ALUMultOutM, PCPlus8M);

    writeback w(clk, rst, jumpM, RegWriteM, MemtoRegM, WriteRegM, ReadDataM, ALUMultOutM, PCPlus8M, pcsrcD, jumpD, jumpdstD, PCPlus4F, pcbranchD, regwriteW, writeregW, resultW, PC);
endmodule
