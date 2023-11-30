//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/12/28     meisq          1.0         Original
//*******************************************************************************/
module top(
//Differential system clock
    input                    sys_clk,
    output                   hdmi_clk,
    output[23:0]             hdmi_d,
    output                   hdmi_de,
    output                   hdmi_hs,
	output                   hdmi_vs,
	output					 hdmi_nreset,
    inout                    hdmi_scl,
    inout                    hdmi_sda   
);


wire                            video_clk;
wire                            clk_100mhz;
wire                            video_hs;
wire                            video_vs;
wire                            video_de;
wire[7:0]                       video_r;
wire[7:0]                       video_g;
wire[7:0]                       video_b;
wire                            pll_locked;
wire[9:0]                       lut_index;
wire[31:0]                      lut_data;
wire pll_9134_locked;
wire pll_iic_locked;
assign pll_locked = pll_9134_locked & pll_iic_locked;


assign hdmi_clk = video_clk;
assign hdmi_d = {video_r,video_g,video_b};
assign hdmi_de = video_de;
assign hdmi_hs = video_hs;
assign hdmi_vs = video_vs;
assign hdmi_nreset = pll_locked ;

color_bar hdmi_color_bar(
	.clk                     (video_clk                  ),
	.rst                     (1'b0                       ),
	.hs                      (video_hs                   ),
	.vs                      (video_vs                   ),
	.de                      (video_de                   ),
	.rgb_r                   (video_r                    ),
	.rgb_g                   (video_g                    ),
	.rgb_b                   (video_b                    )
);

Gowin_rPLL_9134 u_Gowin_rPLL_9134(
	.clkout(video_clk), //output clkout
	.lock(pll_9134_locked), //output lock
	.clkin(sys_clk) //input clkin
);
Gowin_rPLL_iic u_Gowin_rPLL_iic(
	.clkout(clk_100mhz), //output clkout
	.lock(pll_iic_locked), //output lock
	.clkin(sys_clk) //input clkin
);

//I2C master controller
i2c_config i2c_config_m0(
	.rst                        (~pll_locked              ),
	.clk                        (clk_100mhz               ),
	.clk_div_cnt                (16'd499                  ),
	.i2c_addr_2byte             (1'b0                     ),
	.lut_index                  (lut_index                ),
	.lut_dev_addr               (lut_data[31:24]          ),
	.lut_reg_addr               (lut_data[23:8]           ),
	.lut_reg_data               (lut_data[7:0]            ),
	.error                      (                         ),
	.done                       (                         ),
	.i2c_scl                    (hdmi_scl                 ),
	.i2c_sda                    (hdmi_sda                 )
);
//configure look-up table
lut_si9134 lut_si9134_m0(
	.lut_index                  (lut_index                ),
	.lut_data                   (lut_data                 )
); 
endmodule