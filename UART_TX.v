/*
start выставлять по переднему фронту. Если  будут проблемы, то можно добавить буфер, в который будут по заднему фронту писаться данные со входной шины. А уже из буфера встав
*/
module UART_TX
(
	//	Inputs
	clk,
	nrst,
	start,
	data,
	//	Outputs;
	q,
	ready
);

parameter N = 8;	// Word bit width;
parameter M = 3;	// Bit counter width;
parameter PARITY = 0;	
//	0 - none;
//	1 - even;
//	2 - odd;
//	3 - mark;
//	4 - space;
parameter STOP = 1;
//	0 - 1
//	1 - 2
localparam IDLE = 0, SET_START = 1, TX_DATA = 2, SET_PARITY = 3, SET_STOP = 4;

///	INPUTS
//	System;
input clk, nrst;
//	Strat command;
input start;
//	Input data bus;
input [N-1:0]	data;


///	OUTPUTS
output reg q;
output reg ready;


///	INTERNAL
//	Data register and bit counter;
reg	[N-1:0]	data_reg;
reg [M-1:0]	cnt;
reg 		cnt_end;
//	State machine;
reg  [2:0]	state, next_state;


///	WORK
//	State machine;
always@(*)
	case (state)
		IDLE:
			if (start)
				next_state = SET_START;
			else
				next_state = IDLE;

		SET_START:
			next_state = TX_DATA;
			
		TX_DATA:
			if (cnt_end)
				if (PARITY == 0)
					next_state = SET_STOP;
				else
					next_state = SET_PARITY;
			else
				next_state = TX_DATA;
			
		SET_PARITY:
			next_state = SET_STOP;
			
		SET_STOP:
			if (cnt_end)
				if (start)
					next_state = SET_START;
				else
					next_state = IDLE;
			else
				next_state = SET_STOP;
	endcase

always@(negedge clk or negedge nrst)
	if (!nrst)
		state <= 0;
	else
		state <= next_state;


//	Data register and bit counter;
always@(posedge clk or negedge nrst)
	if (!nrst)
		begin
		q <= 1;
		cnt <= 0;
		cnt_end <= 0;
		data_reg <= 0;
		end
	else
		case (state)
			IDLE:
				begin
				q <= 1;
				cnt <= 0;
				cnt_end <= 0;
				data_reg <= 0;
				end
				
			SET_START:
				begin
				q <= 0;
				cnt <= 0;
				cnt_end <= 0;
				data_reg <= data;
				end
				
			TX_DATA:
				begin
				q <= data_reg[N-1];
				data_reg <= {data_reg[N-2:0], 1'b0};
				if (cnt < N-1)
					begin
					cnt <= cnt + 1;
					cnt_end <= 0;
					end
				else
					begin
					cnt <= 0;
					cnt_end <= 1;
					end
				end
			
			SET_PARITY: // пока  не работает
				begin
				q <= 1;
				cnt <= 0;
				cnt_end <= 0;
				data_reg <= 0;
				end
				
			SET_STOP:
				begin
				q <= 1;
				data_reg <= 0;
				if (cnt < STOP)
					begin
					cnt <= cnt + 1;
					cnt_end <= 0;
					end
				else
					begin
					cnt <= 0;
					cnt_end <= 1;
					end
				end
		endcase

//	Ready flag
always@(negedge clk or negedge nrst)
	if (!nrst)
		ready <= 0;
	else
		case (STOP)
			0: ready <= (next_state == SET_STOP);
			1: ready <= (state == SET_STOP) & ~cnt_end;
		endcase
endmodule