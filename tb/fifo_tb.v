`timescale 1ns/1ps

module tb;

parameter WIDTH=2;
parameter DEPTH=4;

// IO
reg 				clk;
reg 				rst_n;
reg					push_enable;
reg					pop_enable;
reg		[WIDTH-1:0]	push_data;
reg 	[WIDTH-1:0]	pop_data;
reg     [$clog2(DEPTH):0] full_fifo;

// TEST
initial begin
repeat (10) @ (posedge clk);

push_t(2'b01);
push_t(2'b11);
push_t(2'b10);
pop_t(2'b01);

push_t(2'b10);

pop_t(2'b11);
pop_t(2'b10);
pop_t(2'b10);


repeat (10) @ (posedge clk);
$display("Test completed");
$finish;
end

task push_t;
input [WIDTH-1:0] data;
@(negedge clk) begin
push_enable = 1'b1;
push_data = data;
repeat (1) @(negedge clk);
push_enable = 1'b0;
end
endtask

task pop_t;
input [WIDTH-1:0] data;
@(negedge clk) begin
pop_enable = 1'b1;
if (pop_data !== data) begin
$display("FIFO Data Is Not Expected! Got: %0b, expected: %0b", pop_data, data);
$finish;
end
repeat (1) @(negedge clk);
pop_enable = 1'b0;
end
endtask

// DUT
fifo #(
	.WIDTH(WIDTH),
	.DEPTH(DEPTH)
) dut(
	.clk(clk),
	.rst_n(rst_n),
	.push_enable(push_enable),
	.pop_enable(pop_enable),
	.pop_data(pop_data),
	.push_data(push_data),
    .item_count(full_fifo)
);

// INIT
initial begin
clk = 0;
rst_n = 1;
push_enable = 0;
pop_enable = 0;
push_data = 0;
end

// RST_N
initial begin
repeat (1) @ (posedge clk);
rst_n=0;
repeat (1) @ (posedge clk);
rst_n=1;
end

// WAVES
initial begin
$dumpfile("tb.vcd");
$dumpvars(0, tb);
end

// clk
always #5 clk = ~clk;

endmodule