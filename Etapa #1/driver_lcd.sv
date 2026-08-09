//Inspirado en el siguiente driver: https://github.com/Maeur1/16x2-LCD-Controller-VHDL/blob/master/lcd_controller.vhd

module driver_lcd #(
  parameter int unsigned freq = 100
)(
  input  logic        clk,
  input  logic        reset_n,
  output logic        rw,
  output logic        rs,
  output logic        e,
  output logic [7:0]  lcd_data,
  input  logic [127:0] line1_buffer,
  input  logic [127:0] line2_buffer   // Pendiente de mejora
);

  typedef enum logic [2:0] {power_up, initialize, RESETLINE, line1, line2, send} control_t;
  control_t state;

  int unsigned clk_count;

  logic [4:0] ptr;
  logic       line;

  always_ff @(posedge clk) begin
    if (!reset_n) begin
      state     <= power_up;
      clk_count <= 0;
      rw        <= 1'b0;
      rs        <= 1'b0;
      e         <= 1'b0;
      lcd_data  <= 8'h00;
      ptr       <= 5'd15;
      line      <= 1'b1;
    end else begin
      case (state)

        power_up: begin
          if (clk_count < (50000 * freq)) begin
            clk_count <= clk_count + 1;
            state     <= power_up;
          end else begin
            clk_count <= 0;
            rs        <= 1'b0;
            rw        <= 1'b0;
            lcd_data  <= 8'b00110000;
            state     <= initialize;
          end
        end

        initialize: begin
          clk_count <= clk_count + 1;

          if (clk_count < (10 * freq)) begin
            lcd_data <= 8'b00111100;
            e        <= 1'b1;
            state    <= initialize;

          end else if (clk_count < (60 * freq)) begin
            lcd_data <= 8'b00000000;
            e        <= 1'b0;
            state    <= initialize;

          end else if (clk_count < (70 * freq)) begin
            lcd_data <= 8'b00001100;
            e        <= 1'b1;
            state    <= initialize;

          end else if (clk_count < (120 * freq)) begin
            lcd_data <= 8'b00000000;
            e        <= 1'b0;
            state    <= initialize;

          end else if (clk_count < (130 * freq)) begin
            lcd_data <= 8'b00000001;
            e        <= 1'b1;
            state    <= initialize;

          end else if (clk_count < (2130 * freq)) begin
            lcd_data <= 8'b00000000;
            e        <= 1'b0;
            state    <= initialize;

          end else if (clk_count < (2140 * freq)) begin
            lcd_data <= 8'b00000110;
            e        <= 1'b1;
            state    <= initialize;

          end else if (clk_count < (2200 * freq)) begin
            lcd_data <= 8'b00000000;
            e        <= 1'b0;
            state    <= initialize;

          end else begin
            clk_count <= 0;
            state     <= RESETLINE;
          end
        end

        RESETLINE: begin
          ptr <= 5'd16;
          if (line == 1'b1) begin
            lcd_data  <= 8'b10000000;
            rs        <= 1'b0;
            rw        <= 1'b0;
            clk_count <= 0;
            state     <= send;
          end else begin
            lcd_data  <= 8'b11000000;
            rs        <= 1'b0;
            rw        <= 1'b0;
            clk_count <= 0;
            state     <= send;
          end
        end

        line1: begin
          line      <= 1'b1;
          lcd_data  <= line1_buffer[(ptr*8) +: 8];
          rs        <= 1'b1;
          rw        <= 1'b0;
          clk_count <= 0;
          state     <= send;
        end

        line2: begin
          line      <= 1'b0;
          lcd_data  <= line2_buffer[(ptr*8) +: 8];
          rs        <= 1'b1;
          rw        <= 1'b0;
          clk_count <= 0;
          state     <= send;
        end

        send: begin
          if (clk_count < (50 * freq)) begin
            if (clk_count < freq) begin
              e <= 1'b0;
            end else if (clk_count < (14 * freq)) begin
              e <= 1'b1;
            end else if (clk_count < (27 * freq)) begin
              e <= 1'b0;
            end
            clk_count <= clk_count + 1;
            state     <= send;
          end else begin
            clk_count <= 0;
            if (line == 1'b1) begin
              if (ptr == 5'd0) begin
                line  <= 1'b0;
                state <= RESETLINE;
              end else begin
                ptr   <= ptr - 1;
                state <= line1;
              end
            end else begin
              if (ptr == 5'd0) begin
                line  <= 1'b1;
                state <= RESETLINE;
              end else begin
                ptr   <= ptr - 1;
                state <= line2;
              end
            end
          end
        end

        default: begin
          state <= power_up;
        end

      endcase
    end
  end

endmodule


