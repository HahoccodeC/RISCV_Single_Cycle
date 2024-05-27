module ALU #(
    parameter OP_WIDTH = 32,
	 parameter ALUCONTROL_WIDTH = 4,
	 parameter ALURESULT_WIDTH = 32,
	 parameter ADD_ALU = 4'b0000,
    parameter SUB_ALU = 4'b0001,
    parameter AND_ALU = 4'b0010,
    parameter OR_ALU = 4'b0011,
    parameter XOR_ALU = 4'b0100,
    parameter SLT_ALU = 4'b0101,
    parameter SHL_ALU = 4'b0110,
    parameter SHR_ALU = 4'b0111,
    parameter EQUAL_ALU = 4'b1001,
    parameter NOT_EQUAL_ALU = 4'b1010
)
(
	input [OP_WIDTH-1:0] A,B,
	input [ALUCONTROL_WIDTH-1:0] ALUcontrol,
	output reg zero,
	output reg [ALURESULT_WIDTH-1:0] ALU_result
	);
always @(ALUcontrol or A or B) begin 
	case (ALUcontrol)
	//gan cac phep tinh toan cho ALU
    ADD_ALU: begin zero =0; ALU_result <= A+B;end
    XOR_ALU: begin zero =0; ALU_result <= A|B;end
    AND_ALU: begin zero =0; ALU_result <= A&B;end
    SUB_ALU: begin if(A==B) zero <=1; else zero <=0; ALU_result <= A-B;end
	 SLT_ALU: ALU_result = (A < B) ? 1 : 0;
	 SHL_ALU: ALU_result = A << B;
	 SHR_ALU: ALU_result = A >> B;
	 EQUAL_ALU:ALU_result = (A == B) ? 1 : 0;
	 NOT_EQUAL_ALU: ALU_result = (A == B) ? 1 : 0;
	endcase
	end
endmodule 