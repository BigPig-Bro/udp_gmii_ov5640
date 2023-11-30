module rgb_timing(
	input               rgb_clk,           //pixel clock
	input               rgb_rst_n,         //reset signal high active
	output  reg         rgb_hs,            //horizontal synchronization
	output  reg         rgb_vs,            //vertical synchronization
	output  	       	rgb_de,            //video valid

	output reg [10:0] 	rgb_x,              //video x position 
	output reg [10:0] 	rgb_y               //video y position 
	);


//1080P30 74.25Mhz
parameter H_ACTIVE		 =  12'd1280; //
parameter H_FP			 =  12'd110;  //
parameter H_SYNC		 =  12'd40;   //
parameter H_BP			 =  12'd220;  //
parameter V_ACTIVE		 =  12'd720;  //
parameter V_FP			 =  12'd5;    //
parameter V_SYNC		 =  12'd5;    //
parameter V_BP			 =  12'd20;   //
parameter HS_POL		 =  'b1;      //
parameter VS_POL		 =  'b1;      //


parameter H_TOTAL = H_ACTIVE + H_FP + H_SYNC + H_BP;//horizontal total time (pixels)
parameter V_TOTAL = V_ACTIVE + V_FP + V_SYNC + V_BP;//vertical total time (lines)

reg[11:0] h_cnt;                 //horizontal counter
reg[11:0] v_cnt;                 //vertical counter

always@(posedge rgb_clk)begin 
//显示计数
	if(h_cnt <= H_ACTIVE - 1)
		rgb_x <= h_cnt;
	else
		rgb_x <= rgb_x;
	
	if(v_cnt <= V_ACTIVE - 1)
		rgb_y <= v_cnt;
	else
		rgb_y <= rgb_y;
end

always@(posedge rgb_clk)begin 
//列计数
	if(rgb_rst_n == 'b0)
		h_cnt <= 12'd0;
	else if(h_cnt == H_TOTAL - 1)//horizontal counter maximum value
		h_cnt <= 12'd0;
	else
		h_cnt <= h_cnt + 12'd1;
//行计数
	if(rgb_rst_n == 'b0)
		v_cnt <= V_TOTAL - 1;
	else if(h_cnt == H_TOTAL - 1)//horizontal sync time
		if(v_cnt == V_TOTAL - 1)//vertical counter maximum value
			v_cnt <= 12'd0;
		else
			v_cnt <= v_cnt + 12'd1;
	else
		v_cnt <= v_cnt;
//HS生成
	if(h_cnt == (H_ACTIVE + H_FP - 1))//horizontal sync time
		rgb_hs <= HS_POL;
	else if(h_cnt == (H_ACTIVE + H_FP + H_SYNC - 1))//horizontal sync time
		rgb_hs <= ~HS_POL;
	else
		rgb_hs <= rgb_hs;
//VS生成
	if(v_cnt == (V_ACTIVE + V_FP - 1))//vertical sync time
		rgb_vs <= 1;
	else if(v_cnt == (V_ACTIVE + V_FP + V_SYNC - 1))//vertical sync time
		rgb_vs <= 0;
	else
		rgb_vs <= 0;
end 
//de生成
assign rgb_de = h_cnt < H_ACTIVE && v_cnt < V_ACTIVE;


endmodule 