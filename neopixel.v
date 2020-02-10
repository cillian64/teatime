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

    // Counter used for metering out the 70us sync signal (800kHz * 80us = 56)
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
                if (sync_counter == 56) begin
                    // Sync window is done, return to clocking bits.
                    state <= 1;
                    sync_counter <= 0;
                end else begin
                    // Sync window
                    sync_counter <= sync_counter + 1;
                end
            end else begin
                if (bit_count == 0) begin
                    shift_reg <= framebuf[state];
                    bit_count <= 8;
                end else begin
                    shift_reg <= shift_reg >> 1;
                    bit_count <= bit_count - 1;
                end
                data <= shift_reg[0];
            end
            state <= state + 1;
        end
    end
endmodule
