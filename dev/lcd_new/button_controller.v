
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

    reg led;

    qlal4s3b_cell_macro qlal4s3b_cell(.Sys_Clk0(clk));
    button_controller #(20000) lcd_disp_ctrl(.mclk(clk), .rst(reset), .pSetButton(~pSetButton), .pAlarmButton(~pAlarmButton), .pButton0(~pButton0), .pButton1(~pButton1), .vButton(vbutton), .clk_mode(mode));

    always @ (posedge clk) begin
        if(vbutton[0] || vbutton[1]) led <= ~led;
    end

    assign redled = mode[0];
    assign RS = mode[1];

endmodule

