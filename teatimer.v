// clk should be 1Hz, used for timing.
module teatimer (input clk,
                 input nrst,
                 input sw_start,
                 input sw_stop,
                 output reg [383:0]framebuf);

    reg [7:0] counter;
    // counter sticks at 0 and 255, for any value
    // in-between it counts up.
    // counter == 0 is the "stopped" state with LEDs off
    // counter == 255 is the "finished" state.

    always @(posedge clk) begin
        if (!nrst) begin
            counter <= 8'b0;
        end else begin
            if (counter > 0 && counter < 255) begin
                counter <= counter + 1;
            end
            if (sw_start) begin
                counter <= 1;
            end
            if (sw_stop) begin
                counter <= 0;
            end
            framebuf <= counter;
        end
    end
endmodule
