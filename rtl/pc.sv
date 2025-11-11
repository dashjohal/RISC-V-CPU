module pc #(
    parameter WIDTH = 32
)(
    input  logic        clk,           // Clock signal
    input  logic        rst,           // Reset signal (active high)
    input  logic        PCsrc,         // Control signal for the MUX
    input logic             trigger, //trigger
    input logic         en,
    input logic [WIDTH -1:0] jump_branchPc,
    output logic [WIDTH-1:0] programcount,      // Current PC value
    output logic [WIDTH-1:0] pcplus4  // OUTPUT for the next pc value for external use
    
   
);

    logic [WIDTH-1:0] next_PC;
    logic [WIDTH-1:0] inc_PC;



    assign inc_PC = programcount + 32'd4; // Add 4 to PC
    assign pcplus4  = inc_PC;

  
   

mux calc_next_PC (
    .in0 (inc_PC),
    .in1 (jump_branchPc),
    .sel (PCsrc),
    .out (next_PC)
);

pc_reg pc_reg (
    .clk (clk),
    .rst (rst),
    .next_pc (next_PC),
    .count (programcount),
    .trigger(trigger),
    .en(en)
);


endmodule
