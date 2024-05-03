
module qlal4s3b_cell_macro(output wire Sys_Clk0);

    reg clk = 0;
    always #1 clk = ~clk;
    assign Sys_Clk0 = clk;

endmodule

module lcd_tb();

    reg clk = 1;
    reg rst = 0;
    reg rInt = 0;

    always #1 clk = ~clk;

    //interrupt_controller #(2, 1) int_ctrl (.mclk(clk), .rst(rst), .raiseInterrupt(rInt), .delay_ms(16'd2));

    //lcd_controller #(1, 4, 2, 2) int_ctrl (.mclk(clk), .rst(rst));

    lcd_display_controller #(1, 8, 2, 2) int_ctrl (.mclk(clk), .rst(rst), .changeWeekday(~rInt));

    //test_ic tic (.rst(rInt));

    initial begin
        $dumpfile("ictrl.vcd");
        $dumpvars;
        
        #20;

        rst = 1;
        // reset on first clock edge
        #2;
        rst = 0;

        #10;
        // raise int
        rInt = ~rInt;

        #60;
        rInt = ~rInt;

        #60;
        rInt = ~rInt;  

        #2000;

        $finish;
    end

endmodule



