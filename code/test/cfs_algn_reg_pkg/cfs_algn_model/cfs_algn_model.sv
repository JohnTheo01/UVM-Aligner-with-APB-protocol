`ifndef CFS_ALGN_MODEL_SV

    `define CFS_ALGN_MODEL_SV

    class cfs_algn_model 
        extends uvm_component
        implements uvm_ext_reset_handler;

        `uvm_component_utils(cfs_algn_model)

        // Register Model
        cfs_algn_reg_block reg_block;

        cfs_algn_env_config env_config;

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            if (reg_block == null) begin
                reg_block = cfs_algn_reg_block::type_id::create("reg_block", this);

                reg_block.build();
                reg_block.lock_model();
            end
        endfunction

        virtual function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);

            reg_block.CTRL.set_algn_data_width(env_config.get_algn_data_width());
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            reg_block.reset("HARD");
        endfunction

    endclass

`endif