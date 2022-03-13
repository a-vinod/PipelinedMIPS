module datapath(input clk, input rst,
								input flushE,
								input stallF, stallD, stallE, stallM, stallW,
								input [1:0] forwardAD1, forwardBD1, forwardAD2, forwardBD2,
								output pcsrcD1, pcsrcD2,
								output [4:0] RsD1, RtD1, RsD2, RtD2,
								output [1:0] predict_takenD,
								output [4:0] RsE1, RtE1, RsE2, RtE2,
								input [2:0] forwardAE1, forwardBE1, forwardAE2, forwardBE2,
								output dependency, dependency_prev,
								output RegWriteE1, RegWriteE2,
								output [3:0] MemtoRegE1, MemtoRegE2,
								output [4:0] writeregE1, writeregE2,
								output RegWriteM1, RegWriteM2,
								output [3:0] MemtoRegM1, MemtoRegM2,
								output [4:0] writeregM1, writeregM2,
								output regwriteW1, regwriteW2,
								output [4:0] writeregW1, writeregW2,
								output hitF, hitM,
								output [1:0] branchD1, branchD2);

	wire [31:0] PC, PCPlus4F, PCPlus4D, PCBranchPredict;
	wire [31:0] pcbranchD1, pcbranchD2;
	wire [31:0] instrF1, instrF2, instrD1, instrD2;

	wire [1:0] predict_takenF;

	fetch f(clk, rst, stallF, pcsrcD1, pcsrcD2, 
				 	branchD1, branchD2,
					PC, pcbranchD1, pcbranchD2,
					hitF, dependency, dependency_prev,
					predict_takenF,
					instrF1, instrF2, PCPlus4F, PCBranchPredict);

	wire [31:0] resultW1, resultW2;
	wire [31:0] aluoutM1, aluoutM2;
	wire [3:0] memtoregD1, memtoregD2;
	wire regwriteD1, regwriteD2;
	wire memwriteD1, memwriteD2;
	wire [2:0] alucontrolD1, alucontrolD2;
	wire [1:0] alusrcD1, alusrcD2;
	wire regdstD1, regdstD2;
	wire jumpD1, jumpD2;
	wire [31:0] RD11, RD12, RD21, RD22, signimmD1, unsignimmD1, signimmD2, unsignimmD2;
	wire misspredict1, misspredict2;
	wire [27:0] jumpdstD1, jumpdstD2;
	wire [4:0] RdD1, RdD2;

	decode d(clk, rst, stallD,
					 predict_takenF,
					 instrF1, instrF2, PCPlus4F,
					 forwardAD1, forwardBD1, forwardAD2, forwardBD2,
					 dependency, dependency_prev,
					 regwriteW1, regwriteW2,
					 writeregW1, writeregW2,
					 resultW1, resultW2,
					 aluoutM1, aluoutM2,
					 memtoregD1, memtoregD2,
					 RegWriteD1, RegWriteD2,
					 MemWriteD1, MemWriteD2,
					 branchD1, branchD2,
					 alucontrolD1, alucontrolD2,
					 alusrcD1, alusrcD2,
					 regdstD1, regdstD2,
				 	 jumpD1, jumpD2,
					 RD11, RD12, RD21, RD22, signimmD1, unsignimmD1, signimmD2, unsignimmD2,
					 RsD1, RtD1, RdD1, RsD2, RtD2, RdD2, 
					 pcbranchD1, pcbranchD2, PCPlus4D,
				 	 pcsrcD1, pcsrcD2, misspredict1, misspredict2,
				 	 predict_takenD,
					 jumpdstD1, jumpdstD2);

	wire MemWriteE1, MemWriteE2;
	wire jumpE1, jumpE2;
	wire [31:0] aluoutE1, aluoutE2;
	wire [31:0] writedataE1, writedataE2, PCPlus4E;

	execute e(clk, rst, flushE, stallE,
						memtoregD1, memtoregD2,
						RegWriteD1, RegWriteD2,
						MemWriteD1, MemWriteD2,
						alucontrolD1, alucontrolD2,
						alusrcD1, alusrcD2,
						regdstD1, regdstD2,
						jumpD1, jumpD2,
						forwardAE1, forwardBE1, forwardAE2, forwardBE2,
						dependency,
						RD11, RD12, RD21, RD22, signimmD1, unsignimmD1, signimmD2, unsignimmD2,
						RsD1, RtD1, RdD1, RsD2, RtD2, RdD2,
						aluoutM1, aluoutM2, resultW1, resultW2,
						PCPlus4F,
						MemtoRegE1, MemtoRegE2,
						RegWriteE1, RegWriteE2,
						MemWriteE1, MemWriteE2,
						jumpE1, jumpE2,
						RsE1, RtE1, RsE2, RtE2,
						aluoutE1, aluoutE2, 
						writedataE1, writedataE2, PCPlus4E,
						writeregE1, writeregE2);

	wire jumpM1, jumpM2;
	wire[31:0] ReadDataM1, ReadDataM2, PCPlus8M;

	memory m(clk, rst, stallM,
					 MemtoRegE1, MemtoRegE2,
					 RegWriteE1, RegWriteE2,
					 MemWriteE1, MemWriteE2,
					 jumpE1, jumpE2,
					 aluoutE1, aluoutE2,
					 writedataE1, writedataE2, PCPlus4E,
					 writeregE1, writeregE2,
					 MemtoRegM1, MemtoRegM2,
					 RegWriteM1, RegWriteM2,
					 jumpM1, jumpM2,
					 ReadDataM1, ReadDataM2, aluoutM1, aluoutM2, PCPlus8M,
					 writeregM1, writeregM2,
					 hitM);
	
	writeback w(clk, rst, stallW,
							MemtoRegM1, MemtoRegM2,
							RegWriteM1, RegWriteM2,
							jumpM1, jumpM2,
							ReadDataM1, ReadDataM2, aluoutM1, aluoutM2, PCPlus8M,
							writeregM1, writeregM2,
							regwriteW1, regwriteW2,
							resultW1, resultW2,
							writeregW1, writeregW2,
							jumpD1, jumpD2, pcsrcD1, pcsrcD2,
							predict_takenF, predict_takenD,
							jumpdstD1, jumpdstD2,
							PCPlus4F, PCPlus4D, pcbranchD1, pcbranchD2, PCBranchPredict,
							PC);
endmodule