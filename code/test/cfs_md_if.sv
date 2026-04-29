`ifndef CFS_MD_IF_SV

    `define CFS_MD_IF_SV

    interface cfs_md_if#(int unsigned DATA_WIDTH = 32)(input clk);

        // Width of the Offset signal
        localparam OFFSET_WIDTH = $clog2(DATA_WIDTH/8) < 1 ? 1 : $clog2(DATA_WIDTH/8);

        // Width of the Size signal
        localparam SIZE_WIDTH = $clog2(DATA_WIDTH/8) + 1;

        logic reset_n;

        logic valid;

        logic[DATA_WIDTH-1:0] data;

        logic[OFFSET_WIDTH-1:0] offset;

        logic[SIZE_WIDTH-1:0] size;

        logic ready;

        logic err;

        bit has_checks;

        initial begin
            has_checks = 1;
        end


        // ----------------------------------- DATA_WIDTH CHECK -----------------------------------
        

        
        if (DATA_WIDTH < 8) begin
            $error("DATA_WIDTH (value: %0d) must be greater or equal to 8", DATA_WIDTH);
        end
      
        if ($log10(DATA_WIDTH)/$log10(2) - $clog2(DATA_WIDTH) != 0) begin
            $error("DATA_WIDTH (value: %0d) must be a power of 2", DATA_WIDTH);
        end
      

        // ----------------------------------- FIRST RULE -----------------------------------
        property valid_high_until_ready_high_p;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            $fell(valid) |-> $past(ready) == 1;
        endproperty        

        VALID_HIGH_UNTIL_READY_HIGH_A: assert property (valid_high_until_ready_high_p)
            else $error("Valid must be high until ready is high");

        // ----------------------------------- SECOND RULE -----------------------------------
        property unknown_value_data_p;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid |-> $isunknown(data) == 0;
        endproperty

        UNKNOWN_VALUE_DATA_A: assert property (unknown_value_data_p)
            else $error("Data must be valid while \"valid\" is high");

        // ----------------------------------- THIRD RULE -----------------------------------
        
        property unknown_value_offset_p;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid |-> $isunknown(offset) == 0;
        endproperty

        UNKNOWN_VALUE_OFFSET_A: assert property (unknown_value_offset_p)
            else $error("Offset must be valid while \"valid\" is high");

        // ----------------------------------- FOURTH RULE -----------------------------------
        property unknown_value_size_p;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid |-> $isunknown(size) == 0;
        endproperty

        UNKNOWN_VALUE_SIZE_A: assert property (unknown_value_size_p)
            else $error("Size must be valid while \"valid\" is high");

        // ----------------------------------- FIFTH RULE -----------------------------------
        property unknown_value_error_p;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid & ready |-> $isunknown(err) == 0;
        endproperty

        UNKNOWN_VALUE_ERROR_A: assert property (unknown_value_error_p)
            else $error("Data must be valid while \"valid\" is high and \"ready\" is high");

        // ----------------------------------- SIXTH RULE -----------------------------------
        property unknown_value_valid_p;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            $isunknown(valid) == 0;
        endproperty

        UNKNOWN_VALUE_VALID_A: assert property (unknown_value_valid_p)
            else $error("Valid must be valid always");

        // ----------------------------------- SEVENTH RULE -----------------------------------
        property unknown_value_ready_p;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid |-> $isunknown(ready) == 0;
        endproperty

        UNKNOWN_VALUE_READY_A: assert property (unknown_value_ready_p)
            else $error("Ready must be valid while \"valid\" is high");

        // ----------------------------------- EIGTH RULE -----------------------------------
        property data_constant_until_ready_high;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid & !ready |=> $stable(data) | ready;
        endproperty

        DATA_CONSTANT_UNTIL_READY_HIGH_A: assert property (data_constant_until_ready_high)    
            else $error("Data must be constant until ready is high");

        // ----------------------------------- NINTH RULE -----------------------------------
        property offset_constant_until_ready_high;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid & !ready |=> $stable(offset) | ready;
        endproperty

        OFFSET_CONSTANT_UNTIL_READY_HIGH_A: assert property (offset_constant_until_ready_high)    
            else $error("Offset must be constant until ready is high");

        // ----------------------------------- TENTH RULE -----------------------------------
        property size_constant_until_ready_high;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid & !ready |=> $stable(size) | ready;
        endproperty

        SIZE_CONSTANT_UNTIL_READY_HIGH_A: assert property (size_constant_until_ready_high)    
            else $error("Size must be constant until ready is high");

        // ----------------------------------- ELEVENTH RULE -----------------------------------
        property error_high_only_when_ready_and_valid_high;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            err |-> valid & ready;
        endproperty

        ERROR_HIGH_ONLY_WHEN_READY_AND_VALID_HIGH_A: assert property(error_high_only_when_ready_and_valid_high)
            else $error("Error can only be high when ready and valid is high");

        // ----------------------------------- TWELFTH RULE  -----------------------------------
        property size_non_zero;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid |-> size != 0;
        endproperty

        SIZE_NON_ZERO: assert property(size_non_zero)
            else $error("Size must not be 0");

        // ----------------------------------- THIRTEENTH RULE -----------------------------------
        property offset_size_max_value;
            @(posedge clk) disable iff (!reset_n || !has_checks)
            valid |-> offset + size <= (DATA_WIDTH / 8);
        endproperty

        OFFSET_SIZE_MAX_VALUE: assert property(offset_size_max_value)
            else $error("Offset + Size must be less or equal to BUS WIDTH (DATA_WIDTH / 8)");




        
        

    endinterface

`endif 