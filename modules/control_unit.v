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

