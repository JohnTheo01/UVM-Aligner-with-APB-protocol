`ifndef CFS_MD_MONITOR_SV

    `define CFS_MD_MONITOR_SV

    class cfs_md_monitor#(int unsigned DATA_WIDTH = 32) 
        extends uvm_monitor
        implements cfs_md_reset_handler;

        // ----------------------------------- FIELDS -----------------------------------
        
        cfs_md_agent_config #(DATA_WIDTH) agent_config;

        uvm_analysis_port#(cfs_md_item_mon) output_port;

        // Process pointer for collect transactions
        protected process process_collect_transactions;

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        `uvm_component_param_utils(cfs_md_monitor#(DATA_WIDTH))

        // ----------------------------------- NEW -----------------------------------

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            // Ορίζουμε το output_port
            output_port = new("output_port", this);
        endfunction

        // ----------------------------------- RUN PHASE -----------------------------------
        
        virtual task run_phase(uvm_phase phase);
            forever begin
                fork
                    begin
                        wait_reset_end();
                        collect_transactions();

                        disable fork;
                    end
                join
            end
        endtask

        // ----------------------------------- COLLECT TRANSACTIONS -----------------------------------
        
        protected virtual task collect_transactions();
            fork
                begin
                    process_collect_transactions = process::self();

                    forever begin
                        collect_transaction();
                    end
                end
            join
            
        endtask

        // ----------------------------------- RESET LOGIC -----------------------------------
        
        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        virtual function void handle_reset(uvm_phase phase);
            if(process_collect_transactions !== null) begin
                process_collect_transactions.kill();

                process_collect_transactions = null;
            end
        endfunction

        // ----------------------------------- COLLECT TRANSACTION -----------------------------------
        protected virtual task collect_transaction();

            cfs_md_vif vif = agent_config.get_vif();

            cfs_md_item_mon item = cfs_md_item_mon::type_id::create(
                "item"
            );

            int data_width_in_bytes = DATA_WIDTH / 8;

            #(agent_config.get_sample_delay_start_tr());

            while (vif.valid !== 1) begin
                @(posedge vif.clk);
                #(agent_config.get_sample_delay_start_tr());

                item.prev_item_delay += 1;
            end

            // Πλέον ξέρουμε ότι το item ξεκίνησε
            item.offset <= vif.offset;
            
            // Περνάμε ένα ένα τα byte (για αυτό και το & 8'hFF)
            for (int i = 0; i < vif.size; i++) begin
                item.data.push_back(vif.data >> ((vif.offset + i) * 8) & 8'hFF);
            end

            // Έχει ήδη περάσει ένας κύκλος ρολογιού.
            item.length = 1;

            // Ορίζουμε την αρχή του transaction
            void'(begin_tr(item));

              `uvm_info("DEBUG", $sformatf("Monitor started collecting item %s", item.convert2string()), UVM_NONE)

            // Περάνμε το item που λάβαμε
            output_port.write(item);

            @(posedge vif.clk);

            // Περιμένουμε να ολοκληρωθεί η συναλλαγή
            while(vif.ready !== 1) begin
                @(posedge vif.clk);
                item.length += 1;

                if (agent_config.get_has_checks()) begin
                    if (item.length >= agent_config.get_stuck_threshold()) begin
                        `uvm_error("PROTOCOL_ERROR", $sformatf("The APB transfer reached the stuck threshold of %0d clock cycles", agent_config.get_stuck_threshold()))
                    end
                end
            end 

            item.response = cfs_md_response'(vif.err);
            void'(end_tr(item));

            output_port.write(item);

            `uvm_info("DEBUG", $sformatf("Monitored item %s", item.convert2string()), UVM_NONE)

        endtask

    endclass

`endif