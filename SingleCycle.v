module PC_add4 (
	input [31:0] fromPC,
    output reg [31:0] nexttoPC
	);
assign nexttoPC = fromPC + 32'h00000004;

endmodule 

module Adder (
	input [31:0] inA,
	input [31:0] inB,
	output [31:0] reg sum 
	);
assign sum = inA + inB ; 
endmodule
 
module PC (
	input clk, reset,
	input [31:0] PC_in,
	output reg [31:0] PC_out
	);
always @(posedge clk or negedge reset) begin 
	if(~reset)
	begin 
		PC_out <= 0;
	end else begin
	PC_out <= PC_in;
	end
end
endmodule 

module IF (
	input clk, reset,
	input [31:0] read_address,
	output reg [31:0] instruction_out
	);
reg [31:0] Imemory [63:0];
integer k;
assign instruction_out = Imemory[read_address];

always @(posedge clk) begin 
	if(reset == 1'b1) begin
		for (k=0; k<64; k=k+1)
		 Imemory[k]=32'h0;
	end 
	else if (reset == 1'b1)begin
		Imemory[0] = 32'b0000000_11001_01010_000_01010_0110011;
	end
end
endmodule 

module RegFile (
	input clk, reset,
    input RegWrite,
    input [4:0] Rs1, Rs2, Rd,
    input [31:0] WriteData,
    output reg [31:0] ReadData1, ReadData2
  );
reg [31:0] registers [31:0];
integer k;
always @(posedge clk ) begin 
	if(reset == 1'b1) begin
		 for(k=0;k<32;k=k+1) begin
		 registers[k] = 32'h0;
	end 
end else if (RegWrite == 1'b1) begin
		 registers[Rd] = WriteData
	end
end
assign ReadData1 = registers[Rs1];
assign ReadData2 = registers[Rs2];
endmodule 

module ImmGen (
    input signed [31:0] instruction, // Lệnh RISC-V đầu vào
    output reg signed [31:0] I, S, SB // Các giá trị immediate cho các loại lệnh khác nhau
);

always @(instruction) begin
    // I-type immediate: từ bit [31:20]
    I = {{20{instruction[31]}}, instruction[31:20]};
    
    // S-type immediate: từ bit [30:25] và [11:7]
    S = {{20{instruction[31]}}, instruction[30:25], instruction[11:7]};
    
    // SB-type immediate: từ bit [31], [7], [30:25], [11:8], và thêm 1 bit 0 ở cuối
    SB = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
end

endmodule
 
module Control_Unit (
	input reset, // khong co clk do control_unit la mach to hop
    input [6:0] opcode,
    output reg Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output reg [1:0] ALUOp // ALUOp1, ALUOp0
	);
always @(opcode) begin
	if(~reset) begin
		Branch <= 7'b0000000;
		MemRead <= 7'b0000000;
		MemtoReg <= 7'b0000000;
		MemWrite <= 7'b0000000;
		ALUSrc <= 7'b0000000;
		ALUOp <= 7'b0000000;
		RegWrite <= 7'b0000000;
	end
	else begin 
		case (opcode)
			7'b0110011: //R-type ins
			begin
				ALUSrc <= 0;
				MemtoReg <= 0;
				RegWrite <= 1;
				MemRead <= 0;
				MemWrite <= 0;
                Branch <= 0;
                ALUOp <= 2'b10;
            end
            7'b0000011: //I-type ins load
            begin
            	ALUSrc <= 1;
				MemtoReg <= 1;
				RegWrite <= 1;
				MemRead <= 1;
				MemWrite <= 0;
                Branch <= 0;
                ALUOp <= 2'b00;
            end
            7'b0100011: //S-type ins
            begin
            	ALUSrc <= 1;
				MemtoReg <= 0;
				RegWrite <= 0;
				MemRead <= 0;
				MemWrite <= 1;
                Branch <= 0;
                ALUOp <= 2'b00;
            end
            7'b1100011: //B-type ins
            begin
            	ALUSrc <= 0;
				MemtoReg <= 0;
				RegWrite <= 0;
				MemRead <= 0;
				MemWrite <= 0;
                Branch <= 1;
                ALUOp <= 2'b01;
            end

default: begin
				ALUSrc <= 0;
				MemtoReg <= 0;
				RegWrite <= 1;
				MemRead <= 0;
				MemWrite <= 0;
                Branch <= 0;
                ALUOp <= 2'b10;
            end
            endcase // opcode
        end 
    end 
endmodule

module ALU (
	input [31:0] A,B,
	input [3:0] ALUcontrol,
	output reg zero,
	output reg [31:0] ALUresult
	);
always @(ALUcontrol or A or B) begin 
	case (ALUcontrol)
	//gan cac phep tinh toan cho ALU
    4'b0010: begin zero <=0; ALUresult <= A+B;
    4'b0001: begin zero <=0; ALUresult <= A|B;
    4'b0000: begin zero <=0; ALUresult <= A&B;
    4'b0110: begin if(A==B) zero <=1; else zero <=0; ALUresult <= A-B;
		default : begin
	endcase
endmodule 

modlue ALU_Control (
	input [1:0] ALUOp,
	input [31:25] funct7,
	input [14:12] funct3,
	output reg [3:0] ALUcontrolout
	);
always @(ALUOp or funct3 or funct7) begin
	case ({ALUOp, funct7, funct3})
		12'b00_0000000_000 : ALUcontrolout = 4'b0010;
		default: ALUcontrolout = 4'bxxxx;
	endcase
end
endmodule

module Data_Memory (
	input clk, reset,
	input MemWrite, MemRead,
	input [31:0] address , WritedataMem,
	output [31:0] Data_out
	);
reg [31:0] DataMemory [63:0];
integer k;
assign Data_out = (MemRead) ? DataMemory[address] : 32'b0; // Đọc dữ liệu từ bộ nhớ

    always @(posedge clk or posedge reset)
    begin
        if (reset == 1'b1)
        begin
            for (k = 0; k < 64; k = k + 1)
            begin
                DataMemory[k] = 32'b0;  // Đặt lại tất cả bộ nhớ thành 0 khi reset
            end
        end
        else if (MemWrite)
        begin
            DataMemory[address] = Writedata;  // Ghi dữ liệu vào bộ nhớ
        end
    end
endmodule

module Mux1 (
	input Sel,
	input [31:0] A1,B1,
	output [31:0] Mux1_out,
	);
assign Mux_out = (Sel==1'b0) ? A1:B1;
endmodule

module Mux2 (
	input Sel,
	input [31:0] A2,B2,
	output [31:0] Mux2_out
	);
assign Mux2_out = (Sel==1'b0) ? A2:B2;
endmodule

module Mux3 (
	input Sel,
	input [31:0] A3,B3,
	output [31:0] Mux3_out
	);
assign Mux3_out = (Sel==1'b0) ? A3:B3;
endmodule

module RISCV_SingleCycle_Top(
	input clk,reset
	);
wire [31:0] PCtop, NexttoPCtop, instruction_outtop,ReadData1top,ReadData2top, toALU, ALUcontrolouttop, ALUresulttop, Dataouttop, writebacktop;
wire Regwritetop, ALUSrctop, Memwritetop, Memreadtop, Memtoregtop;
wire [1:0] ALUOptop;
PC_add4 pc_add4 (
	.fromPC(PCtop), 
	.nexttoPC(NexttoPCtop)
	);

PC program_counter(
	.clk(clk),
	.reset(reset),
	.PC_in(NexttoPCtop),
	.PC_out(PCtop)
	);

IF instruction_memory(
	.clk(clk),
	.reset(reset),
	.read_address(PCtop),
	.instruction_out(instruction_outtop)
	);

RegFile regfile(
	.clk(clk), 
	.reset(reset),
    .RegWrite(Regwritetop),
    .Rs1(instruction_outtop[19-15]), 
    .Rs2(instruction_outtop[24-20]), 
    .Rd(instruction_outtop[11:7]),
    .WriteData(writebacktop),
    .ReadData1(ReadData1top), 
    .ReadData2(toALU)
    );

ALU ALU(
	.A(ReadData1top),
	.B(ReadData2top),
	.ALUControl(ALUcontrolouttop),
	.ALUResult(ALUresulttop),
	.zero(),
	);

Mux1 mux1 (
	.Sel(ALUSrctop),
	.A1(ReadData2top),
	.B1(),
	.Mux1_out(toALU),
	);

ALUcontrol ALUcontrol(
	.ALUOp(ALUOptopl),
    .funct7(instruction_outtop[30]),
	.funct3(instruction_outtop[14:12]),
	.ALUcontrolout(ALUcontrolouttop)
	);

Data_Memory datameory (
	.clk(clk), 
	.reset(reset),
	.MemWrite(Memwritetop), 
	.MemRead(Memreadtop),
	.address(ALUresulttop) , 
	.WritedataMem(),
	.Data_out(Dataouttop)
	);

Mux2 mux2 (
	.Sel(Memtoregtop),
	.A2(ALUresulttop),
	.B2(Dataouttop),
	.Mux2_out(writebacktop)
);

Control_Unit controlunit (
	.reset(reset), 
    .opcode(instruction_outtop[6:0]),
    .Branch(), 
    .MemRead(Memreadtop), 
    .MemtoReg(Memtoregtop), 
    .MemWrite(Memwritetop), 
    .ALUSrc(ALUSrctop), 
    .RegWrite(Regwritetop),
    .ALUOp(ALUOptop)
    );
endmodule 