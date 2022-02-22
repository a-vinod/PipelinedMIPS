
//Stage Fetch

module fetch(
input clk, reset, stallF, pcsrcD,
input [1:0] branchD,
input jumpD,
input [31:0] pc, pcbranchD,
output [31:0] instrF, pcplus4F, pcF_pred,
output hit, predict_taken);

reg  [31:0] pcF, stall_pcF;
wire [31:0] pcF_;
wire [511:0] instr_memory_RD;
wire         instr_memory_ready;

branch_predict_global bp_global(clk, reset, pcsrcD, stallF, pcF, pcbranchD, pcF_pred, predict_taken);
i_cache icache(clk, reset, pcF, pcsrcD, jumpD, branchD, instr_memory_RD, instr_memory_ready, hit, instrF); //Instruction cache
imem imem(clk, reset, pcF, pcsrcD, jumpD, branchD, hit, instr_memory_ready, instr_memory_RD); //Instruction memory
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
module imem(input          clk, rst,
            input   [31:0] a,
            input          pcsrcD, jumpD,
            input   [1:0]  branchD,
						input 				 hit,
            output reg    READY,
            output reg [511:0] rd);

  reg [31:0] RAM[127:0];

  initial
    begin
      // Change file name to match program file name
      $readmemh("grader.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
    end

  reg [5:0] delay;
  integer i;
  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      delay <= 0;
      READY <= 0;
      for (i = 0; i < 128; i = i + 1)
          RAM[i] = 32'b0;
      $readmemh("grader.dat",RAM);
    end else if (hit) begin
			READY <= 0;
			delay <= 0;
		end else if (!branchD[1] && !branchD[0] && !pcsrcD) begin
      if (delay < 19) begin
        delay <= delay + 1;
        READY <= 0;
      end else begin
				delay <= 0;
        rd <= {RAM[{a[31:6], 4'b1111}], 
              RAM[{a[31:6], 4'b1110}], 
              RAM[{a[31:6], 4'b1101}], 
              RAM[{a[31:6], 4'b1100}], 
              RAM[{a[31:6], 4'b1011}], 
              RAM[{a[31:6], 4'b1010}], 
              RAM[{a[31:6], 4'b1001}], 
              RAM[{a[31:6], 4'b1000}], 
              RAM[{a[31:6], 4'b0111}], 
              RAM[{a[31:6], 4'b0110}], 
              RAM[{a[31:6], 4'b0101}], 
              RAM[{a[31:6], 4'b0100}], 
              RAM[{a[31:6], 4'b0011}], 
              RAM[{a[31:6], 4'b0010}], 
              RAM[{a[31:6], 4'b0001}], 
              RAM[{a[31:6], 4'b0000}]};
        READY <= 1;
      end
    end
  end
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