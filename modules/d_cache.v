module d_cache(input		 	  clk, rst,	WE,
							 input      [3:0] MemtoRegM,
               input      [31:0] A, WD,
               input	    [127:0] WM, // 4 words per block read from cache
               input 	 		  READY,
               output			  cache_hit,
               output   [31:0]  RD);
		reg [298:0] cache[0:255];
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
  
    wire         hit_0, hit_1, hit;
  	wire  [298:0] cache_row;
		assign cache_row = cache[A[11:4]];
  	
  	// DEBUG WIRES
		wire [19:0] tag1, tag0, a;
		wire [7:0] s;
  	wire [127:0] data1, data0;
  	wire lru, v0, v1;
  	assign data1 = cache[A[11:4]][276:149];
  	assign data0 = cache[A[11:4]][127:0];
  	assign tag1 = cache[A[11:4]][296:277];
  	assign tag0 = cache[A[11:4]][147:128];
  	assign v1 = cache[A[11:4]][297];
  	assign v0 = cache[A[11:4]][148];
  	assign lru = cache[A[11:4]][298];
  	assign a = A[31:12];
		assign s = A[11:4];

    assign hit_0 = (cache_row[147:128] == A[31:12]) && cache_row[148];
    assign hit_1 = (cache_row[296:277] == A[31:12]) && cache_row[297];
		assign hit   = hit_0 | hit_1;
		assign cache_hit = hit;

    wire [31:0] data_0, data_1;
  	assign data_0 = A[3] ? (A[2] ? cache_row[127:96]  : cache_row[95:64])   : (A[2] ? cache_row[63:32]   : cache_row[31:0]);
  	assign data_1 = A[3] ? (A[2] ? cache_row[276:245] : cache_row[244:213]) : (A[2] ? cache_row[212:181] : cache_row[180:149]);
  	assign RD = hit_1 ? data_1 : data_0;
  	
  	integer i;

  	always @ (negedge clk, posedge rst) begin
        if (rst) begin
          	for (i = 0; i < 256; i = i + 1)
              	cache[i] = 299'b0;
        end else if (MemtoRegM[1:0] == 2'b11 || WE) begin // Read/write
            // Cache miss: after 20 cycles, data fetched from memory is ready
            //             on the WM line and READY signal is high
            if (!hit && READY) begin // cache miss: read from memory
              	if (cache[A[11:4]][298]) begin     // LRU = 1
                    cache[A[11:4]][296:277] <= A[31:12];  // Write to tag_1
                    cache[A[11:4]][276:149] <= WM; // Write to data_1
              			cache[A[11:4]][297]     <= 1;  // Update valid bit
										cache[A[11:4]][298]     <= 0;  // Update LRU
                end else begin                     // LRU = 0
                    cache[A[11:4]][147:128] <= A[31:12];  // Write to tag_0
                    cache[A[11:4]][127:0]   <= WM; // Write to data_0
              			cache[A[11:4]][148]     <= 1;  // Update valid bit
										cache[A[11:4]][298]     <= 1;  // Update LRU
                end
            end else if (hit) begin	// cache hit
								// Update LRU bit
								cache[A[11:4]][298] <= hit_1 ? 0 : 1;
								if (WE) begin //Update word in cache
										if (hit_1) begin
												case (A[3:2])
														2'b00: cache[A[11:4]][180:149] <= WD;
														2'b01: cache[A[11:4]][212:181] <= WD;
														2'b10: cache[A[11:4]][244:213] <= WD;
														2'b11: cache[A[11:4]][276:245] <= WD;
												endcase
										end else if (hit_0) begin
												case (A[3:2])
														2'b00: cache[A[11:4]][31:0]   <= WD;
														2'b01: cache[A[11:4]][63:32]  <= WD;
														2'b10: cache[A[11:4]][95:64]  <= WD;
														2'b11: cache[A[11:4]][127:96] <= WD;
												endcase
										end
								end
						end
        end /*else if (WE) begin // Write-through policy
						if (hit_1 || !cache[A[11:4]][297]) begin // tag 1 match or empty spot in way 1
								case (A[3:2]) begin // Update word in cache
										2'b00: cache[A[11:4]][180:149] <= WD;
										2'b01: cache[A[11:4]][212:181] <= WD;
										2'b10: cache[A[11:4]][244:213] <= WD;
										2'b11: cache[A[11:4]][276:245] <= WD;
								end
								if (!cache[A[11:4]][297]) begin
										cache[A[11:4]][296:277] <= A[31:12];  // Write to tag_1
										cache[A[11:4]][297]     <= 1;  // Update valid bit
								end
								cache[A[11:4]][298]     <= 0; // Update LRU
						end else if (hit_0 || !cache[A[11:4]][148]) begin
								case (A[3:2]) begin // Update word in cache
										2'b00: cache[A[11:4]][31:0] <= WD;
										2'b01: cache[A[11:4]][63:32] <= WD;
										2'b10: cache[A[11:4]][95:64] <= WD;
										2'b11: cache[A[11:4]][127:96] <= WD;
								end
								if (!cache[A[11:4]][148]) begin
										cache[A[11:4]][147:128] <= A[31:12];  // Write to tag_0
										cache[A[11:4]][148]     <= 1;  // Update valid bit
								end
								cache[A[11:4]][298]   <= 1;  // Update LRU
            end else if (!cache[A[11:4]][297]) begin // empty spot in way 1
                cache[A[11:4]][296:277] <= A[31:12];  // Write to tag_1
                cache[A[11:4]][276:149] <= WM; // Write to data_1
      	  			cache[A[11:4]][297]     <= 1;  // Update valid bit
						end else if (!cache[A[11:4]][148]) begin // empty spot in way 0
                cache[A[11:4]][147:128] <= A[31:12];  // Write to tag_0
                cache[A[11:4]][127:0]   <= WM; // Write to data_0
              	cache[A[11:4]][148]     <= 1;  // Update valid bit
						end else begin // cache conflict on write
								if (cache[A[11:4]][298]) begin     // LRU = 1
                    cache[A[11:4]][296:277] <= A[31:12];  // Write to tag_1
                    cache[A[11:4]][276:149] <= WM; // Write to data_1
              			cache[A[11:4]][297]     <= 1;  // Update valid bit
                end else begin                     // LRU = 0
                    cache[A[11:4]][147:128] <= A[31:12];  // Write to tag_0
                    cache[A[11:4]][127:0]   <= WM; // Write to data_0
              			cache[A[11:4]][148]     <= 1;  // Update valid bit
                end
						end
				end*/
  	end
endmodule
