module data_memory(input              clk, rst, WE,
                   input      [31:0]  A, WD,
                   output reg		  READY,
                   output reg [127:0] RD);
    reg [31:0] dm[63:0];
    reg [5:0] delay;

    // DEBUG WIRES
    wire [31:0] dm_a;
    assign dm_a = dm[A];

    // Initialize external memory to zero
    integer i;
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
          	delay = 6'b0;
          	READY <= 0;
            for (i = 0; i < 64; i = i + 1)
              	dm[i] = 32'b0;
        end else begin
          	if (WE) begin
              	READY <= 0;
                dm[A] <= WD;
            end else begin
                // 20 cycle delay
                if (delay < 19) begin
                    delay <= delay + 1;
                    READY <= 0;
                end else begin
                    // output 4 words corresponding to address 0000000000000000000000000000xx00
                    delay <= 0;
                    RD    <= {dm[{A[31:4], 4'b1100}], dm[{A[31:4], 4'b1000}], dm[{A[31:4], 4'b0100}], dm[{A[31:4], 4'b0000}]};
                    READY <= 1;
                end
            end
        end
    end
endmodule
