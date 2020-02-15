module top(input CLK,
           input SW_START,
           input SW_STOP,
           output DATA);

    // CLK is 12MHz from MEMS resonator
    // Divide by 15 to get 800kHz for neopixels
    reg[3:0] divide15;
    always @(posedge CLK) begin
        divide15 <= divide15 + 1;
        if (divide15 == 15) begin
            divide15 <= 0;
        end
    end
    wire clk_800k;
    assign clk_800k = divide15[3];

    // Divide by 800k to get 1Hz clk for timer
    reg [19:0] divide800k;
    always @(posedge clk_800k) begin
        divide800k <= divide800k + 1;
        if (divide800k == 799999) begin
            divide800k <= 0;
        end
    end
    wire clk_1;
    assign clk_1 = divide800k[19];

    // Instantiate a BRAM for framebuf
    // Share clocks with timer and neopixel modules:
    // wclk comes from the 1Hz teatimer clock
    // rclk comes from the 800kHz neopixel clock
    wire write_en;
    wire [8:0] raddr, waddr;
    wire [7:0] din, dout;
    ram framebuf (din, write_en, waddr, clk_1, raddr, clk_800k, dout);

    // Instantiate teatimer and display
 //   teatimer mytt (clk_1, clk_800k, 1, SW_START, SW_STOP, waddr, din,
 //                  write_en);
    neopixel mynp (clk_800k, 1, raddr, dout, DATA);
endmodule
