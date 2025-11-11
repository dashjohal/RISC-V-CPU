#include "noclktestbench.h"
#include <cstdlib>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class ExtTestbench : public Testbench {
protected:
    void initializeInputs() override {
        top->ImmSrc = 0b000;  // Default to I-type immediate
        top->instr = 0;       // Initialize the instruction to zero
    }
};

TEST_F(ExtTestbench, ITypeTest) {
    // Example for I-type immediate (sign-extended)
    top->ImmSrc = 0b000;  // Set ImmSrc for I-type
    top->instr = 0b00000000000100000000000000000011;  // Example I-type instruction
    top->eval();
    EXPECT_EQ(top->imm_ext_out, 0b00000000000000000000000000000001);  // Expected immediate value for I-type (no sign extension)
}

TEST_F(ExtTestbench, STypeTest) {
    // Example for S-type immediate (sign-extended with correct bit order)
    top->ImmSrc = 0b001;  // Set ImmSrc for S-type
    top->instr = 0b00000000001000000000000100100011;  // Example S-type instruction
    top->eval();
    EXPECT_EQ(top->imm_ext_out, 0b00000000000000000000000000000010);  // Expected result for S-type extension
}

TEST_F(ExtTestbench, BTypeTest) {
    // Example for B-type immediate (branch immediate)
    top->ImmSrc = 0b010;  // Set ImmSrc for B-type
    top->instr = 0b00000000000000000000000101100011;  // Example B-type instruction
    top->eval();
    EXPECT_EQ(top->imm_ext_out, 0b00000000000000000000000000000010);  // Expected B-type immediate value
}

TEST_F(ExtTestbench, UTypeTest) {
    // Example for U-type immediate (large value)
    top->ImmSrc = 0b011;  // Set ImmSrc for U-type
    top->instr = 0b10100110110100000000000000110111;  // Example U-type instruction
    top->eval();
    EXPECT_EQ(top->imm_ext_out, 0b11111111111110100110110100000000);  // Expected U-type immediate value (shifted)
}

TEST_F(ExtTestbench, JTypeTest) {
    // Example for J-type immediate (for jump instructions)
    top->ImmSrc = 0b100;  // Set ImmSrc for J-type
    top->instr = 0b01100000000000000000000001101111;  // Example J-type instruction
    top->eval();
    EXPECT_EQ(top->imm_ext_out, 0b00000000000000000000000000110000);  // Expected J-type immediate value
}

int main(int argc, char **argv) {
    top = new Vdut;  // Make sure to use the module name here
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
