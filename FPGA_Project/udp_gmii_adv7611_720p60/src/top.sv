module top(
	input 			sys_clk,
	input 			rst_n,
	input 			grey_mode,slow_mode,

	// 视频源输入
    output          adv7611_rst_n,
    inout           adv7611_sda,
    inout           adv7611_scl,
    input           adv7611_hs,
    input           adv7611_vs,
    input           adv7611_de,
    input           adv7611_pclk,
    input  [15:0]   adv7611_data,   
    
    //环出模块
    output 			hdmi_clk_p	,hdmi_clk_n	,
 	output 	[2:0]	hdmi_data_p,hdmi_data_n,

	// 监测端口
	// output reg [23:0] rd_cnt,wr_cnt,
	output 			ws2812_io,

	// GMII输出
	output 			GMII_RST_N,
	output 			GMII_GTXCLK,
	output 			GMII_TXEN,
	output 			GMII_TXER,
	output 	[7:0]	GMII_TXD
	);
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      接收模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
assign adv7611_rst_n = rst_n;

wire[9:0]    adv7611_lut_index;
wire[31:0]   adv7611_lut_data;
wire 		 cfg_done,cfg_error;
i2c_config i2c_config_m0(
  .rst_n              (rst_n                      ),
  .clk                (sys_clk                    ),
  .clk_div_cnt        (16'd270                    ),
  .i2c_addr_2byte     (1'b0                       ),
  .lut_index          (adv7611_lut_index          ),
  .lut_dev_addr       (adv7611_lut_data[31:24]    ),
  .lut_reg_addr       (adv7611_lut_data[23:8]     ),
  .lut_reg_data       (adv7611_lut_data[7:0]      ),
  .error              (cfg_error                  ),
  .done               (cfg_done                   ),
  .i2c_scl            (adv7611_scl                ),
  .i2c_sda            (adv7611_sda                )
);

lut_adv7611 lut_adv7611_m0(
  .lut_index          (adv7611_lut_index          ),
  .lut_data           (adv7611_lut_data           )
); 


wire [ 9:0] video_rd_data;
wire 		video_rd_en;

reg  			test_de_r,test_de;
reg  			test_hs_r,test_hs;
reg  			test_vs_r,test_vs;
reg  			test_de_y;

reg 	[15:0] 	test_data_r,test_data,test_data_y_r;
reg  	[ 7:0]  test_data_y; // RGB565 -> 灰度
reg  	[10:0] 	test_x;
reg  	[ 1:0]	run_mode; //[0] 0 RGB 1 GREY [1] 0 30fps 1 60fps
reg  			test_de_slow_on,test_de_slow;
always@(posedge adv7611_pclk)begin
	test_x <= test_de ? test_x + 1 : 11'd0;

	test_de_r <= adv7611_de;
	test_de <= test_de_r ;
	test_hs_r <= adv7611_hs;
	test_hs <= test_hs_r;
	test_vs_r <= adv7611_vs;
	test_vs <= test_vs_r;
	test_data_r <= adv7611_de? adv7611_data : 16'd0;

	//模式切换 
	run_mode[0] <= !rst_n? 0 : (!test_vs & test_vs_r )? grey_mode : run_mode[0]; // 0 RGB 1 GREY
	run_mode[1] <= !rst_n? 0 : (!test_vs & test_vs_r )? slow_mode : run_mode[1]; // 0 60fps 1 30fps

	test_data_y_r <= adv7611_data[15:11] * 76 + adv7611_data[10: 5] * 75 + adv7611_data[ 4: 0] * 29;
	test_data_y <= adv7611_de?  test_data_y_r[12:5] : test_data_y;

	test_de_y <= test_de_r ? !test_de_y :  'd0;

	test_de_slow_on <= !rst_n? 0 : (!test_vs & test_vs_r )? ~test_de_slow_on : test_de_slow_on;
	test_de_slow <=  test_de_slow_on ? test_de_r : 'd0;

	test_data <= test_de_r ?   run_mode[0]?  {test_data_y,test_data[15:8]}: adv7611_data : 16'H0000;
end

wire video_rd_rdy,video_de;

assign video_de = run_mode == 2'b00 ? test_de 		| (!test_vs & test_vs_r): 
				  run_mode == 2'b01 ? test_de_y 	| (!test_vs & test_vs_r): 
				  run_mode == 2'b10 ? test_de_slow  | (!test_vs & test_vs_r & test_de_slow_on):
				  					  (test_de_slow & test_de_y ) | (!test_vs & test_vs_r & test_de_slow_on); // run_mode == 2'b11 


video_recive video_recive_m0(
	// .Reset  			('b0        		 		),
	
	.video_clk 			(adv7611_pclk				),
	.video_de 			(video_de  					),
	.video_data 		({1'b1, (!test_vs & test_vs_r), test_data[15:8],1'b1, (!test_vs & test_vs_r), test_data[7:0]}),
	.video_rd_clk 		(GMII_GTXCLK 				),
	.video_rd_rdy 		(video_rd_rdy 				),
	.video_rd_en 		(video_rd_en 				),
	.video_rd_data 		(video_rd_data 				)
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

	.send_start 		(send_start 		),
	.grey_mode 			(grey_mode 			),
	.fifo_send_req 		(video_rd_en 		), 		
	.fifo_send_data 	(video_rd_data 		), 		

	.GMII_GTXCLK 		(GMII_GTXCLK 		),
	.GMII_TXD 			(GMII_TXD 			),
	.GMII_TXEN 			(GMII_TXEN 			),
	.GMII_TXER 			(GMII_TXER 			)
	);

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      环出模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
DVI_TX_Top your_instance_name(
	.I_rst_n			(rst_n						), //input I_rst_n
	.I_rgb_clk			(adv7611_pclk				), //input I_rgb_clk
	.I_rgb_vs			(adv7611_vs					), //input I_rgb_vs
	.I_rgb_hs			(adv7611_hs					), //input I_rgb_hs
	.I_rgb_de			(adv7611_de					), //input I_rgb_de
	.I_rgb_r			({adv7611_data[15:11],3'd0}	), //input [7:0] I_rgb_r
	.I_rgb_g			({adv7611_data[10: 5],2'd0}	), //input [7:0] I_rgb_g
	.I_rgb_b			({adv7611_data[ 4: 0],3'd0}	), //input [7:0] I_rgb_b
	.O_tmds_clk_p		(hdmi_clk_p					), //output O_tmds_clk_p
	.O_tmds_clk_n		(hdmi_clk_n					), //output O_tmds_clk_n
	.O_tmds_data_p		(hdmi_data_p				), //output [2:0] O_tmds_data_p
	.O_tmds_data_n		(hdmi_data_n				) //output [2:0] O_tmds_data_n
);

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      监测模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////\
// always@(posedge GMII_GTXCLK) 	rd_cnt 	<= (!rst_n | adv7611_vs)? 0 : video_rd_en? rd_cnt + 1 :rd_cnt ;
// always@(posedge adv7611_pclk) 	wr_cnt 	<= (!rst_n | adv7611_vs)? 0 : adv7611_de? wr_cnt + 1 :wr_cnt ;


ws2812_top ws2812_top_m0(
    .clk    	(sys_clk            				),
    .key    	({cfg_done,cfg_error}            	),
    .WS2812_Di 	(ws2812_io   						)
);

endmodule