//Inspirado en el driver del profesor Edinson Aedo Cobo
// Se añadió emisión de flags para favorecer el antirebote

module driver_teclado #(
    parameter int TOPVALUE = 50_000_000
)(
    input  logic        clk,
	 input  logic        rst,
    input  logic [3:0]  COLUMNAS,  // Entradas de columnas del teclado
    output logic [3:0]  FILAS,     // Filas activadas por el controlador
    output logic [3:0]  TECLA,     // Código de tecla detectada (0-F)
    output logic        FLAG,      // Flag alto cuando se detecta una tecla
    output logic [7:0]  DISP       // Salida al display de 7 segmentos. muestra valor de la tecla
);

    localparam int DELAY_1MS    = TOPVALUE / 1000;
    localparam int DELAY_10MS   = TOPVALUE / 100;
    localparam int BITS_1MS     = $clog2(DELAY_1MS);
    localparam int BITS_10MS    = $clog2(DELAY_10MS);

    logic [BITS_1MS-1:0]  conta_1ms;
    logic [BITS_10MS-1:0] conta_10ms;

    logic [4:0] tecla_detectada;
    logic [4:0] tecla_confirmada;
    logic [7:0] REG0;
	 logic [7:0] REG1;
	 logic [7:0] REG2;
	 logic [7:0] REG3;
	 logic [7:0] FILACOL;
	 logic [3:0] SCOL;
	 logic clkout, clkout2;
	 logic b;
	 logic b_release;
	 logic [1:0] CONT;
    logic tecla_presionada;
    logic [3:0] filas_mux;

	// increment or reset the counter
	always_ff @(posedge clk) begin
		if (~rst ) begin
			conta_1ms <= 0;
			clkout2 <= 0;
		end else begin
			if (conta_1ms == DELAY_1MS-1) begin
				clkout2 <= ~clkout2;
				conta_1ms <= 0;
			end else begin
			    conta_1ms <= conta_1ms + 1'b1;
            end
		end
	end

 // DIVISOR 10 MS, reloj clkout
 always_ff @(posedge clk) begin
		if (~rst) begin
			conta_10ms <= 0;
			clkout <= 0;
		end else begin
			if (conta_10ms == DELAY_10MS-1) begin
				clkout <= ~clkout;
				conta_10ms <= 0;
			end else begin
			    conta_10ms <= conta_10ms + 1'b1;
            end
		end
	end

	 // cuatro antirebotes por cada columna de entada.
	 //antirebote columnas 0, 1, 2, 3
	always_ff @(posedge clkout2 or negedge rst) begin
	    if (~rst) begin
	        REG0 <= 8'b0;
	        REG1 <= 8'b0;
	        REG2 <= 8'b0;
	        REG3 <= 8'b0;
	        SCOL <= 4'b0000;
	        b <= 1'b0;
	        b_release <= 1'b1;
	    end else begin
	        REG0 <= {REG0[6:0], COLUMNAS[0]};
            REG1 <= {REG1[6:0], COLUMNAS[1]};
			REG2 <= {REG2[6:0], COLUMNAS[2]};
			REG3 <= {REG3[6:0], COLUMNAS[3]};

            if ({REG0[6:0], COLUMNAS[0]} == 8'b11111111) begin
                SCOL[0] <= 1'b1;
			end else begin
				SCOL[0] <= 1'b0;
			end

		    if ({REG1[6:0], COLUMNAS[1]} == 8'b11111111) begin
                SCOL[1] <= 1'b1;
			end else begin
				SCOL[1] <= 1'b0;
			end

			if ({REG2[6:0], COLUMNAS[2]} == 8'b11111111) begin
                SCOL[2] <= 1'b1;
			end else begin
				SCOL[2] <= 1'b0;
			end

			if ({REG3[6:0], COLUMNAS[3]} == 8'b11111111) begin
                SCOL[3] <= 1'b1;
			end else begin
				SCOL[3] <= 1'b0;
			end

			b <= (({REG0[6:0], COLUMNAS[0]} == 8'b11111111) |
			      ({REG1[6:0], COLUMNAS[1]} == 8'b11111111) |
			      ({REG2[6:0], COLUMNAS[2]} == 8'b11111111) |
			      ({REG3[6:0], COLUMNAS[3]} == 8'b11111111));

			b_release <= (({REG0[6:0], COLUMNAS[0]} == 8'b00000000) &
			              ({REG1[6:0], COLUMNAS[1]} == 8'b00000000) &
			              ({REG2[6:0], COLUMNAS[2]} == 8'b00000000) &
			              ({REG3[6:0], COLUMNAS[3]} == 8'b00000000));
	    end
	end

    // Escaneo de filas, se activa una fila cada ciclo de reloj
    always_ff @(posedge clkout or negedge rst) begin
		if (~rst ) begin
			CONT <= 2'd0;
			FILAS <= 4'b0001;
		end else begin
            if (!tecla_presionada) begin
                CONT <= CONT + 2'd1;
                case (CONT)
                    2'b00: FILAS <= 4'b0001;
                    2'b01: FILAS <= 4'b0010;
                    2'b10: FILAS <= 4'b0100;
                    2'b11: FILAS <= 4'b1000;
                endcase
            end
        end
    end

    always_comb begin
        filas_mux = 4'b0000;
        if (SCOL != 4'b0000)
            filas_mux = FILAS;
    end

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            FILACOL <= 8'b00000000;
        end else begin
            FILACOL <= {filas_mux, SCOL};
        end
    end

	// decodificadro de filas y columnas, termina que tecla se activo
	// de acuera la FILA y la COLUMNA.

    always_comb begin
        case (FILACOL) // PRIMEROS 4 BITS LA FILA Y SEGUNDOS 4 BITS LA COLUMNA ACTIVAS.
            8'b00010001: tecla_detectada = 5'b00001; // 0(1)
            8'b00010010: tecla_detectada = 5'b00010; // 0(2)
            8'b00010100: tecla_detectada = 5'b00011; // 0(3)
				8'b00011000: tecla_detectada = 5'b01010; // 0(A)
				8'b00100001: tecla_detectada = 5'b00100; // 0(4)
				8'b00100010: tecla_detectada = 5'b00101; // 0(5)
				8'b00100100: tecla_detectada = 5'b00110; // 0(6)
				8'b00101000: tecla_detectada = 5'b01011; // 0(B)
				8'b01000001: tecla_detectada = 5'b00111; // 0(7)
				8'b01000010: tecla_detectada = 5'b01000; // 0(8)
				8'b01000100: tecla_detectada = 5'b01001; // 0(9)
				8'b01001000: tecla_detectada = 5'b01100; // 0(C)
				8'b10000001: tecla_detectada = 5'b01110; // 0(E)
				8'b10000010: tecla_detectada = 5'b00000; // 0(0)
				8'b10000100: tecla_detectada = 5'b01111; // 0(F)
				8'b10001000: tecla_detectada = 5'b01101; // 0(D)
            default:  tecla_detectada = 5'b10000;
        endcase
    end

    always_ff @(posedge clk or negedge rst) begin
        if (~rst) begin
            tecla_confirmada <= 5'b10000;
            tecla_presionada <= 1'b0;
            FLAG <= 1'b0;
        end else begin
            FLAG <= 1'b0;

            if (!tecla_presionada) begin
                if (b && (tecla_detectada != 5'b10000)) begin
                    tecla_confirmada <= tecla_detectada;
                    tecla_presionada <= 1'b1;
                    FLAG <= 1'b1;
                end
            end else begin
                if (b_release) begin
                    tecla_presionada <= 1'b0;
                end
            end
        end
    end

	 //
	 // Decodificador 7 segmentos (DISP[6:0] = g-a, DISP[7] = punto)
    always_comb begin
        case (tecla_confirmada)  // MUESTRA EL CÓDIGO DE LA TECLA DETECTADA EN EL DISPLAY.
            5'h00: DISP = 8'h30; // 0
            5'h01: DISP = 8'h31; // 1
            5'h02: DISP = 8'h32; // 2
            5'h03: DISP = 8'h33; // 3
            5'h04: DISP = 8'h34; // 4
            5'h05: DISP = 8'h35; // 5
            5'h06: DISP = 8'h36; // 6
            5'h07: DISP = 8'h37; // 7
            5'h08: DISP = 8'h38; // 8
            5'h09: DISP = 8'h39; // 9
            5'h0A: DISP = 8'h2B; // +
            5'h0B: DISP = 8'h2D; // -
            5'h0C: DISP = 8'h2F; // /
				5'h0D: DISP = 8'h2A;
				5'h0E: DISP = 8'h2E;
				5'h0F: DISP = 8'h20;
            default: DISP = 8'h20; //no hay ninguna tecla apretada (muestra solo el segmento g)
        endcase
    end

// salida del código de la tecla
assign TECLA = tecla_confirmada[3:0];

endmodule