
module qlal4s3b_cell_macro(output wire Sys_Clk0);

    reg clk = 0;

    always #1 clk = ~clk;

    assign Sys_Clk0 = clk;

endmodule

module lcd_tb();

    reg clk = 0;
    reg rst = 0;

    reg[7:0] ins_data_v = 0;
    reg ins_data = 0;
    reg send = 0;

    always #1 clk = ~clk;

    //bcd_counter #(9) unitCounter(.trigger(sec_clk), .rst(rst), .set(set), .set_value(rvalue), .counter(unit), .overflow(sec_unit));
    //bcd_counter #(5) tenCounter(.trigger(sec_unit), .rst(rst), .set(set), .set_value(rvalue), .counter(tens), .overflow(sec_ten));
    lcd_disp_interface ldi(.clk(clk), .rst(rst), .data(ins_data_v), .ins_data(ins_data), .send_data(send));
    lcd_top lcdt(.rst(~rst));

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

        #1000;

        ins_data_v = 8'd10;
        ins_data = 0;
        #2;
        send = 1;

        #2;
        send = 0;

        #1000;
        ins_data_v = 8'd46;
        ins_data = 1;
        #2;
        send = 1;

        #2;
        send = 0;

        #50000;

        $finish;
    end

endmodule

