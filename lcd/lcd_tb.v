
module qlal4s3b_cell_macro(output reg Sys_Clk0);

    always #1 Sys_Clk0 = ~Sys_Clk0;

endmodule

module lcd_tb();

    reg clk = 0;
    reg rst = 0;

    reg[7:0] char = 0;

    always #1 clk = ~clk;

    //bcd_counter #(9) unitCounter(.trigger(sec_clk), .rst(rst), .set(set), .set_value(rvalue), .counter(unit), .overflow(sec_unit));
    //bcd_counter #(5) tenCounter(.trigger(sec_unit), .rst(rst), .set(set), .set_value(rvalue), .counter(tens), .overflow(sec_ten));
    lcd_disp_interface #(100) ldi(.clk(clk), .rst(rst), .chcode(char));

    //wire[4:0] values = 23;
    //bin_to_bcd btbcd(.binary(values));

    initial begin
        $dumpfile("lcd.vcd");
        $dumpvars;
        
        #100;

        rst = 1;
        // reset on first clock edge
        #2;
        rst = 0;

        #10000;

        $finish;
    end

endmodule

