`timescale 1 ns/10 ps  // time-unit = 1 ns, precision = 10 ps

module execute_tb;
    reg 			clk, rst;
    reg      [1:0]  forwardAE, forwardBE;
    reg      [31:0] rd1, rd2, ALUOutM, ResultW;
    reg             RegWriteE, MemToRegE, jumpE;
    reg      [1:0]  MemWriteE, ALUSrcE;
    reg      [2:0]  ALUControlE;
  	reg      [15:0] SignImmE, UnsignedImmE;
    reg			    RegDstE, RsE, RtE, RdE, MultStartE, MultSgnE;
    wire            RegWriteM, MemToRegM, jumpM, MultComplete;
    wire     [1:0]  MemWriteM;
    wire     [4:0]  WriteRegE;
    wire     [31:0] WriteDataE, ALUOutE;

    execute dut(clk, rst,forwardAE, forwardBE,rd1, rd2, ALUOutM, ResultW,RegWriteE, MemToRegE, jumpE,MemWriteE,ALUSrcE,ALUControlE, RegDstE,RsE, RtE, RdE,MultStartE, MultSgnE,SignImmE,UnsignedImmE, RegWriteM,MemToRegM,jumpM,MultComplete,MemWriteM,WriteRegE,WriteDataE, ALUOutE);

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(1);
        clk = 0;
        rst = 0;
        forwardAE = 0;
        forwardBE = 0;
        rd1 = 32'b111;
        rd2 = 32'b101;
        RegWriteE = 0;
        MemToRegE = 0;
        jumpE = 0;
        MemWriteE = 2'b10;
        ALUControlE = 3'b010;
        ALUSrcE = 00;
        RegDstE = 0;
        RsE = 32'b111;
        RtE = 32'b101;
        RdE = 32'b000;
        SignImmE = 32'b0;
        MultStartE = 1;
        MultSgnE = 0;

        #5 clk = !clk;
        rst = 0;
        #5 clk = !clk;
        rst = 1;
        #5 clk = !clk;
        rst = 0;
        for (i = 0; i < 70; i = i + 1) begin
            #5 clk = !clk;
        end
    end
endmodule
