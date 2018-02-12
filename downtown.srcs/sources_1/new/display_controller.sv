module display_controller (
		input logic clk, clear,
		input logic [3:0] enables, 
		input logic [3:0] digit3, digit2, digit1, digit0,
		output logic [3:0] AN,
		output logic [6:0] C,
		output logic DP
		);


// internal signals ("wires") are defined here

		logic [3:0] current_digit, cur_dig_AN;
		logic [6:0] Cments;


// the outputs are all continuously assigned

	assign AN = ~(enables & cur_dig_AN);// AN signals are active low,
                                	// and must be enabled to display digit

      	assign C = ~Cments;     	// since the C values are active low

      	assign DP = 1;            	// the dot point is always off 
                                	// (0 = on, since it is active low)
		

// the 19-bit counter, runs at 100 MHz, so bit17 changes each 1.3 millisecond

	
	logic [18:0] count, nextcount;

	always_ff @(posedge clk)
		if(clear) count <= 0;
		else count <= nextcount;

	always_comb
		nextcount = count + 1;
	
	
// the upper 2 bits of the counter cycle through the digits and the AN patterns
			
	always_comb
	   case (count[18:17])
                // left most is AN3  
		2'b00: begin current_digit = digit3; cur_dig_AN = 4'b1000; end  
		2'b01: begin current_digit = digit2; cur_dig_AN = 4'b0100; end
		2'b10: begin current_digit = digit1; cur_dig_AN = 4'b0010; end
		2'b11: begin current_digit = digit0; cur_dig_AN = 4'b0001; end
                // right most is AN0
	   endcase	   
	   

// the hex-to-7-Cment decoder
	always_comb
		case (current_digit)
		4'b0000: Cments = 7'b0111111;  // 0
		4'b0001: Cments = 7'b0000110;  // 1
		4'b0010: Cments = 7'b1011011;  // 2
		4'b0011: Cments = 7'b1001111;  // 3
		4'b0100: Cments = 7'b1100110;  // 4
		4'b0101: Cments = 7'b1101101;  // 5
		4'b0110: Cments = 7'b1111101;  // 6
		4'b0111: Cments = 7'b0000111;  // 7
		4'b1000: Cments = 7'b1111111;  // 8
		4'b1001: Cments = 7'b1101111;  // 9
		4'b1010: Cments = 7'b111_0111;  // A
		4'b1011: Cments = 7'b111_1100;  // b
		4'b1100: Cments = 7'b101_1100;  // o
		4'b1101: Cments = 7'b101_1110;  // d
		4'b1110: Cments = 7'b111_1001;  // E
		4'b1111: Cments = 7'b101_0100;  // n
		default: Cments = 7'bxxx_xxxx;
		endcase		


		
endmodule
