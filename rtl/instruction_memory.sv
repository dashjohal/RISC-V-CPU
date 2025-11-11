module instruction_memory #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 32,         
                ADDRESS_AVAILABLE_WIDTH = 12,  
                ARRAY_WIDTH = 8
                


)(
    input logic [ADDRESS_WIDTH-1:0] A,   
    output logic [DATA_WIDTH-1:0] instr     
);

   
    logic [ARRAY_WIDTH-1:0] rom_array [2**ADDRESS_AVAILABLE_WIDTH-1:0];
    

  
    initial begin

        $readmemh("program.hex", rom_array);
    end

    assign instr = {rom_array[A+3], rom_array[A+2], rom_array[A+1], rom_array[A]} ;  

endmodule
