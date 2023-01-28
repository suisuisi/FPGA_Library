#$kSamplingPeriod
# Disable timing analysis for clock domain crossing dedicated modules
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages_reg[*]/D} -hier]
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages*/PRE || NAME =~ *SyncAsync*/oSyncStages*/CLR} -hier]

set_false_path -through [get_pins -filter {NAME =~ *InstHandshake*/*/CLR} -hier]
set_false_path -from [get_cells -hier -filter {NAME =~ *InstHandshake*/iData_int_reg[*]}] -to [get_cells -hier -filter {NAME=~ *InstHandshake*/oData_reg[*]}]

# Disable timing analysis on the InstCG_ClkODDR primitive reset input.
set_false_path -rise_from [get_pins -hier -filter {NAME =~ *InstClockGenPriRefClkReset*/SyncAsyncx/oSyncStages_reg[1]/C}] -fall_to [get_pins -hier -filter {NAME=~ *InstCG_ClkODDR*/R}]


#
create_generated_clock -name CG_InputClk -source [get_pins InstCG_ClkODDR/C] -add -master_clock [get_clocks -of [get_ports ClockGenPriRefClk]] -divide_by 1 [get_ports CG_InputClk_p]

#DCO Clock period
set tDCO [get_property CLKIN1_PERIOD [get_cells InstDataPath/MMCME2_ADV_inst]];   
set tDCO_half [expr $tDCO/2];
create_clock -period $tDCO -name DcoClkIn -waveform "0.000 $tDCO_half" [get_ports DcoClkIn -prop_thru_buffers]


#Specify timing parameters for AD9648 in CMOS mode
set tskew_max 1.000;
#For kSamplingPeriod values smaller than 10000 ps, use:
#set tskew_max 0.600;     

set tskew_min  -1.200;
#For kSamplingPeriod values smaller than 10000 ps, use:
#set tskew_min  -0.720;

#Reg 0x17 setting 
set OutputDelay  1.12;     

# Zmod Digitizer + Eclypse Z7 (SYZYGY Port A) Net Delays
set net_delay_dco_clk 0.623;
set net_delay_dout_0 0.558;
set net_delay_dout_1 0.585;
set net_delay_dout_2 0.595;
set net_delay_dout_3 0.592;
set net_delay_dout_4 0.599;
set net_delay_dout_5 0.608;
set net_delay_dout_6 0.623;
set net_delay_dout_7 0.577;
set net_delay_dout_8 0.619;
set net_delay_dout_9 0.617;
set net_delay_dout_10 0.617;
set net_delay_dout_11 0.554;
set net_delay_dout_12 0.569;
set net_delay_dout_13 0.559;

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_0 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[0]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_0 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[0]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_0 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[0]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_0 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[0]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_1 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[1]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_1 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[1]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_1 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[1]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_1 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[1]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_2 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[2]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_2 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[2]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_2 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[2]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_2 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[2]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_3 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[3]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_3 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[3]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_3 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[3]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_3 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[3]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_4 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[4]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_4 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[4]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_4 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[4]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_4 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[4]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_5 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[5]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_5 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[5]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_5 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[5]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_5 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[5]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_6 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[6]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_6 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[6]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_6 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[6]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_6 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[6]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_7 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[7]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_7 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[7]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_7 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[7]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_7 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[7]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_8 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[8]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_8 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[8]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_8 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[8]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_8 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[8]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_9 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[9]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_9 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[9]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_9 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[9]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_9 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[9]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_10 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[10]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_10 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[10]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_10 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[10]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_10 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[10]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_11 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[11]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_11 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[11]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_11 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[11]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_11 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[11]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_12 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[12]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_12 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[12]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_12 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[12]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_12 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[12]} -prop_thru_buffers]

set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -min -add_delay [expr $tskew_min + $net_delay_dout_13 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[13]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -clock_fall -max -add_delay [expr $tskew_max + $net_delay_dout_13 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[13]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -min -add_delay [expr $tskew_min + $net_delay_dout_13 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[13]} -prop_thru_buffers]
set_input_delay -clock [get_clocks DcoClkIn] -max -add_delay [expr $tskew_max + $net_delay_dout_13 - $OutputDelay - $net_delay_dco_clk] [get_ports {diZmodADC_Data[13]} -prop_thru_buffers]

set_false_path -fall_from [get_pins -hier -filter {NAME =~ *InstClockGenPriRefClkReset*/SyncAsyncx/oSyncStages_reg[1]/C}] -to [get_pins -hier -filter {NAME=~ *InstCG_ClkODDR*/R}]
set_false_path -rise_from [get_pins -hier -filter {NAME =~ *InstClockGenPriRefClkReset*/SyncAsyncx/oSyncStages_reg[1]/C}] -fall_to [get_pins -hier -filter {NAME=~ *InstCG_ClkODDR*/R}]
set_false_path -setup -rise_from [get_pins -hier -filter {NAME =~ *InstClockGenPriRefClkReset*/SyncAsyncx/oSyncStages_reg[1]/C}] -fall_to [get_pins -hier -filter {NAME=~ *InstCG_ClkODDR*/R}]