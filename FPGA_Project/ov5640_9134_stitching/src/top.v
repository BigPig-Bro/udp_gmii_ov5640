module top(
	    input               clk
	,   input               rst_n

	,   output              cmos_scl
	,   inout               cmos_sda
	,   input               cmos_pclk
	,   input               cmos_vsync
	,   input               cmos_href
	,   input   [7:0]       cmos_db
	,   output              cmos_rst_n
	,   output              cmos_pwdn

	,   output              cmos1_scl
	,   inout               cmos1_sda
	,   input               cmos1_pclk
	,   input               cmos1_vsync
	,   input               cmos1_href
	,   input   [7:0]       cmos1_db
	,   output              cmos1_rst_n
	,   output              cmos1_pwdn

	,   output              cmos2_scl
	,   inout               cmos2_sda
	,   input               cmos2_pclk
	,   input               cmos2_vsync
	,   input               cmos2_href
	,   input   [7:0]       cmos2_db
	,   output              cmos2_rst_n
	,   output              cmos2_pwdn

	,   output              cmos3_scl
	,   inout               cmos3_sda
	,   input               cmos3_pclk
	,   input               cmos3_vsync
	,   input               cmos3_href
	,   input   [7:0]       cmos3_db
	,   output              cmos3_rst_n
	,   output              cmos3_pwdn

	,   output              cmos4_scl
	,   inout               cmos4_sda
	,   input               cmos4_pclk
	,   input               cmos4_vsync
	,   input               cmos4_href
	,   input   [7:0]       cmos4_db
	,   output              cmos4_rst_n
	,   output              cmos4_pwdn

	,   output [14-1:0]     ddr_addr
	,   output [3-1:0]      ddr_bank
	,   output              ddr_cs
	,   output              ddr_ras
	,   output              ddr_cas
	,   output              ddr_we
	,   output              ddr_ck
	,   output              ddr_ck_n
	,   output              ddr_cke
	,   output              ddr_odt
	,   output              ddr_reset_n
	,   output [2-1:0]      ddr_dm
	,   inout [16-1:0]      ddr_dq
	,   inout [2-1:0]       ddr_dqs
	,   inout [2-1:0]       ddr_dqs_n

    // ,   output              hdmi_clk
    // ,   output[23:0]        hdmi_d
    // ,   output              hdmi_de
    // ,   output              hdmi_hs
    // ,   output              hdmi_vs
    // ,   output              hdmi_nreset
    // ,   inout               hdmi_scl
    // ,   inout               hdmi_sda   

    ,   output              O_tmds_clk_p
    ,   output              O_tmds_clk_n
    ,   output  [2:0]       O_tmds_data_p
    ,   output  [2:0]       O_tmds_data_n
);

//memory interface
wire                   memory_clk           ;
wire                   dma_clk         	    ;
wire                   DDR_pll_lock         ;
wire                   cmd_ready            ;
wire[2:0]              cmd                  ;
wire                   cmd_en               ;
wire[5:0]              app_burst_number     ;
wire[ADDR_WIDTH-1:0]   addr                 ;
wire                   wr_data_rdy          ;
wire                   wr_data_en           ;
wire                   wr_data_end          ;
wire[DATA_WIDTH-1:0]   wr_data              ;
wire[DATA_WIDTH/8-1:0] wr_data_mask         ;
wire                   rd_data_valid        ;
wire                   rd_data_end          ;
wire[DATA_WIDTH-1:0]   rd_data              ;   
wire                   init_calib_complete  ;

//According to IP parameters to choose
`define	    WR_VIDEO_WIDTH_16
`define	DEF_WR_VIDEO_WIDTH 16

`define	    RD_VIDEO_WIDTH_16
`define	DEF_RD_VIDEO_WIDTH 16

