`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module decode_tb;
reg clk, reset, stallD;
reg [31:0] instrF, pcplus4F;
reg forwardAD, forwardBD;
reg [4:0] writeregW;
reg [31:0] resultW, aluoutM;
reg regwriteW;
wire [31:0] pcplus4D, pcbranchD;
wire [1:0] branchD, alusrcD;
wire [2:0] wbsrcD, alucontrolD;
wire [4:0] rsD, rtD, reD;
wire [31:0] signimmD, unsignimmD;
wire multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD;
wire pcsrcD;
wire [31:0] rd1d, rd2d;
wire [27:0] jumpdstD;

    decode dut(clk, reset, stallD,
 instrF, pcplus4F,
forwardAD, forwardBD,
 writeregW,
resultW, aluoutM,
regwriteW,
 pcplus4D, pcbranchD,
  branchD, alusrcD,
 wbsrcD, alucontrolD,
  rsD, rtD, reD,
 signimmD, unsignimmD,
 multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD,
 pcsrcD,
  rd1d, rd2d,
 jumpdstD);

    integer i;
  // initialize test
  initial
    begin

      reset <= 1; # 12; reset <= 0;
	  pcplus4F <= 0;
      instrF <= 32'b111000100010000000100101;
      stallD <= 0;
      forwardAD <= 0;
      forwardBD <= 0;
      writeregW <= 5'b000;
      resultW <= 0;
      regwriteW <= 0;
    aluoutM <= 0;
     i <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5;
      clk <= 0; # 5;
      i = i + 1;
      if(i==2)
        instrF <= 32'b00100000000000100000000000000101;
      if(i==5)
        instrF <= 32'b00100000000000110000000000001100;
      if(i==15)
      begin
        stallD <= 1;
        instrF <= 32'b00100000011001111111111111110111;
      end
      if(i==16)
        instrF <= 32'b00000000011001000010100000100100;
      if(i==20)
      begin
        stallD <= 0;
        instrF <= 32'b00000000101001000010100000100000;
      end
      if(i==21)
        instrF <= 32'b00100000000001010000000000000000;
    end

always@(posedge clk)
    begin
    pcplus4F <= pcplus4D + 4;
    end
endmodule