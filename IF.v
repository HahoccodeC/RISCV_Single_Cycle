module IF #(
    parameter INS_WIDTH = 32,
	 parameter INS_DEPTH = 64,
	 parameter ADDR_DEPTH = 64
	 
)(
	input clk, reset,
	input      [ADDR_DEPTH-1:0] read_address,
	output  [INS_WIDTH-1:0] instruction_out
	);
reg [INS_WIDTH-1:0] Imemory [INS_DEPTH-1:0];
integer k;
assign instruction_out = Imemory[read_address];

always @(posedge clk) begin 
	if(reset == 1'b0) begin
		for (k=0; k< INS_DEPTH; k=k+1)
		 Imemory[k] = 32'h0;
	end 
	else if (reset == 1'b1)begin
	 Imemory[0] = 32'b0000000_11001_01010_000_01010_0110011;
	 Imemory[1] = 32'b000000000010_00000_000_00010_0010011; // addi x2, x0, 2
    Imemory[2] = 32'b000000001100_00000_000_00011_0010011; // addi x3, x0, 12
    Imemory[3] = 32'b0100000_00011_00010_000_00001_0110011; // sub x1, x2, x3
    Imemory[4] = 32'b0000000_00011_00010_000_00001_0110011; // add x1, x2, x3
    Imemory[5] = 32'b0000000_00011_00010_001_00001_0110011; // sll x1, x2, x3
    Imemory[6] = 32'b000000000010_00001_000_00010_0010011; // addi x2, x1, 2
	end
end
endmodule 
