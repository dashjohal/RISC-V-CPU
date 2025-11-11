module maindecoder (
    input logic [6:0] opcode,
    input logic [2:0] funct3, // to decode branch types
    
    output logic [3:0] branch,
    output logic jump,
    output logic [1:0] resultSrc,
    output logic memWrite,
    output logic aluSrc,
    output logic regWrite,
    output logic [2:0] ImmSrc,
    output logic [1:0] ALUOp,
    output logic       jalr 
);

always_comb begin
    // Default values
    branch[3] = 0;
    branch[2:0] = funct3;
    jump = 0;
    memWrite = 0;
    aluSrc = 0;
    regWrite = 0;
    resultSrc = 2'b00;
    jalr = 0;
    ImmSrc = 3'b000;
    ALUOp = 2'b00;

    case (opcode)
        // Load Instructions (I-Type)
        7'b0000011: begin
            aluSrc = 1;
            memWrite = 0;
            regWrite = 1;
            resultSrc = 2'b01;  // Memory load
            ImmSrc = 3'b000; // I-type immediate
            ALUOp = 2'b00;  // ADD for effective address
        end

        // Store Instructions (S-Type)
        7'b0100011: begin
            aluSrc = 1;
            memWrite = 1;
            regWrite = 0;
            ImmSrc = 3'b001; // S-type immediate
            ALUOp = 2'b00;  // ADD for effective address
        end

        // R-Type Instructions
        7'b0110011: begin
            aluSrc = 0;
            regWrite = 1;
            resultSrc = 2'b00;  // ALU result
            ALUOp = 2'b10;  // R-type operation
        end

        // I-Type Arithmetic (e.g., addi, xori)
        7'b0010011: begin
            aluSrc = 1;
            regWrite = 1;
            resultSrc = 2'b00;
            ImmSrc = 3'b000; // I-type immediate
            ALUOp = 2'b10;  // Delegate to ALU Decoder
        end

        // Branch Instructions (B-Type)   // this is wrong we need to include the flag
        7'b1100011: begin
            branch[3] = 1;
            branch[2:0] = funct3;
            memWrite = 0;
            aluSrc = 0;
            regWrite = 0;
            ImmSrc = 3'b010; // B-type immediate
            ALUOp = 2'b01;  // Branch operation

        end

        // JAL (J-Type)
        7'b1101111: begin
            jump = 1;
            regWrite = 1;
            resultSrc = 2'b10; // PC + 4
            ImmSrc = 3'b100;    // J-type immediate
            ALUOp = 2'b00;     // No ALU operation needed
            jalr = 0;
        end

        // JALR (I-Type)
        7'b1100111: begin
            jump = 1;
            aluSrc = 1;
            regWrite = 1;
            resultSrc = 2'b10; // PC + 4
            ImmSrc = 3'b000;    // I-type immediate
            ALUOp = 2'b00;     // ADD for rs1 + imm
            jalr = 1;
        end

        // LUI (U-Type)
        7'b0110111: begin
            aluSrc = 1;
            regWrite = 1;
            resultSrc = 2'b00; // ALU result
            ImmSrc = 3'b011;    // U-type immediate
            ALUOp = 2'b01;     // Custom operation for LUI
        end

        // AUIPC (U-Type)
        7'b0010111: begin
            aluSrc = 1;
            regWrite = 1;
            resultSrc = 2'b00; // ALU result
            ImmSrc = 3'b011;    // U-type immediate
            ALUOp = 2'b01;     // Custom operation for AUIPC
        end

        default: begin
            // Default values already set
        end
    endcase
end

endmodule
