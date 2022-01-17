module datapath(input             clk, rst, 
                                  stallF, 

                input             stallD,
                                  forwardAD, forwardBD,
                output            branchD,
                
                input             flushE,
                input      [1:0]  forwardAE, forwardBE,
                output            MemtoRegE, RegWriteE,
                
                output reg        MemtoRegM, RegWriteM,

                output reg        RegWriteW);

    wire [31:0] PC, InstrF, PCPlus4F;
    fetch f(clk, rst, stallF, PC, InstrF, PCPlus4F);

    wire [4:0] writeregW;
    wire [31:0] resultW, ALUMultOutM;
    wire RegWriteW_;
    wire [31:0] pcplus4D, pcbranchD;
    wire [1:0] branchD_, alusrcD;
    wire [2:0] MemtoRegD, alucontrolD;
    wire [4:0] rsD, rtD, reD;
    wire [31:0] signimmD, unsignimmD;
    wire multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD;
    wire pcsrcD;
    wire [31:0] rd1d, rd2d;
    wire [27:0] jumpdstD;
    decode d(clk, rst, stallD, InstrF, PCPlus4F, forwardAD, forwardBD, writeregW, resultW, ALUMultOutM, RegWriteW_, pcplus4D, pcbranchD, branchD_, alusrcD, MemtoRegD, alucontrolD, rsD, rtD, reD, signimmD, unsignimmD, multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD, pcsrcD, rd1d, rd2d, jumpdstD);

    wire        jumpE, RegWriteE_, MemWriteE;
    wire [1:0]  MemtoRegE_;
    wire [4:0]  WriteRegE;
    wire [31:0] ALUMultOutE, WriteDataE, PCPlus4E;
    wire        MultStartE, MultDoneE;
    wire [4:0]  RsE, RtE;
    execute e(clk, rst,  multstartD, multsgnD, regwriteD, memwriteD, branchD_, regdstD, jumpD, alusrcD, MemtoRegD, alucontrolD, rsD, rtD, reD, rd1d, rd2d, signimmD, unsignimmD, pcplus4D,  jumpE, RegWriteE_, MemWriteE, MemtoRegE_, WriteRegE, ALUMultOutM, ALUMultOutE, WriteDataE, PCPlus4E, resultW, flushE, forwardAE, forwardBE, MultStartE, MultDoneE, RsE, RtE);

    wire        jumpM, RegWriteM_;
    wire [1:0]  MemtoRegM_;
    wire [4:0]  WriteRegM;
    wire [31:0] ReadDataM, PCPlus8M;
    memory m(clk, rst, jumpE, RegWriteE_, MemWriteE, MemtoRegE_, WriteRegE, ALUMultOutE, WriteDataE, PCPlus4E, jumpM, RegWriteM_, MemtoRegM_, WriteRegM, ReadDataM, ALUMultOutM, PCPlus8M);

    writeback w(clk, rst, jumpM, RegWriteM_, MemtoRegM_, WriteRegM, ReadDataM, ALUMultOutM, PCPlus8M, pcsrcD, jumpD, jumpdstD, PCPlus4F, pcbranchD, RegWriteW_, writeregW, resultW, PC);

    assign branchD   = branchD_;
    assign MemtoRegE = MemtoRegE_;
    assign RegWriteE = RegWriteE_;
    assign MemtoRegM = MemtoRegM_;
    assign RegWriteM = RegWriteM_;
    assign RegWriteW = RegWriteW_;
endmodule

//Stage Fetch

