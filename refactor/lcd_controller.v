// The LCD controller

// Manage the LCD Display

// mclk: main clock, the clock from the module qlal4...( 20 MHz? )
//
// MFREQ_KHZ: main clock frequency in KHz, use this paramter to set main clock frequency(uses this to measure time in ms)
//         = 1/10/100 for testing, = 20 000 for vaman board ( make sure all time keeping registers are 64 bit wide )
//
// LineA: the first line of output on LCD display(lineA[0] is to the left most side of the display)
// LineB: the second line of output on LCD display
//         for maps from BCD/alphabets to LCD display charecter see the datasheet of KS0066 chip(Samsung) Pg 18 (shared in this repo)
// 
// DB, RS, RW, E: output to the lcd display 
//

module lcd_controller #(parameter MFREQ_KHZ = 1, InsWaitTime = 16'd10, DataWaitTime = 10, RefreshTime = 320)(
    input wire mclk, input wire rst,
    input wire[127:0] LineA, input wire[127:0] LineB,
    output reg[7:0] DB, output reg RS, output reg E, output reg RW
);

    reg init_bar = 0;
    parameter INIT_CMD_LST_SIZE = 3;
    // instructions are executed from bottom to top
    // RS RW DB
    wire[10*INIT_CMD_LST_SIZE-1: 0] init_cmd = {
        {1'b0, 1'b0, 8'b00000110}, 
        {1'b0, 1'b0, 8'b00001111},
        {1'b0, 1'b0, 8'b00111000}
    };

    reg[3:0] init_state = 0;
    // if 0 code will send init_cmd[init_state] and set RS/RW values
    // if 1 code will send E = 1;
    reg init_substate = 0;

    // data sending stage
    parameter DATA_LST_SIZE = 12;
    // instructions are executed from bottom to top
    // RS RW DB
    wire[10*DATA_LST_SIZE-1: 0] data_lst = {
        //{1'b1, 1'b0, 8'b01001111}, // O
        //{1'b1, 1'b0, 8'b01001100}, // L
        //{1'b1, 1'b0, 8'b01001100}, // L
        //{1'b1, 1'b0, 8'b01000101}, // E
        //{1'b1, 1'b0, 8'b01001000}, // H
        //{1'b0, 1'b0, 8'b11000000}, // reposition to line2
        //{1'b1, 1'b0, 8'b01001111}, // O
        //{1'b1, 1'b0, 8'b01001100}, // L
        //{1'b1, 1'b0, 8'b01001100}, // L
        //{1'b1, 1'b0, 8'b01000101}, // E
        //{1'b1, 1'b0, 8'b01001000}, // H
        //{1'b0, 1'b0, 8'b10000000}  // reposition to line1

        {1'b1, 1'b0, LineB[15*8+:8]},
        {1'b1, 1'b0, LineB[14*8+:8]},
        {1'b1, 1'b0, LineB[13*8+:8]},
        {1'b1, 1'b0, LineB[12*8+:8]},
        {1'b1, 1'b0, LineB[11*8+:8]},
        {1'b1, 1'b0, LineB[10*8+:8]},
        {1'b1, 1'b0, LineB[ 9*8+:8]},
        {1'b1, 1'b0, LineB[ 8*8+:8]},
        {1'b1, 1'b0, LineB[ 7*8+:8]},
        {1'b1, 1'b0, LineB[ 6*8+:8]},
        {1'b1, 1'b0, LineB[ 5*8+:8]},
        {1'b1, 1'b0, LineB[ 4*8+:8]},
        {1'b1, 1'b0, LineB[ 3*8+:8]},
        {1'b1, 1'b0, LineB[ 2*8+:8]},
        {1'b1, 1'b0, LineB[ 1*8+:8]},
        {1'b1, 1'b0, LineB[ 0*8+:8]},
        {1'b0, 1'b0, 8'b11000000}, // reposition to line2
        {1'b1, 1'b0, LineA[15*8+:8]},
        {1'b1, 1'b0, LineA[14*8+:8]},
        {1'b1, 1'b0, LineA[13*8+:8]},
        {1'b1, 1'b0, LineA[12*8+:8]},
        {1'b1, 1'b0, LineA[11*8+:8]},
        {1'b1, 1'b0, LineA[10*8+:8]},
        {1'b1, 1'b0, LineA[ 9*8+:8]},
        {1'b1, 1'b0, LineA[ 8*8+:8]},
        {1'b1, 1'b0, LineA[ 7*8+:8]},
        {1'b1, 1'b0, LineA[ 6*8+:8]},
        {1'b1, 1'b0, LineA[ 5*8+:8]},
        {1'b1, 1'b0, LineA[ 4*8+:8]},
        {1'b1, 1'b0, LineA[ 3*8+:8]},
        {1'b1, 1'b0, LineA[ 2*8+:8]},
        {1'b1, 1'b0, LineA[ 1*8+:8]},
        {1'b1, 1'b0, LineA[ 0*8+:8]},
        {1'b0, 1'b0, 8'b10000000}  // reposition to line1
    };

    reg[3:0] data_state = 0;
    // if 0 code will send init_cmd[init_state] and set RS/RW values
    // if 1 code will send E = 1;
    reg data_substate = 0;

    reg exec_next = 0;
    wire init_ins_intr;
    interrupt_controller #(MFREQ_KHZ, 0) init_ctrl_ins(.mclk(mclk), .rst(rst), .raiseInterrupt(~exec_next), .delay_ms(InsWaitTime[15:0]), .interrupt(init_ins_intr));

    reg send_next = 0;
    wire data_intr;
    interrupt_controller #(MFREQ_KHZ, 0) ctrl_data(.mclk(mclk), .rst(rst), .raiseInterrupt(send_next), .delay_ms(DataWaitTime[15:0]), .interrupt(data_intr));

    reg exec_data_next = 0;
    wire exec_intr;
    interrupt_controller #(MFREQ_KHZ, 0) ctrl_ins(.mclk(mclk), .rst(rst), .raiseInterrupt(exec_data_next), .delay_ms(InsWaitTime[15:0]), .interrupt(exec_intr));

    reg start_refresh_intr = 0;
    wire refresh_data_intr;
    interrupt_controller #(MFREQ_KHZ, 1) ctrl_refresh(.mclk(mclk), .rst(rst), .raiseInterrupt(start_refresh_intr), .delay_ms(RefreshTime[15:0]), .interrupt(refresh_data_intr));

    always @ (posedge mclk) begin
        if(rst) begin
            init_bar <= 0;
            init_state <= 0;
            init_substate <= 0;
            E <= 0;
            RS <= 0;
            DB <= 0;
            exec_next <= 1;
        end
        else if(~init_bar) begin
            if(init_ins_intr) begin
                if(init_substate) begin
                    if(init_state < INIT_CMD_LST_SIZE - 1) init_state <= init_state + 1;
                    else begin
                        init_bar <= 1;
                        // start refresh routine
                        start_refresh_intr <= 1;
                        // start sending commands
                        send_next <= data_lst[9];
                        exec_data_next <= ~data_lst[9];
                    end

                    init_substate <= ~init_substate;
                end
                else begin
                    init_substate <= ~init_substate;
                end
                exec_next <= 1;
            end
            else begin
                exec_next <= 0;
            end

            if(init_substate) begin
                E <= 0;
            end
            else begin
                {RS, RW, DB} <= init_cmd[10*init_state+:10];
                E <= 1;
            end
        end
        else begin
            if(data_intr || exec_intr) begin
                if(data_substate) begin
                    if(data_state < DATA_LST_SIZE - 1) data_state <= data_state + 1;
                    else begin
                        data_state <= 0;
                        // do nothing :-)
                    end

                    data_substate <= ~data_substate;
                end
                else begin
                    data_substate <= ~data_substate;
                end
                send_next <= data_lst[(10*data_state)+9+:1];
                exec_data_next <= ~data_lst[(10*data_state)+9+:1];
            end
            else begin
                send_next <= 0;
                exec_data_next <= 0;
            end

            if(data_substate) begin
                E <= 0;
            end
            else begin
                {RS, RW, DB} <= data_lst[10*data_state+:10];
                E <= 1;
            end
        end
    end
endmodule

