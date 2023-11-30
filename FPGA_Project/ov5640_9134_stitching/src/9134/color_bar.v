//*************************************************************************\
//==========================================================================
//   Description:
//  ��������ģ��
//==========================================================================
//   Revision History:
//	Date		  By			Revision	Change Description
//--------------------------------------------------------------------------
//2013/5/7                     1.2         remove some warning
//2013/4/18                    1.1         vs timing
//2013/4/16	        		   1.0			Original
//*************************************************************************/
module color_bar(
	input clk,            //����ʱ�����룬1280x720@60P������ʱ��Ϊ74.25
	input rst,            //��λ,����Ч
	output hs,            //��ͬ��������Ч
	output vs,            //��ͬ��������Ч
	output de,            //������Ч
	output[7:0] rgb_r,    //�������ݡ���ɫ����
	output[7:0] rgb_g,    //�������ݡ���ɫ����
	output[7:0] rgb_b     //�������ݡ���ɫ����
);
/*********��Ƶʱ���������******************************************/
//parameter H_ACTIVE = 16'd1280;  //����Ч���ȣ�����ʱ�����ڸ�����
//parameter H_FP = 16'd110;       //��ͬ��ǰ�糤��
//parameter H_SYNC = 16'd40;      //��ͬ������
//parameter H_BP = 16'd220;       //��ͬ����糤��
//parameter V_ACTIVE = 16'd720;   //����Ч���ȣ��еĸ�����
//parameter V_FP 	= 16'd5;        //��ͬ��ǰ�糤��
//parameter V_SYNC  = 16'd5;      //��ͬ������
//parameter V_BP	= 16'd20;       //��ͬ����糤��

parameter H_ACTIVE = 16'd1920;
parameter H_FP = 16'd88;
parameter H_SYNC = 16'd44;
parameter H_BP = 16'd148; 
parameter V_ACTIVE = 16'd1080;
parameter V_FP 	= 16'd4;
parameter V_SYNC  = 16'd5;
parameter V_BP	= 16'd36;
parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//���ܳ���
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//���ܳ���
/*********����RGB color bar��ɫ��������*****************************/
parameter WHITE_R 		= 8'hff;
parameter WHITE_G 		= 8'hff;
parameter WHITE_B 		= 8'hff;
parameter YELLOW_R 		= 8'hff;
parameter YELLOW_G 		= 8'hff;
parameter YELLOW_B 		= 8'h00;                              	
parameter CYAN_R 		= 8'h00;
parameter CYAN_G 		= 8'hff;
parameter CYAN_B 		= 8'hff;                             	
parameter GREEN_R 		= 8'h00;
parameter GREEN_G 		= 8'hff;
parameter GREEN_B 		= 8'h00;
parameter MAGENTA_R 	= 8'hff;
parameter MAGENTA_G 	= 8'h00;
parameter MAGENTA_B 	= 8'hff;
parameter RED_R 		= 8'hff;
parameter RED_G 		= 8'h00;
parameter RED_B 		= 8'h00;
parameter BLUE_R 		= 8'h00;
parameter BLUE_G 		= 8'h00;
parameter BLUE_B 		= 8'hff;
parameter BLACK_R 		= 8'h00;
parameter BLACK_G 		= 8'h00;
parameter BLACK_B 		= 8'h00;
reg hs_reg;//����һ���Ĵ���,������ͬ��
reg vs_reg;//����һ���Ĵ���,�û���ͬ��
reg hs_reg_d0;//hs_regһ��ʱ�ӵ��ӳ�
              //������_d0��d1��d2��Ϊ��׺�ľ�Ϊĳ���Ĵ������ӳ�
