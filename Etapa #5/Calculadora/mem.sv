module mem #(parameter WIDTH=32, DEPTH=4096)(input logic clk, reset, we2, input logic [WIDTH-1:0] a1, a2, wd, output logic [WIDTH-1:0] rd1, rd2, input logic [9:0] switches, output logic [9:0] leds);
	
	localparam addr_bits = $clog2(DEPTH); 
	
	logic [WIDTH-1:0] rd, q_a;
	logic [addr_bits-1:0] addr_A, addr_B;
	logic we, led_in, switches_in;
	logic keyboard_in, lcd_in, peripheral_in;
	
	
	altsyncram #(
		.OPERATION_MODE("BIDIR_DUAL_PORT"),
		.INIT_FILE("mem.mif"),
		
		.WIDTH_A(WIDTH),
		.WIDTHAD_A(addr_bits),
		
		.WIDTH_B(WIDTH),
		.WIDTHAD_B(addr_bits)
	) 
	u_mem(
		.clock0(clk),
		.address_a(addr_A),
		.q_a(q_a),
	
		.clock1(~clk),
		.address_b(addr_B),
		.wren_b(we),
		.data_b(wd),
		.q_b(rd)
	);
	

	always_comb begin
		
		if(reset) begin
			addr_A = '0;
			addr_B = '0;
			we = 1'b0;
			rd1 = '0;
		end
		else  begin
			addr_B = a2[addr_bits+1:2];
			addr_A = a1[addr_bits+1:2];
			we = (peripheral_in) ? 1'b0 : we2;
			rd1 = q_a;
		end
	end
	
	assign led_in      = (a2 == 32'hFF20_0000) && we2;
	assign switches_in = (a2 == 32'hFF20_0040);

	assign keyboard_in = (a2 == 32'hFF20_0100) ||
	                     (a2 == 32'hFF20_0104) ||
	                     (a2 == 32'hFF20_0108) ||
	                     (a2 == 32'hFF20_010C);

	assign lcd_in      = (a2 == 32'hFF20_0200) ||
	                     (a2 == 32'hFF20_0204) ||
	                     (a2 == 32'hFF20_0208);

	assign peripheral_in = ((a2 == 32'hFF20_0000) || switches_in || keyboard_in || lcd_in) && we2;

	always_comb
		if (switches_in)
			rd2 = {22'b0, switches};
		else
			rd2 = rd; 
			 
	always_ff @(posedge clk)
		if (led_in)
			leds <= wd[9:0];
endmodule
