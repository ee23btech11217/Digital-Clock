
module counter_tb();

    reg clk = 0;
    reg rst = 1;
    reg set = 0;
    wire sec_clk;
    reg[3:0] rvalue = 0;
    wire[3:0] unit;
    wire[3:0] tens;
    wire sec_unit;
    wire sec_ten;
    always #1 clk = ~clk;

    sclk #(1) second_clk(.clk(clk), .rst(rst), .sec_clk(sec_clk));
    bcd_counter #(9) unitCounter(.trigger(sec_clk), .rst(rst), .set(set), .set_value(rvalue), .counter(unit), .overflow(sec_unit));
    bcd_counter #(5) tenCounter(.trigger(sec_unit), .rst(rst), .set(set), .set_value(rvalue), .counter(tens), .overflow(sec_ten));

    initial begin
        $dumpfile("counter.vcd");
        $dumpvars;
        
        // reset on first clock edge
        #2;
        rst = 0;

        #400;

        $finish;
    end

endmodule

