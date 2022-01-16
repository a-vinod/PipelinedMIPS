module data_memory(input             clk, WE,
                   input      [31:0] A, WD,
                   output reg [31:0] RD);
  reg [31:0] dm[63:0];
  // Initialize external memory to zero
  always @ (posedge clk) begin
    case (WE)
      0: RD    <= dm[A];
      1: dm[A] <= WD;
    endcase
  end
endmodule
