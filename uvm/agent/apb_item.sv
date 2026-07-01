`ifndef APB_ITEM_SV
`define APB_ITEM_SV

class apb_item extends uvm_sequence_item;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit        is_write;
  rand bit [3:0]  strb;

  bit error;

  `uvm_object_utils_begin(apb_item)
    `uvm_field_int(addr, UVM_ALL_ON)
    `uvm_field_int(data, UVM_ALL_ON)
    `uvm_field_int(is_write, UVM_ALL_ON)
    `uvm_field_int(strb, UVM_ALL_ON)
    `uvm_field_int(error, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "apb_item");
    super.new(name);
  endfunction
endclass

`endif
