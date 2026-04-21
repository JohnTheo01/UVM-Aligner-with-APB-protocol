`ifndef CFS_APB_AGENT

    `define CFS_APB_AGENT

    class cfs_apb_agent extends uvm_agent;
        
        `uvm_component_utils(cfs_apb_agent)

        // Handler για το Agent configuration
        cfs_apb_agent_config agent_config;

        // Handlers για drive/Sequencer
        cfs_apb_sequencer sequencer;
        cfs_apb_driver driver;

        function  new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agent_config = cfs_apb_agent_config::type_id::create(
                "agent_config",
                this
            );

            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                sequencer = cfs_apb_sequencer::type_id::create("sequence", this);
                driver = cfs_apb_driver::type_id::create("driver", this);
            end

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

            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                driver.seq_item_port.connect(sequencer.seq_item_export);
            end
          
        endfunction
    endclass 

`endif 