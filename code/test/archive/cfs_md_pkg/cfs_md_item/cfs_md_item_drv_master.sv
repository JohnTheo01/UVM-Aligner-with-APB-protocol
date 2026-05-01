`ifndef CFS_MD_ITEM_DRV_MASTER_SV

    `define CFS_MD_ITEM_DRV_MASTER_SV

    class cfs_md_item_drv_master extends cfs_md_item_drv;

        rand int unsigned pre_drive_delay;

        rand int unsigned post_drive_delay;

        rand bit[7:0] data[$];

        rand int unsigned offset;

        constraint pre_drive_delay_default {
            soft pre_drive_delay <= 5;
        }

        constraint post_drive_delay_default {
            soft post_drive_delay <= 5;
        }

        constraint data_default {
            soft data.size() == 1;
        }

        constraint data_hard {
            data.size() > 0;
        }

        constraint offset_default {
            soft offset == 0;
        }

        `uvm_object_utils(cfs_md_item_drv_master)

        function new(string name = "");
            super.new(name);
        endfunction

        virtual function string convert2string();
            string data_as_string = "{";

            foreach (data[idx]) begin
                data_as_string = $sformatf("%0s'h%02x%0s", data_as_string, data[idx], idx == data.size() - 1 ? "" : ", ");
            end

            data_as_string = $sformatf("%0s}", data_as_string);

            return $sformatf("data: %0s, offset: %0d, pre_drive_delay: %0d, post_drive_delay: %d",
                data_as_string, offset, pre_drive_delay, post_drive_delay);

        endfunction

    endclass

`endif