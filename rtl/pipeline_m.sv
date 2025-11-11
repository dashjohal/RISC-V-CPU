module pipeline_m #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32
)(
    input logic clk,       //Clock Signal
    input logic [2:0] e_funct3,
    input logic [DATA_WIDTH-1:0] e_aluresult,   //execute stage ALU Result
    input logic [DATA_WIDTH-1:0] e_wdata,   //e_stage write data
    input logic [4:0] e_rd,       //e_stage write/destination register address
    input logic [ADDRESS_WIDTH-1:0] e_pcplus4,
    input logic e_regwrite, e_memwrite,
    input logic [1:0] e_resultsrc,  
    output logic [DATA_WIDTH-1:0] m_aluresult,   
    output logic [DATA_WIDTH-1:0] m_wdata,   
    output logic [4:0] m_rd,       
    output logic [ADDRESS_WIDTH-1:0] m_pcplus4,  
    output logic m_regwrite, m_memwrite,
    output logic [1:0] m_resultsrc,         
    output logic [2:0] m_funct3 
);

always_ff @ (posedge clk) begin
    m_aluresult <= e_aluresult;
    m_wdata     <= e_wdata;
    m_rd        <= e_rd;
    m_pcplus4   <= e_pcplus4;
    m_regwrite  <= e_regwrite;
    m_memwrite  <= e_memwrite;
    m_resultsrc <= e_resultsrc;
    m_funct3  <= e_funct3;
end

endmodule
