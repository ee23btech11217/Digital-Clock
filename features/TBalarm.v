`timescale 1ns / 1ps

module alarmHex_tb;

  // Parameters
  parameter CLK_PERIOD = 10; // Clock period in ns
  
  // Signals
  reg clk;
  reg rst;
  reg [1:0] alarm_mode;
  reg [15:0] in_time;
  reg [15:0] set_time;
  wire ring;

  // Instantiate the alarmHex module
  alarm dut (
    .clk(clk),
    .rst(rst),
    .alarm_mode(alarm_mode),
    .in_time(in_time),
    .set_time(set_time),
    .ring(ring)
  );

  // Clock generation
  always #((CLK_PERIOD/2)) clk = ~clk;

  // Test scenarios
  initial begin
    $dumpfile("alarm.vcd");
    $dumpvars(0, alarmHex_tb);
    
    clk = 0;
    rst = 1;
    alarm_mode = 0;
    in_time = 16'h1200;
    set_time = 16'h0100;
    #10;
    rst = 0;
    #10;
    alarm_mode = 2'b11;
    set_time = 16'h1209;
    #10;
    alarm_mode = 0;
    repeat(9) begin
        in_time = in_time + 1;
        #10;
    end

    #100;
    $finish;
  end

endmodule
