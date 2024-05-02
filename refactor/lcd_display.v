// display the output using LCD controller

// mclk: main clock, the clock from the module qlal4...( 20 MHz? )
//
// M_FREQ: main clock frequency, use this paramter to set main clock frequency
//         = 1/10/100 for testing, = 20 000 000 for vaman board ( make sure all time keeping registers are 64 bit wide )
//
// clk_mode:
//     == 0: if in default mode
//     == 1: if in set time mode
//     == 2: if in set date mode
//     == 3: if in set alarm mode(any day alarm implementation?)
// 
// vButton: virtual buttons, HIGH(for 1 MCLK) when the physical button(pButton) goes from LOW to HIGH
//           sButton[0]: units digit, sButton[1]: tens digit, 
// 
// lineA: the first line of output on LCD display(lineA[0] is to the left most side of the display)
// lineB: the second line of output on LCD display
//         for maps from BCD/alphabets to LCD display charecter see the datasheet of KS0066 chip(Samsung) Pg 18 (shared in this repo)
// 
// buzzer: output from clock_top module
// 
module lcd_display_controller #(parameter M_FREQ = 1) (
    input wire mclk, input wire rst,
    input wire[1:0] clk_mode, input wire[1:0] vButton,
    output wire buzzer,
);

    reg[7:0] LineA[16];
    reg[7:0] LineB[16];

    // instantinate clock_top module(in clock.v) 
    // instantinate lcd_controller module(in clock.v) 

endmodule
