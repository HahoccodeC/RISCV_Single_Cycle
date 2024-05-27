module Mux1 (
	input Sel,
	input [31:0] A1,B1,
	output [31:0] Mux1_out
	);
assign Mux1_out = (Sel==1'b0) ? A1:B1;
endmodule

