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
    // <<   : 111
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
            3'b110 : y <= {31'd0, S[31]};
            3'b111 : y <= a << b;
        endcase
    end 
      
    assign zero = (y == 0) ;
   
endmodule
module data_memory(input             clk, WE,
                   input      [31:0] A, WD,
                   output reg [31:0] RD);
  reg [31:0] dm[63:0];
  // Initialize external memory to zero
  always @ (posedge clk) begin
    case (WE)
      0: RD    <= dm[A];
      1: dm[A] <= WD;
    endcase
  end
endmodule
module datapath(input             clk, rst, 
                                  stallF, 

                input             stallD,
                input             forwardAD, forwardBD,
                output  [1:0]  branchD,
                output  [4:0]  RsD, RtD,
                
                input             flushE,
                input      [1:0]  forwardAE, forwardBE,
                output        RegWriteE, MultStartE, MultDoneE,
                output  [2:0]  WBSrcE,
                output  [4:0]  RsE, RtE, WriteRegE,
                
                output         RegWriteM,
                output  [2:0]  WBSrcM,
                output  [4:0]  WriteRegM,
                
                output         RegWriteW,
                output  [4:0]  WriteRegW);

    wire [31:0] PC, InstrF, PCPlus4F;
    fetch f(clk, rst, stallF, PC, InstrF, PCPlus4F);

    wire [4:0] writeregW;
    wire [31:0] resultW, ALUMultOutM;
    wire RegWriteW_;
    wire [31:0] pcplus4D, pcbranchD;
  	wire [1:0] alusrcD, branchD_;
    wire [2:0] WBSrcD, alucontrolD;
    wire [4:0] rsD, rtD, reD;
    wire [31:0] signimmD, unsignimmD;
    wire multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD;
    wire pcsrcD;
    wire [31:0] rd1d, rd2d;
    wire [27:0] jumpdstD;
    decode d(clk, rst, stallD, InstrF, PCPlus4F, forwardAD, forwardBD, writeregW, resultW, ALUMultOutM, RegWriteW_, pcplus4D, pcbranchD, branchD_, alusrcD, WBSrcD, alucontrolD, rsD, rtD, reD, signimmD, unsignimmD, multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD, pcsrcD, rd1d, rd2d, jumpdstD);

    wire        jumpE, RegWriteE_, MemWriteE;
    wire [2:0]  WBSrcE_;
    wire [4:0]  WriteRegE_;
    wire [31:0] ALUMultOutE, WriteDataE, PCPlus4E;
  	wire [4:0]  RsE_, RtE_, RdE_;
    wire MultStartE_, MultDoneE_;
    execute e(clk, rst,  multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD, branchD_, alusrcD, WBSrcD[2:0], alucontrolD, rsD, rtD, reD, rd1d, rd2d, signimmD, unsignimmD, pcplus4D,  jumpE, RegWriteE_, MemWriteE, WBSrcE_[2:0], WriteRegE_, ALUMultOutM, ALUMultOutE, WriteDataE, PCPlus4E, resultW, flushE, forwardAE, forwardBE, MultStartE_, MultDoneE_, RsE_, RtE_, RdE_);

    wire        jumpM, RegWriteM_;
    wire [2:0]  WBSrcM_;
    wire [4:0]  WriteRegM_;
    wire [31:0] ReadDataM, PCPlus8M;
    memory m(clk, rst, jumpE, RegWriteE_, MemWriteE, WBSrcE_[2:0], WriteRegE_, ALUMultOutE, WriteDataE, PCPlus4E, jumpM, RegWriteM_, WBSrcM_[2:0], WriteRegM_, ALUMultOutM, ReadDataM, PCPlus8M);


    writeback w(clk, rst, jumpM, RegWriteM_, WBSrcM_[2:0], WriteRegM_, ReadDataM, ALUMultOutM, PCPlus8M, pcsrcD, jumpD, jumpdstD, PCPlus4F, pcbranchD, RegWriteW_, writeregW, resultW, PC);

    assign {MultStartE, MultDoneE} = {MultStartE_, MultDoneE_};
    assign branchD    = branchD_;
    assign {RsD, RtD} = {rsD, rtD};
    assign WBSrcE     = WBSrcE_;
    assign RegWriteE  = RegWriteE_;
    assign WriteRegE  = WriteRegE_;
  	assign {RsE, RtE} = {RsE_, RtE_};
    assign WBSrcM     = WBSrcM_;
    assign RegWriteM  = RegWriteM_;
    assign WriteRegM  = WriteRegM_;
    assign RegWriteW  = RegWriteW_;
    assign WriteRegW  = writeregW;

