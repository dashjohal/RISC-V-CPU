module pipeline_e #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32
)(
    input logic clk, rst,       //Clock and Reset/Clear Signal
    input logic [DATA_WIDTH-1:0] d_rd1,   //decode stage RD1 data
    input logic [DATA_WIDTH-1:0] d_rd2,   //RD2 
    input logic [ADDRESS_WIDTH-1:0] d_pc,       //decode stage program counter
    input logic [4:0] d_ra1, d_ra2, d_rd,   //Register 1, 2 and Register destination addresses
    input logic [DATA_WIDTH-1:0] d_ImmExt, 
    input logic  [ADDRESS_WIDTH-1:0] d_pcplus4,
    input logic d_regwrite, d_memwrite,
    input logic [1:0] d_resultsrc,
    input logic d_jump,
    input logic [3:0] d_branch,
    input logic [3:0] d_alucontrol,
    input logic d_alusrc, d_jalr,
    output logic [DATA_WIDTH-1:0] e_rd1,    // Execute Stage RD1 data 
    output logic [DATA_WIDTH-1:0] e_rd2,   
    output logic [ADDRESS_WIDTH-1:0] e_pc,
    output logic [4:0] e_ra1, e_ra2, e_rd,
    output logic [DATA_WIDTH-1:0] e_ImmExt,
    output logic [ADDRESS_WIDTH-1:0] e_pcplus4,
    output logic e_regwrite, e_memwrite,
    output logic [1:0] e_resultsrc,
    output logic e_jump,
    output logic [3:0] e_branch,
    output logic [3:0] e_alucontrol,
    output logic e_alusrc, e_jalr
);

always_ff @ (posedge clk) begin
    if (rst) begin
        {e_rd1, e_rd2, e_pc, e_ra1, e_ra2, e_rd, e_ImmExt, e_pcplus4} <= '0;
        {e_regwrite,e_memwrite,e_resultsrc,e_jump,e_branch,e_alucontrol,e_alusrc,e_jalr} <= '0;
    end
    else begin
        e_rd1    <= d_rd1;
        e_rd2    <= d_rd2;
        e_pc     <= d_pc;
        e_ra1    <= d_ra1;
        e_ra2    <= d_ra2;
        e_rd     <= d_rd;
        e_ImmExt <= d_ImmExt;
        e_pcplus4 <= d_pcplus4;
        e_regwrite <= d_regwrite;
        e_memwrite <= d_memwrite;
        e_resultsrc <= d_resultsrc;
        e_jump <= d_jump;
        e_branch <= d_branch;
        e_alucontrol <= d_alucontrol;
        e_alusrc <= d_alusrc;
        e_jalr <= d_jalr;
    end
end
endmodule
