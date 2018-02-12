module ultrasonic_module( input  logic clk,
               input  logic echo,
               output logic trig,
               output logic ball_trigger
               );
               
    integer timer; // timer of the measurement cycle
    integer counter; // counts to the 5876 to get 1 cm distance value
    integer temp_distance;
    integer distance;
    logic measure; // it is used to check that if echo is started or not
    logic o_clk;
    
    clk_divider dv(clk,16384,o_clk);
    
    initial
        begin
            distance <=20;
        end
              
    always_ff@( posedge clk) 
        begin
            timer <= timer + 1;
            if( timer >= 6000000) // if timer has reached 60 ms, sets output and resets temp_num, temp_distance, and timer
                begin
                    distance <= temp_distance;  
                    temp_distance <= 0;
                    timer <= 0;
                end
                            
            if( timer >= 0 && timer < 1000) // 10 microsecond trig signal
                trig <= 1;
            else
                trig <= 0; 
                     
            if( !echo) // resets measure
                measure <= 0;
            else
                begin
                    if( !measure) // resets counter
                        begin
                            measure <= 1;
                            counter <= 0;
                        end
                    else
                        begin
                            if( counter < 5876) // 58 microsecond = 1 cm
                                begin
                                    counter <= counter + 1;
                                end
                            else 
                                begin
                                    counter <= 0;
                                    temp_distance <= temp_distance + 1;
                                end            
                           
                        end
                end                        
        end
        
        
    always_ff @(posedge o_clk)
        begin
            if (distance < 6)
                ball_trigger <=1;
            else
                ball_trigger <=0;
        end
endmodule               