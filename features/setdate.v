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
endmodule
