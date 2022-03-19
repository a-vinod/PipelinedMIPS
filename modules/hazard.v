
module hazard(input pcsrcD1, pcsrcD2,
              input [1:0] branchD1, branchD2,
              input [4:0] RsD1, RtD1, RsD2, RtD2,
              input [1:0] predict_takenD,
              input [4:0] RsE1, RtE1, RsE2, RtE2,
              input RegWriteE1, RegWriteE2,
              input [3:0] MemtoRegE1, MemtoRegE2,
              input [4:0] writeregE1, writeregE2,
              input RegWriteM1, RegWriteM2,
              input [3:0] MemtoRegM1, MemtoRegM2,
              input [4:0] writeregM1, writeregM2,
              input regwriteW1, regwriteW2,
              input [4:0] writeregW1, writeregW2,
              input hitF, hitM,
              input dependency, dependency_prev,
              output reg flushE,
              output reg stallF, stallD, stallE, stallM, stallW,
              output reg [1:0] forwardAD1, forwardBD1, forwardAD2, forwardBD2,
              output reg [2:0] forwardAE1, forwardBE1, forwardAE2, forwardBE2);

  // Stall Logic
  assign i_cache_stall = !hitF;
  assign d_cache_stall = !hitM && (MemtoRegM1[1:0] == 2'b11 || MemtoRegM2[1:0] == 2'b11);

  wire lw_stall;
  assign lw_stall = ((RsD1 == RtE1) || (RtD1 == RtE1) || (RsD2 == RtE2) || (RtD2 == RtE2) || (RsD1 == RtE2) || (RtD1 == RtE2) || (RsD2 == RtE1) || (RtD2 == RtE1)) && (MemtoRegE1[1:0] == 2'b11 || MemtoRegE2[1:0] == 2'b11);

  wire branch_stall;
  assign branch_stall = hitF && (branchD1 != 2'b00 || branchD2 != 2'b00) && (RegWriteE2 && ((RsD2 == writeregE2) || (RtD2 == writeregE2) || (RsD1 == writeregE2) || (RtD1 == writeregE2)));

  wire mispredict;
  assign mispredict = hitF && ((predict_takenD[1] && !pcsrcD2) || (!predict_takenD[1] && pcsrcD2) || (predict_takenD[0] && !pcsrcD1) || (!predict_takenD[0] && pcsrcD1));
  always @ (*) begin
    stallF <= 0;
    stallD <= 0;
    stallE <= 0;
    stallM <= 0;
    stallW <= 0;

    flushE <= 0;

    // Instruction 1
    if (!dependency) begin
      if(hitF && (branchD1 != 2'b00 || branchD2 != 2'b00) && ((RegWriteE1 && ((RsD1 == writeregE1) || (RtD1 == writeregE1) || (RsD2 == writeregE1) || (RtD2 == writeregE1))) || ((MemtoRegM1[1:0] == 2'b11) && ((RsD1 == writeregM1) || (RtD1 == writeregM1))))) //branch
        begin
          stallF <= 1;
          stallD <= 1;
          flushE <= 1;
        end
      else if(hitF && (branchD1 != 2'b00 || branchD2 != 2'b00) && (RegWriteE2 && ((RsD2 == writeregE2) || (RtD2 == writeregE2) || (RsD1 == writeregE2) || (RtD1 == writeregE2)))) //branch
        begin
          stallF <= 1;
          stallD <= 1;
          flushE <= 1;
        end
      else if (mispredict)
        begin
          //stallF <= 1;
          //stallD <= 1;
          //flushE <= 1;
          stallM <= 1;
          stallE <= 1;
        end
    end

    if(lw_stall) //lw
      begin
        stallF <= 1;
        stallD <= 1;
        flushE <= 1;
      end

    if(i_cache_stall || d_cache_stall)
      begin
        stallF <= 1;
        stallD <= 1;
        stallE <= 1;
        stallM <= 1;
        stallW <= 1;
      end

    // Instruction 1 writes to register that Instruction 2 reads from (RAW)
    if (dependency) begin
      stallF <= 1;
      stallD <= 0;
      stallE <= 1;
      flushE <= 0;
      stallM <= 1;
      stallW <= 1;
    end

    if (dependency_prev) begin
      stallF <= 1;
    end

  end

  // Forward Logic
  always @ (*) begin
    if ((RsE1 != 0) && (RegWriteM2) && (RsE1 == writeregM2))
      forwardAE1 <= 3'b011;
    else if((RsE1 != 0) && (RegWriteM1) && (RsE1 == writeregM1))
      forwardAE1 <= 3'b010;
    else if((RsE1 != 0) && (regwriteW2) && (RsE1 == writeregW2))
      forwardAE1 <= 3'b100;
    else if((RsE1 != 0) && (regwriteW1) && (RsE1 == writeregW1))
      forwardAE1 <= 3'b001;
    else
      forwardAE1 <= 3'b000;

    if ((RtE1 != 0) && (RegWriteM2) && (RtE1 == writeregM2))
      forwardBE1 <= 3'b011;
    else if((RtE1 != 0) && (RegWriteM1) && (RtE1 == writeregM1))
      forwardBE1 <= 3'b010;
    else if((RtE1 != 0) && (regwriteW2) && (RtE1 == writeregW2))
      forwardBE1 <= 3'b100;
    else if((RtE1 != 0) && (regwriteW1) && (RtE1 == writeregW1))
      forwardBE1 <= 3'b001;
    else
      forwardBE1 <= 3'b000;	

    if((RsD1 != 0) && (RegWriteM1) && (RsD1 == writeregM1))
      forwardAD1 <= 2'b01;
    else if((RsD1 != 0) && (RegWriteM2) && (RsD1 == writeregM2))
      forwardAD1 <= 2'b10;
    else
      forwardAD1 <= 2'b00;

    if((RtD1 != 0) && (RegWriteM1) && (RtD1 == writeregM1))
      forwardBD1 <= 2'b01;
    else if((RtD1 != 0) && (RegWriteM2) && (RtD1 == writeregM2))
      forwardBD1 <= 2'b10;
    else
      forwardBD1 <= 2'b00;

    if((RsE2 != 0) && RegWriteM1 && (RsE2 == writeregM1))
      forwardAE2 <= 3'b011;
    else if((RsE2 != 0) && (RegWriteM2) && (RsE2 == writeregM2))
      forwardAE2 <= 3'b010;
    else if((RsE2 != 0) && regwriteW1 && (RsE2 == writeregW1))
      forwardAE2 <= 3'b100;
    else if((RsE2 != 0) && (regwriteW2) && (RsE2 == writeregW2))
      forwardAE2 <= 3'b001;
    else
      forwardAE2 <= 3'b000;

    if((RtE2 != 0) && RegWriteM1 && (RtE2 == writeregM1))
      forwardBE2 <= 3'b011;
    else if((RtE2 != 0) && (RegWriteM2) && (RtE2 == writeregM2))
      forwardBE2 <= 3'b010;
    else if((RtE2 != 0) && regwriteW1 && (RtE2 == writeregW1))
      forwardBE2 <= 3'b100;
    else if((RtE2 != 0) && (regwriteW2) && (RtE2 == writeregW2))
      forwardBE2 <= 3'b001;
    else
      forwardBE2 <= 3'b000;

    if((RsD2 != 0) && (RegWriteM2) && (RsD2 == writeregM2))
      forwardAD2 <= 2'b01;
    else if((RsD2 != 0) && (RegWriteM1) && (RsD2 == writeregM1))
      forwardAD2 <= 2'b10;
    else
      forwardAD2 <= 2'b00;

    if((RtD2 != 0) && (RegWriteM2) && (RtD2 == writeregM2))
      forwardBD2 <= 2'b01;
    else if((RtD2 != 0) && (RegWriteM1) && (RtD2 == writeregM1))
      forwardBD2 <= 2'b10;
    else
      forwardBD2 <= 2'b00;

  end
endmodule
