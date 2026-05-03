`ifndef CFS_ALGN_REG_PREDICTOR_SV

    `define CFS_ALGN_REG_PREDICTOR_SV

    class cfs_algn_reg_predictor#(type BUSTYPE = uvm_sequence_item) 
        extends uvm_reg_predictor#(BUSTYPE);
        
        cfs_algn_env_config env_config;

        `uvm_component_param_utils(cfs_algn_reg_predictor#(BUSTYPE))

        function new(string name = "", uvm_component parent);
            super.new(name, parent);
        endfunction

        protected virtual function uvm_reg_data_t get_reg_field_value(uvm_reg_field reg_field, uvm_reg_data_t reg_data);
            uvm_reg_data_t mask = (('h1 << reg_field.get_n_bits()) - 1) << reg_field.get_lsb_pos();

            return (mask & reg_data) >> reg_field.get_lsb_pos();
        endfunction

        protected virtual function cfs_algn_reg_access_status_info get_expected_response(uvm_reg_bus_op operation);

            uvm_reg register;

            // Κάθε πρόσβαση σε μνήμη που δεν υπάρχει register πρέπει να επιστρέφει error
            register = map.get_reg_by_offset(operation.addr, (operation.kind == UVM_READ));
            if (register == null) begin
                return cfs_algn_reg_access_status_info::new_instance(
                    .status(UVM_NOT_OK),
                    .info("Access to a register with no reg map address")
                );
            end

            // Κάθε εγγραφή σε read-only register
            if (operation.kind == UVM_WRITE) begin
                uvm_reg_map_info info = map.get_reg_map_info(register);
                if (info.rights == "RO") begin
                    
                    return cfs_algn_reg_access_status_info::new_instance(
                        .status(UVM_NOT_OK),
                        .info("Writing to a \"RO\" register")
                    );
                end
            end 

            // Κάθε ανάγνωση σε write_only register
            if (operation.kind == UVM_READ) begin
                uvm_reg_map_info info = map.get_reg_map_info(register);
                if (info.rights == "WO") begin
                    return cfs_algn_reg_access_status_info::new_instance(
                        .status(UVM_NOT_OK),
                        .info("Reading from a \"WO\" register")
                    );
                end
            end 

            if(operation.kind == UVM_WRITE) begin
                cfs_algn_reg_ctrl ctrl;
                if($cast(ctrl, register)) begin
                    
                    uvm_reg_data_t size_value = get_reg_field_value(ctrl.SIZE, operation.data);
                    uvm_reg_data_t offset_value = get_reg_field_value(ctrl.OFFSET, operation.data);

                    if (size_value == 0) begin
                        return cfs_algn_reg_access_status_info::new_instance(
                            .status(UVM_NOT_OK),
                            .info("Setting 0 value to \"size\"")
                        );
                    end

                    if ((env_config.get_algn_data_width() / 8 + offset_value) % size_value != 0) begin
                        return cfs_algn_reg_access_status_info::new_instance(
                            .status(UVM_NOT_OK), 
                            .info("(Offset, Size) pair not valid")
                        );
                    end
                end
            end

            return cfs_algn_reg_access_status_info::new_instance(
                .status(UVM_IS_OK),
                .info("Everything works correctly :)")
            );
        endfunction

        virtual function void write(BUSTYPE tr);
            uvm_reg_bus_op operation;

            adapter.bus2reg(tr, operation);

            // Check if the operation.status is Correct
            if (env_config.get_has_checks()) begin
                cfs_algn_reg_access_status_info exp_response = get_expected_response(operation);

                if (exp_response.status != operation.status) begin
                    `uvm_error(
                        "DUT_ERROR", 
                        $sformatf(
                            "Mismatch between the bus operation status -expected: %0s -received: %0s -on access: %0s -reason: %0s", 
                            exp_response.status.name(), operation.status.name(), tr.convert2string(), exp_response.info
                        )
                    )
                end
            end

            if (operation.status == UVM_IS_OK) begin
                super.write(tr);
            end

        endfunction

    endclass
`endif 