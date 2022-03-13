module imem(input          clk, rst,
            input   [31:0] a,
            input          pcsrcD1, pcsrcD2,
            input   [1:0]  branchD,
						input 				 hit,
            output reg		 READY,
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
		end else if (!(pcsrcD1 || pcsrcD2)) begin
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