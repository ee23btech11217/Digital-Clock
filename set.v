module setFSM #(
    parameter HOUR = 2'b00, MIN = 2'b01, SEC = 2'b10, DONE = 2'b11
) (
    input clk,
    input reset,
    input setbutton,
    input button1,
    input button2,
    output reg [1:0] hour1,
    output reg [3:0] hour2,
    output reg [2:0] min1,
    output reg [3:0] min2,
    output reg [2:0] sec1,
    output reg [3:0] sec2
);

    reg [1:0] state;
    reg isnext;
    reg isbutton1;
    reg isbutton2;

    // Synchronize inputs with the clock domain
    // reg nextbutton_sync, button1_sync, button2_sync;

    // always @(posedge clk or posedge reset) begin
    //     if (reset)
    //         nextbutton_sync <= 1'b0;
    //     else
    //         nextbutton_sync <= setbutton;
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

    // // Set isnext when setbutton is pressed
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

    always @(posedge setbutton) begin
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
            min1 <= 3'b000;
            min2 <= 4'b0000;
            sec1 <= 3'b000;
            sec2 <= 4'b0000;
            isnext <= 0;
            isbutton1 <=0;
            isbutton2 <=0;
        end
        else begin
//Need to add overflow logic
            case (state)
                HOUR: begin
                    if (isbutton1) begin
                        hour1 <= (hour1 == 2'b11) ? 2'b00 : hour1 + 1;
                        isbutton1 <= 0;
                    end
                    if (isbutton2) begin
                        hour2 <= (hour2 == 4'b1010) ? 4'b0000 : hour2 + 1;
                        isbutton2 <= 0;
                    end
                    state <= isnext ? MIN : HOUR;
                    isnext <=0;
                end

                MIN: begin
                    if (isbutton1) begin
                        min1 <= (min1 == 3'b110) ? 3'b000 : min1 + 1;
                        isbutton1 <= 0;
                    end
                    if (isbutton2) begin
                        min2 <= (min2 == 4'b1010) ? 4'b0000 : min2 + 1;
                        isbutton2 <= 0;
                    end
                    state <= isnext ? SEC : MIN;
                    isnext <= 0;
                end

                SEC: begin
                    if (isbutton1) begin
                        sec1 <= (sec1 == 3'b110) ? 3'b000 : sec1 + 1;
                        isbutton1 <= 0;
                    end
                    if (isbutton2) begin
                        sec2 <= (sec2 == 4'b1010) ? 4'b0000 : sec2 + 1;
                        isbutton2 <= 0;
                    end
                    state <= isnext ? DONE : SEC;
                    isnext <= 0;
                end
                
                DONE: begin
                    
                end

                default: state <= HOUR;
            endcase
        end
    end
endmodule
