`ifndef CFS_MD_DRIVER_MASTER_SV

    `define CFS_MD_DRIVER_MASTER_SV

    class cfs_md_driver_master#(int unsigned DATA_WIDTH = 32) 
        extends cfs_md_driver#(.DATA_WIDTH(DATA_WIDTH), .ITEM_DRV(cfs_md_item_drv_master));

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

      `uvm_component_param_utils(cfs_md_driver_master#(DATA_WIDTH))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);            
        endfunction

        protected virtual task drive_transaction(cfs_md_item_drv_master item);
            
            cfs_md_vif vif = agent_config.get_vif();

            int unsigned data_width_in_bytes = DATA_WIDTH / 8;

            `uvm_info("DEBUG", $sformatf("Driving \"%0s\": %0s", item.get_full_name(), item.convert2string()), UVM_NONE)

            if(item.offset + item.data.size() > data_width_in_bytes) begin
                `uvm_fatal("ALGORITHM_ISSUE", $sformatf("Trying to drive an item with offset: \"%0d\" and size: \"%0d\" but bus width in bytes is: \"%0d\"",
                    item.offset, item.data.size(), data_width_in_bytes))
            end


            // ----------------------------------- Pre Drive Delay -----------------------------------            
            for (int i = 0; i < item.pre_drive_delay; i++) begin
                @(posedge vif.clk);
            end

            // ----------------------------------- Set valid -----------------------------------
            vif.valid <= 1;
            
            // ----------------------------------- Setup data -----------------------------------
            begin 
                bit[DATA_WIDTH-1:0] data = 0;

                foreach (item.data[idx]) begin
                    bit[DATA_WIDTH-1:0] temp = item.data[idx] << (item.offset + idx) * 8;

                    data = data | temp;
                end

                vif.data <= data;
            end

            // ----------------------------------- Offset, Size -----------------------------------
            vif.offset <= item.offset;
            vif.size <= item.data.size();

            // ----------------------------------- Wait Cycle -----------------------------------
            @(posedge vif.clk)
            // Test First Rule
            // vif.valid <= 0;

            vif.data <= 0;

            // ----------------------------------- Wait Resonse -----------------------------------
            while (vif.ready == 0) begin
                @(posedge vif.clk);
            end

            // ----------------------------------- Reset Signals -----------------------------------
            vif.valid   <= 0;
            vif.data    <= 0;
            vif.size    <= 0;
            vif.offset  <= 0;

            // ----------------------------------- Post Drive Delay -----------------------------------
            for (int i = 0; i < item.post_drive_delay; i++) begin
                @(posedge vif.clk);
            end
        endtask

        
        virtual function void handle_reset(uvm_phase phase);
            cfs_md_vif vif = agent_config.get_vif();

            super.handle_reset(phase);

            vif.valid   <= 0;
            vif.data    <= 0;
            vif.size    <= 0;
            vif.offset  <= 0;

        endfunction

    endclass

`endif