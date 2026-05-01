`ifndef UVM_EXT_AGENT_CONFIG_SV

    `define UVM_EXT_AGENT_CONFIG_SV

    class uvm_ext_agent_config#(type VIRTUAL_INTF = int) 
        extends uvm_component;

        protected VIRTUAL_INTF vif;

        protected uvm_active_passive_enum active_passive;

        protected bit has_checks;

        protected bit has_coverage;

        `uvm_component_param_utils(uvm_ext_agent_config#(VIRTUAL_INTF))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
            active_passive          = UVM_ACTIVE;
            has_coverage            = 1;
            has_checks              = 1;
        endfunction

        // =================================== GETTERS - SETTERS ===================================
        virtual function void set_active_passive(uvm_active_passive_enum value);
            this.active_passive = value;
        endfunction

        virtual function uvm_active_passive_enum get_active_passive();
            return this.active_passive;
        endfunction


        virtual function void set_has_checks(bit value);
            this.has_checks = value;

            if (vif != null) begin 
                vif.has_checks = value;
            end
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


        virtual function void set_vif(VIRTUAL_INTF value);
            if (this.vif == null) begin
                this.vif = value;
                return;
            end

            `uvm_fatal("ALGORITHM_ISSUE", "Trying to set MD virtual interface more than once")

        endfunction

        virtual function VIRTUAL_INTF get_vif();
            return this.vif;
        endfunction

        // =================================== Reset Logic ===================================
        virtual task wait_reset_start();
            `uvm_fatal(
                "ALGORITHM_ISSUE", 
                $sformatf(
                    "wait_reset_start() should be implemented here: %s", 
                    get_full_name()
                )
            );
        endtask

        virtual task wait_reset_end();
            `uvm_fatal(
                "ALGORITHM_ISSUE", 
                $sformatf(
                    "wait_reset_end() should be implemented here: %s", 
                    get_full_name()
                )
            );
        endtask

        virtual function void start_of_simulation_phase(uvm_phase phase);
			super.start_of_simulation_phase(phase);

			if(get_vif() == null) begin
				`uvm_fatal("ALGORITHM_ISSUE", "The APB virtual interface is not configured at \"Start of simulation\" phase")
			end
			else begin
				`uvm_info("UVM_EXT_CONFIG", "The virtual interface is configured at \"Start of simulation\" phase", UVM_DEBUG)
			end
		endfunction

    endclass

`endif