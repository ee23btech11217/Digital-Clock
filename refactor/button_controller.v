// Manages button inputs

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
module button_controller #(parameter M_FREQ = 1) (
    input wire mclk, input wire rst,
    input wire pSetButton, input wire pAlarmButton, input wire pButton0, , input wire pButton1,  
    output wire[1:0] clk_mode, output wire[1:0] vButton,
);

endmodule

