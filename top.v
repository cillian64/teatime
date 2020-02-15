`default_nettype none

module top(input CLK_12M,
           input SW_START,
           input SW_STOP,
           output DATA);

    // CLK is 12MHz from MEMS resonator.  Put it through the PLL to get 20MHz
    wire clk_20M;
    wire locked;
    pll mypll(CLK_12M, clk_20M, locked);

    // Divide by 20M to get 1Hz clk for timer
    reg [24:0] divide20M;
    wire clk_1;
    always @(posedge clk_20M) begin
        if (divide20M == 19999999) begin
            divide20M <= 0;
            clk_1 <= ~clk_1;
        end else begin
            divide20M <= divide20M + 1;
        end
    end

    // Instantiate a BRAM for framebuf
    // Share clocks with timer and neopixel modules:
    // wclk comes from the 1Hz teatimer clock
    // rclk comes from the neopixel clock
    wire write_en;
    assign write_en = 0;
    wire [8:0] r_addr, w_addr;
    wire [7:0] din, dout;
    ram framebuf (din, write_en, w_addr, clk_1, r_addr, clk_20M, dout);

    // Instantiate teatimer and display
 //   teatimer mytt (clk_1, clk_20M, locked, SW_START, SW_STOP, w_addr, din,
 //                  write_en);
    neopixel mynp (clk_20M, locked, r_addr, dout, DATA);
endmodule
