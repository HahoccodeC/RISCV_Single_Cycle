module Adder  #(
    parameter PC_WIDTH = 32
) (
	input      [PC_WIDTH-1:0] inA,
	input      [PC_WIDTH-1:0] inB,
	output  [PC_WIDTH-1:0] sum 
	);
assign sum = inA + inB ; 
endmodule