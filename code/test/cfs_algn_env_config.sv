`ifndef CFS_ALGN_ENV_CONFIG_SV

    `define CFS_ALGN_ENV_CONFIG_SV

    class cfs_algn_env_config
        extends uvm_component;

        local bit has_checks;

        local int unsigned algn_data_width;

        `uvm_component_utils(cfs_algn_env_config)

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            has_checks = 1;
            algn_data_width = 8;
        endfunction


        virtual function bit get_has_checks();
            return this.has_checks;
        endfunction

        virtual function void set_has_checks(bit value);
            this.has_checks = value;
        endfunction

        virtual function int unsigned get_algn_data_width();
            return this.algn_data_width;
        endfunction

        virtual function void set_algn_data_width(int unsigned value);
            if ((value < 8) || ($countones(value) != 1)) begin
                `uvm_fatal("ALGORITHM_ISSUE", "You need to specify correct values for \"algn_data_width\"")
            end 
            
            this.algn_data_width = value;
        endfunction


    endclass

`endif 