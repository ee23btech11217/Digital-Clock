module test_lcd_ctrl(
    input wire rst, output wire redled,
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

    qlal4s3b_cell_macro qlal4s3b_cell(.Sys_Clk0(clk));

    assign redled = ~rst;
    assign RS =      ~rst;
    assign RW =      ~rst;
    assign E =       ~rst;
    assign LCD_DB0 = ~rst;
    assign LCD_DB1 = ~rst;
    assign LCD_DB2 = ~rst;
    assign LCD_DB3 = ~rst;
    assign LCD_DB4 = ~rst;
    assign LCD_DB5 = ~rst;
    assign LCD_DB6 = ~rst;
    assign LCD_DB7 = ~rst;

endmodule