`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module fetch_tb;
reg clk, reset, stallF;
reg [31:0] pc;
wire [31:0] instrF, pcplus4F;

    fetch dut(clk, reset, stallF, pc, instrF, pcplus4F);

    integer i;
  // initialize test
  initial
    begin
    pc <= 0;
      reset <= 1; # 12; reset <= 0;
	 stallF <= 0;
     i <= 0;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5;
      clk <= 0; # 5;
      i = i + 1;
      if(i==15)
        stallF <= 1;
      if(i==20)
        stallF <= 0;
    end

always@(negedge clk)
    begin
    pc <= pcplus4F;
    end
endmodule