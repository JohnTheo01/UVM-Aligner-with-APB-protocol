`ifndef UVM_EXT_PKG_SV

    `define UVM_EXT_PKG_SV

    `include "uvm_macros.svh"

    package uvm_ext_pkg;
        import uvm_pkg::*;

        // =========================================================================
        // uvm_ext_reset_handler.sv
        // =========================================================================
        interface class uvm_ext_reset_handler;

            //Function to handle the reset
            pure virtual function void handle_reset(uvm_phase phase);

        endclass

        // =========================================================================
        // uvm_ext_agent_config.sv
        // =========================================================================
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

        // =========================================================================
        // uvm_ext_monitor.sv
        // =========================================================================
        class uvm_ext_monitor#(type VIRTUAL_INTF = int, type ITEM_MON = uvm_sequence_item)
            extends uvm_monitor
            implements uvm_ext_reset_handler;

            uvm_ext_agent_config #(VIRTUAL_INTF) agent_config;

            //Port for sending the collected item
            uvm_analysis_port#(ITEM_MON) output_port;

            //Process for collect_transactions() task
            protected process process_collect_transactions;


            `uvm_component_param_utils(uvm_ext_monitor#(VIRTUAL_INTF, ITEM_MON))

            function new(string name = "", uvm_component parent);
                super.new(name, parent);

                output_port = new("output_port", this);
            endfunction

             //Task for collecting all transactions
            protected virtual task collect_transactions();
                fork
                    begin
                        process_collect_transactions = process::self();

                        forever begin
                            collect_transaction();
                        end

                    end
                join
            endtask

            //Task for waiting the reset to be finished
            protected virtual task wait_reset_end();
                agent_config.wait_reset_end();
            endtask

            //Function to handle the reset
            virtual function void handle_reset(uvm_phase phase);
                if(process_collect_transactions != null) begin
                    process_collect_transactions.kill();

                    process_collect_transactions = null;
                end
            endfunction

            virtual task run_phase(uvm_phase phase);
                forever begin
                    fork
                        begin
                        wait_reset_end();
                        collect_transactions();

                        disable fork;
                        end
                    join
                end
            endtask

            protected virtual task collect_transaction();
                `uvm_fatal("ALGORITHM_ISSUE", "You must implement collect_transaction");
            endtask

        endclass

        // =========================================================================
        // uvm_ext_coverage.sv
        // =========================================================================
        `uvm_analysis_imp_decl(_item)

        virtual class uvm_ext_cover_index_wrapper_base extends uvm_component;

            function new(string name = "", uvm_component parent);
                super.new(name, parent);
            endfunction

            //Function used to sample the information
            pure virtual function void sample(int unsigned value);

            //Function to print the coverage information.
            //This is only to be able to visualize some basic coverage information
            //in EDA Playground.
            //DON'T DO THIS IN A REAL PROJECT!!!
            pure virtual function string coverage2string();

        endclass

        //Wrapper over the covergroup which covers indices.
        //The MAX_VALUE parameter is used to determine the maximum value to sample
        class uvm_ext_cover_index_wrapper#(int unsigned MAX_VALUE_PLUS_1 = 16) extends uvm_ext_cover_index_wrapper_base;

            `uvm_component_param_utils(uvm_ext_cover_index_wrapper#(MAX_VALUE_PLUS_1))

            covergroup cover_index with function sample(int unsigned value);
                option.per_instance = 1;

                index : coverpoint value {
                option.comment = "Index";
                bins values[MAX_VALUE_PLUS_1] = {[0:MAX_VALUE_PLUS_1-1]};
                }

            endgroup

            function new(string name = "", uvm_component parent);
                super.new(name, parent);

                cover_index = new();
                cover_index.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_index"));
            endfunction

            //Function to print the coverage information.
            //This is only to be able to visualize some basic coverage information
            //in EDA Playground.
            //DON'T DO THIS IN A REAL PROJECT!!!
            virtual function string coverage2string();
                return {
                $sformatf("\n   cover_index:              %03.2f%%", cover_index.get_inst_coverage()),
                $sformatf("\n      index:                 %03.2f%%", cover_index.index.get_inst_coverage())
                };
            endfunction

            //Function used to sample the information
            virtual function void sample(int unsigned value);
                cover_index.sample(value);
            endfunction

        endclass


        class uvm_ext_coverage#(type VIRTUAL_INTF = int, ITEM_MON = uvm_sequence_item)
            extends uvm_component
            implements uvm_ext_reset_handler;


            //Pointer to agent configuration
            uvm_ext_agent_config#(VIRTUAL_INTF) agent_config;

            //Port for receiving the collected item
            uvm_analysis_imp_item#(ITEM_MON, uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON)) port_item;

            `uvm_component_param_utils(uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON))

            function new(string name = "", uvm_component parent);
                super.new(name, parent);

                port_item = new("port_item", this);
            endfunction

            //Port associated with port_item port
            virtual function void write_item(ITEM_MON item);
                `uvm_fatal("ALGORITHM_ISSUE", "You must implement write_item");
            endfunction

            //Function to handle the reset
            virtual function void handle_reset(uvm_phase phase);
                `uvm_fatal("ALGORITHM_ISSUE", "You must implement handle_reset");
            endfunction

            //Function to print the coverage information.
            //This is only to be able to visualize some basic coverage information
            //in EDA Playground.
            //DON'T DO THIS IN A REAL PROJECT!!!
            virtual function string coverage2string();
                string result;
                uvm_component children[$];
                uvm_ext_cover_index_wrapper_base wrapper;

                result = "";

                get_children(children);
                foreach(children[idx]) begin
                    if($cast(wrapper, children[idx])) begin
                        result = $sformatf("%s\n\nChild component: %0s%0s", result, wrapper.get_name(), wrapper.coverage2string());
                    end
                end

                return result;
            endfunction

            virtual function void report_phase(uvm_phase phase);
                super.report_phase(phase);

                //IMPORTANT: DON'T DO THIS IN A REAL PROJECT!!!
                `uvm_info("DEBUG", $sformatf("Coverage: %0s", coverage2string()), UVM_NONE)
            endfunction

        endclass

        // =========================================================================
        // uvm_ext_sequencer.sv
        // =========================================================================
        class uvm_ext_sequencer #(type ITEM_DRV = uvm_sequence_item)
            extends uvm_sequencer#(.REQ(ITEM_DRV))
            implements uvm_ext_reset_handler;

            `uvm_component_param_utils(uvm_ext_sequencer#(ITEM_DRV))

            function new(string name = "", uvm_component parent);
                super.new(name, parent);
            endfunction

            virtual function void handle_reset(uvm_phase phase);
                int objections_count;
                stop_sequences();

                objections_count = uvm_test_done.get_objection_count(this);

                if(objections_count > 0) begin
                uvm_test_done.drop_objection(this, $sformatf("Dropping %0d objections at reset", objections_count), objections_count);
                end

                start_phase_sequence(phase);
            endfunction

        endclass

        // =========================================================================
        // uvm_ext_driver.sv
        // =========================================================================
        class uvm_ext_driver # (type VIRTUAL_INTF = int, type ITEM_DRV = uvm_sequence_item)
            extends uvm_driver#(.REQ(ITEM_DRV))
            implements uvm_ext_reset_handler;

            uvm_ext_agent_config #(VIRTUAL_INTF) agent_config;

            //process for drive_transactions() task
            protected process process_drive_transactions;

            `uvm_component_param_utils(uvm_ext_driver#(VIRTUAL_INTF, ITEM_DRV))

            function new(string name = "", uvm_component parent);
                super.new(name, parent);
            endfunction

            virtual task run_phase(uvm_phase phase);
                forever begin
                    fork
                        begin
                        wait_reset_end();
                        drive_transactions();

                        disable fork;
                        end
                    join
                end
            endtask


             //Task for driving all transactions
            protected virtual task drive_transactions();
                fork
                    begin
                        process_drive_transactions = process::self();

                        forever begin
                            ITEM_DRV item;

                            seq_item_port.get_next_item(item);

                            drive_transaction(item);

                            seq_item_port.item_done();
                        end
                    end
                join
            endtask

            //Task for waiting the reset to be finished
            protected virtual task wait_reset_end();
                agent_config.wait_reset_end();
            endtask

            //Function to handle the reset
            virtual function void handle_reset(uvm_phase phase);

                if(process_drive_transactions != null) begin
                    process_drive_transactions.kill();

                    process_drive_transactions = null;
                end

            endfunction


            protected virtual task drive_transaction(ITEM_DRV item);
                `uvm_fatal("ALGORITHM_ISSUE", "You must implement drive_transaction")
            endtask


            virtual function void end_of_elaboration_phase(uvm_phase phase);
                super.end_of_elaboration_phase(phase);

                if ($typename(VIRTUAL_INTF) == "int") begin
                    `uvm_fatal("ALGORITHM_ISSUE", "You must pass the virtual interface type when extending the class")
                end
            endfunction

        endclass

        // =========================================================================
        // uvm_ext_agent.sv
        // =========================================================================
        class uvm_ext_agent#(type VIRTUAL_INTF = int, type ITEM_DRV = uvm_sequence_item, ITEM_MON = uvm_sequence_item)
            extends uvm_agent
            implements uvm_ext_reset_handler;

            uvm_ext_agent_config#(VIRTUAL_INTF) agent_config;

            //Driver handler
            uvm_ext_driver#(VIRTUAL_INTF, ITEM_DRV) driver;

            //Sequencer handler
            uvm_ext_sequencer#(ITEM_DRV) sequencer;

            //Monitor handler
            uvm_ext_monitor#(VIRTUAL_INTF, ITEM_MON) monitor;

            //Coverage handler
            uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON) coverage;

            `uvm_component_param_utils(uvm_ext_agent#(VIRTUAL_INTF, ITEM_DRV, ITEM_MON))

            function new(string name = "", uvm_component parent);
                super.new(name, parent);
            endfunction

            // ----------------------------------- BUILD PHASE -----------------------------------
            virtual function void build_phase(uvm_phase phase);
                super.build_phase(phase);

                if (!uvm_config_db#(uvm_ext_agent_config#(VIRTUAL_INTF))::get(this, "", "agent_config", agent_config)) begin
                    agent_config = uvm_ext_agent_config#(VIRTUAL_INTF)::type_id::create("agent_config", this);
                end

                monitor = uvm_ext_monitor#(VIRTUAL_INTF, ITEM_MON)::type_id::create("monitor", this);

                if(agent_config.get_has_coverage()) begin
                    coverage = uvm_ext_coverage#(VIRTUAL_INTF, ITEM_MON)::type_id::create("coverage", this);
                end

                if(agent_config.get_active_passive() == UVM_ACTIVE) begin
                    driver    = uvm_ext_driver#(VIRTUAL_INTF, ITEM_DRV)::type_id::create("driver", this);
                    sequencer = uvm_ext_sequencer#(ITEM_DRV)::type_id::create("sequencer", this);
                end
            endfunction


            virtual function void connect_phase(uvm_phase phase);
                VIRTUAL_INTF vif;
                string      vif_name = "vif";

                super.connect_phase(phase);

                if(!uvm_config_db#(VIRTUAL_INTF)::get(this, "", vif_name, vif)) begin
                    `uvm_fatal("UVM_EXT_NO_VIF", $sformatf("Could not get from the database the virtual interface using name \"%0s\"", vif_name))
                end
                else begin
                    agent_config.set_vif(vif);
                end

                monitor.agent_config = agent_config;

                if(agent_config.get_has_coverage()) begin
                    coverage.agent_config = agent_config;
                    monitor.output_port.connect(coverage.port_item);
                end

                if(agent_config.get_active_passive() == UVM_ACTIVE) begin
                    driver.seq_item_port.connect(sequencer.seq_item_export);
                    driver.agent_config = agent_config;
                end
            endfunction


            // ----------------------------------- RESET LOGIC -----------------------------------
            protected virtual task wait_reset_start();
                agent_config.wait_reset_start();
            endtask

            protected virtual task wait_reset_end();
                agent_config.wait_reset_end();
            endtask

            virtual function void handle_reset(uvm_phase phase);
                uvm_component children[$];

                get_children(children);

                foreach(children[idx]) begin
                    uvm_ext_reset_handler reset_handler;

                    if($cast(reset_handler, children[idx])) begin
                        reset_handler.handle_reset(phase);
                    end
                end
            endfunction


            // ----------------------------------- RUN PHASE -----------------------------------
            virtual task run_phase(uvm_phase phase);
                forever begin
                    wait_reset_start();
                    handle_reset(phase);
                    wait_reset_end();
                end
            endtask

        endclass

    endpackage

`endif
