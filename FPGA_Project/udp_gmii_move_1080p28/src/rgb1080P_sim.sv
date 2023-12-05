module rgb1080P_sim(
    input           	sys_clk,
    input           	rst_n,

    output 				video_clk, 
    output 	reg			video_rst, 
    output 	reg			video_de, 
    output 	reg [15:0]	video_data
);

// 1964 x 1100 x 30 ->  (有效像素 1920*1080) 时钟
parameter H_ALL = 2047;
parameter V_ALL = 1084;
reg [10:0] h_cnt;
reg [10:0] v_cnt;

always@(posedge sys_clk)
    if(!rst_n)begin
        h_cnt <= 0;
        v_cnt <= 0;
    end
    else begin
        h_cnt <= h_cnt + 1;
        v_cnt <= h_cnt == H_ALL ? v_cnt == V_ALL? 0 : v_cnt + 1 : v_cnt;
    end

always@(posedge sys_clk )
        // video_rst <= (!rst_n | v_cnt == V_ALL - 1)? 1 : 0;
        video_rst <= (v_cnt == V_ALL - 1)? 1 : 0;


//运动色块
parameter SPEED = 5;
parameter CUBE_WIDTH = 256;
reg [10:0] cube_x,cube_y;
reg [1:0] cube_dic;

always@(posedge video_clk)
    if(!rst_n)begin
        cube_x <= 0;
        cube_y <= 0;
        cube_dic <= 2'b11; // x y 增加
    end
    else if(v_cnt == 0 && h_cnt == 0)begin
        cube_x <= cube_dic[1]? cube_x + SPEED : cube_x - SPEED;
        cube_y <= cube_dic[0]? cube_y + SPEED : cube_y - SPEED;

        if(cube_x >= 1920 - CUBE_WIDTH)
            cube_dic[1] <= 0;
        else if(cube_x <=  SPEED)
            cube_dic[1] <= 1;
        else cube_dic[1] <= cube_dic[1] ;

        if(cube_y >= 1080 - CUBE_WIDTH)
            cube_dic[0] <= 0;
        else if(cube_y <=  SPEED)
            cube_dic[0] <= 1;
        else cube_dic[0] <= cube_dic[0] ;
    end
    else begin
        cube_x <= cube_x;
        cube_y <= cube_y;
    end

reg video_de_r;
always@(posedge video_clk)begin
    video_de_r <= (h_cnt < 1920 && v_cnt >= 5 && v_cnt < 1085)? 1 : 0;
    video_de <= video_de_r;
    if(video_de_r)begin
        //横向运动
        if(h_cnt >= cube_x & h_cnt < cube_x + CUBE_WIDTH & v_cnt >= cube_y & v_cnt < cube_y + CUBE_WIDTH )begin
            if(h_cnt >= cube_x & h_cnt < cube_x + CUBE_WIDTH / 8 * 1)begin
                video_data = 16'b11111_111111_1111;
            end
            else if(h_cnt >= cube_x & h_cnt < cube_x + CUBE_WIDTH / 8 * 2)begin
                video_data = 16'b11111_111111_00000;
            end
            else if(h_cnt >= cube_x & h_cnt < cube_x + CUBE_WIDTH / 8 * 3)begin
                video_data = 16'b11111_000000_11111;
            end
            else if(h_cnt >= cube_x & h_cnt < cube_x + CUBE_WIDTH / 8 * 4)begin
                video_data = 16'b11111_000000_00000;
            end
            else if(h_cnt >= cube_x & h_cnt < cube_x + CUBE_WIDTH / 8 * 5)begin
                video_data = 16'b00000_111111_11111;
            end
            else if(h_cnt >= cube_x & h_cnt < cube_x + CUBE_WIDTH / 8 * 6)begin
                video_data = 16'b00000_111111_00000;
            end
            else if(h_cnt >= cube_x & h_cnt < cube_x + CUBE_WIDTH / 8 * 7)begin
                video_data = 16'b00000_000000_11111;
            end
            else begin
                video_data = 16'b00000_000000_00000;
            end
        end
        else begin
            video_data = 16'h0000;
        end
    end
    else begin
        video_data = 16'h0000;
    end
end

endmodule 