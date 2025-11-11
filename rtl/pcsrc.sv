module pcsrc(
    input logic [3:0] e_branch,
    input logic jump,
    input logic EQ, S, C,
    output logic e_pcsrc
);

logic branch; 

always_comb begin
    branch = 0;
    e_pcsrc = 0;

    if (e_branch[3] == 1'b1) begin
        case(e_branch[2:0])
            3'b000: branch = EQ;      // beq
            3'b001: branch = ~EQ;     // bne
            3'b100: branch = S;       // blt
            3'b101: branch = ~S;      // bge
            3'b110: branch = C;       // bltu
            3'b111: branch = ~C;      // bgeu
            default: branch = 0;      // No branch
        endcase
    end

    e_pcsrc = branch || jump;


end
endmodule
