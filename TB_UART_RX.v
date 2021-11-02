`timescale 1ns/100ps
`include "UART_TX.v"

module TB_UART_RX;

localparam N = 8;
localparam STOP = 0;

reg	clk50m, tx_clk, nrst;

//	UART receiver signals;
wire	rx;
wire	r_ready;
wire	[N-1:0] r_data;

//	UART transmitter signals;
reg		t_start;
reg		[N-1:0] t_data;
wire	tx, t_ready;

//	Test data array;
reg [7:0] data_array [0:15];
//	Tests timers;
reg [2:0]	tmr0;
reg 		tmr0_end;
reg			tmr0_en;
//
reg [7:0] i;

///	ASSIGMENTS
// assign rx = tx;
assign rx = 0;


UART_RX #(
	.STOP(STOP)
	)
	UART_RX_INST (
	// Inputs;
	.clk(clk50m),
	.nrst(nrst),
	.in(rx),
	// Outputs;
	.q(r_data),
	.ready(r_ready)
	);
	

UART_TX #(
	.STOP(STOP)
	)
	UART_TX_INST (
	//	Inputs
	.clk(tx_clk),
	.nrst(nrst),
	.start(t_start),
	.data(t_data),
	//	Outputs;
	.q(tx),
	.ready(t_ready)
	);


//	TMR0
always@(negedge tx_clk)
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

always@(posedge tx_clk)
	if (tmr0_end)
		tmr0_en <= 0;
	else
		tmr0_en <= tmr0_en;
		
//	TX data;
always@(posedge tx_clk)
	if (t_ready | tmr0_end)
		begin
		t_data <= data_array[i];
		t_start <= 1;
		i <= i + 1;
		end
	else
		begin
		t_data <= t_data;
		t_start <= 0;
		i <= i;
		end		


	
///	INIT
//	Main;
initial
	begin
	clk50m = 0;
	nrst = 0;
	tx_clk = 0;
	i = 0;
	t_data = 0;
	t_start = 0;
	tmr0 = 0;
	tmr0_en = 1;
	tmr0_end = 0;
	#100
	nrst = 1;
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
	#10 clk50m = ~clk50m;
	
//	Clocks
always
	#43400 tx_clk = ~tx_clk;
	
initial
	#2000000 $finish;


/// GENERATE VCD-FILE
initial
	begin
	$dumpfile("out.vcd");
	$dumpvars(0, TB_UART_RX);
	$dumpvars(0, UART_RX_INST);
	end


endmodule