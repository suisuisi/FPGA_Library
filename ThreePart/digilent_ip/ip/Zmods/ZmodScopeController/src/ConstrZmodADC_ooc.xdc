set ADC_InClk_period 2.500; # 400MHz max frequency expected for ADC_InClk_period
create_clock -period $ADC_InClk_period -name ADC_InClk -waveform {0.000 1.250} -add [get_ports ADC_InClk]
set ADC_SamplingClk_period 8.000; # 125MHz max frequency expected for ADC_SamplingClk_period
create_clock -period $ADC_SamplingClk_period -name ADC_SamplingClk -waveform {0.000 4.000} -add [get_ports ADC_SamplingClk]