module qlal4s3b_cell_macro(output wire Sys_Clk0);

    reg clk = 0;

    always #1 clk = ~clk;

    assign Sys_Clk0 = clk;

endmodule

module ic_tb();

    reg clk = 1;
    reg rst = 0;
    reg rInt = 0;

    reg[15:0] delay_ms = 0;

    always #1 clk = ~clk;

    interrupt_controller #(2, 1) int_ctrl (.mclk(clk), .rst(rst), .raiseInterrupt(rInt), .delay_ms(16'd2));

    test_ic tic (.rst(rInt));

    initial begin
        $dumpfile("ictrl.vcd");
        $dumpvars;
        
        #20;

        rst = 1;
        // reset on first clock edge
        #2;
        rst = 0;

        delay_ms = 10;
        #10;
        // raise int
        rInt = ~rInt;

        #60;
        delay_ms = 0;
        rInt = ~rInt;

        #60;
        rInt = ~rInt;
        

        #200;

        $finish;
    end

endmodule

