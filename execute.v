module execute (input 			  clk, rst,
               	input      [1:0]  forwardAE, forwardBE,
                input      [31:0] rd1, rd2, ALUOutM, ResultW,
                input             RegWriteE, MemToRegE, MemWriteE, jumpE,
                input      [2:0]  ALUControlE,
                input			  ALUSrcE, RegDstE,	
                                  RsE, RtE, RdE, SignImmE,
                output reg        RegWriteM, MemToRegM, MemWriteM, jumpM,
                output reg [4:0]  WriteRegE,
                output reg [31:0] WriteDataE, ALUOutE
              );
    // Downstream pipeline control flags
    assign RegWriteM = RegWriteE;
    assign MemToRegM = MemToRegE;
    assign MemWriteM = MemWriteE;
    assign jumpM     = jumpE;

    assign WriteRegE  = RegDstE      ? (RdE) : (RtE);
    assign WriteDataE = forwardBE[1] ? (ALUOutM) : (forwardBE[0] ? (ResultW) : (rd2));

    // ALU Src selection and computation
    wire [31:0] SrcAE, SrcBE, SrcBE_tmp;
    wire zero;
    assign SrcAE     = forwardAE[1] ? (ALUOutM)  : (forwardAE[0] ? (ResultW) : (rd1));
    assign SrcBE_tmp = forwardBE[1] ? (ALUOutM)  : (forwardBE[0] ? (ResultW) : (rd2));
    assign SrcBE     = ALUSrcE      ? (SignImmE) : (SrcBE_tmp);
    ALU alu(.a(SrcAE), .b(SrcBE), .f(ALUControlE), .y(ALUOutE), .zero(zero));

    // Multiplier
        
    
endmodule
