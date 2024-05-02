`timescale 1ns / 1ps

module datetb;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in ns
  
  // Signals
  reg clk;
  reg [5:0] hour_in;
  reg [18:0] date_in;
  reg date_ow;
  wire [18:0] date_out;

  // Instantiate the clockCalendarDec2 module
  datemodule dut (
    .clk(clk),
    .hour_in(hour_in),
    .date_in(date_in),
    .date_ow(date_ow),
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
    hour_in = 6'h0;
    date_in = 19'b00_0000_0_000_0000_0000;
    date_ow = 0;
    
    // Apply some scenarios
    // Test normal day increment
    #50;
    hour_in = 6'h1;
    #50;
    hour_in = 6'h2;
    #50;
    hour_in = 6'h3;
    // Set date overwrite to change date
    date_ow = 1;
    #10;
    date_in = 19'b00_0001_0_0001_0000_0000;
    #20
    date_ow = 0;
    #50;
    hour_in = 6'h23;
    #10
    hour_in = 6'h0;
    #100
    $finish;
  end

endmodule
