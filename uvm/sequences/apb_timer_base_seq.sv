`ifndef APB_TIMER_BASE_SEQ_SV
`define APB_TIMER_BASE_SEQ_SV

class apb_timer_base_seq extends uvm_sequence #(apb_item);
  `uvm_object_utils(apb_timer_base_seq)

  function new(string name = "apb_timer_base_seq");
    super.new(name);
  endfunction

  task write_reg(bit [31:0] addr, bit [31:0] data);
    apb_item item = apb_item::type_id::create("item");
    start_item(item);
    item.addr = addr;
    item.data = data;
    item.is_write = 1;
    item.strb = 4'hF;
    finish_item(item);
  endtask

  task read_reg(bit [31:0] addr, output bit [31:0] data);
    apb_item item = apb_item::type_id::create("item");
    start_item(item);
    item.addr = addr;
    item.is_write = 0;
    finish_item(item);
    data = item.data;
  endtask
endclass

`endif
