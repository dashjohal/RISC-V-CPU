#include "testbench.h"
#include <cstdlib>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class PCTestbench : public Testbench
{
protected:

    vluint64_t main_time;

    void initializeInputs() override
    {
        top->clk = 1;
        top->rst = 0;
        top->PCsrc = 0;
        top->trigger = 1;
        top->en = 1;
        top->programcount = 0x0000;
    }

    void advanceClock() {
    for (int i = 0; i < 2; ++i) { // Toggle clock
        top->clk = !top->clk;
        top->eval();
        ++main_time;
    }
    }
};

TEST_F(PCTestbench, IncrementTest) {
    EXPECT_EQ(top->programcount, 0); // Program counter starts at 0
    advanceClock();
    EXPECT_EQ(top->programcount, 4); // Increment by 4
    advanceClock();
    EXPECT_EQ(top->programcount, 8); // Increment by another 4
}

TEST_F(PCTestbench, JumpTest) {
    // Set immediate value for the jump
    top->jump_branchPC = 0x1000; // Immediate offset
    top->PCsrc = 1;      // Enable branching

    advanceClock(); // One clock cycle to update PC

    EXPECT_EQ(top->programcount, 0x1000) << "Jump works correctly."; // Expect PC to jump to 0x1000
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
