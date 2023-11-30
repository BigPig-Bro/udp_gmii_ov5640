module iic_master#(
	parameter 	CLK_FRE 				= 50 , //input clock Mhz
	parameter 	IIC_FRE 				= 100,  //IIC SCK 步进 x Khz
	parameter   IIC_SLAVE_ADDR_EX 	= 0,
	parameter   IIC_SLAVE_REG_EX 	= 1
	) (
	input 				clk,    // Clock

	//读写地址相关
	input 		[7 + IIC_SLAVE_ADDR_EX * 8 :0]	slave_addr,
	input 				send_rw,
	input 		[7 + IIC_SLAVE_REG_EX  * 8 :0]  reg_addr,

	//读写数据相关
	input 				send_en,
	output reg			brust_ready,
	input 				brust_vaild,
	input 		[ 7:0] 	send_data,
	output reg  [ 7:0] 	recv_data = 0,

	output  			send_busy,

	//IIC 物理接口
	output reg 			iic_scl = 1, 
	inout 				iic_sda 
);
//IIC inout
reg sda_en  = 1;
reg sda_out = 1;
reg [CLK_FRE / 2:0] sda_out_r = 0;
reg [CLK_FRE / 2:0] sda_en_r = 0;
assign iic_sda = sda_en_r[CLK_FRE / 2]? sda_out_r[CLK_FRE / 2] : 1'bz;

//分出个SCL X2出来
parameter CLK_DIV = CLK_FRE * 500 / IIC_FRE;
reg [9:0] clk_delay = 0;
reg scl_x2 = 0;
always@(posedge clk) clk_delay <= (clk_delay == CLK_DIV)? 0 : clk_delay + 'd1;
always@(posedge clk) scl_x2 <= clk_delay >= CLK_DIV / 2;
//sda偏移 500ns
always@(posedge clk) sda_out_r <= (sda_out_r << 1) + sda_out;//{sda_out_r [(CLK_FRE / 2) - 1:1],sda_out};
always@(posedge clk) sda_en_r  <= (sda_en_r  << 1) + sda_en ;//{sda_en_r  [(CLK_FRE / 2) - 1:1],sda_en };

//端口采样，避免影响主机时序
reg [ 7:0] send_data_r  	= 0;
reg [ 7 + IIC_SLAVE_ADDR_EX * 8 :0] slave_addr_r  = 0;
reg [ 7 + IIC_SLAVE_REG_EX  * 8 :0] reg_addr_r  	= 0;

reg [7:0] recv_data_r = 0;
reg [3:0] send_cnt    = 0;

//循环发送 接收
enum { STATE_IDLE, STATE_SLAVE_EX, STATE_SLAVE, STATE_REG_EX, STATE_REG, STATE_DATA, STATE_ACK , STATE_END } STATE;	

