`ifndef CFS_APB_DRIVER

    `define CFS_APB_DRIVER

    class cfs_apb_driver extends uvm_driver#(.REQ(cfs_apb_item_drv));

        `uvm_component_utils(cfs_apb_driver)

        

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);

            forever begin
                cfs_apb_item_drv item;

                seq_item_port.get_next_item(item);                

              	`uvm_info("DEBUG", $sformatf("Driving: %s", item.convert2string()), UVM_NONE)

              	seq_item_port.item_done();
            end
        endtask

    endclass

`endif