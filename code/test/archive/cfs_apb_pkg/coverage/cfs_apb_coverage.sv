`ifndef CFS_APB_COVERAGE_SV

    `define CFS_APB_COVERAGE_SV


    // Αυτή η κλάση επιτρέπει να ομαδοποιήσουμε όλα τα wrappers μαζί.
    // Ο λόγος που χρειάζεται είναι γιατί κλάσεις με διαφορετικά parameters αντιμετωπίζονται διαφορετικά.
    virtual class cfs_apb_cover_index_wrapper_base extends uvm_component;

         function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        pure virtual function void sample(int unsigned value);

        pure virtual function string coverage2string();
    endclass

    class cfs_apb_cover_index_wrapper #(int unsigned MAX_VALUE_PLUS_1 = 16) extends cfs_apb_cover_index_wrapper_base;
        
        // Γιατί έχει παράμετρο
        `uvm_component_param_utils(cfs_apb_cover_index_wrapper#(MAX_VALUE_PLUS_1))

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

    // Ορίζει την κλάση για το analysis port.
    `uvm_analysis_imp_decl(_item)

    class cfs_apb_coverage extends uvm_component implements cfs_apb_reset_handler;

        `uvm_component_utils(cfs_apb_coverage)

        cfs_apb_agent_config agent_config;
        
        // Port instance declaration
        uvm_analysis_imp_item#(cfs_apb_item_mon, cfs_apb_coverage) port_item;

        // Wraper instances 2 for address and 4 for data
        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH) wrap_cover_addr_1;
        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH) wrap_cover_addr_0; 

        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_wr_data_0;
        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_wr_data_1;

        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_rd_data_0;
        cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH) wrap_cover_rd_data_1;

        covergroup cover_reset with function sample(bit psel);
            option.per_instance = 1;

            access_ongoing: coverpoint psel {
                option.comment = "An APB transfer was ongoing during reset";
            }
        endgroup

        covergroup cover_item with function sample(cfs_apb_item_mon item);
            
            // Θέλουμε να συλλέγουμε coverage για κάθε instance.
            option.per_instance = 1;

            direction : coverpoint item.dir {
                option.comment = "Direction of APB access";
            }

            response : coverpoint item.response {
                option.comment = "Response of APB access";
            }

            length : coverpoint item.length {
                option.comment = "Length of APB access";

                bins length_eq_2 = {2};
                bins length_le_10[8] = {[3: 10]}; // Το χωρίζουμε σε 8 bins
                bins length_gt_10 = {[11:$]};
            }

            prev_item_delay : coverpoint item.prev_item_delay {
                option.comment = "Delay in clock cycles between two consequtive accesses";

                bins back2back      = {0};
                bins delay_le_5[5]  = {[1:5]};
                bins delay_gt_5     = {[6:$]};
            }

            response_x_direction: cross response, direction;

            trans_direction: coverpoint item.dir {
                option.comment = "Transitions of APB transfer";

                bins direaction_trans[] = (CFS_APB_READ, CFS_APB_WRITE => CFS_APB_READ, CFS_APB_WRITE);

            }

        endgroup

        function new(string name = "", uvm_component parent);
            super.new(name, parent);

            cover_item = new();
            // Το όνομα χρησιμοποιείται για να γίνει map με το verification plan
            cover_item.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_item"));

            cover_reset = new();
            cover_reset.set_inst_name($sformatf("%s_%s", get_full_name(), "cover_reset"));

            port_item = new("port_item", this);
        endfunction

        virtual function string coverage2string();
            string result = {
                $sformatf("\n cover_item                    %03.2f%%", cover_item.get_inst_coverage()),
                $sformatf("\n   -direction                  %03.2f%%", cover_item.direction.get_inst_coverage()),
                $sformatf("\n   -response                   %03.2f%%", cover_item.response.get_inst_coverage()),
                $sformatf("\n   -length                     %03.2f%%", cover_item.length.get_inst_coverage()),
                $sformatf("\n   -prev_item_delay            %03.2f%%", cover_item.prev_item_delay.get_inst_coverage()),
                $sformatf("\n   -response_x_direction       %03.2f%%", cover_item.response_x_direction.get_inst_coverage()),
                $sformatf("\n   -trans_direction            %03.2f%%", cover_item.trans_direction.get_inst_coverage()),
                
                $sformatf("\n\n cover_reset                 %03.2f%%", cover_reset.get_inst_coverage()),
                $sformatf("\n   -access_ongoing             %03.2f%%", cover_reset.access_ongoing.get_inst_coverage())
            };

            // Μπορούμε δυναμικά να παίρνουμε όλα τα στοιχεία που είναι του base.
            uvm_component children[$];

            get_children(children);

            foreach (children[idx]) begin
                cfs_apb_cover_index_wrapper_base wrapper;

                if ($cast(wrapper, children[idx])) begin
                    result = $sformatf("%0s\n\nChild Component: %0s%0s", result, wrapper.get_name(), wrapper.coverage2string());
                end
            end

            return result;
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);

            wrap_cover_addr_0      = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_0", this);
            wrap_cover_addr_1      = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_ADDR_WIDTH)::type_id::create("wrap_cover_addr_1", this);

            wrap_cover_wr_data_0    = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wr_data_0", this);
            wrap_cover_wr_data_1    = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_wr_data_1", this);

            wrap_cover_rd_data_0    = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rd_data_0", this);
            wrap_cover_rd_data_1    = cfs_apb_cover_index_wrapper#(`CFS_APB_MAX_DATA_WIDTH)::type_id::create("wrap_cover_rd_data_1", this);
            
        endfunction

        virtual function void handle_reset(uvm_phase phase);
            cfs_apb_vif vif = agent_config.get_vif();

            cover_reset.sample(vif.psel);
        endfunction


        // Fuction για το port_item port
        // Το όνομα είναι write + '_item' από το analysis port decleration
        virtual function void write_item(cfs_apb_item_mon item);
            cover_item.sample(item);

            // IMPORTANT: Μόνο για το  EDA Playground
            `uvm_info("DEBUG", $sformatf("Coverage: %s", coverage2string()), UVM_NONE)

            // Sample address bits
            for (int i = 0; i < `CFS_APB_MAX_ADDR_WIDTH; i++) begin
                if (item.addr[i] == 0) begin
                    wrap_cover_addr_0.sample(i);
                end else begin
                    wrap_cover_addr_1.sample(i);
                end
            end


            // Sample data bits
            for (int i = 0; i < `CFS_APB_MAX_DATA_WIDTH; i++) begin
                case(item.dir)
                    CFS_APB_READ: begin
                        if (item.data[i] == 0) begin
                            wrap_cover_rd_data_0.sample(i);
                        end else begin
                            wrap_cover_rd_data_1.sample(i);
                        end
                    end

                    CFS_APB_WRITE: begin
                        if (item.data[i] == 0) begin
                            wrap_cover_wr_data_0.sample(i);
                        end else begin
                            wrap_cover_wr_data_1.sample(i);
                        end
                    end

                    default: begin
                        `uvm_error("ALGORITHM_ISSUE", $sformatf("Current version of code does not support item.dir: %s", item.dir.name()))
                    end
                endcase
            end
        endfunction 

        

    endclass
`endif 