
// Code your design here
module branch_predict_local(input 					clk, rst, pcsrcD, stallF,
														input  [31:0] 	PC, PCBranchD,
                      			output [31:0]		PC_pred,
                      			output					pred_taken);
  reg [33:0] pht[0:127];
  // Useful indices
  // pht[PC[6:0]][33:2] : Predicted PC
  // pht[PC[6:0]][1:0]  : Prediction state bits
  //	00: N*
  //	01: N*T
  //	10: T*N
  //	11: T*
  
  reg [31:0] pc_prev;

  assign PC_pred 		= pht[PC[6:0]][33:2];
  assign pred_taken = pht[PC[6:0]][1];

	// DEBUG WIRES
	wire [1:0] predict_bits;
	assign predict_bits = pht[PC[6:0]][1:0];

	integer i;

  always @ (posedge clk, posedge rst) begin
    if (rst) begin // RESET behavior
      for (i = 0; i < 128; i = i + 1)
        pht[i] <= 34'b0;

			pc_prev <= 32'b0;
    end else if (!stallF) begin // Updating prediction state bits (FSM)
      case (pht[pc_prev[6:0]][1:0])
        2'b00: pht[pc_prev[6:0]][1:0] <= (pcsrcD ? 2'b01 : 2'b00);
        2'b01: pht[pc_prev[6:0]][1:0] <= (pcsrcD ? 2'b10 : 2'b00);
        2'b10: pht[pc_prev[6:0]][1:0] <= (pcsrcD ? 2'b11 : 2'b01);
        2'b11: pht[pc_prev[6:0]][1:0] <= (pcsrcD ? 2'b11 : 2'b10);
      endcase
			pc_prev <= PC;
			if (pcsrcD) begin
				pht[pc_prev[6:0]][33:2] <= PCBranchD;
			end
    end
  end
endmodule
