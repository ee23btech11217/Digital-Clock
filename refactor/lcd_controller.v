// The LCD controller

// Manage the LCD Display

// mclk: main clock, the clock from the module qlal4...( 20 MHz? )
//
// MFREQ_KHZ: main clock frequency in KHz, use this paramter to set main clock frequency(uses this to measure time in ms)
//         = 1/10/100 for testing, = 20 000 for vaman board ( make sure all time keeping registers are 64 bit wide )
//
// LineA: the first line of output on LCD display(lineA[0] is to the left most side of the display)
// LineB: the second line of output on LCD display
//         for maps from BCD/alphabets to LCD display charecter see the datasheet of KS0066 chip(Samsung) Pg 18 (shared in this repo)
// 
// DB, RS, RW, E: output to the lcd display 
//
module lcd_controller #(parameter MFREQ_KHZ = 1, InsWaitTime = 10, DataWaitTime = 10, RefreshTime = 320)(
    input wire mclk, input wire rst,
    input wire LineA[16], input wire LineB[16],
    output wire[7:0] DB, output reg RS, output reg E, output reg RW
);

endmodule

