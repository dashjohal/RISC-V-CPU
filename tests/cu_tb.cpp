#include "testbench.h"
#include <cstdlib>

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class CUTestbench : public Testbench
{
protected:
    void initializeInputs() override
    {
        top->opcode = 0;
        top->funct3= 0;
        top->funct7 = 0;


    }
};

TEST_F(CUTestbench, ADDITest)
{
    top->opcode = 0b0010011;
    top->funct3 = 0b000;
    top->funct7 = 0b0;
    top->eval();
    EXPECT_EQ(top->resultSrc, 0b01);
    EXPECT_EQ(top->memWrite, 0b0);
    EXPECT_EQ(top->aluSrc, 0b1);
    EXPECT_EQ(top->ImmSrc, 0b000);
    EXPECT_EQ(top->regWrite, 0b1);
    EXPECT_EQ(top->ALUControl, 0b0000); 
}

TEST_F(CUTestbench, BranchTest)
{
    top->opcode = 0b1100011;
    top->funct3 = 0b001;
    top->eval();
    EXPECT_EQ(top->memWrite, 0b0);
    EXPECT_EQ(top->aluSrc, 0b0);
    EXPECT_EQ(top->ImmSrc, 0b010);
    EXPECT_EQ(top->regWrite, 0b0);
    EXPECT_EQ(top->ALUControl, 0b0111);  
    EXPECT_EQ(top->branch, 0b1001);  

}

// TEST_F(CUTestbench, RTest)
// {
    
// }
//Maybe, Test counter by creating a sequence test (Use Vector)

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
