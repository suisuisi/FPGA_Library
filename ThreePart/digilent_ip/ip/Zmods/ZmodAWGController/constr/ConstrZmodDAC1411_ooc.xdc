set tDAC_Clk 10; # 100MHz max frequency expected for DAC_Clk
set tDAC_ClkHalf [expr $tDAC_Clk/2];
create_clock -period $tDAC_Clk -name DAC_Clk -waveform "0.000 $tDAC_ClkHalf" -add [get_ports DAC_Clk]
set tDAC_ClkIO 10; # 100MHz max frequency expected for DAC_InIO_Clk
set tDAC_ClkIO_Half [expr $tDAC_Clk/2 + 2.500];
create_clock -period $tDAC_ClkIO -name DAC_InIO_Clk -waveform "2.500 $tDAC_ClkIO_Half" -add [get_ports DAC_InIO_Clk]