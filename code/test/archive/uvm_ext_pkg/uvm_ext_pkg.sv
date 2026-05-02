`ifndef UVM_EXT_PKG_SV

    `define UVM_EXT_PKG_SV

    `include "uvm_macros.svh"

    package uvm_ext_pkg;
        import uvm_pkg::*;

        `include "uvm_ext_reset_handler.sv"

        `include "uvm_ext_agent_config.sv" 

        `include "uvm_ext_monitor.sv"       

        `include "uvm_ext_coverage.sv"

        `include "uvm_ext_sequencer.sv"

        `include "uvm_ext_driver.sv"

        `include "uvm_ext_agent.sv"

    endpackage

`endif