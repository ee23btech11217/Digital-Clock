`timescale 1ns / 1ps

module datetb;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in ns
  
  // Signals
  reg clk;
  reg [7:0] hour_in;
  reg [23:0] date_in;
  reg [1:0] date_ow;
  wire [23:0] date_out;

  // Instantiate the clockCalendarDec2 module
  datemodule dut (
    .clk(clk),
    .hour_in(hour_in),
    .date_in(date_in),
    .date_mode(date_ow),
    .date_out(date_out)
  );

  // Clock generation
  always #((CLK_PERIOD/2)) clk = ~clk;

  // Test scenarios
  initial begin
    $monitor("Time: %0t, Hour: %h, Date: %b, Date Overwrite: %b, New Date: %b", $time, hour_in, date_in, date_ow, date_out);
    $dumpfile("date.vcd");
    $dumpvars(0, datetb);
    
    // Initialize signals
    clk = 0;
    hour_in = 8'h0;
    date_in = 24'h000000;
    date_ow = 0;
    
    // Apply some scenarios
    // Test normal day increment
    #50;
    hour_in = 8'h01;
    #50;
    hour_in = 8'h02;
    #50;
    hour_in = 8'h03;
    // Set date overwrite to change date
    date_ow = 2;
    #10;
    date_in = 23'h3_1_1_2_0_4;
    #20
    date_ow = 0;
    #50;
    hour_in = 8'h23;
    #10
    hour_in = 8'h0;
    #100
    $finish;
  end

endmodule
