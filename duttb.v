module time_view_tb();

    reg clk, rst, mode12h, set_time, set_alarm, button1, button2, sam_pm;
    reg [1:0] alarm_id;
    reg [19:0] stime_alarm;
    wire [19:0] hh_mm_ss;
    wire am_pm;

    // Instantiate the time_view module
    time_view dut(
        .clk(clk),
        .rst(rst),
        .mode12h(mode12h),
        .set_time(set_time),
        .set_alarm(set_alarm),
        .button1(button1),
        .button2(button2),
        .alarm_id(alarm_id),
        .stime_alarm(stime_alarm),
        .sam_pm(sam_pm),
        .hh_mm_ss(hh_mm_ss),
        .am_pm(am_pm)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Reset generation
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars;

        // Initial state setup
        clk = 0;
        rst = 1;
        mode12h = 1'b0;
        set_time = 1'b0;
        set_alarm = 1'b0;
        button1 = 1'b0;
        button2 = 1'b0;
        sam_pm = 1'b0;
        alarm_id = 2'b00;
        stime_alarm = 20'b0;

        // Release reset after some time
        #10 rst = 0;
        #100;

        // Test case 1: Set time mode, set hours to 12, minutes to 34, seconds to 56, AM
        set_time = 1'b1;
        #100;
        repeat(12) begin
            #50 button1 = 1'b1; // Press button 1
            #50 button1 = 1'b0; // Release button 1
            #50 button2 = 1'b1; // Press button 2
            #50 button2 = 1'b0; // Release button 2
        end

        sam_pm = 1;
        #100;
        repeat(12) begin
            #50 button1 = 1'b1; // Press button 1
            #50 button1 = 1'b0; // Release button 1
            #50 button2 = 1'b1; // Press button 2
            #50 button2 = 1'b0; // Release button 2
        end

        sam_pm = 0;
        #100;

        repeat(12) begin
            #50 button1 = 1'b1; // Press button 1
            #50 button2 = 1'b1; // Press button 2
            #50 button1 = 1'b0; // Release button 1
            #50 button2 = 1'b0; // Release button 2
        end

        sam_pm = 1;

        // Test case 2: Change to PM
        #100;
        set_time = 0;
        sam_pm = 1'b0;

        // Test case 4: Press button 2 to increment minutes
        #100;
        button1 = 1'b0;
        #50 button2 = 1'b1; // Press button 2
        #50 button2 = 1'b0; // Release button 2

        // Test case 6: Toggle mode 12h to 24h
        #100;
        mode12h = 1'b1;
        
        // Add more test cases as needed

        // Finish simulation
        #1000;
        $finish;
    end

endmodule
