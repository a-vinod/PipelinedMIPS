module mips(input clk, rst);

  wire flushE;
  wire stallF, stallD, stallE, stallM, stallW;
  wire [1:0] forwardAD1, forwardBD1, forwardAD2, forwardBD2;
  wire [1:0] predict_takenD;
  wire pcsrcD1, pcsrcD2;
  wire [4:0] RsD1, RtD1, RsD2, RtD2;
  wire [4:0] RsE1, RtE1, RsE2, RtE2;
  wire [2:0] forwardAE1, forwardBE1, forwardAE2, forwardBE2;
  wire RegWriteE1, RegWriteE2;
  wire [3:0] MemtoRegE1, MemtoRegE2;
  wire [4:0] writeregE1, writeregE2;
  wire RegWriteM1, RegWriteM2;
  wire [3:0] MemtoRegM1, MemtoRegM2;
  wire [4:0] writeregM1, writeregM2;
  wire regwriteW1, regwriteW2;
  wire [4:0] writeregW1, writeregW2;
  wire hitF, hitM;
  wire [1:0] branchD1, branchD2;
  wire dependency, dependency_prev;

  hazard hz(pcsrcD1, pcsrcD2,
            branchD1, branchD2,
            RsD1, RtD1, RsD2, RtD2,
            predict_takenD,
            RsE1, RtE1, RsE2, RtE2,
            RegWriteE1, RegWriteE2,
            MemtoRegE1, MemtoRegE2,
            writeregE1, writeregE2,
            RegWriteM1, RegWriteM2,
            MemtoRegM1, MemtoRegM2,
            writeregM1, writeregM2,
            regwriteW1, regwriteW2,
            writeregW1, writeregW2,
            hitF, hitM,
            dependency, dependency_prev,
            flushE,
            stallF, stallD, stallE, stallM, stallW,
            forwardAD1, forwardBD1, forwardAD2, forwardBD2,
            forwardAE1, forwardBE1, forwardAE2, forwardBE2);

  datapath dp( clk,  rst,
              flushE,
              stallF, stallD, stallE, stallM, stallW,
              forwardAD1, forwardBD1, forwardAD2, forwardBD2,
              pcsrcD1, pcsrcD2,
              RsD1, RtD1, RsD2, RtD2,
              predict_takenD,
              RsE1, RtE1, RsE2, RtE2,
              forwardAE1, forwardBE1, forwardAE2, forwardBE2,
              dependency, dependency_prev,
              RegWriteE1, RegWriteE2,
              MemtoRegE1, MemtoRegE2,
              writeregE1, writeregE2,
              RegWriteM1, RegWriteM2,
              MemtoRegM1, MemtoRegM2,
              writeregM1, writeregM2,
              regwriteW1, regwriteW2,
              writeregW1, writeregW2,
              hitF, hitM,
              branchD1, branchD2);
endmodule
