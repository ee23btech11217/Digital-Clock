module test_lcd_ctrl(
    input wire rst, output wire redled, output wire dbg_l2, output wire dbg_l3, output wire dbg_l4,
    input wire pSetButton, input wire pAlarmButton, input wire pTimerToggle0, input wire pTimerToggle1, 
    input wire pButton0, input wire pButton1, input wire pButton2,
    output wire RS, output wire E, output wire RW,
    output wire LCD_DB0,
    output wire LCD_DB1,
    output wire LCD_DB2,
    output wire LCD_DB3,
    output wire LCD_DB4,
    output wire LCD_DB5,
    output wire LCD_DB6,
    output wire LCD_DB7,
    output wire buzzer
);

    reg reset = 0;
    wire clk;
    wire[5:0] vButton;
    wire[1:0] mode;
    wire[1:0] timer_mode;
    wire[4:0] tmpLED;
    reg led;

    qlal4s3b_cell_macro qlal4s3b_cell(.Sys_Clk0(clk));
    button_controller #(20000) bctrl(
        .mclk(clk), .rst(reset), 
        .pSetButton(~pSetButton), .pAlarmButton(~pAlarmButton), .pTimerToggle0(~pTimerToggle0), .pTimerToggle1(~pTimerToggle1), 
        .pButton0(~pButton0), .pButton2(~pButton2), .pButton1(~pButton1), 
        .vButton(vButton), .clk_mode(mode), .timer_mode(timer_mode)
    );

    lcd_display_controller #(10000, 5, 2, 2) lcd_disp_ctrl(
        .mclk(clk), .rst(reset), 
        .E(E), .RS(RS), .RW(RW), 
        .DB({LCD_DB7, LCD_DB6, LCD_DB5, LCD_DB4, LCD_DB3, LCD_DB2, LCD_DB1, LCD_DB0}),
        .vButton(vButton), .clk_mode(mode), .timer_mode(timer_mode), 
        .dbg_led(tmpLED),
        .buzzer(buzzer)
    );

    always @ (posedge clk) begin
        if(vButton[0]) begin
            led <= ~led;
        end
    end

    assign redled = vButton[4];
    assign dbg_l2 = vButton[5];
    assign dbg_l3 = timer_mode[0];
    assign dbg_l4 = timer_mode[1];

endmodule