module hazardunit #(
    //parameter DATA_WIDTH = 32,
    //parameter ADDRESS_WIDTH = 32
)(
    input logic [4:0] d_ra1, d_ra2,     //Decode stage Register Address 1 & 2
    input logic [4:0] e_ra1, e_ra2, e_rd,
    input logic e_pcsrc,                //Execute stage PCsrc
    input logic e_resultsrc,
    input logic [4:0] m_rd, w_rd,        //Memory stage write registers
    input logic m_regwrite, w_regwrite,
    output logic f_stall, d_stall,      //Data control stall signals
    output logic d_flush, e_flush,      //Flush signals
    output logic [1:0] e_forwardA, e_forwardB   //Forwarding Signals
);

    logic data_stall;
    assign data_stall = e_resultsrc && ((d_ra1 == e_rd) || (d_ra2 == e_rd));


always_comb begin
    
    f_stall    = 0;     //default values
    d_stall    = 0;
    d_flush    = 0;
    e_flush    = 0;
    e_forwardA = 2'b00;
    e_forwardB = 2'b00;

    f_stall = data_stall;
    d_stall = data_stall;

    d_flush = e_pcsrc;
    e_flush = data_stall | e_pcsrc;

    if (m_regwrite && (e_ra1 != 0) && (m_rd == e_ra1)) 
        e_forwardA = 2'b10; // Forward from memory stage
    else if (w_regwrite && (e_ra1 != 0) && (w_rd == e_ra1)) 
        e_forwardA = 2'b01; // Forward from writeack stage
    else 
        e_forwardA = 2'b00; // No forwarding
    
    if (m_regwrite && (e_ra2 != 0) && (m_rd == e_ra2)) 
        e_forwardB = 2'b10; // Forward from MEM stage
    else if (w_regwrite && (e_ra2 != 0) && (w_rd == e_ra2)) 
        e_forwardB = 2'b01; // Forward from WB stage
    else 
        e_forwardB = 2'b00; // No forwarding



end

endmodule
