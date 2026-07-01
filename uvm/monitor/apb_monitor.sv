`ifndef APB_MONITOR_SV
`define APB_MONITOR_SV

class apb_monitor extends uvm_monitor;
  virtual apb_if vif;
  uvm_analysis_port #(apb_item) ap;

  `uvm_component_utils(apb_monitor)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif)) begin
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end
  endfunction

  task run_phase(uvm_phase phase);
    apb_item item;
    @(posedge vif.presetn);
    forever begin
      @(posedge vif.pclk);
      if (vif.psel && vif.penable && vif.pready) begin
        item = apb_item::type_id::create("item");
        item.addr     = vif.paddr;
        item.is_write = vif.pwrite;
        item.strb     = vif.pstrb;
        if (vif.pwrite) item.data = vif.pwdata;
        else            item.data = vif.prdata;
        item.error    = vif.pslverr;
        ap.write(item);
      end
    end
  endtask
endclass

`endif
