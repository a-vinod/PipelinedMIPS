
module i_cache(input		 	  clk, rst,
               input      [31:0] A,
            	 input          pcsrcD, jumpD,
            	 input   [1:0]  branchD,
               input	    [511:0] WM, // 4 words per block read from cache
               input 	 		  READY,
               output			  cache_hit,
               output   [31:0]  RD);
		reg [1064:0] cache[0:127];
  	// Useful Indices:
  	// cache[][511:0]       : data_0
    // 	 cache[][31:0] 	    : word_0
    // 	 cache[][63:32] 	: word_1
    // 	 cache[][95:64] 	: word_2
    // 	 cache[][127:96] 	: word_3
    // 	 cache[][159:128] 	: word_4
    // 	 cache[][191:160] 	: word_5
    // 	 cache[][223:192] 	: word_6
    // 	 cache[][255:224] 	: word_7
    // 	 cache[][287:256] 	: word_8
    // 	 cache[][319:288] 	: word_9
    // 	 cache[][351:320] 	: word_10
    // 	 cache[][383:352] 	: word_11
    // 	 cache[][415:384] 	: word_12
    // 	 cache[][447:416] 	: word_13
    // 	 cache[][479:448] 	: word_14
    // 	 cache[][511:480] 	: word_15
  	// cache[][530:512]     : tag_0
  	// cache[][531]         : v_0
  	// cache[][1043:532]    : data_1
    // 	 cache[][563:532]	: word_0
    // 	 cache[][595:564]	: word_1
    // 	 cache[][627:596]	: word_2
    // 	 cache[][659:628]	: word_3
    // 	 cache[][691:660]	: word_4
    // 	 cache[][723:692]	: word_5
    // 	 cache[][755:724]	: word_6
    // 	 cache[][787:756]	: word_7
    // 	 cache[][819:788]	: word_8
    // 	 cache[][851:820]	: word_9
    // 	 cache[][883:852]	: word_10
    // 	 cache[][915:884]	: word_11
    // 	 cache[][947:916]	: word_12
    // 	 cache[][979:948]	: word_13
    // 	 cache[][1011:980]	: word_14
    // 	 cache[][1043:1012]	: word_15
  	// cache[][1062:1044]   : tag_1
  	// cache[][1063]        : v_1
  	// cache[][1064]        : LRU
  	//
    // A[31:13] : tag
    // A[12:6]  : set
    // A[6:2]   : block offset
    // A[1:0]	: byte offset
  
    wire         hit_0, hit_1, hit;
  	wire  [1064:0] cache_row;
	  assign cache_row = cache[A[12:6]];
  	
  	// DEBUG WIRES
	  wire [19:0] tag1, tag0, a;
	  wire [5:0] s;
  	wire [511:0] data1, data0;
  	wire lru, v0, v1;
  	assign data1 = cache[A[12:6]][1043:532];
  	assign data0 = cache[A[12:6]][511:0];
  	assign tag1 = cache[A[12:6]][1062:1044];
  	assign tag0 = cache[A[12:6]][530:512];
  	assign v1 = cache[A[12:6]][1063];
  	assign v0 = cache[A[12:6]][531];
  	assign lru = cache[A[12:6]][1064];
  	assign a = A[31:13];
	  assign s = A[12:6];

    assign hit_0 = (cache_row[530:512] == A[31:13]) && cache_row[531];
    assign hit_1 = (cache_row[1062:1044] == A[31:13]) && cache_row[1063];
	  assign hit   = hit_0 | hit_1;
	  assign cache_hit = hit;

    wire [31:0] data_0, data_1;

    MUX_4b m1(cache[A[12:6]][31:0], cache[A[12:6]][63:32], cache[A[12:6]][95:64], cache[A[12:6]][127:96], cache[A[12:6]][159:128], cache[A[12:6]][191:160], cache[A[12:6]][223:192], cache[A[12:6]][255:224], cache[A[12:6]][287:256], cache[A[12:6]][319:288], cache[A[12:6]][351:320], cache[A[12:6]][383:352], cache[A[12:6]][415:384], cache[A[12:6]][447:416], cache[A[12:6]][479:448], cache[A[12:6]][511:480], A[5:2], data_0);
    MUX_4b m2(cache[A[12:6]][563:532], cache[A[12:6]][595:564], cache[A[12:6]][627:596], cache[A[12:6]][659:628], cache[A[12:6]][691:660], cache[A[12:6]][723:692], cache[A[12:6]][755:724], cache[A[12:6]][787:756], cache[A[12:6]][819:788], cache[A[12:6]][851:820], cache[A[12:6]][883:852], cache[A[12:6]][915:884], cache[A[12:6]][947:916], cache[A[12:6]][979:948], cache[A[12:6]][1011:980], cache[A[12:6]][1043:1012], A[5:2], data_1);
  	assign RD = hit_1 ? data_1 : data_0;
  	
  	integer i;

  	always @ (negedge clk, posedge rst) begin
        if (rst) begin
          	for (i = 0; i < 128; i = i + 1)
              	cache[i] = 1064'b0;
        end else begin
            // Cache miss: after 20 cycles, data fetched from memory is ready
            //             on the WM line and READY signal is high
            if (!hit && READY) begin // cache miss: read from memory
              	if (cache[A[12:6]][1064]) begin     // LRU = 1
                    cache[A[12:6]][1062:1044] <= A[31:13];  // Write to tag_1
                    cache[A[12:6]][1043:532]  <= WM; // Write to data_1
              		  cache[A[12:6]][1063]      <= 1;  // Update valid bit
					          cache[A[12:6]][1064]      <= 0;  // Update LRU
                end else begin                     // LRU = 0
                    cache[A[12:6]][530:512] <= A[31:13];  // Write to tag_0
                    cache[A[12:6]][511:0]   <= WM; // Write to data_0
              		  cache[A[12:6]][531]     <= 1;  // Update valid bit
					          cache[A[12:6]][1064]    <= 1;  // Update LRU
                end
            end else if (hit) begin	// cache hit
								// Update LRU bit
								cache[A[12:6]][1064] <= hit_1 ? 0 : 1;
						end
        end
  	end
endmodule

