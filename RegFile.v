module RegFile #(
    parameter DATA_WIDTH = 32,
	 parameter ADD_REG = 5,
	 parameter REG_DEPTH = 32,
	 parameter REG_WIDTH =32
	 )(
	 input clk, 
	 input reset,
    input RegWrite,
    input [ADD_REG-1:0] Rs1, Rs2, Rd,
    input [DATA_WIDTH-1:0] WriteData,
    output [DATA_WIDTH-1:0] ReadData1, ReadData2
  );
reg [REG_WIDTH-1:0] registers [REG_DEPTH-1:0];
integer k;
always @(posedge clk ) begin 
	if(reset == 1'b1) begin
		 for(k=0;k<32;k=k+1) begin
		 registers[k] = 32'h0;
	end 
end else if (RegWrite == 1'b1) begin
		 registers[Rd] = WriteData;
	end
end
assign ReadData1 = registers[Rs1];
assign ReadData2 = registers[Rs2];
endmodule 
