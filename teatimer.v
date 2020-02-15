module teatimer (input clk_1,
                 input clk_800k,
                 input nrst,
                 input sw_start,
                 input sw_stop,
                 output reg [8:0] w_addr,
                 output reg [7:0] dout,
                 output reg write_en);

    // Counters written by 1Hz block and read async by the 800kHz block
    reg [3:0] sec_counter;  // counts seconds
    reg [3:0] sec16_counter;  // Counts 16-second blocks

    // Handle the counters on the 1Hz clock
    always @(posedge clk_1) begin
        if (!nrst) begin
            sec_counter <= 0;
            sec16_counter <= 0;
        end else begin
            if (sec_counter == 0 && sec16_counter == 0) begin
                // Stopped state: do nothing
            end else if (sec_counter == 15 && sec16_counter == 15) begin
                // Done state: do nothing.
            end else begin
                // Counting state: increment counters
                if (sec_counter == 15) begin
                    sec16_counter <= sec16_counter + 1;
                end
                sec_counter <= sec_counter + 1;
            end

            // Handle button presses
            // TODO: be faster so I don't have to hold buttons for up to 1s
            // Probably catch the button press in a faster block and set a
            // flag which causes counters to be cleared in this block.
            if (sw_start) begin
                if (sec_counter == 0 && sec16_counter == 0) begin
                    sec_counter <= 1;
                end
            end
            if (sw_stop) begin
                sec_counter <= 0;
                sec16_counter <= 0;
            end
        end
    end

    // This is just 800kHz for convenience (to match the neopixel driver)
    // It just needs to be much faster than 1Hz.
    always @(posedge clk_800k) begin
        // Sub-pixel order in framebuf is G, R, B (24 bits per pixel)
        // However, use a memory format of G, R, B, 0 (32 bits) for ease.
        //
        // Keep cycling the write address through the valid addresses,
        // writing continually.  We just change the data lines depending on
        // what the LED at a particular location should display, depending on
        // state (i.e. nrst, sec_counter, sec16_counter).
        if (w_addr == 63) begin
            w_addr <= 0;
        end else begin
            w_addr <= w_addr + 1;
        end
        write_en <= 1;

        if (!nrst) begin
            dout <= 0;
        end else begin
            if (w_addr % 4 == 0) begin
                // Green pixel, used for sec16 counter
                if (w_addr / 4 < sec16_counter) begin
                    dout <= 255;
                end else begin
                    dout <= 0;
                end
            end else if (w_addr % 4 == 1) begin
                // Red pixel: always off
                dout <= 0;
            end else if (w_addr % 4 == 2) begin
                // Blue pixel, used for second counter
                if (w_addr / 4 == sec_counter) begin
                    dout <= 255;
                end else begin
                    dout <= 0;
                end
            end else begin
                // Unused
                dout <= 0;
            end
        end
    end
endmodule
