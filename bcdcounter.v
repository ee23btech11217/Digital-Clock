
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

module hour_counter
(
    input trigger,
    input rst,
    input set,
    input mode_24h,
    input wire[3:0] set_h0,
    input wire[3:0] set_h1,
    input wire[3:0] set_am_pm,
    output reg[3:0] h0,
    output reg[3:0] h1,
    output reg am_pm,
    output reg overflow
);

    always @ (rst) begin : BCD_CRST
        h0 <= 0;
        h1 <= 0;
        am_pm  <= 0;
        overflow <= 0;
    end

    always @ (posedge trigger) begin : BCD_COUNT
        if(set) begin
            h0 <= set_h0;
            h1 <= set_h1;
            am_pm <= set_am_pm;
            overflow <= 0;
        end
        else if((h0 < 9 && h1 == 4'd0) || (h0 < 9 && h1 == 4'd1 && mode_24h) || (h0 < 2 && h1 == 4'd1 && !mode_24h) || (h0 < 4 && h1 == 4'd2 && mode_24h)) begin
            h0 = h0 + 1;
            overflow <= 0;
        end
        else begin
            h0 <= 0;
            if(mode_24h) begin
                if(h1 < 2) h1 <= h1 + 1;
                else h1 <= 0;
            end
            else begin
                if(h1 == 0) h1 <= 4'd1;
                else h1 <= 0;
            end
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
    input mode_24h,
    input set_time,
    input set_alarm,
    input wire[1:0] alarm_id,
    input wire[19:0] stime,
    input wire[19:0] stime_alarm,
    output wire[19:0] hh_mm_ss
);

    wire sec_clk;
    wire bcd_clk[6];

    // clk frequency is 2 Hz
    sclk #(1) second_clk(.clk(clk), .rst(rst), .sec_clk(sec_clk));

    // convert bcd to binary for setting hours time
    wire[3:0] in_htime;
    assign in_htime = stime[18] * 10 + stime[17:14];

    // convert binary to bcd for output hours time
    wire[3:0] bin_htime;
    wire[3:0] htime_12h = bin_htime >= 12 ? (bin_htime > 10 ? bin_htime : bin_htime - 9) : bin_htime - 12;


    assign hh_mm_ss[17:14] = bin_htime > 20 ? (bin_htime > 10 ? bin_htime : bin_htime - 9) : bin_htime - 20;

    bcd_counter #(9) s0(.trigger(sec_clk),    .rst(rst), .set(set_time), .set_value(stime[3:0]), .counter(hh_mm_ss[3:0]), .overflow(bcd_clk[0]));
    bcd_counter #(5) s1(.trigger(bcd_clk[0]), .rst(rst), .set(set_time), .set_value(stime[6:4]), .counter(hh_mm_ss[6:4]), .overflow(bcd_clk[1]));

    bcd_counter #(9) m0(.trigger(bcd_clk[1]), .rst(rst), .set(set_time), .set_value(stime[10: 7]), .counter(hh_mm_ss[10: 7]), .overflow(bcd_clk[2]));
    bcd_counter #(5) m1(.trigger(bcd_clk[2]), .rst(rst), .set(set_time), .set_value(stime[13:11]), .counter(hh_mm_ss[13:11]), .overflow(bcd_clk[3]));

    bcd_counter #(23) h0(.trigger(bcd_clk[4]), .rst(rst), .set(set_time), .set_value(in_htime), .counter(bin_htime), .overflow(bcd_clk[2]));

//    always @ (posedge clk) begin
//        if(rst) begin
//            // reset all state
//            ;
//        end
//    end

endmodule

