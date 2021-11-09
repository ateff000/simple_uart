module FREQ_DIV 
(
	in_clk,
	nrst,
	out_clk
);

parameter F_IN = 50_000_000;
parameter F_OUT = 115_200;
parameter T = F_IN/F_OUT;
parameter LIM = T/2 - 1;
parameter N = $clog2(LIM);


input in_clk, nrst;


output reg out_clk;


reg	[N-1:0] cnt;


always@(posedge in_clk or negedge nrst)
	if(!nrst)
		begin
		cnt <= 0;
		out_clk <= 0;
		end
	else
		if (cnt < LIM)
			begin
			cnt <= cnt + 1;
			out_clk <= out_clk;
			end
		else
			begin
			cnt <= 0;
			out_clk <= ~out_clk;
			end


endmodule