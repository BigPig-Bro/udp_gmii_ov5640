module axi_native_transition#(
	    parameter MEM_DATA_BITS = 64
	,   parameter MEM_IF_ADDR_BITS = 27
	,   parameter ADDR_BITS = 24

		// Thread ID Width
	,   parameter integer C_S_AXI_ID_WIDTH	= 1
		// Width of Address Bus
	,   parameter integer C_S_AXI_ADDR_WIDTH	= 32
		// Width of Data Bus
	,   parameter integer C_S_AXI_DATA_WIDTH	= 32
		// Width of User Write Address Bus
	,   parameter integer C_S_AXI_AWUSER_WIDTH	= 0
		// Width of User Read Address Bus
	,   parameter integer C_S_AXI_ARUSER_WIDTH	= 0
		// Width of User Write Data Bus
	,   parameter integer C_S_AXI_WUSER_WIDTH	= 0
		// Width of User Read Data Bus
	,   parameter integer C_S_AXI_RUSER_WIDTH	= 0
		// Width of User Response Bus
	,   parameter integer C_S_AXI_BUSER_WIDTH	= 0
)(

//----------------------------------------------------
// DDR native app port
        input                           app_clk
    ,   input                           app_rst
    ,   output  [MEM_IF_ADDR_BITS-1:0]  app_addr
    ,   output  [2:0]                   app_cmd
    ,   output                          app_en
    ,   input                           app_rdy
    ,   input   [MEM_DATA_BITS-1:0]     app_rd_data
    ,   input                           app_rd_data_end
    ,   input                           app_rd_data_valid
    ,   output  [MEM_DATA_BITS-1:0]     app_wdf_data
    ,   output                          app_wdf_end
    ,   output  [MEM_DATA_BITS/8-1:0]   app_wdf_mask
    ,   input                           app_wdf_rdy
    ,   output                          app_wdf_wren,

//----------------------------------------------------
// AXI-FULL master port
    // Global Clock Signal
		input wire  S_AXI_ACLK,
		// Global Reset Signal. This Signal is Active LOW
		input wire  S_AXI_ARESETN,
		// Write Address ID
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_AWID,
		// Write address
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_AWLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_AWSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_AWBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_AWLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_AWCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_AWPROT,
		// Quality of Service, QoS identifier sent for each
    // write transaction.
		input wire [3 : 0] S_AXI_AWQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_AWREGION,
		// Optional User-defined signal in the write address channel.
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0] S_AXI_AWUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid write address and
    // control information.
		input wire  S_AXI_AWVALID,
		// Write address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output wire  S_AXI_AWREADY,
		// Write Data
		input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		// Write strobes. This signal indicates which byte
    // lanes hold valid data. There is one write strobe
    // bit for each eight bits of the write data bus.
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		// Write last. This signal indicates the last transfer
    // in a write burst.
		input wire  S_AXI_WLAST,
		// Optional User-defined signal in the write data channel.
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0] S_AXI_WUSER,
		// Write valid. This signal indicates that valid write
    // data and strobes are available.
		input wire  S_AXI_WVALID,
		// Write ready. This signal indicates that the slave
    // can accept the write data.
		output wire  S_AXI_WREADY,
		// Response ID tag. This signal is the ID tag of the
    // write response.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_BID,
		// Write response. This signal indicates the status
    // of the write transaction.
		output wire [1 : 0] S_AXI_BRESP,
		// Optional User-defined signal in the write response channel.
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0] S_AXI_BUSER,
		// Write response valid. This signal indicates that the
    // channel is signaling a valid write response.
		output wire  S_AXI_BVALID,
		// Response ready. This signal indicates that the master
    // can accept a write response.
		input wire  S_AXI_BREADY,
		// Read address ID. This signal is the identification
    // tag for the read address group of signals.
		input wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_ARID,
		// Read address. This signal indicates the initial
    // address of a read burst transaction.
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		// Burst length. The burst length gives the exact number of transfers in a burst
		input wire [7 : 0] S_AXI_ARLEN,
		// Burst size. This signal indicates the size of each transfer in the burst
		input wire [2 : 0] S_AXI_ARSIZE,
		// Burst type. The burst type and the size information, 
    // determine how the address for each transfer within the burst is calculated.
		input wire [1 : 0] S_AXI_ARBURST,
		// Lock type. Provides additional information about the
    // atomic characteristics of the transfer.
		input wire  S_AXI_ARLOCK,
		// Memory type. This signal indicates how transactions
    // are required to progress through a system.
		input wire [3 : 0] S_AXI_ARCACHE,
		// Protection type. This signal indicates the privilege
    // and security level of the transaction, and whether
    // the transaction is a data access or an instruction access.
		input wire [2 : 0] S_AXI_ARPROT,
		// Quality of Service, QoS identifier sent for each
    // read transaction.
		input wire [3 : 0] S_AXI_ARQOS,
		// Region identifier. Permits a single physical interface
    // on a slave to be used for multiple logical interfaces.
		input wire [3 : 0] S_AXI_ARREGION,
		// Optional User-defined signal in the read address channel.
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0] S_AXI_ARUSER,
		// Write address valid. This signal indicates that
    // the channel is signaling valid read address and
    // control information.
		input wire  S_AXI_ARVALID,
		// Read address ready. This signal indicates that
    // the slave is ready to accept an address and associated
    // control signals.
		output wire  S_AXI_ARREADY,
		// Read ID tag. This signal is the identification tag
    // for the read data group of signals generated by the slave.
		output wire [C_S_AXI_ID_WIDTH-1 : 0] S_AXI_RID,
		// Read Data
		output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		// Read response. This signal indicates the status of
    // the read transfer.
		output wire [1 : 0] S_AXI_RRESP,
		// Read last. This signal indicates the last transfer
    // in a read burst.
		output wire  S_AXI_RLAST,
		// Optional User-defined signal in the read address channel.
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0] S_AXI_RUSER,
		// Read valid. This signal indicates that the channel
    // is signaling the required read data.
		output wire  S_AXI_RVALID,
		// Read ready. This signal indicates that the master can
    // accept the read data and response information.
		input wire  S_AXI_RREADY
);

