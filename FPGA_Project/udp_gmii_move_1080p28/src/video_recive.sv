module video_recive(
    input           Reset,     

    input           video_clk,  				
    input           video_de, 			
    input [15:0]    video_data, 		

    input           video_rd_clk,		
    input           video_rd_en,
    output reg      video_rd_rdy,
    output [ 7:0]   video_rd_data		
);
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      FIFO模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
wire video_rd_rdy_r;
fifo4096x16	fifo4096x16_m0 (
	// .Reset 		(Reset		                    ),
	.WrReset 		(Reset		                    ),
	.RdReset 		(Reset		                    ),
    
    .Empty          (                               ),
    .Full           (                               ),

	.Data 		    (video_data 		            ),
	.WrClk 		    (video_clk 	                    ),
	.WrEn 		    (video_de 	                    ),
    .Almost_Full    (video_rd_rdy_r                 ),

	.RdClk 		    (video_rd_clk  		            ),
	.RdEn 		    (video_rd_en 			        ),
	.Q 			    (video_rd_data  		        )
	);

always@(posedge video_rd_clk) video_rd_rdy <= video_rd_rdy_r;

endmodule