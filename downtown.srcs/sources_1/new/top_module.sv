module top_module(input  logic       CLOCK,
                 input  logic       game_reset,
                 input  logic       echo,
                 output logic       OE, //output enable
                 output logic       SH_CP, // shift register clock pulse
                 output logic       ST_CP, // store register clock pulse
                 output logic       reset, // reset for the shift register
                 output logic       DS, // digital signal
                 output logic [7:0] cathode,
                 output logic [3:0] AN,
                 output logic [6:0] C,
                 output logic       DP,
                 output logic       trig);
    
    logic [23:0] row;
    logic [7:0]  column;
	logic [24:1] message;
	logic [23:0] current;
	logic        clk_SHCP;
    logic        clk_STCP;
    logic [2:0]  a;
    logic [8:0]  serial_counter;
    logic        ball_trigger;
           
    assign message = current;
    assign clk_STCP = ~clk_SHCP;
    	
	game_module gm(CLOCK,ball_trigger,game_reset,row,column,AN,C,DP);
	ultrasonic_module um(CLOCK,echo,trig,ball_trigger);
    clk_divider dv(CLOCK,8,clk_SHCP);
               
    initial
	   begin 
	       current <= 24'b000000000000000000000000;
		   a <= 3'b000;
		   serial_counter <= 9'b00000001;
	   end
               
    always_ff @ (posedge clk_STCP)
            serial_counter = serial_counter+1;

    always_ff @ (serial_counter)
         begin
            if (serial_counter < 9'b000000100) 
                reset<=0;
            else
                reset<=1;
            if (serial_counter>9'b000000011 && serial_counter<9'b000011100) 
                DS<=message[serial_counter-9'b000000011];
            else
                DS<=0;
            if (serial_counter<9'b000011100) 
                begin
                    SH_CP<=clk_STCP;
                    ST_CP<=clk_SHCP;
                end
            else
                begin
                    SH_CP<=0;
                    ST_CP<=1;
                end
         end
         
    always_ff @ (posedge clk_SHCP)
        begin
            if (serial_counter==9'b110011110)
                a = a+1;
            if (serial_counter>9'b000011100 && serial_counter<9'b110011101)
                OE<=0;
            else
                OE<=1;
        end
   
    always_ff @ (a)
        begin
		    if (a==0) 
                begin
					current <= row;
                    cathode<=column;
                end
		end

endmodule