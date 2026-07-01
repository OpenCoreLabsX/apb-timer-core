module apb_timer_apb_if import apb_timer_pkg::*; #(
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

  input  logic [31:0]                 i_timer_val,
  input  logic                        i_timer_overflow,
  input  logic                        i_timer_compare_match,
  input  logic                        i_timer_hw_clear_en,

  output logic                        o_timer_en,
  output logic                        o_timer_oneshot,
  output logic                        o_timer_pwm_en,
  output logic [15:0]                 o_timer_prescaler,
  output logic                        o_timer_val_wr_en,
  output logic [31:0]                 o_timer_val_wr_data,
  output logic [31:0]                 o_timer_reload,
  output logic [31:0]                 o_timer_compare,
  output logic                        o_timer_irq
);

  logic w_apb_write;
  logic w_apb_read;
  logic w_addr_valid;

  assign w_apb_write = i_timer_psel && i_timer_penable && i_timer_pwrite;
  assign w_apb_read  = i_timer_psel && i_timer_penable && !i_timer_pwrite;
  assign o_timer_pready = 1'b1;

  logic [31:0] r_ctrl;
  logic [31:0] r_reload;
  logic [31:0] r_compare;
  logic [31:0] r_irq_en;
  logic [31:0] r_irq_stat;
  logic [31:0] w_status;

  assign w_status = {30'd0, i_timer_compare_match, i_timer_overflow};
  assign o_timer_pslverr = (i_timer_psel && i_timer_penable) && !w_addr_valid;

  always_comb begin
    w_addr_valid = 1'b1;
    unique case (i_timer_paddr)
      APB_TIMER_ADDR_CTRL     : ;
      APB_TIMER_ADDR_STATUS   : ;
      APB_TIMER_ADDR_VALUE    : ;
      APB_TIMER_ADDR_RELOAD   : ;
      APB_TIMER_ADDR_COMPARE  : ;
      APB_TIMER_ADDR_IRQ_EN   : ;
      APB_TIMER_ADDR_IRQ_STAT : ;
      default: w_addr_valid = 1'b0;
    endcase
  end

  always_ff @(posedge i_timer_pclk or negedge i_timer_presetn) begin
    if (!i_timer_presetn) begin
      r_ctrl     <= 32'd0;
      r_reload   <= 32'hFFFF_FFFF;
      r_compare  <= 32'hFFFF_FFFF;
      r_irq_en   <= 32'd0;
      r_irq_stat <= 32'd0;
    end else begin
      logic [31:0] w_hw_set;
      logic [31:0] w_sw_clear;
      
      w_hw_set = {30'd0, i_timer_compare_match, i_timer_overflow};
      w_sw_clear = (w_apb_write && w_addr_valid && (i_timer_paddr == APB_TIMER_ADDR_IRQ_STAT)) ? apply_strb(32'd0, i_timer_pwdata, i_timer_pstrb) : 32'd0;

      r_irq_stat <= (r_irq_stat & ~w_sw_clear) | w_hw_set;

      if (i_timer_hw_clear_en) begin
        r_ctrl[0] <= 1'b0;
      end

      if (w_apb_write && w_addr_valid) begin
        unique case (i_timer_paddr)
          APB_TIMER_ADDR_CTRL   : begin
             r_ctrl <= apply_strb(r_ctrl, i_timer_pwdata, i_timer_pstrb);
             if (i_timer_hw_clear_en) begin
                 r_ctrl[0] <= 1'b0;
             end
          end
          APB_TIMER_ADDR_RELOAD : r_reload  <= apply_strb(r_reload, i_timer_pwdata, i_timer_pstrb);
          APB_TIMER_ADDR_COMPARE: r_compare <= apply_strb(r_compare, i_timer_pwdata, i_timer_pstrb);
          APB_TIMER_ADDR_IRQ_EN : r_irq_en  <= apply_strb(r_irq_en, i_timer_pwdata, i_timer_pstrb);
          default: ;
        endcase
      end
    end
  end

  always_comb begin
    o_timer_prdata = 32'd0;
    if (w_addr_valid) begin
      unique case (i_timer_paddr)
        APB_TIMER_ADDR_CTRL     : o_timer_prdata = r_ctrl;
        APB_TIMER_ADDR_STATUS   : o_timer_prdata = w_status;
        APB_TIMER_ADDR_VALUE    : o_timer_prdata = i_timer_val;
        APB_TIMER_ADDR_RELOAD   : o_timer_prdata = r_reload;
        APB_TIMER_ADDR_COMPARE  : o_timer_prdata = r_compare;
        APB_TIMER_ADDR_IRQ_EN   : o_timer_prdata = r_irq_en;
        APB_TIMER_ADDR_IRQ_STAT : o_timer_prdata = r_irq_stat;
        default: o_timer_prdata = 32'd0;
      endcase
    end
  end

  assign o_timer_en          = r_ctrl[0];
  assign o_timer_oneshot     = r_ctrl[1];
  assign o_timer_pwm_en      = r_ctrl[2];
  assign o_timer_prescaler   = r_ctrl[31:16];

  assign o_timer_val_wr_en   = w_apb_write && (i_timer_paddr == APB_TIMER_ADDR_VALUE) && w_addr_valid;
  assign o_timer_val_wr_data = i_timer_pwdata;

  assign o_timer_reload      = r_reload;
  assign o_timer_compare     = r_compare;

  assign o_timer_irq         = |(r_irq_stat & r_irq_en);

endmodule
