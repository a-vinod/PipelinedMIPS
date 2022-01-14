`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module alu_tb;
  reg clk;
  reg [31:0] a, b;
  reg [2:0] f;
  wire [31:0] out;
  wire zero;
  
  ALU dut(.a(a), .b(b), .f(f), .y(out), .zero(zero));
  
  initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1);
    
    // Test and
    clk = 0;
    f = 3'b000;
    a = 32'b1;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b1;
    b = 32'b0;
    
    #5 clk = 0;
    a = 32'b0;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b0;
    
    // Test or
    #5 clk = 0;
    f = 3'b001;
    a = 32'b1;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b1;
    b = 32'b0;
    
    #5 clk = 0;
    a = 32'b0;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b0;
    
    // Test add
    #5 clk = 0;
    f = 3'b001;
    a = 32'b1;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b1;
    b = 32'b0;
    
    #5 clk = 0;
    a = 32'b0;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b0;
    
    // Test xor
    #5 clk = 0;
    f = 3'b011;
    a = 32'b1;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b1;
    b = 32'b0;
    
    #5 clk = 0;
    a = 32'b0;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b0;
    
    // Test xnor
    #5 clk = 0;
    f = 3'b100;
    a = 32'b1;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b1;
    
    #5 clk = 0;
    a = 32'b1;
    b = 32'b0;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b0;
    
    // Test sub
    #5 clk = 0;
    f = 3'b101;
    a = 32'b10;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b100;
    b = 32'b100;
    
    #5 clk = 0;
    a = 32'b1010;
    b = 32'b101;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b0;
    
    // Test slt
    #5 clk = 0;
    f = 3'b110;
    a = 32'b1;
    b = 32'b1;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b1;
    
    #5 clk = 0;
    a = 32'b1;
    b = 32'b0;
    
    #5 clk = 1;
    a = 32'b0;
    b = 32'b0;
    
    // Test <<
    #5 clk = 0;
    f = 3'b111;
    a = 32'b1;
    b = 32'b100;
    
    #5;
    
  end
endmodule
