module Data_Memory #(
   parameter ADDR_WIDTH =32,
	parameter DATAMEM_WIDTH =32,
	parameter DATAOUT_WIDTH =32,
	parameter DATA_DEPTH =32
	
)
(
	input clk, reset,
	input MemWrite, MemRead,
	input [ADDR_WIDTH-1:0] address , 
	input [DATAMEM_WIDTH-1:0] WritedataMem,
	output [DATAOUT_WIDTH-1:0] Data_out
	);
reg [DATAMEM_WIDTH-1:0] DataMemory [DATA_DEPTH-1:0];
integer k;
assign Data_out = (MemRead) ? DataMemory[address] : 32'b0; // Đọc dữ liệu từ bộ nhớ

    always @(posedge clk or posedge reset)
    begin
        if (reset == 1'b1)
        begin
            for (k = 0; k < DATA_DEPTH; k = k + 1)
            begin
                DataMemory[k] = 32'b0;  // Đặt lại tất cả bộ nhớ thành 0 khi reset
            end
        end
        else if (MemWrite)
        begin
            DataMemory[address] = WritedataMem;  // Ghi dữ liệu vào bộ nhớ
        end
    end
endmodule
