`timescale 1ns/1ns
module top_tb();

reg sys_clk,rst_n;

wire 		GMII_GTXCLK,GMII_TXEN,GMII_TXER;
wire [ 7:0] GMII_TXD;

top top_m0(
	.sys_clk 		(sys_clk 		),
	.rst_n 			(rst_n 			),

	.GMII_GTXCLK	(GMII_GTXCLK	),
	.GMII_TXEN		(GMII_TXEN		),
	.GMII_TXER		(GMII_TXER		),
	.GMII_TXD		(GMII_TXD		)
	);

initial begin
	#0 sys_clk = 0; rst_n = 0;
	#60000 rst_n = 1;
end

always#18.5 sys_clk = ~sys_clk;

endmodule 