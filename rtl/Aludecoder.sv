module Aludecoder  (
    input logic [2:0] funct3,
    input logic [6:0] funct7, // 7 bits wide
    input logic [1:0] ALUOp,
    input logic [6:0] op,
    output logic [3:0] ALUControl
);

always_comb begin
    case (ALUOp)
 
        // R-Type Instructions
        2'b10: begin
            case (funct3)
                3'b000: begin // ADD or SUB
                    if (funct7 == 7'b0100000)
                        ALUControl = 4'b0001; // SUB
                    else
                        ALUControl = 4'b0000; // ADD
                end
                3'b010: ALUControl = 4'b1000; //SLT
                3'b011: ALUControl = 4'b1001; //SLTU
                3'b100: ALUControl = 4'b0100; // XOR
                3'b110: ALUControl = 4'b0011; // OR
                3'b111: ALUControl = 4'b0010; // AND
                3'b001: ALUControl = 4'b0111; // SLL
                3'b101: begin // SRL or SRA
                    if (funct7[5] == 1'b1)
                        ALUControl = 4'b0110; // SRA
                    else
                        ALUControl = 4'b0101; // SRL
                end
                default: ALUControl = 4'b0000; // Default to ADD
            endcase
        end

        // I-Type Instructions
        2'b11: begin
            case (funct3)
                3'b000: ALUControl = 4'b0000; // ADDI
                3'b100: ALUControl = 4'b0100; // XORI
                3'b110: ALUControl = 4'b0011; // ORI
                3'b111: ALUControl = 4'b0010; // ANDI
                default: ALUControl = 4'b0000; // Default to ADD
            endcase
        end

        // Load/Store Instructions
        2'b00: begin
            ALUControl = 4'b0000; // ADD (calculate effective address)
        end

        // U-Type Instructions (LUI, AUIPC)
        2'b01: begin
            case (op)
                7'b0110111: ALUControl = 4'b1011; // LUI
                7'b0010111: ALUControl = 4'b1010; // AUIPC
                default: ALUControl = 4'b0000; // Default
            endcase
        end

        default: ALUControl = 4'b0000; // Default to ADD
    endcase
end

endmodule
