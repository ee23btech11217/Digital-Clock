
module interrupt_controller #(parameter MFREQ_KHZ = 1, parameter REPEAT = 0) (input wire mclk, input wire rst, input wire raiseInterrupt, input wire[15:0] delay_ms, output reg interrupt);

    reg[63:0] clk_counter = 0;
    reg[16:0] ms_counter = 0;
    reg upCount = 0;
    reg rIntLatched = 0;

    always @ (posedge mclk) begin
        if(rst) begin
            clk_counter <= 0;
            ms_counter <= 0;
            upCount <= 0;
            interrupt <= 0;
            rIntLatched <= 0;
        end
        else if(raiseInterrupt && !rIntLatched) begin
            upCount <= 1;
            rIntLatched <= 1;
            ms_counter <= 0;
            clk_counter <= 0;
        end
        else if(clk_counter >= MFREQ_KHZ) begin
            clk_counter <= 0;
            ms_counter <= ms_counter + upCount;

            if(ms_counter >= delay_ms - 1) begin
                interrupt <= 1;
                ms_counter <= 0;
                if(REPEAT == 0) upCount <= 0;
            end
        end
        else clk_counter <= clk_counter + 1;

        if(!raiseInterrupt && rIntLatched) rIntLatched <= 0;

        if(interrupt && !rst) interrupt <= 0;
    end

endmodule

module test_ic(input wire rst, output wire redled);

    reg reset;
    wire clk;

    reg[15:0] counter = 0;

    qlal4s3b_cell_macro qlal4s3b_cell(.Sys_Clk0(clk));

    interrupt_controller #(20000000, 0) int_ctrl(.mclk(clk), .rst(1'b0), .raiseInterrupt(counter[12]), .delay_ms(16'd2), .interrupt(redled));

    always @ (posedge clk) begin
        counter <= counter + (1 & ~rst);
    end

endmodule


