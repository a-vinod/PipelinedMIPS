module regfile (input clk,
								input rst, we13, we23,
								input [4:0] a11, a12, wa13,
								input [31:0] wd13,
								input [4:0] a21, a22, wa23,
								input [31:0] wd23,
								output [31:0] rd11, rd12, rd21, rd22);

    reg [31:0] rf[31:0];
    always @ (negedge clk) begin
        if (we13==1 && wa13 != 0) 
            rf[wa13] <= wd13;
        if (we23==1 && wa23 != 0) 
            rf[wa23] <= wd23;
		end

    assign rd11 = (a11 != 0) ? rf[a11] : 0;
    assign rd12 = (a12 != 0) ? rf[a12] : 0;
    assign rd21 = (a21 != 0) ? rf[a21] : 0;
    assign rd22 = (a22 != 0) ? rf[a22] : 0;
endmodule
