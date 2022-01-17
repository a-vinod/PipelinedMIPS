`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module mips_tb;
    reg     clk, rst;
    integer i;
  
  	mips m(clk, rst);
  
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1);
      	clk = 0;
      	rst = 0;
        #5 clk = !clk;
        rst = 0;
        #5 clk = !clk;
        rst = 1;
        #5 clk = !clk;
        rst = 0;
      
      	for (i = 0; i < 10; i = i + 1) begin
            #5 clk = !clk;
        end
    end
endmodule
