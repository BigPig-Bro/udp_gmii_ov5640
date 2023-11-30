module top(
	input 			sys_clk,
	input 			rst_n,grey_mode,

	// 视频源输入
	// input 			video_clk, 
	// input 			video_rst, 
	// input 			video_de, 
	// input 	[15:0]	video_data0, 
	// input 	[15:0]	video_data1, 

	// 串口监测端口
	output reg [23:0] rd_cnt,wr_cnt,

	// GMII输出
	output 			GMII_RST_N,
	output 			GMII_GTXCLK,
	output 			GMII_TXEN,
	output 			GMII_TXER,
	output 	[7:0]	GMII_TXD
	);

//此处使用RGB模拟一个1080P@30的时序
wire video_clk;
video_pll video_pll_m0(
	.clkin 	(sys_clk 		),
	.clkout (video_clk 		)
);

//============ 720P60 ==================
//产生标准空白RGB视频流
wire 		video_rst,video_de;
wire [10:0] video_x;
wire [15:0] video_data;
rgb_timing rgb_timing_m0(
	.rgb_clk	(video_clk			),	
	.rgb_rst_n	(rst_n				),	
	.rgb_hs		(					),
	.rgb_vs		(video_rst			),
	.rgb_de		(video_de			),
	.rgb_x		(video_x			),
	.rgb_y		(   				)
	);

assign video_data = video_de ? 
video_x < (1280  / 16  *  1)? 16'B10000_000000_00000: video_x < (1280  / 16  *  2)? 16'B01000_000000_00000:
video_x < (1280  / 16  *  3)? 16'B00100_000000_00000:	video_x < (1280  / 16  *  4)? 16'B00010_000000_00000:
video_x < (1280  / 16  *  5)? 16'B00001_000000_00000:	video_x < (1280  / 16  *  6)? 16'B00000_100000_00000:

video_x < (1280  / 16  *  7)? 16'B00000_010000_00000:	video_x < (1280  / 16  *  8)? 16'B00000_001000_00000:
video_x < (1280  / 16  *  9)? 16'B00000_000100_00000:	video_x < (1280  / 16  * 10)? 16'B00000_000010_00000:
video_x < (1280  / 16  * 11)? 16'B00000_000001_00000:	video_x < (1280  / 16  * 12)? 16'B00000_000000_10000:

video_x < (1280  / 16  * 13)? 16'B00000_000000_01000:	video_x < (1280  / 16  * 14)? 16'B00000_000000_00100:
video_x < (1280  / 16  * 15)? 16'B00000_000000_00010:				  			  16'B00000_000000_00001
: 16'H0000;

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      接收模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
reg  			test_de_r,test_de;
// reg  			test_hs_r,test_hs;
reg  			test_vs_r,test_vs;
reg  			test_de_y;

