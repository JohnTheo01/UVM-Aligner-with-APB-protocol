`ifndef CFS_APB_IF_SV

    `define CFS_APB_IF_SV

    `ifndef CFS_APB_MAX_DATA_WIDTH
		`define CFS_APB_MAX_DATA_WIDTH 32
	`endif

	`ifndef CFS_APB_MAX_ADDR_WIDTH
		`define CFS_APB_MAX_ADDR_WIDTH 16
	`endif

   
	interface cfs_apb_if(input pclk);

   	  	logic preset_n;
      
      	logic psel;
      	
      	logic penable;
      
      	logic pwrite;	
      
      	logic [`CFS_APB_MAX_ADDR_WIDTH-1:0] paddr;
      	
      	logic [`CFS_APB_MAX_DATA_WIDTH-1:0] pwdata;
      
      	logic pready;
      
      	logic [`CFS_APB_MAX_DATA_WIDTH-1:0] prdata;
      
      	logic pslverr;
      
		bit has_checks;

		initial begin
			has_checks = 1;
		end

		sequence setup_phase_s;
			(psel == 1) && ( ($past(psel) == 0) || (($past(psel) == 1) && ($past(pready) == 1)) );
		endsequence

		sequence access_phase_s;
			(psel ==  1) && (penable == 1);
		endsequence

		//---------------------------------------- FIRST RULE ----------------------------------------
		property penable_at_setup_phase_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			setup_phase_s |-> penable == 0;
		endproperty

		PRENABLE_AT_SETUP_PHASE_A : assert property(penable_at_setup_phase_p)
			else $error("PENABLE at setup phase not set to 0");

		property penable_entering_access_phase_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			setup_phase_s |=> penable == 1;
		endproperty

		PRENABLE_ENTERING_ACCESS_PHASE_A : assert property(penable_entering_access_phase_p)
			else $error("PENABLE entering access phase not set to 1");

		//---------------------------------------- SECOND RULE ----------------------------------------
		property penable_exiting_access_phase_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			access_phase_s and (pready == 1) |=> penable == 0;
		endproperty

		PRENABLE_EXITING_ACCESS_PHASE_A : assert property(penable_exiting_access_phase_p)
			else $error("PENABLE exiting access phase not set to 0");

		//---------------------------------------- THIRD_RULE ----------------------------------------
		property penable_stable_during_access_phase_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			access_phase_s |-> penable == 1;
		endproperty

		PENABLE_STABLE_DURING_ACCESS_PHASE_A: assert property(penable_stable_during_access_phase_p)
			else $error("PENABLE not stable during \"access phase\"");

		property pwrite_stable_during_access_phase_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			access_phase_s |-> $stable(pwrite);
		endproperty

		PWRITE_STABLE_DURING_ACCESS_PHASE_A: assert property(pwrite_stable_during_access_phase_p)
			else $error("PWRITE not stable during \"access phase\"");

		property paddr_stable_during_access_phase_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			access_phase_s |-> $stable(paddr);
		endproperty

		PADDR_STABLE_DURING_ACCESS_PHASE_A: assert property(pwrite_stable_during_access_phase_p)
			else $error("PADDR not stable during \"access phase\"");

		property pwdata_stable_during_access_phase_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			access_phase_s and (pwrite == 1) |-> $stable(paddr);
		endproperty

		PWDATA_STABLE_DURING_ACCESS_PHASE_A: assert property(pwrite_stable_during_access_phase_p)
			else $error("PWDATA not stable during \"access phase\"");

		//---------------------------------------- FOURTH RULE ----------------------------------------
		property psel_unknown_value_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			$isunknown(psel) == 0;
		endproperty

		PSEL_UNKOWN_VALUE_A : assert property(psel_unknown_value_p)
			else $error("PSEL is unknown");


		property penable_unknown_value_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			psel == 1 |-> $isunknown(penable) == 0;
		endproperty

		ENABLE_UNKOWN_VALUE_A : assert property(penable_unknown_value_p)
			else $error("PENABLE is unknown");


		property paddr_unknown_value_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			psel == 1 |-> $isunknown(paddr) == 0;
		endproperty

		PADDR_UNKOWN_VALUE_A : assert property(paddr_unknown_value_p)
			else $error("PADDR is unknown");


		property pwrite_unknown_value_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			psel == 1 |-> $isunknown(pwrite) == 0;
		endproperty

		PWRITE_UNKOWN_VALUE_A : assert property(pwrite_unknown_value_p)
			else $error("PWRITE is unknown");


		property pwdata_unknown_value_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			(psel == 1) and (pwrite == 1) |-> $isunknown(pwdata) == 0;
		endproperty

		PWDATA_UNKOWN_VALUE_A : assert property(pwdata_unknown_value_p)
			else $error("PWDATA is unknown");


		property prdata_unknown_value_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			(psel == 1) and (pwrite == 0) and (pready == 1) and (pslverr == 0) |-> $isunknown(prdata) == 0;
		endproperty

		PRDATA_UNKNOWN_VALUE_A : assert property(prdata_unknown_value_p)
			else $error("PRDATA is unknown");


		property pready_unknown_value_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			(psel == 1) |-> $isunknown(pready) == 0;
		endproperty

		PREADY_UNKNOWN_VALUE_A : assert property(pready_unknown_value_p)
			else $error("PREADY is unknown");
				

		property pslverr_unknown_value_p;
			@(posedge pclk) disable iff (!preset_n || !has_checks)
			(psel == 1) && (pready == 1) |-> $isunknown(pslverr);
		endproperty

		PSLVERR_UNKNOWN_VALUE_A : assert property (pslverr_unknown_value_p)
			else $error("PSLVERR is unknown");

    endinterface


`endif