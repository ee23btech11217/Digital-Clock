module lcd_disp_interface #(parameter FKMINUS1 = 1, parameter waitTimeIns = 30, parameter waitTimeData = 10)
(
    input wire clk, input wire rst, 
    input wire[7:0] data, input wire send_data, input wire ins_data,
    output reg RS, output reg E, output reg RW, output reg[7:0] DB, output reg ready
);

    reg init;
    reg[1:0] data_send_mode;
    reg id_mode;
    reg[63:0] counter;

    always @ (posedge clk) begin
        // wait for 30ms
        // after start

        if(rst) begin
            E <= 0;
            RS <= 0;
            RW <= 0;
            DB <= 0;
            init <= 1;
            counter = 0;
            data_send_mode <= 0;
            ready <= 0;
        end
        else counter = counter + 1;

        // wait 30 ms and then start init sequence
        if(counter > 1*waitTimeIns*FKMINUS1 && counter < 2*waitTimeIns*FKMINUS1 && init) begin
            RS <= 0;
            E <= 1;
            RW <= 0;
            DB <= 8'b00111000;
            ready <= 0;
        end
        else if(counter > 2*waitTimeIns*FKMINUS1 && counter < 3*waitTimeIns*FKMINUS1 && init) begin
            E <= 0; // set value to b00111000
            ready <= 0;
        end
        else if(counter > 3*waitTimeIns*FKMINUS1 && counter < 4*waitTimeIns*FKMINUS1 && init) begin
            E <= 1;
            DB <= 8'b00001100;
            ready <= 0;
        end
        else if(counter > 4*waitTimeIns*FKMINUS1 && counter < 5*waitTimeIns*FKMINUS1 && init) begin
            E <= 0; // set value to b00001111
            ready <= 0;
        end
        else if(counter > 5*waitTimeIns*FKMINUS1 && counter < 6*waitTimeIns*FKMINUS1 && init) begin
            E <= 1;
            DB <= 8'b00000110;
            ready <= 0;
        end
        else if(counter > 6*waitTimeIns*FKMINUS1 && counter < 7*waitTimeIns*FKMINUS1 && init) begin
            E <= 0; // set value to b00000110
            ready <= 0;
        end
        else if(counter > 7*waitTimeIns*FKMINUS1 && counter < 8*waitTimeIns*FKMINUS1 && init) begin
            E <= 1;
            DB <= 8'b00000001;
            ready <= 0;
        end
        else if(counter > 8*waitTimeIns*FKMINUS1 && counter < 9*waitTimeIns*FKMINUS1 && init) begin
            E <= 0; // set value to b00000110
            ready <= 0;
        end
        else if(counter > 9*waitTimeIns*FKMINUS1 && counter < 10*waitTimeIns*FKMINUS1 && init) begin
            E <= 0;
            init <= 0;
            counter = 0;
            data_send_mode <= 0;
            id_mode <= 0;
            ready <= 1;
        end

        if(!init && send_data && data_send_mode == 0) begin
            RS <= ins_data;
            E <= 1;
            DB <= data;
            id_mode <= ins_data;
            data_send_mode <= 1;
            ready <= 0;
        end
        if(!init && data_send_mode == 1 && counter > waitTimeData*FKMINUS1) begin
            E <= 0;
            data_send_mode <= 2;
            ready <= 0;
        end
        else if(!init && data_send_mode == 2 && counter > 2*waitTimeData*FKMINUS1) begin
            E <= 0;
            data_send_mode <= 0;
            counter = 0;
            ready <= 1;
        end
    end

endmodule

module sclk #(parameter F_MINUS1 = 10) (input clk, input rst, output reg sec_clk);

    reg[31:0] counter;

    always @ (posedge clk) begin
        if(rst) begin
            counter <= 0;
            sec_clk <= 0;
        end
        else if(counter < F_MINUS1) begin
            counter <= counter + 1;
            sec_clk <= 0;
        end
        else if(counter >= F_MINUS1) begin
            counter <= 0;
            sec_clk <= 1;
        end
    end

