//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/12/28     meisq          1.0         Original
//*******************************************************************************/

module lut_adv7611(
	input[9:0]             lut_index, // Look-up table index address
	output reg[31:0]       lut_data   // I2C device address register address register data
);

always@(*)
begin
	case(lut_index)
		//To be compatible with the 16bit register address, add 8'h00
		10'd0	: 	lut_data	<= 	 {8'h98, 24'h00FF80};  //I2C RESET
		10'd1	: 	lut_data	<= 	 {8'h98, 24'h00F480};  //CEC MAP
		10'd2	: 	lut_data	<= 	 {8'h98, 24'h00F57C};  //INFOFRAME MAP
		10'd3   : 	lut_data	<= 	 {8'h98, 24'h00F84C};  //DPLL MAP
		10'd4   : 	lut_data	<= 	 {8'h98, 24'h00F964};  //Repeater MAP
		10'd5   : 	lut_data	<= 	 {8'h98, 24'h00FA6C};  //EDID MAP
		10'd6   : 	lut_data	<= 	 {8'h98, 24'h00FB68};  //HDMI MAP, address: 0x68
		10'd7	: 	lut_data	<= 	 {8'h98, 24'h00FD44};  //CP MAP
		10'd8	: 	lut_data	<= 	 {8'h98, 24'h000106};  //prim_Mode =110b HDMI-GR
		10'd9	: 	lut_data	<= 	 {8'h98, 24'h000019};  //1920 ¡Á 1200 @ 60
		10'd10	: 	lut_data	<=	 {8'h98, 24'h0002f7};  //Auto CSC, RGB out, op_656 b
		10'd11	: 	lut_data	<= 	 {8'h98, 24'h000340};  //24 bit SDR 444 Mode
		10'd12	: 	lut_data	<= 	 {8'h98, 24'h000528};  //AV Codes Off
		10'd13	: 	lut_data	<= 	 {8'h98, 24'h0006A6};  //Invert VS,HS pins
		10'd14	: 	lut_data	<= 	 {8'h98, 24'h000B44};  //power-down control
		10'd15	: 	lut_data	<= 	 {8'h98, 24'h000C42};  //power-down control
		10'd16	: 	lut_data	<= 	 {8'h98, 24'h00143F};  //drive strength
		10'd17	: 	lut_data	<= 	 {8'h98, 24'h001580};  //Tristate Pins
		10'd18	: 	lut_data	<= 	 {8'h98, 24'h001998};  //adjust dll phase
		10'd19	: 	lut_data	<= 	 {8'h98, 24'h003340};  //enable dll		
		
		10'd20	: 	lut_data	<= 	 {8'h44, 24'h00BA01};	//Set HDMI FreeRun	
		
		10'd21	: 	lut_data	<= 	 {8'h68, 24'h009B03};	//ADI recommended setting
		10'd22	: 	lut_data	<= 	 {8'h68, 24'h000000};	//Set HDMI Input Port A
		10'd23	: 	lut_data	<= 	 {8'h68, 24'h000310};	//Audio data width 16 bit
		10'd24	: 	lut_data	<= 	 {8'h68, 24'h006D00};	//Disable TDM Mode ##
		10'd25	: 	lut_data	<= 	 {8'h68, 24'h0083FE};	//Enable clock terminator
		10'd26	: 	lut_data	<= 	 {8'h68, 24'h006F0C};	//ADI recommended setting
		10'd27	: 	lut_data	<= 	 {8'h68, 24'h00851F};	//ADI recommended setting
		10'd28	: 	lut_data	<= 	 {8'h68, 24'h008770};	//ADI recommended setting
		10'd29	: 	lut_data	<= 	 {8'h68, 24'h008D04};	//LFG
		10'd30	: 	lut_data	<= 	 {8'h68, 24'h008E1E};	//HFG
		10'd31	: 	lut_data	<= 	 {8'h68, 24'h001A8A};	//unmute audio
        10'd32	: 	lut_data	<= 	 {8'h68, 24'h0057DA};	//ADI recommended setting
        10'd33	: 	lut_data	<= 	 {8'h68, 24'h005801};	//ADI recommended setting
        10'd34	: 	lut_data	<= 	 {8'h68, 24'h007510};	//DDC drive strength
        10'd35	: 	lut_data	<= 	 {8'h68, 24'h009004};	//LFG
        10'd36	: 	lut_data	<= 	 {8'h68, 24'h00911E};	//HFG
        10'd37	: 	lut_data	<= 	 {8'h68, 24'h009D02};	//ADI Equaliser Setting	
		//load edid
		10'd38	: 	lut_data	<= 	 {8'h6C, 24'h000000};		
		10'd39	: 	lut_data	<= 	 {8'h6C, 24'h0001FF};
		10'd40	: 	lut_data	<= 	 {8'h6C, 24'h0002FF};
		10'd41	: 	lut_data	<= 	 {8'h6C, 24'h0003FF};
		10'd42	: 	lut_data	<= 	 {8'h6C, 24'h0004FF};
		10'd43	: 	lut_data	<= 	 {8'h6C, 24'h0005FF};
		10'd44	: 	lut_data	<= 	 {8'h6C, 24'h0006FF};
		10'd45	: 	lut_data	<= 	 {8'h6C, 24'h000700};
		10'd46	: 	lut_data	<= 	 {8'h6C, 24'h000806};
		10'd47	: 	lut_data	<= 	 {8'h6C, 24'h00098F};
		10'd48	: 	lut_data	<= 	 {8'h6C, 24'h000A07};
		10'd49	: 	lut_data	<= 	 {8'h6C, 24'h000B11};
		10'd50	: 	lut_data	<= 	 {8'h6C, 24'h000C01};
		10'd51	: 	lut_data	<= 	 {8'h6C, 24'h000D00};
		10'd52	: 	lut_data	<= 	 {8'h6C, 24'h000E00};
		10'd53	: 	lut_data	<= 	 {8'h6C, 24'h000F00};
		10'd54	: 	lut_data	<= 	 {8'h6C, 24'h001017};
		10'd55	: 	lut_data	<= 	 {8'h6C, 24'h001111};
		10'd56	: 	lut_data	<= 	 {8'h6C, 24'h001201};
		10'd57	: 	lut_data	<= 	 {8'h6C, 24'h001303};
		10'd58	: 	lut_data	<= 	 {8'h6C, 24'h001480};
		10'd59	: 	lut_data	<= 	 {8'h6C, 24'h00150C};
		10'd60	: 	lut_data	<= 	 {8'h6C, 24'h001609};
		10'd61	: 	lut_data	<= 	 {8'h6C, 24'h001778};
		10'd62	: 	lut_data	<= 	 {8'h6C, 24'h00180A};
		10'd63	: 	lut_data	<= 	 {8'h6C, 24'h00191E};
		10'd64	: 	lut_data	<= 	 {8'h6C, 24'h001AAC};
		10'd65	: 	lut_data	<= 	 {8'h6C, 24'h001B98};
		10'd66	: 	lut_data	<= 	 {8'h6C, 24'h001C59};
		10'd67	: 	lut_data	<= 	 {8'h6C, 24'h001D56};
		10'd68	: 	lut_data	<= 	 {8'h6C, 24'h001E85};
		10'd69	: 	lut_data	<= 	 {8'h6C, 24'h001F28};
		10'd70	: 	lut_data	<= 	 {8'h6C, 24'h002029};
		10'd71	: 	lut_data	<= 	 {8'h6C, 24'h002152};
		10'd72	: 	lut_data	<= 	 {8'h6C, 24'h002257};
		10'd73	: 	lut_data	<= 	 {8'h6C, 24'h002300};
		10'd74	: 	lut_data	<= 	 {8'h6C, 24'h002400};
		10'd75	: 	lut_data	<= 	 {8'h6C, 24'h002500};
		10'd76	: 	lut_data	<= 	 {8'h6C, 24'h002601};
		10'd77	: 	lut_data	<= 	 {8'h6C, 24'h002701};
		10'd78	: 	lut_data	<= 	 {8'h6C, 24'h002801};
        10'd79	: 	lut_data	<= 	 {8'h6C, 24'h002901};
        10'd80	: 	lut_data	<= 	 {8'h6C, 24'h002A01};
        10'd81	: 	lut_data	<= 	 {8'h6C, 24'h002B01};
        10'd82	: 	lut_data	<= 	 {8'h6C, 24'h002C01};
        10'd83	: 	lut_data	<= 	 {8'h6C, 24'h002D01};
        10'd84	: 	lut_data	<= 	 {8'h6C, 24'h002E01};
        10'd85	: 	lut_data	<= 	 {8'h6C, 24'h002F01};
        10'd86	: 	lut_data	<= 	 {8'h6C, 24'h003001};
        10'd87	: 	lut_data	<= 	 {8'h6C, 24'h003101};
        10'd88	: 	lut_data	<= 	 {8'h6C, 24'h003201};
        10'd89	: 	lut_data	<= 	 {8'h6C, 24'h003301};
        10'd90	: 	lut_data	<= 	 {8'h6C, 24'h003401};
        10'd91	: 	lut_data	<= 	 {8'h6C, 24'h003501};
        10'd92	: 	lut_data	<= 	 {8'h6C, 24'h00368C};
        10'd93	: 	lut_data	<= 	 {8'h6C, 24'h00370A};
        10'd94	: 	lut_data	<= 	 {8'h6C, 24'h0038D0};
        10'd95	: 	lut_data	<= 	 {8'h6C, 24'h00398A};
        10'd96	: 	lut_data	<= 	 {8'h6C, 24'h003A20};
        10'd97	: 	lut_data	<= 	 {8'h6C, 24'h003BE0};
        10'd98	: 	lut_data	<= 	 {8'h6C, 24'h003C2D};
        10'd99	: 	lut_data	<= 	 {8'h6C, 24'h003D10};
        10'd100	: 	lut_data	<= 	 {8'h6C, 24'h003E10};
        10'd101	: 	lut_data	<= 	 {8'h6C, 24'h003F3E};
        10'd102	: 	lut_data	<= 	 {8'h6C, 24'h004096};
        10'd103	: 	lut_data	<= 	 {8'h6C, 24'h004100};
        10'd104	: 	lut_data	<= 	 {8'h6C, 24'h004281};
        10'd105	: 	lut_data	<= 	 {8'h6C, 24'h004360};
        10'd106	: 	lut_data	<= 	 {8'h6C, 24'h004400};
        10'd107	: 	lut_data	<= 	 {8'h6C, 24'h004500};
        10'd108	: 	lut_data	<= 	 {8'h6C, 24'h004600};
        10'd109	: 	lut_data	<= 	 {8'h6C, 24'h004718};
        10'd110	: 	lut_data	<= 	 {8'h6C, 24'h004801};
        10'd111	: 	lut_data	<= 	 {8'h6C, 24'h00491D};
        10'd112	: 	lut_data	<= 	 {8'h6C, 24'h004A80};
        10'd113	: 	lut_data	<= 	 {8'h6C, 24'h004B18};
        10'd114	: 	lut_data	<= 	 {8'h6C, 24'h004C71};
        10'd115	: 	lut_data	<= 	 {8'h6C, 24'h004D1C};
        10'd116	: 	lut_data	<= 	 {8'h6C, 24'h004E16};
        10'd117	: 	lut_data	<= 	 {8'h6C, 24'h004F20};
        10'd118	: 	lut_data	<= 	 {8'h6C, 24'h005058};
        10'd119	: 	lut_data	<= 	 {8'h6C, 24'h00512C};
        10'd120	: 	lut_data	<= 	 {8'h6C, 24'h005225};
        10'd121	: 	lut_data	<= 	 {8'h6C, 24'h005300};
        10'd122	: 	lut_data	<= 	 {8'h6C, 24'h005481};
        10'd123	: 	lut_data	<= 	 {8'h6C, 24'h005549};
        10'd124	: 	lut_data	<= 	 {8'h6C, 24'h005600};
        10'd125	: 	lut_data	<= 	 {8'h6C, 24'h005700};
        10'd126	: 	lut_data	<= 	 {8'h6C, 24'h005800};
        10'd127	: 	lut_data	<= 	 {8'h6C, 24'h00599E};
        10'd128	: 	lut_data	<= 	 {8'h6C, 24'h005A00};
        10'd129	: 	lut_data	<= 	 {8'h6C, 24'h005B00};
        10'd130	: 	lut_data	<= 	 {8'h6C, 24'h005C00};
        10'd131	: 	lut_data	<= 	 {8'h6C, 24'h005DFC};
        10'd132	: 	lut_data	<= 	 {8'h6C, 24'h005E00};
        10'd133	: 	lut_data	<= 	 {8'h6C, 24'h005F56};
        10'd134	: 	lut_data	<= 	 {8'h6C, 24'h006041};
        10'd135	: 	lut_data	<= 	 {8'h6C, 24'h00612D};
        10'd136	: 	lut_data	<= 	 {8'h6C, 24'h006231};
        10'd137	: 	lut_data	<= 	 {8'h6C, 24'h006338};
        10'd138	: 	lut_data	<= 	 {8'h6C, 24'h006430};
        10'd139	: 	lut_data	<= 	 {8'h6C, 24'h006539};
        10'd140	: 	lut_data	<= 	 {8'h6C, 24'h006641};
        10'd141	: 	lut_data	<= 	 {8'h6C, 24'h00670A};
        10'd142	: 	lut_data	<= 	 {8'h6C, 24'h006820};
        10'd143	: 	lut_data	<= 	 {8'h6C, 24'h006920};
        10'd144	: 	lut_data	<= 	 {8'h6C, 24'h006A20};
        10'd145	: 	lut_data	<= 	 {8'h6C, 24'h006B20};
        10'd146	: 	lut_data	<= 	 {8'h6C, 24'h006C00};
        10'd147	: 	lut_data	<= 	 {8'h6C, 24'h006D00};
        10'd148	: 	lut_data	<= 	 {8'h6C, 24'h006E00};
        10'd149	: 	lut_data	<= 	 {8'h6C, 24'h006FFD};
        10'd150	: 	lut_data	<= 	 {8'h6C, 24'h007000};
        10'd151	: 	lut_data	<= 	 {8'h6C, 24'h007117};
        10'd152	: 	lut_data	<= 	 {8'h6C, 24'h00723D};
        10'd153	: 	lut_data	<= 	 {8'h6C, 24'h00730D};
        10'd154	: 	lut_data	<= 	 {8'h6C, 24'h00742E};
        10'd155	: 	lut_data	<= 	 {8'h6C, 24'h007511};
        10'd156	: 	lut_data	<= 	 {8'h6C, 24'h007600};
        10'd157	: 	lut_data	<= 	 {8'h6C, 24'h00770A};
        10'd158	: 	lut_data	<= 	 {8'h6C, 24'h007820};
        10'd159	: 	lut_data	<= 	 {8'h6C, 24'h007920};
        10'd160	: 	lut_data	<= 	 {8'h6C, 24'h007A20};
        10'd161	: 	lut_data	<= 	 {8'h6C, 24'h007B20};
        10'd162	: 	lut_data	<= 	 {8'h6C, 24'h007C20};
        10'd163	: 	lut_data	<= 	 {8'h6C, 24'h007D20};
        10'd164	: 	lut_data	<= 	 {8'h6C, 24'h007E01};
        10'd165	: 	lut_data	<= 	 {8'h6C, 24'h007F1C};
        10'd166	: 	lut_data	<= 	 {8'h6C, 24'h008002};
        10'd167	: 	lut_data	<= 	 {8'h6C, 24'h008103};
        10'd168	: 	lut_data	<= 	 {8'h6C, 24'h008234};
        10'd169	: 	lut_data	<= 	 {8'h6C, 24'h008371};
        10'd170	: 	lut_data	<= 	 {8'h6C, 24'h00844D};
        10'd171	: 	lut_data	<= 	 {8'h6C, 24'h008582};
        10'd172	: 	lut_data	<= 	 {8'h6C, 24'h008605};
        10'd173	: 	lut_data	<= 	 {8'h6C, 24'h008704};
        10'd174	: 	lut_data	<= 	 {8'h6C, 24'h008801};
        10'd175	: 	lut_data	<= 	 {8'h6C, 24'h008910};
        10'd176	: 	lut_data	<= 	 {8'h6C, 24'h008A11};
        10'd177	: 	lut_data	<= 	 {8'h6C, 24'h008B14};
        10'd178	: 	lut_data	<= 	 {8'h6C, 24'h008C13};
        10'd179	: 	lut_data	<= 	 {8'h6C, 24'h008D1F};
        10'd180	: 	lut_data	<= 	 {8'h6C, 24'h008E06};
        10'd181	: 	lut_data	<= 	 {8'h6C, 24'h008F15};
        10'd182	: 	lut_data	<= 	 {8'h6C, 24'h009003};
        10'd183	: 	lut_data	<= 	 {8'h6C, 24'h009112};
        10'd184	: 	lut_data	<= 	 {8'h6C, 24'h009235};
        10'd185	: 	lut_data	<= 	 {8'h6C, 24'h00930F};
        10'd186	: 	lut_data	<= 	 {8'h6C, 24'h00947F};
        10'd187	: 	lut_data	<= 	 {8'h6C, 24'h009507};
        10'd188	: 	lut_data	<= 	 {8'h6C, 24'h009617};
        10'd189	: 	lut_data	<= 	 {8'h6C, 24'h00971F};
        10'd190	: 	lut_data	<= 	 {8'h6C, 24'h009838};
        10'd191	: 	lut_data	<= 	 {8'h6C, 24'h00991F};
        10'd192	: 	lut_data	<= 	 {8'h6C, 24'h009A07};
        10'd193	: 	lut_data	<= 	 {8'h6C, 24'h009B30};
        10'd194	: 	lut_data	<= 	 {8'h6C, 24'h009C2F};
        10'd195	: 	lut_data	<= 	 {8'h6C, 24'h009D07};
        10'd196	: 	lut_data	<= 	 {8'h6C, 24'h009E72};
        10'd197	: 	lut_data	<= 	 {8'h6C, 24'h009F3F};
        10'd198	: 	lut_data	<= 	 {8'h6C, 24'h00A07F};
        10'd199	: 	lut_data	<= 	 {8'h6C, 24'h00A172};
        10'd200	: 	lut_data	<= 	 {8'h6C, 24'h00A257};
        10'd201	: 	lut_data	<= 	 {8'h6C, 24'h00A37F};
        10'd202	: 	lut_data	<= 	 {8'h6C, 24'h00A400};
        10'd203	: 	lut_data	<= 	 {8'h6C, 24'h00A537};
        10'd204	: 	lut_data	<= 	 {8'h6C, 24'h00A67F};
        10'd205	: 	lut_data	<= 	 {8'h6C, 24'h00A772};
        10'd206	: 	lut_data	<= 	 {8'h6C, 24'h00A883};
        10'd207	: 	lut_data	<= 	 {8'h6C, 24'h00A94F};
        10'd208	: 	lut_data	<= 	 {8'h6C, 24'h00AA00};
        10'd209	: 	lut_data	<= 	 {8'h6C, 24'h00AB00};
        10'd210	: 	lut_data	<= 	 {8'h6C, 24'h00AC67};
        10'd211	: 	lut_data	<= 	 {8'h6C, 24'h00AD03};
        10'd212	: 	lut_data	<= 	 {8'h6C, 24'h00AE0C};
        10'd213	: 	lut_data	<= 	 {8'h6C, 24'h00AF00};
        10'd214	: 	lut_data	<= 	 {8'h6C, 24'h00B010};
        10'd215	: 	lut_data	<= 	 {8'h6C, 24'h00B100};
        10'd216	: 	lut_data	<= 	 {8'h6C, 24'h00B288};
        10'd217	: 	lut_data	<= 	 {8'h6C, 24'h00B32D};
        10'd218	: 	lut_data	<= 	 {8'h6C, 24'h00B400};
        10'd219	: 	lut_data	<= 	 {8'h6C, 24'h00B500};
        10'd220	: 	lut_data	<= 	 {8'h6C, 24'h00B600};
        10'd221	: 	lut_data	<= 	 {8'h6C, 24'h00B7FF};
        10'd222	: 	lut_data	<= 	 {8'h6C, 24'h00B800};
        10'd223	: 	lut_data	<= 	 {8'h6C, 24'h00B90A};
        10'd224	: 	lut_data	<= 	 {8'h6C, 24'h00BA20};
        10'd225	: 	lut_data	<= 	 {8'h6C, 24'h00BB20};
        10'd226	: 	lut_data	<= 	 {8'h6C, 24'h00BC20};
        10'd227	: 	lut_data	<= 	 {8'h6C, 24'h00BD20};
        10'd228	: 	lut_data	<= 	 {8'h6C, 24'h00BE20};
        10'd229	: 	lut_data	<= 	 {8'h6C, 24'h00BF20};
        10'd230	: 	lut_data	<= 	 {8'h6C, 24'h00C020};
        10'd231	: 	lut_data	<= 	 {8'h6C, 24'h00C120};
        10'd232	: 	lut_data	<= 	 {8'h6C, 24'h00C220};
        10'd233	: 	lut_data	<= 	 {8'h6C, 24'h00C320};
        10'd234	: 	lut_data	<= 	 {8'h6C, 24'h00C420};
        10'd235	: 	lut_data	<= 	 {8'h6C, 24'h00C520};
        10'd236	: 	lut_data	<= 	 {8'h6C, 24'h00C600};
        10'd237	: 	lut_data	<= 	 {8'h6C, 24'h00C700};
        10'd238	: 	lut_data	<= 	 {8'h6C, 24'h00C800};
        10'd239	: 	lut_data	<= 	 {8'h6C, 24'h00C9FF};
        10'd240	: 	lut_data	<= 	 {8'h6C, 24'h00CA00};
        10'd241	: 	lut_data	<= 	 {8'h6C, 24'h00CB0A};
        10'd242	: 	lut_data	<= 	 {8'h6C, 24'h00CC20};
        10'd243	: 	lut_data	<= 	 {8'h6C, 24'h00CD20};
        10'd244	: 	lut_data	<= 	 {8'h6C, 24'h00CE20};
        10'd245	: 	lut_data	<= 	 {8'h6C, 24'h00CF20};
        10'd246	: 	lut_data	<= 	 {8'h6C, 24'h00D020};
        10'd247	: 	lut_data	<= 	 {8'h6C, 24'h00D120};
        10'd248	: 	lut_data	<= 	 {8'h6C, 24'h00D220};
        10'd249	: 	lut_data	<= 	 {8'h6C, 24'h00D320};
        10'd250	: 	lut_data	<= 	 {8'h6C, 24'h00D420};
        10'd251	: 	lut_data	<= 	 {8'h6C, 24'h00D520};
        10'd252	: 	lut_data	<= 	 {8'h6C, 24'h00D620};
        10'd253	: 	lut_data	<= 	 {8'h6C, 24'h00D720};
        10'd254	: 	lut_data	<= 	 {8'h6C, 24'h00D800};
        10'd255	: 	lut_data	<= 	 {8'h6C, 24'h00D900};
        10'd256	: 	lut_data	<= 	 {8'h6C, 24'h00DA00};
        10'd257	: 	lut_data	<= 	 {8'h6C, 24'h00DBFF};
        10'd258	: 	lut_data	<= 	 {8'h6C, 24'h00DC00};
        10'd259	: 	lut_data	<= 	 {8'h6C, 24'h00DD0A};
        10'd260	: 	lut_data	<= 	 {8'h6C, 24'h00DE20};
        10'd261	: 	lut_data	<= 	 {8'h6C, 24'h00DF20};
        10'd262	: 	lut_data	<= 	 {8'h6C, 24'h00E020};
        10'd263	: 	lut_data	<= 	 {8'h6C, 24'h00E120};
        10'd264	: 	lut_data	<= 	 {8'h6C, 24'h00E220};
        10'd265	: 	lut_data	<= 	 {8'h6C, 24'h00E320};
        10'd266	: 	lut_data	<= 	 {8'h6C, 24'h00E420};
        10'd267	: 	lut_data	<= 	 {8'h6C, 24'h00E520};
        10'd268	: 	lut_data	<= 	 {8'h6C, 24'h00E620};
        10'd269	: 	lut_data	<= 	 {8'h6C, 24'h00E720};
        10'd270	: 	lut_data	<= 	 {8'h6C, 24'h00E820};
        10'd271	: 	lut_data	<= 	 {8'h6C, 24'h00E920};
        10'd272	: 	lut_data	<= 	 {8'h6C, 24'h00EA00};
        10'd273	: 	lut_data	<= 	 {8'h6C, 24'h00EB00};
        10'd274	: 	lut_data	<= 	 {8'h6C, 24'h00EC00};
        10'd275	: 	lut_data	<= 	 {8'h6C, 24'h00ED00};
        10'd276	: 	lut_data	<= 	 {8'h6C, 24'h00EE00};
        10'd277	: 	lut_data	<= 	 {8'h6C, 24'h00EF00};
        10'd278	: 	lut_data	<= 	 {8'h6C, 24'h00F000};
        10'd279	: 	lut_data	<= 	 {8'h6C, 24'h00F100};
        10'd280	: 	lut_data	<= 	 {8'h6C, 24'h00F200};
        10'd281	: 	lut_data	<= 	 {8'h6C, 24'h00F300};
        10'd282	: 	lut_data	<= 	 {8'h6C, 24'h00F400};
        10'd283	: 	lut_data	<= 	 {8'h6C, 24'h00F500};
        10'd284	: 	lut_data	<= 	 {8'h6C, 24'h00F600};
        10'd285	: 	lut_data	<= 	 {8'h6C, 24'h00F700};
        10'd286	: 	lut_data	<= 	 {8'h6C, 24'h00F800};
        10'd287	: 	lut_data	<= 	 {8'h6C, 24'h00F900};
        10'd288	: 	lut_data	<= 	 {8'h6C, 24'h00FA00};
        10'd289	: 	lut_data	<= 	 {8'h6C, 24'h00FB00};
        10'd290	: 	lut_data	<= 	 {8'h6C, 24'h00FC00};
        10'd291	: 	lut_data	<= 	 {8'h6C, 24'h00FD00};
        10'd292	: 	lut_data	<= 	 {8'h6C, 24'h00FE00};
        10'd293	: 	lut_data	<= 	 {8'h6C, 24'h00FFDA};
        10'd294	: 	lut_data	<= 	 {8'h64, 24'h007700};
        10'd295	: 	lut_data	<= 	 {8'h64, 24'h005220};
        10'd296	: 	lut_data	<= 	 {8'h64, 24'h005300};
        10'd297	: 	lut_data	<= 	 {8'h64, 24'h00709E};
        10'd298 : 	lut_data	<= 	 {8'h64, 24'h007403};	
		default :	lut_data 	<= 	 {8'hff, 16'hffff,8'hff};
		endcase 
	end       
endmodule 
