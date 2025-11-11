module RegisterFile (
    input logic clk,                  // Clock signal
    input logic [4:0] AD1,            // Address 1 (5 bits) for RD1
    input logic [4:0] AD2,            // Address 2 (5 bits) for RD2
    input logic [4:0] AD3,            // Address 3 (5 bits) for write address
    input logic WE3,                  // Write enable for register file
    input logic [31:0] WD3,           // Data to write (32 bits)
    output logic [31:0] RD1,          // Data output for RD1
    output logic [31:0] RD2, 
    output logic [31:0] a0,t4,t1,t2         // Data output for RD2

);

logic [31:0] registers [31:0];


always_comb begin
    RD1 = registers[AD1];
    RD2 = registers[AD2];
    a0 = registers[10];
    t4 = registers[29];
    t1 = registers[6];
    t2 = registers[7];

    
end


always_ff @(negedge clk) begin
  
    if(WE3) begin
    registers[AD3] <= WD3;
    end
    registers[0] <= 32'b0;
end
    
endmodule
