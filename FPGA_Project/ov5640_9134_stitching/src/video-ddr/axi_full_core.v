`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/09/07 13:57:50
// Design Name: 
// Module Name: fifo2axi-f
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_full_core#(
    	parameter FDW = 32
    ,	parameter FAW = 8

		// Base address of targeted slave
	,   parameter  C_M_TARGET_SLAVE_BASE_ADDR	= 32'h40000000
		// Burst Length. Supports 1, 2, 4, 8, 16, 32, 64, 128, 256 burst lengths
	,   parameter integer C_M_AXI_BURST_LEN	= 32
		// Thread ID Width
	,   parameter integer C_M_AXI_ID_WIDTH	= 1
		// Width of Address Bus
	,   parameter integer C_M_AXI_ADDR_WIDTH	= 32
		// Width of Data Bus
	,   parameter integer C_M_AXI_DATA_WIDTH	= 32
		// Width of User Write Address Bus
	,   parameter integer C_M_AXI_AWUSER_WIDTH	= 0
		// Width of User Read Address Bus
	,   parameter integer C_M_AXI_ARUSER_WIDTH	= 0
		// Width of User Write Data Bus
	,   parameter integer C_M_AXI_WUSER_WIDTH	= 0
		// Width of User Read Data Bus
	,   parameter integer C_M_AXI_RUSER_WIDTH	= 0
		// Width of User Response Bus
	,   parameter integer C_M_AXI_BUSER_WIDTH	= 0
)(
//----------------------------------------------------
// auxiliary signals
    // Initiate AXI transactions
        input wire  INIT_AXI_TXN
    // Asserts when transaction is complete
    ,   output wire TXN_DONE
    // Asserts when ERROR is detected
    ,   output reg  ERROR

//----------------------------------------------------
// AXI-FULL master port
    // Global Clock Signal.
    ,   input wire  M_AXI_ACLK
    // Global Reset Singal. This Signal is Active Low
    ,   input wire  M_AXI_ARESETN

    //----------------Write Address Channel----------------//
    // Master Interface Write Address ID
    ,   output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_AWID
    // Master Interface Write Address
    ,   output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR
    // Burst length. The burst length gives the exact number of transfers in a burst
    ,   output wire [7 : 0] M_AXI_AWLEN
    // Burst size. This signal indicates the size of each transfer in the burst
    ,   output wire [2 : 0] M_AXI_AWSIZE
    // Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
    ,   output wire [1 : 0] M_AXI_AWBURST
    // Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
    ,   output wire  M_AXI_AWLOCK
    // Memory type. This signal indicates how transactions
    // are required to progress through a system.
    ,   output wire [3 : 0] M_AXI_AWCACHE
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    ,   output wire [2 : 0] M_AXI_AWPROT
    // Quality of Service, QoS identifier sent for each write transaction.
    ,   output wire [3 : 0] M_AXI_AWQOS
    // Optional User-defined signal in the write address channel.
    ,   output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER
    // Write address valid. This signal indicates that
    // the channel is signaling valid write address and control information.
    ,   output wire  M_AXI_AWVALID
    // Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
    ,   input wire  M_AXI_AWREADY

    //----------------Write Data Channel----------------//
    // Master Interface Write Data.
    ,   output wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA
    // Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
    ,   output wire [C_M_AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB
    // Write last. This signal indicates the last transfer in a write burst.
    ,   output wire  M_AXI_WLAST
    // Optional User-defined signal in the write data channel.
    ,   output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER
    // Write valid. This signal indicates that valid write
    // data and strobes are available
    ,   output wire  M_AXI_WVALID
    // Write ready. This signal indicates that the slave
    // can accept the write data.
    ,   input wire  M_AXI_WREADY

    //----------------Write Response Channel----------------//
    // Master Interface Write Response.
    ,   input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_BID
    // Write response. This signal indicates the status of the write transaction.
    ,   input wire [1 : 0] M_AXI_BRESP
    // Optional User-defined signal in the write response channel
    ,   input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER
    // Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
    ,   input wire  M_AXI_BVALID
    // Response ready. This signal indicates that the master
    // can accept a write response.
    ,   output wire  M_AXI_BREADY

    //----------------Read Address Channel----------------//
    // Master Interface Read Address.
    ,   output wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_ARID
    // Read address. This signal indicates the initial
    // address of a read burst transaction.
    ,   output wire [C_M_AXI_ADDR_WIDTH-1 : 0] M_AXI_ARADDR
    // Burst length. The burst length gives the exact number of transfers in a burst
    ,   output wire [7 : 0] M_AXI_ARLEN
    // Burst size. This signal indicates the size of each transfer in the burst
    ,   output wire [2 : 0] M_AXI_ARSIZE
    // Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
    ,   output wire [1 : 0] M_AXI_ARBURST
    // Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
    ,   output wire  M_AXI_ARLOCK
    // Memory type. This signal indicates how transactions
    // are required to progress through a system.
    ,   output wire [3 : 0] M_AXI_ARCACHE
    // Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
    ,   output wire [2 : 0] M_AXI_ARPROT
    // Quality of Service, QoS identifier sent for each read transaction
    ,   output wire [3 : 0] M_AXI_ARQOS
    // Optional User-defined signal in the read address channel.
    ,   output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER
    // Write address valid. This signal indicates that
    // the channel is signaling valid read address and control information
    ,   output wire  M_AXI_ARVALID
    // Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated control signals
    ,   input wire  M_AXI_ARREADY

    //----------------Read Data Channel----------------//
    // Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
    ,   input wire [C_M_AXI_ID_WIDTH-1 : 0] M_AXI_RID
    // Master Read Data
    ,   input wire [C_M_AXI_DATA_WIDTH-1 : 0] M_AXI_RDATA
    // Read response. This signal indicates the status of the read transfer
    ,   input wire [1 : 0] M_AXI_RRESP
    // Read last. This signal indicates the last transfer in a read burst
    ,   input wire  M_AXI_RLAST
    // Optional User-defined signal in the read address channel.
    ,   input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER
    // Read valid. This signal indicates that the channel
    // is signaling the required read data.
    ,   input wire  M_AXI_RVALID
    // Read ready. This signal indicates that the master can
    // accept the read data and response information.
    ,   output wire  M_AXI_RREADY

//----------------------------------------------------
// forward FIFO0 read interface
    ,   output  wire           	cmos0_frd_rdy  	
    ,   input   wire           	cmos0_frd_vld  	
    ,   input   wire [FDW-1:0] 	cmos0_frd_din  	
    ,   input   wire           	cmos0_frd_empty	
    ,   input   wire [FAW:0] 	cmos0_frd_cnt	

//----------------------------------------------------
// forward FIFO1 read interface
    ,   output  wire           	cmos1_frd_rdy  	
    ,   input   wire           	cmos1_frd_vld  	
    ,   input   wire [FDW-1:0] 	cmos1_frd_din  	
    ,   input   wire           	cmos1_frd_empty	
    ,   input   wire [FAW:0] 	cmos1_frd_cnt	

//----------------------------------------------------
// forward FIFO2 read interface
    ,   output  wire           	cmos2_frd_rdy  	
    ,   input   wire           	cmos2_frd_vld  	
    ,   input   wire [FDW-1:0] 	cmos2_frd_din  	
    ,   input   wire           	cmos2_frd_empty	
    ,   input   wire [FAW:0] 	cmos2_frd_cnt	

//----------------------------------------------------
// forward FIFO3 read interface
    ,   output  wire           	cmos3_frd_rdy  	
    ,   input   wire           	cmos3_frd_vld  	
    ,   input   wire [FDW-1:0] 	cmos3_frd_din  	
    ,   input   wire           	cmos3_frd_empty	
    ,   input   wire [FAW:0] 	cmos3_frd_cnt	

//----------------------------------------------------
// forward FIFO4 read interface
    ,   output  wire           	cmos4_frd_rdy  	
    ,   input   wire           	cmos4_frd_vld  	
    ,   input   wire [FDW-1:0] 	cmos4_frd_din  	
    ,   input   wire           	cmos4_frd_empty	
    ,   input   wire [FAW:0] 	cmos4_frd_cnt	

//----------------------------------------------------
// backward FIFO write interface
    ,   input   wire           	video_bwr_rdy
    ,   output  reg            	video_bwr_vld
    ,   output  reg  [FDW-1:0] 	video_bwr_din
    ,   input   wire           	video_bwr_empty
    ,   input   wire [FAW:0] 	video_bwr_cnt

//----------------------------------------------------
// cmos burst handshake 
	,	input   wire           	cmos0_burst_valid	
	,	output	wire			cmos0_burst_ready
	,	input   wire           	cmos1_burst_valid	
	,	output	wire			cmos1_burst_ready
	,	input   wire           	cmos2_burst_valid	
	,	output	wire			cmos2_burst_ready	
	,	input   wire           	cmos3_burst_valid	
	,	output	wire			cmos3_burst_ready
	,	input   wire           	cmos4_burst_valid	
	,	output	wire			cmos4_burst_ready

//----------------------------------------------------
// video burst handshake 
	,	input   wire           	video_burst_valid
	,	output	reg				video_burst_ready

//----------------------------------------------------
// cmos interface 
	,	input	wire			cmos0_vsync
	,	input	wire			cmos1_vsync
	,	input	wire			cmos2_vsync
	,	input	wire			cmos3_vsync
	,	input	wire			cmos4_vsync

//----------------------------------------------------
// video interface 
	,	input	wire			video_vsync
);


	wire           	cmos_frd_rdy  	[0 : 4]	;
	wire           	cmos_frd_vld  	[0 : 4]	;
	wire [FDW-1:0] 	cmos_frd_din  	[0 : 4]	;
	wire           	cmos_frd_empty	[0 : 4]	;
	wire [FAW:0] 	cmos_frd_cnt	[0 : 4]	;

	assign	cmos0_frd_rdy  		=	cmos_frd_rdy  	[0]	;
	assign	cmos_frd_vld  	[0]	=	cmos0_frd_vld  		;
	assign	cmos_frd_din  	[0]	=	cmos0_frd_din  		;
	assign	cmos_frd_empty	[0]	=	cmos0_frd_empty		;
	assign	cmos_frd_cnt	[0]	=	cmos0_frd_cnt		;

	assign	cmos1_frd_rdy  		=	cmos_frd_rdy  	[1]	;
	assign	cmos_frd_vld  	[1]	=	cmos1_frd_vld  		;
	assign	cmos_frd_din  	[1]	=	cmos1_frd_din  		;
	assign	cmos_frd_empty	[1]	=	cmos1_frd_empty		;
	assign	cmos_frd_cnt	[1]	=	cmos1_frd_cnt		;

	assign	cmos2_frd_rdy  		=	cmos_frd_rdy  	[2]	;
	assign	cmos_frd_vld  	[2]	=	cmos2_frd_vld  		;
	assign	cmos_frd_din  	[2]	=	cmos2_frd_din  		;
	assign	cmos_frd_empty	[2]	=	cmos2_frd_empty		;
	assign	cmos_frd_cnt	[2]	=	cmos2_frd_cnt		;

	assign	cmos3_frd_rdy  		=	cmos_frd_rdy  	[3]	;
	assign	cmos_frd_vld  	[3]	=	cmos3_frd_vld  		;
	assign	cmos_frd_din  	[3]	=	cmos3_frd_din  		;
	assign	cmos_frd_empty	[3]	=	cmos3_frd_empty		;
	assign	cmos_frd_cnt	[3]	=	cmos3_frd_cnt		;

	assign	cmos4_frd_rdy  		=	cmos_frd_rdy  	[4]	;
	assign	cmos_frd_vld  	[4]	=	cmos4_frd_vld  		;
	assign	cmos_frd_din  	[4]	=	cmos4_frd_din  		;
	assign	cmos_frd_empty	[4]	=	cmos4_frd_empty		;
	assign	cmos_frd_cnt	[4]	=	cmos4_frd_cnt		;

	wire           	cmos_burst_valid	[0 : 4]	;
	reg				cmos_burst_ready	[0 : 4]	;

	assign	cmos_burst_valid[0]	= 	cmos0_burst_valid;
	assign	cmos_burst_valid[1]	= 	cmos1_burst_valid;
	assign	cmos_burst_valid[2]	= 	cmos2_burst_valid;
	assign	cmos_burst_valid[3]	= 	cmos3_burst_valid;
	assign	cmos_burst_valid[4]	= 	cmos4_burst_valid;
	assign	cmos0_burst_ready	=	cmos_burst_ready[0];
	assign	cmos1_burst_ready	=	cmos_burst_ready[1];
	assign	cmos2_burst_ready	=	cmos_burst_ready[2];
	assign	cmos3_burst_ready	=	cmos_burst_ready[3];
	assign	cmos4_burst_ready	=	cmos_burst_ready[4];

	wire			cmos_vsync [0 : 4];

	assign	cmos_vsync[0]	=	cmos0_vsync;
	assign	cmos_vsync[1]	=	cmos1_vsync;
	assign	cmos_vsync[2]	=	cmos2_vsync;
	assign	cmos_vsync[3]	=	cmos3_vsync;
	assign	cmos_vsync[4]	=	cmos4_vsync;

	// C_TRANSACTIONS_NUM is the width of the index counter for 
	// number of write or read transaction.
	localparam integer C_TRANSACTIONS_NUM = clogb2(C_M_AXI_BURST_LEN-1);
	//size of C_M_AXI_BURST_LEN length burst in bytes
	wire [C_TRANSACTIONS_NUM+4 : 0] 	burst_size_bytes;

	genvar i;
	integer j;

	parameter Cmos0_H = 640;
	parameter Cmos0_V = 360;
	parameter Cmos1_H = 640;
	parameter Cmos1_V = 360;
	parameter Cmos2_H = 640;
	parameter Cmos2_V = 240;
	parameter Cmos3_H = 640;
	parameter Cmos3_V = 240;
	parameter Cmos4_H = 640;
	parameter Cmos4_V = 240;
	
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr_video0;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr_video1;


	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr_cmos0;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr_cmos1;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr_cmos2;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr_cmos3;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr_cmos4;
	wire [C_M_AXI_ADDR_WIDTH-1 : 0]	axi_awaddr_cmos0_max;
	wire [C_M_AXI_ADDR_WIDTH-1 : 0]	axi_awaddr_cmos1_max;
	wire [C_M_AXI_ADDR_WIDTH-1 : 0]	axi_awaddr_cmos2_max;
	wire [C_M_AXI_ADDR_WIDTH-1 : 0]	axi_awaddr_cmos3_max;
	wire [C_M_AXI_ADDR_WIDTH-1 : 0]	axi_awaddr_cmos4_max;
	assign axi_awaddr_cmos0_max = Cmos0_H * Cmos0_V * 4 - Cmos0_H * 4;
	assign axi_awaddr_cmos1_max = Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 - Cmos1_H * 4;
	assign axi_awaddr_cmos2_max = Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 + Cmos2_H * Cmos2_V * 4 - Cmos2_H * 4;
	assign axi_awaddr_cmos3_max = Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 + Cmos2_H * Cmos2_V * 4 + Cmos3_H * Cmos3_V * 4 - Cmos3_H * 4;
	assign axi_awaddr_cmos4_max = Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 + Cmos2_H * Cmos2_V * 4 + Cmos3_H * Cmos3_V * 4 + Cmos4_H * Cmos4_V * 4 - Cmos4_H * 4;

	reg				cmos_vsync_d1[0:4];
	reg				cmos_vsync_d2[0:4];

	reg				video_vsync_d1;
	reg				video_vsync_d2;
	
	reg				cmos_wr_buffer[0:4];
	wire    [31:0]	BUFFER0_MAX;
	reg	 	[4:0]	current_write_cam = 0;
	
	assign BUFFER0_MAX = Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 + Cmos2_H * Cmos2_V * 4 + Cmos3_H * Cmos3_V * 4 + Cmos4_H * Cmos4_V * 4;

	generate for(i = 0; i < 5 ;i = i + 1) begin
		always @(posedge M_AXI_ACLK) begin
			if (M_AXI_ARESETN == 0) begin
				cmos_vsync_d1[i]	<=	0;
				cmos_vsync_d2[i]	<=	0;                             
			end                                                                               
			else begin  
				cmos_vsync_d1[i]	<=	cmos_vsync[i];
				cmos_vsync_d2[i]	<=	cmos_vsync_d1[i];                                                                 
			end                                                                      
		end   
	end
	endgenerate

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0) begin
			video_vsync_d1		<=	0;
			video_vsync_d2		<=	0;                             
		end                                                                               
		else begin  
			video_vsync_d1		<=	video_vsync;
			video_vsync_d2		<=	video_vsync_d1;                                                                 
		end                                                                      
	end   

	generate for(i = 0; i < 5 ;i = i + 1) begin
		always @(posedge M_AXI_ACLK) begin
			if (M_AXI_ARESETN == 0) begin
				cmos_wr_buffer[i]	<=	0;                         
			end                                                                               
			else if(cmos_vsync_d2[i] & !cmos_vsync_d1[i]) begin  
				cmos_wr_buffer[i]	<=	~cmos_wr_buffer[i];                                                                
			end                                                                      
		end   
	end
	endgenerate


	wire			frd_rdy;

	generate 
		for(i = 0; i < 5; i = i + 1) begin
			assign	cmos_frd_rdy[i] = frd_rdy & current_write_cam[i];
		end
	endgenerate


	// function called clogb2 that returns an integer which has the
	//value of the ceiling of the log base 2

	  // function called clogb2 that returns an integer which has the 
	  // value of the ceiling of the log base 2.                      
	  function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
	  endfunction                                                     


	// Burst length for transactions, in C_M_AXI_DATA_WIDTHs.
	// Non-2^n lengths will eventually cause bursts across 4K address boundaries.
	 localparam integer C_MASTER_LENGTH	= 12;
	// total number of burst transfers is master length divided by burst length and burst size
	 localparam integer C_NO_BURSTS_REQ = C_MASTER_LENGTH-clogb2((C_M_AXI_BURST_LEN*C_M_AXI_DATA_WIDTH/8)-1);
	// Example State machine to initialize counter, initialize write transactions, 
	// initialize read transactions and comparison of read data with the 
	// written data words.
	parameter [3:0] IDLE = 4'b0000, // This state initiates AXI4Lite transaction 
			// after the state machine changes state to INIT_WRITE 
			// when there is 0 to 1 transition on INIT_AXI_TXN
		INIT_WRITE   = 4'b0001, // This state initializes write transaction,
			// once writes are done, the state machine 
			// changes state to INIT_READ 
		INIT_READ_REGION_A = 4'b0010,
		INIT_READ_REGION_B = 4'b0011;


	 reg [3:0] mst_exec_state;

	// AXI4LITE signals
	//AXI4 internal temp signals
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_awaddr;
	reg  	axi_awvalid;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	axi_wdata;
	reg  	axi_wlast;
	reg  	axi_wvalid;
	reg  	axi_bready;
	reg [C_M_AXI_ADDR_WIDTH-1 : 0] 	axi_araddr;
	reg  	axi_arvalid;
	reg  	axi_rready;
	//write beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	write_index;
	//read beat count in a burst
	reg [C_TRANSACTIONS_NUM : 0] 	read_index;
	//The burst counters are used to track the number of burst transfers of C_M_AXI_BURST_LEN burst length needed to transfer 2^C_MASTER_LENGTH bytes of data.
	reg [C_NO_BURSTS_REQ : 0] 	write_burst_counter;
	reg [C_NO_BURSTS_REQ : 0] 	write_burst_counter_max;
	reg [C_NO_BURSTS_REQ : 0] 	read_burst_counter;
	reg [C_NO_BURSTS_REQ : 0] 	read_burst_counter_max;
	reg  	start_single_burst_write;
	reg  	start_single_burst_read;
	reg  	writes_done;
	reg  	reads_done;
	reg  	error_reg;
	reg  	compare_done;
	reg  	read_mismatch;
	reg  	burst_write_active;
	reg  	burst_read_active;
	reg [C_M_AXI_DATA_WIDTH-1 : 0] 	expected_rdata;
	//Interface response error flags
	wire  	write_resp_error;
	wire  	read_resp_error;
	wire  	wnext;
	wire  	rnext;
	reg  	init_txn_edge;


	// I/O Connections assignments

	//I/O Connections. Write Address (AW)
	assign M_AXI_AWID	= 'b0;
	//The AXI address is a concatenation of the target base address + active offset range
	assign M_AXI_AWADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_awaddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_AWLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^SIZE bytes, otherwise narrow bursts are used
	assign M_AXI_AWSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_AWBURST	= 2'b01;
	assign M_AXI_AWLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_AWCACHE	= 4'b0010;
	assign M_AXI_AWPROT	= 3'h0;
	assign M_AXI_AWQOS	= 4'h0;
	assign M_AXI_AWUSER	= 'b1;
	assign M_AXI_AWVALID	= axi_awvalid;
	//Write Data(W)
	assign M_AXI_WDATA	= axi_wdata;
	//All bursts are complete and aligned in this example
	assign M_AXI_WSTRB	= {(C_M_AXI_DATA_WIDTH/8){1'b1}};
	assign M_AXI_WLAST	= axi_wlast;
	assign M_AXI_WUSER	= 'b0;
	assign M_AXI_WVALID	= axi_wvalid;
	//Write Response (B)
	assign M_AXI_BREADY	= axi_bready;
	//Read Address (AR)
	assign M_AXI_ARID	= 'b0;
	assign M_AXI_ARADDR	= C_M_TARGET_SLAVE_BASE_ADDR + axi_araddr;
	//Burst LENgth is number of transaction beats, minus 1
	assign M_AXI_ARLEN	= C_M_AXI_BURST_LEN - 1;
	//Size should be C_M_AXI_DATA_WIDTH, in 2^n bytes, otherwise narrow bursts are used
	assign M_AXI_ARSIZE	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	//INCR burst type is usually used, except for keyhole bursts
	assign M_AXI_ARBURST	= 2'b01;
	assign M_AXI_ARLOCK	= 1'b0;
	//Update value to 4'b0011 if coherent accesses to be used via the Zynq ACP port. Not Allocated, Modifiable, not Bufferable. Not Bufferable since this example is meant to test memory, not intermediate cache. 
	assign M_AXI_ARCACHE	= 4'b0010;
	assign M_AXI_ARPROT	= 3'h0;
	assign M_AXI_ARQOS	= 4'h0;
	assign M_AXI_ARUSER	= 'b1;
	assign M_AXI_ARVALID	= axi_arvalid;
	//Read and Read Response (R)
	assign M_AXI_RREADY	= axi_rready;
	//Example design I/O
	assign TXN_DONE	= compare_done;
	//Burst size in bytes
	assign burst_size_bytes	= C_M_AXI_BURST_LEN * C_M_AXI_DATA_WIDTH / 8;
	wire  	init_read_pulse;
	assign 	init_read_pulse	= video_vsync_d2 && !video_vsync_d1;
	wire 	init_pulse;
	assign init_pulse = 0;

	//--------------------
	//Write Address Channel
	//--------------------

	// The purpose of the write address channel is to request the address and 
	// command information for the entire transaction.  It is a single beat
	// of information.

	// The AXI4 Write address channel in this example will continue to initiate
	// write commands as fast as it is allowed by the slave/interconnect.
	// The address will be incremented on each accepted address transaction,
	// by burst_size_byte to point to the next address. 

	always @(posedge M_AXI_ACLK) begin                                                                    
	    if (M_AXI_ARESETN == 0 || init_pulse == 1'b1 ) begin                                                            
			axi_awvalid <= 1'b0;                                           
		end                                                              
	    // If previously not valid , start next transaction                
	    else if (~axi_awvalid && start_single_burst_write) begin                                                            
			axi_awvalid <= 1'b1;                                           
		end                                                              
	    /* Once asserted, VALIDs cannot be deasserted, so axi_awvalid      
	    must wait until transaction is accepted */                         
	    else if (M_AXI_AWREADY && axi_awvalid) begin                                                            
	        axi_awvalid <= 1'b0;                                           
		end                                                              
	    else begin                                                             
	      	axi_awvalid <= axi_awvalid;  
		end                                    
	end                                                                

	                                                                       
	// Next address after AWREADY indicates previous address acceptance    
	always @(posedge M_AXI_ACLK || init_pulse == 1'b1) begin                                                                
		if (M_AXI_ARESETN == 0) begin                                                            
			axi_awaddr <= 1'b0;                                             
		end
		else if (cmos_burst_ready[0] & cmos_burst_valid[0]) begin
			axi_awaddr	<=	axi_awaddr_cmos0 + (cmos_wr_buffer[0] ? BUFFER0_MAX : 0);
		end
		else if (cmos_burst_ready[1] & cmos_burst_valid[1]) begin
			axi_awaddr	<=	axi_awaddr_cmos1 + Cmos0_H * Cmos0_V * 4 + (cmos_wr_buffer[1] ? BUFFER0_MAX : 0);
		end
		else if (cmos_burst_ready[2] & cmos_burst_valid[2]) begin
			axi_awaddr	<=	axi_awaddr_cmos2 + Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 + (cmos_wr_buffer[2] ? BUFFER0_MAX : 0);
		end
		else if (cmos_burst_ready[3] & cmos_burst_valid[3]) begin
			axi_awaddr	<=	axi_awaddr_cmos3 + Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 + Cmos2_H * Cmos2_V * 4 + (cmos_wr_buffer[3] ? BUFFER0_MAX : 0);
		end
		else if (cmos_burst_ready[4] & cmos_burst_valid[4]) begin
			axi_awaddr	<=	axi_awaddr_cmos4 + Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 + Cmos2_H * Cmos2_V * 4 + Cmos3_H * Cmos3_V * 4 + (cmos_wr_buffer[4] ? BUFFER0_MAX : 0);
		end
		else if (M_AXI_AWREADY && axi_awvalid) begin                                                            
			axi_awaddr <= axi_awaddr + burst_size_bytes;                   
		end                                                              
		else begin                                                           
			axi_awaddr <= axi_awaddr;
		end                                        
	end                                                                


	//--------------------
	//Write Data Channel
	//--------------------

	//The write data will continually try to push write data across the interface.

	//The amount of data accepted will depend on the AXI slave and the AXI
	//Interconnect settings, such as if there are FIFOs enabled in interconnect.

	//Note that there is no explicit timing relationship to the write address channel.
	//The write channel has its own throttling flag, separate from the AW channel.

	//Synchronization between the channels must be determined by the user.

	//The simpliest but lowest performance would be to only issue one address write
	//and write data burst at a time.

	//In this example they are kept in sync by using the same address increment
	//and burst sizes. Then the AW and W channels have their transactions measured
	//with threshold counters as part of the user logic, to make sure neither 
	//channel gets too far ahead of each other.

	//Forward movement occurs when the write channel is valid and ready

	assign wnext = M_AXI_WREADY & axi_wvalid;                                   
	                                                                                    
	// WVALID logic, similar to the axi_awvalid always block above                      
	always @(posedge M_AXI_ACLK) begin                                                                             
		if (M_AXI_ARESETN == 0 || init_pulse == 1'b1 ) begin                                                                         
			axi_wvalid <= 1'b0;                                                         
		end                                                                           
		// If previously not valid, start next transaction                              
		//else if (~axi_wvalid && start_single_burst_write) begin                      
		else if (~axi_wvalid && M_AXI_AWREADY && axi_awvalid) begin                                                                         
			axi_wvalid <= 1'b1;                                                         
		end                                                                           
		/* If WREADY and too many writes, throttle WVALID                               
		Once asserted, VALIDs cannot be deasserted, so WVALID                           
		must wait until burst is complete with WLAST */                                 
		else if (wnext && axi_wlast) begin                                                    
			axi_wvalid <= 1'b0;           
		end                                                
		else begin                                                                            
			axi_wvalid <= axi_wvalid;
		end                                                     
	end                                                                               


	//WLAST generation on the MSB of a counter underflow                                
	// WVALID logic, similar to the axi_awvalid always block above                      
	always @(posedge M_AXI_ACLK) begin                                                                             
		if (M_AXI_ARESETN == 0 || init_pulse == 1'b1 ) begin                                                                         
			axi_wlast <= 1'b0;                                                          
		end                                                                           
		// axi_wlast is asserted when the write index                                   
		// count reaches the penultimate count to synchronize                           
		// with the last write data when write_index is b1111                           
		// else if (&(write_index[C_TRANSACTIONS_NUM-1:1])&& ~write_index[0] && wnext)  
		else if (((write_index == C_M_AXI_BURST_LEN-2 && C_M_AXI_BURST_LEN >= 2) && wnext) || (C_M_AXI_BURST_LEN == 1 )) begin                                                                         
			axi_wlast <= 1'b1;                                                          
		end                                                                           
		// Deassrt axi_wlast when the last write data has been                          
		// accepted by the slave with a valid response                                  
		else if (wnext) begin                                                               
			axi_wlast <= 1'b0; 
		end                                                           
		else if (axi_wlast && C_M_AXI_BURST_LEN == 1) begin                                 
			axi_wlast <= 1'b0;                             
		end                               
		else begin                                                                            
			axi_wlast <= axi_wlast;               
		end                                        
	end                                                                               


	/* Burst length counter. Uses extra counter register bit to indicate terminal       
	 count to reduce decode logic */                                                    
	always @(posedge M_AXI_ACLK) begin                                                                             
		if (M_AXI_ARESETN == 0 || init_pulse == 1'b1 || start_single_burst_write == 1'b1) begin                                                                         
			write_index <= 0;                                                           
		end                                                                           
		else if (wnext && (write_index != C_M_AXI_BURST_LEN-1)) begin                                                                         
			write_index <= write_index + 1;                                             
		end                                                                           
		else begin
			write_index <= write_index;
		end                                               
	end                                                                               


	/* Write Data Generator                                                             
	 Data pattern is only a simple incrementing count from 0 for each burst  */         
	always @(posedge M_AXI_ACLK) begin                                                                             
		if (M_AXI_ARESETN == 0 || init_pulse == 1'b1) begin                                                        
			axi_wdata <= 0;                                  
		end                           
		//else if (wnext && axi_wlast)                                                  
		//  axi_wdata <= 'b0;      
		else if (M_AXI_AWREADY && axi_awvalid) begin
			case(current_write_cam)
				5'b00001: 	axi_wdata <= cmos_frd_din[0];
				5'b00010: 	axi_wdata <= cmos_frd_din[1];
				5'b00100: 	axi_wdata <= cmos_frd_din[2];
				5'b01000: 	axi_wdata <= cmos_frd_din[3];
				5'b10000: 	axi_wdata <= cmos_frd_din[4];
				default:	axi_wdata <= 0;
			endcase
		end                                                     
		else if (wnext) begin         
			case(current_write_cam)
				5'b00001: 	axi_wdata <= cmos_frd_din[0];
				5'b00010: 	axi_wdata <= cmos_frd_din[1];
				5'b00100: 	axi_wdata <= cmos_frd_din[2];
				5'b01000: 	axi_wdata <= cmos_frd_din[3];
				5'b10000: 	axi_wdata <= cmos_frd_din[4];
				default:	axi_wdata <= 0;
			endcase
		end                                                   
		else begin                                                                           
			axi_wdata <= axi_wdata;
		end                                                       
	end    

	assign	frd_rdy = (!axi_wlast) && ((M_AXI_AWREADY && axi_awvalid) || wnext);                                                   


	//----------------------------
	//Write Response (B) Channel
	//----------------------------

	//The write response channel provides feedback that the write has committed
	//to memory. BREADY will occur when all of the data and the write address
	//has arrived and been accepted by the slave.

	//The write issuance (number of outstanding write addresses) is started by 
	//the Address Write transfer, and is completed by a BREADY/BRESP.

	//While negating BREADY will eventually throttle the AWREADY signal, 
	//it is best not to throttle the whole data channel this way.

	//The BRESP bit [1] is used indicate any errors from the interconnect or
	//slave for the entire write burst. This example will capture the error 
	//into the ERROR output. 

	always @(posedge M_AXI_ACLK) begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_pulse == 1'b1 ) begin                                                             
			axi_bready <= 1'b0;                                             
		end                                                               
	    // accept/acknowledge bresp with axi_bready by the master           
	    // when M_AXI_BVALID is asserted by slave                           
	    else if (M_AXI_BVALID && ~axi_bready) begin                                                             
			axi_bready <= 1'b1;                                             
		end                                                               
	    // deassert after one clock cycle                                   
	    else if (axi_bready) begin                                                             
			axi_bready <= 1'b0;                                             
		end                                                               
	    // retain the previous value                                        
	    else begin                                                               
	      	axi_bready <= axi_bready;  
		end                                       
	end                                                                   
	                                                                        
	                                                                        
	//Flag any write response errors                                        
	assign write_resp_error = axi_bready & M_AXI_BVALID & M_AXI_BRESP[1]; 


	//----------------------------
	//Read Address Channel
	//----------------------------

	//The Read Address Channel (AW) provides a similar function to the
	//Write Address channel- to provide the tranfer qualifiers for the burst.

	//In this example, the read address increments in the same
	//manner as the write address channel.

	always @(posedge M_AXI_ACLK) begin
		if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1 ) begin                                                          
			axi_arvalid <= 1'b0;                                         
		end                                                            
		// If previously not valid, start next transaction              
		else if (~axi_arvalid && start_single_burst_read) begin                                                          
			axi_arvalid <= 1'b1;                                         
		end                                                            
		else if (M_AXI_ARREADY && axi_arvalid) begin                                                          
			axi_arvalid <= 1'b0;                                         
		end                                                            
		else begin                                                        
			axi_arvalid <= axi_arvalid;          
		end                          
	end                                                                


	// Next address after ARREADY indicates previous address acceptance  
	always @(posedge M_AXI_ACLK) begin                                                              
	    if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1) begin                                                          
	        axi_araddr <= 	'b0;                                           
		end
		else if(video_burst_ready & video_burst_valid) begin
			if(axi_araddr_video0 >= (Cmos0_H * Cmos0_V * 4)) begin
				axi_araddr	<=	axi_araddr_video0 + (cmos_wr_buffer[1] ? 0 : BUFFER0_MAX);
			end
			else begin
				axi_araddr	<=	axi_araddr_video0 + (cmos_wr_buffer[0] ? 0 : BUFFER0_MAX);
			end
		end
		else if((mst_exec_state  == INIT_READ_REGION_A) & reads_done) begin
			if(axi_araddr_video1 >=  (Cmos2_H * Cmos2_V * 4 + Cmos3_H * Cmos3_V * 4)) begin
				axi_araddr	<=	axi_araddr_video1 + (cmos_wr_buffer[4] ? 0 : BUFFER0_MAX) + (Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4);
			end
			else if(axi_araddr_video1 >=  (Cmos2_H * Cmos2_V * 4)) begin
				axi_araddr	<=	axi_araddr_video1 + (cmos_wr_buffer[3] ? 0 : BUFFER0_MAX) + (Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4);
			end
			else begin
				axi_araddr	<=	axi_araddr_video1 + (cmos_wr_buffer[2] ? 0 : BUFFER0_MAX) + (Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4);
			end
		end
	    else if (M_AXI_ARREADY && axi_arvalid) begin                                                          
	    	axi_araddr 	<= 	axi_araddr + burst_size_bytes;
		end                                                            
	    else begin                                                            
	      	axi_araddr 	<= 	axi_araddr;       
		end                               
	end                                                                


	//--------------------------------
	//Read Data (and Response) Channel
	//--------------------------------

	// Forward movement occurs when the channel is valid and ready   
	assign rnext = M_AXI_RVALID && axi_rready;                            


	// Burst length counter. Uses extra counter register bit to indicate    
	// terminal count to reduce decode logic                                
	always @(posedge M_AXI_ACLK) begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1 || start_single_burst_read) begin                                                             
			read_index <= 0;                                                
		end                                                               
	    else if (rnext && (read_index != C_M_AXI_BURST_LEN-1)) begin                                                             
	     	read_index <= read_index + 1;                                   
		end                                                               
	    else begin                                                               
	      	read_index <= read_index;  
		end                                       
	end
                                
	always @(posedge M_AXI_ACLK) begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1) begin
	        video_bwr_vld	<=	0;
			video_bwr_din	<=	0;   	                                  
		end
		else if(rnext)begin
	        video_bwr_vld	<=	1;
			video_bwr_din	<=	M_AXI_RDATA;   
		end
		else begin
	        video_bwr_vld	<=	0;
			video_bwr_din	<=	0;   	
		end
	end


	/*                                                                      
	 The Read Data channel returns the results of the read request          
	                                                                        
	 In this example the data checker is always able to accept              
	 more data, so no need to throttle the RREADY signal                    
	 */                                                                     
	always @(posedge M_AXI_ACLK) begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1 ) begin                                                             
			axi_rready <= 1'b0;                                             
		end                                                               
	    // accept/acknowledge rdata/rresp with axi_rready by the master     
	    // when M_AXI_RVALID is asserted by slave                           
	    else if (M_AXI_RVALID) begin                                      
			if (M_AXI_RLAST && axi_rready) begin                                  
	            axi_rready <= 1'b0;                  
			end                                    
			else begin                                 
				axi_rready <= 1'b1;                 
			end                                   
		end
	    // retain the previous value                 
	end                                            
	                                                                        
	//Check received read data against data generator                       
	always @(posedge M_AXI_ACLK) begin                                                                 
	    if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1) begin
	        read_mismatch <= 1'b0;                                          
		end
	    //Only check data when RVALID is active                             
	    else if (rnext && (M_AXI_RDATA != expected_rdata)) begin                                                             
	        read_mismatch <= 1'b1;                                          
		end
	    else begin
	      	read_mismatch <= 1'b0;             
		end
	end                                                                   
	                                                                        
	//Flag any read response errors                                         
	assign read_resp_error = axi_rready & M_AXI_RVALID & M_AXI_RRESP[1];  


	//----------------------------------------
	//Example design read check data generator
	//-----------------------------------------

	//Generate expected read data to check against actual read data

	always @(posedge M_AXI_ACLK) begin                                                  
		if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1) begin// || M_AXI_RLAST)             
			expected_rdata <= 'b1;                            
		end
		else if (M_AXI_RVALID && axi_rready) begin 
			expected_rdata <= expected_rdata + 1; 
		end            
		else begin                                                  
			expected_rdata <= expected_rdata;      
		end           
	end                                                    


	//----------------------------------
	//Example design error register
	//----------------------------------

	//Register and hold any data mismatches, or read/write interface errors 

	always @(posedge M_AXI_ACLK) begin                                                              
		if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1) begin                                                          
			error_reg <= 1'b0;                                           
		end                                                            
		else if (read_mismatch || write_resp_error || read_resp_error) begin                                                          
			error_reg <= 1'b1;                                           
		end                                                            
		else begin                                                            
			error_reg <= error_reg;        
		end                                
	end                                                                


	//--------------------------------
	//Example design throttling
	//--------------------------------

	// For maximum port throughput, this user example code will try to allow
	// each channel to run as independently and as quickly as possible.

	// However, there are times when the flow of data needs to be throtted by
	// the user application. This example application requires that data is
	// not read before it is written and that the write channels do not
	// advance beyond an arbitrary threshold (say to prevent an 
	// overrun of the current read address by the write address).

	// From AXI4 Specification, 13.13.1: "If a master requires ordering between 
	// read and write transactions, it must ensure that a response is received 
	// for the previous transaction before issuing the next transaction."

	// This example accomplishes this user application throttling through:
	// -Reads wait for writes to fully complete
	// -Address writes wait when not read + issued transaction counts pass 
	// a parameterized threshold
	// -Writes wait when a not read + active data burst count pass 
	// a parameterized threshold

	// write_burst_counter counter keeps track with the number of burst transaction initiated            
	// against the number of burst transactions the master needs to initiate                                   
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_pulse == 1'b1 ) begin                                                                                                 
			write_burst_counter <= 'b0;                                                                         
		end                                                                                                   
		else if (M_AXI_AWREADY && axi_awvalid) begin                                                                                                 
			if (write_burst_counter <= write_burst_counter_max) begin                                                         
				write_burst_counter <= write_burst_counter + 1'b1;        
			end                                  
		end
		else if(writes_done)begin                                                                                                  
			write_burst_counter <= 0;         
		end                                                  
	end                                                                                                       

	// read_burst_counter counter keeps track with the number of burst transaction initiated                   
	// against the number of burst transactions the master needs to initiate                                   
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1) begin                                                                                                 
			read_burst_counter <= 'b0;                                                                          
		end                                                                                                   
		else if (M_AXI_ARREADY && axi_arvalid) begin                                                                                                 
			if (read_burst_counter <= read_burst_counter_max) begin
				read_burst_counter <= read_burst_counter + 1'b1;
			end                                                                                               
		end                                                                                                   
		else if(reads_done)begin                                                                                                  
			read_burst_counter <= 0;     
		end                                                        
	end

//----------------------------------------------------------
//read address for cmos
	always @ ( posedge M_AXI_ACLK) begin
		if ((M_AXI_ARESETN == 1'b0) | (cmos_vsync_d2[0] & !cmos_vsync_d1[0])) begin
			axi_awaddr_cmos0	<=	0;
		end
		else if(cmos_burst_valid[0] & cmos_burst_ready[0]) begin
			axi_awaddr_cmos0 	<=	(axi_awaddr_cmos0 >= (Cmos0_H * Cmos0_V * 4 - Cmos0_H * 4)) ? 0 : (axi_awaddr_cmos0 + Cmos0_H * 4);
		end
	end
	
	always @ ( posedge M_AXI_ACLK) begin
		if ((M_AXI_ARESETN == 1'b0) | (cmos_vsync_d2[1] & !cmos_vsync_d1[1])) begin
			axi_awaddr_cmos1	<=	0;
		end
		else if(cmos_burst_valid[1] & cmos_burst_ready[1]) begin
			axi_awaddr_cmos1 	<=	(axi_awaddr_cmos1 >= (Cmos1_H * Cmos1_V * 4 - Cmos1_H * 4)) ? 0 : (axi_awaddr_cmos1 + Cmos1_H * 4);
		end
	end
	
	always @ ( posedge M_AXI_ACLK) begin
		if ((M_AXI_ARESETN == 1'b0) | (cmos_vsync_d2[2] & !cmos_vsync_d1[2])) begin
			axi_awaddr_cmos2	<=	0;
		end
		else if(cmos_burst_valid[2] & cmos_burst_ready[2]) begin
			axi_awaddr_cmos2 	<=	(axi_awaddr_cmos2 >= (Cmos2_H * Cmos2_V * 4 - Cmos2_H * 4)) ? 0 : (axi_awaddr_cmos2 + Cmos2_H * 4);
		end
	end
	
	always @ ( posedge M_AXI_ACLK) begin
		if ((M_AXI_ARESETN == 1'b0) | (cmos_vsync_d2[3] & !cmos_vsync_d1[3])) begin
			axi_awaddr_cmos3	<=	0;
		end
		else if(cmos_burst_valid[3] & cmos_burst_ready[3]) begin
			axi_awaddr_cmos3 	<=	(axi_awaddr_cmos3 >= (Cmos3_H * Cmos3_V * 4 - Cmos3_H * 4)) ? 0 : (axi_awaddr_cmos3 + Cmos3_H * 4);
		end
	end
	
	always @ ( posedge M_AXI_ACLK) begin
		if ((M_AXI_ARESETN == 1'b0) | (cmos_vsync_d2[4] & !cmos_vsync_d1[4])) begin
			axi_awaddr_cmos4	<=	0;
		end
		else if(cmos_burst_valid[4] & cmos_burst_ready[4]) begin
			axi_awaddr_cmos4 	<=	(axi_awaddr_cmos4 >= (Cmos4_H * Cmos4_V * 4 - Cmos4_H * 4)) ? 0 : (axi_awaddr_cmos4 + Cmos4_H * 4);
		end
	end

//----------------------------------------------------------
//read address for video
	always @ ( posedge M_AXI_ACLK) begin
		if ((M_AXI_ARESETN == 1'b0) || init_read_pulse == 1'b1) begin
			axi_araddr_video0	<=	0;
			axi_araddr_video1	<=	0;
		end
		else if((mst_exec_state  == INIT_READ_REGION_B) & reads_done) begin
			axi_araddr_video0 <= (axi_araddr_video0 >= (Cmos0_H * Cmos0_V * 4 + Cmos1_H * Cmos1_V * 4 - Cmos1_H * 4)) ? 0 : (axi_araddr_video0 + Cmos0_H * 4);
			axi_araddr_video1 <= (axi_araddr_video1 >= (Cmos2_H * Cmos2_V * 4 + Cmos3_H * Cmos3_V * 4 + Cmos4_H * Cmos4_V * 4 - Cmos4_H * 4)) ? 0 : (axi_araddr_video1 + Cmos2_H * 4);
		end
	end 
	//implement master command interface state machine

	always @ ( posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 1'b0) begin                                                                                                 
			// reset condition                                                                                  
			// All the signals are assigned default values under reset condition                                
			mst_exec_state      <= IDLE;                                                                
			start_single_burst_write <= 1'b0;                                                                   
			start_single_burst_read  <= 1'b0;
			current_write_cam	<=	0;
			for(j = 0; j < 5; j = j + 1)begin
				cmos_burst_ready[j]	<=	0;
			end
			write_burst_counter_max	<=	0;

			video_burst_ready <= 0;
			read_burst_counter_max	<=	0;
		end
		else begin                                                                                                 

			// state transition                                                                                 
			case (mst_exec_state)                                                                               
																												
				IDLE:                                                                                     
				// This state is responsible to wait for user defined C_M_START_COUNT                           
				// number of clock cycles.
				if(video_burst_valid) begin
					mst_exec_state  <= INIT_READ_REGION_A;
					read_burst_counter_max	<=	(Cmos0_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
					video_burst_ready <= 1;
				end
				else if(cmos_burst_valid[0] | cmos_burst_valid[1] | cmos_burst_valid[2] | cmos_burst_valid[3] | cmos_burst_valid[4]) begin
					if(cmos_burst_valid[0]) begin
						mst_exec_state  <= INIT_WRITE;
						write_burst_counter_max	<=	(Cmos0_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
						cmos_burst_ready[0] <= 1'b1;
						current_write_cam <= 5'b00001;
					end
					else if(cmos_burst_valid[1]) begin
						mst_exec_state  <= INIT_WRITE;
						write_burst_counter_max	<=	(Cmos1_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
						cmos_burst_ready[1] <= 1'b1;
						current_write_cam <= 5'b00010;
					end
					else if(cmos_burst_valid[2]) begin
						mst_exec_state  <= INIT_WRITE;
						write_burst_counter_max	<=	(Cmos2_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
						cmos_burst_ready[2] <= 1'b1;
						current_write_cam <= 5'b00100;
					end
					else if(cmos_burst_valid[3]) begin
						mst_exec_state  <= INIT_WRITE;
						write_burst_counter_max	<=	(Cmos3_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
						cmos_burst_ready[3] <= 1'b1;
						current_write_cam <= 5'b01000;
					end
					else if(cmos_burst_valid[4]) begin
						mst_exec_state  <= INIT_WRITE;
						write_burst_counter_max	<=	(Cmos4_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
						cmos_burst_ready[4] <= 1'b1;
						current_write_cam <= 5'b10000;
					end
					else begin
						mst_exec_state  <= IDLE;
					end
/*
					case({cmos_burst_valid[0] , cmos_burst_valid[1] , cmos_burst_valid[2]})
						3'b100,3'b101,3'b110,3'b111 : begin
							mst_exec_state  <= INIT_WRITE;
							write_burst_counter_max	<=	(Cmos0_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
							cmos_burst_ready[0] <= 1'b1;
							current_write_cam <= 3'b001;
						end
						3'b010,3'b011 : begin
							mst_exec_state  <= INIT_WRITE;
							write_burst_counter_max	<=	(Cmos1_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
							cmos_burst_ready[1] <= 1'b1;
							current_write_cam <= 3'b010;
						end
						3'b001: begin
							mst_exec_state  <= INIT_WRITE;
							write_burst_counter_max	<=	(Cmos2_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
							cmos_burst_ready[2] <= 1'b1;
							current_write_cam <= 3'b100;
						end
						default: begin
							mst_exec_state  <= IDLE;
						end
					endcase
*/
				end                                                                                           
				else begin
					mst_exec_state  <= IDLE;                                                            
				end

				INIT_WRITE:                                                                                       
				// This state is responsible to issue start_single_write pulse to                               
				// initiate a write transaction. Write transactions will be                                     
				// issued until burst_write_active signal is asserted.                                          
				// write controller                                                                             
				if (writes_done) begin                                                                                         
					mst_exec_state <= IDLE;                                                              
				end                                                                                           
				else begin                                                                                         
					mst_exec_state  <= INIT_WRITE;                                                              
	
					for(j = 0; j < 5; j = j + 1)begin
						cmos_burst_ready[j]	<=	0;
					end
					
					if (~axi_awvalid && ~start_single_burst_write && ~burst_write_active) begin                                                                                     
						start_single_burst_write <= 1'b1;                                                       
					end                                                                                       
					else begin                                                                                     
						start_single_burst_write <= 1'b0; //Negate to generate a pulse                          
					end                                                                                       
				end
				INIT_READ_REGION_A : begin
					if (reads_done) begin
						mst_exec_state <= INIT_READ_REGION_B;
						read_burst_counter_max	<=	(Cmos1_H * 32) / (C_M_AXI_DATA_WIDTH * C_M_AXI_BURST_LEN);
					end                                                                                           
					else begin                                                                                         
						mst_exec_state  <= INIT_READ_REGION_A;
						video_burst_ready <= 0;
						if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read) begin                                                                                     
							start_single_burst_read <= 1'b1;                                                        
						end                                                                                       
					else
						start_single_burst_read <= 1'b0; //Negate to generate a pulse                                                              
					end
				end
				INIT_READ_REGION_B : begin
					if (reads_done) begin
						mst_exec_state <= IDLE;
					end                                                                                           
					else begin                                                                                         
						mst_exec_state  <= INIT_READ_REGION_B;
						if (~axi_arvalid && ~burst_read_active && ~start_single_burst_read) begin                                                                                     
							start_single_burst_read <= 1'b1;                                                        
						end                                                                                       
					else
						start_single_burst_read <= 1'b0; //Negate to generate a pulse                                       
					end
				end
				default : begin                                                                                           
					mst_exec_state  <= IDLE;                                                              
				end                                                                                             
			endcase                                                                                             
		end                                                                                                   
	end //MASTER_EXECUTION_PROC                                                                               


	// burst_write_active signal is asserted when there is a burst write transaction                          
	// is initiated by the assertion of start_single_burst_write. burst_write_active                          
	// signal remains asserted until the burst write is accepted by the slave                                 
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_pulse == 1'b1)                                                                                 
			burst_write_active <= 1'b0;                                                                           
																												
		//The burst_write_active is asserted when a write burst transaction is initiated                        
		else if (start_single_burst_write)                                                                      
			burst_write_active <= 1'b1;                                                                           
		else if (M_AXI_BVALID && axi_bready)                                                                    
			burst_write_active <= 0;                                                                              
	end                                                                                                       

	 // Check for last write completion.                                                                        
	                                                                                                            
	 // This logic is to qualify the last write count with the final write                                      
	 // response. This demonstrates how to confirm that a write has been                                        
	 // committed.                                                                                              
	                                                                                                            
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_pulse == 1'b1)                                                                                 
			writes_done <= 1'b0;                                                                                  
																												
		//The writes_done should be associated with a bready response                                           
		//else if (M_AXI_BVALID && axi_bready && (write_burst_counter == {(C_NO_BURSTS_REQ-1){1}}) && axi_wlast)
		else if (M_AXI_BVALID && (write_burst_counter == write_burst_counter_max) && axi_bready)                          
			writes_done <= 1'b1;                                                                                  
		else                                                                                                    
			writes_done <= 0;                                                                           
	end                                                                                                     
	                                                                                                            
	// burst_read_active signal is asserted when there is a burst write transaction                           
	// is initiated by the assertion of start_single_burst_write. start_single_burst_read                     
	// signal remains asserted until the burst read is accepted by the master                                 
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1)                                                                                 
			burst_read_active <= 1'b0;                                                                            
																												
		//The burst_write_active is asserted when a write burst transaction is initiated                        
		else if (start_single_burst_read)                                                                       
			burst_read_active <= 1'b1;                                                                            
		else if (M_AXI_RVALID && axi_rready && M_AXI_RLAST)                                                     
			burst_read_active <= 0;                                                                               
	end                                                                                                     


	// Check for last read completion.                                                                         
																											
	// This logic is to qualify the last read count with the final read                                        
	// response. This demonstrates how to confirm that a read has been                                         
	// committed.                                                                                              
																											
	always @(posedge M_AXI_ACLK) begin                                                                                                     
		if (M_AXI_ARESETN == 0 || init_read_pulse == 1'b1)                                                                                 
			reads_done <= 1'b0;                                                                                   
																												
		//The reads_done should be associated with a rready response                                            
		//else if (M_AXI_BVALID && axi_bready && (write_burst_counter == {(C_NO_BURSTS_REQ-1){1}}) && axi_wlast)
		else if (M_AXI_RVALID && axi_rready && (read_index == C_M_AXI_BURST_LEN-1) && (read_burst_counter == read_burst_counter_max))
			reads_done <= 1'b1;                                                                                   
		else                                                                                                    
			reads_done <= 0;                                                                             
	end                                                                                                     

	// Add user logic here

	// User logic ends

	endmodule