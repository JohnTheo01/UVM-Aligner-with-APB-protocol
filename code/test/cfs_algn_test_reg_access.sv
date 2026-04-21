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

            begin 
                cfs_apb_sequence_simple seq_simple = cfs_apb_sequence_simple::type_id::create("seq_simple");

                void'(seq_simple.randomize() with {
                    item.addr == 'h222;
                });

                seq_simple.start(env.apb_agent.sequencer);
            end

            begin 
                cfs_apb_sequence_rw seq_rw = cfs_apb_sequence_rw::type_id::create("seq_rw");

                // Προσοχή εδώ ορίζουμε την address του sequence και όχι του item
                void'(seq_rw.randomize() with {
                    addr == 'h4;

                });

                seq_rw.start(env.apb_agent.sequencer);
            end
            
            begin 
                cfs_apb_sequence_random seq_random = cfs_apb_sequence_random::type_id::create("seq_random");

                void'(seq_random.randomize() with {
                    num_items == 3;
                });

                seq_random.start(env.apb_agent.sequencer);
            end

            `uvm_info("DEBUG", "end of test", UVM_LOW)

            phase.drop_objection(this, "TEST_DONE");

        endtask

    endclass

`endif