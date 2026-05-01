`ifndef CFS_MD_AGENT_CONFIG_SV

    `define CFS_MD_AGENT_CONFIG_SV

    class cfs_md_agent_config#(int unsigned DATA_WIDTH = 32) extends uvm_component;

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        local cfs_md_vif vif;

        local uvm_active_passive_enum active_passive;

        local bit has_checks;

        local bit has_coverage;

        local time sample_delay_start_tr;

        local int unsigned stuck_threshold;

        `uvm_component_param_utils(cfs_md_agent_config#(DATA_WIDTH))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            active_passive          = UVM_ACTIVE;
            has_coverage            = 1;
            has_checks              = 1;
            sample_delay_start_tr   = 1ns;
            stuck_threshold         = 1000;
        endfunction

        // ----------------------------------- UVM Phases -----------------------------------
        
        virtual task run_phase(uvm_phase phase);
            forever begin 
                @(vif.has_checks);

                if (vif.has_checks !== get_has_checks()) begin 
                    `uvm_error("ALGORITHM_ISSUE", $sformatf("Cannot change the \"has_checks\" from APB interface directly - use %0s_set_has_checks()", get_full_name()))
                end
            end
        endtask

        // ----------------------------------- Setters - Getters -----------------------------------

        virtual function void set_sample_delay_start_tr(time value);
            this.sample_delay_start_tr = value;
        endfunction

        virtual function time get_sample_delay_start_tr();
            return this.sample_delay_start_tr;
        endfunction
        

        virtual function void set_active_passive(uvm_active_passive_enum value);
            this.active_passive = value;
        endfunction

        virtual function uvm_active_passive_enum get_active_passive();
            return this.active_passive;
        endfunction


        virtual function void set_has_checks(bit value);
            this.has_checks = value;
        endfunction

        virtual function bit unsigned get_has_checks();
            return this.has_checks;
        endfunction


        virtual function void set_has_coverage(bit value);
            this.has_coverage = value;
        endfunction

        virtual function bit unsigned get_has_coverage();
            return this.has_coverage;
        endfunction


        virtual function void set_vif(cfs_md_vif value);
            if (this.vif == null) begin
                this.vif = value;
                set_has_checks(get_has_checks());
                return;
            end

            `uvm_fatal("ALGORITHM_ISSUE", "Trying to set MD virtual interface more than once")

        endfunction

        virtual function cfs_md_vif get_vif();
            return this.vif;
        endfunction


        virtual function void set_stuck_threshold(int unsigned value);
            this.stuck_threshold = value;
        endfunction

        virtual function int unsigned get_stuck_threshold();
            return this.stuck_threshold;
        endfunction

        // ----------------------------------- Reset Logic -----------------------------------

        virtual task wait_reset_start();
            if(vif.reset_n == 1) begin
                @(negedge vif.reset_n);
            end
        endtask

        virtual task wait_reset_end();
            while(vif.reset_n == 0) begin
                @(posedge vif.clk);
            end
        endtask



    endclass

`endif