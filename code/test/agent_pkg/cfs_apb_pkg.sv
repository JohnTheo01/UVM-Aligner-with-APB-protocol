`ifndef CFS_APB_PKG_SV
  `define CFS_APB_PKG_SV

  `include "uvm_macros.svh"

  `include "cfs_apb_if.sv"

  package cfs_apb_pkg;
    import uvm_pkg::*;

    `include "cfs_apb_types.sv"
    
	`include "cfs_apb_item_base.sv"
    `include "cfs_apb_item_drv.sv"

    `include "cfs_apb_agent_config.sv"

	`include "cfs_apb_sequencer.sv"
	`include "cfs_apb_driver.sv"

	`include "cfs_apb_sequence_base.sv"
	`include "cfs_apb_sequence_simple.sv"
	`include "cfs_apb_sequence_rw.sv"

	`include "cfs_apb_agent.sv"
  endpackage

`endif