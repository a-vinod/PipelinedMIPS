module execute (input 			  clk, rst,
               	input      [1:0]  forwardAE, forwardBE,
                input      [31:0] rd1, rd2, ALUOutM, ResultW, PCPlus4E,
                input             RegWriteE, jumpE,
                input      [1:0]  MemWriteE, ALUSrcE,
                input      [2:0]  ALUControlE,
                input			  RegDstE,	
                                  RsE, RtE, RdE,
                                  MultStartE, MultSgnE,
                input      [15:0] SignImmE, UnsignedImmE,
                output reg        RegWriteM, MemToRegM, jumpM,
                                  MultComplete,
                output reg [1:0]  MemWriteM,
                output reg [4:0]  WriteRegE,
                output reg [31:0] WriteDataE, ALUOutE, PCPlus4M
              );
    // Downstream pipeline control flags
    assign RegWriteM = RegWriteE;
    assign MemWriteM = MemWriteE;
    assign PCPlus4M  = PCPlus4E; 
    assign jumpM     = jumpE;

    assign WriteRegE  = RegDstE      ? (RdE) : (RtE);
    assign WriteDataE = forwardBE[1] ? (ALUOutM) : (forwardBE[0] ? (ResultW) : (rd2));

    // SrcA and SrcB selection for ALU/multiplier
    wire [31:0] SrcAE, SrcBE, SrcBE_tmp, ALU_a, ALU_b, ALUOut;
    wire zero;
    assign SrcAE     = forwardAE[1] ? (ALUOutM)      : (forwardAE[0] ? (ResultW)   : (rd1));
    assign SrcBE_tmp = forwardBE[1] ? (ALUOutM)      : (forwardBE[0] ? (ResultW)   : (rd2));
  	assign SrcBE     = ALUSrcE[1]   ? (UnsignedImmE) : (ALUSrcE[1]   ? (SignImmE) : (SrcBE_tmp));

    // MUX to select ALU inputs from multiplier or from register
    assign ALU_a     = MultStartE   ? ALU_a_mult : SrcAE;
    assign ALU_b     = MultStartE   ? ALU_b_mult : SrcBE;
    wire [31:0] ALU_a_mult, ALU_b_mult, multOutHi, multOutLo;

    // Instantiate and wire together ALU and multiplier
    ALU alu(.a(ALU_a), .b(ALU_b), .f(ALUControlE), .y(ALUOut), .zero(zero));

    multiplier m(.clk(clk),       .rst(rst),          .SrcAE(SrcAE),   
                 .SrcBE(SrcBE),   .MultE(MultStartE), .ALUOut(ALUOut), 
                 .ALU_zero(zero), .ALU_A(ALU_a_mult), .ALU_B(ALU_b_mult), 
                 .hi(multOutHi),  .lo(multOutLo),     .completed(MultComplete));

  	assign ALUOutE = MemWriteE[1] ? (MemWriteE[0] ? multOutHi : multOutLo) : ALUOut;
    
endmodule
