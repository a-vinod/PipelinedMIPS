module ALU (input [31:0] a, b, input [2:0] f, output reg [31:0] y, output zero);
  wire [31:0] b_signed;
  wire [31:0] S;
  wire        cout;

  // fn   : f
  // ----------
  // and  : 000
  // or   : 001
  // add  : 010
  // xor  : 011
  // xnor : 100
  // sub  : 101
  // slt  : 110
  // <<16 : 111
  assign b_signed = (f[2]) ? ~b : b;
  assign {cout, S} = f[2] + a + b_signed ;
  always @ * begin
    case (f) 
      3'b000 : y <= a & b;
      3'b001 : y <= a | b;
      3'b010 : y <= S;
      3'b011 : y <= a ^ b;
      3'b100 : y <= a ^~ b;
      3'b101 : y <= S;
      3'b110 : y <= {31'b0, S[31]};
      3'b111 : y <= b << 16;
    endcase
  end 

  assign zero = (y == 0) ;

endmodule
