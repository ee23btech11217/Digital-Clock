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

    // Samples buttons every 5ms to prevent bouncing of inputs
    button_sampler #(MFREQ_KHZ*5) bsampler( .mclk(mclk), .rst(rst), .pSetButton(pSetButton), .pAlarmButton(pAlarmButton), .pButton0(pButton0), .pButton1(pButton1), .sbutton({ sButton0, sButton1, sSetButton, sAlarmButton }) );

    always @ (posedge mclk) begin

        // set vButton[0] on posedge of sButton0
        if(sButton0 && !lsButton0) begin
            lsButton0 <= 1;
            vButton[0] <= 1;
        end
        else if(!sButton0 && lsButton0) begin
            lsButton0 <= 0;
            vButton[0] <= 0;
        end
        else vButton[0] <= 0;

        // set vButton[1] on posedge of sButton0
        if(sButton1 && !lsButton1) begin
            lsButton1 <= 1;
            vButton[1] <= 1;
        end
        else if(!sButton1 && lsButton1) begin
            lsButton1 <= 0;
            vButton[1] <= 0;
        end
        else vButton[1] <= 0;

        // change the mode on posedge of sSetButton
        if(sSetButton && !lsSetButton) begin
            lsSetButton <= 1;
            
            if(clk_mode == 0) clk_mode <= 1;
            else if(clk_mode == 1) clk_mode <= 3;
            else if(clk_mode == 3) clk_mode <= 0;
        end
        else if(!sSetButton && lsSetButton) begin
            lsSetButton <= 0;
        end

        // goto the alarm mode on posedge of sAlarmButton
        if(sAlarmButton && !lsAlarmButton) begin
            lsAlarmButton <= 1;
            
            if(clk_mode == 0) clk_mode <= 2;
            if(clk_mode == 2) clk_mode <= 0;
        end
        else if(!sAlarmButton && lsAlarmButton) begin
            lsAlarmButton <= 0;
        end
    end

endmodule

