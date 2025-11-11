module imm_ext(
    input  logic [31:0] instr,       // 32-bit instruction
    input  logic [2:0] ImmSrc,      // Immediate source selector (e.g., I-type, S-type, etc.)
    output logic [31:0] imm_ext_out  // Sign-extended immediate output
);

    // Immediate Type Constants
    localparam IMM_I = 3'b000;  // I-type
    
    localparam IMM_S = 3'b001;  // S-type
    localparam IMM_B = 3'b010;  // B-type
    localparam IMM_U = 3'b011;  // U-type
    localparam IMM_J = 3'b100;  // U-type




    always_comb begin
        case (ImmSrc)
            IMM_I: imm_ext_out = {{21{instr[31]}}, instr[30:20]}; // I-type: 12-bit sign-extended
            IMM_S: imm_ext_out = {{21{instr[31]}}, instr[30:25], instr[11:7]}; // S-type: 12-bit sign-extended
            IMM_B: imm_ext_out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type: 13-bit sign-extended
            IMM_U: imm_ext_out = {{12{instr[31]}}, instr[31:12]}; // U-type: Upper 20 bits, shifted
            IMM_J: imm_ext_out = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type: 21-bit sign-extended
            default: imm_ext_out = instr; // Default case (for safety)
        endcase
    end

endmodule
