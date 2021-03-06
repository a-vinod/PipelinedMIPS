module data_memory(input              clk, rst, WE,
									 input      [3:0] MemtoRegM,
                   input      [31:0]  A, WD,
                   output reg		  READY,
                   output reg [511:0] RD);
    reg [31:0] dm    [2047:0];
    reg [5:0]  delay;

    // DEBUG WIRES
    wire [31:0] dm_a;
    assign dm_a = dm[A];

	integer i;
    // Write on rising edge (first half of clock cycle)
	always @ (posedge clk, posedge rst) begin
	    if (rst) begin
          	delay = 6'b0;
          	READY <= 0;
        for (i = 0; i < 2048; i = i + 1)
		        dm[i] = 32'b0;
        end else if (WE) begin
        		READY <= 0;
            dm[A >> 2] <= WD;
        end 
	end

		// Read on falling edge (second half of clock cycle)
    always @ (negedge clk) begin
		if (MemtoRegM[1:0] == 2'b11) begin // If reading from memory
            // 20 cycle delay
            if (delay < 19) begin
                delay <= delay + 1;
                READY <= 0;
            end else begin // output 16 words corresponding to address tag
                delay <= 0;
		        RD    <= {dm[{A[31:6], 4'b1111}],
                          dm[{A[31:6], 4'b1110}],
                          dm[{A[31:6], 4'b1101}],
                          dm[{A[31:6], 4'b1100}],
                          dm[{A[31:6], 4'b1011}],
                          dm[{A[31:6], 4'b1010}],
                          dm[{A[31:6], 4'b1001}],
                          dm[{A[31:6], 4'b1000}],
                          dm[{A[31:6], 4'b0111}],
                          dm[{A[31:6], 4'b0110}],
                          dm[{A[31:6], 4'b0101}],
                          dm[{A[31:6], 4'b0100}],
                          dm[{A[31:6], 4'b0011}],
                          dm[{A[31:6], 4'b0010}],
                          dm[{A[31:6], 4'b0001}],
                          dm[{A[31:6], 4'b0000}]};
                READY <= 1;
            end
        end
    end
endmodule
