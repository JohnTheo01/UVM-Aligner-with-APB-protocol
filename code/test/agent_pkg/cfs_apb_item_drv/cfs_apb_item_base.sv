`ifndef CFS_APB_ITEM_BASE_SV

    `define CFS_APB_ITEM_BASE_SV

    class cfs_apb_item_base extends uvm_sequence_item;

        // Προσοχή έχουμε object utils και όχι component
        `uvm_object_utils(cfs_apb_item_base)

        // Προσοχή δεν έχει parent component
        function new(string name = "");
            super.new(name);
        endfunction

    endclass

`endif