module top(input CLK,
           output LED_GRN,
           output LED_RED0,
           output LED_RED1,
           output LED_RED2,
           output LED_RED3);

    // CLK is 12MHz from MEMS resonator
    // Divide by 1.2 million to get a 10Hz clock
    reg[21:0] divide;
    reg clk_10;
    always @(posedge CLK) begin
        divide <= divide + 1;
        if (divide == 1200000) begin
            divide <= 0;
            clk_10 <= ~clk_10;
        end
    end

    reg [3:0] leds;
    always @(posedge clk_10) begin
        if (leds == 8 || leds == 0) begin
            leds <= 1;
        end else begin
            leds <= leds << 1;
        end
    end

    assign LED_GRN = clk_10;
    assign LED_RED0 = leds[0];
    assign LED_RED1 = leds[1];
    assign LED_RED2 = leds[2];
    assign LED_RED3 = leds[3];
endmodule
