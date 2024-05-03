
module lcd_display_controller #(parameter M_FREQ = 1, InsWaitTime = 16'd10, DataWaitTime = 10, RefreshTime = 320) (
    input wire mclk, input wire rst, input changeWeekday,
    output wire[7:0] DB, output wire RS, output wire E, output wire RW
//    input wire[1:0] clk_mode, input wire[1:0] vButton,
//    output wire buzzer,
);

    reg[127:0] lineA;
    reg[127:0] lineB;

    // EEE, Mon, Tue, Wed, Thu, Fri, Sat, Sun
    wire[63:0] weekdays0 = {8'h53, 8'h53, 8'h46, 8'h54, 8'h57, 8'h54, 8'h4d, 8'h00};
    wire[63:0] weekdays1 = {8'h75, 8'h61, 8'h72, 8'h68, 8'h65, 8'h75, 8'h6f, 8'h00};
    wire[63:0] weekdays2 = {8'h6e, 8'h74, 8'h69, 8'h75, 8'h64, 8'h65, 8'h6e, 8'h00};

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

module button_sampler #(parameter SFREQ_KHZ = 1) (
    input wire mclk, input wire rst,
    input wire pSetButton, input wire pAlarmButton, input wire pButton0, input wire pButton1,
    output reg[3:0] sbutton
);

    reg[31:0] counter;

    always @ (posedge mclk) begin
        if(rst) begin
            counter <= 0;
            sbutton <= 0;
        end
        else if(counter >= SFREQ_KHZ) begin
            counter <= 0;
            sbutton <= { pButton0, pButton1, pSetButton, pAlarmButton };
        end
        else counter <= counter + 1;
    end

endmodule

module button_controller #(parameter MFREQ_KHZ = 1) (
    input wire mclk, input wire rst,
    input wire pSetButton, input wire pAlarmButton, input wire pButton0, input wire pButton1,
    output reg[1:0] clk_mode, output reg[1:0] vButton,
);
    wire sButton0;
    wire sButton1;
    wire sSetButton;
    wire sAlarmButton;

    reg lsButton0;
    reg lsButton1;
    reg lsSetButton;
    reg lsAlarmButton;

    button_sampler #(MFREQ_KHZ*5) bsampler( .mclk(mclk), .rst(rst), .pSetButton(pSetButton), .pAlarmButton(pAlarmButton), .pButton0(pButton0), .pButton1(pButton1), .sbutton({ sButton0, sButton1, sSetButton, sAlarmButton }) );

    always @ (posedge mclk) begin
        if(sButton0 && !lsButton0) begin
            lsButton0 <= 1;
            vButton[0] <= 1;
        end
        else if(!sButton0 && lsButton0) begin
            lsButton0 <= 0;
            vButton[0] <= 0;
        end
        else vButton[0] <= 0;

        if(sButton1 && !lsButton1) begin
            lsButton1 <= 1;
            vButton[1] <= 1;
        end
        else if(!sButton1 && lsButton1) begin
            lsButton1 <= 0;
            vButton[1] <= 0;
        end
        else vButton[1] <= 0;

        if(sSetButton && !lsSetButton) begin
            lsSetButton <= 1;
            
            if(clk_mode == 0) clk_mode <= 1;
            else if(clk_mode == 1) clk_mode <= 2;
            else if(clk_mode == 2) clk_mode <= 0;
        end
        else if(!sSetButton && lsSetButton) begin
            lsSetButton <= 0;
        end

        if(sAlarmButton && !lsAlarmButton) begin
            lsAlarmButton <= 1;
            
            if(clk_mode == 0) clk_mode <= 3;
            if(clk_mode == 3) clk_mode <= 0;
        end
        else if(!sAlarmButton && lsAlarmButton) begin
            lsAlarmButton <= 0;
        end

    end

endmodule

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

    //reg[15:0] counter = 0;

    qlal4s3b_cell_macro qlal4s3b_cell(.Sys_Clk0(clk));
    button_controller #(20000) bctrl(.mclk(clk), .rst(reset), .pSetButton(~pSetButton), .pAlarmButton(~pAlarmButton), .pButton0(~pButton0), .pButton1(~pButton1), .vButton(vbutton), .clk_mode(mode));
    lcd_display_controller #(200000, 4, 2, 2) lcd_disp_ctrl(.mclk(clk), .rst(reset), .changeWeekday(vbutton[0]), .E(E), .RS(RS), .RW(RW), .DB({LCD_DB7, LCD_DB6, LCD_DB5, LCD_DB4, LCD_DB3, LCD_DB2, LCD_DB1, LCD_DB0}));

    assign redled = ~rst;

    //always @ (posedge clk) begin
    //    counter <= counter + (1 & ~rst);
    //end

endmodule

