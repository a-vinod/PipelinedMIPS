module d_cache(input		 	  clk, rst,	WE1, WE2,
               input      [3:0] MemtoRegM1, MemtoRegM2,
               input      [31:0] A1, A2, WD1, WD2,
               input	    [511:0] WM1, WM2, // 4 words per block read from cache
               input 	 		  READY,
               output			  cache_hit,
               output   [31:0]  RD1, RD2);
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
  // A1[31:12] : tag
  // A1[11:6]  : set
  // A1[6:2]   : block offset
  // A1[1:0]	: byte offset

  wire         hit_0, hit_1, hit;
  wire  [1066:0] cache_row;
  assign cache_row = cache[A1[11:6]];

  // DEBUG WIRES
  wire [19:0] tag1, tag0, a;
  wire [5:0] s;
  wire [511:0] data1, data0;
  wire lru, v0, v1;
  assign data1 = cache[A1[11:6]][1044:533];
  assign data0 = cache[A1[11:6]][511:0];
  assign tag1 = cache[A1[11:6]][1064:1045];
  assign tag0 = cache[A1[11:6]][531:512];
  assign v1 = cache[A1[11:6]][1065];
  assign v0 = cache[A1[11:6]][532];
  assign lru = cache[A1[11:6]][1066];
  assign a = A1[31:12];
  assign s = A1[11:6];

  assign hit1_0 = (cache_row[531:512] == A1[31:12]) && cache_row[532];
  assign hit1_1 = (cache_row[1064:1045] == A1[31:12]) && cache_row[1065];
  assign hit1   = hit1_0 | hit1_1;

  assign hit2_0 = (cache_row[531:512] == A2[31:12]) && cache_row[532];
  assign hit2_1 = (cache_row[1064:1045] == A2[31:12]) && cache_row[1065];
  assign hit2   = hit2_0 | hit2_1;

  assign cache_hit = hit1 && hit2;

  wire [31:0] data1_0, data1_1, data2_0, data2_1;

  MUX_4b m1(cache[A1[11:6]][31:0], cache[A1[11:6]][63:32], cache[A1[11:6]][95:64], cache[A1[11:6]][127:96], cache[A1[11:6]][159:128], cache[A1[11:6]][191:160], cache[A1[11:6]][223:192], cache[A1[11:6]][255:224], cache[A1[11:6]][287:256], cache[A1[11:6]][319:288], cache[A1[11:6]][351:320], cache[A1[11:6]][383:352], cache[A1[11:6]][415:384], cache[A1[11:6]][447:416], cache[A1[11:6]][479:448], cache[A1[11:6]][511:480], A1[5:2], data1_0);
  MUX_4b m2(cache[A1[11:6]][564:533], cache[A1[11:6]][596:565], cache[A1[11:6]][628:597], cache[A1[11:6]][660:629], cache[A1[11:6]][692:661], cache[A1[11:6]][724:693], cache[A1[11:6]][756:725], cache[A1[11:6]][788:757], cache[A1[11:6]][820:789], cache[A1[11:6]][852:821], cache[A1[11:6]][884:853], cache[A1[11:6]][916:885], cache[A1[11:6]][948:917], cache[A1[11:6]][980:949], cache[A1[11:6]][1012:981], cache[A1[11:6]][1044:1013], A1[5:2], data1_1);

  MUX_4b m3(cache[A2[11:6]][31:0], cache[A2[11:6]][63:32], cache[A2[11:6]][95:64], cache[A2[11:6]][127:96], cache[A2[11:6]][159:128], cache[A2[11:6]][191:160], cache[A2[11:6]][223:192], cache[A2[11:6]][255:224], cache[A2[11:6]][287:256], cache[A2[11:6]][319:288], cache[A2[11:6]][351:320], cache[A2[11:6]][383:352], cache[A2[11:6]][415:384], cache[A2[11:6]][447:416], cache[A2[11:6]][479:448], cache[A2[11:6]][511:480], A2[5:2], data2_0);
  MUX_4b m4(cache[A2[11:6]][564:533], cache[A2[11:6]][596:565], cache[A2[11:6]][628:597], cache[A2[11:6]][660:629], cache[A2[11:6]][692:661], cache[A2[11:6]][724:693], cache[A2[11:6]][756:725], cache[A2[11:6]][788:757], cache[A2[11:6]][820:789], cache[A2[11:6]][852:821], cache[A2[11:6]][884:853], cache[A2[11:6]][916:885], cache[A2[11:6]][948:917], cache[A2[11:6]][980:949], cache[A2[11:6]][1012:981], cache[A2[11:6]][1044:1013], A2[5:2], data2_1);

  assign RD1 = hit1_1 ? data1_1 : data1_0;
  assign RD2 = hit2_1 ? data2_1 : data2_0;

  integer i;

  always @ (negedge clk, posedge rst) begin
    if (rst) begin
      for (i = 0; i < 64; i = i + 1)
        cache[i] = 1067'b0;
    end else if (MemtoRegM1[1:0] == 2'b11 || MemtoRegM2[1:0] == 2'b11 || WE1 || WE2) begin // Read/write
      // Cache miss: after 20 cycles, data fetched from memory is ready
      //             on the WM line and READY signal is high
      if (!hit1 && READY) begin // cache miss: read from memory
        if (cache[A1[11:6]][1066]) begin     // LRU = 1
          cache[A1[11:6]][1064:1045] <= A1[31:12];  // Write to tag_1
          cache[A1[11:6]][1044:533]  <= WM1; // Write to data_1
          cache[A1[11:6]][1065]      <= 1;  // Update valid bit
          cache[A1[11:6]][1066]      <= 0;  // Update LRU
        end else begin                     // LRU = 0
          cache[A1[11:6]][531:512] <= A1[31:12];  // Write to tag_0
          cache[A1[11:6]][511:0]   <= WM1; // Write to data_0
          cache[A1[11:6]][532]     <= 1;  // Update valid bit
          cache[A1[11:6]][1066]    <= 1;  // Update LRU
        end
      end else if (!hit2 && READY) begin
        if (cache[A2[11:6]][1066]) begin     // LRU = 1
          cache[A2[11:6]][1064:1045] <= A2[31:12];  // Write to tag_1
          cache[A2[11:6]][1044:533]  <= WM2; // Write to data_1
          cache[A2[11:6]][1065]      <= 1;  // Update valid bit
          cache[A2[11:6]][1066]      <= 0;  // Update LRU
        end else begin                     // LRU = 0
          cache[A2[11:6]][531:512] <= A2[31:12];  // Write to tag_0
          cache[A2[11:6]][511:0]   <= WM2; // Write to data_0
          cache[A2[11:6]][532]     <= 1;  // Update valid bit
          cache[A2[11:6]][1066]    <= 1;  // Update LRU
        end
      end else if (hit) begin	// cache hit
        // Update LRU bit
        cache[A1[11:6]][1066] <= hit1_1 ? 0 : 1;
        cache[A2[11:6]][1066] <= hit2_1 ? 0 : 1;

        if (WE1) begin //Update word in cache
          if (hit1_1) begin
            case (A1[5:2])
              4'b0000: cache[A1[11:6]][564:533]    <= WD1;
              4'b0001: cache[A1[11:6]][596:565]    <= WD1;
              4'b0010: cache[A1[11:6]][628:597]    <= WD1;
              4'b0011: cache[A1[11:6]][660:629]    <= WD1;
              4'b0100: cache[A1[11:6]][692:661]    <= WD1;
              4'b0101: cache[A1[11:6]][724:693]    <= WD1;
              4'b0110: cache[A1[11:6]][756:725]    <= WD1;
              4'b0111: cache[A1[11:6]][788:757]    <= WD1;
              4'b1000: cache[A1[11:6]][820:789]    <= WD1;
              4'b1001: cache[A1[11:6]][852:821]    <= WD1;
              4'b1010: cache[A1[11:6]][884:853]    <= WD1;
              4'b1011: cache[A1[11:6]][916:885]    <= WD1;
              4'b1100: cache[A1[11:6]][948:917]    <= WD1;
              4'b1101: cache[A1[11:6]][980:949]    <= WD1;
              4'b1110: cache[A1[11:6]][1012:981]   <= WD1;
              4'b1111: cache[A1[11:6]][1044:1013]  <= WD1;
            endcase
          end else if (hit1_0) begin
            case (A1[5:2])
              4'b0000: cache[A1[11:6]][31:0]     <= WD1;
              4'b0001: cache[A1[11:6]][63:32]    <= WD1;
              4'b0010: cache[A1[11:6]][95:64]    <= WD1;
              4'b0011: cache[A1[11:6]][127:96]   <= WD1;
              4'b0100: cache[A1[11:6]][159:128]  <= WD1;
              4'b0101: cache[A1[11:6]][191:160]  <= WD1;
              4'b0110: cache[A1[11:6]][223:192]  <= WD1;
              4'b0111: cache[A1[11:6]][255:224]  <= WD1;
              4'b1000: cache[A1[11:6]][287:256]  <= WD1;
              4'b1001: cache[A1[11:6]][319:288]  <= WD1;
              4'b1010: cache[A1[11:6]][351:320]  <= WD1;
              4'b1011: cache[A1[11:6]][383:352]  <= WD1;
              4'b1100: cache[A1[11:6]][415:384]  <= WD1;
              4'b1101: cache[A1[11:6]][447:416]  <= WD1;
              4'b1110: cache[A1[11:6]][479:448]  <= WD1;
              4'b1111: cache[A1[11:6]][511:480]  <= WD1;
            endcase
          end
        end else if (WE2) begin //Update word in cache
          if (hit2_1) begin
            case (A2[5:2])
              4'b0000: cache[A2[11:6]][564:533]    <= WD2;
              4'b0001: cache[A2[11:6]][596:565]    <= WD2;
              4'b0010: cache[A2[11:6]][628:597]    <= WD2;
              4'b0011: cache[A2[11:6]][660:629]    <= WD2;
              4'b0100: cache[A2[11:6]][692:661]    <= WD2;
              4'b0101: cache[A2[11:6]][724:693]    <= WD2;
              4'b0110: cache[A2[11:6]][756:725]    <= WD2;
              4'b0111: cache[A2[11:6]][788:757]    <= WD2;
              4'b1000: cache[A2[11:6]][820:789]    <= WD2;
              4'b1001: cache[A2[11:6]][852:821]    <= WD2;
              4'b1010: cache[A2[11:6]][884:853]    <= WD2;
              4'b1011: cache[A2[11:6]][916:885]    <= WD2;
              4'b1100: cache[A2[11:6]][948:917]    <= WD2;
              4'b1101: cache[A2[11:6]][980:949]    <= WD2;
              4'b1110: cache[A2[11:6]][1012:981]   <= WD2;
              4'b1111: cache[A2[11:6]][1044:1013]  <= WD2;
            endcase
          end else if (hit2_0) begin
            case (A2[5:2])
              4'b0000: cache[A2[11:6]][31:0]     <= WD2;
              4'b0001: cache[A2[11:6]][63:32]    <= WD2;
              4'b0010: cache[A2[11:6]][95:64]    <= WD2;
              4'b0011: cache[A2[11:6]][127:96]   <= WD2;
              4'b0100: cache[A2[11:6]][159:128]  <= WD2;
              4'b0101: cache[A2[11:6]][191:160]  <= WD2;
              4'b0110: cache[A2[11:6]][223:192]  <= WD2;
              4'b0111: cache[A2[11:6]][255:224]  <= WD2;
              4'b1000: cache[A2[11:6]][287:256]  <= WD2;
              4'b1001: cache[A2[11:6]][319:288]  <= WD2;
              4'b1010: cache[A2[11:6]][351:320]  <= WD2;
              4'b1011: cache[A2[11:6]][383:352]  <= WD2;
              4'b1100: cache[A2[11:6]][415:384]  <= WD2;
              4'b1101: cache[A2[11:6]][447:416]  <= WD2;
              4'b1110: cache[A2[11:6]][479:448]  <= WD2;
              4'b1111: cache[A2[11:6]][511:480]  <= WD2;
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
