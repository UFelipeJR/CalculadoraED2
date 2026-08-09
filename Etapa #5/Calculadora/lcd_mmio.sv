/*
 * LCD MMIO
 * Interfaz entre el procesador y driver_lcd.
 *
 * Direcciones:
 * 0xFF20_0200 -> LCD_CHAR   escritura: escribe un caracter ASCII
 * 0xFF20_0204 -> LCD_CMD    escritura: comandos
 * 0xFF20_0208 -> LCD_STATUS lectura: 1 = listo
 *
 * Comandos LCD_CMD:
 * 1 -> limpiar pantalla
 * 2 -> backspace
 * 3 -> mover cursor a linea 2
 * 4 -> mover cursor a linea 1
 */

module lcd_mmio(
    input  logic        clk,
    input  logic        reset_n,

    // Bus desde CPU
    input  logic [31:0] DataAdr,
    input  logic [31:0] WriteData,
    input  logic        MemWrite,

    output logic [31:0] ReadData,
    output logic        selected,

    // Buffers hacia driver_lcd
    output logic [127:0] line1_buffer,
    output logic [127:0] line2_buffer,

    // Debug opcional
    output logic [4:0] cursor_debug,
    output logic       line_debug
);

    localparam logic [31:0] LCD_CHAR   = 32'hFF20_0200;
    localparam logic [31:0] LCD_CMD    = 32'hFF20_0204;
    localparam logic [31:0] LCD_STATUS = 32'hFF20_0208;

    localparam logic [31:0] CMD_CLEAR = 32'd1;
    localparam logic [31:0] CMD_BS    = 32'd2;
    localparam logic [31:0] CMD_LINE2 = 32'd3;
    localparam logic [31:0] CMD_LINE1 = 32'd4;
	 
	 logic lcd_write_active;
	 logic lcd_write_active_d;
	 logic lcd_write_pulse;

    logic [4:0] cursor;
    logic       current_line;
	 
	 assign lcd_write_active = MemWrite && ((DataAdr == LCD_CHAR) || (DataAdr == LCD_CMD));
	 assign lcd_write_pulse  = lcd_write_active && !lcd_write_active_d;

    assign selected = (DataAdr == LCD_CHAR) ||
                      (DataAdr == LCD_CMD)  ||
                      (DataAdr == LCD_STATUS);

    // Lectura del periferico LCD
    always_comb begin
        case (DataAdr)
            LCD_STATUS: ReadData = 32'd1;
            default:    ReadData = 32'd0;
        endcase
    end

    // Escribir un caracter en una posicion del buffer.
    // OJO: tu driver_lcd lee line_buffer[(ptr*8)+:8] desde ptr=15 hasta 0.
    // Por eso el caracter visual de la posicion 0 se guarda en bits [15*8 +: 8].
    task automatic write_char_to_buffer(input logic [7:0] ch);
        int index;
        begin
            index = 15 - cursor;

            if (current_line == 1'b0) begin
                line1_buffer[(index*8) +: 8] <= ch;
            end else begin
                line2_buffer[(index*8) +: 8] <= ch;
            end

            if (cursor < 5'd15) begin
                cursor <= cursor + 5'd1;
            end else begin
                cursor <= 5'd0;
                current_line <= ~current_line;
            end
        end
    endtask

    task automatic clear_buffers();
        int i;
        begin
            for (i = 0; i < 16; i = i + 1) begin
                line1_buffer[(i*8) +: 8] <= 8'h20;
                line2_buffer[(i*8) +: 8] <= 8'h20;
            end
            cursor       <= 5'd0;
            current_line <= 1'b0;
        end
    endtask

	task automatic backspace();
		 int index;
		 logic [4:0] new_cursor;
		 begin
			  if (cursor > 5'd0) begin
					new_cursor = cursor - 5'd1;
					index = 15 - new_cursor;

					if (current_line == 1'b0) begin
						 line1_buffer[(index*8) +: 8] <= 8'h20;
					end else begin
						 line2_buffer[(index*8) +: 8] <= 8'h20;
					end

					cursor <= new_cursor;
			  end
		 end
	endtask

		always_ff @(posedge clk or negedge reset_n) begin
			 if (!reset_n) begin
				  clear_buffers();
				  lcd_write_active_d <= 1'b0;
			 end else begin
			 
        lcd_write_active_d <= lcd_write_active;
				if (lcd_write_pulse && (DataAdr == LCD_CHAR)) begin
					 write_char_to_buffer(WriteData[7:0]);
				end

            if (lcd_write_pulse && (DataAdr == LCD_CMD)) begin
                case (WriteData)
                    CMD_CLEAR: clear_buffers();

                    CMD_BS: backspace();

                    CMD_LINE2: begin
                        current_line <= 1'b1;
                        cursor       <= 5'd0;
                    end

                    CMD_LINE1: begin
                        current_line <= 1'b0;
                        cursor       <= 5'd0;
                    end

                    default: begin
                        // no hace nada
                    end
                endcase
            end
        end
    end

    assign cursor_debug = cursor;
    assign line_debug   = current_line;

endmodule