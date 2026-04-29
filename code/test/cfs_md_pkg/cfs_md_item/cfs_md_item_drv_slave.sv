`ifndef CFS_MD_ITEM_DRV_SLAVE_SV

    `define CFS_MD_ITEM_DRV_SLAVE_SV

    class cfs_md_item_drv_slave extends cfs_md_item_drv;

        rand int unsigned length;

        rand cfs_md_response response;

        rand bit ready_at_end;

        `uvm_object_utils(cfs_md_item_drv_slave)

        constraint length_default{
            soft length <= 5;
        }

        function new(string name = "");
            super.new(name);
        endfunction

        virtual function string convert2string();
            return $sformatf("length: %0d, response: %0s, ready_at_end: %0b", length, response.name(), ready_at_end);
        endfunction


    endclass

`endif