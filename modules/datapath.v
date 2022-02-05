module datapath(input             clk, rst, 
                                  stallF, 

                input             stallD,
                input             forwardAD, forwardBD,
                output  [1:0]  branchD,
                output  [4:0]  RsD, RtD,
                
                input             flushE, stallE,
                input      [1:0]  forwardAE, forwardBE,
                output        RegWriteE, MultStartE, MultDoneE,
                output  [3:0]  WBSrcE,
                output  [4:0]  RsE, RtE, WriteRegE,
                
								input 				 stallM,
                output         RegWriteM, hitM,
                output  [3:0]  WBSrcM,
                output  [4:0]  WriteRegM,
                
								input 				 stallW,
                output         RegWriteW,
                output  [4:0]  WriteRegW);

    wire [31:0] PC, InstrF, PCPlus4F;
    fetch f(clk, rst, stallF, PC, InstrF, PCPlus4F);

    wire [4:0] writeregW;
    wire [31:0] resultW, ALUMultOutM;
    wire RegWriteW_;
    wire [31:0] pcplus4D, pcbranchD;
  	wire [1:0] alusrcD, branchD_;
    wire [2:0] alucontrolD;
		wire [3:0] WBSrcD;
    wire [4:0] rsD, rtD, reD;
    wire [31:0] signimmD, unsignimmD;
    wire multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD;
    wire pcsrcD;
    wire [31:0] rd1d, rd2d;
    wire [27:0] jumpdstD;
    decode d(clk, rst, stallD, InstrF, PCPlus4F, forwardAD, forwardBD, writeregW, resultW, ALUMultOutM, RegWriteW_, pcplus4D, pcbranchD, branchD_, alusrcD, WBSrcD, alucontrolD, rsD, rtD, reD, signimmD, unsignimmD, multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD, pcsrcD, rd1d, rd2d, jumpdstD);

    wire        jumpE, RegWriteE_, MemWriteE;
    wire [3:0]  WBSrcE_;
    wire [4:0]  WriteRegE_;
    wire [31:0] ALUMultOutE, WriteDataE, PCPlus4E;
  	wire [4:0]  RsE_, RtE_, RdE_;
    wire MultStartE_, MultDoneE_;
    execute e(clk, rst, multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD, branchD_, alusrcD, WBSrcD, alucontrolD, rsD, rtD, reD, rd1d, rd2d, signimmD, unsignimmD, pcplus4D,  jumpE, RegWriteE_, MemWriteE, WBSrcE_, WriteRegE_, ALUMultOutM, ALUMultOutE, WriteDataE, PCPlus4E, resultW, flushE, stallE, forwardAE, forwardBE, MultStartE_, MultDoneE_, RsE_, RtE_, RdE_);

    wire        jumpM, RegWriteM_;
    wire [3:0]  WBSrcM_;
    wire [4:0]  WriteRegM_;
    wire [31:0] ReadDataM, PCPlus8M;
    memory m(clk, rst, stallM, jumpE, RegWriteE_, MemWriteE, WBSrcE_, WriteRegE_, ALUMultOutE, WriteDataE, PCPlus4E, jumpM, RegWriteM_, hitM, WBSrcM_, WriteRegM_, ALUMultOutM, ReadDataM, PCPlus8M);


    writeback w(clk, rst, stallW, jumpM, RegWriteM_, WBSrcM_, WriteRegM_, ReadDataM, ALUMultOutM, PCPlus8M, pcsrcD, jumpD, jumpdstD, PCPlus4F, pcbranchD, RegWriteW_, writeregW, resultW, PC);

    assign {MultStartE, MultDoneE} = {MultStartE_, MultDoneE_};
    assign branchD    = branchD_;
    assign {RsD, RtD} = {rsD, rtD};
    assign WBSrcE     = WBSrcE_;
    assign RegWriteE  = RegWriteE_;
    assign WriteRegE  = WriteRegE_;
  	assign {RsE, RtE} = {RsE_, RtE_};
    assign WBSrcM     = WBSrcM_;
    assign RegWriteM  = RegWriteM_;
    assign WriteRegM  = WriteRegM_;
    assign RegWriteW  = RegWriteW_;
    assign WriteRegW  = writeregW;

endmodule

