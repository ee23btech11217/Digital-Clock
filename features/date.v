
module datemodule(input clk, input [5:0] hour_in, input [18:0] date_in, input date_ow, output [18:0] date_out);

  //Time signal format: hh_hhhh
  //Date signal format: dd_dddd.m_mmmm.10_0000_yyyy_yyyy   (1-1-2000 --> 12-12-2099) *CAUTION ABOUT THE 20** FORMAT OF YEAR*
  //When date_ow is high, date_in is the data_out at posedge clk and is retained after date_ow is low
  //Date transitions delay is one clock cycle (posedge (hour_in = 23) --> posedge (hour_in = 0) --> posedge (date_out is changed))
  //clk: mclk, hour_in: bufferofhour, date_in: bufferofdate, date_ow: clk_mode, date_out: date

  //separated date signals to respective meaning
  wire [5:0] day_in;
  wire [4:0] month_in;
  wire [7:0] year_in;

  reg [5:0] day_reg, day_reg_del; //day_reg_del: delayed signal
  reg [4:0] month_reg, month_reg_del; //month_reg_del: delayed signal
  reg [7:0] year_reg;

  reg [5:0] hour_reg; //Store previous hour data
  reg new_day; //Detect new day
  wire new_year, new_month; //Detect new year/month

  //separation and combination of date signals
  assign {day_in, month_in, year_in} = date_in;
  assign date_out = {day_reg, month_reg, year_reg};

  //edge detaction for year & month changes
  assign new_year = (month_reg == 5'h1) & (month_reg_del != 5'h1);
  assign new_month = (day_reg == 5'h1) & (day_reg_del != 5'h1);

  always@(posedge clk) //edge detection
    begin
      new_day <= (hour_in == 6'h0) & (hour_reg == 6'h23);
    end

  always@(posedge clk) //generate delayed signals for edge detection
    begin
      hour_reg <= hour_in;
      day_reg_del <= day_reg;
      month_reg_del <= month_reg;
    end

  //handle year
  always@(posedge clk or posedge date_ow)
    begin
      if(date_ow == 2b'10)  //clk_mode == 2 for set date
        begin
          year_reg <= year_in;
        end
      else
        begin
          if(new_year)
            begin
              casex(year_reg)
                8'h?9: year_reg <= {(year_reg[7:4]+4'd1),4'h0}; //(2009 --> 2010)
                default: year_reg <= year_reg + 8'b1; //(2008 --> 2009)
              endcase 
            end
        end
    end     

  //handle month
  always@(posedge clk or posedge date_ow)
    begin
      if(date_ow == 2b'10)  //clk_mode == 2 for set date
        begin
          month_reg <= month_in;
        end
      else
        begin
          if(new_month)
            begin
              case(month_reg)
                5'h12: month_reg <= 5'h1; //(Dec --> Jan)
                5'h09: month_reg <= 5'h10; //(Sept --> Oct)
                default: month_reg <= month_reg + 5'd1;
              endcase 
            end
        end
    end     
    
  //handle day
  always@(posedge clk or posedge date_ow) 
    begin
      if(date_ow == 2b'10)  //clk_mode == 2 for set date
        begin
          day_reg <= day_in;
        end
      else
        begin
          if(new_day)
            begin
              casex(month_reg)
                5'd2: //February
                    casex(day_reg)
                      6'h29: day_reg <= 6'h1; //(Feb 29 --> Feb 1)
                      6'h28: day_reg <= (year_reg[1:0] == 2'b00) ? 6'h29 : 6'h1; //Leap year (only divisibility by 4 check), enough for 2000-2099
                      6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Feb 09 --> Feb 10)
                      default: day_reg <= day_reg + 6'd1; 
                    endcase
                5'b00??0: //even months (30 days); April and June; 4, 6
                  casex(day_reg)
                    6'h30: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Apr 09 --> Apr 10)
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b00??1: //odd months (31 days); January, March, May and July; 1, 3, 5, 7
                  casex(day_reg)
                    6'h31: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Jan 09 --> Jan 10)
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b????0: //even months (31 days); August, October, December; 8, 10, 12
                  casex(day_reg)
                    6'h31: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Aug 09 --> Aug 10)
                    default: day_reg <= day_reg + 6'd1;
                  endcase
                5'b????1: //odd months (30 days); September, November; 9, 11
                  casex(day_reg)
                    6'h30: day_reg <= 6'd1;
                    6'h?9: day_reg <= {(day_reg[5:4]+2'h1),4'h0}; //(Sep 09 --> Sep 10)
                    default: day_reg <= day_reg + 6'd1;
                  endcase
              endcase
            end
        end
    end
endmodule