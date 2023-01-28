set ClockGenPriRefClk_period 2.500; # 400MHz max frequency expected for ClockGenPriRefClk_period
create_clock -period $ClockGenPriRefClk_period -name ClockGenPriRefClk -waveform {0.000 1.250} -add [get_ports ClockGenPriRefClk]
