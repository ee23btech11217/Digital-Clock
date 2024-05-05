module button_sampler #(parameter SFREQ_KHZ = 1) (
    input wire mclk, input wire rst,
    input wire pSetButton, input wire pAlarmButton, input wire pTimerToggle0, input wire pTimerToggle1,
    input wire pButton0, input wire pButton1, input wire pButton2,
    output reg[6:0] sbutton
);

    reg[31:0] counter;

    always @ (posedge mclk) begin
        if(rst) begin
            counter <= 0;
            sbutton <= 0;
        end
        else if(counter >= SFREQ_KHZ) begin
            counter <= 0;
            sbutton <= { pButton0, pButton1, pButton2, pSetButton, pAlarmButton, pTimerToggle0, pTimerToggle1 };
        end
        else counter <= counter + 1;
    end

endmodule

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
module button_controller #(parameter MFREQ_KHZ = 1) (
    input wire mclk, input wire rst,
    input wire pSetButton, input wire pAlarmButton, input wire pTimerToggle0, input wire pTimerToggle1, 
    input wire pButton0, input wire pButton1, input wire pButton2,
    output reg[1:0] clk_mode, output reg[1:0] timer_mode, output reg[5:0] vButton
);
    wire sButton0;
    wire sButton1;
    wire sButton2;
    wire sSetButton;
    wire sAlarmButton;
    wire sTimerToggle0;
    wire sTimerToggle1;

    reg lsButton0;
    reg lsButton1;
    reg lsButton2;
    reg lsSetButton;
    reg lsAlarmButton;
    reg lsTimerToggle0;
    reg lsTimerToggle1;

    // Samples buttons every 5ms to prevent bouncing of inputs
    button_sampler #(MFREQ_KHZ*5) bsampler( 
        .mclk(mclk), .rst(rst), 
        .pSetButton(pSetButton), .pAlarmButton(pAlarmButton), 
        .pButton0(pButton0), .pButton1(pButton1), .pButton2(pButton2),
        .pTimerToggle0(pTimerToggle0), .pTimerToggle1(pTimerToggle1), 
        .sbutton({ sButton0, sButton1, sButton2, sSetButton, sAlarmButton, sTimerToggle0, sTimerToggle1 })
    );

    always @ (posedge mclk) begin

        // set vButton[0] on posedge of sButton0
        // if in default state toggle 12h mode
        if(sButton0 && !lsButton0) begin
            lsButton0 <= 1;
            if(clk_mode == 0 && timer_mode == 0) vButton[3] <= ~vButton[3];
            vButton[0] <= 1;
        end
        else if(!sButton0 && lsButton0) begin
            lsButton0 <= 0;
            vButton[0] <= 0;
        end
        else vButton[0] <= 0;

        // set vButton[1] on posedge of sButton0
        // if in default state toggle activate alarm
        if(sButton1 && !lsButton1) begin
            lsButton1 <= 1;
            if(clk_mode == 0 && timer_mode == 0) vButton[4] <= ~vButton[4];
            vButton[1] <= 1;
        end
        else if(!sButton1 && lsButton1) begin
            lsButton1 <= 0;
            vButton[1] <= 0;
        end
        else vButton[1] <= 0;

        // set vButton[2] on posedge of sButton0
        // if in default state toggle activate timer
        if(sButton2 && !lsButton2) begin
            lsButton2 <= 1;
            if(clk_mode == 0 && timer_mode == 0) vButton[5] <= ~vButton[5];
            vButton[2] <= 1;
        end
        else if(!sButton2 && lsButton2) begin
            lsButton2 <= 0;
            vButton[2] <= 0;
        end
        else vButton[2] <= 0;

        // change the mode on posedge of sTimerToggle0
        if(sTimerToggle0 && !lsTimerToggle0) begin
            lsTimerToggle0 <= 1;
            
            if(timer_mode == 0 && clk_mode == 0) timer_mode <= 1;
            if(timer_mode == 1 && clk_mode == 0) timer_mode <= 0;
        end
        else if(!sTimerToggle0 && lsTimerToggle0) begin
            lsTimerToggle0 <= 0;
        end
        // change the mode on posedge of sTimerToggle1
        if(sTimerToggle1 && !lsTimerToggle1) begin
            lsTimerToggle1 <= 1;
            
            if(timer_mode == 0 && clk_mode == 0) timer_mode <= 2;
            if(timer_mode == 2 && clk_mode == 0) timer_mode <= 0;
        end
        else if(!sTimerToggle1 && lsTimerToggle1) begin
            lsTimerToggle1 <= 0;
        end

        // change the mode on posedge of sSetButton
        if(sSetButton && !lsSetButton) begin
            lsSetButton <= 1;
            
            if(clk_mode == 0 && timer_mode == 0) clk_mode <= 1;
            else if(clk_mode == 1 && timer_mode == 0) clk_mode <= 3;
            else if(clk_mode == 3 && timer_mode == 0) clk_mode <= 0;
        end
        else if(!sSetButton && lsSetButton) begin
            lsSetButton <= 0;
        end

        // goto the alarm mode on posedge of sAlarmButton
        if(sAlarmButton && !lsAlarmButton) begin
            lsAlarmButton <= 1;
            
            if(clk_mode == 0 && timer_mode == 0) clk_mode <= 2;
            if(clk_mode == 2 && timer_mode == 0) clk_mode <= 0;
        end
        else if(!sAlarmButton && lsAlarmButton) begin
            lsAlarmButton <= 0;
        end
    end

endmodule

