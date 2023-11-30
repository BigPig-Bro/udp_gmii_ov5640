//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: V1.9.9 Beta-5
//Created Time: 2023-11-12 23:52:28
create_clock -name adv7611_pclk -period 13 -waveform {0 6.5} [get_ports {adv7611_pclk}]
