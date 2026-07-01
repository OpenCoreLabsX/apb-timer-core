`ifndef APB_TIMER_SMOKE_TEST_SV
`define APB_TIMER_SMOKE_TEST_SV

class apb_timer_smoke_test extends apb_timer_base_test;
  `uvm_component_utils(apb_timer_smoke_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    apb_timer_smoke_seq seq;
    phase.raise_objection(this);
    
    seq = apb_timer_smoke_seq::type_id::create("seq");
    seq.start(env.m_apb_agent.sequencer);
    
    #1000;
    phase.drop_objection(this);
  endtask
endclass

`endif
