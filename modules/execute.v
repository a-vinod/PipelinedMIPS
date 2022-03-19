module execute(input clk, rst, flushE, stallE,
               // Control signals
               input [3:0] MemtoRegD1, MemtoRegD2,
               input RegWriteD1, RegWriteD2,
               input MemWriteD1, MemWriteD2,
               input [2:0] alucontrolD1, alucontrolD2,
               input [1:0] alusrcD1, alusrcD2,
               input regdstD1, regdstD2,
               input jumpD1, jumpD2,
               input [2:0] forwardAE1, forwardBE1, forwardAE2, forwardBE2,
               output dependency,
               // Data
               input [31:0] RD11, RD12, RD21, RD22, signimmD1, unsignimmD1, signimmD2, unsignimmD2,
               input [4:0] RsD1, RtD1, RdD1, RsD2, RtD2, RdD2,
               input [31:0] aluoutM1, aluoutM2, resultW1, resultW2,
               input [31:0] PCPlus4F,
               // Output
               // Control Signals
               output [3:0] MemtoRegE1, MemtoRegE2,
               output RegWriteE1, RegWriteE2,
               output MemWriteE1, MemWriteE2,
               output jumpE1, jumpE2,
               // Data
               output [4:0] RsE1, RtE1, RsE2, RtE2,
               output [31:0] aluoutE1, aluoutE2, 
               output [31:0] writedataE1, writedataE2, PCPlus4E,
               output [4:0] writeregE1, writeregE2);

  wire [31:0] srcA1, srcB1, srcB1_, srcA2, srcB2, srcB2_;

  reg [3:0] MemtoRegD1_, MemtoRegD2_;
  reg RegWriteD1_, RegWriteD2_;
  reg MemWriteD1_, MemWriteD2_;
  reg [2:0] alucontrolD1_, alucontrolD2_;
  reg [1:0] alusrcD1_, alusrcD2_;
  reg regdstD1_, regdstD2_;
  reg jumpD1_, jumpD2_;

  reg [31:0] RD11_, RD12_, RD21_, RD22_, signimmD1_, unsignimmD1_, signimmD2_, unsignimmD2_;
  reg [31:0] RsD1_, RtD1_, RdD1_, RsD2_, RtD2_, RdD2_;

  reg [31:0] PCPlus4F_;

  assign srcA1  = forwardAE1[2] ? resultW2 : (forwardAE1[1] ? (forwardAE1[0] ? aluoutM2 : aluoutM1)	: (forwardAE1[0] ? resultW1 	 : RD11_));
  assign srcB1_ = forwardBE1[2] ? resultW2 : (forwardBE1[1] ? (forwardBE1[0] ? aluoutM2 : aluoutM1)	: (forwardBE1[0] ? resultW1 	 : RD12_));
  assign srcB1  = alusrcD1_[1]  ? (unsignimmD1_) : (alusrcD1_[0]  ? signimmD1_ : srcB1_);

  assign writedataE1 = srcB1_;

  assign srcA2  = forwardAE2[2] ? resultW1 : (forwardAE2[1] ? (forwardAE2[0] ? aluoutM1 : aluoutM2) : (forwardAE2[0] ? resultW2 : RD21_));
  assign srcB2_ = forwardAE2[2] ? resultW1 : (forwardBE2[1] ? (forwardBE2[0] ? aluoutM1 : aluoutM2)	: (forwardBE2[0] ? resultW2 : RD22_));
  assign srcB2  = alusrcD2_[1]  ? (unsignimmD2_) : (alusrcD2_[0]  ? signimmD2_ : srcB2_);

  assign writedataE2 = srcB2_;
  wire zero1, zero2;
  ALU alu1(srcA1, srcB1, alucontrolD1_, aluoutE1, zero1);
  ALU alu2(srcA2, srcB2, alucontrolD2_, aluoutE2, zero2);

  assign writeregE1 = regdstD1_ ? RdD1_ : RtD1_;
  assign writeregE2 = regdstD2_ ? RdD2_ : RtD2_;

  assign RsE1 = RsD1_;
  assign RtE1 = RtD1_;
  assign RsE2 = RsD2_;
  assign RtE2 = RtD2_;

  assign MemtoRegE1 = MemtoRegD1_;
  assign MemtoRegE2 = MemtoRegD2_;

  assign MemWriteE1 = MemWriteD1_;
  assign MemWriteE2 = MemWriteD2_;

  assign RegWriteE1 = RegWriteD1_;
  assign RegWriteE2 = RegWriteD2_;

  assign jumpE1 = jumpD1_;
  assign jumpE2 = jumpD2_;

  assign PCPlus4E = PCPlus4F_;

  // RAW or WAW
  assign dependency = (((RsD2 == (regdstD1 ? RdD1 : RtD1)) || (RtD2 == (regdstD1 ? RdD1 : RtD1))) && RegWriteD1) || (RegWriteD1 && RegWriteD2 && ((regdstD1 ? RdD1 : RtD1) == (regdstD2 ? RdD2 : RtD2)));

  always @ (posedge clk, posedge rst) begin
    if (rst || flushE) begin
      MemtoRegD1_ <= 0;
      MemtoRegD2_ <= 0;
      RegWriteD1_ <= 0;
      RegWriteD2_ <= 0;
      MemWriteD1_ <= 0;
      MemWriteD2_ <= 0;
      alucontrolD1_ <= 0;
      alucontrolD2_ <= 0;
      alusrcD1_ <= 0;
      alusrcD2_ <= 0;
      regdstD1_ <= 0;
      regdstD2_ <= 0;
      jumpD1_ <= 0;
      jumpD2_ <= 0;

      RD11_ <= 0;
      RD12_ <= 0;
      RD21_ <= 0;
      RD22_ <= 0;
      signimmD1_ <= 0;
      unsignimmD1_ <= 0;
      signimmD2_ <= 0;
      unsignimmD2_ <= 0;
      RsD1_ <= 0;
      RtD1_ <= 0;
      RdD1_ <= 0;
      RsD2_ <= 0;
      RtD2_ <= 0;
      RdD2_ <= 0;
      PCPlus4F_ <= 0;
    end else if (!stallE) begin
      MemtoRegD1_ <= MemtoRegD1;
      MemtoRegD2_ <= MemtoRegD2;
      RegWriteD1_ <= RegWriteD1;
      RegWriteD2_ <= RegWriteD2;
      MemWriteD1_ <= MemWriteD1;
      MemWriteD2_ <= MemWriteD2;
      alucontrolD1_ <= alucontrolD1;
      alucontrolD2_ <= alucontrolD2;
      alusrcD1_ <= alusrcD1;
      alusrcD2_ <= alusrcD2;
      regdstD1_ <= regdstD1;
      regdstD2_ <= regdstD2;
      jumpD1_ <= jumpD1;
      jumpD2_ <= jumpD2;

      RD11_ <= RD11;
      RD12_ <= RD12;
      RD21_ <= RD21;
      RD22_ <= RD22;
      signimmD1_ <= signimmD1;
      unsignimmD1_ <= unsignimmD1;
      signimmD2_ <= signimmD2;
      unsignimmD2_ <= unsignimmD2;
      RsD1_ <= RsD1;
      RtD1_ <= RtD1;
      RdD1_ <= RdD1;
      RsD2_ <= RsD2;
      RtD2_ <= RtD2;
      RdD2_ <= RdD2;
      PCPlus4F_ <= PCPlus4F;
    end
  end

endmodule
