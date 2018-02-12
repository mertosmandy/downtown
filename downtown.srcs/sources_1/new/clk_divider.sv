module clk_divider(input  logic clk,
                   input  integer divide,
                   output logic o_clk);

    integer counter = 0;

    always_ff @ (posedge clk)
        if(counter == divide)
            begin
                o_clk <= ~o_clk;
                counter = 0;
            end
        else
            counter = counter +1;
endmodule
