`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module mips_tb;
    reg     clk, rst;
    integer i;
  
  	mips m(clk, rst);
  
    initial begin
      $dumpfile("dump.vcd");
      $dumpvars;
      clk = 1;
      rst <= 1;
      #5;
      clk <= 0; 
      rst <= 0;
      #5;
      
      // change upper bound to adjust number of cycles
      for (i = 0; i < 250; i = i  + 1) begin
      clk <= 1; # 5;
      clk <= 0; # 5;
    end
    end

endmodule
