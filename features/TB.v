module zellers_congruence_tb;

    reg [7:0] year;
    reg [7:0] month;
    reg [7:0] day;
    wire [2:0] day_of_week;
    
    zellers_congruence dut (
        .year(year),
        .month(month),
        .day(day),
        .day_of_week(day_of_week)
    );

initial begin
    $monitor("Time: %0t, %h - %h - %h, %h", $time, day, month, year, day_of_week);
    year = 8'h24;
    month = 8'h05;
    day = 8'h1;
    #100;
    repeat(30)    
    begin
        day = day + 1;
        #100;
    end

end

endmodule