// time keeping circuit

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
// bcd_time: time is 
//                  bcd_time[5] bcd_time[4] : bcd_time[3] bcd_time[2] : bcd_time[1] bcd_time[0]
//                      H           H       :     M           M       :     S           S
// weekday: 0: if ?? day to 7 if ?? day 
//
// year: year as: year[3] year[2] year[1] year[0] (year[i] is a bcd digit)
//                  2       0       2       4      = 2024
//
// buzzer: HIGH for 5 seconds after alarm went off otherwise LOW
// 
module clock_top #(parameter M_FREQ = 1) (
    input wire mclk, input wire rst,
    input wire[1:0] clk_mode, input wire[1:0] vButton,
    output wire[3:0] bcd_time[6],
    output wire[2:0] weekday,
    output wire[3:0] year[4],
    output wire buzzer,
);

    ;

endmodule
