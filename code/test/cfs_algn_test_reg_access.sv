`ifndef CFS_ALGN_TEST_REG_ACCESS_SV

    `define CFS_ALGN_TEST_REG_ACCESS_SV

    `include "uvm_macros.svh"

    class cfs_algn_test_reg_access extends cfs_algn_test_base;

        `uvm_component_utils(cfs_algn_test_reg_access)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
    
            phase.raise_objection(this, "TEST_DONE");

            `uvm_info("DEBUG", "start of test", UVM_LOW)

        
            #(100ns);

            for (int i = 0; i < 10; i++) begin
               cfs_apb_item_drv item = cfs_apb_item_drv::type_id::create("item");

               void'(std::randomize(item));

               `uvm_info("DEBUG", $sformatf("Generated item: %s", item.convert2string()), UVM_LOW);
            end

            `uvm_info("DEBUG", "end of test", UVM_LOW)

            phase.drop_objection(this, "TEST_DONE");

        endtask

    endclass

`endif