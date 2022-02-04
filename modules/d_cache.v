// Code your testbench here
// or browse Examples
module d_cache(input		 	  clk, rst,	
               input      [31:0]  A,
               input	  [127:0] WM, // 4 words per block
               input 	 		  READY,
               output 			  HIT,
               output     [31:0]  RD);
  	// Useful Indices:
  	// cache[][127:0]       : data_0
  	// 	   cache[][31:0]    : word_0
  	// 	   cache[][63:32]   : word_1
  	// 	   cache[][95:64]   : word_2
  	// 	   cache[][127:96]  : word_3
  	// cache[][147:128]     : tag_0
  	// cache[][148]         : v_0
  	// cache[][276:149]     : data_1
  	// 	   cache[][180:149] : word_0
  	//     cache[][212:181] : word_1
  	//     cache[][244:213] : word_2
  	//     cache[][276:245] : word_3
  	// cache[][296:277]     : tag_1
  	// cache[][297]         : v_1
  	// cache[][298]         : LRU
  	//
    // A[31:12] : tag
    // A[11:4]  : set
    // A[3:2]   : block offset
    // A[1:0]	: byte offset
  
    wire         hit_0, hit_1;
  	reg  [298:0] cache_row;
  
    wire [19:0] tag1, tag0, a;
  	wire [127:0] data1, data0;
  	wire lru, v0, v1;
  	
  	// DEBUG WIRES
  	assign data1 = cache[A[11:4]][276:149];
  	assign data0 = cache[A[11:4]][127:0];
  	assign tag1 = cache[A[11:4]][296:277];
  	assign tag0 = cache[A[11:4]][147:128];
  	assign v1 = cache[A[11:4]][297];
  	assign v0 = cache[A[11:4]][148];
  	assign lru = cache[A[11:4]][298];
  	assign a = A[31:12];

    assign hit_0 = (cache_row[147:128] == A[31:12]) & cache_row[148];
    assign hit_1 = (cache_row[296:277] == A[31:12]) & cache_row[297];
    assign HIT   = hit_0 | hit_1;

    wire [31:0] data_0, data_1;
  	assign data_0 = A[3] ? (A[2] ? cache_row[127:96]  : cache_row[95:64])   : (A[2] ? cache_row[63:32]   : cache_row[31:0]);
  	assign data_1 = A[3] ? (A[2] ? cache_row[276:245] : cache_row[244:213]) : (A[2] ? cache_row[212:181] : cache_row[180:149]);
  	assign RD = hit_1 ? data_1 : data_0;

  	reg [298:0] cache[0:255];
  	integer i;
  	always @ (posedge clk, posedge rst) begin
        if (rst) begin
          	for (i = 0; i < 256; i = i + 1)
              	cache[i] = 299'b0;
        end else begin
            cache_row <= cache[A[11:4]];

            // Update LRU bit
          	cache[A[11:4]][298] <= HIT ? (hit_1 ? 0 : 1) : cache[A[11:4]][298];

            // Cache miss: after 20 cycles, data fetched from memory is ready
            //             on the WM line and READY signal is high
            if (!HIT & READY) begin
              	if (cache[A[11:4]][298]) begin // LRU = 1
                    cache[A[11:4]][296:277] <= A[31:12];  // Write to tag_1
                    cache[A[11:4]][276:149] <= WM; // Write to data_1
              		cache[A[11:4]][297]     <= 1;  // Update valid bit
                end else begin                     // LRU = 0
                    cache[A[11:4]][147:128] <= A[31:12];  // Write to tag_0
                    cache[A[11:4]][127:0]   <= WM; // Write to data_0
              		cache[A[11:4]][148]     <= 1;  // Update valid bit
                end
            end
        end
  	end
endmodule
