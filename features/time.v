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

endmodule