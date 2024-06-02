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

/*
Current Code:
module lcd_display_controller #(parameter M_FREQ = 1, InsWaitTime = 16'd10, DataWaitTime = 10, RefreshTime = 320) (
    input wire mclk, input wire rst, input changeWeekday,
    output wire[7:0] DB, output wire RS, output wire E, output wire RW
//    input wire[1:0] clk_mode, input wire[1:0] vButton,
//    output wire buzzer,
);

    reg[127:0] lineA;
    reg[127:0] lineB;

    // EEE, Mon, Tue, Wed, Thu, Fri, Sat, Sun
    wire[63:0] weekdays0 = {8'h53, 8'h53, 8'h46, 8'h54, 8'h57, 8'h54, 8'h4d, 8'h45};
    wire[63:0] weekdays1 = {8'h75, 8'h61, 8'h72, 8'h68, 8'h65, 8'h75, 8'h6f, 8'h45};
    wire[63:0] weekdays2 = {8'h6e, 8'h74, 8'h69, 8'h75, 8'h64, 8'h65, 8'h6e, 8'h45};

    lcd_controller #(M_FREQ, InsWaitTime, DataWaitTime, RefreshTime) lcd_ctrl(.mclk(mclk), .rst(rst), .LineA(lineA), .LineB(lineB), .E(E), .RS(RS), .RW(RW), .DB(DB));

    reg[2:0] weekday;

    always @ (posedge mclk) begin
        if(rst) begin
            weekday <= 0;
            blatched <= 0;
            lineA <= {16{8'h20}};
            lineB <= {16{8'h20}};
        end
        if(changeWeekday) begin
            weekday <= weekday + 1;
        end
        else begin
            lineA <= { {13{8'h20}}, weekdays2[8*weekday+:8], weekdays1[8*weekday+:8], weekdays0[8*weekday+:8] };
        end
    end

endmodule
*/

