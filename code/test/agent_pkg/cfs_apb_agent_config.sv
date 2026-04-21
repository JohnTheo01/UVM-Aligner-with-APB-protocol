`ifndef CFS_APB_AGENT_CONFIG_SV

	`define CFS_APB_AGENT_CONFIG_SV

	class cfs_apb_agent_config extends uvm_component;
      
      	local cfs_apb_vif vif;
      	
        // Ελέγχει εάν είναι active η passive ο agent
        local uvm_active_passive_enum active_passive;

     	`uvm_component_utils(cfs_apb_agent_config)
      
        function new(string name = "", uvm_component parent);
          super.new(name, parent);
          
          // Από προεπιλογή active
          this.active_passive = UVM_ACTIVE;
        endfunction

        virtual function cfs_apb_vif get_vif();
            return vif;
        endfunction

        virtual function void set_vif(cfs_apb_vif value);
            // Εξασφαλίζουμε ότι το VIF ορίζεται μόνο μία φορά
            if (vif == null) begin
                vif = value;                
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

        // Getter
        virtual function uvm_active_passive_enum get_active_passive();
            return this.active_passive;
        endfunction

        // Setter
        virtual function void set_active_passive(uvm_active_passive_enum value);
            this.active_passive = value;
        endfunction
    endclass

`endif