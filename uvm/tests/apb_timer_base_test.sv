`ifndef APB_TIMER_BASE_TEST_SV
`define APB_TIMER_BASE_TEST_SV

class apb_timer_base_test extends uvm_test;
  apb_timer_env env;

  `uvm_component_utils(apb_timer_base_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = apb_timer_env::type_id::create("env", this);
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_report_server svr;
    super.report_phase(phase);
    svr = uvm_report_server::get_server();
    if (svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR) == 0) begin
      `uvm_info("TEST", "---------------------------------------", UVM_NONE)
      `uvm_info("TEST", "----           TEST PASSED         ----", UVM_NONE)
      `uvm_info("TEST", "---------------------------------------", UVM_NONE)
    end else begin
      `uvm_info("TEST", "---------------------------------------", UVM_NONE)
      `uvm_info("TEST", "----           TEST FAILED         ----", UVM_NONE)
      `uvm_info("TEST", "---------------------------------------", UVM_NONE)
    end
  endfunction
endclass

`endif
