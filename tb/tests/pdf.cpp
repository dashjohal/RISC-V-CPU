#include <cstdlib>
#include <iostream>
#include <unistd.h>  // For sleep()
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vdut.h"
#include "vbuddy.cpp"

int main(int argc, char **argv, char **env) {
    std::string name = "5_pdf";  // Set the program name (change from "f1" to "pdf")
    std::ignore = system(("./assemble.sh asm/" + name + ".s").c_str());  // Assemble PDF program
    std::string data_file = "reference/triangle.mem"; 
    std::ignore = system(("cp " + data_file + " data.hex").c_str());

    int i, clk;

    Verilated::commandArgs(argc, argv);  // Initialize Verilator
    Vdut* top = new Vdut;  // Instantiate the Verilog DUT
    Verilated::traceEverOn(true);  // Enable tracing
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Set trace level
    tfp->open("5_pdf.vcd");  // Open VCD file for dumping simulation data

    // Initialize Vbuddy
    if (vbdOpen() != 1) return (-1);  // Open Vbuddy interface
    vbdHeader("PDF Generation");  // Display header on Vbuddy

    // Initialize simulation inputs
    top->clk = 1;  // Set clock to 1
    top->rst = 0;  // Set reset to 0 (active low)
    top->trigger = 1;  // Trigger signal set to 1

    // Run simulation for 1000000 clock cycles
    for (i = 0; i < 1000000; i++) {
        for (clk = 0; clk < 2; clk++) {
            tfp->dump(2 * i + clk);  // Dump the simulation data
            top->clk = !top->clk;  // Toggle clock
            top->eval();  // Evaluate the Verilog model
        }

        // Display PDF data to Vbuddy
        if(top->t4 == 1 && top->a0 >= 0) {

             vbdPlot(top->a0, 0, 255);
       
        }

        top->rst = false;  // Deassert reset
       
        top->trigger = true;  // Keep trigger active

        // Exit if the simulation finishes or the 'q' key is pressed
        if ((Verilated::gotFinish()) || (vbdGetkey() == 'q')) {
            exit(0);
        }
    }

    vbdClose();  // Close Vbuddy
    tfp->close();  // Close trace file
    exit(0);  // End the program
}
