module PC_add4 #(
    parameter PC_WIDTH = 32
)(
	input    [PC_WIDTH-1:0] fromPC,
   output   [PC_WIDTH-1:0] nexttoPC
	);
assign nexttoPC = fromPC + 32'h00000004;
endmodule