assign app_wdf_mask = {MEM_DATA_BITS/8{1'b0}};

localparam IDLE = 3'd0;
localparam MEM_READ = 3'd1;
localparam MEM_READ_WAIT = 3'd2;
localparam MEM_WRITE  = 3'd3;
localparam MEM_WRITE_WAIT = 3'd4;
localparam READ_END = 3'd5;
localparam WRITE_END = 3'd6;
localparam MEM_WRITE_FIRST_READ = 3'd7;
reg[2:0] state;	
reg[9:0] rd_addr_cnt;
reg[9:0] rd_data_cnt;
reg[9:0] wr_addr_cnt;
reg[9:0] wr_data_cnt;

reg[2:0] app_cmd_r;
reg[MEM_IF_ADDR_BITS-1:0] app_addr_r;
reg app_en_r;
reg [MEM_DATA_BITS-1:0] app_wdf_data_r;
reg app_wdf_wren_r;

reg     s_axi_awready;
wire    s_axi_wready;
reg     s_axi_bvalid;
reg     s_axi_arready;
reg     s_axi_rvalid;
reg		s_axi_rlast;
reg  [7:0] burst_counter;
reg  [7:0] read_counter;

reg   [MEM_DATA_BITS-1:0]     app_rd_data_d1;
reg                           app_rd_data_valid_d1;

assign app_cmd = app_cmd_r;
assign app_addr = app_addr_r;
assign app_en = app_en_r;
assign app_wdf_end = app_wdf_wren;
assign app_wdf_data = app_wdf_data_r;
assign app_wdf_wren = app_wdf_wren_r;
assign S_AXI_AWREADY = s_axi_awready;
assign S_AXI_WREADY = s_axi_wready;
assign s_axi_wready = app_wdf_rdy;
assign S_AXI_BVALID = s_axi_bvalid;
assign S_AXI_ARREADY = s_axi_arready;
assign S_AXI_RVALID = s_axi_rvalid | app_rd_data_valid_d1;
assign S_AXI_RDATA = app_rd_data_d1;
assign S_AXI_BRESP = 0;
assign S_AXI_RRESP = 0;
assign S_AXI_RLAST = (read_counter == S_AXI_ARLEN) & S_AXI_RVALID & S_AXI_RREADY;


always@(posedge app_clk) begin
	app_rd_data_d1				<=	app_rd_data;
	app_rd_data_valid_d1		<=	app_rd_data_valid;
end


always@(posedge app_clk or posedge app_rst) begin
	if(app_rst) begin
		read_counter	<=	1'b0;
	end
	else if(S_AXI_RREADY & S_AXI_RVALID) begin
		read_counter 	<=	read_counter + 1;
	end
	else if(state == IDLE) begin
		read_counter 	<=	0;
	end
end

always@(posedge app_clk or posedge app_rst) begin
	if(app_rst) begin
		app_wdf_data_r	<=	1'b0;
	end
	else if(s_axi_wready & S_AXI_WVALID) begin
		app_wdf_data_r 	<=	S_AXI_WDATA;
	end
end

always@(posedge app_clk or posedge app_rst) begin
	if(app_rst) begin
		state <= IDLE;
		app_cmd_r <= 3'b000;
		app_addr_r <= 1'b0;
		app_en_r <= 1'b0;
        app_wdf_wren_r <= 1'b0;

        s_axi_awready  <= 0;
        s_axi_bvalid  <= 0;
        s_axi_arready <= 0;
        s_axi_rvalid  <= 0;
	end
	else begin
		case(state)
			IDLE: begin
                app_en_r <= 1'b0;
                app_wdf_wren_r 	<= 1'b0;
                s_axi_awready  	<= 1'b1;
                s_axi_arready 	<= 1'b1;
                s_axi_rvalid 	<= 1'b0;
				if(S_AXI_ARVALID & s_axi_arready) begin
                    state <= MEM_READ;
                    s_axi_awready  	<= 0;
                    s_axi_arready   <= 0;

					app_cmd_r <= 3'b001;
                    app_addr_r <= S_AXI_ARADDR>>1;
                    s_axi_rvalid <=  1'b1;
					app_en_r <= 1'b1;
				end
				else if(S_AXI_AWVALID & s_axi_awready) begin
					state <= MEM_WRITE;
                    s_axi_awready  	<= 0;
                    s_axi_arready   <= 0;

					app_cmd_r <= 3'b000;
					app_addr_r <= S_AXI_AWADDR>>1;
					app_en_r	<= 1'b1;
				end
			end
			MEM_READ: begin
                s_axi_rvalid <=  0;
				if(app_rdy & app_en_r) begin
					app_en_r <= 1'b0;
					state <= READ_END;
				end
			end
			MEM_WRITE: begin
                if(app_rdy & app_en_r) begin
					app_en_r 	<= 1'b0;
                end

				if(s_axi_wready & S_AXI_WVALID) begin
                    app_wdf_wren_r 	<= 1'b1;
				end
				else begin
                    app_wdf_wren_r 	<= 1'b0;
				end

                if(S_AXI_WLAST & s_axi_wready & S_AXI_WVALID) begin
				    state 		<= WRITE_END;
                end
			end
			READ_END:begin
                if ((read_counter == S_AXI_ARLEN) & S_AXI_RREADY & S_AXI_RVALID) begin
				    state <= IDLE;
				end
            end
			WRITE_END: begin
				app_wdf_wren_r 	<= 1'b0;
                s_axi_bvalid    <=  1'b1;
				if(s_axi_bvalid & S_AXI_BREADY) begin
                	s_axi_bvalid    <=  1'b0;
					state <= IDLE;
				end
            end
			default:
				state <= IDLE;
		endcase
	end
end










endmodule