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

  	reg  [31:0] A, B, C;
  	reg  [63:0] product, product_,invertpro;
    wire [31:0] ta,tb;

    assign ta = SrcAE[31] ? (~SrcAE + 1) : SrcAE;
    assign tb = SrcBE[31] ? (~SrcBE + 1) : SrcBE;

  	assign ALU_A = A;
  	assign ALU_B = B;
  	assign C = ALUOut;

  	always @ (posedge clk or posedge rst) begin
        if (rst) begin
            hi        <= 32'b0;
            lo        <= 32'b0;
            product   <= 64'b0;
            counter   <= 0;
          	completed <= 0;
          end else if (MultE && !MultSgn) begin
            if (counter == 0) begin
                counter <= counter + 1;

              	product[31:0] <= SrcAE;
              	A <= SrcAE[0] ? (product[63:32] << 1) : 32'b0;
                B <= SrcAE[0] ? SrcBE    : 32'b0;
            end else if  (counter <= 32) begin
              	counter <= counter + 1;

                // C = A + B is computed using the processor's ALU.
                // There are two cases in which A is non-zero:
                //  1: next bit to be right-shifted to LSB (product[1]) is 1
                //  2: current bit in LSB is 1, but case (1) isn't true
                //
                // Case 1: If the next bit to be right shifted into the LSB
                // is 1, then we must set A and B in this clock cycle so that
                // C is ready by the next clock cycle (product[1] is shifted to LSB).
                // Then we can update the left half of the product register
                // with the result C as the shift-add multiplier algorithm shows.
                //
                // Case 2: If the current LSB is 1, but case (1) doesn't hold,
                // then we must've already set A and B appropriately in the 
                // previous clock cycle and C is ready to use in this clock cycle
                // to update the product register.
                A <= product[1] ? ALUOut >> 1 : (product[0] ? ALUOut >> 1 : 32'b0);
              	B <= product[1] ? SrcBE  : 32'b0;     

                // If the product's LSB is 1, then we need to update the left-half
                // of the product register with the pre-computed sum from C. But if
                // the LSB is 0, then we don't change the register. Regardless, we 
                // shift right by 1.         
                product <= ((product[0]) ? {ALUOut, product[31:0]} : product) >> 1;
            end else if (counter == 33) begin
                completed <= 1;
              	hi <= product[63:32];
              	lo <= product[31:0];
            end
        end else if (MultE && MultSgn) //signed 
            begin
              if (counter == 0) begin
                  counter <= counter + 1;

                  product[31:0] <= ta;
                  A <= ta[0] ? (product[63:32] << 1) : 32'b0;
                  B <= tb[0] ? tb    : 32'b0;
              end else if  (counter <= 32) begin
                  counter <= counter + 1;

                  A <= product[1] ? C >> 1 : (product[0] ? C >> 1 : 32'b0);
                  B <= product[1] ? tb  : 32'b0;     

                  product <= ((product[0]) ? {C, product[31:0]} : product) >> 1;
            
              end 
              else if (counter == 33) begin
                invertpro <= ~(product-1);
                  if((SrcAE[31] & SrcBE[31]) || (~SrcAE[31] & ~SrcBE[31])) //positive
                    begin
                      completed <= 1;
                      hi <= product[63:32];
                      lo <= product[31:0];
                    end
                  else //negative
                    begin
                      completed <= 1;
                      hi <= invertpro[63:32];
                      lo <= invertpro[31:0];
                    end
              end
            end
    end
endmodule
