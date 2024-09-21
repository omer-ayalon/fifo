module fifo #(
parameter 	WIDTH=4,
parameter	DEPTH=2
)(
	input 						clk,
	input 						rst_n,
	input 						push_enable,
	input 	[WIDTH-1:0]			push_data,
	input						pop_enable,
	output  [WIDTH-1:0]			pop_data,
    output  [L2_DEPTH:0]		item_count
);

localparam L2_DEPTH = $clog2(DEPTH);

reg  [DEPTH-1:0][WIDTH-1:0]	mem;
reg  						full_flag;
reg							empty_flag;
wire [L2_DEPTH-1:0] 		rd_ptr;
wire [L2_DEPTH-1:0] 		wr_ptr;
wire [L2_DEPTH:0] 		item_count;

counter #(
	.N_BITS(L2_DEPTH)
) write_counter (
	.clk(clk),
	.rst_n(rst_n),
	.inc(push_enable),
    .dec(1'b0),
	.cnt(wr_ptr));
	
counter #(
	.N_BITS(L2_DEPTH)
) read_counter (
	.clk(clk),
	.rst_n(rst_n),
	.inc(pop_enable),
    .dec(1'b0),
	.cnt(rd_ptr));

counter #(
	.N_BITS(L2_DEPTH+1)
) full_counter (
	.clk(clk),
	.rst_n(rst_n),
	.inc(push_enable),
    .dec(pop_enable),
	.cnt(item_count));
    
// Write Data
always @(posedge clk)
if (push_enable) begin
mem[wr_ptr] <= push_data;
end

// Read Data
assign pop_data = mem[rd_ptr];
assign full_flag = (item_count=={1'b1, {L2_DEPTH{1'b0}}});
assign empty_flag = (item_count=={1'b0, {L2_DEPTH{1'b0}}});

endmodule