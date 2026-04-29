`ifndef CFS_APB_MONITOR_SV

    `define CFS_APB_MONITOR_SV

    class cfs_apb_monitor extends uvm_monitor implements cfs_apb_reset_handler;

        cfs_apb_agent_config agent_config;

        uvm_analysis_port#(cfs_apb_item_mon) output_port;

        // Process pointer for collect transactions
        protected process process_collect_transactions;

        `uvm_component_utils(cfs_apb_monitor)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            // Ορίζουμε το output_port
            output_port = new("output_port", this);
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                wait_reset_end();
                collect_transactions();

                disable fork;
            end
        endtask

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

        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        virtual function void handle_reset(uvm_phase phase);
            if(process_collect_transactions !== null) begin
                process_collect_transactions.kill();

                process_collect_transactions = null;
            end
        endfunction

        protected virtual task collect_transaction();
            cfs_apb_vif vif = agent_config.get_vif();

            cfs_apb_item_mon item = cfs_apb_item_mon::type_id::create("item");

            // Αποθηκεύουμε το delay σε κύκλους ρολογιού
            while (vif.psel !== 1) begin
                @(posedge vif.pclk);
                item.prev_item_delay += 1;
            end

            // Συλέγουμε τις υπόλοιπες πληροφορίες
            item.addr = vif.paddr;
            item.dir = cfs_apb_dir'(vif.pwrite);

            if (item.dir == CFS_APB_WRITE) begin
                item.data = vif.pwdata;
            end

            // Αρχικοποιούμε το length σε 1 (ήδη έχει περάσει ένας κύκλος ρολογιού)
            item.length = 1;

            @(posedge vif.pclk);
            item.length += 1;

            while (vif.pready !== 1) begin
                @(posedge vif.pclk);
                item.length += 1;

                if (agent_config.get_has_checks()) begin
                    if (item.length >= agent_config.get_stuck_threshold()) begin
                        `uvm_error("PROTOCOL_ERROR", $sformatf("The APB transfer reached the stuck threshold of %0d clock cycles", agent_config.get_stuck_threshold()))
                    end
                end
            end

            

            // Παίρνουμε το response (εάν είχαμε error)
            item.response = cfs_apb_response'(vif.pslverr);

            // Διαβάζουμε τα δεδομένα εάν είχαμε read
            if (item.dir == CFS_APB_READ) begin
                item.data = vif.prdata;
            end

            // Γράφουμε τα δεδομένα
            output_port.write(item);

            // Ενημερώνουμε το σύστημα για την ανάγνωση
            `uvm_info("MONITOR", $sformatf("Monitored item: %s", item.convert2string()), UVM_NONE)

        endtask

    endclass

`endif 