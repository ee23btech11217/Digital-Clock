module zellers_congruence(
    input [7:0] year,
    input [7:0] month,
    input [7:0] day,
    output reg [2:0] day_of_week
    );

    reg [7:0] y;
    reg [7:0] m;
    reg [7:0] d;
    reg [7:0] h;
    
    always @(*) begin
        if(month <= 2) begin
            y = year - 1;
            m = month + 12;
        end
        else begin
            y = year;
            m = month;
        end
        d = day;
        
        h = (d + ((m + 1) * 26) / 10 + y + y/4 + 6 * (y/100) + y/400) % 7;
        
        case(h)
            0: day_of_week = 3'b000; // Saturday
            1: day_of_week = 3'b001; // Sunday
            2: day_of_week = 3'b010; // Monday
            3: day_of_week = 3'b011; // Tuesday
            4: day_of_week = 3'b100; // Wednesday
            5: day_of_week = 3'b101; // Thursday
            6: day_of_week = 3'b110; // Friday
            default: day_of_week = 3'b000; // Saturday (Fallback)
        endcase
    end
endmodule
