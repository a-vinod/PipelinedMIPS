module writeback(input clk, rst, stallW,
                 // Control signals
                 input [3:0] MemtoRegM1, MemtoRegM2,
                 input RegWriteM1, RegWriteM2,
                 input jumpM1, jumpM2,
                 // Data
                 input [31:0] ReadDataM1, ReadDataM2, aluoutM1, aluoutM2, PCPlus8M,
                 input [4:0] writeregM1, writeregM2,
                 // Output
                 // Control Signals
                 output RegWriteW1, RegWriteW2,
                 // Data
                 output [31:0] ResultW1, ResultW2,
                 output [4:0] WriteRegW1, WriteRegW2,

                 // Next PC
                 input jumpD1, jumpD2, pcsrcD1, pcsrcD2,
                 input [1:0] predict_takenF, predict_takenD,
                 input [27:0] jumpDstD1, jumpDstD2,
                 input [31:0] PCPlus4F, PCPlus4D, PCBranchD1, PCBranchD2, PCBranchPredict,
                 output [31:0] PC);

  reg [3:0] MemtoRegM1_, MemtoRegM2_;
  reg RegWriteM1_, RegWriteM2_;
  reg jumpM1_, jumpM2_;
  reg [31:0] ReadDataM1_, ReadDataM2_, aluoutM1_, aluoutM2_, PCPlus8M_;
  reg [4:0] writeregM1_, writeregM2_;

  assign WriteRegW1 = jumpM1_ ? 5'b11111 : writeregM1_;
  assign WriteRegW2 = jumpM2_ ? 5'b11111 : writeregM2_;

  assign ResultW1 = MemtoRegM1_[1] ? (MemtoRegM1_[0] ? ReadDataM1_ : aluoutM1_) : PCPlus8M_;
  assign ResultW2 = MemtoRegM2_[1] ? (MemtoRegM2_[0] ? ReadDataM2_ : aluoutM2_) : PCPlus8M_;

  assign RegWriteW1 = RegWriteM1_;
  assign RegWriteW2 = RegWriteM2_;

  wire [31:0] PC1, PC2;
  assign PC1 = jumpD1 ? {PCPlus4F[31:28], jumpDstD1} : ((predict_takenD[0] && !pcsrcD1) ? (PCPlus4D) : ((!predict_takenD[0] && pcsrcD1) ? (PCBranchD1) : (predict_takenF[0] ? PCBranchPredict : PCPlus4F)));
  assign PC2 = jumpD2 ? {PCPlus4F[31:28], jumpDstD2} : ((predict_takenD[1] && !pcsrcD2) ? (PCPlus4D) : ((!predict_takenD[1] && pcsrcD2) ? (PCBranchD2) : (predict_takenF[1] ? PCBranchPredict : PCPlus4F)));

  // Branching 
  // Case 1: instrF1 and instrF2 branch predict taken -> PC = branch predicted by PC of instrF1
  // mispredicted -> PC = pcplus4D
  // Case 2: instrF1 and instrF2 branch predict not taken -> PC = PC+8
  // mispredicted isntrF1 -> PC = pcbranchD1
  // mispredicted instrF2 -> PC = prbranchD2

  assign PC = (jumpD1 || predict_takenF[0] || (predict_takenD[0] && !pcsrcD1) || (!predict_takenD[0] && pcsrcD1)) ? PC1 : PC2;

  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      MemtoRegM1_ <= 0;
      MemtoRegM2_ <= 0;
      RegWriteM1_ <= 0;
      RegWriteM2_ <= 0;
      jumpM1_ <= 0;
      jumpM2_ <= 0;
      ReadDataM1_ <= 0;
      ReadDataM2_ <= 0;
      aluoutM1_ <= 0;
      aluoutM2_ <= 0;
      PCPlus8M_ <= 0;
      writeregM1_ <= 0;
      writeregM2_ <= 0;
    end else if (!stallW) begin
      MemtoRegM1_ <= MemtoRegM1;
      MemtoRegM2_ <= MemtoRegM2;
      RegWriteM1_ <= RegWriteM1;
      RegWriteM2_ <= RegWriteM2;
      jumpM1_ <= jumpM1;
      jumpM2_ <= jumpM2;
      ReadDataM1_ <= ReadDataM1;
      ReadDataM2_ <= ReadDataM2;
      aluoutM1_ <= aluoutM1;
      aluoutM2_ <= aluoutM2;
      PCPlus8M_ <= PCPlus8M;
      writeregM1_ <= writeregM1;
      writeregM2_ <= writeregM2;
    end
  end
endmodule
