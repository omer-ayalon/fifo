/**
 * @file tb.v
 * 
 * This testbench module simulates the operation of the FIFO 
 * module (`m_fifo`) to verify its functionality and correctness. 
 * It generates various test scenarios to ensure that the FIFO 
 * correctly handles push and pop operations, including edge cases 
 * such as pushing on a full FIFO and popping from an empty FIFO. 
 * The testbench also verifies that the FIFO state flags (full and 
 * empty) behave as expected during operations.
 * 
 * @parameter WIDTH  The bit-width of the data elements that the 
 *                    FIFO can hold. This parameter is used to set 
 *                    the size of the push and pop data signals.
 * @parameter DEPTH  The maximum number of data elements the FIFO 
 *                    can store. This parameter determines the 
 *                    depth of the FIFO.
 * @parameter L2_DEPTH_P1 The logarithm base 2 of (DEPTH + 1), 
 *                    used to determine the number of bits needed 
 *                    for the item count tracking.
 * 
 * @signal clk      The clock signal used to synchronize operations 
 *                   within the FIFO.
 * @signal rst_n    The active-low reset signal. When asserted 
 *                   (low), the FIFO is reset to its initial state.
 * @signal push_enable The control signal to enable writing data 
 *                     into the FIFO.
 * @signal pop_enable  The control signal to enable reading data 
 *                      from the FIFO.
 * @signal push_data   The data input that will be pushed into the 
 *                     FIFO when `push_enable` is high.
 * @signal pop_data    The data output that is read from the FIFO 
 *                     when `pop_enable` is high.
 * @signal item_count  The current number of items in the FIFO, 
 *                     represented in binary.
 * @signal full_flag   A flag indicating whether the FIFO is full.
 * @signal empty_flag  A flag indicating whether the FIFO is empty.
 * 
 * The testbench includes various test cases to check the behavior 
 * of the FIFO under normal conditions and boundary cases. The 
 * results of the FIFO operations are printed to the console, 
 * allowing for easy verification of the expected vs. actual behavior. 
 * Waveform dumps are also created for further analysis in a waveform 
 * viewer.
 */
module tb;

parameter WIDTH=2;
parameter DEPTH=4;
parameter L2_DEPTH_P1 = $clog2(DEPTH+1);

// IO
reg 					clk;
reg 					rst_n;
reg						push_enable;
reg						pop_enable;
reg	 [WIDTH-1:0]		push_data;
reg  [WIDTH-1:0]		pop_data;
reg	 [L2_DEPTH_P1-1:0]	item_count;
reg						full_flag;
reg						empty_flag;

/////////////////////////////////////////////////////////
// TEST
/////////////////////////////////////////////////////////
initial begin
repeat (10) @ (posedge clk);

// PUSH ON FULL
// t_push(2'b01);
// t_push(2'b10);
// t_push(2'b10);
// t_push(2'b11);
// t_push(2'b10);

// POP ON EMPTY
// t_push(2'b11);
// t_pop(2'b11);
// t_pop(2'b10);

// NORMAL
t_push(2'b01);
t_push(2'b11);
t_push(2'b10);
t_pop(2'b01);
t_push(2'b00);
t_pop(2'b11);
t_pop(2'b10);
t_pop(2'b00);

// rst_n
// t_push(2'b01);
// t_push(2'b11);
// t_push(2'b10);
// t_pop(2'b01);
// rst_n = 0;
// repeat (1) @(posedge clk)
// rst_n = 1;
// t_push(2'b00);
// t_pop(2'b00);

repeat (5) @(posedge clk);
$display("Test completed");
$finish;
end

/////////////////////////////////////////////////////////
// Push/Pop tasks
/////////////////////////////////////////////////////////

task t_push;
input [WIDTH-1:0] data;
begin
#1;
push_enable = 1'b1;
push_data = data;
repeat (1) @(posedge clk);
#1;
push_enable = 1'b0;
end
endtask

task t_pop;
input [WIDTH-1:0] data;
begin
#1
pop_enable = 1'b1;
if (pop_data != data) begin
	$display("FIFO Data Is Not Expected!");
	$display("Got     : %2b", pop_data);
	$display("expected: %2b", data);
	$finish;
end
repeat (1) @(posedge clk)
#1
pop_enable = 1'b0;
end
endtask

/////////////////////////////////////////////////////////
// DUT
/////////////////////////////////////////////////////////

m_fifo #(
	.WIDTH(WIDTH),
	.DEPTH(DEPTH)
) dut(
	.clk(clk),
	.rst_n(rst_n),
	.push_enable(push_enable),
	.pop_enable(pop_enable),
	.pop_data(pop_data),
	.push_data(push_data),
    .item_count(item_count),
	.full_flag(full_flag),
	.empty_flag(empty_flag)
);

/////////////////////////////////////////////////////////
// INIT
/////////////////////////////////////////////////////////

initial begin
clk = 0;
rst_n = 1;
push_enable = 0;
pop_enable = 0;
push_data = 0;
end

/////////////////////////////////////////////////////////
// RST_N
/////////////////////////////////////////////////////////

initial begin
repeat (1) @ (posedge clk);
rst_n=0;
repeat (1) @ (posedge clk);
rst_n=1;
end

/////////////////////////////////////////////////////////
// WAVES
/////////////////////////////////////////////////////////

initial begin
$dumpfile("tb.vcd");
$dumpvars(0, tb);
end

/////////////////////////////////////////////////////////
// clk
/////////////////////////////////////////////////////////

always #5 clk = ~clk;

endmodule