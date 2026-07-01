module apb_timer_wrapper #(
  parameter int C_APB_DATA_WIDTH = 32,
  parameter int C_APB_ADDR_WIDTH = 8
) (
  input  logic                        i_timer_pclk,
  input  logic                        i_timer_presetn,

  input  logic [C_APB_ADDR_WIDTH-1:0] i_timer_paddr,
  input  logic                        i_timer_psel,
  input  logic                        i_timer_penable,
  input  logic                        i_timer_pwrite,
  input  logic [C_APB_DATA_WIDTH-1:0] i_timer_pwdata,
  input  logic [3:0]                  i_timer_pstrb,
  output logic [C_APB_DATA_WIDTH-1:0] o_timer_prdata,
  output logic                        o_timer_pready,
  output logic                        o_timer_pslverr,

  output logic                        o_timer_irq,
  output logic                        o_timer_pwm
);

  logic        w_timer_en;
  logic        w_timer_oneshot;
  logic        w_timer_pwm_en;
  logic [15:0] w_timer_prescaler;
  
  logic        w_timer_val_wr_en;
  logic [31:0] w_timer_val_wr_data;
  
  logic [31:0] w_timer_reload;
  logic [31:0] w_timer_compare;
  
  logic [31:0] w_timer_val;
  logic        w_timer_overflow;
  logic        w_timer_compare_match;
  logic        w_timer_hw_clear_en;

  apb_timer_core u_timer_core (
    .i_timer_clk             (i_timer_pclk),
    .i_timer_rst_n           (i_timer_presetn),
    .i_timer_en              (w_timer_en),
    .i_timer_oneshot         (w_timer_oneshot),
    .i_timer_pwm_en          (w_timer_pwm_en),
    .i_timer_prescaler       (w_timer_prescaler),
    .i_timer_val_wr_en       (w_timer_val_wr_en),
    .i_timer_val_wr_data     (w_timer_val_wr_data),
    .i_timer_reload          (w_timer_reload),
    .i_timer_compare         (w_timer_compare),
    .o_timer_val             (w_timer_val),
    .o_timer_overflow        (w_timer_overflow),
    .o_timer_compare_match   (w_timer_compare_match),
    .o_timer_pwm             (o_timer_pwm),
    .o_timer_hw_clear_en     (w_timer_hw_clear_en)
  );

  apb_timer_apb_if #(
    .C_APB_DATA_WIDTH (C_APB_DATA_WIDTH),
    .C_APB_ADDR_WIDTH (C_APB_ADDR_WIDTH)
  ) u_apb_if (
    .i_timer_pclk            (i_timer_pclk),
    .i_timer_presetn         (i_timer_presetn),
    .i_timer_paddr           (i_timer_paddr),
    .i_timer_psel            (i_timer_psel),
    .i_timer_penable         (i_timer_penable),
    .i_timer_pwrite          (i_timer_pwrite),
    .i_timer_pwdata          (i_timer_pwdata),
    .i_timer_pstrb           (i_timer_pstrb),
    .o_timer_prdata          (o_timer_prdata),
    .o_timer_pready          (o_timer_pready),
    .o_timer_pslverr         (o_timer_pslverr),
    .i_timer_val             (w_timer_val),
    .i_timer_overflow        (w_timer_overflow),
    .i_timer_compare_match   (w_timer_compare_match),
    .i_timer_hw_clear_en     (w_timer_hw_clear_en),
    .o_timer_en              (w_timer_en),
    .o_timer_oneshot         (w_timer_oneshot),
    .o_timer_pwm_en          (w_timer_pwm_en),
    .o_timer_prescaler       (w_timer_prescaler),
    .o_timer_val_wr_en       (w_timer_val_wr_en),
    .o_timer_val_wr_data     (w_timer_val_wr_data),
    .o_timer_reload          (w_timer_reload),
    .o_timer_compare         (w_timer_compare),
    .o_timer_irq             (o_timer_irq)
  );

endmodule
