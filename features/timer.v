module timer(input clk_1hz, input [1:0] timer_mode, input [23:0] time_in, output [23:0] time_out, output buzzer);

  //separated time signals to respective meaning
  wire [7:0] sec_in, min_in, hour_in;
  reg [7:0] sec_reg, min_reg, hour_reg;

  //separation and combination of time signals
  assign {hour_in, min_in, sec_in} = time_in;
  assign time_out = {hour_reg, min_reg, sec_reg};
  assign buzzer = (time_out == 24'h0) ? 1 : 0; //how many seconds?

    always@(posedge clk_1hz)
    begin 
    //shallisetnow is one for 
    if (timer_mode == 2'b01)
        begin
          sec_reg <= sec_in;
          min_reg <= min_in;
          hour_reg <= hour_in;
        end
    else begin
            //secs
          casex(sec_reg)
            8'h00:
              begin
                sec_reg <= 8'h59;
              end
            8'h?0:
              begin
                sec_reg <= {(sec_reg[7:4]-4'h1), 4'h9};
              end
            default:
              begin
                sec_reg <= sec_reg - 8'h01;
              end
          endcase

            //mins
          if(sec_reg == 8'h00)
            begin
              casex(min_reg)
                8'h00:
                  begin
                    min_reg <= 8'h59;
                  end
                8'h?0:
                  begin
                    min_reg <= {(min_reg[7:4]-4'h1), 4'h9};
                  end
                default:
                  begin
                    min_reg <= min_reg - 8'h01;
                  end
              endcase
            end

            //hours
            if((sec_reg == 8'h00) & (min_reg == 8'h00))
            begin
              casex(hour_reg)
                8'h00:
                  begin
                    hour_reg <= 8'h00;
                  end
                8'h10:
                  begin
                    hour_reg <= 8'h09;
                  end
                8'h20: 
                  begin
                    hour_reg <= 8'h19;
                  end
                default:
                  begin
                    hour_reg <= hour_reg - 8'h01;
                  end
              endcase
            end
        end
    end

endmodule