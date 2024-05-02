
module alarm(input clk, input rst, input [1:0] alarm_mode, input [15:0] in_time, output reg ring);

//in_time/out_time hhhh_hhhh_mmmm_mmmm
//clk: mclk, rst: rst, alarm_mode: clk_mode, {in_time, 8'h00}: timebuffer, ring: buzzer 
//alarm_mode == 3, in_time is set as time_alarm
//Alarm is not sensitive to seconds
//ring is high when in_time == time_alarm for one minute

  reg [15:0] time_alarm; //stores the alarm time

  //set alarm time
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
          time_alarm <= 16'd0; 
        end
      else
        begin
          time_alarm <= (alarm_mode == 2'b11) ? in_time : time_alarm;
        end
    end
    
  //handle the ringing of the alarm
  always@(posedge clk or posedge rst)
    begin
      if(rst)
        begin
           ring <= 1'b0;
        end
      else
        begin
              //16'h0001 --> number of minutes ring is high (1 min)
              ring <= ((in_time >= time_alarm) && (in_time < time_alarm + 16'h0001)) ? 1 : 0; 
        end
    end

endmodule//alarm