`timescale 1ns/100ps
module TB_UART_TX;


reg clk, nrst;

//	Uart transmitter signals
reg		start;
reg		[7:0] data;
wire	q;
wire	ready;




UART_TX UART_TX_INST (
	//	Inputs
	.clk(clk),
	.nrst(nrst),
	.start(start),
	.data(data),
	//	Outputs;
	.q(q),
	.ready(ready)
	);


///	INIT
initial
	begin
	clk = 0;
	nrst = 0;
	start = 0;
	data = 0;
	#100
	nrst = 1;
	#21600
	start = 1;
	data = 8'h5a;
	#8680
	start = 0;
	end

//	Clocks
always
	#4340 clk = ~clk;

initial
	#500000 $finish;

/// GENERATE VCD-FILE
initial
	begin
	$dumpfile("out.vcd");
	$dumpvars(0, TB_UART_TX);
	$dumpvars(0, UART_TX_INST);
	end


endmodule