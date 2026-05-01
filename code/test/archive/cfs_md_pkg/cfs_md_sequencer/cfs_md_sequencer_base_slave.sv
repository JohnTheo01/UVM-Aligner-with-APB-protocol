`ifndef CFS_MD_SEQUENCER_BASE_SLAVE_SV

    `define CFS_MD_SEQUENCER_BASE_SLAVE_SV

    class cfs_md_sequencer_base_slave 
        extends cfs_md_sequencer_base#(.ITEM_DRV(cfs_md_item_drv_slave));

        // FIFO containing pending items
        uvm_tlm_fifo#(cfs_md_item_mon) pending_items;

        // Port for receiving data from monitor
        uvm_analysis_imp#(cfs_md_item_mon, cfs_md_sequencer_base_slave) port_from_mon; 

        `uvm_component_utils(cfs_md_sequencer_base_slave)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            port_from_mon = new(
                "port_from_mon",
                this
            );

            pending_items = new(
                "pending_items",    // Name
                this,               // Parent
                1);                 // Size - 1 Item μπορεί να παράγει σε μία χρονική στιγμή ο master

        endfunction

        virtual function void write(cfs_md_item_mon item);
            //Ελέγχουμε εάν το item από το  monitor προέρχεται από την αρχή του item
            if(item.is_active()) begin
                // Ελέγχουμε εάν έχουμε χώρο
                if (pending_items.is_full()) begin
                    `uvm_fatal(
                        "AGLORITHM_ISSUE", 
                        $sformatf(
                            "FIFO %0s is full (size: %0d) - a possible cause is that there is one sequence started that pulls information from this FIFO",
                            pending_items.get_full_name(), pending_items.size()
                        )
                    )
                end
                
                // Δοκιμάζουμε να κάνουμε push στην FIFO
                if (pending_items.try_put(item) == 0) begin
                    `uvm_fatal(
                        "ALGORITHM_ISSUE",
                        $sformatf(
                            "Failed to push an new item in FIFO %0s",
                            pending_items.get_full_name()
                        )
                    )
                end
            end
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            super.handle_reset(phase);

            pending_items.flush();
        endfunction

    endclass


`endif 