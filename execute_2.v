module execute(input             clk, rst,
               // DECODE STAGE
               // Downstream control flags
               input			 MultStartD, MultSgnD, RegWriteD, MemWriteD,
                                 BranchD, ALUSrcD, RegDstD, jumpD,
               input      [1:0]  MemtoRegD, // WBSrc
               input      [2:0]  ALUControlE,
               // Data
               input      [4:0]  RsD, RtD, RdD,
               input      [31:0] rd1D, rd2D, SignImmD, 
                                 UnsignedImmD, PCPlus4D,

               // MEMORY STAGE
               // Downstream control flags
               output reg        jumpE, RegWriteE, MemWriteE,
               output reg [1:0]  MemtoRegE,
               output reg [4:0]  WriteRegE,
               // Fordwarding
               input      [31:0] ALUOutM,
               // Data
               output reg [31:0] ALUMultOut, WriteDataE, PCPlus4E,

               // WRITEBACK STAGE
               // Forwarding
               input      [31:0] ResultW,

               // HAZARD UNIT
               input             FlushE, ForwardAE, ForwardBE, RsE, RtE,
               output reg        MultStartE, RegWriteE, MemtoRegE, MultDoneE
               output reg [4:0]  RsE, RtE
               );

    // Execute Stage Registers
    reg        jumpE_, RegWriteE_, MemtoRegE_, MemWriteE_, RegDstE_, MultStartE, MultSgnE;
    reg [1:0]  ALUSrcE_; 
    reg [2:0]  ALUControlE_;
    reg [4:0]  RsE_, RtE_, RdE_;
    reg [31:0] rd1E_, rd2E_, UnsignedImmE_, SignImmE_, PCPlus4E_; 

    // Downstream pipeline control flags
    assign jumpE = jumpE_;
    assign RegWriteE = RegWriteE_;
    assign MemWriteE = MemWriteE_;
    assign MemtoRegE = MemtoRegE_;

    // Hazard Unit
    wire RdE;
    assign RsE = RsE_;
    assign RtE = RtE_;
    assign RdE = RdE_;

    assign MultStartE = MultStartE_;
    assign RegWriteE  = RegWriteE_;
    assign MemtoRegE  = MemtoRegE_;

    assign WriteRegE  = RegDstE      ? (RdE_) : (RtE_);
    assign WriteDataE = forwardBE[1] ? (ALUOutM) : (forwardBE[0] ? (ResultW) : (rd2E_));

    // SrcA and SrcB selection for ALU/multiplier
    wire [31:0] SrcAE, SrcBE, SrcBE_tmp, ALU_a, ALU_b, ALUOut;
    wire zero;
    assign SrcAE     = forwardAE[1] ? (ALUOutM)       : (forwardAE[0] ? (ResultW)   : (rd1E_));
    assign SrcBE_tmp = forwardBE[1] ? (ALUOutM)       : (forwardBE[0] ? (ResultW)   : (rd2E_));
  	assign SrcBE     = ALUSrcE_[1]  ? (UnsignedImmE_) : (ALUSrcE_[1]  ? (SignImmE_) : (SrcBE_tmp));

    // MUX to select ALU inputs from multiplier or from register
    assign ALU_a     = MultStartE_   ? ALU_a_mult : SrcAE;
    assign ALU_b     = MultStartE_   ? ALU_b_mult : SrcBE;
    wire [31:0] ALU_a_mult, ALU_b_mult, multOutHi, multOutLo;

    // Instantiate and wire together ALU and multiplier
    ALU alu(.a(ALU_a), .b(ALU_b), .f(ALUControlE), .y(ALUOut), .zero(zero));

    multiplier m(.clk(clk),       .rst(rst),          .SrcAE(SrcAE),   
                 .SrcBE(SrcBE),   .MultE(MultStartE), .ALUOut(ALUOut), 
                 .ALU_zero(zero), .ALU_A(ALU_a_mult), .ALU_B(ALU_b_mult), 
                 .hi(multOutHi),  .lo(multOutLo),     .completed(MultDoneE));

  	assign ALUOutE = MemWriteE_[1] ? (MemWriteE_[0] ? multOutHi : multOutLo) : ALUOut;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
        end else begin
            if (FlushE) begin
                jumpE_        <= 1'b0;
                RegWriteE_    <= 1'b0;
                MemtoRegE_    <= 1'b0;
                MemWriteE_    <= 2'b0;
                RegDstE_      <= 1'b0;
                MultStartE_   <= 1'b0;
                MultSgnE_     <= 1'b0;
                ALUSrcE_      <= 1'b0;
                ALUControlE_  <= 3'b0;
                RsE_          <= 5'b0;
                RtE_          <= 5'b0;
                RdE_          <= 5'b0;
                rd1E_         <= 32'b0;
                rd2E_         <= 32'b0;
                UnsignedImmE_ <= 32'b0;
                SignImmE_     <= 32'b0;
                PCPlus4E_     <= 32'b0;
            end else
                jumpE_        <= jumpD;
                RegWriteE_    <= RegWriteD;
                MemtoRegE_    <= MemtoRegD;
                MemWriteE_    <= MemWriteD;
                RegDstE_      <= RegDstD;
                MultStartE_   <= MultStartD;
                MultSgnE_     <= MultSgnD;
                ALUSrcE_      <= ALUSrcD;
                ALUControlE_  <= ALUControlD;
                RsE_          <= RsD;
                RtE_          <= RtD;
                RdE_          <= RdD;
                rd1E_         <= rd1D;
                rd2E_         <= rd2D;
                UnsignedImmE_ <= UnsignedImmD;
                SignImmE_     <= SignImmD;
                PCPlus4E_     <= PCPlus4D;
            begin
        end
    end
    
endmodule
