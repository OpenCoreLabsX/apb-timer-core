package apb_timer_pkg;

  localparam logic [7:0] APB_TIMER_ADDR_CTRL     = 8'h00;
  localparam logic [7:0] APB_TIMER_ADDR_STATUS   = 8'h04;
  localparam logic [7:0] APB_TIMER_ADDR_VALUE    = 8'h08;
  localparam logic [7:0] APB_TIMER_ADDR_RELOAD   = 8'h0C;
  localparam logic [7:0] APB_TIMER_ADDR_COMPARE  = 8'h10;
  localparam logic [7:0] APB_TIMER_ADDR_IRQ_EN   = 8'h14;
  localparam logic [7:0] APB_TIMER_ADDR_IRQ_STAT = 8'h18;

  function automatic logic [31:0] apply_strb(
    input logic [31:0] current_val,
    input logic [31:0] write_val,
    input logic [3:0]  strb
  );
    logic [31:0] next_val;
    next_val = current_val;
    if (strb[0]) next_val[7:0]   = write_val[7:0];
    if (strb[1]) next_val[15:8]  = write_val[15:8];
    if (strb[2]) next_val[23:16] = write_val[23:16];
    if (strb[3]) next_val[31:24] = write_val[31:24];
    return next_val;
  endfunction

endpackage
