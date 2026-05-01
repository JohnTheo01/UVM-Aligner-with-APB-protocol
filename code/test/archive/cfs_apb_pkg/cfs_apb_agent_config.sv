`ifndef CFS_APB_AGENT_CONFIG_SV

	`define CFS_APB_AGENT_CONFIG_SV

	class cfs_apb_agent_config extends uvm_component;
      
      	local cfs_apb_vif vif;
      	
        // Ελέγχει εάν είναι active η passive ο agent
        local uvm_active_passive_enum active_passive;

        local int unsigned stuck_threshold;

        local bit has_checks;

        local int sample_delay_transaction_start;

        // Switch για coverage
        local bit has_coverage;

     	`uvm_component_utils(cfs_apb_agent_config)
      
        function new(string name = "", uvm_component parent);
            super.new(name, parent);
            
            // Από προεπιλογή active
            this.active_passive = UVM_ACTIVE;

            this.has_checks                     = 1;
            this.has_coverage                   = 1;
            this.stuck_threshold                = 1000;
            this.sample_delay_transaction_start = 1ns;
        endfunction

        virtual function cfs_apb_vif get_vif();
            return vif;
        endfunction

        virtual function void set_vif(cfs_apb_vif value);
            // Εξασφαλίζουμε ότι το VIF ορίζεται μόνο μία φορά
            if (vif == null) begin
                vif = value;
                
                set_has_checks(get_has_checks());   
            end
            else begin 
                `uvm_fatal("ALGORITHM_ISSUE", "Trying to set VIF twice")
            end
        endfunction

        virtual function void start_of_simulation_phase(uvm_phase phase);
            super.start_of_simulation_phase(phase);
            
            if (get_vif() == null) begin
                `uvm_fatal("ALGORITHM_ISSUE", "VIF not set for APB agent config")
            end 
            else begin
                `uvm_info(
                    "APB_CONFIG", "VIF successfully set for APB agent config at \"start_of_simulation\" phase", UVM_LOW)
            end

        endfunction

        virtual task run_phase(uvm_phase phase);
            forever begin
                @(vif.has_checks);
                
                if (vif.has_checks !== this.has_checks) begin
                    `uvm_error("ALGORITHM ISSUE", $sformatf("Cannot change /has_checks/ from APB interface directly. Use %s.set_has_checks()", get_full_name()))
                end
            end
        endtask


        virtual function bit get_has_coverage();
            return this.has_coverage;
        endfunction

        virtual function void set_has_coverage(bit value);
            this.has_coverage = value;
        endfunction

        
        virtual function int unsigned get_stuck_threshold();
            return this.stuck_threshold;
        endfunction

        virtual function void set_stuck_threshold(int unsigned value);
            this.stuck_threshold = value;
        endfunction


        virtual function uvm_active_passive_enum get_active_passive();
            return this.active_passive;
        endfunction

        virtual function void set_active_passive(uvm_active_passive_enum value);
            this.active_passive = value;
        endfunction


        virtual function bit get_has_checks();
            return this.has_checks;
        endfunction

        virtual function void set_has_checks(bit value);
            this.has_checks = value;

            // Ελέγχουμε ότι έχουμε ορίσει πρώτα το vif
            if (this.vif != null) begin
                this.vif.has_checks = this.has_checks;
            end
        endfunction

        virtual task wait_reset_start();
            if (vif.preset_n !== 0) begin
                @(negedge vif.preset_n);
            end
        endtask

        virtual task wait_reset_end();
            while (vif.preset_n === 0) begin
                @(posedge vif.pclk);
            end
        endtask

    endclass

`endif