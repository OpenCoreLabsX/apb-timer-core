`ifndef TIMER_MONITOR_SV
`define TIMER_MONITOR_SV

class timer_monitor extends uvm_monitor;
  virtual timer_if vif;
  uvm_analysis_port #(timer_item) ap;

  `uvm_component_utils(timer_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual timer_if)::get(this, "", "timer_vif", vif)) begin
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end
  endfunction

  task run_phase(uvm_phase phase);
    timer_item item;
    forever begin
      @(posedge vif.clk);
      if (vif.o_timer_irq || vif.o_timer_pwm) begin
         item = timer_item::type_id::create("item");
         item.irq_asserted = vif.o_timer_irq;
         item.pwm_state = vif.o_timer_pwm;
         ap.write(item);
      end
    end
  endtask
endclass

`endif
