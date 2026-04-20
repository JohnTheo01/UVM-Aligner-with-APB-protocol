`ifndef CFS_APB_AGENT

    `define CFS_APB_AGENT

    class cfs_apb_agent extends uvm_agent;
        
        `uvm_component_utils(cfs_apb_agent)

        // Handler για το Agent configuration
        cfs_apb_agent_config agent_config;

        function  new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agent_config = cfs_apb_agent_config::type_id::create(
                "agent_config",
                this
            );

        endfunction

      	virtual function void connect_phase(uvm_phase phase);
        
          	cfs_apb_vif vif;
          
          	super.connect_phase(phase);
          	
            if (uvm_config_db#(cfs_apb_vif)::get(
                this, "", "vif", vif
            ) == 0) begin
              	`uvm_fatal("APB_NO_VIF", "Could not get APB VIF from database") 
            end
          	else begin
              	agent_config.set_vif(vif);
            end
          
        endfunction
    endclass 

`endif 