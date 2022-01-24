//This is the hazard Unit

module hazard(
    input [1:0] branchD,
    input [3:0] wbsrcE, wbsrcM,
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
    input [3:0] wbsrcE, wbsrcM,
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

    if(((rsD == rtE) || (rtE == rtD)) && (wbsrcE == 4'b1111)) //lw
    begin
        stallF <= 1;
        stallD <= 1;
        flushE <= 1;
    end

    if((branchD!=2'b00) && ((regwriteE && ((rsD == writeregE) || (rtD == writeregE))) || ((wbsrcM == 4'b1110) && ((rsD == writeregM) || (rtD == writeregM))))) //branch
    begin
        stallF <= 1;
        stallD <= 1;
        flushE <= 1;
    end

    if((multstartE == 1)) //start multplication
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
        multplier <= 0;
    end
    
end
endmodule



