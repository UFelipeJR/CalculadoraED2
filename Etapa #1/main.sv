module main(
    input  logic       reloj,
    input  logic       rst,
    input  logic       btn_error,
    input  logic [3:0] COLUMNAS,
    output logic [3:0] FILAS,
    output logic       rw,
    output logic       rs,
    output logic       e,
    output logic [7:0] lcd_data
);

    logic [3:0] tecla;
    logic       flag;
    logic [7:0] ascii_tecla;

    logic [127:0] line1_buffer;
    logic [127:0] line2_buffer;

    logic flag_d;
    logic btn_error_d;
    logic [4:0] pos;

    driver_teclado u_teclado (
        .clk(reloj),
        .rst(rst),
        .COLUMNAS(COLUMNAS),
        .FILAS(FILAS),
        .TECLA(tecla),
        .FLAG(flag),
        .DISP(ascii_tecla)
    );

    driver_lcd #(.freq(1000)) u_lcd (
        .clk(reloj),
        .reset_n(rst),
        .rw(rw),
        .rs(rs),
        .e(e),
        .lcd_data(lcd_data),
        .line1_buffer(line1_buffer),
        .line2_buffer(line2_buffer)
    );

    always_ff @(posedge reloj) begin
        if (!rst) begin
            line1_buffer <= {
                8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,
                8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20
            };
            line2_buffer <= {
                8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,
                8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20
            };
            pos         <= 5'd0;
            flag_d      <= 1'b0;
            btn_error_d <= 1'b1;
        end else begin
            flag_d <= flag;
            btn_error_d <= btn_error;

            if (!btn_error && btn_error_d) begin
                line1_buffer <= {
                    8'h45,8'h52,8'h52,8'h4F,8'h52,8'h20,8'h20,8'h20,
                    8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20
                };
                line2_buffer <= {
                    8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,
                    8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20
                };
                pos <= 5'd0;
            end else if (flag && !flag_d) begin
                if (tecla == 4'hF) begin
                    if (pos > 0 && pos <= 16) begin
                        line1_buffer[(16-pos)*8 +: 8] <= 8'h20;
                        pos <= pos - 1'b1;
                    end else if (pos > 16 && pos <= 32) begin
                        line2_buffer[(32-pos)*8 +: 8] <= 8'h20;
                        pos <= pos - 1'b1;
                    end
                end else begin
                    if (pos < 16) begin
                        line1_buffer[(15-pos)*8 +: 8] <= ascii_tecla;
                        pos <= pos + 1'b1;
                    end else if (pos < 32) begin
                        line2_buffer[(31-pos)*8 +: 8] <= ascii_tecla;
                        pos <= pos + 1'b1;
                    end else begin
                        pos <= 5'd0;
                    end
                end
            end
        end
    end

endmodule



module tb_driver_lcd;

logic clk;
logic reset_n;

logic rw;
logic rs;
logic e;
logic [7:0] lcd_data;

logic [127:0] line1_buffer;
logic [127:0] line2_buffer;

driver_lcd #(.freq(1)) dut (
    .clk(clk),
    .reset_n(reset_n),
    .rw(rw),
    .rs(rs),
    .e(e),
    .lcd_data(lcd_data),
    .line1_buffer(line1_buffer),
    .line2_buffer(line2_buffer)
);

initial clk = 0;
always #10 clk = ~clk;

initial begin
    reset_n = 0;
    #100;
    reset_n = 1;
end

initial begin
    line1_buffer = {
        8'h48,8'h45,8'h4C,8'h4C,
        8'h4F,8'h20,8'h57,8'h4F,
        8'h52,8'h4C,8'h44,8'h20,
        8'h20,8'h20,8'h20,8'h20
    };

    line2_buffer = {
        8'h48,8'h4F,8'h4C,8'h41,
        8'h20,8'h4D,8'h55,8'h4E,
        8'h44,8'h4F,8'h20,8'h20,
        8'h20,8'h20,8'h20,8'h20
    };
end

initial begin
    #50000000;
    $stop;
end

endmodule


module tb_Driver_Teclado;

    parameter int TOPVALUE = 50_000;

    localparam int DELAY_10MS     = TOPVALUE / 100;
    localparam int HOLD_CYCLES    = 20 * DELAY_10MS;
    localparam int RELEASE_CYCLES = 4 * DELAY_10MS;

    logic clk;
    logic rst;
    logic [3:0] columnas;
    logic [3:0] filas;
    logic [3:0] tecla;
    logic flag;
    logic [7:0] disp;

    integer f;
    integer c;

    driver_teclado #(
        .TOPVALUE(TOPVALUE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .COLUMNAS(columnas),
        .FILAS(filas),
        .TECLA(tecla),
        .FLAG(flag),
        .DISP(disp)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    function automatic [3:0] fila_mask;
        input integer fila;
        begin
            case (fila)
                0: fila_mask = 4'b0001;
                1: fila_mask = 4'b0010;
                2: fila_mask = 4'b0100;
                3: fila_mask = 4'b1000;
                default: fila_mask = 4'b0000;
            endcase
        end
    endfunction

    task automatic presionar_tecla;
        input integer fila;
        input integer col;
        reg [3:0] fila_objetivo;
        reg detectada;
        integer k;
        begin
            fila_objetivo = fila_mask(fila);
            detectada = 1'b0;

            $display("Probando fila=%0d col=%0d", fila, col);

            for (k = 0; k < HOLD_CYCLES; k = k + 1) begin
                @(posedge clk);
                columnas = 4'b0000;
                if (filas == fila_objetivo)
                    columnas[col] = 1'b1;

                if (flag && !detectada) begin
                    detectada = 1'b1;
                    $display("Resultado fila=%0d col=%0d -> FILAS=%b COLUMNAS=%b TECLA=%h DISP=%h t=%0t",
                             fila, col, filas, columnas, tecla, disp, $time);
                end
            end

            columnas = 4'b0000;

            if (!detectada)
                $display("Resultado fila=%0d col=%0d -> sin deteccion", fila, col);

            for (k = 0; k < RELEASE_CYCLES; k = k + 1)
                @(posedge clk);
        end
    endtask

    initial begin
        $display("Inicio de simulacion");

        rst = 1'b0;
        columnas = 4'b0000;

        repeat (10) @(posedge clk);
        rst = 1'b1;

        repeat (1000) @(posedge clk);

        for (f = 0; f < 4; f = f + 1) begin
            for (c = 0; c < 4; c = c + 1) begin
                presionar_tecla(f, c);
            end
        end

        repeat (1000) @(posedge clk);

        $display("Fin de simulacion");
        $stop;
    end

endmodule