reg 	[15:0] 	test_data_r,test_data,test_data_y_r;
reg  	[ 7:0]  test_data_y; // RGB565 -> 灰度
reg  	[10:0] 	test_x;
reg  			run_mode; // 0 RGB 1 GREY
always@(posedge video_clk)begin
	test_x <= test_de ? test_x + 1 : 11'd0;

	test_de_r <= video_de;
	test_de <= test_de_r;
	// test_hs_r <= adv7611_hs;
	// test_hs <= test_hs_r;
	test_vs_r <= video_rst;
	test_vs <= test_vs_r;
	test_data_r <= video_de? video_data : 16'd0;

	//RGB 0 GREY 1 模式切换 
	run_mode <= !rst_n? 0 : (!test_vs & test_vs_r )? grey_mode : run_mode; // 0 RGB 1 GREY

	test_data_y_r <= video_data[15:11] * 76 + video_data[10: 5] * 75 + video_data[ 4: 0] * 29;
	test_data_y <= video_de?  test_data_y_r[12:5] : test_data_y;

	test_de_y <= test_de_r ? !test_de_y : 'd0;

	test_data <= test_de_r ?   run_mode?  {test_data_y,test_data[15:8]}: video_data
				// test_x < (1280  / 16  *  1)? 16'B10000_000000_00000: test_x < (1280  / 16  *  2)? 16'B01000_000000_00000:
				// test_x < (1280  / 16  *  3)? 16'B00100_000000_00000: test_x < (1280  / 16  *  4)? 16'B00010_000000_00000:
				// test_x < (1280  / 16  *  5)? 16'B00001_000000_00000: test_x < (1280  / 16  *  6)? 16'B00000_100000_00000:
				// test_x < (1280  / 16  *  7)? 16'B00000_010000_00000: test_x < (1280  / 16  *  8)? 16'B00000_001000_00000:
				// test_x < (1280  / 16  *  9)? 16'B00000_000100_00000: test_x < (1280  / 16  * 10)? 16'B00000_000010_00000:
				// test_x < (1280  / 16  * 11)? 16'B00000_000001_00000: test_x < (1280  / 16  * 12)? 16'B00000_000000_10000:
				// test_x < (1280  / 16  * 13)? 16'B00000_000000_01000: test_x < (1280  / 16  * 14)? 16'B00000_000000_00100:
				// test_x < (1280  / 16  * 15)? 16'B00000_000000_00010:				  			  16'B00000_000000_00001
				: 16'H0000;
end

wire [ 7:0] video_rd_data;
wire 		video_rd_en;

video_recive video_recive_m0(
	.Reset  			(video_rst								),
	
	.video_clk 			(video_clk 								),
	.video_de 			(run_mode? test_de_y : test_de 			),
	 .video_data 		(test_data	 							),	

	.video_rd_clk 		(GMII_GTXCLK 							),
	.video_rd_rdy 		(video_rd_rdy 							),
	.video_rd_en 		(video_rd_en 							),
	.video_rd_data 		(video_rd_data 							)
	);

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      压缩模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//未使用

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      发送模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
parameter DATA_SIZE = 16'D1442; // 2字节编号 + 1440字节数据
assign GMII_RST_N = rst_n;

GMII_pll GMII_pll_m0(
	.clkin 		(sys_clk 		), 
	.clkout  	(GMII_GTXCLK 	) // 125MHz
	);

wire send_start;
assign send_start   	= video_rd_rdy; // video_rd_num >= 1440;//(DATA_SIZE - 2); //当存满的数据足够一次发送，就开始发送(-2 编号字节) 
GMII_send #(
	.BOARD_MAC 	(48'h00_11_22_33_44_55 			),//开发板MAC地址
	.BOARD_IP 	({8'd192,8'd168,8'd2,8'd123}	),//开发板IP地址
	.BOARD_PORT (16'd8000 						),
	.DES_MAC 	(48'hff_ff_ff_ff_ff_ff 			),//目的MAC地址
	.DES_IP 	({8'd192,8'd168,8'd2,8'd102} 	),//目的IP地址
	.DES_PORT 	(16'd8001 						), //DES_PORT 
	.DATA_SIZE	(DATA_SIZE 						) //数据包长度 50~1500 B
	)GMII_send_m0(
	.rst_n 				(rst_n 				),

	.sys_clk 			(sys_clk 			),
	.frame_rst 			(video_rst 			),
	.run_mode 			(run_mode 			),

	.send_start 		(send_start 		),
	.fifo_send_req 		(video_rd_en 		), 		
	.fifo_send_data 	(video_rd_data 		), 		

	.GMII_GTXCLK 		(GMII_GTXCLK 		),
	.GMII_TXD 			(GMII_TXD 			),
	.GMII_TXEN 			(GMII_TXEN 			),
	.GMII_TXER 			(GMII_TXER 			)
	);
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      监测模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
always@(posedge GMII_GTXCLK) rd_cnt <=(!rst_n | video_rst)? 0 : video_rd_en? rd_cnt + 1 :rd_cnt ;
always@(posedge video_clk) wr_cnt 	<=(!rst_n | video_rst)? 0 : video_de? wr_cnt + 1 :wr_cnt ;


endmodule