endmodule

module bcd_counter#(
    parameter MAX_COUNT = 4'd9
) (
    input trigger,
    input rst,
    input set,
    input wire[3:0] set_value,
    output reg[3:0] counter,
    output reg overflow
);
    always @ (posedge trigger) begin : BCD_COUNT
        if(set) begin
            counter <= set_value;
            overflow <= 0;
        end
        else if(counter < MAX_COUNT) begin
            counter = counter + 1;
            overflow <= 0;
        end
        else if(counter >= MAX_COUNT) begin
            counter = 0;
            overflow <= 1;
        end
    end

endmodule

// converts a binary number from 0...23 into bcd values
// fast as fuck
module bin_to_bcd(input wire[4:0] binary, output wire[1:0] d1, output wire[3:0] d0);
    wire[8:0] bin9;
    wire[8:0] q;
    assign bin9[8:0] = {4'b0, binary[4:0]};
    assign q[8:0] = (bin9 + (bin9 << 2) + (bin9 << 3));
    assign d1[1:0] = q[8:7];
    assign d0[3:0] = binary + {q[7], q[8], q[7] | q[8], q[7], 1'b0};
endmodule

module bcd_to_bin(input wire[3:0] d1, input wire[3:0] d0, output wire[4:0] binary);
    assign binary = d0 + (d1 << 1) + (d1 << 3);
endmodule

module hour_counter
(
    input trigger,
    input rst,
    input set,
    input mode_12h,
    input wire[3:0] set_h0,
    input wire[3:0] set_h1,
    input wire set_am_pm,
    output wire[3:0] h0,
    output wire[1:0] h1,
    output wire am_pm,
    output reg overflow,
    output wire[4:0] hr_bin
);

    wire[4:0] set_hr;
    reg[4:0] hr_counter = 0;

    wire[4:0] hr_mode;
    assign am_pm = hr_counter > 11;
    assign hr_mode = hr_counter + {mode_12h & am_pm, 1'b0, mode_12h & am_pm, 2'b0};

    bin_to_bcd binToBCD(.binary(hr_mode), .d1(h1), .d0(h0));
    bcd_to_bin bcdToBinSET(.d1(set_h1), .d0(set_h0), .binary(set_hr));

    always @ (posedge trigger) begin : BCD_COUNT
        if(set == 1) begin
        hr_counter <= set_hr + {1'b0, mode_12h & set_am_pm, mode_12h & set_am_pm, 2'b0}; // set_am_pm
        overflow <= 0;
        end
        else if(hr_counter < 23) begin
            hr_counter = hr_counter + 1;
            overflow <= 0;
        end
        else begin
            hr_counter <= 0;
            overflow <= 1;
        end
    end

    assign hr_bin = hr_counter;

endmodule

module time_view
(
    input clk, 
    input rst,
    input mode12h,
    input set_time,
    input set_alarm,
    input button1,
    input button2,
    input wire[19:0] stime_alarm,
    input wire sam_pm,
    output wire[19:0] hh_mm_ss,
    output wire am_pm,
    output wire buzz,
    output wire dled
);

    wire sec_clk;
    wire bcd_clk[6];
    wire wireX[2];
    reg[3:0] stime[6];
    wire snd_clk;
    wire[4:0] hr_bin;

    reg[19:0] alarm_time;
    reg alarm_mask;

    reg setTimeL;

    // clk frequency is 2 Hz
    // change frequency before flashing to 20 000 000
    sclk #(12000000) second_clk(.clk(clk), .rst(rst), .sec_clk(sec_clk));

    // change frequency before flashing
    // to something like 2kHz
    reg[63:0] play_alarm_sound;
    sclk #(1) sound_clk(.clk(clk), .rst(rst), .sec_clk(snd_clk));

    bcd_counter #(9) s0(.trigger(sec_clk),    .rst(rst), .set(setTimeL), .set_value(stime[0]), .counter(hh_mm_ss[3:0]), .overflow(bcd_clk[0]));
    bcd_counter #(5) s1(.trigger(bcd_clk[0]), .rst(rst), .set(setTimeL), .set_value(stime[1]), .counter({wireX[0], hh_mm_ss[6:4]}), .overflow(bcd_clk[1]));

    bcd_counter #(9) m0(.trigger(bcd_clk[1]), .rst(rst), .set(setTimeL), .set_value(stime[2]), .counter(hh_mm_ss[10: 7]), .overflow(bcd_clk[2]));
    bcd_counter #(5) m1(.trigger(bcd_clk[2]), .rst(rst), .set(setTimeL), .set_value(stime[3]), .counter({wireX[1], hh_mm_ss[13:11]}), .overflow(bcd_clk[3]));

    hour_counter hrc(.trigger(bcd_clk[3]), .rst(rst), .set(setTimeL), .mode_12h(mode12h),
                           .set_h0(stime[4]), .set_h1(stime[5]), .set_am_pm(sam_pm),
                           .h0(hh_mm_ss[17:14]), .h1(hh_mm_ss[19:18]), .am_pm(am_pm), .overflow(bcd_clk[4]), .hr_bin(hr_bin));
    
    //setFSM setlogic(.clk(clk), .reset(rst), .setbutton(sam_pm), .button1(button1), .button2(button2), .hour1(stime[19:18]), .hour2(stime[17:14]), .min1(stime[13:11]), .min2(stime[10:7]), .sec1(stime[6:4]), .sec2(stime[3:0]));

    reg mode;

    reg lockButton1;
    reg lockButton2;

    assign dled = button2;

    always @ (posedge clk) begin
        if(rst) begin
            // reset all state
            alarm_time <= 0;
            alarm_mask <= 0;
            play_alarm_sound <= 0;
            mode <= 0;
            setTimeL <= 0;
        end

        if(set_alarm) begin
            alarm_mask <= 1;
            alarm_time[13:0] <= stime_alarm[13:0];
            alarm_time[18:14] <= (stime_alarm[17:14] + 10 * stime_alarm[19:18]) + (12 * am_pm * mode12h);
        end

        lockButton1 <= button1;
        lockButton2 <= button2;

        if(set_time && !setTimeL) begin
            setTimeL <= ~setTimeL;
        end

        // button switched on(posedge)
        if(button1 && !lockButton1 && setTimeL) begin
            stime[2*mode] <= stime[2*mode] + 1;
        end
        if(button2 && !lockButton2 && setTimeL) begin
            stime[(2*mode) + 1] <= stime[(2*mode) + 1] + 1;
        end

        // if a alarm is active
        if(alarm_mask) begin
            if(alarm_time[13:0] == hh_mm_ss[13:0] && alarm_time[18:14] == hr_bin[4:0]) begin
                // ring the alarm alarm
                play_alarm_sound = 1;
                alarm_mask <= 0; 
            end
        end

        // value measured in clock cycles
        // change value when flashing
        if(play_alarm_sound > 10) begin
            play_alarm_sound <= 0;
        end
        else if(play_alarm_sound > 0) play_alarm_sound <= play_alarm_sound + 1;
    end

    assign buzz = (play_alarm_sound > 0) & snd_clk;

endmodule

module lcd_top(input wire rst, output wire IsRst, output wire IsRst2,
input wire button1,
input wire button2,
input wire set_time,
input wire sam_pm,
output wire LCD_RS,
output wire LCD_E,
output wire LCD_RW,
output wire LCD_DB0,
output wire LCD_DB1,
output wire LCD_DB2,
output wire LCD_DB3,
output wire LCD_DB4,
output wire LCD_DB5,
output wire LCD_DB6,
output wire LCD_DB7
);

    wire clk;

    qlal4s3b_cell_macro u_qlal4s3b_cell_macro (
        .Sys_Clk0 (clk)
    );

    reg[20:0] counter;
    reg[5:0] data_index;

    reg[7:0] testValue;
    reg send;
    reg insDataMode;
    reg[2:0] sendPulse;
    wire ready;

    wire secclk;
    reg[7:0] display[32];

    reg updateDisplay;
    reg set_bcd;
    reg mode12h;

    wire[3:0] cnter;
    wire[19:0] current_time;

    sclk #(12000000) second_clk(.clk(clk), .rst(~rst), .sec_clk(secclk));

    //bcd_counter #(9) bcd9(.trigger(secclk), .rst(~rst), .set(set_bcd), .counter(cnter));

    time_view tview(.clk(clk), .rst(~rst), .mode12h(mode12h), .set_alarm(set_bcd), .hh_mm_ss(current_time), .button1(~button1), .button2(~button2), .set_time(~set_time), .sam_pm(~sam_pm), .dled(IsRst));

    lcd_disp_interface #( 12000, 10, 5 ) ldi(.clk(clk), .rst(~rst), .data(testValue), .ins_data(insDataMode), .send_data(send), .RS(LCD_RS), .E(LCD_E), .RW(LCD_RW), .DB({LCD_DB7, LCD_DB6, LCD_DB5, LCD_DB4, LCD_DB3, LCD_DB2, LCD_DB1, LCD_DB0}), .ready(ready));

    always @ (posedge clk) begin
        if(~rst) begin
            data_index <= 0;
            insDataMode <= 0;
            send <= 0;
            sendPulse <= 0;
            testValue <= 0;
            updateDisplay <= 0; 
            set_bcd <= 0;
            mode12h <= 0;
        end

        if(secclk && !updateDisplay) begin
            updateDisplay <= 1;
            data_index <= 0;
            testValue <= {4'b0011, cnter[3:0]};
        end

        if(data_index < 4) begin
            testValue <= 8'h20;
            insDataMode <= 1;
        end
        if(data_index == 4) begin
            testValue <= {4'b0011, 2'b0, current_time[19:18]};
            insDataMode <= 1;
        end
        else if(data_index == 5) begin
            testValue <= {4'b0011, current_time[17:14]};
            insDataMode <= 1;
        end
        else if(data_index == 6) begin
            testValue <= {4'b0011, 4'b1010};
            insDataMode <= 1;
        end
        else if(data_index == 7) begin
            testValue <= {4'b0011, 1'b0, current_time[13:11]};
            insDataMode <= 1;
        end
        else if(data_index == 8) begin
            testValue <= {4'b0011, current_time[10:7]};
            insDataMode <= 1;
        end
        else if(data_index == 9) begin
            testValue <= {4'b0011, 4'b1010};
            insDataMode <= 1;
        end
        else if(data_index == 10) begin
            testValue <= {4'b0011, 1'b0, current_time[6:4]};
            insDataMode <= 1;
        end
        else if(data_index == 11) begin
            testValue <= {4'b0011, current_time[3:0]};
            insDataMode <= 1;
        end
        else if(data_index == 12) begin
            testValue <= 8'b00000011;
            insDataMode <= 0;
        end
        else begin
            testValue <= 8'h20;
            insDataMode <= 1;
        end

        if(ready && updateDisplay && !(sendPulse || send)) begin
            data_index <= data_index + 1;
            sendPulse <= 1;
        end
        else if(updateDisplay) begin
            case (sendPulse)

            1: begin
                sendPulse <= 2;
                send <= 0;
            end
            2: begin
                sendPulse <= 3;
                send <= 1;
            end
            3: begin
                sendPulse <= 4;
                send <= 1;
            end
            4: begin
                sendPulse <= 0;
                send <= 0;
            end
            default: begin
                sendPulse <= 0;
                send <= 0;
            end
            endcase

            if(data_index == 13) begin
                data_index <= 0;
                updateDisplay <= 0;
            end
        end
        else send <= 0;

    end

    assign IsRst2 = 1;
    //assign IsRst = button2;

endmodule

