module test_lcd_ctrl(
    input wire rst, output wire redled,
    input wire pSetButton, input wire pAlarmButton, input wire pButton0, input wire pButton1,
    output wire RS, output wire E, output wire RW,
    output wire LCD_DB0,
    output wire LCD_DB1,
    output wire LCD_DB2,
    output wire LCD_DB3,
    output wire LCD_DB4,
    output wire LCD_DB5,
    output wire LCD_DB6,
    output wire LCD_DB7
);

    reg reset = 0;
    wire clk;
    wire[1:0] vbutton;
    wire[1:0] mode;

    qlal4s3b_cell_macro qlal4s3b_cell(.Sys_Clk0(clk));
    button_controller #(20000) bctrl(.mclk(clk), .rst(reset), .pSetButton(~pSetButton), .pAlarmButton(~pAlarmButton), .pButton0(~pButton0), .pButton1(~pButton1), .vButton(vbutton), .clk_mode(mode));
    lcd_display_controller #(20000, 5, 2, 2) lcd_disp_ctrl(.mclk(clk), .rst(reset), .E(E), .RS(RS), .RW(RW), .DB({LCD_DB7, LCD_DB6, LCD_DB5, LCD_DB4, LCD_DB3, LCD_DB2, LCD_DB1, LCD_DB0}),
                                                            .vButton(vButton), .clk_mode(mode));

    assign redled = vbutton[0];

endmodule