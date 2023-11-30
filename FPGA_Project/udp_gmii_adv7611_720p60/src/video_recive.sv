module video_recive(
    // input           Reset,     

    input           video_clk,  				
    input           video_de,	
    input [19:0]    video_data, 		

    input           video_rd_clk,		
    input           video_rd_en,
    output reg      video_rd_rdy,
    output [ 9:0]   video_rd_data		
);
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
//////////////////// 			      FIFO模块	      	   /////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
reg video_rd_rdy_r;
reg video_rd_rdy_rr;
reg rst_r, rst_rr;
fifo4096x20	fifo4096x20_m0 (
	// .Reset 		(rst_rr		                    ),
	//  .WrReset 		(Reset		                    ),
	//  .RdReset 		(Reset		                    ),
    
    .Empty          (                               ),
    .Full           (                               ),

	.Data 		    (video_data                     ),
	.WrClk 		    (video_clk 	                    ),
	.WrEn 		    (video_de 	                    ),
    .Almost_Full    (video_rd_rdy_r                 ),

	.RdClk 		    (video_rd_clk  		            ),
	.RdEn 		    (video_rd_en 			        ),
	.Q 			    (video_rd_data  		        )
	);

// always@(posedge video_clk)
// begin
//     if (Reset) begin
//         rst_r <= 'b1;
//         rst_rr <= 'b1;
//     end else begin
//         rst_r <= 'b0;
//         rst_rr <= rst_r;
//     end
// end

always@(posedge video_rd_clk)
begin
    // if (Reset) begin
    //     video_rd_rdy_rr <= 'b0;
    //     video_rd_rdy <= 'b0;
    // end else begin
        video_rd_rdy_rr <= video_rd_rdy_r;
        video_rd_rdy <= video_rd_rdy_rr;
    // end
end

endmodule