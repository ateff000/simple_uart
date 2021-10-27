`timescale 1ns/100ps
module TB_UART_TX;


reg clk, nrst;

//	Uart transmitter signals;
reg		start;
reg		[7:0] data;
wire	q;
wire	ready;

//	Test data array;
reg [7:0] data_array [0:15];
//	Tests timers;
reg [2:0]	tmr0;
reg 		tmr0_end;
reg			tmr0_en;
//
reg [7:0] i;



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

//	TMR0
always@(negedge clk)
	if (tmr0_en)
		if (tmr0 < 7)
			begin
			tmr0 <= tmr0 + 1;
			tmr0_end <= 0;
			end
		else
			begin
			tmr0 <= 0;
			tmr0_end <= 1;
			end
	else
		begin
		tmr0 <= 0;
		tmr0_end <= 0;
		end


always@(posedge clk)
	if (tmr0_end)
		tmr0_en <= 0;
	else
		tmr0_en <= tmr0_en;


///
always@(posedge clk)
	if (ready | tmr0_end)
		begin
		data <= data_array[i];
		start <= 1;
		i <= i + 1;
		end
	else
		begin
		data <= data;
		start <= 0;
		i <= i;
		end
		

///	INIT
//	Main;
initial
	begin
	i = 0;
	clk = 0;
	nrst = 0;
	start = 0;
	data = 0;
	tmr0 = 0;
	tmr0_end = 0;
	tmr0_en = 1;
	#100
	nrst = 1;
	// #21600
	// start = 1;
	// data = 8'h5a;
	// #8680
	// start = 0;
	end

//	Test data array;
initial
	begin
	data_array[0]	= 8'h5a;
	data_array[1]	= 8'h2b;
	data_array[2]	= 8'h00;
	data_array[3]	= 8'hff;
	data_array[4]	= 8'h1c;
	data_array[5]	= 8'h5e;
	data_array[6]	= 8'h04;
	data_array[7]	= 8'h13;
	data_array[8]	= 8'h7d;
	data_array[9]	= 8'h65;
	data_array[10]	= 8'h2e;
	data_array[11]	= 8'h81;
	data_array[12]	= 8'h09;
	data_array[13]	= 8'hab;
	data_array[14]	= 8'h51;
	data_array[15]	= 8'h2d;
	end

//	Clocks
always
	#4340 clk = ~clk;

initial
	#2000000 $finish;


/// GENERATE VCD-FILE
initial
	begin
	$dumpfile("out.vcd");
	$dumpvars(0, TB_UART_TX);
	$dumpvars(0, UART_TX_INST);
	end


endmodule