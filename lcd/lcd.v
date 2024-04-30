
module clk_ms_timer #(parameter F_KMINUS1 = 10) (input wire clk, input wire rst, input wire shouldTime, output reg[15:0] ms_time);

    reg[31:0] counter;
    
    reg shTime_sampled;

    always @ (rst) begin : CLK_MS_RST
        counter <= 0;
        ms_time <= 0;
        shTime_sampled <= 0;
    end

    always @ (posedge clk) begin
        if(rst) begin
            counter <= 0;
            ms_time <= 0;
        end
        else if(counter < F_KMINUS1) begin
            counter <= counter + 1;
        end
        else if(counter >= F_KMINUS1) begin
            counter <= 0;
            ms_time <= ms_time + (1'b1 & shouldTime);
        end

        if(shTime_sampled != shouldTime) begin
            ms_time <= 0;
        end

        shTime_sampled <= shouldTime;
    end

endmodule

module lcd_disp_interface #(parameter waitTime = 30) (input wire clk, input wire rst, input wire[7:0] chcode, 
                          output reg RS, output reg E, output reg RW, output reg[7:0] DB);

    reg delay;

    //clk_ms_timer #(20000) ms_delay(.clk(clk), .rst(rst), .shouldTime(delay));
    clk_ms_timer #(1) ms_delay(.clk(clk), .rst(rst), .shouldTime(delay));
    
    reg[3:0] state;

    always @ (posedge rst) begin
        state <= 0;
        delay <= 1;
        E <= 1;
        RS <= 0;
        RW <= 0;
        DB <= 0;
    end

    always @ (posedge clk) begin
        // wait for 30ms
        // after start
        if(state == 0 && ms_delay.ms_time > waitTime) begin
            RS <= 0;
            E <= 1;
            RW <= 0;
            DB <= 8'b00111000;
            state <= state + 1;
        end
        else if(state == 1 && ms_delay.ms_time > 2*waitTime && ms_delay.ms_time < 3*waitTime) begin
            E <= 0;
        end
        else if(state == 1 && ms_delay.ms_time > 3*waitTime) begin
            E <= 1;
            state <= state + 1;
        end
        else if(state == 2 && ms_delay.ms_time > 4*waitTime && ms_delay.ms_time < 5*waitTime) begin
            E <= 0;
        end
        else if(state == 2 && ms_delay.ms_time > 5*waitTime) begin
            E <= 1;
            state <= state + 1;
        end
        else if(state == 3 && ms_delay.ms_time > 6*waitTime && ms_delay.ms_time < 7*waitTime) begin
            E <= 0;
            DB <= 1;
        end
        else if(state == 3 && ms_delay.ms_time > 7*waitTime) begin
            E <= 1;
            state <= state + 1;
        end
        else if(state == 4 && ms_delay.ms_time > 8*waitTime && ms_delay.ms_time < 9*waitTime) begin
            E <= 0;
            DB <= 8'b00001111;
        end
        else if(state == 4 && ms_delay.ms_time > 9*waitTime) begin
            E <= 1;
            state <= state + 1;
        end
        else if(state == 5 && ms_delay.ms_time > 10*waitTime && ms_delay.ms_time < 11*waitTime) begin
            E <= 0;
            DB <= 2;
        end
        else if(state == 5 && ms_delay.ms_time > 11*waitTime) begin
            E <= 1;
            state <= state + 1;
        end
        else if(state == 6 && ms_delay.ms_time > 12*waitTime) begin
            E <= 0;
            DB <= 0;
        end
    end

endmodule

module lcd_top(input wire rst, output wire IsRst, output wire IsRst2,
output wire LCD_RS,
output wire LCD_E,
output wire LCD_RW,
output wire LCD_DB0,
output wire LCD_DB1,
output wire LCD_DB2,
output wire LCD_DB3,
output wire LCD_DB4,
output wire LCD_DB5,
output wire LCD_DB6,
output wire LCD_DB7
);

    wire clk;

    qlal4s3b_cell_macro u_qlal4s3b_cell_macro (
        .Sys_Clk0 (clk)
    );

    reg rled;

    reg[7:0] testValue;

    lcd_disp_interface #(500)  ldi(.clk(clk), .rst(~rst), .chcode(testValue), .RS(LCD_RS), .E(LCD_E), .RW(LCD_RW), .DB({LCD_DB7, LCD_DB6, LCD_DB5, LCD_DB4, LCD_DB3, LCD_DB2, LCD_DB1, LCD_DB0}));

    always @ (posedge clk) begin
        rled <= (ldi.ms_delay.ms_time > 0);
    end

    //assign IsRst = rled;

    assign IsRst = ldi.ms_delay.ms_time > 0;
    assign IsRst2 = ldi.ms_delay.shouldTime;

endmodule

