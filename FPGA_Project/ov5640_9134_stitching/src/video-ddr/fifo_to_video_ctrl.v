module fifo_to_video_ctrl#(
    parameter  H_SYNC   =  12'd40   ,
    parameter  H_BACK   =  12'd220  ,
    parameter  H_DISP   =  12'd1280 ,
    parameter  H_FRONT  =  12'd110  ,
    parameter  H_TOTAL  =  H_SYNC + H_BACK + H_DISP + H_FRONT,

    parameter  V_SYNC   =  12'd5    ,
    parameter  V_BACK   =  12'd20   ,
    parameter  V_DISP   =  12'd720  ,
    parameter  V_FRONT  =  12'd5    ,
    parameter  V_TOTAL  =  V_SYNC + V_BACK + V_DISP + V_FRONT,

    parameter AXI4_DATA_WIDTH = 128
)(
    
        input               video_clk
    ,   input               video_rst_n

    ,   input               M_AXI_ACLK       
    ,   input               M_AXI_ARESETN    

	,   output              video_vs_out    
	,   output              video_hs_out    
	,   output              video_de_out    
	,   output  [23 :0]     video_data_out  

    ,   input   [AXI4_DATA_WIDTH -1 :0]     fifo_data_in
    ,   output  reg         fifo_enable
    ,   output              fifo_rst_n

    ,   output              AXI_FULL_BURST_VALID
    ,   input               AXI_FULL_BURST_READY
);
reg axi_full_burst_valid = 0;

wire  [11:0]  pixel_ypos;
reg   [11:0]  pixel_ypos_d1;
reg   [11:0]  pixel_ypos_d2;

reg     [1:0]   shift_cnt = 0;
wire            data_req;
reg     [23:0]  pixel_data = 0;

reg             video_vs_out_d1 = 0;
reg             video_vs_out_d2 = 0;
reg             video_de_out_d2 = 0;
reg             video_de_out_d1 = 0;

assign AXI_FULL_BURST_VALID = axi_full_burst_valid;
assign fifo_rst_n = !(pixel_ypos_d2 == V_DISP + 2); 

always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN)begin
        pixel_ypos_d1 <= 1'b0;
        pixel_ypos_d2 <= 1'b0;
    end
    else begin
        pixel_ypos_d1 <= pixel_ypos;
        pixel_ypos_d2 <= pixel_ypos_d1;
    end 
end

always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN)begin
        video_vs_out_d1 <= 1'b0;
        video_vs_out_d2 <= 1'b0;
    end
    else begin
        video_vs_out_d1 <= video_vs_out;
        video_vs_out_d2 <= video_vs_out_d1;
    end 
end

always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN)begin
        video_de_out_d1 <= 1'b0;
        video_de_out_d2 <= 1'b0;
    end
    else begin
        video_de_out_d1 <= video_de_out;
        video_de_out_d2 <= video_de_out_d1;
    end 
end

always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN)begin
    if(!M_AXI_ARESETN)begin
        axi_full_burst_valid <= 1'b0;
    end
    else if((!video_vs_out_d2 & video_vs_out_d1) | (!video_de_out_d2 & video_de_out_d1 & !(pixel_ypos_d2 == V_DISP))) begin
        axi_full_burst_valid <= 1'b1;
    end
    else if(axi_full_burst_valid & AXI_FULL_BURST_READY)begin
        axi_full_burst_valid <= 1'b0;
    end 
end

always@(posedge video_clk or negedge video_rst_n)begin
    if(!video_rst_n)begin
        shift_cnt <= 1'b0;
    end
    else if(data_req) begin
        shift_cnt <= (shift_cnt >= (AXI4_DATA_WIDTH / 32) - 1) ? 0 : shift_cnt + 1'b1;
    end
end

always@(posedge video_clk or negedge video_rst_n)begin
    if(!video_rst_n)begin
        fifo_enable <= 1'b0;
    end
    else if(shift_cnt == (AXI4_DATA_WIDTH / 32) - 2 ) begin
        fifo_enable <= 1'b1 & data_req;
    end
    else begin
        fifo_enable <= 1'b0;
    end 
end

always@(posedge video_clk or negedge video_rst_n)begin
    if(!video_rst_n)begin
        pixel_data <= 1'b0;
    end
    else if(data_req) begin
        case(shift_cnt)
            2'b00:begin
                pixel_data <= fifo_data_in[(AXI4_DATA_WIDTH - 32)+:24];
            end
            2'b01:begin
                pixel_data <= fifo_data_in[(AXI4_DATA_WIDTH - 64)+:24];
            end
            2'b10:begin
                pixel_data <= fifo_data_in[(AXI4_DATA_WIDTH - 96)+:24];
            end
            2'b11:begin
                pixel_data <= fifo_data_in[(AXI4_DATA_WIDTH - 128)+:24];
            end
            default:begin
                pixel_data <= 0;
            end
        endcase
    end
end

video_driver#(
        .H_SYNC   (H_SYNC   )
    ,   .H_BACK   (H_BACK   )
    ,   .H_DISP   (H_DISP   )
    ,   .H_FRONT  (H_FRONT  )
    ,   .H_TOTAL  (H_TOTAL  )

    ,   .V_SYNC   (V_SYNC   )
    ,   .V_BACK   (V_BACK   )
    ,   .V_DISP   (V_DISP   )
    ,   .V_FRONT  (V_FRONT  )
    ,   .V_TOTAL  (V_TOTAL  ) 
)u_video_driver(
        .pixel_clk      (video_clk      )
    ,   .sys_rst_n      (video_rst_n    )

    ,   .video_vs       (video_vs_out   )
    ,   .video_hs       (video_hs_out   )
    ,   .video_de       (video_de_out   )
    ,   .video_rgb      (video_data_out )

    ,   .pixel_xpos     ()
    ,   .pixel_ypos     (pixel_ypos     )
    ,   .pixel_data     (pixel_data     )
    ,   .data_req       (data_req       )
);









endmodule