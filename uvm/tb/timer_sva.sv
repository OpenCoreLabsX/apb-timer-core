module timer_sva (
  input  logic        clk,
  input  logic        rst_n,

  // Control & Core Inputs
  input  logic        timer_en,
  input  logic        oneshot,
  input  logic        pwm_en,
  input  logic [15:0] prescaler,

  // Direct Write Interface
  input  logic        val_wr_en,
  input  logic [31:0] val_wr_data,

  // Values & Limits
  input  logic [31:0] timer_val,
  input  logic [31:0] reload,
  input  logic [31:0] compare,

  // Outputs & IRQ
  input  logic        hw_clear_en,
  input  logic        timer_pwm,
  input  logic [31:0] irq_stat,
  input  logic [31:0] irq_en,
  input  logic        timer_irq
);

  default clocking cb @(posedge clk); endclocking;
  default disable iff (!rst_n);

  // 1. Counter Stability While Disabled
  property p_counter_stable_when_disabled;
    (!timer_en && !val_wr_en) |=> $stable(timer_val);
  endproperty
  assert_counter_stable_when_disabled: assert property (p_counter_stable_when_disabled);

  // 2. Direct Write Updates Counter
  property p_direct_write_value;
    val_wr_en |=> (timer_val == $past(val_wr_data));
  endproperty
  assert_direct_write_value: assert property (p_direct_write_value);

  // 3. One-Shot Mode Hardware Clear
  property p_oneshot_hw_clear;
    (timer_en && oneshot && !val_wr_en && (timer_val >= reload) &&
     (timer_val != $past(timer_val) || prescaler == 16'd0))
    |=> hw_clear_en;
  endproperty
  assert_oneshot_hw_clear: assert property (p_oneshot_hw_clear);

  // 4. PWM Disabled Output
  property p_pwm_disabled_low;
    (!pwm_en || !timer_en) |=> (timer_pwm == 1'b0);
  endproperty
  assert_pwm_disabled_low: assert property (p_pwm_disabled_low);

  // 5. Active PWM Level
  property p_pwm_active_level;
    (pwm_en && timer_en) |=> (timer_pwm == ($past(timer_val) < $past(compare)));
  endproperty
  assert_pwm_active_level: assert property (p_pwm_active_level);

  // 6. IRQ Masking Check
  property p_irq_unmasked_check;
    timer_irq == |(irq_stat & irq_en);
  endproperty
  assert_irq_unmasked_check: assert property (p_irq_unmasked_check);

endmodule