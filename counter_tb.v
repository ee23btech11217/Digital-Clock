
module counter_tb();

    reg clk = 0;
    reg rst = 1;
    reg set = 0;
    wire HIGH = 1;
    wire LOW = 0;
    wire sec_clk;
    reg[3:0] rvalue = 0;
    wire[3:0] unit;
    wire[3:0] tens;
    reg[3:0] h0;
    reg[3:0] h1;
    wire sec_unit;
    wire sec_ten;
    always #1 clk = ~clk;

    reg mode_AMPM = 0;
    reg mode12h = 0;

    sclk #(1) second_clk(.clk(clk), .rst(rst), .sec_clk(sec_clk));
    //bcd_counter #(9) unitCounter(.trigger(sec_clk), .rst(rst), .set(set), .set_value(rvalue), .counter(unit), .overflow(sec_unit));
    //bcd_counter #(5) tenCounter(.trigger(sec_unit), .rst(rst), .set(set), .set_value(rvalue), .counter(tens), .overflow(sec_ten));
    hour_counter hcounter(.trigger(sec_clk), .rst(rst), .set(set), .set_h0(h0), .set_h1(h1), .set_am_pm(mode_AMPM), .mode_12h(mode12h));

    //wire[4:0] values = 23;
    //bin_to_bcd btbcd(.binary(values));

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars;
        
        // reset on first clock edge
        #2;
        rst = 0;

        #100;

        h0 = 4'd9;
        h1 = 4'd1;
        set = 1;
        #4

        set = 0;

        #100;

        mode12h = 1;
        #4
        #100;

        h0 = 4'd8;
        h1 = 4'd0;
        mode_AMPM = 1;
        set = 1;
        #4

        set = 0;

        #100;

        ;


        #100;

        $finish;
    end

endmodule

