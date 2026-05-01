`ifndef CFS_MD_ITEM_MON_SV

    `define CFS_MD_ITEM_MON_SV

    class cfs_md_item_mon 
        extends cfs_md_item_base;

        `uvm_object_utils(cfs_md_item_mon)

        // ----------------------------------- FIELDS -----------------------------------
        int unsigned prev_item_delay;

        int unsigned length;

        bit[7:0] data[$];

        int unsigned offset;

        cfs_md_response response;

        // ----------------------------------- NEW -----------------------------------
        function new(string name = "");
            super.new(name);
        endfunction


        // ----------------------------------- Convert 2 string -----------------------------------
        virtual function string convert2string();

            string data_as_string = "{";

            foreach (data[idx]) begin
                data_as_string = $sformatf("%0s'h%02x%0s", data_as_string, data[idx], idx == data.size() - 1 ? "" : ", ");
            end

            data_as_string = $sformatf("%0s}", data_as_string);

            return $sformatf("[%0t...%0s] data: %s, offset: %d, size: %d, response: %s, length: %d, prev_item_delay: %d",
                get_begin_time(),
                is_active() ? "" : $sformatf("%0t", get_end_time()),
                data_as_string,
                offset,
                data.size(),
                response.name(),
                length,
                prev_item_delay
            );

        endfunction

    endclass
`endif