// Manages interrupts
// Used to manage timings in lcd_controller

// mclk: main clock, the clock from the module qlal4...( 20 MHz? )
//
// MFREQ_KHZ: main clock frequency in KHz, use this paramter to set main clock frequency(uses this to measure time in ms)
//         = 1/10/100 for testing, = 20 000 for vaman board ( make sure all time keeping registers are 64 bit wide )
// 
// raiseInterrupt: Raise a interrupt [delay_ms] ms after raiseInterrupt went high
// 
// interrupt: interrupt line, raised high after [delay_ms] ms raiseInterrupt posedge
// 
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
