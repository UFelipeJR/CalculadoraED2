/*
 * Keyboard MMIO
 * Conecta el driver_teclado al bus del procesador.
 *
 * Direcciones:
 * 0xFF20_0100 -> KEY_DATA   lectura: codigo de tecla 0-F
 * 0xFF20_0104 -> KEY_FLAG   lectura: 1 si hay tecla pendiente
 * 0xFF20_0108 -> KEY_ASCII  lectura: ASCII de la tecla
 * 0xFF20_010C -> KEY_CLEAR  escritura: limpia la bandera
 */

module keyboard_mmio #(
    parameter int TOPVALUE = 50_000_000
)(
    input  logic        clk,
    input  logic        reset_n,

    // Bus desde CPU
    input  logic [31:0] DataAdr,
    input  logic [31:0] WriteData,
    input  logic        MemWrite,

    output logic [31:0] ReadData,
    output logic        selected,

    // Pines físicos del teclado
    input  logic [3:0]  COLUMNAS,
    output logic [3:0]  FILAS,

    // Debug opcional
    output logic [3:0]  tecla_debug,
    output logic [7:0]  ascii_debug,
    output logic        key_valid_debug
);

    localparam logic [31:0] KEY_DATA  = 32'hFF20_0100;
    localparam logic [31:0] KEY_FLAG  = 32'hFF20_0104;
    localparam logic [31:0] KEY_ASCII = 32'hFF20_0108;
    localparam logic [31:0] KEY_CLEAR = 32'hFF20_010C;

    logic [3:0] tecla_raw;
    logic       flag_raw;
    logic [7:0] ascii_raw;

    logic [3:0] tecla_latched;
    logic [7:0] ascii_latched;
    logic       key_valid;

    // Selección general del periférico teclado
    assign selected = (DataAdr == KEY_DATA)  ||
                      (DataAdr == KEY_FLAG)  ||
                      (DataAdr == KEY_ASCII) ||
                      (DataAdr == KEY_CLEAR);

    driver_teclado #(
        .TOPVALUE(TOPVALUE)
    ) u_teclado (
        .clk(clk),
        .rst(reset_n),
        .COLUMNAS(COLUMNAS),
        .FILAS(FILAS),
        .TECLA(tecla_raw),
        .FLAG(flag_raw),
        .DISP(ascii_raw)
    );

    // Guardar la tecla cuando el driver genera FLAG
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            tecla_latched <= 4'h0;
            ascii_latched <= 8'h00;
            key_valid     <= 1'b0;
        end else begin
            if (flag_raw) begin
                tecla_latched <= tecla_raw;
                ascii_latched <= ascii_raw;
                key_valid     <= 1'b1;
            end

            // La CPU limpia la bandera escribiendo en KEY_CLEAR
            if (MemWrite && (DataAdr == KEY_CLEAR)) begin
                key_valid <= 1'b0;
            end
        end
    end

    // Lectura desde CPU
    always_comb begin
        case (DataAdr)
            KEY_DATA:  ReadData = {28'b0, tecla_latched};
            KEY_FLAG:  ReadData = {31'b0, key_valid};
            KEY_ASCII: ReadData = {24'b0, ascii_latched};
            default:   ReadData = 32'b0;
        endcase
    end

    assign tecla_debug     = tecla_latched;
    assign ascii_debug     = ascii_latched;
    assign key_valid_debug = key_valid;

endmodule