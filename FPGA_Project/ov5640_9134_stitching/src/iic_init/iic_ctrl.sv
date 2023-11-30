module iic_ctrl#(
	parameter 	CLK_FRE 				= 50,
	parameter 	IIC_FRE 				= 100,
	parameter   IIC_SLAVE_ADDR_EX 		= 0,
	parameter   IIC_SLAVE_REG_EX 		= 1,
	parameter   IIC_SLAVE_ADDR 			= 16'h78,
	parameter 	INIT_CMD_NUM 	 		= 303,
	parameter 	PIC_PATH = "init_1024x768.txt"
)(
	input 			clk,rst_n,
	output 			iic_scl,
	inout 			iic_sda
);

parameter DELAY = CLK_FRE  * 1000;

parameter STATE_DELAY    		= 0;
parameter STATE_INIT     		= 1;
parameter STATE_FINISH    		= 2;
parameter STATE_WAIT_BUSY     	= 5;

logic [ 2:0] pre_state = 0;
logic [ 2:0] state_main = 0;
logic [31:0] clk_delay = 0;

logic [10:0] send_cnt = 0;

logic 			send_busy;	  	
logic  			send_en = 0;   		
logic  [ 7 + IIC_SLAVE_REG_EX * 8 :0]	send_addr = 0;   	
logic  [ 7:0]	send_data  = 0	;

logic [ 15 + IIC_SLAVE_REG_EX * 8 :0] init_cmd[INIT_CMD_NUM - 1 : 0];
initial $readmemh(PIC_PATH,init_cmd);

always@(posedge clk,negedge rst_n)
	if(!rst_n)begin 
		state_main 	<= 'd0;
		send_cnt 	<= 'd0;
		send_en 	<= 'b0;
	end
	else
		case (state_main)
		STATE_DELAY:
			if(clk_delay == DELAY)begin
				clk_delay <= 'd0;
				state_main <= state_main + 'd1;
			end
			else  
				clk_delay <= clk_delay + 'd1;
		STATE_INIT://initial oled
			if (send_cnt == INIT_CMD_NUM) //初始化完成
			begin 
				send_en <= 0;
				send_cnt <= 0;

				state_main <= STATE_FINISH;
			end
			else if(!send_busy)begin 		  
				send_en <= 1;
				send_addr <= init_cmd[send_cnt][15 + IIC_SLAVE_REG_EX *8 : 8];
				send_data <= init_cmd[send_cnt][7:0];
				send_cnt <= send_cnt + 'd1;

				pre_state <= state_main;
				state_main <= STATE_WAIT_BUSY;
			end
			else
				send_en <= 0;

		STATE_FINISH://write data
			state_main <= state_main;

		STATE_WAIT_BUSY://WAIT FOR BUSY 
			if(send_busy) state_main <= pre_state;

		default : begin
			state_main <= 'd0;
		end
		endcase


//IIC 底层驱动
iic_master#(
	.CLK_FRE 				(CLK_FRE	 			),
	.IIC_FRE 				(IIC_FRE 	 			),
	.IIC_SLAVE_ADDR_EX 		(IIC_SLAVE_ADDR_EX ),
	.IIC_SLAVE_REG_EX 		(IIC_SLAVE_REG_EX 	)

	) iic_master_m0(
	.clk			(clk					),

	.slave_addr		(IIC_SLAVE_ADDR	),	
	.send_rw		(1'b0 					),// 只有写没有读	
	.reg_addr		(send_addr				),	
	.send_en		(send_en				),	
	.brust_ready	(						),		
	.brust_vaild	(1'b0					),		
	.send_data		(send_data				),	
	.recv_data		(						),// 只有写没有读	
	.send_busy		(send_busy				),
		
	.iic_scl		(iic_scl				),	
	.iic_sda		(iic_sda				)	
	);

endmodule