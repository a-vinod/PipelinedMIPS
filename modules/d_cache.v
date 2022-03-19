module d_cache(input		 clk, rst,	WE,
               input [3:0]	 MemtoRegM,
               input [31:0]  A, WD,
               input [511:0] WM, // 4 words per block read from cache
               input 	 	 READY,
               output		 cache_hit,
               output [31:0] RD);
  reg [1066:0] cache[0:63];
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
  // cache[][531:512]     : tag_0
  // cache[][532]         : v_0
  // cache[][1045:533]    : data_1
  // 	 cache[][564:533] 	: word_0
  // 	 cache[][596:565] 	: word_1
  // 	 cache[][628:597] 	: word_2
  // 	 cache[][660:629] 	: word_3
  // 	 cache[][692:661] 	: word_4
  // 	 cache[][724:693] 	: word_5
  // 	 cache[][756:725] 	: word_6
  // 	 cache[][788:757] 	: word_7
  // 	 cache[][820:789] 	: word_8
  // 	 cache[][852:821] 	: word_9
  // 	 cache[][884:853] 	: word_10
  // 	 cache[][916:885] 	: word_11
  // 	 cache[][948:917] 	: word_12
  // 	 cache[][980:949] 	: word_13
  // 	 cache[][1012:981] 	: word_14
  // 	 cache[][1044:1013] : word_15
  // cache[][1064:1045]   : tag_1
  // cache[][1065]        : v_1
  // cache[][1066]        : LRU
  //
  // A[31:12] : tag
  // A[11:6]  : set
  // A[6:2]   : block offset
  // A[1:0]	: byte offset

  wire         hit_0, hit_1, hit;
  wire  [1066:0] cache_row;
  assign cache_row = cache[A[11:6]];

  // DEBUG WIRES
  wire [19:0] tag1, tag0, a;
  wire [5:0] s;
  wire [511:0] data1, data0;
  wire lru, v0, v1;
  assign data1 = cache[A[11:6]][1044:533];
  assign data0 = cache[A[11:6]][511:0];
  assign tag1 = cache[A[11:6]][1064:1045];
  assign tag0 = cache[A[11:6]][531:512];
  assign v1 = cache[A[11:6]][1065];
  assign v0 = cache[A[11:6]][532];
  assign lru = cache[A[11:6]][1066];
  assign a = A[31:12];
  assign s = A[11:6];

  assign hit_0 = (cache_row[531:512] == A[31:12]) && cache_row[532];
  assign hit_1 = (cache_row[1064:1045] == A[31:12]) && cache_row[1065];
  assign hit   = hit_0 | hit_1;
  assign cache_hit = hit;

  wire [31:0] data_0, data_1;

  MUX_4b m1(cache[A[11:6]][31:0], cache[A[11:6]][63:32], cache[A[11:6]][95:64], cache[A[11:6]][127:96], cache[A[11:6]][159:128], cache[A[11:6]][191:160], cache[A[11:6]][223:192], cache[A[11:6]][255:224], cache[A[11:6]][287:256], cache[A[11:6]][319:288], cache[A[11:6]][351:320], cache[A[11:6]][383:352], cache[A[11:6]][415:384], cache[A[11:6]][447:416], cache[A[11:6]][479:448], cache[A[11:6]][511:480], A[5:2], data_0);
  MUX_4b m2(cache[A[11:6]][564:533], cache[A[11:6]][596:565], cache[A[11:6]][628:597], cache[A[11:6]][660:629], cache[A[11:6]][692:661], cache[A[11:6]][724:693], cache[A[11:6]][756:725], cache[A[11:6]][788:757], cache[A[11:6]][820:789], cache[A[11:6]][852:821], cache[A[11:6]][884:853], cache[A[11:6]][916:885], cache[A[11:6]][948:917], cache[A[11:6]][980:949], cache[A[11:6]][1012:981], cache[A[11:6]][1044:1013], A[5:2], data_1);
  assign RD = hit_1 ? data_1 : data_0;

  integer i;

  always @ (negedge clk, posedge rst) begin
    if (rst) begin
      for (i = 0; i < 64; i = i + 1)
        cache[i] = 1067'b0;
    end else if (MemtoRegM[1:0] == 2'b11 || WE) begin // Read/write
      // Cache miss: after 20 cycles, data fetched from memory is ready
      //             on the WM line and READY signal is high
      if (!hit && READY) begin // cache miss: read from memory
        if (cache[A[11:6]][1066]) begin     // LRU = 1
          cache[A[11:6]][1064:1045] <= A[31:12];  // Write to tag_1
          cache[A[11:6]][1044:533]  <= WM; // Write to data_1
          cache[A[11:6]][1065]      <= 1;  // Update valid bit
          cache[A[11:6]][1066]      <= 0;  // Update LRU
        end else begin                     // LRU = 0
          cache[A[11:6]][531:512] <= A[31:12];  // Write to tag_0
          cache[A[11:6]][511:0]   <= WM; // Write to data_0
          cache[A[11:6]][532]     <= 1;  // Update valid bit
          cache[A[11:6]][1066]    <= 1;  // Update LRU
        end
      end else if (hit) begin	// cache hit
        // Update LRU bit
        cache[A[11:6]][1066] <= hit_1 ? 0 : 1;
        if (WE) begin //Update word in cache
          if (hit_1) begin
            case (A[5:2])
              4'b0000: cache[A[11:6]][564:533]    <= WD;
              4'b0001: cache[A[11:6]][596:565]    <= WD;
              4'b0010: cache[A[11:6]][628:597]    <= WD;
              4'b0011: cache[A[11:6]][660:629]    <= WD;
              4'b0100: cache[A[11:6]][692:661]    <= WD;
              4'b0101: cache[A[11:6]][724:693]    <= WD;
              4'b0110: cache[A[11:6]][756:725]    <= WD;
              4'b0111: cache[A[11:6]][788:757]    <= WD;
              4'b1000: cache[A[11:6]][820:789]    <= WD;
              4'b1001: cache[A[11:6]][852:821]    <= WD;
              4'b1010: cache[A[11:6]][884:853]    <= WD;
              4'b1011: cache[A[11:6]][916:885]    <= WD;
              4'b1100: cache[A[11:6]][948:917]    <= WD;
              4'b1101: cache[A[11:6]][980:949]    <= WD;
              4'b1110: cache[A[11:6]][1012:981]   <= WD;
              4'b1111: cache[A[11:6]][1044:1013]  <= WD;
            endcase
          end else if (hit_0) begin
            case (A[5:2])
              4'b0000: cache[A[11:6]][31:0]     <= WD;
              4'b0001: cache[A[11:6]][63:32]    <= WD;
              4'b0010: cache[A[11:6]][95:64]    <= WD;
              4'b0011: cache[A[11:6]][127:96]   <= WD;
              4'b0100: cache[A[11:6]][159:128]  <= WD;
              4'b0101: cache[A[11:6]][191:160]  <= WD;
              4'b0110: cache[A[11:6]][223:192]  <= WD;
              4'b0111: cache[A[11:6]][255:224]  <= WD;
              4'b1000: cache[A[11:6]][287:256]  <= WD;
              4'b1001: cache[A[11:6]][319:288]  <= WD;
              4'b1010: cache[A[11:6]][351:320]  <= WD;
              4'b1011: cache[A[11:6]][383:352]  <= WD;
              4'b1100: cache[A[11:6]][415:384]  <= WD;
              4'b1101: cache[A[11:6]][447:416]  <= WD;
              4'b1110: cache[A[11:6]][479:448]  <= WD;
              4'b1111: cache[A[11:6]][511:480]  <= WD;
            endcase
          end
        end
      end
    end
  end
endmodule

module MUX_4b(input  [31:0] w0, w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12, w13, w14, w15,
              input  [3:0]  s,
              output [31:0] out);
  reg [31:0] out_;
  assign out = out_;
  always @ (*) begin
    case (s)
      4'b0000: out_ <= w0;
      4'b0001: out_ <= w1;
      4'b0010: out_ <= w2;
      4'b0011: out_ <= w3;
      4'b0100: out_ <= w4;
      4'b0101: out_ <= w5;
      4'b0110: out_ <= w6;
      4'b0111: out_ <= w7;
      4'b1000: out_ <= w8;
      4'b1001: out_ <= w9;
      4'b1010: out_ <= w10;
      4'b1011: out_ <= w11;
      4'b1100: out_ <= w12;
      4'b1101: out_ <= w13;
      4'b1110: out_ <= w14;
      4'b1111: out_ <= w15;
    endcase
  end
endmodule