endmodule

//Stage Decode

module decode(
input clk, reset, stallD,
input [31:0] instrF, pcplus4F,
input forwardAD, forwardBD,
input [4:0] writeregW,
input [31:0] resultW, aluoutM,
input regwriteW,
output [31:0] pcplus4D, pcbranchD,
output [1:0] branchD, alusrcD,
output [2:0] wbsrcD, alucontrolD,
output [4:0] rsD, rtD, reD,
output [31:0] signimmD, unsignimmD,
output multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD,
output pcsrcD,
output [31:0] rd1d, rd2d,
output [27:0] jumpdstD
);

wire [31:0] instrD;
wire [1:0] clear; //0 for branch, 1 for jal
assign clear[1] = jumpD;
assign clear[0] = branchD[0] | branchD[1];
fdgate fdg(clk, reset, stallD, clear, instrF, pcplus4F, instrD, pcplus4D);//the gate 

controller c(instrD[31:26], instrD[5:0],
               multstartD, multsgnD,
               branchD, wbsrcD, memwriteD,
               alusrcD, regdstD, regwriteD, jumpD,
               alucontrolD);

//Register File
wire [31:0] rd1, rd2;
regfile rf(clk, regwriteW, reset, instrD[25:21], instrD[20:16], writeregW, resultW, rd1, rd2);

//rsD, rtD, reD
assign rsD = instrD[25:21];
assign rtD = instrD[20:16];
assign reD = instrD[15:11];

//extension
signext se(instrD[15:0], signimmD);
unsignext tuse(instrD[15:0], unsignimmD);

//brench
wire [31:0] shiftedsignimm;
sl2 immsh(signimmD, shiftedsignimm);
adderD pcaddD(pcplus4D, shiftedsignimm, pcbranchD);//PC p addressing

//brench early decision
mux2 #(32) mux1D(rd1, aluoutM, forwardAD, rd1d);
mux2 #(32) mux2D(rd2, aluoutM, forwardBD, rd2d);
branchComparison bc(rd1d,rd2d,branchD,pcsrcD);//branch comparasion

//j type address
assign jumpdstD =  instrD[25:0] << 2;

endmodule

module fdgate(  //pipeline gate between F and D
input clk, rst, stallD,
input [1:0] clear,
input [31:0] instrF, pcplus4F,
output reg [31:0] instrD, pcplus4D
);

reg [31:0] stall_instr, stall_pcplus4D;

