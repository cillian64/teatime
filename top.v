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

    // Framebuffer array: 16 neopixels = 48 LEDs, each 8-bit. Order is GBR
    wire [383:0]framebuf;

    // Instantiate teatimer and display
    wire nrst;
    assign nrst = 1;
    teatimer mytt (clk_1, nrst, SW_START, SW_STOP, framebuf);
    neopixel mynp (clk_800k, nrst, framebuf, DATA);
endmodule
