//功能描述：驱动 WS2812显示不同键值颜色
module ws2812_top (
	input 			clk,  //输入 时钟源 

	input [1:0]   	key, 

	output reg WS2812_Di //输出到WS2812的接口
	
);
parameter WS2812_NUM 	= 1  - 1     ; // WS2812的LED数量(1从0开始)
parameter WS2812_WIDTH 	= 24 	     ; // WS2812的数据位宽
parameter CLK_FRE 	 	= 27_000_000	 	 ; // CLK的频率(mHZ)

parameter DELAY_1_HIGH 	= (CLK_FRE / 1_000_000 * 0.85 )  - 1; //≈850ns±150ns     1 高电平时间
parameter DELAY_1_LOW 	= (CLK_FRE / 1_000_000 * 0.40 )  - 1; //≈400ns±150ns 	  1 低电平时间
parameter DELAY_0_HIGH 	= (CLK_FRE / 1_000_000 * 0.40 )  - 1; //≈400ns±150ns 	  0 高电平时间
parameter DELAY_0_LOW 	= (CLK_FRE / 1_000_000 * 0.85 )  - 1; //≈850ns±150ns     0 低电平时间
parameter DELAY_RESET 	= (CLK_FRE  / 10 ) - 1; //0.1s 复位时间 ＞50us

parameter RESET 	 		= 0; //状态机声明
parameter DATA_SEND  		= 1;
parameter BIT_SEND_HIGH   	= 2;
parameter BIT_SEND_LOW   	= 3;

reg [ 1:0] state       = 0/* synthesis preserve */; //主状态机控制
reg [ 4:0] bit_send    = 0; //数据数量发送控制
reg [ 4:0] data_send   = 0; //数据位发送控制
reg [31:0] clk_delay   = 0; //延时控制
reg [23:0] WS2812_data = 24'd1; // WS2812的颜色数据(初始淡蓝){GRB}

always@(posedge clk)
	case (state)
		RESET:begin
			WS2812_Di <= 0;

			if (clk_delay < DELAY_RESET) 
				clk_delay <= clk_delay + 1;
			else begin
				clk_delay <= 0;
				WS2812_data <= (key == 2'D1) ? 24'H000100 : (key == 2'D2 )? 24'H010000 :  24'h000000;
				state <= DATA_SEND;
			end
		end

		DATA_SEND:
			if (data_send == WS2812_NUM && bit_send == WS2812_WIDTH)begin 
				data_send <= 0;
				bit_send  <= 0;
				state <= RESET;
			end 
			else if (bit_send < WS2812_WIDTH) begin
				state    <= BIT_SEND_HIGH;
			end
			else begin// if (bit_send == WS2812_WIDTH)
				data_send <= data_send + 1;
				bit_send  <= 0;
				state    <= BIT_SEND_HIGH;
			end
			
		BIT_SEND_HIGH:begin
			WS2812_Di <= 1;

			if (WS2812_data[23-bit_send]) 
				if (clk_delay < DELAY_1_HIGH)
					clk_delay <= clk_delay + 1;
				else begin
					clk_delay <= 0;
					state    <= BIT_SEND_LOW;
				end
			else 
				if (clk_delay < DELAY_0_HIGH)
					clk_delay <= clk_delay + 1;
				else begin
					clk_delay <= 0;
					state    <= BIT_SEND_LOW;
				end
		end

		BIT_SEND_LOW:begin
			WS2812_Di <= 0;

			if (WS2812_data[23-bit_send]) 
				if (clk_delay < DELAY_1_LOW) 
					clk_delay <= clk_delay + 1;
				else begin
					clk_delay <= 0;

					bit_send <= bit_send + 1;
					state    <= DATA_SEND;
				end
			else 
				if (clk_delay < DELAY_0_LOW) 
					clk_delay <= clk_delay + 1;
				else begin
					clk_delay <= 0;
					
					bit_send <= bit_send + 1;
					state    <= DATA_SEND;
				end
		end
	endcase
endmodule