reg vs_reg_d0;//vs_regһ��ʱ�ӵ��ӳ�
reg[11:0] h_cnt;//�����еļ�����
reg[11:0] v_cnt;//���ڳ���֡���ļ�����
reg[11:0] active_x;//��Чͼ��ĵ�����x
reg[11:0] active_y;//��Чͼ�������y
reg[7:0] rgb_r_reg;//��������r����
reg[7:0] rgb_g_reg;//��������g����
reg[7:0] rgb_b_reg;//��������b����
reg h_active;//��ͼ����Ч
reg v_active;//��ͼ����Ч
wire video_active;//һ֡��ͼ�����Ч����h_active & v_active
reg video_active_d0;
assign hs = hs_reg_d0;
assign vs = vs_reg_d0;
assign video_active = h_active & v_active;
assign de = video_active_d0;
assign rgb_r = rgb_r_reg;
assign rgb_g = rgb_g_reg;
assign rgb_b = rgb_b_reg;
always@(posedge clk or posedge rst)
begin
	if(rst)
		begin
			hs_reg_d0 <= 1'b0;
			vs_reg_d0 <= 1'b0;
			video_active_d0 <= 1'b0;
		end
	else
		begin
			hs_reg_d0 <= hs_reg;
			vs_reg_d0 <= vs_reg;
			video_active_d0 <= video_active;
		end
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL - 1)//�м����������ֵ����
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		active_x <= 12'd0;
	else if(h_cnt >= H_FP + H_SYNC + H_BP - 1)//����ͼ���x����
		active_x <= h_cnt - (H_FP[11:0] + H_SYNC[11:0] + H_BP[11:0] - 12'd1);
	else
		active_x <= active_x;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		v_cnt <= 12'd0;
	else if(h_cnt == H_FP  - 1)//������������ΪH_FP - 1��ʱ�򳡼�����+1������
		if(v_cnt == V_TOTAL - 1)//�������������ֵ�ˣ�����
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;//û�����ֵ��+1
	else
		v_cnt <= v_cnt;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		hs_reg <= 1'b0;
	else if(h_cnt == H_FP - 1)//��ͬ����ʼ��...
		hs_reg <= 1'b1;
	else if(h_cnt == H_FP + H_SYNC - 1)//��ͬ����ʱ��Ҫ������
		hs_reg <= 1'b0;
	else
		hs_reg <= hs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		h_active <= 1'b0;
	else if(h_cnt == H_FP + H_SYNC + H_BP - 1)
		h_active <= 1'b1;
	else if(h_cnt == H_TOTAL - 1)
		h_active <= 1'b0;
	else
		h_active <= h_active;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		vs_reg <= 1'd0;
	else if((v_cnt == V_FP - 1) && (h_cnt == H_FP - 1))
		vs_reg <= 1'b1;
	else if((v_cnt == V_FP + V_SYNC - 1) && (h_cnt == H_FP - 1))
		vs_reg <= 1'b0;	
	else
		vs_reg <= vs_reg;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		v_active <= 1'd0;
	else if((v_cnt == V_FP + V_SYNC + V_BP - 1) && (h_cnt == H_FP - 1))
		v_active <= 1'b1;
	else if((v_cnt == V_TOTAL - 1) && (h_cnt == H_FP - 1))
		v_active <= 1'b0;	
	else
		v_active <= v_active;
end

always@(posedge clk or posedge rst)
begin
	if(rst)
		begin
			rgb_r_reg <= 8'h00;
			rgb_g_reg <= 8'h00;
			rgb_b_reg <= 8'h00;
		end
	else if(video_active)
		if(active_x == 12'd0)
			begin
				rgb_r_reg <= WHITE_R;
				rgb_g_reg <= WHITE_G;
				rgb_b_reg <= WHITE_B;
			end
		else if(active_x == (H_ACTIVE/8) * 1)
			begin
				rgb_r_reg <= WHITE_R;
				rgb_g_reg <= WHITE_G;
				rgb_b_reg <= WHITE_B;
			end			
		else if(active_x == (H_ACTIVE/8) * 2)
			begin
				rgb_r_reg <= CYAN_R;
				rgb_g_reg <= CYAN_G;
				rgb_b_reg <= CYAN_B;
			end
		else if(active_x == (H_ACTIVE/8) * 3)
			begin
				rgb_r_reg <= GREEN_R;
				rgb_g_reg <= GREEN_G;
				rgb_b_reg <= GREEN_B;
			end
		else if(active_x == (H_ACTIVE/8) * 4)
			begin
				rgb_r_reg <= MAGENTA_R;
				rgb_g_reg <= MAGENTA_G;
				rgb_b_reg <= MAGENTA_B;
			end
		else if(active_x == (H_ACTIVE/8) * 5)
			begin
				rgb_r_reg <= RED_R;
				rgb_g_reg <= RED_G;
				rgb_b_reg <= RED_B;
			end
		else if(active_x == (H_ACTIVE/8) * 6)
			begin
				rgb_r_reg <= BLUE_R;
				rgb_g_reg <= BLUE_G;
				rgb_b_reg <= BLUE_B;
			end	
		else if(active_x == (H_ACTIVE/8) * 7)
			begin
				rgb_r_reg <= RED_R;
				rgb_g_reg <= RED_G;
				rgb_b_reg <= RED_B;
			end
		else
			begin
				rgb_r_reg <= rgb_r_reg;
				rgb_g_reg <= rgb_g_reg;
				rgb_b_reg <= rgb_b_reg;
			end			
	else
		begin
			rgb_r_reg <= 8'h00;
			rgb_g_reg <= 8'h00;
			rgb_b_reg <= 8'h00;
		end
end

endmodule 