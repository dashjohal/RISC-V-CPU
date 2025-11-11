module pipeline_w #(
    parameter DATA_WIDTH = 32,
    parameter ADDRESS_WIDTH = 32
)(
    input logic clk,       //Clock Signal
    input logic [DATA_WIDTH-1:0] m_aluresult,   //memory stage ALU Result
    input logic [DATA_WIDTH-1:0] m_readdata,   //memory write read data output
    input logic [4:0] m_rd,       //m_stage write/destination register address
    input logic [ADDRESS_WIDTH-1:0] m_pcplus4,  
    input logic m_regwrite,
    input logic [1:0] m_resultsrc,

    output logic [DATA_WIDTH-1:0] w_aluresult,   
    output logic [DATA_WIDTH-1:0] w_readdata,   
    output logic [4:0] w_rd,       
    output logic [ADDRESS_WIDTH-1:0] w_pcplus4,  
    output logic w_regwrite,
    output logic [1:0] w_resultsrc

);

always_ff @ (posedge clk) begin
    w_aluresult <= m_aluresult;
    w_readdata  <= m_readdata;
    w_rd        <= m_rd;
    w_pcplus4   <= m_pcplus4;
    w_regwrite  <= m_regwrite;
    w_resultsrc <= m_resultsrc;
    w_readdata  <= m_readdata;
end

endmodule
