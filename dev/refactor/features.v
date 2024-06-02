
module datemodule(input clk, input [7:0] hour_in, input [23:0] date_in, input [2:0] weekday_in, input [1:0] date_mode, output [23:0] date_out, output [2:0] weekday_out);

  //Time signal format: hhhh_hhhh
  //Date signal format: dddd_dddd.mmmm_mmmm.0010_0000_yyyy_yyyy   (1-1-2000 --> 12-12-2099) *CAUTION ABOUT THE 20** FORMAT OF YEAR*
  //When date_mode is 2, date_in is set
  //Date transitions delay is one clock cycle (posedge (hour_in = 23) --> posedge (hour_in = 0) --> posedge (date_out is changed))
  //clk: mclk, hour_in: bufferofhour, date_in: bufferofdate, date_mode: clk_mode, date_out: date
  //need to implement set logic for dates

  //separated date signals to respective meaning
  wire [7:0] day_in;
  wire [7:0] month_in;
  wire [7:0] year_in;

  reg [7:0] day_reg, day_reg_del; //day_reg_del: delayed signal
  reg [7:0] month_reg, month_reg_del; //month_reg_del: delayed signal
  reg [7:0] year_reg;
  reg [2:0] weekdayreg;
  reg [7:0] hour_reg; //Store previous hour data
  reg new_day; //Detect new day
  wire new_year, new_month; //Detect new year/month

  //separation and combination of date signals
  assign {day_in, month_in, year_in} = date_in;
  assign date_out = {day_reg, month_reg, year_reg};
  assign weekday_out = weekdayreg;

  //edge detaction for year & month changes
  assign new_year = (month_reg == 8'h01) & (month_reg_del != 8'h01);
  assign new_month = (day_reg == 8'h01) & (day_reg_del != 8'h01);

  always@(posedge clk) //edge detection
  begin
      new_day <= (hour_in == 8'h0) & (hour_reg == 8'h23);
      hour_reg <= hour_in;
      day_reg_del <= day_reg;
      month_reg_del <= month_reg;

      if(date_mode == 2'b11)  //clk_mode == 3 for set date
      begin
          year_reg <= year_in;
          month_reg <= month_in;
          day_reg <= day_in;
          weekdayreg <= weekday_in;
      end
      else begin
          //handle years
          if(new_year)
            begin
              casex(year_reg)
                8'h?9: year_reg <= {(year_reg[7:4]+4'h1),4'h0}; //(2009 --> 2010)
                default: year_reg <= year_reg + 8'b01; //(2008 --> 2009)
              endcase 
            end

          //handle months
          if(new_month)
            begin
              case(month_reg)
                8'h12: month_reg <= 8'h01; //(Dec --> Jan)
                8'h09: month_reg <= 8'h10; //(Sept --> Oct)
                default: month_reg <= month_reg + 4'h1;
              endcase 
            end

          //handle days
          if(new_day)
            begin
              casex(month_reg)
                5'd2: //February
                    casex(day_reg)
                      8'h29: day_reg <= 8'h01; //(Feb 29 --> Feb 1)
                      8'h28: day_reg <= (year_reg[1:0] == 2'b00) ? 8'h29 : 8'h1; //Leap year (only divisibility by 4 check), enough for 2000-2099
                      8'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Feb 09 --> Feb 10)
                      default: day_reg <= day_reg + 8'd1; 
                    endcase
                5'b00??0: //even months (30 days); April and June; 4, 6
                  casex(day_reg)
                    8'h30: day_reg <= 8'd01;
                    8'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Apr 09 --> Apr 10)
                    default: day_reg <= day_reg + 8'd01;
                  endcase
                5'b00??1: //odd months (31 days); January, March, May and July; 1, 3, 5, 7
                  casex(day_reg)
                    8'h31: day_reg <= 8'd01;
                    8'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Jan 09 --> Jan 10)
                    default: day_reg <= day_reg + 8'd01;
                  endcase
                5'b????0: //even months (31 days); August, October, December; 8, 10, 12
                  casex(day_reg)
                    8'h31: day_reg <= 8'd01;
                    8'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Aug 09 --> Aug 10)
                    default: day_reg <= day_reg + 8'd1;
                  endcase
                5'b????1: //odd months (30 days); September, November; 9, 11
                  casex(day_reg)
                    8'h30: day_reg <= 8'd01;
                    8'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Sep 09 --> Sep 10)
                    default: day_reg <= day_reg + 8'd1;
                  endcase
              endcase

              //handle weekday
              weekdayreg <= (weekdayreg == 3'b110) ? 3'b000 : weekday_out + 3'b001; //(Sun --> Mon)
            end
        end
  end     
endmodule//datemodule

module setdate (
    input clk,
    input button1,
    input button2,
    input button3,
    input [1:0] set_mode,
    output reg [3:0] day1,
    output reg [3:0] day2,
    output reg [3:0] month1,
    output reg [3:0] month2,
    output reg [3:0] year1,
    output reg [3:0] year2, 
    output reg [2:0] day
);

//when set_mode = 3, 

    parameter DAY = 2'b00, MONTH = 2'b01, YEAR = 2'b10, WEEKDAY = 2'b11;
    reg [1:0] state;
    reg issetpressednow;

    always @(posedge clk) begin
        if (set_mode == 2'b11) begin
            if (issetpressednow) begin
                state <= 0;
                day1 <= 0;
                day2 <= 0;
                month1 <= 0;
                month2 <= 0;
                year1 <= 0;
                year2 <= 0;
                issetpressednow <= 0;
            end

            casex(state)
                DAY: begin
                    if (button1) begin
                        day1 <= (day1 == 4'h3) ? 4'b0 : day1 + 1;
                    end
                    if (button2) begin
                        day2 <= (day2 == 4'h9) ? 4'b0 : day2 + 1;
                    end
                    if (button3) begin
                        state <= MONTH;
                    end
                end

                MONTH: begin
                    if (button1) begin
                        month1 <= (month1 == 4'h3) ? 4'b0 : month1 + 1;
                    end
                    if (button2) begin
                        month2 <= (month2 == 4'h9) ? 4'b0 : month2 + 1;
                    end
                    if (button3) begin
                        state <= YEAR;
                    end
                end

                YEAR: begin
                    if (button1) begin
                        year1 <= (year1 == 4'h9) ? 4'b0 : year1 + 1;
                    end
                    if (button2) begin
                        year2 <= (year2 == 4'h9) ? 4'b0 : year2 + 1;
                    end
                    if (button3) begin
                        state <= WEEKDAY;
                    end
                end
                
                WEEKDAY: begin
                    if (button1) begin
                        day <= (day == 3'h6) ? 3'h0 : day + 1;
                    end

                    if (button3) begin
                        state <= DAY;
                    end
                end

                default: state <= DAY;
            endcase
        end

        else begin
           issetpressednow <= 1;
        end
    end
endmodule //setdate

module settime (
    input clk,
    input button1,
    input button2,
    input button3,
    input [1:0] set_mode,
    output reg [3:0] hour1,
    output reg [3:0] hour2,
    output reg [3:0] min1,
    output reg [3:0] min2,
    output reg [3:0] sec1,
    output reg [3:0] sec2
);

parameter HOUR = 2'b00, MIN = 2'b01, SEC = 2'b10, DONE = 2'b11;
    reg [1:0] state;
    reg issetpressednow;

    always @(posedge clk) begin
        if (set_mode == 2'b01) begin
            if (issetpressednow) begin
                state <= 0;
                hour1 <= 0;
                hour2 <= 0;
                min1 <= 0;
                min2 <= 0;
                sec1 <= 0;
                sec2 <= 0;
                issetpressednow <= 0;
            end

            casex(state)
                HOUR: begin
                    if (button1) begin
                        hour1 <= (hour1 == 4'h2) ? 4'b0 : hour1 + 1;
                    end
                    if (button2) begin
                        hour2 <= (hour2 == 4'h9) ? 4'b0 : hour2 + 1;
                    end
                    if (button3) begin
                        state <= MIN;
                    end
                end

                MIN: begin
                    if (button1) begin
                        min1 <= (min1 == 4'h5) ? 4'b0 : min1 + 1;
                    end
                    if (button2) begin
                        min2 <= (min2 == 4'h9) ? 4'b0 : min2 + 1;
                    end
                    if (button3) begin
                        state <= SEC;
                    end
                end

                SEC: begin
                    if (button1) begin
                        sec1 <= (sec1 == 4'h5) ? 4'b0 : sec1 + 1;
                    end
                    if (button2) begin
                        sec2 <= (sec2 == 4'h9) ? 4'b0 : sec2 + 1;
                    end
                    if (button3) begin
                        state <= HOUR;
                    end
                end
                default: state <= HOUR;
            endcase
        end

        else begin
           issetpressednow <= 1;
        end
    end
endmodule //settime

module clocktime(input clk_1hz, input rst, input [1:0] clk_mode, input [23:0] time_in, output [23:0] time_out);

  //separated time signals to respective meaning
  wire [7:0] sec_in, min_in, hour_in;
  reg [7:0] sec_reg, min_reg, hour_reg;

  //separation and combination of time signals
  assign {hour_in, min_in, sec_in} = time_in;
  assign time_out = {hour_reg, min_reg, sec_reg};

  //handle seconds
  always@(posedge clk_1hz or clk_mode or posedge rst)
    begin
      if (rst) begin
         hour_reg <= 8'h00;
         min_reg <= 8'h00;
         sec_reg <= 8'h00;
      end

      if (clk_mode == 2'b01)
        begin
          sec_reg <= sec_in;
          min_reg <= min_in;
          hour_reg <= hour_in;
        end
      else if (clk_mode == 2'b00)
        begin
            //secs
          casex(sec_reg)
            8'h59:
              begin
                sec_reg <= 8'h00;
              end
            8'h?9:
              begin
                sec_reg <= {(sec_reg[7:4]+4'h1), 4'h0};
              end
            default:
              begin
                sec_reg <= sec_reg + 8'h01;
              end
          endcase

            //mins
          if(sec_reg == 8'h59)
            begin
              casex(min_reg)
                8'h59:
                  begin
                    min_reg <= 8'h0;
                  end
                8'h?9:
                  begin
                    min_reg <= {(min_reg[7:4]+4'h1), 4'h0};
                  end
                default:
                  begin
                    min_reg <= min_reg + 8'h01;
                  end
              endcase
            end

            //hours
            if((sec_reg == 8'h59) & (min_reg == 8'h59))
            begin
              casex(hour_reg)
                8'h23:
                  begin
                    hour_reg <= 8'h00;
                  end
                8'b000?1001: //09 & 19
                  begin
                    hour_reg <= {(hour_reg[5:4]+3'd1),4'd0};
                  end
                default:
                  begin
                    hour_reg <= hour_reg + 8'h01;
                  end
              endcase
            end
        end

        else begin
            
        end
    end

endmodule //clocktime

module formattime (
    input wire [1:0] clk_mode,     // Clock mode (2-bit)
    input wire setampm,  // Time format toggle signal
    input wire [23:0] clock_time, // Current clock time (24-bit)
    input wire [23:0] alarm_time, // Alarm time (24-bit)
    output reg [23:0] bcd_time,   // Converted time output (24-bit)
    output reg ampm               // AM/PM flag output
);

// Temporary storage for time based on clock mode
reg [23:0] bcd_time_temp;
reg formattimetoggle;

// Select clock or alarm time based on clock mode
always @* begin
    if (clk_mode == 2'b10)
        bcd_time_temp = alarm_time;
    else bcd_time_temp = clock_time;

    if (setampm == 1) begin
        // Toggle time format
        formattimetoggle = ~formattimetoggle;
    end

    if (formattimetoggle) // 24-hour format
        bcd_time = bcd_time_temp;
    else begin // 12-hour format
        if (bcd_time_temp[23:16] > 8'h12) begin // PM
            bcd_time[23:16] = bcd_time_temp[23:16] - 8'h12;
            ampm = 1; // Set PM flag
        end else begin // AM
            bcd_time[23:16] = bcd_time_temp[23:16];
            ampm = 0; // Set AM flag
        end
        bcd_time[15:0] = bcd_time_temp[15:0]; // Keep lower 16 bits unchanged
    end
end

endmodule //formattime

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
          ring <= 1'b0;
        end
      else
        begin
          time_alarm <= (alarm_mode == 2'b11) ? in_time : time_alarm;
          ring <= ((in_time >= time_alarm) && (in_time < time_alarm + 16'h0001)) ? 1 : 0; 
        end
    end
endmodule//alarm

