module mux3 #(
    parameter DATA_WIDTH = 32
)(
    input logic [DATA_WIDTH-1:0] in0, // Input 0
    input logic [DATA_WIDTH-1:0] in1, // Input 1
    input logic [DATA_WIDTH-1:0] in2, //Input 2
    input logic [1:0]            sel, //2-bit select signal
    output logic [DATA_WIDTH-1:0] out //Output

);
    always_comb begin 
        case(sel)
            2'b00: out = in0; //Select input 0
            2'b01: out = in1; //select input 1
            2'b10: out = in2; // select input 2

        default: out = {DATA_WIDTH{1'b0}};
        
        endcase

    end 

endmodule

