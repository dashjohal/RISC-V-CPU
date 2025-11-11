module pipeline_d #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32
)(
    input logic clk, en, rst,       //Clock, Enable and Reset/Clear Signal
    input logic [DATA_WIDTH-1:0] f_instr,   //fetch stage instruction
    input logic [ADDRESS_WIDTH-1:0] f_pc,   //new program counter
    input logic [ADDRESS_WIDTH-1:0] f_pcplus4,
    output logic [DATA_WIDTH-1:0] d_instr,   
    output logic [ADDRESS_WIDTH-1:0] d_pc,   
    output logic [ADDRESS_WIDTH-1:0] d_pcplus4
);

always_ff @ (posedge clk) begin
    if (rst) begin
        {d_instr, d_pc,d_pcplus4} <= '0;
    end
    else if (en) begin
        d_instr <= f_instr;
        d_pc <= f_pc;
        d_pcplus4 <= f_pcplus4;
    end
end
endmodule
