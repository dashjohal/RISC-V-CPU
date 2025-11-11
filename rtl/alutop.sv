module alutop(              
    input logic [31:0] ImmOp,                
    input logic ALUsrc,
    input logic [31:0] ALUop1,
    input logic [31:0] ALUop2_in0,               
    input logic [3:0] ALUctrl,  // ALU control signal
    input logic [3:0] e_branch,
    input logic e_jump,
    output logic [31:0] ALUout,
    output logic e_pcsrc

);
    logic [31:0] ALUop2;
    logic EQ;
    logic C;
    logic S;  

    pcsrc pc_src(
        .e_branch(e_branch),
        .jump(e_jump),
        .EQ(EQ),
        .S(S),
        .C(C),
        .e_pcsrc(e_pcsrc)

    );

    // ALU Operand Multiplexer
    mux alu_mux (
        .in0(ALUop2_in0),
        .in1(ImmOp),
        .sel(ALUsrc),
        .out(ALUop2)
    );

    // ALU Instantiation
    alu my_alu (
        .ALUop1(ALUop1),          
        .ALUop2(ALUop2),       
        .ALUctrl(ALUctrl),  // Connect ALU control signal
        .ALUout(ALUout), 
        .EQ(EQ),             // Check if there is a branch or not
        .C(C),             //check for carry
        .S(S)              //check sign flag
        
    );

endmodule

