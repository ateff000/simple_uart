module UART_RX
(
	// Inputs;
	clk,
	nrst,
	in,
	// Outputs;
	q,
	ready
);

parameter F = 50_000_000;	// Main clocks frquency, Hz;
parameter BR = 115_200;		// receiver bitrate;
parameter L = F/BR;			// One bit clk length;
parameter hL = L/2;			// One bit clk half-length;
parameter N = 8;	// Word bit width;
parameter M = 3;	// Bits counter width;
parameter PARYTY = 0;
parameter STOP = 1;

localparam IDLE = 0, GET_START = 1, RX_DATA = 2, GET_PARITY = 3, GET_STOP = 4;

///	INPUTS
//	System;
input clk, nrst;
//	Data input;
input in;

///	OUTPUTS
output	reg	[N-1:0]	q;
output 	reg	ready;

///	INTERNAL
//	Bits counter;
reg	[M-1:0]	bcnt;
reg 		bcnt_end;
reg			bcnt_en;
//	Bit length counter;
reg [15:0]	lcnt;
reg			lcnt_end;

//	State machine;
reg [2:0] state, next_state;

//	Check stop bits register;
reg stop, last_stop;


///	WORK
always@(*)
	case (state)
	IDLE:
		if (!in)
			next_state = GET_START;
		else
			next_state = IDLE;
			
    GET_START:
		if (lcnt_end)
			next_state = RX_DATA;
		else
			next_state = GET_START;
			
    RX_DATA:
		if (bcnt_end & lcnt_end)
			if (PARYTY)
				next_state = PARYTY;
			else
				next_state = GET_STOP;
		else
			next_state = RX_DATA;
			
    GET_PARITY:
		if (lcnt_end)
			next_state = GET_STOP;
		else
			next_state = GET_PARITY;
	
    GET_STOP:
		if ((bcnt_end & lcnt_end) | ((lcnt > hL) & !in))
			next_state = IDLE;
		else
			next_state = GET_STOP;
			
	endcase

always@(negedge clk or negedge nrst)
	if (!nrst)
		state <= 0;
	else
		state <= next_state;

//	Bit length counter and local clocks;
always@(posedge clk or negedge nrst)
	if (!nrst)
		begin
		lcnt <= 0;
		lcnt_end <= 0;
		end
	else
		if (state == IDLE)
			begin
			lcnt <= 0;
			lcnt_end <= 0;
			end
		else
			begin
			if (lcnt < L - 1)
				begin
				lcnt <= lcnt + 1;
				lcnt_end <= 0;
				end
			else
				begin
				lcnt <= 0;
				lcnt_end <= 1;
				end
			end

//	Bits counter and data register;
always@(negedge clk or negedge nrst)
	if (!nrst)
		bcnt_en <= 0;
	else
		if (state == IDLE)
			bcnt_en <= 0;
		else
			bcnt_en <= (lcnt == hL);

always@(posedge clk or negedge nrst)
	if (!nrst)
		begin
		q <= 0;
		bcnt <= 0;
		bcnt_end <= 0;
		end
	else
		case (state)
		IDLE:
			begin
			q <= q;
			bcnt <= 0;
			bcnt_end <= 0;
			end
			
		GET_START:
			begin
			q <= q;
			bcnt <= 0;
			bcnt_end <= 0;
			end
			
		RX_DATA:
			if (bcnt_en)
				begin
				q <= {q[N-2:0], in};
				if (bcnt < N-1)
					begin
					bcnt <= bcnt + 1;
					bcnt_end <= 0;
					end
				else
					begin
					bcnt <= 0;
					bcnt_end <= 1;
					end
				end
			else
				begin
				q <= q;
				bcnt <= bcnt;
				bcnt_end <= bcnt_end;
				end
		
		GET_PARITY:
			begin
			q <= q;
			bcnt <= 0;
			bcnt_end <= 0;
			end
				
		GET_STOP:
			begin
			q <= q;
			if (bcnt_en)
				if (bcnt < STOP)
						begin
						bcnt <= bcnt + 1;
						bcnt_end <= 0;
						end
					else
						begin
						bcnt <= 0;
						bcnt_end <= 1;
						end
			else
				begin
				bcnt <= bcnt;
				bcnt_end <= bcnt_end;
				end
			end
		
		endcase

//	Stop signal;
always@(posedge clk or negedge nrst)
	if (!nrst)
		last_stop <= 0;
	else
		if (bcnt_en)
			last_stop <= in;
		else
			last_stop <= last_stop;
			
always@(*)
	case (STOP)
		0:
			stop = (state == GET_STOP) & (bcnt == STOP) & (in);
		1:
			stop = (state == GET_STOP) & (bcnt == STOP) & (in) & (last_stop);
	endcase

//	Ready signal
always@(posedge clk or negedge nrst)
	if (!nrst)
		ready <= 0;
	else
		if (state == GET_STOP)
			if (bcnt_en)
				ready <= stop;
			else
				ready <= ready;
		else
			ready <= 0;
			

endmodule