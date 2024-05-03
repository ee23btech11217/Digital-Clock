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
module lcd_display_controller #(parameter M_FREQ = 1, InsWaitTime = 16'd10, DataWaitTime = 10, RefreshTime = 320) (
    input wire mclk, input wire rst, 
    output wire[7:0] DB, output wire RS, output wire E, output wire RW,
    input wire[1:0] clk_mode, input wire[1:0] vButton,
    output wire buzzer,
);

    reg[127:0] lineA;
    reg[127:0] lineB;

    wire[23:0] bcd_time;
    wire am_pm;
    wire[2:0] weekday;
    wire[23:0] date;

    // EEE, Mon, Tue, Wed, Thu, Fri, Sat, Sun
    wire[63:0] weekdays0 = {8'h45, 8'h53, 8'h53, 8'h46, 8'h54, 8'h57, 8'h54, 8'h4d};
    wire[63:0] weekdays1 = {8'h45, 8'h75, 8'h61, 8'h72, 8'h68, 8'h65, 8'h75, 8'h6f};
    wire[63:0] weekdays2 = {8'h45, 8'h6e, 8'h74, 8'h69, 8'h75, 8'h64, 8'h65, 8'h6e};

    lcd_controller #(M_FREQ, InsWaitTime, DataWaitTime, RefreshTime) lcd_ctrl(.mclk(mclk), .rst(rst), .LineA(lineA), .LineB(lineB), .E(E), .RS(RS), .RW(RW), .DB(DB));
    clock_top #(2000) clk_top(.mclk(mclk), .rst(rst), .clk_mode(clk_mode), .vButton({1'b0, 1'b0, vButton[1:0]}), .bcd_time(bcd_time), .ampm(am_pm), .weekday(weekday), .date(date), .buzzer(buzzer));

    wire[23:0] week_disp = {weekdays2[8*weekday+:8], weekdays1[8*weekday+:8], weekdays0[8*weekday+:8]};

    wire[71:0] date_disp = { 
        8'h2c, {4'b0011, date[ 3: 0]}, {4'b0011, date[ 7: 4]}, 
        8'h2d, {4'b0011, date[11: 8]}, {4'b0011, date[15:12]},
        8'h2d, {4'b0011, date[19:16]}, {4'b0011, date[23:20]}
    };

    wire[71:0] time_disp = { 
        8'h20, {4'b0011, bcd_time[ 3: 0]}, {4'b0011, bcd_time[ 7: 4]}, 
        8'h3a, {4'b0011, bcd_time[11: 8]}, {4'b0011, bcd_time[15:12]}, 
        8'h3a, {4'b0011, bcd_time[19:16]}, {4'b0011, bcd_time[23:20]}  
    };

    always @ (posedge mclk) begin
        if(rst) begin
            weekday <= 0;
            blatched <= 0;
            lineA <= {16{8'h20}};
            lineB <= {16{8'h20}};
        end
        else begin
            lineA <= { {4{8'h20}}, week_disp[23:0], date_disp[71:0] };
            lineB <= { {7{8'h20}}, time_disp[71:0] };
        end
    end

endmodule


