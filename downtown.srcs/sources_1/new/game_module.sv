module game_module(input  logic        CLOCK,
                  input  logic        ball_trigger,
                  input  logic        game_reset,
                  output logic [23:0] row_Final,
                  output logic [7:0]  column_Final,
                  output logic [3:0]  AN,
                  output logic [6:0]  C,
                  output logic        DP);
    
    logic        FSMbool, FSMbool1, clk_FSM, clk_fin, clk_hoop, clk_ball, nextRound;
    logic [1:0]  state, nextstate;
    logic [23:0] row;
    logic [7:0]  column_HoopBottom, column_HoopTop;
    logic [3:0]  round;
    logic [3:0]  roundDigit;
    logic [3:0]  life;
    logic [1:0]  life_add;
    logic [3:0]  digitEnabler;
    logic [3:0]  digitFirst;
    logic [3:0]  digitSecond;
    logic [3:0]  digitThird;
    logic [3:0]  digitForth;
    logic [3:0]  score;
    
    integer reverse = 7;
    integer hoopColumn = 0;
    integer checkIt = 1;
    integer divide_finish = 0;
    integer ball = 10000000;
    integer hoop = 5000000;
    integer FSM = 300000;
    integer roundcount_one = 0;
    integer auto = 0;
    integer change = 0;
    
    assign column_Final = (nextRound || game_reset) ? 8'b11111111: (!FSMbool && !FSMbool1) ? column_HoopTop : (!FSMbool && FSMbool1) ? column_HoopBottom : 8'b00010000 ;
    assign row_Final = (nextRound || game_reset) ? 24'b11111111_00000000_11111111 :(!FSMbool && !FSMbool1) ? 24'b00000000_00000000_00000001 : (!FSMbool && FSMbool1) ? 24'b00000000_00000000_00000010 : row;
     
    display_controller dc(CLOCK, 0,digitEnabler, digitFirst, digitSecond, digitThird, digitForth,AN,C,DP);

    clk_divider dv1(CLOCK,ball,clk_ball);
    clk_divider dv2(CLOCK,hoop,clk_hoop);
    clk_divider dv3(CLOCK,FSM,clk_FSM);          
          
    initial
        begin
            
            digitSecond <= 4'b0000;
            digitThird <= 4'b0000;
            digitEnabler<=4'b1011;
            clk_ball <= 0;
            row <= 24'b10000000_00000000_00000000;
            column_HoopBottom <= 8'b00011000;
            column_HoopTop<= 8'b00011000;
            state <= 0;
            nextstate <= 0;
            FSMbool <= 0;
            clk_FSM <= 0;
            score <= 0;
            round<= 0;
            nextRound <= 0;
            clk_fin <= 0;
            clk_hoop <= 0;
            life <= 4;
        end

    always_comb

        state <= nextstate;
  
    
    always_ff @(posedge clk_FSM)
        begin
            
            if(digitThird >2 )
                    begin
                        digitEnabler <= 4'b1111;
                        digitFirst <= 4'b1101;
                        digitSecond <= 4'b1100;
                        digitThird <= 4'b1111;
                        digitForth <= 4'b1110;
                        
                    end
            if(digitThird< 3 || game_reset)
                begin
                    digitEnabler<=4'b1011;
                    digitFirst <= life;
                    digitThird <= round/2;
                    digitForth <= score;
                end
            
            case(state)
                0: begin nextstate <= 1; FSMbool <= 0; FSMbool1 <= 0; end
                1: begin nextstate <= 2; FSMbool <= 0; FSMbool1 <= 1; end
                2: begin nextstate <= 0; FSMbool <= 1; FSMbool1 <= 0; end
            endcase
        end
         
    
    always_ff @ (posedge clk_ball)
        begin   
            if(life_add == 2'b10) 
                begin
                    life<=life+1;
                    life_add<=0;
                end 
        
            if( (nextRound && life == 4'b0000) || game_reset)
                begin
                    score<=0;
                    round <= 0;
                    nextRound <= 0;
                    life<=3;
                end
                
            if(nextRound && life != 4'b0000)
                begin
                    score<=0;
                    round <= round +1;
                    nextRound <= 0;
                    life_add<=life_add+1;
                end
               
            if(reverse == 7)
                begin
                    row <= 24'b10000000_00000000_00000000;
                    reverse = 0;
                    if(3 == hoopColumn+1 && checkIt)
                        score <= score+1;
                    if(3 != hoopColumn+1 && checkIt)
                        life <= life -1;
                    if(life == 4'b0000)
                        nextRound <= 1;
                    if(score == 4'b0011)
                        nextRound <= 1;
                    if(!ball_trigger || nextRound || game_reset)
                        begin
                            checkIt = 0;
                            row <= 24'b10000000_00000000_00000000;
                            reverse = 7;
                        end
                end
            else
                begin
                    checkIt = 1;
                    row <= row>>1;
                    reverse = reverse +1;
                end

        end
      

    always_ff @ (posedge clk_hoop)
        begin
            if(roundcount_one > 8)
                roundcount_one =0;
            if(roundcount_one == 6 && round/2 == 0)
                begin
                    if(auto == 5)
                        change = 1;
                    if(auto == 0)
                        change = 0;
                    if(change)
                        begin
                            hoopColumn = hoopColumn - 1;
                            auto = auto -1; 
                            roundcount_one = 0;
                        end
                    else
                        begin
                            hoopColumn = hoopColumn + 1; 
                            auto = auto +1;
                            roundcount_one = 0;
                        end
                end
             
             if(roundcount_one == 4 && round/2 == 1)
                begin
                    if(auto == 5)
                        change = 1;
                    if(auto == 0)
                        change = 0;
                    if(change)
                        begin
                            hoopColumn = hoopColumn - 1;
                            auto = auto -1; 
                            roundcount_one = 0;
                        end
                    else
                        begin
                            hoopColumn = hoopColumn + 1; 
                            auto = auto +1;
                            roundcount_one = 0;
                        end
                end
                
              if(roundcount_one == 2 && round/2 == 2)
                begin
                    if(auto == 5)
                        change = 1;
                    if(auto == 0)
                        change = 0;
                    if(change)
                        begin
                            hoopColumn = hoopColumn - 1;
                            auto = auto -1; 
                            roundcount_one = 0;
                        end
                    else
                        begin
                            hoopColumn = hoopColumn + 1; 
                            auto = auto +1;
                            roundcount_one = 0;
                        end
                end
                
                
                    
              
             else
                roundcount_one = roundcount_one+1;
  
               
            case(hoopColumn)
                0:  begin column_HoopBottom <= 8'b11100000; column_HoopTop <= 8'b10100000; end 
                1:  begin column_HoopBottom <= 8'b01110000; column_HoopTop <= 8'b01010000; end 
                2:  begin column_HoopBottom <= 8'b00111000; column_HoopTop <= 8'b00101000; end 
                3:  begin column_HoopBottom <= 8'b00011100; column_HoopTop <= 8'b00010100; end 
                4:  begin column_HoopBottom <= 8'b00001110; column_HoopTop <= 8'b00001010; end  
                5:  begin column_HoopBottom <= 8'b00000111; column_HoopTop <= 8'b00000101; end  
            endcase
        end


      
    
              
endmodule
