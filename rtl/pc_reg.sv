module pc_reg #(
    parameter WIDTH = 32
)(
    //Interface signals
    input logic             clk,    //clock
    input logic             rst,    //reset
    input logic             trigger,     //trigger
    input logic             en,      //enable
    input logic [WIDTH-1:0] next_pc, //next count
    output logic [WIDTH-1:0] count   //program counter output
);

always_ff @ (posedge clk)
    if (rst)        count <= {WIDTH{1'b0}};
    else if (trigger && en)    count <= next_pc;

endmodule
