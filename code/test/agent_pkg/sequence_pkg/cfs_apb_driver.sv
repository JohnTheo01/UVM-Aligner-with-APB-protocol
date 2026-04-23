`ifndef CFS_APB_DRIVER

    `define CFS_APB_DRIVER

    class cfs_apb_driver extends uvm_driver#(.REQ(cfs_apb_item_drv)) implements cfs_apb_reset_handler;

        cfs_apb_agent_config agent_config;

        // Process for drive_transactions task
        protected process process_drive_tansactions;

        `uvm_component_utils(cfs_apb_driver)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                fork
                    begin
                        wait_reset_end();
                        drive_transactions();

                        disable fork;
                    end
                join
                
            end
        endtask


        protected virtual task drive_transactions();
            fork
                begin
                    process_drive_tansactions = process::self();

                    forever begin
                        cfs_apb_item_drv item;
                        seq_item_port.get_next_item(item);
                        
                        drive_transaction(item);
                        
                        seq_item_port.item_done();
                    end
                end
            join
        endtask

        // Οδηγεί ένα item στο bus
        protected virtual task drive_transaction(cfs_apb_item_drv item);
            cfs_apb_vif vif = agent_config.get_vif();
            `uvm_info("DEBUG", $sformatf("Driving: %s", item.convert2string()), UVM_NONE)
        
            // Η λογική για να περιμένουμε το pre_drive_delay τόσους κύκλους ρολογιού
            for (int i = 0; i < item.pre_drive_delay; i++) begin
                @(posedge vif.pclk);
            end

            // Ξεκινάμε την Setup Phase
            vif.psel    <= 1;
            vif.pwrite  <= bit'(item.dir);
            vif.paddr   <= item.addr;

            if (item.dir == CFS_APB_WRITE) begin
                vif.pwdata <= item.data;
            end

            // Αναμένουμε έναν κύκλο
            @(posedge vif.pclk);

            // Οδηγούμε το penable
            vif.penable <= 1;

            // Αναμένουμε άλλο ένα κύκλο
            @(posedge vif.pclk);

            // Περιμένουμε το pready να γίνει 1 
            while(vif.pready !== 1) begin
                @(posedge vif.pclk);
            end


            // Ολοκληρώθηκε το transfer. Επαναφορά στο 0
            vif.psel    <= 0;
            vif.penable <= 0;
            vif.pwrite  <= 0;
            vif.paddr   <= 0;
            vif.pwdata   <= 0;

             // Η λογική για να περιμένουμε το pre_drive_delay τόσους κύκλους ρολογιού
            for (int i = 0; i < item.post_drive_delay; i++) begin
                @(posedge vif.pclk);
            end

        endtask

        virtual function void handle_reset(uvm_phase phase);

            cfs_apb_vif vif = agent_config.get_vif();

            if (process_drive_tansactions !== null) begin
                process_drive_tansactions.kill();

                process_drive_tansactions = null;
            end

            //Reset signals
            vif.psel    <= 0;
            vif.penable <= 0;
            vif.pwrite  <= 0;
            vif.paddr   <= 0;
            vif.pwdata   <= 0;
        endfunction

        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

    endclass

`endif