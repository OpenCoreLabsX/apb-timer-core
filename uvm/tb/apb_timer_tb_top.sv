module apb_timer_tb_top;
  import uvm_pkg::*;
  import apb_timer_uvm_pkg::*;

  logic pclk;
  logic presetn;

  // Clock generation
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end

  // Reset generation
  initial begin
    presetn = 0;
    #20 presetn = 1;
  end

  // Interfaces
  apb_if apb_vif (pclk, presetn);
  timer_if timer_vif (pclk, presetn);

  // Connect TB TIMER loopback
  // (No loopback needed for timer)

  // DUT instantiation
  apb_timer_wrapper #(
    .C_APB_DATA_WIDTH (32),
    .C_APB_ADDR_WIDTH (8)
  ) u_dut (
    .i_timer_pclk    (pclk),
    .i_timer_presetn (presetn),

    .i_timer_paddr   (apb_vif.paddr),
    .i_timer_psel    (apb_vif.psel),
    .i_timer_penable (apb_vif.penable),
    .i_timer_pwrite  (apb_vif.pwrite),
    .i_timer_pwdata  (apb_vif.pwdata),
    .i_timer_pstrb   (apb_vif.pstrb),
    .o_timer_prdata  (apb_vif.prdata),
    .o_timer_pready  (apb_vif.pready),
    .o_timer_pslverr (apb_vif.pslverr),

    .o_timer_pwm     (timer_vif.o_timer_pwm),
    .o_timer_irq     (timer_vif.o_timer_irq)
  );

  // Bind SVA assertions module to DUT
  bind apb_timer_wrapper timer_sva u_timer_sva (
    .clk         (i_timer_pclk),
    .rst_n       (i_timer_presetn),
    .timer_en    (u_apb_if.o_timer_en),
    .oneshot     (u_apb_if.o_timer_oneshot),
    .pwm_en      (u_apb_if.o_timer_pwm_en),
    .prescaler   (u_apb_if.o_timer_prescaler),
    .val_wr_en   (u_apb_if.o_timer_val_wr_en),
    .val_wr_data (u_apb_if.o_timer_val_wr_data),
    .timer_val   (w_timer_val),
    .reload      (w_timer_reload),
    .compare     (w_timer_compare),
    .hw_clear_en (w_timer_hw_clear_en),
    .timer_pwm   (o_timer_pwm),
    .irq_stat    (u_apb_if.r_irq_stat),
    .irq_en      (u_apb_if.r_irq_en),
    .timer_irq   (o_timer_irq)
  );

  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "uvm_test_top.env.m_apb_agent.*", "apb_vif", apb_vif);
    uvm_config_db#(virtual timer_if)::set(null, "uvm_test_top.env.m_timer_agent.*", "timer_vif", timer_vif);

    run_test();
  end
endmodule