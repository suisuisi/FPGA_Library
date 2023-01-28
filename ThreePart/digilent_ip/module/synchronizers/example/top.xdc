create_clock -period 100.000 -name OneClk -waveform {0.000 50.000} [get_ports OneClk]
create_clock -period 100.000 -name TwoClk -waveform {1.000 51.000} [get_ports TwoClk]

current_instance -quiet

# Begin scope to SyncAsync instance
current_instance [get_cells SyncAsync1]
# Input to synchronizer ignored for timing analysis
set_false_path -through [get_ports -scoped_to_current_instance aIn]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells oSyncStages_reg[*]] -to [get_cells oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to SyncAsync instance

# Begin scope to ResetBridge instance
current_instance [get_cells ResetBridgePos]
 # Reset input to the synchronizer must be ignored for timing analysis
set_false_path -through [get_ports -scoped_to_current_instance aRst]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] -to [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to ResetBridge instance

# Begin scope to ResetBridge instance
current_instance [get_cells ResetBridgeNeg]
 # Reset input to the synchronizer must be ignored for timing analysis
set_false_path -through [get_ports -scoped_to_current_instance aRst]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] -to [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to ResetBridge instance

# Begin scope to ResetBridge instance
current_instance [get_cells ResetBridgeBack]
 # Reset input to the synchronizer must be ignored for timing analysis
set_false_path -through [get_ports -scoped_to_current_instance aRst]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] -to [get_cells OutputFF*.SyncAsyncx/oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to ResetBridge instance

# Replace <InstSyncBase> with path to SyncBase instance, keep rest unchanged
# Begin scope to SyncBase instance
current_instance [get_cells SyncBase]
# Input to synchronizer ignored for timing analysis
set_false_path -through [get_pins SyncAsyncx/aIn]
# Constrain internal synchronizer paths to half-period, which is expected to be easily met with ASYNC_REG=true
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_ports -scoped_to_current_instance OutClk]]]
set_max_delay -from [get_cells SyncAsyncx/oSyncStages_reg[*]] -to [get_cells SyncAsyncx/oSyncStages_reg[*]] [expr $ClkPeriod/2]
current_instance -quiet
# End scope to SyncBase instance

# For the SyncAsync modules inside this module, the path between the
# input clock domain and output clock domain needs to not be analized:
set_false_path -through [get_pins -filter {NAME =~ *SyncAsync*/oSyncStages_reg[0]/D} -hier]
# Also for the SyncAsync modules, the path between the flip-flops in
# the output clock domain needs to be overconstrained to half of the
# output clock period, to leave the other half for metastability to
# settle:
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_pins -filter {NAME =~ *HandshakeData*SyncAsyncPushTBack*/oSyncStages_reg[0]/C} -hier]]]
set_max_delay -from [get_pins -filter {NAME =~ *HandshakeData*SyncAsyncPushTBack*/oSyncStages_reg[0]/C} -hier] -to [get_pins -filter {NAME =~ *HandshakeData*SyncAsyncPushTBack*/oSyncStages_reg[1]/D} -hier] [expr {$ClkPeriod/2}]
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_pins -filter {NAME =~ *HandshakeData*SyncAsyncPushT/oSyncStages_reg[0]/C} -hier]]]
set_max_delay -from [get_pins -filter {NAME =~ *HandshakeData*SyncAsyncPushT/oSyncStages_reg[0]/C} -hier] -to [get_pins -filter {NAME =~ *HandshakeData*SyncAsyncPushT/oSyncStages_reg[1]/D} -hier] [expr {$ClkPeriod/2}]
# For the ResetBridge module inside this module, the path between the
# flip-flops in the output clock domain needs to be overconstrained to
# half of the output clock period, to leave the other half for
# metastability to settle:
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_pins -filter {NAME =~ *HandshakeData*SyncReset*SyncAsync*/oSyncStages_reg[0]/C} -hier]]]
set_max_delay -from [get_pins -filter {NAME =~ *HandshakeData*SyncReset*SyncAsync*/oSyncStages_reg[0]/C} -hier] -to [get_pins -filter {NAME =~ *HandshakeData*SyncReset*SyncAsync*/oSyncStages_reg[1]/D} -hier] [expr {$ClkPeriod/2}]
# Also for the ResetBridge module, we need to disable timing analysis on
# the reset paths, for both its edges. This is necessary because the
# input reset of this module is considered to be fully asynchronous:
set_false_path -to [get_pins -filter {NAME =~ *HandshakeData*SyncReset*SyncAsync*/oSyncStages*/PRE || NAME =~ *HandshakeData*SyncReset*SyncAsync*/oSyncStages*/CLR} -hier]
# For the data path between the input clock domain and the output clock
# domain, the maximum delay needs to be set to 2 output clock cycles, so
# the data sampled in the output clock domain is stable by the time
# oPushTChanged is asserted.
set ClkPeriod [get_property PERIOD [get_clocks -of_objects [get_pins -filter {NAME =~ *HandshakeData*/oData_reg[0]/C} -hier]]]
set_max_delay -datapath_only -from [get_cells -hier -filter {NAME =~ *HandshakeData*/iData_int_reg[*]}] -to [get_cells -hier -filter {NAME=~ *HandshakeData*/oData_reg[*]}] [expr {$ClkPeriod*2}]
