`ifndef APB_TIMER_SMOKE_SEQ_SV
`define APB_TIMER_SMOKE_SEQ_SV

class apb_timer_smoke_seq extends apb_timer_base_seq;
  `uvm_object_utils(apb_timer_smoke_seq)

  function new(string name = "apb_timer_smoke_seq");
    super.new(name);
  endfunction

  virtual task body();
    logic [31:0] rdata;
    
    `uvm_info("SEQ", "Starting APB Timer Smoke Sequence...", UVM_LOW)

    // 1. Set Prescaler = 0, One-shot = 0, PWM Enable = 1
    // 2. Set Reload = 100
    // 3. Set Compare = 50
    // 4. Set IRQ_EN = 3 (Overflow & Compare Match)
    // 5. Enable Timer

    write_reg(8'h0C, 32'd100); // RELOAD
    write_reg(8'h10, 32'd50);  // COMPARE
    write_reg(8'h14, 32'd3);   // IRQ_EN
    write_reg(8'h00, 32'd5);   // CTRL = 5 (PWM Enable | Enable)

    // Wait some time for PWM and IRQ
    #2000;

    // Read STATUS
    read_reg(8'h04, rdata);
    `uvm_info("SEQ", $sformatf("STATUS read: %0h", rdata), UVM_LOW)

    // Clear IRQ
    write_reg(8'h18, 32'hFFFF_FFFF);

    `uvm_info("SEQ", "Smoke Sequence completed.", UVM_LOW)
  endtask
endclass

`endif
