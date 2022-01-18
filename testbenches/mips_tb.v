`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module mips_tb;
    reg     clk, rst;
    integer i;
  
  	mips m(clk, rst);
  
    initial begin
      rst <= 1; # 12; rst <= 0;
    end

      always
    begin
      clk <= 1; # 5;
      clk <= 0; # 5;
    end

endmodule