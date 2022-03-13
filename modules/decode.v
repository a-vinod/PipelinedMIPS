module decode(input clk, reset, stallD,
							input [1:0] predict_takenF,
							input [31:0] instrF1, instrF2, PCPlus4F,
							input [1:0] forwardAD1, forwardBD1, forwardAD2, forwardBD2,
							input dependency,
							output dependency_prev,
							input regwriteW1, regwriteW2,
							input [4:0] writeregW1, writeregW2,
							input [31:0] resultW1, resultW2,
							input [31:0] aluoutM1, aluoutM2,
							// Control Signals
							output [3:0] MemtoRegD1, MemtoRegD2,
							output RegWriteD1, RegWriteD2,
							output MemWriteD1, MemWriteD2,
							output [1:0] branchD1, branchD2,
							output [2:0] alucontrolD1, alucontrolD2,
							output [1:0] alusrcD1, alusrcD2,
							output regdstD1, regdstD2,
							output jumpD1, jumpD2,
							// Data Outputs 
							output [31:0] RD11, RD12, RD21, RD22, signimmD1, unsignimmD1, signimmD2, unsignimmD2,
							output [4:0] RsD1, RtD1, RdD1, RsD2, RtD2, RdD2,
							output [31:0] pcbranchD1, pcbranchD2, pcplus4D,
							output pcsrcD1, pcsrcD2, misspredict1, misspredict2,
							output [1:0] predict_takenD,
							output [27:0] jumpdstD1, jumpdstD2);
							
	reg [31:0] instrD1, instrD2, pcplus4D_;

	controller c1(instrD1[31:26], instrD1[5:0],
		       multstartD, multsgnD,
		       branchD1, MemtoRegD1, MemWriteD1,
		       alusrcD1, regdstD1, RegWriteD1, jumpD1,
		       alucontrolD1);
	controller c2(instrD2[31:26], instrD2[5:0],
		       multstartD, multsgnD,
		       branchD2, MemtoRegD2, MemWriteD2,
		       alusrcD2, regdstD2, RegWriteD2, jumpD2,
		       alucontrolD2);

	//Register File
	wire [31:0] rd11, rd12, rd21, rd22;
	regfile rf(clk, reset, regwriteW1, regwriteW2, instrD1[25:21], instrD1[20:16], writeregW1, resultW1, instrD2[25:21], instrD2[20:16], writeregW2, resultW2, rd11, rd12, rd21, rd22);

	//rsD, rtD, reD
	assign RsD1 = instrD1[25:21];
	assign RtD1 = instrD1[20:16];
	assign RdD1 = instrD1[15:11];
	assign RsD2 = instrD2[25:21];
	assign RtD2 = instrD2[20:16];
	assign RdD2 = instrD2[15:11];


	//extension
	signext se1(instrD1[15:0], signimmD1);
	signext se2(instrD2[15:0], signimmD2);
	unsignext tuse1(instrD1[15:0], unsignimmD1);
	unsignext tuse2(instrD2[15:0], unsignimmD2);

	//branch
	wire [31:0] shiftedsignimm1, shiftedsignimm2;
	sl2 immsh1(signimmD1, shiftedsignimm1);
	adderD pcaddD1(pcplus4D_, shiftedsignimm1, pcbranchD1);
	sl2 immsh2(signimmD2, shiftedsignimm2);
	adderD pcaddD2(pcplus4D_, shiftedsignimm2, pcbranchD2);

	//branch early decision
	assign RD11 = forwardAD1[1] ? aluoutM2 : (forwardAD1[0] ? aluoutM1 : rd11);
	assign RD12 = forwardBD1[1] ? aluoutM2 : (forwardBD1[0] ? aluoutM1 : rd12);
	assign RD21 = forwardAD2[1] ? aluoutM1 : (forwardAD2[0] ? aluoutM2 : rd21);
	assign RD22 = forwardBD2[1] ? aluoutM1 : (forwardBD2[0] ? aluoutM2 : rd22);

	wire pcsrcD1_, pcsrcD2_;
	branchComparison bc1(RD11,RD12,branchD1,pcsrcD1_);//branch comparasion
	branchComparison bc2(RD21,RD22,branchD2,pcsrcD2_);
	assign pcsrcD1 = dependency ? 0 : pcsrcD1_;
	assign pcsrcD2 = dependency ? 0 : pcsrcD2_;

	//j type address
	assign jumpdstD1 = instrD1[25:0] << 2;
	assign jumpdstD2 = instrD2[25:0] << 2;
	assign pcplus4D = pcplus4D_;

	reg [1:0] predict_takenD_;
	assign predict_takenD = predict_takenD_;

	assign misspredict1 = (!predict_takenD[0] && pcsrcD1) || (predict_takenD[0] && !pcsrcD1);
	assign misspredict2 = (!predict_takenD[1] && pcsrcD2) || (predict_takenD[1] && !pcsrcD2);
	assign misspredict  = misspredict2 || misspredict1;

	reg dependency_prev_;
	assign dependency_prev = dependency_prev_;
	reg [31:0] instrF1_prev, instrF2_prev;

	always @ (posedge clk, posedge reset) begin 
			if (reset || ((jumpD1 || jumpD2 || misspredict) && !stallD)) begin
					if (reset || jumpD1 || misspredict) begin
						instrD1 <= 32'b0;
						instrD2 <= 32'b0;
					end else if (jumpD2)
						instrD2 <= 32'b0;

					pcplus4D_ <= 32'b0;
					predict_takenD_ <= 2'b00;
					dependency_prev_ <= 0;
					instrF1_prev <= 32'b0;
					instrF2_prev <= 32'b0;
			end else if (!stallD) begin
					dependency_prev_ <= dependency;

					if (dependency) begin
						instrD1 <= instrF1_prev;
						instrD2 <= 32'b0;
					end else begin
						predict_takenD_ <= predict_takenF;
						pcplus4D_ <= PCPlus4F;
						if (dependency_prev_) begin
							instrD1 <= 32'b0;
							instrD2 <= instrF2_prev;
						end else begin
							instrD1 <= instrF1;
							instrD2 <= instrF2;
							instrF1_prev <= instrF1;
							instrF2_prev <= instrF2;
						end
					end
			end
	end

endmodule

module signext (input [15:0] a, //signExtension
output [31:0] y);
    assign y = {{16{a[15]}}, a};
endmodule


//unsign for ori
module unsignext (input [15:0] a, //signExtension
output [31:0] y);
    wire e;
    assign e = 0;
    assign y = {{16{e}}, a};
endmodule


module adderD (input [31:0] a, b,
output [31:0] y);
    assign y = a + b;
endmodule


//This module shift input signal two bits to the left
// which is how we implement PC? = PC + 4 + SignImm × 4 in beq
module sl2 (input [31:0] a,
output [31:0] y);
// shift left by 2
    assign y = a<<2;
endmodule


module branchComparison (  //branch comparasion
	input [31:0] SRCA, SRCB,
	input [1:0] OP,
	output reg COMP
	);

	always@(*)
	begin
		if(OP == 2'b10 && SRCA != SRCB) //bne
		  COMP <= 1;
		else if(OP == 2'b01 &&  SRCA == SRCB)//beq
		  COMP <= 1;
		else
		  COMP <= 0;
	end

endmodule
