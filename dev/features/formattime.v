module formattime (
    input wire [1:0] clk_mode,     // Clock mode (2-bit)
    input wire setampm,  // Time format toggle signal
    input wire [23:0] clock_time, // Current clock time (24-bit)
    input wire [23:0] alarm_time, // Alarm time (24-bit)
    output reg [23:0] bcd_time,   // Converted time output (24-bit)
    output reg ampm               // AM/PM flag output
);

// Temporary storage for time based on clock mode
reg [23:0] bcd_time_temp;
reg formattimetoggle;

// Select clock or alarm time based on clock mode
always @* begin
    if (clk_mode == 2'b10)
        bcd_time_temp = alarm_time;
    else bcd_time_temp = clock_time;

    if (setampm == 1) begin
        // Toggle time format
        formattimetoggle = ~formattimetoggle;
    end

    if (formattimetoggle) // 24-hour format
        bcd_time = bcd_time_temp;
    else begin // 12-hour format
        if (bcd_time_temp[23:16] > 8'h12) begin // PM
            bcd_time[23:16] = bcd_time_temp[23:16] - 8'h12;
            ampm = 1; // Set PM flag
        end else begin // AM
            bcd_time[23:16] = bcd_time_temp[23:16];
            ampm = 0; // Set AM flag
        end
        bcd_time[15:0] = bcd_time_temp[15:0]; // Keep lower 16 bits unchanged
    end
end

endmodule
