module testbench();

    // Parameters
    parameter CLK_PERIOD = 2; // Clock period in time units (e.g., ps, ns, us)

    // Signals
    reg clk = 0;
    reg reset = 1;
    reg setbutton = 0;
    reg button1 = 0;
    reg button2 = 0;
    reg isset = 0;

    // Outputs
    wire [1:0] hour1_out;
    wire [3:0] hour2_out;
    wire [2:0] min1_out;
    wire [3:0] min2_out;
    wire [2:0] sec1_out;
    wire [3:0] sec2_out;

    // Instantiate the module under test
    setFSM dut (
        .clk(clk),
        .reset(reset),
        .setbutton(setbutton),
        .button1(button1),
        .button2(button2),
        .hour1(hour1_out),
        .hour2(hour2_out),
        .min1(min1_out),
        .min2(min2_out),
        .sec1(sec1_out),
        .sec2(sec2_out)
    );

    // Clock generation
    always #((CLK_PERIOD / 2)) clk = ~clk;

    // Reset assertion and release
    initial begin
        $monitor($time, "Time: %d%d:%d%d:%d%d", hour1_out, hour2_out, min1_out, min2_out, sec1_out, sec2_out);
        $dumpfile("set.vcd");
        $dumpvars;

        #100; // Wait for a bit
        reset = 1; // Assert reset
        #100; // Wait for a bit
        reset = 0; // Release reset
        #100; // Wait for a bit

        // Simulate button presses to set the time to 11:30:55
        // Set hours to 11
        setbutton = 1;
        #10
        setbutton = 0;
        button1 = 1;
        #10;
        button1 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10
        button2 = 1;
        #10;
        button2 = 0;
        #10
        setbutton = 1;
        #10
        setbutton = 0;
        #10
        // Set minutes to 30
        button2 = 1;
        #10;
        button2 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10
        setbutton = 1;
        #10
        setbutton = 0;
        #10
        button2 = 1;
        #10;
        button2 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10
        setbutton = 1;
        #10
        setbutton = 0;
        #10
        button2 = 1;
        #10;
        button2 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10
        #100
        #100; // Wait for a bit
        reset = 1; // Assert reset
        #100; // Wait for a bit
        reset = 0; // Release reset
        #100; // Wait for a bit

        // Simulate button presses to set the time to 11:30:55
        // Set hours to 11
        setbutton = 1;
        #10
        setbutton = 0;
        button1 = 1;
        #10;
        button1 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10
        button2 = 1;
        #10;
        button2 = 0;
        #10
        setbutton = 1;
        #10
        setbutton = 0;
        #10
        // Set minutes to 30
        button2 = 1;
        #10;
        button2 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10
        setbutton = 1;
        #10
        setbutton = 0;
        #10
        button2 = 1;
        #10;
        button2 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10
        setbutton = 1;
        #10
        setbutton = 0;
        #10
        button2 = 1;
        #10;
        button2 = 0;
        #10;
        button2 = 1;
        #10;
        button2 = 0;
        #10
        #100
        $finish;
    end

endmodule
