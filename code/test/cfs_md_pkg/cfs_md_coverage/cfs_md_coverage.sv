`ifndef CFS_MD_COVERAGE_SV

    `define CFS_MD_COVERAGE_SV

    // ----------------------------------- INDEX WRAPPER BASE ----------------------------------- 
    virtual class cfs_md_cover_index_wrapper_base extends uvm_component;

         function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        pure virtual function void sample(int unsigned value);

        pure virtual function string coverage2string();
    endclass


    // ----------------------------------- INDEX WRAPPER -----------------------------------
    class cfs_md_cover_index_wrapper #(int unsigned MAX_VALUE_PLUS_1 = 16) extends cfs_md_cover_index_wrapper_base;
        
        // Γιατί έχει παράμετρο
        `uvm_component_param_utils(cfs_md_cover_index_wrapper#(MAX_VALUE_PLUS_1))

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

        virtual function void sample(int unsigned value);
            cover_index.sample(value);
        endfunction

        virtual function string coverage2string();
            string result = {
                $sformatf("\n cover_item            %03.2f%%", cover_index.get_inst_coverage()),
                $sformatf("\n   -index              %03.2f%%", cover_index.index.get_inst_coverage())
            };

            return result;
        endfunction

    endclass

    // ----------------------------------- PORT CLASS DECLERATION -----------------------------------
    `uvm_analysis_imp_decl(_item)


    // ----------------------------------- COVERAGE CLASS -----------------------------------
    class cfs_md_coverage#(int unsigned DATA_WIDTH = 32) 
        extends uvm_component
        implements cfs_md_reset_handler;

        typedef virtual cfs_md_if#(DATA_WIDTH) cfs_md_vif;

        cfs_md_agent_config #(DATA_WIDTH) agent_config;

        uvm_analysis_imp_item#(cfs_md_item_mon, cfs_md_coverage#(DATA_WIDTH)) port_item;

        cfs_md_cover_index_wrapper #(DATA_WIDTH) wrap_cover_data_0;
        cfs_md_cover_index_wrapper #(DATA_WIDTH) wrap_cover_data_1;

        `uvm_component_param_utils(cfs_md_coverage#(DATA_WIDTH))


        covergroup cover_reset with function sample(bit valid);
            option.per_instance = 1;

            transfer_ongoing: coverpoint valid {
                option.comment = "An MD transfer was ongoing during reset";
            }
        endgroup


        covergroup cover_item with function sample(cfs_md_item_mon item);

            option.per_instance = 1;

            offset: coverpoint item.offset {
                option.comment = "Offset of MD item transfer";

                bins values[] = {[0: (DATA_WIDTH / 8) - 1]};
            }

            size: coverpoint item.data.size() {
                option.comment = "Size of MD item transfer";

                bins values[] = {[1: (DATA_WIDTH / 8)]};
            }

            response: coverpoint item.response {
                option.comment = "Response of MD item transfer";
            }

            length : coverpoint item.length {
                option.comment = "Length of MD access";

                bins length_eq_1 = {1};
                bins length_le_10[8] = {[2: 10]}; // Το χωρίζουμε σε 8 bins
                bins length_gt_10 = {[11:$]};

                illegal_bins length_lt_1 = {0};
            }

            prev_item_delay: coverpoint item.prev_item_delay {
                option.comment = "Delays in clock cycles between two MD transfers";

                bins back2back      = {0};
                bins delay_le_5[5]  = {[1:5]};
                bins delay_gt_5     = {[6:$]};
            }

            size_x_offset: cross offset, size {
                ignore_bins ignore_offset_plus_size_gt_data_width = size_x_offset 
                    with (offset + size > (DATA_WIDTH / 8));
            }

        endgroup

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            cover_item = new();

            cover_item.set_inst_name(
                $sformatf(
                    "%s_%s", get_full_name(), "cover_item")
            );

            cover_reset = new();

            cover_reset.set_inst_name(
                $sformatf(
                    "%s_%s", get_full_name(), "cover_reset"
                )
            );

            port_item = new("port_item", this);

        endfunction 

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            wrap_cover_data_0 = cfs_md_cover_index_wrapper#(DATA_WIDTH)::type_id::create(
                "wrap_cover_data_0", this
            );
            wrap_cover_data_1 = cfs_md_cover_index_wrapper#(DATA_WIDTH)::type_id::create(
                "wrap_cover_data_1", this
            );

        endfunction

        virtual function void handle_reset(uvm_phase phase);
            cfs_md_vif vif = agent_config.get_vif();

            cover_reset.sample(vif.valid);

        endfunction


        virtual function void write_item(cfs_md_item_mon item);
            cover_item.sample(item);

            foreach(item.data[byte_index]) begin
                for(int bit_index = 0; bit_index < 8; bit_index++) begin
                    int unsigned idx = (item.offset * 8) + (byte_index*8) + bit_index;

                    if (item.data[byte_index][bit_index] == 0) begin
                        wrap_cover_data_0.sample(idx);
                    end else begin
                        wrap_cover_data_1.sample(idx);
                    end
                end
            end

        endfunction


        virtual function string coverage2string();
            string result = {
                $sformatf("\n cover_item                    %03.2f%%", cover_item.get_inst_coverage()),
                $sformatf("\n   -offset                     %03.2f%%", cover_item.offset.get_inst_coverage()),
                $sformatf("\n   -size                       %03.2f%%", cover_item.size.get_inst_coverage()),
                $sformatf("\n   -length                     %03.2f%%", cover_item.length.get_inst_coverage()),
                $sformatf("\n   -prev_item_delay            %03.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
                $sformatf("\n   -offset_x_size              %03.2f%%", cover_item.size_x_offset.get_inst_coverage()),
                $sformatf("\n   -response                   %03.2f%%", cover_item.response.get_inst_coverage()),
                
                $sformatf("\n\n cover_reset                 %03.2f%%", cover_reset.get_inst_coverage()),
                $sformatf("\n   -access_ongoing             %03.2f%%", cover_reset.transfer_ongoing.get_inst_coverage())
            };

            // Μπορούμε δυναμικά να παίρνουμε όλα τα στοιχεία που είναι του base.
            uvm_component children[$];

            get_children(children);

            foreach (children[idx]) begin
                cfs_md_cover_index_wrapper_base wrapper;

                if ($cast(wrapper, children[idx])) begin
                    result = $sformatf("%0s\n\nChild Component: %0s%0s", result, wrapper.get_name(), wrapper.coverage2string());
                end
            end

            return result;
        endfunction

        virtual function void report_phase(uvm_phase phase);
            super.report_phase(phase);

            // IMPORTANT: Μόνο για το  EDA Playground
            `uvm_info("DEBUG", $sformatf("Coverage: %s", coverage2string()), UVM_NONE)

        endfunction

    endclass 

`endif