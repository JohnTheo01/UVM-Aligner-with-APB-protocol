`ifndef CFS_ALGN_ENV_SV
  `define CFS_ALGN_ENV_SV
	

  class cfs_algn_env#(int unsigned DATA_WIDTH = 32) extends uvm_env;

    `uvm_component_param_utils(cfs_algn_env#(DATA_WIDTH))
    
    cfs_apb_agent apb_agent;

    // Handlers for MD_RX, MD_TX agents
    cfs_md_agent_master #(DATA_WIDTH) md_rx_agent;

    cfs_md_agent_slave #(DATA_WIDTH) md_tx_agent;
    
    function new(string name = "", uvm_component parent);
      super.new(name, parent);
    endfunction
    

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Προσθήκη APB agent
        apb_agent = cfs_apb_agent::type_id::create(
            "apb_agent",
            this
        );

        md_rx_agent = cfs_md_agent_master#(DATA_WIDTH)::type_id::create(
          "md_rx_agent",
          this
        );

        md_tx_agent = cfs_md_agent_slave#(DATA_WIDTH)::type_id::create(
          "md_tx_agent",
          this
        );

    endfunction
    
  endclass

`endif