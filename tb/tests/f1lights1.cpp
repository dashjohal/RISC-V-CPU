#include<utility>
#include "Vdut.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "vbuddy.cpp"
#include <cstdlib>
#include <iostream>
#include <unistd.h> // for sleep()
#include "verilated_vcd_c.h"



int main(int argc, char **argv, char **env) {
    std::string name= "f1";
    std::ignore = system(("./assemble.sh asm/" + name+ ".s").c_str());
    // Create default empty file for data memory
    std::ignore = system("touch data.hex");
    int i;              //# of cycles to simulate
    int clk;

    Verilated::commandArgs(argc, argv);
    // init top verilog instance
    Vdut* top = new Vdut;
    // init trace dumpx
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace (tfp,99);
    tfp->open ("f1lights1.vcd");

    //init Vbuddy
    if (vbdOpen()!=1) return (-1);
    vbdHeader("F1 lights");

    //initialize simulation inputs
    top->clk = 1;
    top->rst = 0;
    top->trigger = 1;

    //run simulation for many clock cycles
    for (i=0; i<10000;i++) {
        //dump variables into VCD file and toggle clock
        for (clk =0;clk<2;clk++) { 
            tfp->dump (2*i+clk);
            top->clk = !top->clk;
            top->eval();
        }

        vbdBar(top->a0 & 0xFF);

        
        top->rst = false ;
        top->trigger = true;
    // either simulation finished, or 'q' is pressed
    if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) 
      exit(0);                // ... exit if finish OR 'q' pressed    
    }

    vbdClose();
    tfp->close();
    exit(0);
}
