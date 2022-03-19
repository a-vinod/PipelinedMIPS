// Shift and add multiplier as shown in P&H
module multiplier (input             clk, rst,
                   input      [31:0] SrcAE, SrcBE,
                   input             MultE, MultSgn,
                   input	  [31:0] ALUOut,
                   input 	  		 ALU_zero,
                   output reg [31:0] ALU_A, ALU_B,
                   output reg [31:0] hi, lo,
                   output reg        completed);
  reg  [5:0]  counter;

  wire [63:0] invertpro;
  reg  [63:0] product;
  assign invertpro = ~(product-1);
  wire [31:0] ta,tb;
  reg  [31:0] srca, srcb;
  reg         multsgn;

  // Twos complement to convert negative to positive values
  assign ta = SrcAE[31] ? (~SrcAE + 1) : SrcAE;
  assign tb = SrcBE[31] ? (~SrcBE + 1) : SrcBE;

  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      hi        <= 32'b0;
      lo        <= 32'b0;
      product   <= 64'b0;
      counter   <= 0;
      completed <= 0;
    end else if (MultE && !MultSgn) begin // Start unsigned multiply
      completed <= 0;
      multsgn <= 0;
      counter <= counter + 1;

      product <= {SrcAE[0] ? (SrcBE) : (32'b0), SrcAE} >> 1;
      ALU_A   <= (SrcAE[0] ? (SrcBE >> 1) : (32'b0));
      ALU_B   <= SrcBE;
    end else if (MultE && MultSgn) begin // Start signed multiply
      completed <= 0;
      multsgn <= 1;
      counter <= counter + 1;

      srca <= SrcAE;
      srcb <= SrcBE;
      product <= {ta[0] ? (tb) : (32'b0), ta} >> 1;
      ALU_A   <= (ta[0] ? (tb >> 1) : (32'b0));
      ALU_B   <= tb;
    end else begin // during multiplication
      if (counter > 0 && counter <= 30) begin
        counter <= counter + 1;

        product <= {product[0] ? (ALUOut) : (product[63:32]) , product[31:0]} >> 1;
        ALU_A   <= (product[0] ? (ALUOut) : (product[63:32])) >> 1;
      end else if (counter == 31) begin
        counter <= counter + 1;

        product <= {product[0] ? (ALUOut) : product[63:32] , product[31:0]} >> 1;
      end else if (counter == 32) begin
        counter <= 0;
        if (multsgn) begin
          if((srca[31] & srcb[31]) || (~srca[31] & ~srcb[31])) begin //positive
            completed <= 1;
            hi <= product[63:32];
            lo <= product[31:0];
          end else begin //negative
            completed <= 1;
            hi <= invertpro[63:32];
            lo <= invertpro[31:0];
          end
        end else begin
          completed <= 1;
          hi <= product[63:32];
          lo <= product[31:0];
        end
      end
    end
  end
endmodule

