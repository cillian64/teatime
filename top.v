`default_nettype none

module top(input CLK_12M,
           input SW_START,
           input SW_STOP,
           output DATA);

    // CLK is 12MHz from MEMS resonator.  Put it through the PLL to get 20MHz
    wire clk_20M;
    wire locked;
    pll mypll(CLK_12M, clk_20M, locked);

    neopixel mynp (clk_20M, locked, DATA);
endmodule
