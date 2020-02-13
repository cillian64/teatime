#include <stdio.h>

#include "verilated.h"
#include "verilated_vcd_c.h"

#include "Vtop.h"

vluint64_t main_time = 0;
double sc_time_stamp() {
    return main_time;
}

int main(int argc, char **argv, char **env) {
    Verilated::traceEverOn(true);
    Verilated::commandArgs(argc, argv);

    Vtop *top = new Vtop;

    VerilatedVcdC *tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    tfp->open("teatime.vcd");

    // Let's run for 10 seconds = 16,000,000 ticks @ 800kHz, 2 ticks per clk

    while (!Verilated::gotFinish() && main_time < 16000000ul) {
        // Release reset after 10 clocks
        top->RST_N = main_time > 20;

        // Push start button for the first 1 second = 1,600,000 clocks
        top->SW_START = main_time < 1600000;

        // Toggle clock with period of 2 ticks:
        top->CLK = main_time % 2;

        top->eval();

//        printf("At time %d, clk=%d rst_n=%d out=%d\n",
//               main_time, top->CLK, top->RST_N, top->DATA);

        tfp->dump(main_time);

        main_time++;
    }

    top->final();
    tfp->close();
    delete top;
    delete tfp;
    return 0;
}
