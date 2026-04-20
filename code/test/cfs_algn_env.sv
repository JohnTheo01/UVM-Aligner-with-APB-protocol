`ifndef CFS_ALGN_ENV_SV
  `define CFS_ALGN_ENV_SV
	

  class cfs_algn_env extends uvm_env;

    `uvm_component_utils(cfs_algn_env)
    
    cfs_apb_agent apb_agent;
    
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

    endfunction
    
  endclass

`endif