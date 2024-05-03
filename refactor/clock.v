// time keeping circuit

// mclk: main clock, the clock from the module qlal4...( 20 MHz? )
//
// M_FREQ: main clock frequency, use this parameter to set main clock frequency
//         = 1/10/100 for testing, = 20 000 000 for vaman board ( make sure all time keeping registers are 64 bit wide )
//
// clk_mode:
//     == 0: if in default mode
//     == 1: if in set time mode
//     == 2: if in set alarm mode (any day alarm implementation?)
//     == 3: if in set date mode

// vButton: virtual buttons, HIGH(for 1 MCLK) when the physical button(pButton) goes from LOW to HIGH
//           sButton[0]: units digit, sButton[1]: tens digit, 
//          0-->button1, 1-->button2, 2-->button3, 3-->setampm

// bcd_time: time is 
//                  bcd_time[5] bcd_time[4] : bcd_time[3] bcd_time[2] : bcd_time[1] bcd_time[0]
//                      H           H       :     M           M       :     S           S
// weekday: 0: if ?? day to 7 if ?? day 
//
// year: year as: year[3] year[2] year[1] year[0] (year[i] is a bcd digit)
//                  2       0       2       4      = 2024
//
// buzzer: HIGH for 5 seconds after alarm went off otherwise LOW

module clock_top #(parameter M_FREQ = 1) (
    input wire mclk, input wire rst,
    input wire[1:0] clk_mode, input wire [3:0] vButton,
    output wire[23:0] bcd_time,
    output wire ampm, //0 --> AM, 1 --> PM
    output wire[2:0] weekday,
    output wire[23:0] date,
    output wire buzzer
);

reg clk1 = 0;
wire outtime;
wire [23:0] connectTime;
wire [23:0] alarm_time;
wire [23:0] clock_time;
wire [23:0] setDate;
wire [2:0] setWeekday;

//clock 1 Hz frequency
reg [31:0] counter; // 32-bit counter(Just in case the frequency is higher/lower) for 1Hz output from a 20MHz input clock

always @(posedge mclk) begin
    if (counter >= M_FREQ) begin // For 20MHz input clock
        counter <= 0;
        clk1 <= ~clk1; 
    end
    else begin
        counter <= counter + 1;
    end
end

//12-24 hour conversion
formattime d7 (.clk_mode(clk_mode), .setampm(vButton[3]), .clock_time(clock_time), .alarm_time(alarm_time), .bcd_time(bcd_time), .ampm(ampm));

//counter
settime d1 (.clk(mclk), .button1(vButton[0]), .button2(vButton[1]), .button3(vButton[2]), .set_mode(clk_mode), .hour1(connectTime[23:20]), .hour2(connectTime[19:16]), .min1(connectTime[15:12]), .min2(connectTime[11:8]), .sec1(connectTime[7:4]), .sec2(connectTime[3:0]));
clocktime d2 (.clk_1hz(clk1), .rst(rst), .clk_mode(clk_mode), .time_in(connectTime), .time_out(clock_time));  

//alarm
settime d4 (.clk(mclk), .button1(vButton[0]), .button2(vButton[1]), .button3(vButton[2]), .set_mode({clk_mode[0], clk_mode[1]}), .hour1(alarm_time[23:20]), .hour2(alarm_time[19:16]), .min1(alarm_time[15:12]), .min2(alarm_time[11:8]), .sec1(alarm_time[7:4]), .sec2(alarm_time[3:0]));
alarm d3 (.clk(mclk), .rst(rst), .alarm_mode(clk_mode), .in_time(bcd_time[23:8]), .ring(buzzer));

//date
setdate d6 (.clk(mclk), .button1(vButton[0]), .button2(vButton[1]), .button3(vButton[2]), .set_mode(clk_mode), .day1(setDate[23:20]), .day2(setDate[19:16]), .month1(setDate[15:12]), .month2(setDate[11:8]), .year1(setDate[7:4]), .year2(setDate[3:0]), .day(setWeekday));
datemodule d5 (.clk(mclk), .hour_in(clock_time[23:16]), .date_in(setDate), .weekday_in(setWeekday), .date_mode(clk_mode), .date_out(date), .weekday_out(weekday));

//timer


endmodule
