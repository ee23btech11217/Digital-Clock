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
endmodule
