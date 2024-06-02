module lcd_disp_interface (input wire rst, input wire[7:0] chcode, 
                          output reg RS, output reg E, output reg RW, output reg[7:0] DB);

    reg[63:0] counter;

    qlal4s3b_cell_macro u_qlal4s3b_cell_macro (
        .Sys_Clk0 (clk)
    );

    always @ (posedge clk) begin
        // wait for 30ms
        // after start

        if(rst) begin
            E <= 0;
            RS <= 0;
            RW <= 0;
            DB <= 0;
            counter <= 0;
        end
        else counter <= counter + 1;

        if(counter > 1*300*20000 && counter < 2*300*20000) begin
            RS <= 0;
            E <= 1;
            RW <= 0;
            DB <= 8'b00111000;
        end
        else if(counter > 2*300*20000 && counter < 3*300*20000) begin
            E <= 0; // set value to b00111000
        end
        else if(counter > 3*300*20000 && counter < 4*300*20000) begin
            E <= 1;
            DB <= 8'b00001110;
        end
        else if(counter > 4*300*20000 && counter < 5*300*20000) begin
            E <= 0; // set value to b00111000
        end
        else if(counter > 5*300*20000 && counter < 6*300*20000) begin
            E <= 1;
            DB <= 8'b00000110;
        end
        else if(counter > 6*300*20000 && counter < 7*300*20000) begin
            E <= 0; // set value to b00111000
        end
        else if(counter > 7*300*20000 && counter < 8*300*20000) begin
            E <= 1;
            DB <= 8'b01001000;
            RS <= 1;
        end
        else if(counter > 8*300*20000 && counter < 9*300*20000) begin
            E <= 0; // set value to b00001111
        end
        else if(counter > 9*300*20000 && counter < 10*300*20000) begin
            DB <= 8'b01000101;
            RS <= 1;
            E <= 1;
        end
        else if(counter > 10*300*20000 && counter < 11*300*20000) begin
            E <= 0; // set value to 0x1
        end
        else if(counter > 11*300*20000 && counter < 12*300*20000) begin
            E <= 1;
            RS <= 1;
            DB <= 8'b01001100;
        end
        else if(counter > 12*300*20000 && counter < 13*300*20000) begin
            E <= 0; // set value to 0xf
        end
        else if(counter > 13*300*20000 && counter < 14*300*20000) begin
            E <= 0;
            RS <= 0;
            DB <= 8'b01001100;
        end
        else if(counter > 14*300*20000 && counter < 15*300*20000) begin
            E <= 0; // set value to 0x2
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

    //wire clk;

    

    reg rled;

    reg[7:0] testValue;

    lcd_disp_interface ldi(.rst(~rst), .chcode(testValue), .RS(LCD_RS), .E(LCD_E), .RW(LCD_RW), .DB({LCD_DB7, LCD_DB6, LCD_DB5, LCD_DB4, LCD_DB3, LCD_DB2, LCD_DB1, LCD_DB0}));
/*
    always @ (posedge clk) begin
        rled <= ~rst;
    end
*/
    //assign IsRst = rled;

    assign IsRst = 1;//ldi.ms_delay.ms_time > 0;
    assign IsRst2 = 1;//rled;//ldi.ms_delay.shouldTime;

endmodule

