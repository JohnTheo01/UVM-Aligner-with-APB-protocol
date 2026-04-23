`ifndef CFS_APB_SEQUENCE_RW_SV

    `define CFS_APB_SEQUENCE_RW_SV

    class cfs_apb_sequence_rw extends cfs_apb_sequence_base;
        
        `uvm_object_utils(cfs_apb_sequence_rw)


        rand cfs_apb_addr addr;

        rand cfs_apb_data w_data;

        function new(string name = "");
          	super.new(name);
        endfunction 

        // Θέλουμε 2 items ένα που θα διαβάζει από αυτή την διεύθυνση και ένα που θα στέλνει σε αυτή την
        // διεύθυνση που περνάμε τα δεδομένα που περνάμε
      	virtual task body();

            cfs_apb_item_drv item;

            `uvm_do_with(item, {
                addr == local::addr;
                dir == CFS_APB_READ;
            })

            `uvm_do_with(item, {
                addr == local::addr;
                dir == CFS_APB_WRITE;
                data == w_data;
            })

        endtask

    endclass 

`endif