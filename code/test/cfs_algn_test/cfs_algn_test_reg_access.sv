`ifndef CFS_ALGN_TEST_REG_ACCESS_SV

    `define CFS_ALGN_TEST_REG_ACCESS_SV

    `include "uvm_macros.svh"

    class cfs_algn_test_reg_access extends cfs_algn_test_base;

        `uvm_component_utils(cfs_algn_test_reg_access)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual task run_phase(uvm_phase phase);
    
            uvm_status_e status;
            uvm_reg_data_t data;

            phase.raise_objection(this, "TEST_DONE");

            `uvm_info("DEBUG", "start of test", UVM_LOW)

        
            #(100ns);

             fork
                begin
                    cfs_md_sequence_slave_response_forever seq_response_forever = cfs_md_sequence_slave_response_forever::type_id::create(
                        "seq_response_forever"
                    );
                    
                    seq_response_forever.start(env.md_tx_agent.sequencer);
                end
            join_none


            begin
                cfs_algn_seq_reg_config seq = cfs_algn_seq_reg_config::type_id::create("seq");

                seq.reg_block = env.model.reg_block;

                seq.start(env.model.reg_block.default_map.get_sequencer());


            end

            repeat(2) begin 
                cfs_md_sequence_simple_master seq_simple = cfs_md_sequence_simple_master::type_id::create("seq_simple");

                seq_simple.set_sequencer(env.md_rx_agent.sequencer);
                
                void'(seq_simple.randomize() with {
                   item.data.size() == 4;
                   item.offset      == 0;
                });

                seq_simple.start(env.md_rx_agent.sequencer);
            end

            #(100ns);

            `uvm_info("DEBUG", "end of test", UVM_LOW)

            phase.drop_objection(this, "TEST_DONE");

        endtask

    endclass

`endif