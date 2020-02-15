// Memory model based on Lattice appnote "Memory Usage Guide for iCE40 Devices"

module ram (din, write_en, waddr, wclk, raddr, rclk, dout);
    // Treat the 256x16 embedded BRAM as 512x8
    // Hopefully yosys can figure it out.
    parameter addr_width = 9;
    parameter data_width = 8;

    input [addr_width-1:0] waddr;
    input [addr_width-1:0] raddr;
    input [data_width-1:0] din;
    input write_en;
    input wclk;
    input rclk;

    output reg [data_width-1:0] dout;

    reg [data_width-1:0] mem [(1<<addr_width)-1:0];

    always @(posedge wclk) begin // Write memory.
        if (write_en) begin
            mem[waddr] <= din;
        end
    end

    always @(posedge rclk) begin // Read memory.
        dout <= mem[raddr];
    end

    initial begin
        mem[0] = 255;
        mem[1] = 0;
        mem[2] = 0;
        mem[3] = 0;

        mem[4] = 0;
        mem[5] = 255;
        mem[6] = 0;
        mem[7] = 0;

        mem[8] = 0;
        mem[9] = 0;
        mem[10] = 255;
        mem[11] = 0;

        mem[12] = 0;
        mem[13] = 0;
        mem[14] = 0;
        mem[15] = 255;

        mem[16] = 255;
        mem[17] = 0;
        mem[18] = 0;
        mem[19] = 0;

        mem[20] = 0;
        mem[21] = 255;
        mem[22] = 0;
        mem[23] = 0;

        mem[24] = 0;
        mem[25] = 0;
        mem[26] = 255;
        mem[27] = 0;

        mem[28] = 0;
        mem[29] = 0;
        mem[30] = 0;
        mem[31] = 255;
    end
endmodule
