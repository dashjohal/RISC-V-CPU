module cu (
    input logic [6:0] opcode,      // Opcode field
    input logic [2:0] funct3,      // funct3 field
    input logic[6:0] funct7,            // funct7 MSB
    output logic[1:0] resultSrc,        // Result source (memory or ALU or program_counter)
    output logic memWrite,         // Memory write enable
    output logic aluSrc,           // ALU source
    output logic regWrite,         // Register write enable
    output logic [2:0] ImmSrc,     // Immediate format
    output logic [3:0] ALUControl,  // ALU operation control signals
    output logic [3:0] branch,
    output logic jalr,
    output logic jump
);
    logic [1:0] ALUOp;             // ALU operation code


    // Instantiate Main Decoder
    maindecoder mainDecoder (
        .opcode(opcode),
        .funct3(funct3),
        .branch(branch),
        .memWrite(memWrite),
        .aluSrc(aluSrc),
        .regWrite(regWrite),
        .resultSrc(resultSrc),
        .ImmSrc(ImmSrc),
        .ALUOp(ALUOp),
        .jump(jump),
        .jalr(jalr)
    );

    // Instantiate ALU Decoder
    Aludecoder aluDecoder (
        .ALUOp(ALUOp),
        .funct3(funct3),
        .op(opcode),
        .funct7(funct7),
        .ALUControl(ALUControl)
    );

    // Combine Branch and Zero to determine PCSrc
endmodule
