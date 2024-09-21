module counter #(
parameter N_BITS=4
)(
	input 				    clk,
	input 				    rst_n,
	input				    inc,
    input                   dec,
	output  [N_BITS-1:0]    cnt
);

reg [N_BITS-1:0] counter;

always @(posedge clk or negedge rst_n)
if (~rst_n)
counter <= {N_BITS{1'b0}};
else if (inc) counter <= counter + N_BITS'(1'b1);
else if (dec) counter <= counter - N_BITS'(1'b1);

assign cnt = counter;

endmodule