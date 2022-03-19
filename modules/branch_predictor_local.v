
module branch_predictor_local(input 					clk, rst, pcsrcD1, pcsrcD2, stallF, dependency, dependency_prev,
                              input  [31:0] 	PC, PCBranchD1, PCBranchD2,
                              output [31:0]		PC_pred,
                              output [1:0]		pred_taken);
  reg [33:0] pht[0:127];
  // Useful indices
  // pht[PC[6:0]][33:2] : Predicted PC
  // pht[PC[6:0]][1:0]  : Prediction state bits
  //	00: N*
  //	01: N*T
  //	10: T*N
  //	11: T*

  reg [31:0] pc_prev;
  reg [31:0] pcplus4_prev;
  wire [31:0] PCplus4F;
  assign PCplus4F = PC + 4;

  assign pred_taken = {pht[PCplus4F[6:0]][1], pht[PC[6:0]][1]};
  assign PC_pred 		= pred_taken[1] ? (pht[PCplus4F[6:0]][33:2]) : (pred_taken[0] ? (pht[PC[6:0]][33:2]) : (32'b0));

  integer i;

  always @ (posedge clk, posedge rst) begin
    if (rst) begin // RESET behavior
      for (i = 0; i < 128; i = i + 1)
        pht[i] <= 34'b0;

      pc_prev 		 <= 32'b0;
      pcplus4_prev <= 32'b0;
    end else if (!stallF) begin
      // Updating prediction state bits (FSM)
      // PC
      case (pht[pc_prev[6:0]][1:0])
        2'b00: pht[pc_prev[6:0]][1:0] <= (pcsrcD1 ? 2'b01 : 2'b00);
        2'b01: pht[pc_prev[6:0]][1:0] <= (pcsrcD1 ? 2'b10 : 2'b00);
        2'b10: pht[pc_prev[6:0]][1:0] <= (pcsrcD1 ? 2'b11 : 2'b01);
        2'b11: pht[pc_prev[6:0]][1:0] <= (pcsrcD1 ? 2'b11 : 2'b10);
      endcase
      // PC + 4
      if (!dependency)
        begin
          case (pht[pcplus4_prev[6:0]][1:0])
            2'b00: pht[pcplus4_prev[6:0]][1:0] <= (pcsrcD2 ? 2'b01 : 2'b00);
            2'b01: pht[pcplus4_prev[6:0]][1:0] <= (pcsrcD2 ? 2'b10 : 2'b00);
            2'b10: pht[pcplus4_prev[6:0]][1:0] <= (pcsrcD2 ? 2'b11 : 2'b01);
            2'b11: pht[pcplus4_prev[6:0]][1:0] <= (pcsrcD2 ? 2'b11 : 2'b10);
          endcase
        end

      // Updating branch target address
      if (pcsrcD1) begin
        pht[pc_prev[6:0]][33:2]			 <= PCBranchD1;
      end
      if (pcsrcD2) begin
        pht[pcplus4_prev[6:0]][33:2] <= PCBranchD2;
      end

      //if (!dependency_prev) begin
      pc_prev 		 <= PC;
      pcplus4_prev <= PCplus4F;
      //end
    end
  end

  // DEBUG wires
  wire [1:0] sm1;
  assign sm1 = pht[pc_prev[6:0]][1:0];
  wire [1:0] sm2;
  assign sm2 = pht[pcplus4_prev[6:0]][1:0];
endmodule
