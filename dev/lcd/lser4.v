module lcd_disp_interface #(parameter FKMINUS1 = 1, parameter waitTimeIns = 30, parameter waitTimeData = 10)
(
    input wire clk, input wire rst, 
    input wire[7:0] data, input wire send_data, input wire ins_data,
    output reg RS, output reg E, output reg RW, output reg[7:0] DB, output reg ready
);

    reg init;
    reg[1:0] data_send_mode;
    reg id_mode;
    reg[63:0] counter;

    always @ (posedge clk) begin
        // wait for 30ms
        // after start

        if(rst) begin
            E <= 0;
            RS <= 0;
            RW <= 0;
            DB <= 0;
            init <= 1;
            counter = 0;
            data_send_mode <= 0;
            ready <= 0;
        end
        else counter = counter + 1;

        // wait 30 ms and then start init sequence
        if(counter > 1*waitTimeIns*FKMINUS1 && counter < 2*waitTimeIns*FKMINUS1 && init) begin
            RS <= 0;
            E <= 1;
            RW <= 0;
            DB <= 8'b00111000;
            ready <= 0;
        end
        else if(counter > 2*waitTimeIns*FKMINUS1 && counter < 3*waitTimeIns*FKMINUS1 && init) begin
            E <= 0; // set value to b00111000
            ready <= 0;
        end
        else if(counter > 3*waitTimeIns*FKMINUS1 && counter < 4*waitTimeIns*FKMINUS1 && init) begin
            E <= 1;
            DB <= 8'b00001111;
            ready <= 0;
        end
        else if(counter > 4*waitTimeIns*FKMINUS1 && counter < 5*waitTimeIns*FKMINUS1 && init) begin
            E <= 0; // set value to b00001111
            ready <= 0;
        end
        else if(counter > 5*waitTimeIns*FKMINUS1 && counter < 6*waitTimeIns*FKMINUS1 && init) begin
            E <= 1;
            DB <= 8'b00000110;
            ready <= 0;
        end
        else if(counter > 6*waitTimeIns*FKMINUS1 && counter < 7*waitTimeIns*FKMINUS1 && init) begin
            E <= 0; // set value to b00000110
            ready <= 0;
        end
        else if(counter > 7*waitTimeIns*FKMINUS1 && counter < 8*waitTimeIns*FKMINUS1 && init) begin
            E <= 1;
            DB <= 8'b00000001;
            ready <= 0;
        end
        else if(counter > 8*waitTimeIns*FKMINUS1 && counter < 9*waitTimeIns*FKMINUS1 && init) begin
            E <= 0; // set value to b00000110
            ready <= 0;
        end
        else if(counter > 9*waitTimeIns*FKMINUS1 && counter < 10*waitTimeIns*FKMINUS1 && init) begin
            E <= 0;
            init <= 0;
            counter = 0;
            data_send_mode <= 0;
            id_mode <= 0;
            ready <= 1;
        end

        if(!init && send_data && data_send_mode == 0) begin
            RS <= ins_data;
            E <= 1;
            DB <= data;
            id_mode <= ins_data;
            data_send_mode <= 1;
            ready <= 0;
        end
        if(!init && data_send_mode == 1 && counter > waitTimeData*FKMINUS1) begin
            E <= 0;
            data_send_mode <= 2;
            ready <= 0;
        end
        else if(!init && data_send_mode == 2 && counter > 2*waitTimeData*FKMINUS1) begin
            E <= 0;
            data_send_mode <= 0;
            counter = 0;
            ready <= 1;
        end
    end

endmodule

module sclk #(parameter F_MINUS1 = 10) (input clk, input rst, output reg sec_clk);

    reg[31:0] counter;

    always @ (posedge clk) begin
        if(rst) begin
            counter <= 0;
            sec_clk <= 0;
        end
        else if(counter < F_MINUS1) begin
            counter <= counter + 1;
            sec_clk <= 0;
        end
        else if(counter >= F_MINUS1) begin
            counter <= 0;
            sec_clk <= 1;
        end
    end

endmodule

module bcd_counter#(
    parameter MAX_COUNT = 4'd9
) (
    input trigger,
    input rst,
    input set,
    input wire[3:0] set_value,
    output reg[3:0] counter,
    output reg overflow
);

//    always @ (rst) begin : BCD_CRST
//        counter <= 0;
//        overflow <= 0;
//    end

    always @ (posedge trigger) begin : BCD_COUNT
        if(set) begin
            counter <= set_value;
            overflow <= 0;
        end
        else if(counter < MAX_COUNT) begin
            counter = counter + 1;
            overflow <= 0;
        end
        else if(counter >= MAX_COUNT) begin
            counter = 0;
            overflow <= 1;
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

    reg[20:0] counter;
    reg[5:0] data_index;

    reg[7:0] testValue;
    reg send;
    reg insDataMode;
    reg[2:0] sendPulse;
    wire ready;

    wire secclk;
    reg[7:0] display[32];

    reg updateDisplay;
    reg set_bcd;

    wire[3:0] cnter;

    sclk #(20000000) second_clk(.clk(clk), .rst(~rst), .sec_clk(secclk));

    bcd_counter #(9) bcd9(.trigger(secclk), .rst(~rst), .set(set_bcd), .counter(cnter));

    lcd_disp_interface #( 20000, 30, 10 ) ldi(.clk(clk), .rst(~rst), .data(testValue), .ins_data(insDataMode), .send_data(send), .RS(LCD_RS), .E(LCD_E), .RW(LCD_RW), .DB({LCD_DB7, LCD_DB6, LCD_DB5, LCD_DB4, LCD_DB3, LCD_DB2, LCD_DB1, LCD_DB0}), .ready(ready));

    always @ (posedge clk) begin
        if(~rst) begin
            data_index <= 0;
            insDataMode <= 0;
            send <= 0;
            sendPulse <= 0;
            testValue <= 0;
            updateDisplay <= 0; 
            set_bcd <= 0;
        end

        if(secclk && !updateDisplay) begin
            updateDisplay <= 1;
            data_index <= 0;
            testValue <= {4'b0011, cnter[3:0]};
        end

        if(data_index == 0) begin
            testValue <= {4'b0011, cnter[3:0]};
            insDataMode <= 1;
        end
        else if(data_index == 1) begin
            testValue <= 8'b00000011;
            insDataMode <= 0;
        end
        else begin
            testValue <= 8'h20;
            insDataMode <= 1;
        end

//        case (data_index) 
//
//            0: testValue <= 8'b01001000;
//            1: testValue <= 8'b01000101;
//            2: testValue <= 8'b01001100;
//            3: testValue <= 8'b01001100;
//            4: begin
//                testValue <= 8'b01001111;
//            end
//
//        endcase

        if(ready && updateDisplay && !(sendPulse || send)) begin
            data_index <= data_index + 1;
            sendPulse <= 1;
        end
        else if(updateDisplay) begin
            case (sendPulse)

            1: begin
                sendPulse <= 2;
                send <= 0;
            end
            2: begin
                sendPulse <= 3;
                send <= 1;
            end
            3: begin
                sendPulse <= 4;
                send <= 1;
            end
            4: begin
                sendPulse <= 0;
                send <= 0;
            end
            default: begin
                sendPulse <= 0;
                send <= 0;
            end
            endcase

            if(data_index == 2) begin
                data_index <= 0;
                updateDisplay <= 0;
            end
        end
        else send <= 0;

    end

    assign IsRst2 = 1;
    assign IsRst = cnter[0];

endmodule

