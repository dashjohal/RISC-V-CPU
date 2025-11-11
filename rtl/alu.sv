module alu #( 
    parameter WIDTH = 32
)( 
    input logic [WIDTH - 1:0]   ALUop1,    
    input logic [WIDTH - 1:0]   ALUop2,
    input logic [3:0]           ALUctrl,    
    output logic                EQ,
    output logic                C,          // Carry/Borrow flag (unsigned comparison)
    output logic                S,          // Sign flag (signed comparison)
    output logic [WIDTH - 1:0]  ALUout
);

wire signed [WIDTH - 1:0] ALUop1_signed;
assign ALUop1_signed = ALUop1;

wire signed [WIDTH - 1:0] ALUop2_signed;
assign ALUop2_signed = ALUop2;

logic [WIDTH:0] sub_result_unsigned;
logic [WIDTH -1:0] zero;


always_comb begin
    case(ALUctrl)
        4'b0000: ALUout = ALUop1 + ALUop2;               // ADD
        4'b0001: ALUout = ALUop1 - ALUop2;               // SUB
        4'b0010: ALUout = ALUop1 & ALUop2;               // AND
        4'b0011: ALUout = ALUop1 | ALUop2;               // OR
        4'b0100: ALUout = ALUop1 ^ ALUop2;               // XOR
        4'b0111: ALUout = ALUop1 << ALUop2;              // shift left logical 
        4'b0101: ALUout = ALUop1 >> ALUop2;              // shift right logical srl
        4'b0110: ALUout = ALUop1_signed >>> ALUop2;      // ASR
        4'b1000: ALUout = (ALUop1_signed < ALUop2_signed) ? 1 : 0; // SLT
        4'b1001: ALUout = (ALUop1 < ALUop2) ? 1 : 0;     // SLTU
        4'b1010: ALUout = ALUop1 + (ALUop2 << 12); // AUIPC: PC + (Imm << 12)
        4'b1011: ALUout = ALUop2 << 12; // LUI: Imm << 12
        default: ALUout = 0;                             // Default case
    endcase
    

    sub_result_unsigned = {1'b0, ALUop1} - {1'b0, ALUop2};
    C = sub_result_unsigned[WIDTH]; // Borrow flag 

    // Compute sign flag
    S = (ALUop1_signed - ALUop2_signed) < 0;

    // Set EQ if ALUout equals 0
    zero = ALUop1 - ALUop2;
    EQ = (zero == 0);    
end

endmodule
