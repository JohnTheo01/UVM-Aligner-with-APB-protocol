`ifndef CFS_ALGN_REG_STATUS_SV

    `define CFS_ALGN_REG_STATUS_SV

    class cfs_algn_reg_status extends uvm_reg;

        rand uvm_reg_field CNT_DROP;

        rand uvm_reg_field RX_LVL;
        
        rand uvm_reg_field TX_LVL;

        `uvm_object_utils(cfs_algn_reg_status)

        function new(string name = "");
            super.new(name, 32, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            CNT_DROP    = uvm_reg_field::type_id::create("CNT_DROP", null, get_full_name());
            RX_LVL      = uvm_reg_field::type_id::create("RX_LVL", null, get_full_name());
            TX_LVL      = uvm_reg_field::type_id::create("TX_LVL", null, get_full_name());
        
            CNT_DROP.configure(
                .parent(this),
                .size(8), 
                .lsb_pos(0),
                .access("RO"),
                .volatile(0),
                .reset(8'b00000000),
                .has_reset(1), 
                .is_rand(1), 
                .individually_accessible(0)
            );

            RX_LVL.configure(
                .parent(this),
                .size(4), 
                .lsb_pos(8),
                .access("RO"),
                .volatile(0),
                .reset(4'b0000),
                .has_reset(1), 
                .is_rand(1), 
                .individually_accessible(0)
            );


            TX_LVL.configure(
                .parent(this),
                .size(4), 
                .lsb_pos(16),
                .access("RO"),
                .volatile(0),
                .reset(4'b0000),
                .has_reset(1), 
                .is_rand(1), 
                .individually_accessible(0)
            );


        endfunction 

    endclass

`endif