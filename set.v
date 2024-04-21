module setFSM #(
    parameter HOUR = 2'b00, MIN = 2'b01, SEC = 2'b10, DONE = 2'b11
) (
    input clk,
    input reset,
    input nextbutton,
    input button1,
    input button2,
    input isset,
    output reg [1:0] hour1,
    output reg [3:0] hour2,
    output reg [3:0] min1,
    output reg [3:0] min2,
    output reg [3:0] sec1,
    output reg [3:0] sec2
);

    reg [1:0] state;
    reg isnext;
    reg isbutton1;
    reg isbutton2;

    // Synchronize inputs with the clock domain
    reg nextbutton_sync, button1_sync, button2_sync;

    // always @(posedge clk or posedge reset) begin
    //     if (reset)
    //         nextbutton_sync <= 1'b0;
    //     else
    //         nextbutton_sync <= nextbutton;
    // end

    // always @(posedge clk or posedge reset) begin
    //     if (reset)
    //         button1_sync <= 1'b0;
    //     else
    //         button1_sync <= button1;
    // end

    // always @(posedge clk or posedge reset) begin
    //     if (reset)
    //         button2_sync <= 1'b0;
    //     else
    //         button2_sync <= button2;
    // end

    // // Set isnext when nextbutton is pressed
    // always @(posedge clk or posedge reset) begin
    //     if (reset)
    //         isnext <= 0;
    //     else if (nextbutton_sync)
    //         isnext <= 1;
    // end

    // // Set isbutton1 when button1 is pressed
    // always @(posedge clk or posedge reset) begin
    //     if (reset)
    //         isbutton1 <= 0;
    //     else if (button1_sync)
    //         isbutton1 <= 1;
    // end

    // // Set isbutton2 when button2 is pressed
    // always @(posedge clk or posedge reset) begin
    //     if (reset)
    //         isbutton2 <= 0;
    //     else if (button2_sync)
    //         isbutton2 <= 1;
    // end

    always @(posedge nextbutton) begin
        isnext <= 1;
    end
    always @(posedge button1) begin
        isbutton1 <= 1;
    end
    always @(posedge button2) begin
        isbutton2 <= 1;
    end


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= HOUR;
            hour1 <= 2'b00;
            hour2 <= 4'b0000;
            min1 <= 4'b0000;
            min2 <= 4'b0000;
            sec1 <= 4'b0000;
            sec2 <= 4'b0000;
        end else begin
            // State transition logic
            case (state)
                HOUR: begin
                    if (isbutton1) begin
                        hour1 <= (hour1 == 2'b01) ? 2'b00 : hour1 + 1;
                        isbutton1 <= 0;
                    end
                    if (isbutton2) begin
                        hour2 <= (hour2 == 4'b1001) ? 4'b0000 : hour2 + 1;
                        isbutton2 <= 0;
                    end
                    state <= isnext ? MIN : HOUR;
                    isnext =0;
                end

                MIN: begin
                    if (isbutton1) begin
                        min1 <= (min1 == 4'b0101) ? 4'b0000 : min1 + 1;
                        isbutton1 <= 0;
                    end
                    if (isbutton2) begin
                        min2 <= (min2 == 4'b1001) ? 4'b0000 : min2 + 1;
                        isbutton2 <= 0;
                    end
                    state <= isnext ? SEC : MIN;
                    isnext = 0;
                end

                SEC: begin
                    if (isbutton1) begin
                        sec1 <= (sec1 == 4'b0101) ? 4'b0000 : sec1 + 1;
                        isbutton1 <= 0;
                    end
                    if (isbutton2) begin
                        sec2 <= (sec2 == 4'b1001) ? 4'b0000 : sec2 + 1;
                        isbutton2 <= 0;
                    end
                    state <= isnext ? HOUR : SEC;
                    isnext = 0;
                end

                default: state <= HOUR;
            endcase
        end
    end
endmodule
