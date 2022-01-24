`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module multiplier_tb;
  reg clk, rst, MultE, MultSgn;
  reg [31:0] SrcAE, SrcBE;
  wire [31:0] A, B;
  reg [2:0]  ALU_f_add;
  wire        zero;
  wire [31:0] hi, lo, ALUOut;
  wire completed;
  
  ALU alu(.a(A), .b(B), .f(ALU_f_add), .y(ALUOut), .zero(zero));
  
  multiplier dut(.clk(clk), .rst(rst), .SrcAE(SrcAE), .SrcBE(SrcBE), .MultE(MultE), .MultSgn(MultSgn), .ALUOut(ALUOut), .ALU_zero(zero), .ALU_A(A), .ALU_B(B), .hi(hi), .lo(lo), .completed(completed));
  
  integer i;
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    clk = 0;
    rst = 0;
    ALU_f_add = 3'b010;
    
    MultSgn = 0;
    MultE = 1;
    // replace these values for testing 
    SrcAE = 6'b110011;
    SrcBE = 6'b110011;
    
    #5 clk = !clk;
    rst = 0;
    #5 clk = !clk;
    rst = 1;
    #5 clk = !clk;
    rst = 0;
    
    
    for (i = 0; i < 68; i = i + 1) begin
      #5 clk = !clk;
    end
  end
  
endmodule
