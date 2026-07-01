`ifndef APB_TIMER_ENV_SV
`define APB_TIMER_ENV_SV

class apb_timer_env extends uvm_env;
  apb_agent            m_apb_agent;
  timer_agent          m_timer_agent;
  apb_timer_scoreboard m_scoreboard;

  `uvm_component_utils(apb_timer_env)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_apb_agent   = apb_agent::type_id::create("m_apb_agent", this);
    m_timer_agent = timer_agent::type_id::create("m_timer_agent", this);
    m_scoreboard  = apb_timer_scoreboard::type_id::create("m_scoreboard", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_apb_agent.monitor.ap.connect(m_scoreboard.apb_export);
    m_timer_agent.m_monitor.ap.connect(m_scoreboard.timer_export);
  endfunction
endclass

`endif
