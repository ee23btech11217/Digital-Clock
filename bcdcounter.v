
// count till max_count

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

    always @ (rst) begin : BCD_CRST
        counter <= 0;
        overflow <= 0;
    end

    always @ (posedge trigger, set_value) begin : BCD_COUNT
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
    output reg overflow
);

    wire[4:0] set_hr;
    reg[4:0] hr_counter = 0;

    wire[4:0] hr_mode;
    assign am_pm = hr_counter > 11;
    assign hr_mode = hr_counter + {mode_12h & am_pm, 1'b0, mode_12h & am_pm, 2'b0};

    always @ (rst) begin : BCD_CRST
        hr_counter <= 0;
        overflow <= 0;
    end

    bin_to_bcd binToBCD(.binary(hr_mode), .d1(h1), .d0(h0));
    bcd_to_bin bcdToBinSET(.d1(set_h1), .d0(set_h0), .binary(set_hr));

    always @ (posedge trigger, set_hr) begin : BCD_COUNT
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

// h1 h2 : m1 m2 : s1 s2
// 1 + 4 + 3 + 4 + 3 + 4
// 19

module time_view
(
    input clk, 
    input rst,
    input mode12h,
    input set_time,
    input set_alarm,
    input button1,
    input button2,
    input wire[1:0] alarm_id,
    input wire[19:0] stime_alarm,
    input wire sam_pm,
    output wire[19:0] hh_mm_ss,
    output wire am_pm
);

    wire sec_clk;
    wire bcd_clk[6];
    wire wireX[2];
    wire[19:0] stime;

    // clk frequency is 2 Hz
    sclk #(1) second_clk(.clk(clk), .rst(rst), .sec_clk(sec_clk));

    bcd_counter #(9) s0(.trigger(sec_clk),    .rst(rst), .set(set_time), .set_value(stime[3:0]), .counter(hh_mm_ss[3:0]), .overflow(bcd_clk[0]));
    bcd_counter #(5) s1(.trigger(bcd_clk[0]), .rst(rst), .set(set_time), .set_value({1'b0, stime[6:4]}), .counter({wireX[0], hh_mm_ss[6:4]}), .overflow(bcd_clk[1]));

    bcd_counter #(9) m0(.trigger(bcd_clk[1]), .rst(rst), .set(set_time), .set_value(stime[10: 7]), .counter(hh_mm_ss[10: 7]), .overflow(bcd_clk[2]));
    bcd_counter #(5) m1(.trigger(bcd_clk[2]), .rst(rst), .set(set_time), .set_value({1'b0, stime[13:11]}), .counter({wireX[1], hh_mm_ss[13:11]}), .overflow(bcd_clk[3]));

    hour_counter hrc(.trigger(bcd_clk[3]), .rst(rst), .set(set_time), .mode_12h(mode12h),
                           .set_h0(stime[17:14]), .set_h1({1'b0, 1'b0, stime[19:18]}), .set_am_pm(sam_pm),
                           .h0(hh_mm_ss[17:14]), .h1(hh_mm_ss[19:18]), .am_pm(am_pm), .overflow(bcd_clk[4]));
    
    setFSM setlogic(.clk(clk), .reset(rst), .setbutton(sam_pm), .button1(button1), .button2(button2), .hour1(stime[19:18]), .hour2(stime[17:14]), .min1(stime[13:11]), .min2(stime[10:7]), .sec1(stime[6:4]), .sec2(stime[3:0]));

//    always @ (posedge clk) begin
//        if(rst) begin
//            // reset all state
//            ;
//        end
//    end

endmodule

