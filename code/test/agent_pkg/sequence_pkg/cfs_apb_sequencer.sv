`ifndef CFS_APB_SEQUENCER_SV

    `define CFS_APB_SEQUENCER_SV

    class cfs_apb_sequencer extends uvm_sequencer#(.REQ(cfs_apb_item_drv)) implements cfs_apb_reset_handler;


        `uvm_component_utils(cfs_apb_sequencer)


        function new(string name = "", uvm_component parent);

            super.new(name, parent);

        endfunction

        virtual function void handle_reset(uvm_phase phase);
            int objections_count;

            stop_sequences();

            objections_count = uvm_test_done.get_objection_count(this);

            if (objections_count > 0) begin
                uvm_test_done.drop_objection(
                    this, 
                    $sformatf("Dropping %0d objections at reset", objections_count), objections_count);
            end

            start_phase_sequence(phase);
        endfunction

    endclass

`endif