//Stage Decode

module decode(input         clk, reset, stallD,
              input  [31:0] instrF, pcplus4F,
              input         forwardAD, forwardBD,
              input  [4:0]  writeregW,
              input  [31:0] resultW, aluoutM,
              input         regwriteW,
              output [31:0] pcplus4D, pcbranchD,
              output [1:0]  branchD, alusrcD,
              output [3:0]  wbsrcD,
              output [2:0]  alucontrolD,
              output [4:0]  rsD, rtD, reD,
              output [31:0] signimmD, unsignimmD,
              output        multstartD, multsgnD, regwriteD, memwriteD, regdstD, jumpD, pcsrcD,
              output [31:0] rd1d, rd2d,
              output [27:0] jumpdstD);

    reg [31:0] instrD, pcplus4D_;
    wire [1:0] clear; //0 for branch, 1 for jal
    assign clear[1] = jumpD;
    assign clear[0] = branchD[0] | branchD[1];
    // fdgate fdg(clk, reset, stallD, clear, instrF, pcplus4F, instrD, pcplus4D);//the gate 

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
    adderD pcaddD(pcplus4D_, shiftedsignimm, pcbranchD);//PC p addressing

    //brench early decision
    mux2 #(32) mux1D(rd1, aluoutM, forwardAD, rd1d);
    mux2 #(32) mux2D(rd2, aluoutM, forwardBD, rd2d);
    branchComparison bc(rd1d,rd2d,branchD,pcsrcD);//branch comparasion

    //j type address
    assign jumpdstD = instrD[25:0] << 2;
    assign pcplus4D = pcplus4D_;
    reg stall_and_flush;
    always @ (posedge clk, posedge reset) begin 
	    if (reset || (pcsrcD && clear!=0 && !stallD)) begin
		    instrD <= 32'b0;
		    pcplus4D_ <= 32'b0;
	    end else if (!stallD) begin
		    instrD <= instrF;
		    pcplus4D_ <= pcplus4F;
	    end
    end

endmodule

/*
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
*/


module controller(input   [5:0] opD, functD,
                  output        multstartD, multsgnD,
                  output  [1:0] branchD,
                  output  [3:0] wbsrcD,  //Chooses source of the Register File writeback (e.g. data memory, ALU, PC, product registers).
                  output        memwriteD,
                  output  [1:0] alusrcD, //00 for R-type, 01 for I-type, 10 for unsigned ext
                  output        regdstD, regwriteD,
                  output        jumpD,
                  output  [2:0] alucontrolD);

reg [16:0] controls;

assign {regwriteD, wbsrcD, memwriteD, alucontrolD, alusrcD, regdstD, branchD, jumpD, multstartD, multsgnD} = controls;
always@(*)
//add, addi, sub, and, or, xor, xnor, andi, ori, xori, slt, slti, lw, sw, lui, jal, bne, beq, mult, multu, mflo, mfhi.
begin
    if(opD==6'b000000) //R-type
        begin
            case(functD)
                6'b000000: controls <= 17'b00000000000000000; //nop
                6'b100000: controls <= 17'b11110001000100000; //add
                6'b100010: controls <= 17'b11110010100100000; //subtract
                6'b100100: controls <= 17'b11110000000100000; //and
                6'b100101: controls <= 17'b11110000100100000; //or
                6'b100110: controls <= 17'b11110001100100000; //xor
                6'b100111: controls <= 17'b11110010000100000; //xnor
                6'b101010: controls <= 17'b11110011000100000; //slt
                6'b011000: controls <= 17'b01110000000000011; //mult
                6'b011001: controls <= 17'b01110000000000010; //multu
                6'b010010: controls <= 17'b11010000000100000; //mflo
                6'b010000: controls <= 17'b10110000000100000; //mfhi
            endcase
        end
    else
        begin
            case(opD) 
                6'b001000: controls <= 17'b11110001001000000; //addi
                6'b001100: controls <= 17'b11110000010000000; //andi
                6'b001101: controls <= 17'b11110000110000000; //ori
                6'b001110: controls <= 17'b11110001110000000; //xori
                6'b001010: controls <= 17'b11110011001000000; //slti
                6'b100011: controls <= 17'b11111001001000000; //lw
                6'b101011: controls <= 17'b01110101001000000; //sw
                6'b001111: controls <= 17'b11110011101000000; //lui
                6'b000011: controls <= 17'b10000000000000100; //jal
                6'b000101: controls <= 17'b01110011000010000; //bne
                6'b000100: controls <= 17'b01110011000001000; //beq
                default: controls <= 17'bxxxxxxxxxxxxxxxx; //default
            endcase
        end    
end
endmodule


//This is the regfile that keeps track of the registers
//a1 is the  read port
//a2 is the bits of the instruction 
//a3 is the destination register
//rd1 and rd2 are the two outputs
module regfile(input clk,
               input we3, rst,
               input [4:0] a1, a2, wa3,
               input [31:0] wd3,
               output [31:0] rd1, rd2);

    reg [31:0] rf[31:0];
    always @ (negedge clk)
        if (we3==1 && wa3 != 0) 
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
// which is how we implement PC? = PC + 4 + SignImm Ã 4 in beq
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
endmodule
*/

