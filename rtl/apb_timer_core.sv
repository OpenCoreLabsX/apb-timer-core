module apb_timer_core (
  input  logic        i_timer_clk,
  input  logic        i_timer_rst_n,

  input  logic        i_timer_en,
  input  logic        i_timer_oneshot,
  input  logic        i_timer_pwm_en,
  input  logic [15:0] i_timer_prescaler,

  input  logic        i_timer_val_wr_en,
  input  logic [31:0] i_timer_val_wr_data,

  input  logic [31:0] i_timer_reload,
  input  logic [31:0] i_timer_compare,

  output logic [31:0] o_timer_val,
  output logic        o_timer_overflow,
  output logic        o_timer_compare_match,
  output logic        o_timer_pwm,
  output logic        o_timer_hw_clear_en
);

  logic [15:0] r_prescaler_cnt;
  logic [31:0] r_counter;
  logic        w_tick;

  assign w_tick = i_timer_en && (r_prescaler_cnt == 16'd0);
  assign o_timer_val = r_counter;

  always_ff @(posedge i_timer_clk or negedge i_timer_rst_n) begin
    if (!i_timer_rst_n) begin
      r_prescaler_cnt <= 16'd0;
    end else if (i_timer_en) begin
      if (w_tick) begin
        r_prescaler_cnt <= i_timer_prescaler;
      end else begin
        r_prescaler_cnt <= r_prescaler_cnt - 16'd1;
      end
    end else begin
      r_prescaler_cnt <= i_timer_prescaler;
    end
  end

  always_ff @(posedge i_timer_clk or negedge i_timer_rst_n) begin
    if (!i_timer_rst_n) begin
      r_counter             <= 32'd0;
      o_timer_overflow      <= 1'b0;
      o_timer_compare_match <= 1'b0;
      o_timer_hw_clear_en   <= 1'b0;
    end else begin
      o_timer_overflow      <= 1'b0;
      o_timer_compare_match <= 1'b0;
      o_timer_hw_clear_en   <= 1'b0;

      if (i_timer_val_wr_en) begin
        r_counter <= i_timer_val_wr_data;
      end else if (w_tick) begin
        if (r_counter == i_timer_compare) begin
          o_timer_compare_match <= 1'b1;
        end

        if (r_counter >= i_timer_reload) begin
          o_timer_overflow <= 1'b1;
          if (i_timer_oneshot) begin
            o_timer_hw_clear_en <= 1'b1;
          end else begin
            r_counter <= 32'd0;
          end
        end else begin
          r_counter <= r_counter + 32'd1;
        end
      end
    end
  end

  always_ff @(posedge i_timer_clk or negedge i_timer_rst_n) begin
    if (!i_timer_rst_n) begin
      o_timer_pwm <= 1'b0;
    end else begin
      if (i_timer_pwm_en && i_timer_en) begin
        if (r_counter < i_timer_compare) begin
          o_timer_pwm <= 1'b1;
        end else begin
          o_timer_pwm <= 1'b0;
        end
      end else begin
        o_timer_pwm <= 1'b0;
      end
    end
  end

endmodule
