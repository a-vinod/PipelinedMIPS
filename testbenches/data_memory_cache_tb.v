`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module data_memory_cache_tb;
    reg          clk, rst, WE;
  	reg  [31:0]  A, WD;
  	wire 		 READY;
  wire [127:0] WM;
  
  data_memory mdut(clk, rst, WE, A, WD, READY, WM);
  	wire 		HIT;
    wire [31:0] RD;
  
  	d_cache cdut(clk, rst, A, WM, READY, HIT, RD);
  
  	integer i;
    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;

        rst <= 1;
        clk = 1; #5;
      	clk = 0; #5;
     
        rst <= 0;
        clk = 1; #5;
      	clk = 0; #5;
      
      	// Load 4 words to data memory
      	A  <= 32'b0000;
      	WD <= 32'hAAAAAAAA;
      	WE <= 1;
        clk = 1; #5;
      	clk = 0; #5;
      
      	A  <= 32'b0100;
      	WD <= 32'hBBBBBBBB;
      	WE <= 1;
        clk = 1; #5;
      	clk = 0; #5;
      
      	A  <= 32'b1000;
      	WD <= 32'hCCCCCCCC;
      	WE <= 1;
        clk = 1; #5;
      	clk = 0; #5;

      	A  <= 32'b1100;
      	WD <= 32'hDDDDDDDD;
      	WE <= 1;
        clk = 1; #5;
      	clk = 0; #5;
      
      	// TEST: Fetch 4 words corresponding to address 0000000000000000000000000000XX00
      	A  <= 32'b0000;
      	WE <= 0;
        for (i = 0; i < 20; i = i + 1) begin
            clk = 1; #5;
            clk = 0; #5;
        end
      
      	clk = 1; #5;
      	clk = 0; #5;
    end

endmodule
