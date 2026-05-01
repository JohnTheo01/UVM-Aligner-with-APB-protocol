`ifndef CFS_APB_AGENT

    `define CFS_APB_AGENT

    class cfs_apb_agent extends uvm_agent implements cfs_apb_reset_handler;
        
        `uvm_component_utils(cfs_apb_agent)

        // Handler για το Agent configuration
        cfs_apb_agent_config agent_config;

        // Handlers για drive/Sequencer
        cfs_apb_sequencer sequencer;
        cfs_apb_driver driver;

        // Handler για Monitor
        cfs_apb_monitor monitor;

        // Handler για coverage
        cfs_apb_coverage coverage;

        function  new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agent_config = cfs_apb_agent_config::type_id::create(
                "agent_config",
                this
            );
            monitor = cfs_apb_monitor::type_id::create(
                "monitor",
                this
            );

            if (agent_config.get_has_coverage()) begin 
                coverage = cfs_apb_coverage::type_id::create("coverage", this);
            end

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

            monitor.agent_config = agent_config;

            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                // Σύνδεση του driver με το agent config
                driver.agent_config = agent_config;
                driver.seq_item_port.connect(sequencer.seq_item_export);
            end

            if (agent_config.get_has_coverage()) begin
                coverage.agent_config = agent_config;
                monitor.output_port.connect(coverage.port_item);
            end
          
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            uvm_component children[$];

            get_children(children);

            foreach (children[idx]) begin
                cfs_apb_reset_handler reset_handler;

                if($cast(reset_handler, children[idx])) begin
                    reset_handler.handle_reset(phase);
                end
            end
        endfunction

        virtual task wait_reset_start();
            agent_config.wait_reset_start();
        endtask

        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        virtual task run_phase(uvm_phase phase);
            forever begin
                wait_reset_start();
                handle_reset(phase);
                wait_reset_end();
            end
        endtask


    endclass 

`endif 