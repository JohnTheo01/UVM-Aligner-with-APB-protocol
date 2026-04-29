`ifndef CFS_MD_DRIVER_SV

    `define CFS_MD_DRIVER_SV

    class cfs_md_driver#(int unsigned DATA_WIDTH = 32, type ITEM_DRV = cfs_md_item_drv) 
        extends uvm_driver#(.REQ(ITEM_DRV))
        implements cfs_md_reset_handler;

        

        cfs_md_agent_config #(DATA_WIDTH) agent_config;

        protected process process_drive_transactions;

        `uvm_component_param_utils(cfs_md_driver#(DATA_WIDTH, ITEM_DRV))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        // ----------------------------------- Reset Logic -----------------------------------


        virtual task wait_reset_end();
            agent_config.wait_reset_end();
        endtask

        virtual function void handle_reset(uvm_phase phase);

            if(process_drive_transactions !== null) begin
                process_drive_transactions.kill();

                process_drive_transactions = null;
            end
        endfunction

        // ----------------------------------- UVM phases -----------------------------------
        

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

        // ----------------------------------- drive transactions -----------------------------------
        

        protected virtual task drive_transactions();
            fork
                begin
                    process_drive_transactions = process::self();

                    forever begin
                        ITEM_DRV item;
                        seq_item_port.get_next_item(item);

                        drive_transaction(item);

                        seq_item_port.item_done();
                    end
                end
            join
        endtask

        protected virtual task drive_transaction(ITEM_DRV item);
            `uvm_fatal("ALGORITHM_ISSUE", "Implement drive_transactions()")
        endtask


    endclass

`endif