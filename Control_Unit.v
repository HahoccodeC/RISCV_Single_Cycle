module Control_Unit #(
	parameter OPCODE_WIDTH = 7,
	parameter ALUOP_WIDTH = 2
)(
	 input reset, // khong co clk do control_unit la mach to hop
    input [OPCODE_WIDTH-1:0] opcode,
    output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output reg [ALUOP_WIDTH-1:0] ALUOp // ALUOp1, ALUOp0
	);
always @(opcode) begin
	if(~reset) begin
		Branch = 0;
		MemRead = 0;
		MemtoReg = 0;
		MemWrite = 0;
		ALUSrc = 0;
		ALUOp = 2'b00;
		RegWrite = 0;
	end
	else begin 
		case (opcode)
		7'b0110011: //R-type ins
			begin
				ALUSrc = 0;
				MemtoReg = 0;
				RegWrite = 1;
				MemRead = 0;
				MemWrite = 0;
            Branch = 0;
            ALUOp = 2'b10;
            end
       7'b0000011: //I-type ins load
            begin
            ALUSrc = 1;
				MemtoReg = 1;
				RegWrite = 1;
				MemRead = 1;
				MemWrite = 0;
            Branch = 0;
            ALUOp = 2'b00;
            end
        7'b0100011: //S-type ins
            begin
            ALUSrc = 1;
				MemtoReg = 0;
				RegWrite = 0;
				MemRead = 0;
				MemWrite = 1;
            Branch = 0;
            ALUOp = 2'b00;
            end
        7'b1100011: //B-type ins
            begin
            ALUSrc = 0;
				MemtoReg = 0;
				RegWrite = 0;
				MemRead = 0;
				MemWrite = 0;
            Branch = 1;
            ALUOp = 2'b01;
            end

default: begin
				ALUSrc = 0;
				MemtoReg = 0;
				RegWrite = 1;
				MemRead = 0;
				MemWrite = 0;
            Branch = 0;
            ALUOp = 2'b10;
            end
            endcase // opcode
        end 
    end 
endmodule
