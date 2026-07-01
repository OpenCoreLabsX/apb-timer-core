class timer_item extends uvm_sequence_item;
  logic irq_asserted;
  logic pwm_state;

  `uvm_object_utils_begin(timer_item)
    `uvm_field_int(irq_asserted, UVM_ALL_ON)
    `uvm_field_int(pwm_state, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "timer_item");
    super.new(name);
  endfunction
endclass
