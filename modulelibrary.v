module button(
    input button,              // Button input
    output reg buttontoggle   // Toggle output
);

// Initialize output
initial begin
    buttontoggle = 1'b0;   // Initialize output
end

// Detect positive edge of the button
always @(posedge button) begin
    buttontoggle <= ~buttontoggle; // Toggle output
end
endmodule