`ifndef CFS_APB_SEQUENCE_SIMPLE

    `define CFS_APB_SEQUENCE_SIMPLE

    class cfs_apb_sequence_simple extends cfs_apb_sequence_base;

        `uvm_object_utils(cfs_apb_sequence_simple)

        rand cfs_apb_item_drv item;

        function new(string name = "");
            super.new(name);

            item = cfs_apb_item_drv::type_id::create("item");
        endfunction

        virtual task body();
            // // Αρχίζουμε το item
            // start_item(item);

            // // Τελειώνουμε το item
            // finish_item(item);

            `uvm_do(item)
        endtask

    endclass

`endif 