#include "noclktestbench.h"
#include <cstdlib>

Vdut *top;  // ALU DUT instance

class ALUTestbench : public Testbench {
public:
    void initializeInputs() override {
        top->ALUop1 = 0;      // Input operand 1
        top->ALUop2 = 0;      // Input operand 2
        top->ALUctrl = 0;     // ALU control signal
    }

    void runTest(int op1, int op2, int ctrl, int expectedOut, int expectedEQ) {
        top->ALUop1 = op1;
        top->ALUop2 = op2;
        top->ALUctrl = ctrl;
        top->eval();  // Evaluate combinational logic
        EXPECT_EQ(top->ALUout, expectedOut);
        EXPECT_EQ(top->EQ, expectedEQ);
    }
};

TEST_F(ALUTestbench, AdditionTest) {
    runTest(20, 10, 0b0000, 30, 0);  // Addition
}

TEST_F(ALUTestbench, SubtractionTest) {
    runTest(50, 20, 0b0001, 30, 0);  // Subtraction
}

TEST_F(ALUTestbench, LogicalAndTest) {
    runTest(0b1010, 0b1100, 0b0010, 0b1000, 0);  // AND
}

TEST_F(ALUTestbench, LogicalOrTest) {
    runTest(0b1010, 0b1100, 0b0011, 0b1110, 0);  // OR
}

TEST_F(ALUTestbench, SLTTest) {
    runTest(-5, 10, 0b1000, 1, 0);  // Set Less Than (signed)
}

TEST_F(ALUTestbench, SLTUTest) {
    runTest(5, 10, 0b1001, 1, 0);  // Set Less Than Unsigned
}

TEST_F(ALUTestbench, ShiftLeftLogicalTest) {
    runTest(1, 3, 0b0111, 8, 0);  // Logical Shift Left
}

TEST_F(ALUTestbench, AUIPCTest) {
    runTest(100, 5, 0b1010, 100 + (5 << 12), 0);  // Add Upper Immediate to PC
}

int main(int argc, char **argv) {
    top = new Vdut;

    Verilated::traceEverOn(true);

    testing::InitGoogleTest(&argc, argv);
    int res = RUN_ALL_TESTS();

    top->final();
    delete top;

    return res;  // Return test result status
}
