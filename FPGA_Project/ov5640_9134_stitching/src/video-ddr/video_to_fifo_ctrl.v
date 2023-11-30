`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/24 16:45:44
// Design Name: 
// Module Name: video_to_fifo_ctrl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module video_to_fifo_ctrl#(
    parameter  AXI4_DATA_WIDTH = 128
)(
    
        input           video_clk
    ,   input           video_rst_n

    ,   input           M_AXI_ACLK
    ,   input           M_AXI_ARESETN

	,   input           video_vs_out    
	,   input           video_hs_out    
	,   input           video_de_out    
	,   input   [23:0]  video_data_out  

    ,   output  [AXI4_DATA_WIDTH-1:0] fifo_data_out
    ,   output  reg     fifo_enable

    ,   output  reg     AXI_FULL_BURST_VALID
    ,   input           AXI_FULL_BURST_READY
);

reg [AXI4_DATA_WIDTH-1:0] fifo_data_out_buffer;
reg [1:0]   buf_cnt;
reg     video_hs_out_d1;
reg     video_hs_out_d2;
reg     video_de_out_d1;
reg     video_de_out_d2;
reg     de_valid_flag = 0;

assign  fifo_data_out   =   fifo_data_out_buffer;

always@(posedge video_clk or negedge video_rst_n) begin
    if(!video_rst_n) begin
        fifo_data_out_buffer    <=  0;
    end
    else if(video_de_out) begin
        fifo_data_out_buffer    <=  {fifo_data_out_buffer[AXI4_DATA_WIDTH-32-1:0],8'hff,video_data_out};
    end
end

always@(posedge video_clk or negedge video_rst_n) begin
    if(!video_rst_n) begin
        buf_cnt    <=  0;
    end
    else if(video_de_out) begin
        buf_cnt    <=  (buf_cnt == (AXI4_DATA_WIDTH / 32) -1) ? 0 : buf_cnt + 1;
    end
end

always@(posedge video_clk or negedge video_rst_n) begin
    if(!video_rst_n) begin
        fifo_enable    <=  0;
    end
    else if(video_de_out & (buf_cnt == (AXI4_DATA_WIDTH / 32) -1)) begin
        fifo_enable    <=  1;
    end
    else begin
        fifo_enable    <=  0;
    end
end

always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
    if(!M_AXI_ARESETN) begin
        video_hs_out_d1 <=  0;
        video_hs_out_d2 <=  0;
        video_de_out_d1 <=  0;
        video_de_out_d2 <=  0;
    end 
    else begin
        video_hs_out_d1 <=  video_hs_out;
        video_hs_out_d2 <=  video_hs_out_d1;
        video_de_out_d1 <=  video_de_out;
        video_de_out_d2 <=  video_de_out_d1;
    end
end

always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
    if(!M_AXI_ARESETN) begin
        de_valid_flag <=  0;
    end 
    else if(video_de_out_d2)begin
        de_valid_flag <=  1;
    end
    else if(video_hs_out_d2 & !video_hs_out_d1) begin
        de_valid_flag <=  0;
    end
end

always@(posedge M_AXI_ACLK or negedge M_AXI_ARESETN) begin
    if(!M_AXI_ARESETN) begin
        AXI_FULL_BURST_VALID <=  0;
    end 
    else if(video_hs_out_d2 & !video_hs_out_d1 & de_valid_flag)begin
        AXI_FULL_BURST_VALID <=  1;
    end
    else if(AXI_FULL_BURST_VALID & AXI_FULL_BURST_READY) begin
        AXI_FULL_BURST_VALID <=  0;
    end
end














endmodule
