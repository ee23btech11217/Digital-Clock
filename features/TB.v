module clock_divider_tb;

    reg clk_in; // 20MHz clock input
    wire clk_out; // 1Hz output clock
    
    // Instantiate the clock divider module
    clock_divider dut (
        .clk_in(clk_in),
        .clk_out(clk_out)
    );
    
    // Generate a clock for simulation
    always #1 clk_in = ~clk_in; // 20MHz clock period is 50ns
    
    // Monitor the clock output
    initial begin
        $monitor("Time = %0t, clk_out = %b", $time, clk_out);
        // Simulate for 50 microseconds
        clk_in = 0;
        #60000000;
        $finish;
    end

endmodule
