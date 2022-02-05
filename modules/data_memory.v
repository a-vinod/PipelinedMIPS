module data_memory(input              clk, rst, WE,
									 input      [3:0] MemtoRegM,
                   input      [31:0]  A, WD,
                   output reg		  READY,
                   output reg [127:0] RD);
    reg [31:0] dm[2047:0];
    reg [5:0] delay;

    // DEBUG WIRES
    wire [31:0] dm_a;
    assign dm_a = dm[A];

    
		always @ (posedge clk) begin
				if (WE) begin
        		READY <= 0;
            dm[A >> 2] <= WD;
        end 
		end

		integer i;
    always @ (negedge clk, posedge rst) begin
        if (rst) begin
          	delay = 6'b0;
          	READY <= 0;
						for (i = 0; i < 512; i = i + 1)
								dm[i] = 32'b0;
        end else begin
          	if (MemtoRegM[1:0] == 2'b11) begin
                // 20 cycle delay
                if (delay < 19) begin
                    delay <= delay + 1;
                    READY <= 0;
                end else begin
                    // output 4 words corresponding to address tag
                    delay <= 0;
										RD    <= {dm[{A[31:4], 2'b11}], dm[{A[31:4], 2'b10}], dm[{A[31:4], 2'b01}], dm[{A[31:4], 2'b00}]};
                    READY <= 1;
                end
            end
        end
    end
endmodule
