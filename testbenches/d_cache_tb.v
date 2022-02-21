`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module d_cache_tb;
    reg         clk, rst;
  	reg  [31:0] A;
  	reg  [127:0] WM;
  	reg  	   	READY;
  	wire 		HIT;
    wire [31:0] RD;
  
  	d_cache dut(clk, rst, A, WM, READY, HIT, RD);
  
  	integer i;
    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars;

        clk = 1;
        rst <= 1;
        #5;
        clk <= 0; 
        rst <= 0;
        #5;

      	// TEST 1 : loading data to cache
        // A : tag_set_word-offset_block-offset
        A     <= 32'b10000000000000000000_00010000_00_00;
        READY <=  1'b0;

        // 20 cycle delay to simulate memory delay
        for (i = 0; i < 20; i = i  + 1) begin
            clk <= 1; #5;
            clk <= 0; #5;
        end
      
      	WM    <= {{32'hAAAA}, {32'hAAA}, {32'hAA}, {32'hA}};
        READY <= 1'b1;
        clk   <= 1; #5;
        clk   <= 0; #5;
      	READY <= 1'b0;
        clk <= 1; #5;
        clk <= 0; #5;

      
      	// TEST 2 : Loading data to same set in cache
      	READY <= 1'b0;
      	A     <= 32'b11000000000000000000_00010000_00_00;
        clk <= 1; #5;
        clk <= 0; #5;
      
        // 20 cycle delay to simulate memory delay
        for (i = 0; i < 20; i = i  + 1) begin
            clk <= 1; #5;
            clk <= 0; #5;
        end
      
      	WM    <= {{32'hBBBB}, {32'hBBB}, {32'hBB}, {32'hB}};
        READY <= 1'b1;
        clk   <= 1; #5;
        clk   <= 0; #5;
		READY <= 1'b0;
        clk   <= 1; #5;
        clk   <= 0; #5;

        // TEST 3: Loading data into same set of cache, verifying LRU policy
      	// Should replace way 0
      	READY <= 1'b0;
      	A     <= 32'b00000000000000000000_00010000_00_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      
        // 20 cycle delay to simulate memory delay
        for (i = 0; i < 20; i = i  + 1) begin
            clk <= 1; #5;
            clk <= 0; #5;
        end
      
      	WM    <= {{32'hCCCC}, {32'hCCC}, {32'hCC}, {32'hC}};
        READY <= 1'b1;
        clk   <= 1; #5;
        clk   <= 0; #5;
      
		READY <= 1'b0;
        clk   <= 1; #5;
        clk   <= 0; #5;
      
      	// TEST 4: Loading data into same set of cache, verifying LRU policy
      	// should replace way 1
      	READY <= 1'b0;
      	A     <= 32'b00000000000000000001_00010000_00_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      
        // 20 cycle delay to simulate memory delay
        for (i = 0; i < 20; i = i  + 1) begin
            clk <= 1; #5;
            clk <= 0; #5;
        end
      
      	WM    <= {{32'hDDDD}, {32'hDDD}, {32'hDD}, {32'hD}};
        READY <= 1'b1;
        clk   <= 1; #5;
        clk   <= 0; #5;

      	READY <= 1'b0;
        clk   <= 1; #5;
        clk   <= 0; #5;
      
      	// TEST 5 : Testing word offset
      	A     <= 32'b00000000000000000001_00010000_00_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      	A     <= 32'b00000000000000000001_00010000_01_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      	A     <= 32'b00000000000000000001_00010000_10_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      	A     <= 32'b00000000000000000001_00010000_11_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      
		A     <= 32'b00000000000000000000_00010000_00_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      	A     <= 32'b00000000000000000000_00010000_01_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      	A     <= 32'b00000000000000000000_00010000_10_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      	A     <= 32'b00000000000000000000_00010000_11_00;
        clk   <= 1; #5;
        clk   <= 0; #5;
      
      	clk   <= 1; #5;
        clk   <= 0; #5;
    end

endmodule
