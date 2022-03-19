module memory(input clk, rst, stallM,
              // Control Signals
              input [3:0] MemtoRegE1, MemtoRegE2,
              input RegWriteE1, RegWriteE2,
              input MemWriteE1, MemWriteE2,
              input jumpE1, jumpE2,
              // Data
              input [31:0] aluoutE1, aluoutE2,
              input [31:0] writedataE1, writedataE2, PCPlus4E,
              input [4:0] writeregE1, writeregE2,
              // Output
              // Control Signals
              output [3:0] MemtoRegM1, MemtoRegM2,
              output RegWriteM1, RegWriteM2,
              output jumpM1, jumpM2,
              // Data
              output [31:0] ReadDataM1, ReadDataM2, aluoutM1, aluoutM2, PCPlus8M,
              output [4:0] writeregM1, writeregM2,
              output hitM);

  reg [3:0] MemtoRegE1_,MemtoRegE2_;
  reg RegWriteE1_,RegWriteE2_;
  reg MemWriteE1_,MemWriteE2_;
  reg jumpE1_,jumpE2_;
  reg [31:0] aluoutE1_,aluoutE2_;
  reg [31:0] writedataE1_,writedataE2_,writeregE1_,writeregE2_,PCPlus4E_;

  assign MemtoRegM1 = MemtoRegE1_;
  assign MemtoRegM2 = MemtoRegE2_;
  assign RegWriteM1 = RegWriteE1_;
  assign RegWriteM2 = RegWriteE2_;
  assign jumpM1		  = jumpE1_;
  assign jumpM2		  = jumpE2_;
  assign aluoutM1		= aluoutE1_;
  assign aluoutM2		= aluoutE2_;
  assign writeregM1 = writeregE1_;
  assign writeregM2 = writeregE2_;
  assign PCPlus8M		= PCPlus4E + 4;

  wire READY;
  wire [511:0] WM1, WM2;
  data_memory dm(clk, rst, MemWriteE1_, MemWriteE2_, MemtoRegE1_, MemtoRegE2_, aluoutE1_, aluoutE2_, writedataE1_, writedataE2_, READY, WM1, WM2);
  d_cache			dc(clk, rst, MemWriteE1_, MemWriteE2_, MemtoRegE1_, MemtoRegE2_, aluoutE1_, aluoutE2_, writedataE1_, writedataE2_, WM1, WM2, READY, hitM, ReadDataM1, ReadDataM2);

  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      MemtoRegE1_<= 0;
      MemtoRegE2_<= 0;
      RegWriteE1_<= 0;
      RegWriteE2_<= 0;
      MemWriteE1_<= 0;
      MemWriteE2_<= 0;
      jumpE1_<= 0;
      jumpE2_<= 0;
      aluoutE1_<= 0;
      aluoutE2_<= 0;
      writedataE1_<= 0;
      writedataE2_<= 0;
      writeregE1_<= 0;
      writeregE2_<= 0;
      PCPlus4E_<= 0;
    end else if (!stallM) begin
      MemtoRegE1_<= MemtoRegE1;
      MemtoRegE2_<= MemtoRegE2;
      RegWriteE1_<= RegWriteE1;
      RegWriteE2_<= RegWriteE2;
      MemWriteE1_<= MemWriteE1;
      MemWriteE2_<= MemWriteE2;
      jumpE1_<= jumpE1;
      jumpE2_<= jumpE2;
      aluoutE1_<= aluoutE1;
      aluoutE2_<= aluoutE2;
      writedataE1_<= writedataE1;
      writedataE2_<= writedataE2;
      writeregE1_<= writeregE1;
      writeregE2_<= writeregE2;
      PCPlus4E_<= PCPlus4E;
    end
  end

endmodule
