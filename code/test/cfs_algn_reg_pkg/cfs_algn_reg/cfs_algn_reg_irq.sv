// =============================================================================
// AUTO-EDITED by add_uvm_field.py
// Last edit : 2026-05-02 16:10:57
// Generated : 2026-05-02 16:08:38
// Fields    : RX_FIFO_EMPTY, RX_FIFO_FULL, TX_FIFO_EMPTY, TX_FIFO_FULL, MAX_DROP
// Width     : 32 bits
// Coverage  : UVM_NO_COVERAGE
// =============================================================================

`ifndef CFS_ALGN_REG_IRQ_SV

    `define CFS_ALGN_REG_IRQ_SV

    class cfs_algn_reg_irq extends uvm_reg;

        rand uvm_reg_field RX_FIFO_EMPTY;
        rand uvm_reg_field RX_FIFO_FULL;
        rand uvm_reg_field TX_FIFO_EMPTY;
        rand uvm_reg_field TX_FIFO_FULL;
        rand uvm_reg_field MAX_DROP;
        // <<UVM_REG_FIELDS>>

        `uvm_object_utils(cfs_algn_reg_irq)

        function new(string name = "");
            super.new(name, 32, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();
            RX_FIFO_EMPTY = uvm_reg_field::type_id::create("RX_FIFO_EMPTY", null, get_full_name());
            RX_FIFO_FULL  = uvm_reg_field::type_id::create("RX_FIFO_FULL", null, get_full_name());
            TX_FIFO_EMPTY = uvm_reg_field::type_id::create("TX_FIFO_EMPTY", null, get_full_name());
            TX_FIFO_FULL  = uvm_reg_field::type_id::create("TX_FIFO_FULL", null, get_full_name());
            MAX_DROP      = uvm_reg_field::type_id::create("MAX_DROP", null, get_full_name());
            // <<UVM_CREATE_CALLS>>

            RX_FIFO_EMPTY.configure(
                this,
                .size(1),
                .lsb_pos(0),
                .access(W1C),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            RX_FIFO_FULL.configure(
                this,
                .size(1),
                .lsb_pos(1),
                .access(W1C),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            TX_FIFO_EMPTY.configure(
                this,
                .size(1),
                .lsb_pos(2),
                .access(W1C),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            TX_FIFO_FULL.configure(
                this,
                .size(1),
                .lsb_pos(3),
                .access(W1C),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            MAX_DROP.configure(
                this,
                .size(1),
                .lsb_pos(4),
                .access(W1C),
                .volatile(0),
                .reset(1'b0),
                .has_reset(1),
                .is_rand(1),
                .individually_accessible(0)
            );

            // <<UVM_CONFIGURE_BLOCKS>>

        endfunction
    endclass

`endif
