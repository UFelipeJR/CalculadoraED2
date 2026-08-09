/*
 * This module is the TOP of the ARM single-cycle processor
 */ 
module top(input logic clk, nreset,
			  input logic [9:0] switches,
			  output logic [9:0] leds,
			  
			  //-Teclado
			  input  logic [3:0] COLUMNAS,
			  output logic [3:0] FILAS,
			  
			  //-LCD
			  output logic       LCD_RW,
			  output logic       LCD_RS,
			  output logic       LCD_E,
			  output logic [7:0] LCD_DATA);
			  

			  
	
	logic clk_slow;
	logic MemWrite, nSyncReset, syncReset;
	logic [31:0] PCNext, Instr, ReadData;
	logic [31:0] WriteData, DataAdr;
	logic [31:0] ReadData_mem;
	logic [31:0] ReadData_key;
	logic        key_selected;
	
	logic [31:0] ReadData_lcd;
	logic        lcd_selected;

	logic [127:0] lcd_line1_buffer;
	logic [127:0] lcd_line2_buffer;

	logic [4:0] lcd_cursor_debug;
	logic       lcd_line_debug;
	
	
	assign syncReset = ~nSyncReset;
	
	cntdiv_n #(8) clk_divider(clk, ~nreset, clk_slow);
	
	mem mem(clk_slow, syncReset, MemWrite, PCNext, DataAdr, WriteData, Instr, ReadData_mem, switches, leds);
	
	keyboard_mmio u_keyboard (
    .clk(clk),
    .reset_n(nSyncReset),

    .DataAdr(DataAdr),
    .WriteData(WriteData),
    .MemWrite(MemWrite),

    .ReadData(ReadData_key),
    .selected(key_selected),

    .COLUMNAS(COLUMNAS),
    .FILAS(FILAS),

    .tecla_debug(),
    .ascii_debug(),
    .key_valid_debug()
    );
	 
	lcd_mmio u_lcd_mmio (
    .clk(clk),
    .reset_n(nSyncReset),

    .DataAdr(DataAdr),
    .WriteData(WriteData),
    .MemWrite(MemWrite),

    .ReadData(ReadData_lcd),
    .selected(lcd_selected),

    .line1_buffer(lcd_line1_buffer),
    .line2_buffer(lcd_line2_buffer),

    .cursor_debug(lcd_cursor_debug),
    .line_debug(lcd_line_debug)
	);
	
		driver_lcd #(
			  .freq(100)
		) u_driver_lcd (
			  .clk(clk),
			  .reset_n(nSyncReset),

			  .rw(LCD_RW),
			  .rs(LCD_RS),
			  .e(LCD_E),
			  .lcd_data(LCD_DATA),

			  .line1_buffer(lcd_line1_buffer),
			  .line2_buffer(lcd_line2_buffer)
		);
	
	assign ReadData = key_selected ? ReadData_key :
							lcd_selected ? ReadData_lcd :
							ReadData_mem;
	
	arm arm(clk_slow, syncReset, PCNext, Instr, MemWrite, DataAdr, WriteData, ReadData);
	
	flopr #(1) resetReg(clk_slow, ~nreset, 1'b1, nSyncReset);

endmodule