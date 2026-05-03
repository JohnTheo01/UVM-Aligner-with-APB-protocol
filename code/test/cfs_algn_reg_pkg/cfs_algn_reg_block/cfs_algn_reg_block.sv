`ifndef CFS_ALGN_REG_BLOCK_SV

    `define CFS_ALGN_REG_BLOCK_SV

    class cfs_algn_reg_block extends uvm_reg_block;

        rand cfs_algn_reg_ctrl CTRL;

        rand cfs_algn_reg_status STATUS;

        rand cfs_algn_reg_irqen IRQEN;

        rand cfs_algn_reg_irq IRQ;

        `uvm_object_utils(cfs_algn_reg_block)

        function new(string name = "");
            super.new(name, UVM_NO_COVERAGE);
        endfunction

        virtual function void build();

            default_map = create_map(
                .name(              "apb_map"           ),
                .base_addr(         'h0000              ),
                .n_bytes(           4                   ),
                .endian(            UVM_LITTLE_ENDIAN   ),
                .byte_addressing(   1                   )
            );

            default_map.set_check_on_read(1);

            CTRL    = cfs_algn_reg_ctrl::type_id::create(   "CTRL",     null,   get_full_name());
            STATUS  = cfs_algn_reg_status::type_id::create( "STATUS",   null,   get_full_name());
            IRQEN   = cfs_algn_reg_irqen::type_id::create(  "IRQEN",    null,   get_full_name());
            IRQ     = cfs_algn_reg_irq::type_id::create(    "IRQ",      null,   get_full_name());  


            CTRL.configure(
                .blk_parent(this),
                .regfile_parent(null),
                .hdl_path("")
            );

            STATUS.configure(
                .blk_parent(this),
                .regfile_parent(null),
                .hdl_path("")
            );

            IRQEN.configure(
                .blk_parent(this),
                .regfile_parent(null),
                .hdl_path("")
            );
            
            IRQ.configure(
                .blk_parent(this),
                .regfile_parent(null),
                .hdl_path("")
            );

            CTRL.build();
            STATUS.build();
            IRQEN.build();
            IRQ.build();

            default_map.add_reg(
                .rg(CTRL),
                .offset('h0000),
                .rights("RW")
            );

            default_map.add_reg(
                .rg(STATUS),
                .offset('h000C),
                .rights("RO")
            );

            default_map.add_reg(
                .rg(IRQEN),
                .offset('h00F0),
                .rights("RW")
            );

            default_map.add_reg(
                .rg(IRQ),
                .offset('h00F4),
                .rights("RW")
            );

        endfunction

    endclass
`endif