always @ (posedge clk, posedge rst, posedge clear)
    begin
        if(clear!=2'b00 || rst)
            begin
              instrD <= 0;
              pcplus4D <= 0;
            end 
        else if(!stallD)
            begin
              instrD <= instrF;
              pcplus4D <= pcplus4F;
              stall_instr <= instrF;
              stall_pcplus4D <= pcplus4F;
            end
        else if (stallD)
            begin
              instrD <= stall_instr;
              pcplus4D <= stall_pcplus4D;
            end
    end

endmodule


module controller(input   [5:0] opD, functD,
                  output        multstartD, multsgnD,
                  output  [1:0] branchD,
                  output  [2:0] wbsrcD,  //Chooses source of the Register File writeback (e.g. data memory, ALU, PC, product registers).
                  output        memwriteD,
                  output  [1:0] alusrcD, //00 for R-type, 01 for I-type, 10 for unsigned ext
                  output        regdstD, regwriteD,
                  output        jumpD,
                  output  [2:0] alucontrolD);

reg [15:0] controls;

assign {regwriteD, wbsrcD, memwriteD, alucontrolD, alusrcD, regdstD, branchD, jumpD, multstartD, multsgnD} = controls;
always@(*)
//add, addi, sub, and, or, xor, xnor, andi, ori, xori, slt, slti, lw, sw, lui, jal, bne, beq, mult, multu, mflo, mfhi.
begin
    if(opD==6'b000000) //R-type
        begin
            case(functD)
                6'b000000: controls <= 16'b0000000000000000; //nop
                6'b100000: controls <= 16'b1010001000100000; //add
                6'b100010: controls <= 16'b1010010100100000; //subtract
                6'b100100: controls <= 16'b1010000000100000; //and
                6'b100101: controls <= 16'b1010000100100000; //or
                6'b100110: controls <= 16'b1010001100100000; //xor
                6'b100111: controls <= 16'b1010010000100000; //xnor
                6'b101010: controls <= 16'b1010011000100000; //slt
                6'b011000: controls <= 16'b0010000000000011; //mult
                6'b011001: controls <= 16'b0010000000000010; //multu
                6'b010010: controls <= 16'b1100000000100000; //mflo
                6'b010000: controls <= 16'b1110000000100000; //mfhi
            endcase
        end
    else
        begin
            case(opD) 
                6'b001000: controls <= 16'b1010001001000000; //addi
                6'b001100: controls <= 16'b1010000010000000; //andi
                6'b001101: controls <= 16'b1010000110000000; //ori
                6'b001110: controls <= 16'b1010001110000000; //xori
                6'b001010: controls <= 16'b1010011001000000; //slti
                6'b100011: controls <= 16'b1011001001000000; //lw
                6'b101011: controls <= 16'b0010101001000000; //sw
                6'b001111: controls <= 16'b1010011101000000; //lui
                6'b000011: controls <= 16'b1000000000000100; //jal
                6'b000101: controls <= 16'b0010011000010000; //bne
                6'b000100: controls <= 16'b0010011000001000; //beq
                default: controls <= 16'bxxxxxxxxxxxxxxxx; //default
            endcase
        end    
end
endmodule

//This is the regfile that keeps track of the registers
//a1 is the  read port
//a2 is the bits of the instruction 
//a3 is the destination register
//rd1 and rd2 are the two outputs
module regfile (input clk,
input we3, rst,
input [4:0] a1, a2, wa3,
input [31:0] wd3,
output [31:0] rd1, rd2);

    reg [31:0] rf[31:0];
    always @ (negedge clk)
        if (we3==1) 
            rf[wa3] <= wd3;
    
    assign rd1 = (a1 != 0) ? rf[a1] : 0;
    assign rd2 = (a2 != 0) ? rf[a2] : 0;
endmodule

//this module extend the 16bits input to 32 bits
// which is used in lw instruction.
module signext (input [15:0] a, //signExtension
output [31:0] y);
    assign y = {{16{a[15]}}, a};
endmodule

//unsign for ori
module unsignext (input [15:0] a, //signExtension
output [31:0] y);
    wire e;
    assign e = 0;
    assign y = {{16{e}}, a};
endmodule

module adderD (input [31:0] a, b,
output [31:0] y);
    assign y = a + b;
endmodule

//This module shift input signal two bits to the left
// which is how we implement PC′ = PC + 4 + SignImm × 4 in beq
module sl2 (input [31:0] a,
output [31:0] y);
// shift left by 2
    assign y = a<<2;
endmodule

module branchComparison (  //branch comparasion
input [31:0] SRCA, SRCB,
input [1:0] OP,
output reg COMP
);

always@(*)
begin
  if(OP == 2'b10 && SRCA != SRCB) //bne
    COMP <= 1;
  else if(OP == 2'b01 &&  SRCA == SRCB)//beq
    COMP <= 1;
  else
    COMP <= 0;
end

endmodule

//This 2:1 mux implement all the muxs in the design
/*
module mux2 # (parameter WIDTH = 8) //2:1MUX
(input [WIDTH-1:0] d0, d1,
input s,
output [WIDTH-1:0] y);
    assign y = s ? d1 : d0;
endmodule*/


module execute(input             clk, rst,
               // DECODE STAGE
               // Downstream control flags
               input			 MultStartD, MultSgnD, RegWriteD, MemWriteD,
                                 RegDstD, jumpD,
               input      [1:0]  BranchD, ALUSrcD, 
               input      [2:0]  MemtoRegD,ALUControlD,// WBSrc
               // Data
               input      [4:0]  RsD, RtD, RdD,
               input      [31:0] rd1D, rd2D, SignImmD, 
                                 UnsignedImmD, PCPlus4D,

               // MEMORY STAGE
               // Downstream control flags
               output         jumpE, RegWriteE, MemWriteE,
               output  [2:0]  MemtoRegE,
               output  [4:0]  WriteRegE,
               // Fordwarding
               input      [31:0] ALUOutM,
               // Data
               output  [31:0] ALUMultOutE, WriteDataE, PCPlus4E,

               // WRITEBACK STAGE
               // Forwarding
               input      [31:0] ResultW,

               // HAZARD UNIT
               input             FlushE,
               input      [1:0]  ForwardAE, ForwardBE,
               output         MultStartE, MultDoneE,
               output       [4:0]  RsE, RtE, RdE);

    // Execute Stage Registers
    reg        jumpE_, RegWriteE_, MemWriteE_, RegDstE_, MultStartE_, MultSgnE_;
  	reg [1:0]  ALUSrcE_; 
    reg [2:0]  ALUControlE_, MemtoRegE_;
    reg [4:0]  RsE_, RtE_, RdE_;
    reg [31:0] rd1E_, rd2E_, UnsignedImmE_, SignImmE_, PCPlus4E_; 

    // Downstream pipeline control flags
    assign jumpE       = jumpE_;
    assign RegWriteE   = RegWriteE_;
    assign MemWriteE   = MemWriteE_;
    assign MemtoRegE   = MemtoRegE_;

    // Hazard Unit
    assign RsE = RsE_;
    assign RtE = RtE_;
    assign RdE = RdE_;
    assign PCPlus4E = PCPlus4E_;

    assign MultStartE = MultStartE_;

    assign WriteRegE  = RegDstE_     ? (RdE) : (RtE);
  	assign WriteDataE = ForwardBE[1] ? (ALUOutM) : (ForwardBE[0] ? (ResultW) : (rd2E_));

    // SrcA and SrcB selection for ALU/multiplier
  wire [31:0] SrcAE, SrcBE, SrcBE_tmp, ALU_a, ALU_b, ALUOut;
  wire [31:0] ALU_a_mult, ALU_b_mult, multOutHi, multOutLo;
    wire zero;
  	assign SrcAE     = ForwardAE[1] ? (ALUOutM)       : (ForwardAE[0] ? (ResultW)   : (rd1E_));
  	assign SrcBE_tmp = ForwardBE[1] ? (ALUOutM)       : (ForwardBE[0] ? (ResultW)   : (rd2E_));
  	assign SrcBE     = ALUSrcE_[1]  ? (UnsignedImmE_) : (ALUSrcE_[0]  ? (SignImmE_) : (SrcBE_tmp));
    // MUX to select ALU inputs from multiplier or from register
    assign ALU_a     = MultStartE_   ? ALU_a_mult : SrcAE;
    assign ALU_b     = MultStartE_   ? ALU_b_mult : SrcBE;
  	

    // Instantiate and wire together ALU and multiplier
  	ALU alu(.a(ALU_a), .b(ALU_b), .f(ALUControlE_), .y(ALUOut), .zero(zero));
    wire MultDoneE_;

    multiplier m(.clk(clk),       .rst(rst),          .SrcAE(SrcAE),   
                 .SrcBE(SrcBE),   .MultE(MultStartE), .MultSgn(MultSgnE_), .ALUOut(ALUOut), 
                 .ALU_zero(zero), .ALU_A(ALU_a_mult), .ALU_B(ALU_b_mult), 
                 .hi(multOutHi),  .lo(multOutLo),     .completed(MultDoneE_));

    assign MultDoneE = MultDoneE_;

  	assign ALUMultOutE = MemtoRegE_[2] ? (MemtoRegE_[1] ? multOutHi : multOutLo) : ALUOut;

    always @ (posedge clk, posedge rst) begin

            if (FlushE==1 || rst) begin
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
            end else begin
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
        	end
        end

    
endmodule

//Stage Fetch

module fetch(
input clk, reset, stallF,
input [31:0] pc,
output [31:0] instrF, pcplus4F
);

wire [31:0] pcF;

flopr pcreg(clk, reset, stallF, pc, pcF);//Set for reset and update pc value
imem imem(pcF[7:2], instrF); //Instruction memory
adder pcadd1(pcF, 32'b100, pcplus4F); //PC + 4

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
            output  [31:0] rd);

  reg [63:0] RAM[63:0];

  initial
    begin
      $readmemh("tb1.dat",RAM); // initialize memory with test program. Change this with memfile2.dat for the modified code
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


//This is the hazard Unit

module hazard(
    input [1:0] branchD,
    input [2:0] wbsrcE, wbsrcM,
    input regwriteE, regwriteM, regwriteW, 
    input multstartE, pve,
    input [4:0] rtD, rsD, rsE, rtE, writeregE, writeregW, writeregM,
    output stallF, stallD, flushE,
    output forwardAD, forwardBD,
    output [1:0] forwardAE, forwardBE
);

    forward fw(rtD, rsD, rsE, rtE, writeregE, writeregW, writeregM,regwriteE, regwriteM, regwriteW,forwardAD, forwardBD,forwardAE, forwardBE);
    stall st(branchD, wbsrcE, wbsrcM,regwriteE, regwriteM, regwriteW,rtD, rsD, rsE, rtE, writeregE, writeregW, writeregM,multstartE, pve, stallF, stallD, flushE);

endmodule

module forward(
    input [4:0] rtD, rsD, rsE, rtE, writeregE, writeregW, writeregM,
    input regwriteE, regwriteM, regwriteW, 
    output reg forwardAD, forwardBD,
    output reg [1:0] forwardAE, forwardBE
);
always@(*)
begin
    if((rsE != 0) && (regwriteM) && (rsE == writeregM))
        forwardAE <= 2'b10;
    else if((rsE != 0) && (regwriteW) && (rsE == writeregW))
        forwardAE <= 2'b01;
    else
        forwardAE <= 2'b00;

    if((rtE != 0) && (regwriteM) && (rtE == writeregM))
        forwardBE <= 2'b10;
    else if((rtE != 0) && (regwriteW) && (rtE == writeregW))
        forwardBE <= 2'b01;
    else
        forwardBE <= 2'b00;

    if((rsD != 0) && (regwriteM) && (rsD == writeregM))
        forwardAD <= 1;
    else
        forwardAD <= 0;

    if((rtD != 0) && (regwriteM) && (rtD == writeregM))
        forwardBD <= 1;
    else
        forwardBD <= 0;
end
endmodule

module stall(
    input [1:0] branchD,
    input [2:0] wbsrcE, wbsrcM,
    input regwriteE, regwriteM, regwriteW,
    input [4:0] rtD, rsD, rsE, rtE, writeregE, writeregW, writeregM,
    input multstartE, pve,
    output reg stallF, stallD, flushE
);
reg multplier;
initial begin
    multplier = 0;
end
always@(*)
begin
    stallF <= 0;
    stallD <= 0;
    flushE <= 0;

    if(((rsD == rtE) || (rtE == rtD)) && (wbsrcE == 3'b011)) //lw
    begin
        stallF <= 1;
        stallD <= 1;
        flushE <= 1;
    end

    if((branchD!=2'b00) && ((regwriteE && ((rsD == writeregE) || (rtD == writeregE))) || ((wbsrcM == 3'b011) && ((rsD == writeregM) || (rtD == writeregM))))) //branch
    begin
        stallF <= 1;
        stallD <= 1;
        flushE <= 1;
    end

    if((multplier == 0) && (multstartE == 1)) //start multplication
    begin
        stallF <= 1;
        stallD <= 1;
        flushE <= 1;
        multplier <= 1;
    end

    if((multplier == 1) && (pve == 0)) //during multplication
    begin
        stallF <= 1;
        stallD <= 1;
        flushE <= 1;
    end

    if((multplier == 1) && (pve == 1) && (multstartE != 1)) //end multplication
    begin
        multplier <= 1;
    end
    
end
endmodulemodule memory(input             clk, rst,
                                jumpE, RegWriteE, MemWriteE,
              input      [2:0]  MemtoRegE,
              input      [4:0]  WriteRegE,
              input      [31:0] ALUMultOutE, WriteDataE, PCPlus4E,
              output reg        jumpM, RegWriteM,
              output reg [2:0]  MemtoRegM,
              output reg [4:0]  WriteRegM,
              output reg [31:0] ALUMultOutM,
              output reg [31:0] ReadDataM,
              output     [31:0] PCPlus8M);  
  
    reg [31:0]  WriteDataM, PCPlus4M_;
    wire [31:0] ReadDataM_;

    assign PCPlus8M = PCPlus4M_ + 4;

  	data_memory dm(.clk(clk), .WE(MemWriteE), .A(ALUMultOutE), .WD(WriteDataE), .RD(ReadDataM_));
    
    always @ (posedge clk) begin

            jumpM     <= jumpE;
            RegWriteM <= RegWriteE;
            MemtoRegM <= MemtoRegE;

            ALUMultOutM  <= ALUMultOutE;
            WriteRegM    <= WriteRegE;
            PCPlus4M_    <= PCPlus4E;
            ReadDataM    <= ReadDataM_;

    end

endmodule
module mips(input clk, rst);
    wire stallF;

    wire        stallD;
    wire        forwardAD, forwardBD;
    wire [1:0]  branchD;
    wire [4:0]  RsD, RtD;
    
    wire        flushE;
    wire [1:0]  forwardAE, forwardBE;
    wire        RegWriteE, MultStartE, MultDoneE;
    wire [2:0]  WBSrcE;
    wire [4:0]  RsE, RtE, WriteRegE;
    
    wire        RegWriteM;
    wire [2:0]  WBSrcM;
    wire [4:0]  WriteRegM;

    wire        RegWriteW;
    wire [4:0]  WriteRegW;
    datapath dp(clk, rst, stallF, stallD, forwardAD, forwardBD, branchD, RsD, RtD, flushE, forwardAE, forwardBE, RegWriteE, MultStartE, MultDoneE, WBSrcE, RsE, RtE, WriteRegE, RegWriteM, WBSrcM, WriteRegM, RegWriteW, WriteRegW);

    hazard hz(branchD, WBSrcE, WBSrcM, RegWriteE, RegWriteM, RegWriteW, MultStartE, MultDoneE, RtD, RsD, RsE, RtE, WriteRegE, WriteRegW, WriteRegM, stallF, stallD, flushE, forwardAD, forwardBD, forwardAE, forwardBE);
endmodule
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

  	reg  [63:0] product, invertpro;
    wire [31:0] ta,tb;
    reg  multsgn;

    // Twos complement to convert negative to positive values
    assign ta = SrcAE[31] ? (~SrcAE + 1) : SrcAE;
    assign tb = SrcBE[31] ? (~SrcBE + 1) : SrcBE;

  	always @ (posedge clk, posedge rst) begin
        if (rst) begin
            hi        <= 32'b0;
            lo        <= 32'b0;
            product   <= 64'b0;
            counter   <= 0;
          	completed <= 0;
        end else if (MultE && !MultSgn) begin // Start unsigned multiply
            multsgn <= 0;
            counter <= counter + 1;

            product <= {SrcAE[0] ? (SrcBE) : (32'b0), SrcAE} >> 1;
            ALU_A   <= (SrcAE[0] ? (SrcBE >> 1) : (32'b0));
            ALU_B   <= SrcBE;
        end else if (MultE && MultSgn) begin // Start signed multiply
            multsgn <= 1;
            counter <= counter + 1;

            product <= {ta[0] ? (tb) : (32'b0), ta} >> 1;
            ALU_A   <= (ta[0] ? (tb >> 1) : (32'b0));
            ALU_B   <= tb;
        end else begin // during multiplication
            if (counter > 0 && counter <= 30) begin
                counter <= counter + 1;

                product <= {product[0] ? (ALUOut) : (product[63:32]) , product[31:0]} >> 1;
                ALU_A   <= (product[0] ? (ALUOut) : (product[63:32])) >> 1;
            end else if (counter == 31) begin
                counter <= counter + 1;

                product <= {product[0] ? (ALUOut) : product[63:32] , product[31:0]} >> 1;
            end else if (counter == 32) begin
                if (multsgn) begin
                    invertpro <= ~(product-1);
                    if((SrcAE[31] & SrcBE[31]) || (~SrcAE[31] & ~SrcBE[31])) begin //positive
                        completed <= 1;
                        hi <= product[63:32];
                        lo <= product[31:0];
                    end else begin //negative
                        completed <= 1;
                        hi <= invertpro[63:32];
                        lo <= invertpro[31:0];
                    end
                end else begin
                    completed <= 1;
                    hi <= product[63:32];
                    lo <= product[31:0];
                end
            end
        end
    end
endmodule

module writeback(input             clk, rst,
                 input             jumpM, RegWriteM,
                 input      [2:0]  MemtoRegM,
                 input      [4:0]  WriteRegM,
                 input      [31:0] ReadDataM, ALUMultOutM, PCPlus8M,

                 input             PCSrcD, jumpD,
                 input      [27:0] jumpDstD,
                 input      [31:0] PCPlus4F, PCBranchD,
                 
                 output reg        RegWriteW,
                 output reg [4:0]  WriteRegW,
				 output reg [31:0] ResultW,
                 output     [31:0] PC);

    assign PC = jumpD ? ({PCPlus4F[31:28], jumpDstD}) : (PCSrcD ? (PCBranchD) : (PCPlus4F));
    always @ (posedge clk) begin
        ResultW <= MemtoRegM[1] ? (MemtoRegM[0] ? (ReadDataM) : (ALUMultOutM)) : (PCPlus8M); 
        RegWriteW <= RegWriteM;
        WriteRegW <= jumpM     ?  (5'b11111) : (WriteRegM);
    end

endmodule
