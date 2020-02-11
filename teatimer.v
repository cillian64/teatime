// clk should be 1Hz, used for timing.
module teatimer (input clk,
                 input nrst,
                 input sw_start,
                 input sw_stop,
                 output reg [383:0]framebuf);

    reg [3:0] sec_counter;  // counts seconds
    reg [3:0] sec16_counter;  // Counts 16-second blocks
    integer i; // loop counter

    // Two states are special:
    //   both counters == 0 is the "stopped" state
    //   both counters == 15 is the "done" state

    always @(posedge clk) begin
        if (!nrst) begin
            sec_counter <= 0;
            sec16_counter <= 0;
            framebuf <= 0;
        end else begin
            if (sec_counter == 0 && sec16_counter == 0) begin
                // Stopped state
                framebuf <= 0;
            end else if (sec_counter == 15 && sec16_counter == 15) begin
                // Done state: all LEDs white
                for (i = 0; i < 48; i++) begin
                    framebuf[8*i+7:8*i] <= 1;
                end
            end else begin
                // Counting state

                // Increment counters
                if (sec_counter == 15) begin
                    sec16_counter <= sec16_counter + 1;
                end
                sec_counter <= sec_counter + 1;
            end

            // Handle button presses
            if (sw_start) begin
                sec_counter <= 1;
            end
            if (sw_stop) begin
                sec_counter <= 0;
                sec16_counter <= 0;
                framebuf <= 0;
            end

            // Turn on appropriate LEDs based on counters:
            //     Second counter turns on blue pixels
            //     16-second counter turns on green pixels
            // Sub-pixel order in framebuf is G, R, B (24 bits per pixel)
            if (sec_counter > 0) begin
                framebuf[(sec_counter-1)*24+23:(sec_counter-1)*24+16] <= 255;
            end
            if (sec16_counter > 0) begin
                framebuf[(sec16_counter-1)*24+7:(sec16_counter-1)*24] <= 255;
            end
        end
    end
endmodule
