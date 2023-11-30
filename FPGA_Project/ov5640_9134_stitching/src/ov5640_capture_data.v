

module  ov5640_capture_data(
    input                   rst_n           , 

    input                   cam_pclk        , 
    input                   cam_vsync       , 
    input                   cam_href        , 
    input        [7:0]      cam_data        , 
    output                  cam_rst_n       , 
    output                  cam_pwdn        , 

    output                  cmos_frame_clk,   
    output                  cmos_frame_ce,    

	output                  cmos_frame_vsync, 
    output                  cmos_frame_href , 
    output                  cmos_frame_de ,   
    output       [23:0]     cmos_frame_data,   

    output  reg  [11:0]     x_cnt = 0,
    output  reg  [11:0]     y_cnt = 0
);


localparam  WAIT_FRAME = 4'd10  ;

//reg define
reg          rst_n_d0 =1;
reg          rst_n_syn =1;
reg          cam_vsync_d0 ;
reg          cam_vsync_d1 ;
reg          cam_href_d0 ;
reg          cam_href_d1 ;
reg   [3:0]  cmos_ps_cnt ;
reg          wait_done ;
reg          byte_flag ;
reg   [7:0]  cam_data_d0 ;
reg  [15:0]  cmos_data_16b ;
reg          byte_flag_d0 ;

//wire define
wire  pos_vsync ;

//*****************************************************
//**                    main code
//*****************************************************

assign  pos_vsync  = (~cam_vsync_d1) & cam_vsync_d0 ;

assign  cam_rst_n = 1'b1;

assign  cam_pwdn  = 1'b0;

assign  cmos_frame_clk   = cam_pclk;
assign  cmos_frame_ce    = wait_done  ?  (byte_flag_d0 & cmos_frame_href) || (!cmos_frame_href) : 1'b0;
assign  cmos_frame_vsync = wait_done  ?  !cam_vsync_d1  :  1'b0;
assign  cmos_frame_href  = wait_done  ?  cam_href_d1   :  1'b0;
assign  cmos_frame_de    = cmos_frame_href & cmos_frame_ce;
assign  cmos_frame_data  = wait_done  ?
	{ cmos_data_16b[15:11],3'd0 , cmos_data_16b[10:5],2'd0 , cmos_data_16b[4:0],3'd0 }
	:  24'd0;

always @(posedge cam_pclk or negedge rst_n) begin
    if(!rst_n) begin
        rst_n_d0 <= 1'b0;
        rst_n_d0 <= 1'b0;
    end
    else begin
        rst_n_d0  <= 1'b1;
        rst_n_syn <= rst_n_d0;
    end
end

always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn) begin
        cam_vsync_d0 <= 1'b0;
        cam_vsync_d1 <= 1'b0;

        cam_href_d0 <= 1'b0;
        cam_href_d1 <= 1'b0;
    end
    else begin
        cam_vsync_d0 <= cam_vsync;
        cam_vsync_d1 <= cam_vsync_d0;

        cam_href_d0 <= cam_href;
        cam_href_d1 <= cam_href_d0;
    end
end

always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn)
        cmos_ps_cnt <= 4'd0;
    else if(pos_vsync && (cmos_ps_cnt < WAIT_FRAME))
        cmos_ps_cnt <= cmos_ps_cnt + 4'd1; 
end

always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn)
        wait_done <= 1'b0;
    else if((cmos_ps_cnt == WAIT_FRAME) && pos_vsync)
        wait_done <= 1'b1;
end


always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn) begin
        cmos_data_16b <= 16'd0;
        cam_data_d0 <= 8'd0;
        byte_flag <= 1'b0;
    end
    else if( cam_href ) begin 
        byte_flag   <= ~byte_flag;
        cam_data_d0 <= cam_data;
        if(byte_flag)
            cmos_data_16b <= {cam_data_d0,cam_data};
    end
    else begin
        byte_flag <= 1'b0;
        cam_data_d0 <= 8'b0;
    end
end

always @(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn)
        byte_flag_d0 <= 1'b0;
    else
        byte_flag_d0 <= byte_flag;
end




always@(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn) begin
        x_cnt <= 0;
    end
    else if(cmos_frame_ce & cmos_frame_de) begin
        x_cnt <= x_cnt + 1;
    end
    else if(cam_href_d1 & !cam_href_d0) begin
        x_cnt <= 0;
    end
end

always@(posedge cam_pclk or negedge rst_n_syn) begin
    if(!rst_n_syn) begin
        y_cnt <= 0;
    end
    else if(cam_href_d1 & !cam_href_d0) begin
        y_cnt <= y_cnt + 1;
    end
    else if(pos_vsync) begin
        y_cnt <= 0;
    end
end

endmodule
