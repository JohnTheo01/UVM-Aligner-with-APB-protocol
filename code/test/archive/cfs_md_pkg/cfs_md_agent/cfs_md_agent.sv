`ifndef CFS_MD_AGENT_SV

    `define CFS_MD_AGENT_SV

    class cfs_md_agent#(int unsigned DATA_WIDTH = 32, type ITEM_DRV = cfs_md_item_drv) 
        extends uvm_agent 
        implements cfs_md_reset_handler;

        typedef virtual cfs_md_if #(DATA_WIDTH) cfs_md_vif;

        cfs_md_agent_config #(DATA_WIDTH) agent_config;

        // Sequencer Handler
        cfs_md_sequencer_base #(ITEM_DRV) sequencer;

        // Driver Handler
        cfs_md_driver #(.DATA_WIDTH(DATA_WIDTH), .ITEM_DRV(ITEM_DRV)) driver; 

        // Monitor Handler
        cfs_md_monitor #(DATA_WIDTH) monitor;

        // Coverage Handler
        cfs_md_coverage #(DATA_WIDTH) coverage;

        `uvm_component_param_utils(cfs_md_agent#(DATA_WIDTH, ITEM_DRV))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction
    
        // ----------------------------------- UVM phases -----------------------------------
    
        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            agent_config = cfs_md_agent_config#(DATA_WIDTH)::type_id::create(
                "agent_config",
                this
            );

            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                
                sequencer = cfs_md_sequencer_base#(ITEM_DRV)::type_id::create(
                    "sequencer",
                    this
                );

                driver = cfs_md_driver#(DATA_WIDTH, ITEM_DRV)::type_id::create(
                    "driver",
                    this
                );
            end

            monitor = cfs_md_monitor#(DATA_WIDTH)::type_id::create(
                "monitor",
                this
            );

            if (agent_config.get_has_coverage()) begin
                coverage = cfs_md_coverage#(DATA_WIDTH)::type_id::create(
                    "coverage",
                    this
                );
            end
            

        endfunction

        virtual function void connect_phase(uvm_phase phase);
            
            cfs_md_vif vif;
            string vif_name = "vif";
            
            super.connect_phase(phase);

            // Connect Virtual Interface
            if(!uvm_config_db#(cfs_md_vif)::get(this, "", vif_name, vif)) begin 
                `uvm_fatal("MD_NO_VIF", $sformatf("Could not get from the database the MD virual interface using the name: %s", vif_name))
            end else begin
                agent_config.set_vif(vif);
            end

            if (agent_config.get_active_passive() == UVM_ACTIVE) begin
                driver.seq_item_port.connect(sequencer.seq_item_export);

                driver.agent_config = agent_config;
            end

            if (agent_config.get_has_coverage()) begin
                coverage.agent_config = agent_config;

                monitor.output_port.connect(coverage.port_item);
            end

            monitor.agent_config = agent_config;
        
        endfunction

      	virtual task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                wait_reset_start();
                handle_reset(phase);
                wait_reset_end();
            end

        endtask
        // ----------------------------------- Reset Logic -----------------------------------

        protected virtual task wait_reset_start();
            agent_config.wait_reset_start();
        endtask

        protected virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        virtual function void handle_reset(uvm_phase phase);
            
            uvm_component children[$];
            get_children(children);

            foreach (children[idx]) begin
                cfs_md_reset_handler reset_handler;

                if ($cast(reset_handler, children[idx])) begin
                    reset_handler.handle_reset(phase);
                end
            end
        endfunction

    endclass
`endif
