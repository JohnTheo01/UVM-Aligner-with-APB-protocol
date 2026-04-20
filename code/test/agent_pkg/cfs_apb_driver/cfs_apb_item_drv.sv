`ifndef CFS_APB_ITEM_DRV_SV

    `define CFS_APB_ITEM_DRV_SV

    class cfs_apb_item_drv extends cfs_apb_item_base;


        rand cfs_apb_dir dir;

        rand cfs_apb_addr addr;

        rand cfs_apb_data data;      

        // Delays
        rand int unsigned  predrive_delay;
        rand int unsigned  postdrive_delay;

        constraint pre_drive_delay_default{
            soft predrive_delay <= 5;
        }

        constraint post_drive_delay_default{
            soft postdrive_delay <= 5;
        }

        // Προσοχή έχουμε object utils και όχι component
        `uvm_object_utils(cfs_apb_item_drv)

        // Προσοχή δεν έχει parent component
        function new(string name = "");
            super.new(name);
        endfunction

        virtual function string convert2string();
            string result = $sformatf("dir: %0s, addr: %0x", dir.name(), addr);

            // Το Data field έχει νόημα μόνο για write transactions
            if (dir == CFS_APB_WRITE) begin
                result = $sformatf("%s, data: %0x", result, data);
            end
            
            result = $sformatf("%s, predrive_delay: %0d, postdrive_delay: %0d", 
                result, predrive_delay, postdrive_delay);

             return result;
        endfunction

    endclass

`endif