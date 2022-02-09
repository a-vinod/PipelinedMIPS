
//Stage Fetch

module fetch(
input clk, reset, stallF, pcsrcD,
input [1:0] branchD,
input [31:0] pc,
output [31:0] instrF, pcplus4F
);

reg [31:0] pcF, stall_pcF;
wire [31:0] pcF_;

//flopr pcreg(clk, reset, stallF, pc, pcF);//Set for reset and update pc value
imem imem(pcF[7:2], pcsrcD, branchD, instrF); //Instruction memory
adder pcadd1(pcF, 32'b100, pcplus4F); //PC + 4

	always @ (posedge clk, posedge reset) begin
		if (reset) begin
			pcF <= 32'b0;
		end else if (!stallF) begin
			pcF <= pc;
		end
	end

endmodule


//This 2:1 mux implement all the muxs in the design
module mux2 # (parameter WIDTH = 8) //2:1MUX
(input [WIDTH-1:0] d0, d1,
input s,
output [WIDTH-1:0] y);

    assign y = s ? d1 : d0;

endmodule


// Instruction memory
module imem(input   [5:0]  a,
            input          pcsrcD,
            input   [1:0]  branchD,
            output  [31:0] rd);

  reg [63:0] RAM[63:0];

  initial
    begin
      // Change file name to match program file name
      $readmemh("grader.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
    end

  assign rd = RAM[a]; // word aligned
endmodule


//flopr is the module controling the PC
//If reset signal is 1, the address is reset to 1
//If the reset is 0, we keeps setting pc to pcnext
module flopr //use for reset
(input clk, reset, stallF,
input [31:0] d,
output reg [31:0] q);
reg [31:0] prev_d;
    always @ (posedge clk, posedge reset)
        if (reset) 
            q <= 0;
        else if(!stallF) begin
            q <= d;
            prev_d <= d;
        end else
            q <= prev_d;
endmodule


module adder (input [31:0] a, b,
output [31:0] y);
    assign y = a + b;
endmodule
