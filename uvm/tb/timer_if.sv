interface timer_if (
  input logic clk,
  input logic rst_n
);
  logic o_timer_pwm;
  logic o_timer_irq;

endinterface
