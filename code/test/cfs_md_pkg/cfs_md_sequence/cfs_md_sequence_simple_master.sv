`ifndef CFS_MD_SEQUENCE_SIMPLE_MASTER_SV

    `define CFS_MD_SEQUENCE_SIMPLE_MASTER_SV

    class cfs_md_sequence_simple_master
        extends cfs_md_sequence_base_master;

        `uvm_object_utils(cfs_md_sequence_simple_master)

        // Item constraints

        rand cfs_md_item_drv_master item;

        // Bus data width used for simulators not supporting functions in constraints
        local int unsigned data_width;

        constraint item_hard {
            item.data.size() > 0;
            item.data.size() <= data_width / 8;

            item.offset < data_width / 8;

            item.data.size() + item.offset < data_width / 8;
        }

        function new(string name = "");
            super.new(name);

            item = cfs_md_item_drv_master::type_id::create(
                "item"
            );

            // Κάνουμε disable τα constraints που δεν θέλουμε.
            item.data_default.constraint_mode(0);
            item.offset_default.constraint_mode(0);

        endfunction


        virtual task body();
            `uvm_send(item)
        endtask

        function void pre_randomize();
            this.data_width = p_sequencer.get_data_width();
        endfunction

    endclass
`endif