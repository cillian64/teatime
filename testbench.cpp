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
    tfp->open("teatime.fst");

    // Let's run for 10 seconds = 240,000,000 ticks @ 12MHz, 2 ticks per clk

    while (!Verilated::gotFinish() && main_time < 240000000ul) {
        // Release reset after 10 clocks
        top->RST_N = main_time > 20;

        // Push start button after 24,000,000 clocks = 1 second
        top->SW_START = main_time > 24000000;

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
