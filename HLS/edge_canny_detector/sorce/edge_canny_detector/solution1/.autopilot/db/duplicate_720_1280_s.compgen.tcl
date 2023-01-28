# This script segment is generated automatically by AutoPilot

# clear list
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_begin
    cg_default_interface_gen_bundle_begin
    AESL_LIB_XILADAPTER::native_axis_begin
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 49 \
    name gradx_mat_4210 \
    type fifo \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_gradx_mat_4210 \
    op interface \
    ports { gradx_mat_4210_dout { I 16 vector } gradx_mat_4210_empty_n { I 1 bit } gradx_mat_4210_read { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 50 \
    name grady_mat_4213 \
    type fifo \
    dir I \
    reset_level 1 \
    sync_rst true \
    corename dc_grady_mat_4213 \
    op interface \
    ports { grady_mat_4213_dout { I 16 vector } grady_mat_4213_empty_n { I 1 bit } grady_mat_4213_read { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 51 \
    name gradx1_mat_4211 \
    type fifo \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_gradx1_mat_4211 \
    op interface \
    ports { gradx1_mat_4211_din { O 16 vector } gradx1_mat_4211_full_n { I 1 bit } gradx1_mat_4211_write { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 52 \
    name gradx2_mat_4212 \
    type fifo \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_gradx2_mat_4212 \
    op interface \
    ports { gradx2_mat_4212_din { O 16 vector } gradx2_mat_4212_full_n { I 1 bit } gradx2_mat_4212_write { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 53 \
    name grady1_mat_4214 \
    type fifo \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_grady1_mat_4214 \
    op interface \
    ports { grady1_mat_4214_din { O 16 vector } grady1_mat_4214_full_n { I 1 bit } grady1_mat_4214_write { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id 54 \
    name grady2_mat_4215 \
    type fifo \
    dir O \
    reset_level 1 \
    sync_rst true \
    corename dc_grady2_mat_4215 \
    op interface \
    ports { grady2_mat_4215_din { O 16 vector } grady2_mat_4215_full_n { I 1 bit } grady2_mat_4215_write { O 1 bit } } \
} "
}

# Direct connection:
if {${::AESL::PGuard_autoexp_gen}} {
eval "cg_default_interface_gen_dc { \
    id -1 \
    name ap_ctrl \
    type ap_ctrl \
    reset_level 1 \
    sync_rst true \
    corename ap_ctrl \
    op interface \
    ports { ap_done { O 1 bit } ap_idle { O 1 bit } ap_continue { I 1 bit } } \
} "
}


# Adapter definition:
set PortName ap_clk
set DataWd 1 
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc cg_default_interface_gen_clock] == "cg_default_interface_gen_clock"} {
eval "cg_default_interface_gen_clock { \
    id -2 \
    name ${PortName} \
    reset_level 1 \
    sync_rst true \
    corename apif_ap_clk \
    data_wd ${DataWd} \
    op interface \
}"
} else {
puts "@W \[IMPL-113\] Cannot find bus interface model in the library. Ignored generation of bus interface for '${PortName}'"
}
}


# Adapter definition:
set PortName ap_rst
set DataWd 1 
if {${::AESL::PGuard_autoexp_gen}} {
if {[info proc cg_default_interface_gen_reset] == "cg_default_interface_gen_reset"} {
eval "cg_default_interface_gen_reset { \
    id -3 \
    name ${PortName} \
    reset_level 1 \
    sync_rst true \
    corename apif_ap_rst \
    data_wd ${DataWd} \
    op interface \
}"
} else {
puts "@W \[IMPL-114\] Cannot find bus interface model in the library. Ignored generation of bus interface for '${PortName}'"
}
}



# merge
if {${::AESL::PGuard_autoexp_gen}} {
    cg_default_interface_gen_dc_end
    cg_default_interface_gen_bundle_end
    AESL_LIB_XILADAPTER::native_axis_end
}