`define	USE_THREE_FRAME_BUFFER

`define	DEF_ADDR_WIDTH 28 
`define	DEF_SRAM_DATA_WIDTH 128
//
//=========================================================
//SRAM parameters
parameter ADDR_WIDTH          = `DEF_ADDR_WIDTH;    //存储单元是byte，总容量=2^27*16bit = 2Gbit,增加1位rank地址，{rank[0],bank[2:0],row[13:0],cloumn[9:0]}
parameter DATA_WIDTH          = `DEF_SRAM_DATA_WIDTH;   //与生成DDR3IP有关，此ddr3 2Gbit, x16， 时钟比例1:4 ，则固定128bit
parameter WR_VIDEO_WIDTH      = `DEF_WR_VIDEO_WIDTH;  
parameter RD_VIDEO_WIDTH      = `DEF_RD_VIDEO_WIDTH;  

//-------------------
//syn_code
wire                        syn_off0_re;  // ofifo read enable signal
wire                        syn_off0_vs;
wire                        syn_off0_hs;

wire                        off0_syn_de  ;
wire [RD_VIDEO_WIDTH-1:0]   off0_syn_data;

wire[15:0]                  cmos_16bit_data;
wire                        cmos_16bit_clk;

wire[9:0]                   lut_index;
wire[31:0]                  lut_data;

wire                        cmos_frame_clk  ;
wire                        cmos_frame_vsync;
wire                        cmos_frame_href ;
wire                        cmos_frame_de   ;
wire    [23:0]              cmos_frame_data ;

wire                        cmos1_frame_clk  ;
wire                        cmos1_frame_vsync;
wire                        cmos1_frame_href ;
wire                        cmos1_frame_de   ;
wire    [23:0]              cmos1_frame_data ;

wire                        cmos2_frame_clk  ;
wire                        cmos2_frame_vsync;
wire                        cmos2_frame_href ;
wire                        cmos2_frame_de   ;
wire    [23:0]              cmos2_frame_data ;

wire                        cmos3_frame_clk  ;
wire                        cmos3_frame_vsync;
wire                        cmos3_frame_href ;
wire                        cmos3_frame_de   ;
wire    [23:0]              cmos3_frame_data ;

wire                        cmos4_frame_clk  ;
wire                        cmos4_frame_vsync;
wire                        cmos4_frame_href ;
wire                        cmos4_frame_de   ;
wire    [23:0]              cmos4_frame_data ;

wire                        serial_clk      ;
wire                        video_clk       ;
wire                        TMDS_lock       ;
wire                        video_vsync     ;
wire                        video_href      ;
wire                        video_de        ;
wire    [23:0]              video_data      ;

wire                        ila_clk         ;


// //generate the CMOS sensor clock and the SDRAM controller clock
// cmos_pll cmos_pll_m0(
// 	.clkin                  (clk                    ),
// 	.clkout                 (cmos_clk 	            )
// );

mem_pll mem_pll_m0(
	.clkin                  (clk                    ),
	.clkout                 (memory_clk 	        ),
    .clkoutd                (ila_clk                ),
	.lock 				    (DDR_pll_lock 		    )
);
    
// Gowin_rPLL_lcd u_Gowin_rPLL_lcd(
// 	.clkout                 (video_clk              ), //output clkout
// 	.lock                   (                       ), //output lock
// 	.clkin                  (clk                    ) //input clkin
// );

TMDS_rPLL u_TMDS_rPLL(
    .clkout                 (serial_clk             ), //output clkout
    .lock                   (TMDS_lock              ), //output lock
    .clkin                  (clk                    ) //input clkin
);

Gowin_CLKDIV u_Gowin_CLKDIV(
    .clkout                 (video_clk              ), //output clkout
    .hclkin                 (serial_clk             ), //input hclkin
    .resetn                 (TMDS_lock              ) //input resetn
);

//IIC 延时约1s复位
reg [31:0] clk_delay = 0;
wire iic_rst = clk_delay != 65_000_000;
always@(posedge video_clk, negedge rst_n) begin
    if (!rst_n) begin
        clk_delay = 0;
    end
    else begin 
        clk_delay <=( clk_delay == 65_000_000)? clk_delay : clk_delay + 1;
    end
end


iic_ctrl#(
    .CLK_FRE                (27             ),
    .IIC_FRE                (100            ),
    .IIC_SLAVE_REG_EX       (1              ),
    .IIC_SLAVE_ADDR_EX      (0              ),
    .IIC_SLAVE_ADDR         (16'h78         ),
    .INIT_CMD_NUM           (303            ),
    .PIC_PATH               ("init_640x360.txt")
)iic_ctrl_m0(
    .clk                    (clk            ),
    .rst_n                  (~iic_rst       ),
    .iic_scl                (cmos_scl       ),
    .iic_sda                (cmos_sda       )
);

iic_ctrl#(
    .CLK_FRE                (27             ),
    .IIC_FRE                (100            ),
    .IIC_SLAVE_REG_EX       (1              ),
    .IIC_SLAVE_ADDR_EX      (0              ),
    .IIC_SLAVE_ADDR         (16'h78         ),
    .INIT_CMD_NUM           (303            ),
    .PIC_PATH               ("init_640x360.txt")
)iic_ctrl_m1(
    .clk                    (clk            ),
    .rst_n                  (~iic_rst       ),
    .iic_scl                (cmos1_scl      ),
    .iic_sda                (cmos1_sda      )
);

iic_ctrl#(
    .CLK_FRE                (27             ),
    .IIC_FRE                (100            ),
    .IIC_SLAVE_REG_EX       (1              ),
    .IIC_SLAVE_ADDR_EX      (0              ),
    .IIC_SLAVE_ADDR         (16'h78         ),
    .INIT_CMD_NUM           (303            ),
    .PIC_PATH               ("init_640x240.txt")
)iic_ctrl_m2(
    .clk                    (clk            ),
    .rst_n                  (~iic_rst       ),
    .iic_scl                (cmos2_scl      ),
    .iic_sda                (cmos2_sda      )
);

iic_ctrl#(
    .CLK_FRE                (27             ),
    .IIC_FRE                (100            ),
    .IIC_SLAVE_REG_EX       (1              ),
    .IIC_SLAVE_ADDR_EX      (0              ),
    .IIC_SLAVE_ADDR         (16'h78         ),
    .INIT_CMD_NUM           (303            ),
    .PIC_PATH               ("init_640x240.txt")
)iic_ctrl_m3(
    .clk                    (clk            ),
    .rst_n                  (~iic_rst       ),
    .iic_scl                (cmos3_scl      ),
    .iic_sda                (cmos3_sda      )
);

iic_ctrl#(
    .CLK_FRE                (27             ),
    .IIC_FRE                (100            ),
    .IIC_SLAVE_REG_EX       (1              ),
    .IIC_SLAVE_ADDR_EX      (0              ),
    .IIC_SLAVE_ADDR         (16'h78         ),
    .INIT_CMD_NUM           (303            ),
    .PIC_PATH               ("init_640x240.txt")
)iic_ctrl_m4(
    .clk                    (clk            ),
    .rst_n                  (~iic_rst       ),
    .iic_scl                (cmos4_scl      ),
    .iic_sda                (cmos4_sda      )
);

ov5640_capture_data  u_ov5640_capture_data(
    .rst_n                      (rst_n              ), 

    .cam_pclk                   (cmos_pclk          ), 
    .cam_vsync                  (cmos_vsync         ), 
    .cam_href                   (cmos_href          ), 
    .cam_data                   (cmos_db            ), 
    .cam_rst_n                  (cmos_rst_n         ), 
    .cam_pwdn                   (cmos_pwdn          ), 

    .cmos_frame_clk             (cmos_frame_clk     ), 
	.cmos_frame_vsync           (cmos_frame_vsync   ), 
    .cmos_frame_href            (cmos_frame_href    ), 
    .cmos_frame_de              (cmos_frame_de      ),   
    .cmos_frame_data            (cmos_frame_data    )
);

ov5640_capture_data  u_ov5640_capture_data1(
    .rst_n                      (rst_n              ), 

    .cam_pclk                   (cmos1_pclk         ), 
    .cam_vsync                  (cmos1_vsync        ), 
    .cam_href                   (cmos1_href         ), 
    .cam_data                   (cmos1_db           ), 
    .cam_rst_n                  (cmos1_rst_n        ), 
    .cam_pwdn                   (cmos1_pwdn         ), 

    .cmos_frame_clk             (cmos1_frame_clk    ), 
	.cmos_frame_vsync           (cmos1_frame_vsync  ), 
    .cmos_frame_href            (cmos1_frame_href   ), 
    .cmos_frame_de              (cmos1_frame_de     ),   
    .cmos_frame_data            (cmos1_frame_data   )
);

ov5640_capture_data  u_ov5640_capture_data2(
    .rst_n                      (rst_n              ), 

    .cam_pclk                   (cmos2_pclk         ), 
    .cam_vsync                  (cmos2_vsync        ), 
    .cam_href                   (cmos2_href         ), 
    .cam_data                   (cmos2_db           ), 
    .cam_rst_n                  (cmos2_rst_n        ), 
    .cam_pwdn                   (cmos2_pwdn         ), 

    .cmos_frame_clk             (cmos2_frame_clk    ), 
	.cmos_frame_vsync           (cmos2_frame_vsync  ), 
    .cmos_frame_href            (cmos2_frame_href   ), 
    .cmos_frame_de              (cmos2_frame_de     ),   
    .cmos_frame_data            (cmos2_frame_data   )
);

ov5640_capture_data  u_ov5640_capture_data3(
    .rst_n                      (rst_n              ), 

    .cam_pclk                   (cmos3_pclk         ), 
    .cam_vsync                  (cmos3_vsync        ), 
    .cam_href                   (cmos3_href         ), 
    .cam_data                   (cmos3_db           ), 
    .cam_rst_n                  (cmos3_rst_n        ), 
    .cam_pwdn                   (cmos3_pwdn         ), 

    .cmos_frame_clk             (cmos3_frame_clk    ), 
	.cmos_frame_vsync           (cmos3_frame_vsync  ), 
    .cmos_frame_href            (cmos3_frame_href   ), 
    .cmos_frame_de              (cmos3_frame_de     ),   
    .cmos_frame_data            (cmos3_frame_data   )
);

ov5640_capture_data  u_ov5640_capture_data4(
    .rst_n                      (rst_n              ), 

    .cam_pclk                   (cmos4_pclk         ), 
    .cam_vsync                  (cmos4_vsync        ), 
    .cam_href                   (cmos4_href         ), 
    .cam_data                   (cmos4_db           ), 
    .cam_rst_n                  (cmos4_rst_n        ), 
    .cam_pwdn                   (cmos4_pwdn         ), 

    .cmos_frame_clk             (cmos4_frame_clk    ), 
	.cmos_frame_vsync           (cmos4_frame_vsync  ), 
    .cmos_frame_href            (cmos4_frame_href   ), 
    .cmos_frame_de              (cmos4_frame_de     ),   
    .cmos_frame_data            (cmos4_frame_data   )
);

video_stiching_top u_video_stiching_top( 
//----------------------------------------------------
// Cmos port
	 	.cmos0_clk				(cmos_frame_clk     )
    ,   .cmos0_vsync 			(cmos_frame_vsync   )    
    ,   .cmos0_href  			(cmos_frame_href    )    
    ,   .cmos0_clken 			(cmos_frame_de      )    
    ,   .cmos0_data  			({cmos_frame_data[7-:8],cmos_frame_data[15-:8],cmos_frame_data[23-:8]})    

	,	.cmos1_clk				(cmos1_frame_clk     )
    ,   .cmos1_vsync 			(cmos1_frame_vsync   )    
    ,   .cmos1_href  			(cmos1_frame_href    )    
    ,   .cmos1_clken 			(cmos1_frame_de      )    
    ,   .cmos1_data  			({cmos1_frame_data[7-:8],cmos1_frame_data[15-:8],cmos1_frame_data[23-:8]})    
    
	,	.cmos2_clk				(cmos2_frame_clk     )
    ,   .cmos2_vsync 			(cmos2_frame_vsync   )    
    ,   .cmos2_href  			(cmos2_frame_href    )    
    ,   .cmos2_clken 			(cmos2_frame_de      )    
    ,   .cmos2_data  			({cmos2_frame_data[7-:8],cmos2_frame_data[15-:8],cmos2_frame_data[23-:8]})   
    
	,	.cmos3_clk				(cmos3_frame_clk     )
    ,   .cmos3_vsync 			(cmos3_frame_vsync   )    
    ,   .cmos3_href  			(cmos3_frame_href    )    
    ,   .cmos3_clken 			(cmos3_frame_de      )    
    ,   .cmos3_data  			({cmos3_frame_data[7-:8],cmos3_frame_data[15-:8],cmos3_frame_data[23-:8]})  
    
	,	.cmos4_clk				(cmos4_frame_clk     )
    ,   .cmos4_vsync 			(cmos4_frame_vsync   )    
    ,   .cmos4_href  			(cmos4_frame_href    )    
    ,   .cmos4_clken 			(cmos4_frame_de      )    
    ,   .cmos4_data  			({cmos4_frame_data[7-:8],cmos4_frame_data[15-:8],cmos4_frame_data[23-:8]})  

//----------------------------------------------------
// Video port
    ,   .video_clk              (video_clk          )
    ,   .video_vsync            (video_vsync        )
    ,   .video_href             (video_href         )
    ,   .video_de               (video_de           )
    ,   .video_data             (video_data         )

//----------------------------------------------------
// DDR native port
    ,   .ref_clk                (clk                )
    ,   .sys_rst_n              (rst_n              )
    ,   .init_calib_complete    (init_calib_complete)
    ,   .c0_sys_clk             (memory_clk         )
    ,   .c0_sys_clk_locked      (DDR_pll_lock       )
    ,   .ddr_addr               (ddr_addr           )
    ,   .ddr_bank               (ddr_bank           )
    ,   .ddr_cs                 (ddr_cs             )
    ,   .ddr_ras                (ddr_ras            )
    ,   .ddr_cas                (ddr_cas            )
    ,   .ddr_we                 (ddr_we             )
    ,   .ddr_ck                 (ddr_ck             )
    ,   .ddr_ck_n               (ddr_ck_n           )
    ,   .ddr_cke                (ddr_cke            )
    ,   .ddr_odt                (ddr_odt            )
    ,   .ddr_reset_n            (ddr_reset_n        )
    ,   .ddr_dm                 (ddr_dm             )
    ,   .ddr_dq                 (ddr_dq             )
    ,   .ddr_dqs                (ddr_dqs            )
    ,   .ddr_dqs_n              (ddr_dqs_n          )
);

//---------------------------------------------------
//Sil9134

// wire[9:0]           lut_index;
// wire[31:0]          lut_data;
// wire                clk_100mhz;
// wire                pll_iic_locked;


// Gowin_rPLL_iic u_Gowin_rPLL_iic(
// 	.clkout     (clk_100mhz), //output clkout
// 	.lock       (pll_iic_locked), //output lock
// 	.clkin      (clk) //input clkin
// );

// //I2C master controller
// i2c_config i2c_config_m0(
// 	.rst                        (~pll_iic_locked          ),
// 	.clk                        (clk_100mhz               ),
// 	.clk_div_cnt                (16'd499                  ),
// 	.i2c_addr_2byte             (1'b0                     ),
// 	.lut_index                  (lut_index                ),
// 	.lut_dev_addr               (lut_data[31:24]          ),
// 	.lut_reg_addr               (lut_data[23:8]           ),
// 	.lut_reg_data               (lut_data[7:0]            ),
// 	.error                      (                         ),
// 	.done                       (                         ),
// 	.i2c_scl                    (hdmi_scl                 ),
// 	.i2c_sda                    (hdmi_sda                 )
// );
// //configure look-up table
// lut_si9134 lut_si9134_m0(
// 	.lut_index                  (lut_index                ),
// 	.lut_data                   (lut_data                 )
// ); 


// assign  hdmi_clk        =   video_clk       ;   
// assign  hdmi_vs         =   video_vsync     ;   
// assign  hdmi_hs         =   video_href      ;   
// assign  hdmi_de         =   video_de        ;   
// assign  hdmi_d          =   video_data      ;   
// assign  hdmi_nreset     =   pll_iic_locked  ;


//==============================================================================
//TMDS TX(HDMI4)
DVI_TX_Top DVI_TX_Top_inst(
    .I_rst_n        (TMDS_lock          ),  //asynchronous reset, low active
    .I_serial_clk   (serial_clk         ),

    .I_rgb_clk      (video_clk          ),  //pixel clock
    .I_rgb_vs       (video_vsync        ), 
    .I_rgb_hs       (video_href         ),    
    .I_rgb_de       (video_de           ), 
    .I_rgb_r        (video_data[16+:8]  ),  //tp0_data_r
    .I_rgb_g        (video_data[ 8+:8]  ),  
    .I_rgb_b        (video_data[ 0+:8]  ),  

    .O_tmds_clk_p   (O_tmds_clk_p       ),
    .O_tmds_clk_n   (O_tmds_clk_n       ),
    .O_tmds_data_p  (O_tmds_data_p      ),  //{r,g,b}
    .O_tmds_data_n  (O_tmds_data_n      )
);

endmodule
