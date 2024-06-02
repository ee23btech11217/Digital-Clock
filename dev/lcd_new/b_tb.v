
module qlal4s3b_cell_macro(output wire Sys_Clk0);

    reg clk = 0;
    always #1 clk = ~clk;
    assign Sys_Clk0 = clk;

endmodule

module button_tb();

    reg clk = 1;
    reg rst = 0;
    reg pSetButton = 0;
    reg pAlarmButton = 0;
    reg pButton0 = 0;
    reg pButton1 = 0;

    always #1 clk = ~clk;

    //interrupt_controller #(2, 1) int_ctrl (.mclk(clk), .rst(rst), .raiseInterrupt(pSetButton), .delay_ms(16'd2));

    //lcd_controller #(1, 4, 2, 2) int_ctrl (.mclk(clk), .rst(rst));

    button_controller #(1) button_ctrl (.mclk(clk), .rst(rst), .pSetButton(pSetButton), .pAlarmButton(pAlarmButton), .pButton0(pButton0), .pButton1(pButton1));

    //test_ic tic (.rst(pSetButton));

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
        pSetButton = ~pSetButton;

        #60;
        pSetButton = ~pSetButton;

        #60;
        pSetButton = ~pSetButton;  

        #2000;

        $finish;
    end

endmodule



