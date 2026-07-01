`ifndef APB_TIMER_SCOREBOARD_SV
`define APB_TIMER_SCOREBOARD_SV

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_timer)

class apb_timer_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp_apb #(apb_item, apb_timer_scoreboard) apb_export;
  uvm_analysis_imp_timer #(timer_item, apb_timer_scoreboard) timer_export;

  `uvm_component_utils(apb_timer_scoreboard)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    apb_export = new("apb_export", this);
    timer_export = new("timer_export", this);
  endfunction

  virtual function void write_apb(apb_item item);
    if (item.is_write) begin
      `uvm_info("SCB_APB", $sformatf("APB Write to %0h: %0h", item.addr, item.data), UVM_LOW)
    end else begin
      `uvm_info("SCB_APB", $sformatf("APB Read from %0h: %0h", item.addr, item.data), UVM_LOW)
    end
  endfunction

  virtual function void write_timer(timer_item item);
    `uvm_info("SCB_TIMER", $sformatf("Timer Event - IRQ: %0b, PWM: %0b", item.irq_asserted, item.pwm_state), UVM_LOW)
  endfunction
endclass

`endif
