module rgb1080P_sim(
    input           	sys_clk,
    input           	rst_n,

    output 				video_clk, 
    output 	reg			video_rst, 
    output 	reg			video_de, 
    output 	reg [15:0]	video_data
);

// 2048 x 1085 x 30 ->  (有效像素 1920*1080) 时钟 2048*1085*28 = 61.7M
// parameter H_ALL = 1930;
parameter V_ALL = 1084;
reg [10:0] h_cnt;
reg [10:0] v_cnt;

always@(posedge sys_clk)
    if(!rst_n)begin
        h_cnt <= 0;
        v_cnt <= 0;
    end
    else begin
        h_cnt <=  h_cnt + 1;
        v_cnt <= h_cnt == 2047 ? v_cnt == V_ALL? 0 : v_cnt + 1 : v_cnt;
    end

always@(posedge sys_clk )
        video_rst <= (v_cnt == V_ALL - 1)? 1 : 0;//实物代码 （ 1/ 2）
        // video_rst <= (!rst_n | v_cnt == V_ALL - 1)? 1 : 0;//仿真代码 （ 1/ 2）
reg video_de_r;

always@(video_clk) begin
    video_de_r  <= (h_cnt < 1920 && v_cnt < 1080)? 1 : 0; //实物代码 （ 2/ 2）
    // video_de_r  <= (h_cnt >0 && h_cnt <= 1920 && v_cnt < 1080)? 1 : 0;//仿真代码 （ 2/ 2）

    video_de    <= video_de_r;

    if(video_de_r)
        if(h_cnt < 1920 / 8 * 1)begin
            video_data <= 16'b11111_111111_11111;
        end
        else if(h_cnt < 1920 / 8 * 2)begin
            video_data <= 16'b11111_111111_00000;
        end
        else if(h_cnt < 1920 / 8 * 3)begin
            video_data <= 16'b11111_000000_11111;
        end
        else if(h_cnt < 1920 / 8 * 4)begin
            video_data <= 16'b11111_000000_00000;
        end
        else if(h_cnt < 1920 / 8 * 5)begin
            video_data <= 16'b00000_111111_11111;
        end
        else if(h_cnt < 1920 / 8 * 6)begin
            video_data <= 16'b00000_111111_00000;
        end
        else if(h_cnt < 1920 / 8 * 7)begin
            video_data <= 16'b00000_000000_11111;
        end
        else if(h_cnt < 1920 / 8 * 8)begin
            video_data <= 16'b00000_000000_00000;
        end
    else begin
        video_data <= 16'h0000;
    end
end

endmodule 