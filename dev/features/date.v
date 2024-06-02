
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
endmodule