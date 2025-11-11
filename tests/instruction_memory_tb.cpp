#include "testbench.h"
#include <cstdlib>
#include <vector>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class InstrMemTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->A = 0;
        // Initialize the instruction input, if needed
        // top->instr = 32'h00000000; // Example initialization
    }
};

TEST_F(InstrMemTestbench, AddrtoMachineCodeTest)
{
    system("./compile.sh asm/program.S"); // Ensure this script compiles your assembly code to the object file
    std::vector<unsigned int> machinecode = {
        32'hff00313, 32'h00000513, 32'h00000593,
        32'h00058513, 32'h00158593, 32'hfe659ce3, 32'hfe0318e3
    };
    bool success = true;
    for (int i = 0; i < 7; i++)
    {
        top->pcaddr = top->pcaddr + (4 * i); // Update pcaddr to point to the next instruction
        top->eval(); // Evaluate the DUT
        if (top->instr != machinecode[i])
        {
            FAIL() << "Mismatch at index " << i << ". Expected: " << std::hex << machinecode[i] << ", Got: " << top->instr;
            success = false;
            break;
        }
    }
    if (success)
    {
        SUCCEED() << "Correct Machine Code Output from Address";
    }
}

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
