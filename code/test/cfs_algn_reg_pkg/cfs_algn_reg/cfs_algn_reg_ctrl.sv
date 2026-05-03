`ifndef CFS_ALGN_REG_CTRL_SV

    `define CFS_ALGN_REG_CTRL_SV

    class cfs_algn_reg_ctrl extends uvm_reg;

        // ----------------------------------- REG FIELDS -----------------------------------
        rand uvm_reg_field SIZE;

        rand uvm_reg_field OFFSET;

        rand uvm_reg_field CLR;

        local int unsigned ALGN_DATA_WIDTH;

        // ----------------------------------- CONSTRAINTS -----------------------------------
        constraint legal_size {
            SIZE.value != 0;
        }

        constraint legal_combination_size_offset{
            ((ALGN_DATA_WIDTH / 8) + OFFSET.value) % SIZE.value == 0;
            OFFSET.value + SIZE.value <= (ALGN_DATA_WIDTH / 8);
        }

        // ----------------------------------- BOILERPLATE CODE  -----------------------------------
        `uvm_object_utils(cfs_algn_reg_ctrl)
        
        function new(string name = "");
            super.new(name, .n_bits(32), .has_coverage(UVM_NO_COVERAGE));
            
            this.ALGN_DATA_WIDTH = 8;
        endfunction

        virtual function void build();
            SIZE    = uvm_reg_field::type_id::create("SIZE", null, get_full_name());
            OFFSET  = uvm_reg_field::type_id::create("OFFSET", null, get_full_name());
            CLR     = uvm_reg_field::type_id::create("CLR", null, get_full_name());


            SIZE.configure(
                .parent(this),
                .size(3), 
                .lsb_pos(0),
                .access("RW"),
                .volatile(0),
                .reset(3'b001),
                .has_reset(1), 
                .is_rand(1), 
                .individually_accessible(0)
            );

            OFFSET.configure(
                .parent(this),
                .size(2),
                .lsb_pos(8),
                .access("RW"),
                .volatile(0),
                .reset(2'b00),
                .has_reset(1), 
                .is_rand(1),
                .individually_accessible(0)
            );

            CLR.configure(
                .parent(this),
                .size(1),
                .lsb_pos(16),
                .access("RO"),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1), 
                .is_rand(1),
                .individually_accessible(0)
            );

        endfunction

        virtual function void set_algn_data_width(int unsigned value);
             if ((value < 8) || ($countones(value) != 1)) begin
                `uvm_fatal("ALGORITHM_ISSUE", "You need to specify correct values for \"algn_data_width\"")
            end 
            
            this.ALGN_DATA_WIDTH = value;
        endfunction 

        virtual function int unsigned get_algn_data_width();
            return this.ALGN_DATA_WIDTH;
        endfunction

    endclass

`endif