module branch_predict_global(input 					clk, rst, pcsrcD, stallF,
                             input  [31:0] 	PC, PCBranchD,
                             output [31:0]	PC_pred,
                             output					pred_taken);
  wire [31:0] PC_pred1, PC_pred2, PC_pred3, PC_pred4; 
  wire				pred_taken1, pred_taken2, pred_taken3, pred_taken4;

  branch_predict_local bp1(clk, rst, pcsrcD, stallF, PC, PCBranchD, PC_pred1, pred_taken1);
  branch_predict_local bp2(clk, rst, pcsrcD, stallF, PC, PCBranchD, PC_pred2, pred_taken2);
  branch_predict_local bp3(clk, rst, pcsrcD, stallF, PC, PCBranchD, PC_pred3, pred_taken3);
  branch_predict_local bp4(clk, rst, pcsrcD, stallF, PC, PCBranchD, PC_pred4, pred_taken4);

  // Recent global branch history
  reg [1:0] global_bh;

  assign PC_pred = global_bh[1] ? (global_bh[0] ? PC_pred4 : PC_pred3) : (global_bh[0] ? PC_pred2 : PC_pred1);
  assign pred_taken = global_bh[1] ? (global_bh[0] ? pred_taken4 : pred_taken3) : (global_bh[0] ? pred_taken2 : pred_taken1);

  always @ (posedge clk, posedge rst) begin
    if (rst) begin
      global_bh <= 2'b0;
    end else if (!stallF) begin
      case (global_bh)
        2'b00: global_bh <= pred_taken ? 2'b01 : 2'b00;
        2'b01: global_bh <= pred_taken ? 2'b10 : 2'b00;
        2'b10: global_bh <= pred_taken ? 2'b11 : 2'b01;
        2'b11: global_bh <= pred_taken ? 2'b11 : 2'b10;
      endcase
    end
  end
endmodule