logic [ 2:0] state_main = 0;
logic [ 2:0] state_next = 0;
logic [ 1:0] state_sub = 0;
assign send_busy = state_main != 0;
always@(posedge scl_x2)
	case (state_main)
		STATE_IDLE://等待 en 触发信号
			if (send_en) begin
				send_data_r 	<= send_data;
				reg_addr_r  	<= reg_addr;
				slave_addr_r  	<= slave_addr  + send_rw;

				sda_out  <= 0; //IIC开始信号

				state_main <= (IIC_SLAVE_ADDR_EX)? STATE_SLAVE_EX : STATE_SLAVE  ;
			end
			else begin
				sda_en   <= 1;
				sda_out  <= 1;
				iic_scl  <= 1;
			end

		STATE_SLAVE_EX://发送从机slave器件地址 高8位
			case (state_sub)
				2'd0:begin//SCL 下降沿 准备数据
					iic_scl <= 0;
					sda_en <= 'b1;
					sda_out <= slave_addr_r[15 - send_cnt];
					send_cnt <= send_cnt + 'd1;

					state_sub <= state_sub + 'd1;
				end

				2'd1:begin//SCL 上升沿 发送数据
					iic_scl <= 1;

					state_sub <= 'd0;
					state_next <= (send_cnt == 8)? STATE_SLAVE: state_next;
					state_main <= (send_cnt == 8)? STATE_ACK  : state_main;
				end
			endcase
		
		STATE_SLAVE://发送从机slave器件地址 低8位	
			case (state_sub)
				2'd0:begin//SCL 下降沿 准备数据
					iic_scl <= 0;
					sda_en <= 'b1;
					sda_out <= slave_addr_r[7 - send_cnt];
					send_cnt <= send_cnt + 'd1;

					state_sub <= state_sub + 'd1;
				end

				2'd1:begin//SCL 上升沿 发送数据
					iic_scl <= 1;

					state_sub <= 'd0;

					state_next <= (send_cnt == 8)? IIC_SLAVE_REG_EX ? STATE_REG_EX : STATE_REG : state_next;
					state_main <= (send_cnt == 8)? STATE_ACK : state_main;
				end
			endcase

		STATE_REG_EX://发送从机slave寄存器地址 高8位	
			case (state_sub)
				2'd0:begin//SCL 下降沿 准备数据
					iic_scl <= 0;
					sda_en <= 'b1;
					sda_out <= reg_addr_r[15 - send_cnt];
					send_cnt <= send_cnt + 'd1;

					state_sub <= state_sub + 'd1;
				end

				2'd1:begin//SCL 上升沿 发送数据
					iic_scl <= 1;

					state_sub <= 'd0;

					state_next <= (send_cnt == 8)? STATE_REG  : state_next;
					state_main <= (send_cnt == 8)? STATE_ACK  : state_main;
				end
			endcase

		STATE_REG://发送从机slave寄存器地址	低8位
			case (state_sub)
				2'd0:begin//SCL 下降沿 准备数据
					iic_scl <= 0;
					sda_en <= 'b1;
					sda_out <= reg_addr_r[7 - send_cnt];
					send_cnt <= send_cnt + 'd1;

					state_sub <= state_sub + 'd1;
				end

				2'd1:begin//SCL 上升沿 发送数据
					iic_scl <= 1;

					state_sub <= 'd0;

					state_next <= (send_cnt == 8)? STATE_DATA : state_next;
					state_main <= (send_cnt == 8)? STATE_ACK  : state_main;
				end
			endcase

		STATE_DATA://发送/读取 数据(突发)
			case (state_sub)
				2'd0:begin//SCL 下降沿 准备数据
					iic_scl <= 0;
					sda_en  <= slave_addr_r[0]? 'b0 : 'b1;
					sda_out <= send_data_r[7 - send_cnt];//写

					send_cnt <= send_cnt + 'd1;

					state_sub <= state_sub + 'd1;
				end

				2'd1:begin//SCL 上升沿 发送数据
					iic_scl <= 1;

					recv_data_r[8 - send_cnt] <= iic_sda;//读
					brust_ready <= (send_cnt == 8)? 'b1 : 'd0;

					state_sub <= 'd0;
					state_next  <= (send_cnt == 8)? brust_vaild ? STATE_DATA : STATE_END : state_next;
					state_main  <= (send_cnt == 8)? STATE_ACK : state_main;
				end
			endcase

		STATE_ACK:begin//ACK
			sda_en   <= 0;
			send_cnt <= 0;
			case (state_sub)
				2'd0:begin//SCL 下降沿 
					iic_scl <= 0;

					state_sub <= state_sub + 'd1;
				end

				2'd1:begin//SCL 上升沿 
					iic_scl <= 1;
					
					brust_ready <= 'b0;
					send_data_r <= send_data;

					state_sub <= 'd0;
					state_main <= state_next;
				end
			endcase
		end

		STATE_END:begin
			sda_en <= 1;
			case (state_sub)
				2'd0:begin//SCL 下降沿 
					iic_scl <= 0;
					sda_out <= 0;

					state_sub <= state_sub + 'd1;
				end

				2'd1:begin
					iic_scl <= 1;
					sda_out <= 1;
					
					state_main <= STATE_IDLE;
					state_sub <= 'd0;
				end
			endcase

		end
	endcase

endmodule 