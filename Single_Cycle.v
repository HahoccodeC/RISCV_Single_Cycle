module Single_Cycle #(
   parameter PC_WIDTH = 32,
	parameter ALUOP_WIDTH = 2
)
(
	input clk,reset
	);
wire [PC_WIDTH-1:0] PCtop, NexttoPCtop, instruction_outtop,ReadData1top,ReadData2top, toALU, ALUcontrolouttop, ALUresulttop, Dataouttop, writebacktop;
wire Regwritetop, ALUSrctop, Memwritetop, Memreadtop, Memtoregtop;
wire [ALUOP_WIDTH-1:0] ALUOptop;
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
	.ALUcontrol(ALUcontrolouttop),
	.ALU_result(ALUresulttop),
	.zero(),
	);

Mux1 mux1 (
	.Sel(ALUSrctop),
	.A1(ReadData2top),
	.B1(),
	.Mux1_out(toALU),
	);

ALU_Control ALUcontrol(
	.ALUOp(ALUOptopl),
   .funct7(instruction_outtop[30]),
	.funct3(instruction_outtop[14:12]),
	.ALUControl(ALUcontrolouttop)
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