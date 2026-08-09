/*
 * Testbench to test the peripherals part
 */ 
module testbench_peripherals();
	logic clk;
	logic reset;
	logic [9:0] switches, leds;

	localparam DELAY = 10;
	
	// Variable para el bucle
	integer i;
	
	// instantiate device to be tested
	top dut(clk, reset, switches, leds);

	// initialize test
	initial
	begin
		// Inicialización y Reset
		switches <= 10'd0;
		reset <= 0; #(DELAY*9.5); 
		reset <= 1; 
		
		// Bucle para encender un switch a la vez (del 0 al 9)
		for (i = 0; i < 10; i = i + 1) begin
			switches <= (10'b1 << i);   // Desplaza el bit '1' a la posición 'i'
			#(DELAY*100);               // Espera 100 ciclos antes de mover el siguiente
		end
		
		// Apagar todos al final y terminar
		switches <= 10'd0;
		#(DELAY*10);
		$stop;
	end

	// generate clock to sequence tests
	always
	begin
		clk <= 1; #(DELAY/2); 
		clk <= 0; #(DELAY/2);
	end
endmodule