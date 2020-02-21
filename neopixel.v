`default_nettype none

// clk should be 20MHz, used for clocking out data to the neopixel string
module neopixel (input clk_20M,
                 input nrst,
                 output reg data);

    // State counters:
    // Top-level, there are 49 states:
    //     0 corresponds to the 50us sync signal
    //     1-48 correspond to each of the 48 bytes of LED data
    reg [5:0] state;

    // Counter is used for counting the bits out of a byte.
    reg [3:0] bit_count;

    // Used for timing the waveform within each bit
    reg [5:0] waveform_timer;

    // Counter used for metering out the 70us sync signal
    reg [10:0] sync_counter;

    // Shift register for clocking out the bits in a byte.
    reg [7:0] shift_reg;

    always @(posedge clk_20M) begin
        if (!nrst) begin
            // Initialise counters
            state <= 0;
            bit_count <= 0;
            waveform_timer <= 0;
            sync_counter <= 0;
            shift_reg <= 0;

            // Initialise output (fake sync window)
            data <= 0;
        end else begin
            if (state == 0) begin
                // We are in the sync window, so output zero.
                data <= 0;
                if (sync_counter == 1599) begin  // (20MHz * 80us = 1600)
                    // Sync window is done, next state returns to clocking bits
                    state <= 1;
                    sync_counter <= 0;  // Reset for next time
                    // TODO: We essentially need to pre-load the shift register
                    // here, otherwise it will get a garbage value at the
                    // beginning of state 1.
                    // TODO: we might also need to reset bit_count or
                    // waveform_timer??
                end else begin
                    // Next state is still in sync counter.
                    sync_counter <= sync_counter + 1;
                end
            end else begin
                if (waveform_timer == 24) begin
                    // We have finished a single bit's waveform
                    waveform_timer <= 0;

                    if (bit_count == 0) begin
                        // Finished bits out of a byte, so get the next byte
                        // Pixel order is G, R, B
                        // Note that all of these are 1-early because we need
                        // to get the shift register ready in time for the next
                        // clock
                        if (state == 0) shift_reg <= 255;  // G
                        else if (state == 4) shift_reg <= 255; // R
                        else if (state == 8) shift_reg <= 255; // B
                        else if (state == 9) shift_reg <= 255;  // G
                        else if (state == 13) shift_reg <= 255;  // R
                        else if (state == 17) shift_reg <= 255;  // B
                        else if (state == 18) shift_reg <= 255;  // G
                        else if (state == 22) shift_reg <= 255;  // R
                        else if (state == 26) shift_reg <= 255;  // B
                        else shift_reg <= 0;

                        bit_count <= 7;

                        // Are we finished clocking bytes?
                        if (state == 48) begin
                            // Yes: next state is in sync window.
                            state <= 0;
                        end else begin
                            // No: next byte!
                            state <= state + 1;
                        end
                    end else begin
                        // Just get the next bit from this byte.
                        shift_reg <= shift_reg << 1;
                        bit_count <= bit_count - 1;
                    end
                end else begin
                    waveform_timer <= waveform_timer + 1;
                end

                // Output depends on position in waveform and current data bit
                if (shift_reg[7] == 0) begin
                    if (waveform_timer >= 6) begin
                        data <= 0;
                    end else begin
                        data <= 1;
                    end
                end else begin // shift_reg[0] == 1
                    if (waveform_timer >= 12) begin
                        data <= 0;
                    end else begin
                        data <= 1;
                    end
                end
            end
        end
    end
endmodule
