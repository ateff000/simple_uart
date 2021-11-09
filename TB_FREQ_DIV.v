`timescale 1ns/100ps
module TB_FREQ_DIV;

reg in_clk, nrst;

wire out_clk;


FREQ_DIV #(
	.F_IN(50_000_000),
	.F_OUT(9600)
	)
	FREQ_DIV_INST
	(
	.in_clk(in_clk),
	.nrst(nrst),
	.out_clk(out_clk)
	);


initial
	begin
	in_clk = 0;
	nrst = 0;
	#100
	nrst = 1;
	end

always
	#10 in_clk = ~in_clk;
	
initial
	#1000000 $finish;


initial
	begin
	$dumpfile("out_freq_div.vcd");
	$dumpvars(0, TB_FREQ_DIV);
	$dumpvars(0, FREQ_DIV_INST);
	end


endmodule