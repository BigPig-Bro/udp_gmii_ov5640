`timescale 1ns / 1ps

module CRC32_D8(
	Clk,
	Reset,
	Data_in, 
	Enable,
	Crc,
	CrcNext,
	Crc_eth
);

	parameter Tp = 1;

	input Clk;
	input Reset;
	input [7:0] Data_in;
	input Enable;

	output reg [31:0] Crc;
 
	output [31:0]Crc_eth;

	output [31:0] CrcNext;

	wire [7:0] Data;

	assign Data={Data_in[0],Data_in[1],Data_in[2],Data_in[3],Data_in[4],Data_in[5],Data_in[6],Data_in[7]};

	assign CrcNext[0] = Crc[24] ^ Crc[30] ^ Data[0] ^ Data[6];
	assign CrcNext[1] = Crc[24] ^ Crc[25] ^ Crc[30] ^ Crc[31] ^ Data[0] ^ Data[1] ^ Data[6] ^ Data[7];
	assign CrcNext[2] = Crc[24] ^ Crc[25] ^ Crc[26] ^ Crc[30] ^ Crc[31] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[6] ^ Data[7];
	assign CrcNext[3] = Crc[25] ^ Crc[26] ^ Crc[27] ^ Crc[31] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[7];
	assign CrcNext[4] = Crc[24] ^ Crc[26] ^ Crc[27] ^ Crc[28] ^ Crc[30] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[4] ^ Data[6];
	assign CrcNext[5] = Crc[24] ^ Crc[25] ^ Crc[27] ^ Crc[28] ^ Crc[29] ^ Crc[30] ^ Crc[31] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4] ^ Data[5] ^ Data[6] ^ Data[7];
	assign CrcNext[6] = Crc[25] ^ Crc[26] ^ Crc[28] ^ Crc[29] ^ Crc[30] ^ Crc[31] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[6] ^ Data[7];
	assign CrcNext[7] = Crc[24] ^ Crc[26] ^ Crc[27] ^ Crc[29] ^ Crc[31] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[7];
	assign CrcNext[8] = Crc[0] ^ Crc[24] ^ Crc[25] ^ Crc[27] ^ Crc[28] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4];
	assign CrcNext[9] = Crc[1] ^ Crc[25] ^ Crc[26] ^ Crc[28] ^ Crc[29] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5];
	assign CrcNext[10] = Crc[2] ^ Crc[24] ^ Crc[26] ^ Crc[27] ^ Crc[29] ^ Data[0] ^ Data[2] ^ Data[3] ^ Data[5];
	assign CrcNext[11] = Crc[3] ^ Crc[24] ^ Crc[25] ^ Crc[27] ^ Crc[28] ^ Data[0] ^ Data[1] ^ Data[3] ^ Data[4];
	assign CrcNext[12] = Crc[4] ^ Crc[24] ^ Crc[25] ^ Crc[26] ^ Crc[28] ^ Crc[29] ^ Crc[30] ^ Data[0] ^ Data[1] ^ Data[2] ^ Data[4] ^ Data[5] ^ Data[6];
	assign CrcNext[13] = Crc[5] ^ Crc[25] ^ Crc[26] ^ Crc[27] ^ Crc[29] ^ Crc[30] ^ Crc[31] ^ Data[1] ^ Data[2] ^ Data[3] ^ Data[5] ^ Data[6] ^ Data[7];
	assign CrcNext[14] = Crc[6] ^ Crc[26] ^ Crc[27] ^ Crc[28] ^ Crc[30] ^ Crc[31] ^ Data[2] ^ Data[3] ^ Data[4] ^ Data[6] ^ Data[7];
	assign CrcNext[15] =  Crc[7] ^ Crc[27] ^ Crc[28] ^ Crc[29] ^ Crc[31] ^ Data[3] ^ Data[4] ^ Data[5] ^ Data[7];
	assign CrcNext[16] = Crc[8] ^ Crc[24] ^ Crc[28] ^ Crc[29] ^ Data[0] ^ Data[4] ^ Data[5];
	assign CrcNext[17] = Crc[9] ^ Crc[25] ^ Crc[29] ^ Crc[30] ^ Data[1] ^ Data[5] ^ Data[6];
	assign CrcNext[18] = Crc[10] ^ Crc[26] ^ Crc[30] ^ Crc[31] ^ Data[2] ^ Data[6] ^ Data[7];
	assign CrcNext[19] = Crc[11] ^ Crc[27] ^ Crc[31] ^ Data[3] ^ Data[7];
	assign CrcNext[20] = Crc[12] ^ Crc[28] ^ Data[4];
	assign CrcNext[21] = Crc[13] ^ Crc[29] ^ Data[5];
	assign CrcNext[22] = Crc[14] ^ Crc[24] ^ Data[0];
	assign CrcNext[23] = Crc[15] ^ Crc[24] ^ Crc[25] ^ Crc[30] ^ Data[0] ^ Data[1] ^ Data[6];
	assign CrcNext[24] = Crc[16] ^ Crc[25] ^ Crc[26] ^ Crc[31] ^ Data[1] ^ Data[2] ^ Data[7];
	assign CrcNext[25] = Crc[17] ^ Crc[26] ^ Crc[27] ^ Data[2] ^ Data[3];
	assign CrcNext[26] = Crc[18] ^ Crc[24] ^ Crc[27] ^ Crc[28] ^ Crc[30] ^ Data[0] ^ Data[3] ^ Data[4] ^ Data[6];
	assign CrcNext[27] = Crc[19] ^ Crc[25] ^ Crc[28] ^ Crc[29] ^ Crc[31] ^ Data[1] ^ Data[4] ^ Data[5] ^ Data[7];
	assign CrcNext[28] = Crc[20] ^ Crc[26] ^ Crc[29] ^ Crc[30] ^ Data[2] ^ Data[5] ^ Data[6];
	assign CrcNext[29] = Crc[21] ^ Crc[27] ^ Crc[30] ^ Crc[31] ^ Data[3] ^ Data[6] ^ Data[7];
	assign CrcNext[30] = Crc[22] ^ Crc[28] ^ Crc[31] ^ Data[4] ^ Data[7];
	assign CrcNext[31] = Crc[23] ^ Crc[29] ^ Data[5];

	always @ (posedge Clk)
	if (Reset)
		Crc <={32{1'b1}};
   else if (Enable)
		Crc <= #1 CrcNext;

assign Crc_eth = ~{
						CrcNext[24], CrcNext[25], CrcNext[26], CrcNext[27],CrcNext[28], CrcNext[29], CrcNext[30], CrcNext[31],
						Crc[16], Crc[17], Crc[18], Crc[19],Crc[20], Crc[21], Crc[22], Crc[23],
						Crc[ 8], Crc[ 9], Crc[10], Crc[11],Crc[12], Crc[13], Crc[14], Crc[15],
						Crc[ 0], Crc[ 1], Crc[ 2], Crc[ 3],Crc[ 4], Crc[ 5], Crc[ 6], Crc[ 7]};		

endmodule