// clk should be 800kHz, used for clocking out data to the
// neopixel string
module neopixel (input clk,
                 input nrst,
                 input wire [383:0]framebuf,
                 output reg data);

    // Top-level, there are 49 states:
    //     0 corresponds to the 50us sync signal
    //     1-48 correspond to each of the 48 bytes of LED data
    reg [5:0] state;

    // Shift register for clocking out the bits in a byte.
    reg [7:0] shift_reg;

    // Counter is used for counting the bits out of a byte.
    reg [3:0] bit_count;

    // Counter used for metering out the 70us sync signal
    reg [5:0] sync_counter;

    always @(posedge clk) begin
        if (!nrst) begin
            data <= 0;
            shift_reg <= 0;
            bit_count <= 0;
            sync_counter <= 0;
            state <= 0;
        end else begin
            if (state == 0) begin
                // We are in the sync window, so output zero.
                data <= 0;
                if (sync_counter == 56) begin  // (800kHz * 80us = 56)
                    // Sync window is done, return to clocking bits.
                    state <= 1;
                    sync_counter <= 0;  // Reset for next time
                end else begin
                    // Sync window
                    sync_counter <= sync_counter + 1;
                end
            end else begin
                if (bit_count == 0) begin
                    // Finished clocking the last byte, so get the next
                    // one from the framebuf
                    shift_reg <= framebuf[state];
                    bit_count <= 8;
                    state <= state + 1;
                end else begin
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count - 1;
                end
                data <= shift_reg[0];
            end
            if (state == 48) begin
                // We have finished the framebuffer so sync window next
                state <= 0;
            end
        end
    end
endmodule
