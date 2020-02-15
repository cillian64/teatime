// clk should be 20MHz, used for clocking out data to the neopixel string
module neopixel (input clk,
                 input nrst,
                 input wire [383:0]framebuf,
                 output reg data);

    // State counters:
    // Top-level, there are 49 states:
    //     0 corresponds to the 50us sync signal
    //     1-48 correspond to each of the 48 bytes of LED data
    reg [5:0] state;

    // Counter is used for counting the bits out of a byte.
    reg [3:0] bit_count;

    // Used for timing the waveform within each bit
    reg [6:0] waveform_timer;

    // Counter used for metering out the 70us sync signal
    reg [10:0] sync_counter;

    // Shift register for clocking out the bits in a byte.
    reg [7:0] shift_reg;

    always @(posedge clk) begin
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
                end else begin
                    // Next state is still in sync counter.
                    sync_counter <= sync_counter + 1;
                end
            end else begin
                if (waveform_timer == 124) begin
                    // We have finished a single bit's waveform
                    waveform_timer <= 0;

                    if (bit_count == 0) begin
                        // Finished bits out of a byte, so get the next byte
                        // from the framebuf
                        shift_reg <= framebuf[8 * (state - 1) +: 8];
                        bit_count <= 8;

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
                        shift_reg <= shift_reg >> 1;
                        bit_count <= bit_count - 1;
                    end
                end else begin
                    waveform_timer <= waveform_timer + 1;
                end

                // Output depends on position in waveform and current data bit
                if (shift_reg[0] == 0) begin
                    if (waveform_timer >= 8) begin
                        data <= 1;
                    end else begin
                        data <= 0;
                    end
                end else begin // shift_ref[0] == 1
                    if (waveform_timer >= 16) begin
                        data <= 1;
                    end else begin
                        data <= 0;
                    end
                end
            end
        end
    end
endmodule
