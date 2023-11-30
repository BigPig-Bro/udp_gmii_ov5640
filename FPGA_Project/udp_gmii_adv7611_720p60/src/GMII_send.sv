module GMII_send#(
	parameter BOARD_MAC 	= 48'h03_08_35_01_AE_C2 		,//开发板MAC地址
	parameter BOARD_IP 		= {8'd192,8'd168,8'd3,8'd2}	,//开发板IP地址
	parameter BOARD_PORT	= 16'h8000, 					 //开发板IP地址-端口 
	parameter DES_MAC 		= 48'hff_ff_ff_ff_ff_ff 		,//目的MAC地址
	parameter DES_IP 		= {8'd192,8'd168,8'd3,8'd3} 	,//目的IP地址
	parameter DES_PORT		= 16'h8000, 					 //目的IP地址-端口 
	parameter DATA_SIZE		= 16'd100						 //数据包长度 46~1500 B
	)(
	input  				rst_n, 

	input 				send_start,
	input 				grey_mode,
	output reg  		fifo_send_req,
	input 		[9:0] 	fifo_send_data,

	input 				GMII_GTXCLK,
	output reg  [7:0] 	GMII_TXD, 		
	output reg 			GMII_TXEN, 		
	output reg			GMII_TXER
	);

enum {IDLE, WAIT, PACKET_HEAD, SEND_MAC, SEND_HEADER, SEND_DATA_NUM, SEND_DATA, SEND_CRC,DELAY} SEND_STATE;
reg [ 3:0] state;
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      数据编号生成 	        /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
reg [15:0]  fifo_rd_cnt = 0;
reg [15:0]	frame_rst_r;
reg     	frame_rst_d;
reg [ 3:0] 	state_r;
reg  		state_cnt;


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      数据包发送 	        /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
parameter IP_HEAD_CODE = 64'h55_55_55_55_55_55_55_d5;  //7个前导码55,一个帧开始符d5
parameter DES_MAC_CODE = DES_MAC; //目的MAC地址 ff-ff-ff-ff-ff-ff, 全ff为广播包
parameter BOARD_MAC_CODE = BOARD_MAC; //开发板MAC地址
parameter DATA_TYPE = 16'H0800; // 数据包类型
parameter MAC_DATA = {DES_MAC,BOARD_MAC,16'h0800}; //目的MAC+源MAC+数据类型

wire [31:0] packet_header [6:0];     //IP数据头包
assign	packet_header[0] = {16'h4500,DATA_SIZE+16'd28};  //版本号：4； 包头长度：20；IP包总长(数据+20B头)
assign	packet_header[1] = {{5'b00000,11'd0},16'h4000};    //包序列号+Fragment offset
assign	packet_header[2] = {8'h80,8'h11,16'h6EFD};         //生存时间 + UDP协议 + IP包头检验和
assign	packet_header[3] = BOARD_IP;                   	//开发板源地址
assign	packet_header[4] = DES_IP;                   		//目的地址广播地址
assign	packet_header[5] = {BOARD_PORT,DES_PORT}; //2个字节的源端口号和2个字节的目的端口号
assign	packet_header[6] = {DATA_SIZE+16'd8,16'h0000};         	//数据长度+UDP头检验（可不用）

reg [31:0] check_buffer; // 检验和临时变量

wire [31:0] 	crc_data;
reg 		 	crc_en;
reg 			crc_rst;

reg [10:0] send_cnt;

always@(posedge GMII_GTXCLK or negedge rst_n)begin
	if(!rst_n)begin
        crc_en 		<= 'b0;
		send_cnt 	<= 'd0;
		fifo_send_req <= 'b0;
		
		state 		<= IDLE;
        frame_rst_d <= 'b0;
        fifo_rd_cnt <= 'b0;
	end
	else
		case(state)
			IDLE:begin
				send_cnt 		<= 'd0;

				GMII_TXEN 		<= 'b0;
				GMII_TXER 		<= 'd0;
				GMII_TXD  		<= 'd0;

				// if(send_start | state_cnt)begin
				if(send_start)begin
				 	state <= PACKET_HEAD;
				end
			end
            
			PACKET_HEAD:begin//----------发送8个IP前导码:7个55, 1个d5   
                send_cnt 	<= (send_cnt == 7) ? 0 : send_cnt + 1; 

				GMII_TXEN 	<= 'b1;
				GMII_TXD 	<= IP_HEAD_CODE[(7-send_cnt)*8 +: 8];

				state <= (send_cnt == 7) ? SEND_MAC : state;
			end

			SEND_MAC:begin //------------发送目标MAC address和源MAC address和IP包类型  ，开始CRC
				send_cnt 	<= (send_cnt == 13) ? 0 : send_cnt + 1; 
				crc_en 		<= 'b1;

				GMII_TXD 	<= MAC_DATA [(13-send_cnt)*8 +: 8] ;

				state 		<= (send_cnt == 13) ? SEND_HEADER : state;
			end

			SEND_HEADER:begin //---------发送7个32bit的IP 包头
				send_cnt 	<= (send_cnt == 'd27) ? 0 : send_cnt + 1; 

				GMII_TXD 	<= packet_header[send_cnt[10:2]][(3 - send_cnt[1:0]) * 8 +: 8];

				state <= (send_cnt == 'd27) ? SEND_DATA_NUM : state;
			end

			SEND_DATA_NUM:begin //-----------发送数据包 0-1 编号段
				send_cnt 		<= send_cnt + 'b1;
				fifo_send_req 	<=  (send_cnt == 'd0) ? 1 : fifo_send_req ;

				GMII_TXD 		<= send_cnt? fifo_rd_cnt[7:0] : fifo_rd_cnt[15:8] ;

				// state 			<= (send_cnt == 1) ? state_cnt? SEND_DATA_NULL : SEND_DATA: state;
				state 			<= (send_cnt == 1) ?  SEND_DATA: state;
			end

			SEND_DATA:begin //-----------发送数据包 2~1441 数据段
                if (fifo_send_data[8]) begin
                    frame_rst_d     <= 'b1;
                    fifo_send_req 	<= 'b1;
                    fifo_rd_cnt     <= grey_mode ? 16'h8000 : 16'h0000;
                end else begin
                    frame_rst_d     <= frame_rst_d;
                    fifo_send_req 	<= frame_rst_d ? grey_mode ? 16'h8000 : 16'h0000 : ((send_cnt >= DATA_SIZE - 2) ? 0 : fifo_send_req);
                    fifo_rd_cnt     <= frame_rst_d ? grey_mode ? 16'h8000 : 16'h0000 : ((send_cnt == DATA_SIZE - 1) ? fifo_rd_cnt + 'b1 : fifo_rd_cnt);
                end

                send_cnt 		<= (send_cnt == DATA_SIZE - 1) ? 0 : send_cnt + 'b1;

                GMII_TXD 		<= fifo_send_data[7:0]; 
               
                state 			<= (send_cnt == DATA_SIZE - 1) ? SEND_CRC: state;
			end

			SEND_CRC:begin //------------发送CRC包
                frame_rst_d     <= 'b0;
                fifo_send_req   <= frame_rst_d;

				send_cnt 		<= (send_cnt == 'd3)? 0 : send_cnt + 1;
				crc_en 			<= 'b0;

				case(send_cnt)
					'd0: GMII_TXD <= crc_data[31:24];
					'd1: GMII_TXD <= crc_data[23:16];
					'd2: GMII_TXD <= crc_data[15:8];
					'd3: GMII_TXD <= crc_data[7:0];
					default: GMII_TXER <= 'd1;
				endcase

				state 			<= (send_cnt == 'd3)? DELAY: state;
			end
			
			DELAY:begin//------------等待帧间隔
				send_cnt <= send_cnt [3] ? 0 : send_cnt + 1;
				
				GMII_TXEN 		<= 'b0;
				GMII_TXER 		<= 'd0;
				GMII_TXD  		<= 'd0;
				
				state <= send_cnt [3] ? IDLE : state;
			end

			default: state <= IDLE;
		endcase
end


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      CRC校验  		        /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

CRC32_D8 CRC32_D8(
	.Clk		(GMII_GTXCLK 	), 
	.Reset		(state == IDLE  ), 
	.Data_in	(GMII_TXD 		), 
	.Enable		(crc_en 		), 
	.Crc		(        		),
	.CrcNext	(  				),
    .Crc_eth    (crc_data       )
	);


endmodule 