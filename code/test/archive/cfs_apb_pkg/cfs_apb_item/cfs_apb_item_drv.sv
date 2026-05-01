`ifndef CFS_APB_ITEM_DRV_SV

    `define CFS_APB_ITEM_DRV_SV

    class cfs_apb_item_drv extends cfs_apb_item_base; 

        // Delays
        rand int unsigned  pre_drive_delay;
        rand int unsigned  post_drive_delay;

        constraint pre_drive_delay_default{
            soft pre_drive_delay <= 5;
        }

        constraint post_drive_delay_default{
            soft post_drive_delay <= 5;
        }

        // Προσοχή έχουμε object utils και όχι component
        `uvm_object_utils(cfs_apb_item_drv)

        // Προσοχή δεν έχει parent component
        function new(string name = "");
            super.new(name);
        endfunction

        virtual function string convert2string();
            string result = super.convert2string();

            // Το Data field έχει νόημα μόνο για write transactions
            if (dir == CFS_APB_WRITE) begin
                result = $sformatf("%s, data: %0x", result, data);
            end
            
            result = $sformatf("%s, predrive_delay: %0d, postdrive_delay: %0d", 
                result, pre_drive_delay, post_drive_delay);

             return result;
        endfunction

    endclass

`endif