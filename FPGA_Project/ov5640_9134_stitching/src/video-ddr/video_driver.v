module video_driver#(
    parameter  H_SYNC   =  12'd40   ,
    parameter  H_BACK   =  12'd220  ,
    parameter  H_DISP   =  12'd1280 ,
    parameter  H_FRONT  =  12'd110  ,
    parameter  H_TOTAL  =  H_SYNC + H_BACK + H_DISP + H_FRONT,

    parameter  V_SYNC   =  12'd5    ,
    parameter  V_BACK   =  12'd20   ,
    parameter  V_DISP   =  12'd720  ,
    parameter  V_FRONT  =  12'd5    ,
    parameter  V_TOTAL  =  V_SYNC + V_BACK + V_DISP + V_FRONT
)(
        input               pixel_clk   
    ,   input               sys_rst_n   

    ,   output  reg         video_hs    
    ,   output  reg         video_vs    
    ,   output  reg         video_de    
    ,   output      [23:0]  video_rgb   

    ,   output  reg [11:0]  pixel_xpos
    ,   output  reg [11:0]  pixel_ypos
    ,   input       [23:0]  pixel_data
    ,   output  reg         data_req
);

reg [12:0]  cnt_h;
reg [12:0]  cnt_v;
reg [12:0]  cnt_h_buf;
reg [12:0]  cnt_v_buf;

always @(posedge pixel_clk ) begin
    if (!sys_rst_n) begin
        cnt_h_buf <= 12'd0;
    end
    else begin
        if(cnt_h_buf < H_TOTAL - 1'b1) begin
            cnt_h_buf <= cnt_h_buf + 1'b1;
        end
        else begin
            cnt_h_buf <= 12'd0;
        end
    end
end

always @(posedge pixel_clk ) begin
    if (!sys_rst_n) begin
        cnt_v_buf <= 12'd0;
    end
    else if(cnt_h_buf == H_TOTAL - 1'b1) begin
        if(cnt_v_buf < V_TOTAL - 1'b1) begin
            cnt_v_buf <= cnt_v_buf + 1'b1;
        end
        else begin 
            cnt_v_buf <= 12'd0;
        end
    end
end

always @(posedge pixel_clk ) begin
    cnt_h   <=  cnt_h_buf;  
end

always @(posedge pixel_clk ) begin
    cnt_v   <=  cnt_v_buf;
end

always @(posedge pixel_clk) begin
    video_hs  <= ( cnt_h < H_SYNC ) ? 1'b0 : 1'b1;
    video_vs  <= ( cnt_v < V_SYNC ) ? 1'b0 : 1'b1;
end

always @(posedge pixel_clk) begin
    video_de    <= (((cnt_h >= H_SYNC+H_BACK) && (cnt_h < H_SYNC+H_BACK+H_DISP))
                &&((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                ?  1'b1 : 1'b0;
end

always @(posedge pixel_clk) begin
    data_req    <= (((cnt_h >= H_SYNC+H_BACK-1'b1) && (cnt_h < H_SYNC+H_BACK+H_DISP-1'b1))
                && ((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                ?  1'b1 : 1'b0;
end

always @(posedge pixel_clk) begin
    pixel_xpos <= cnt_h - (H_SYNC + H_BACK - 1'b1);
end

always @(posedge pixel_clk) begin
    pixel_ypos <= cnt_v - (V_SYNC + V_BACK - 1'b1);
end

assign  video_rgb   = video_de ? pixel_data : 24'd0;

endmodule