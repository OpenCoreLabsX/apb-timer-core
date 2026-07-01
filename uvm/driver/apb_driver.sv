`ifndef APB_DRIVER_SV
`define APB_DRIVER_SV

class apb_driver extends uvm_driver #(apb_item);
  virtual apb_if vif;

  `uvm_component_utils(apb_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "apb_vif", vif)) begin
      `uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
    end
  endfunction

  task run_phase(uvm_phase phase);
    vif.psel    <= 0;
    vif.penable <= 0;
    vif.pwrite  <= 0;
    vif.paddr   <= 0;
    vif.pwdata  <= 0;
    vif.pstrb   <= 0;

    @(posedge vif.presetn);
    forever begin
      seq_item_port.get_next_item(req);
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_item(apb_item item);
    @(posedge vif.pclk);
    vif.psel    <= 1;
    vif.pwrite  <= item.is_write;
    vif.paddr   <= item.addr;
    if (item.is_write) begin
      vif.pwdata <= item.data;
      vif.pstrb  <= item.strb;
    end
    vif.penable <= 0;

    @(posedge vif.pclk);
    vif.penable <= 1;

    wait(vif.pready);
    
    if (!item.is_write) begin
      item.data = vif.prdata;
    end
    item.error = vif.pslverr;

    @(posedge vif.pclk);
    vif.psel    <= 0;
    vif.penable <= 0;
  endtask
endclass

`endif
