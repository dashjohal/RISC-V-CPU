module datamemory #(
    parameter   ADDRESS_WIDTH = 32,
                DATA_WIDTH = 32,
                ADDRESS_AVAILABLE_WIDTH = 17,
                ARRAY_WIDTH = 8
)(
    input logic                  clk,
    input logic                  WE, // Write Enable
    input logic [2:0]           funct3, // 
    input logic [ADDRESS_WIDTH-1:0] A,   // Address
    input logic [DATA_WIDTH-1:0] WD,     // Write Data
    input logic  [1:0]               ResultSrcE,     // For calculating hit rate
    output logic [DATA_WIDTH-1:0] hitcount,
    output logic [DATA_WIDTH-1:0] misscount,
    output logic [DATA_WIDTH-1:0] ReadData     // Read Data
);

    logic [ARRAY_WIDTH-1:0] ram_array [2**ADDRESS_AVAILABLE_WIDTH-1:0];

    // Cache signals
    logic cache_hit;                         // Cache hit signal
    logic [DATA_WIDTH-1:0] cache_data;       // Data from cache


    cache cache(
        .clk (clk),
        .addr (A),
        .wdata (WD),
        .we (WE),
        .rdata (cache_data),
        .hit (cache_hit)
    );


    initial begin
        $readmemh("data.hex", ram_array, 65536); // Load memory file (binary format)
    
    end

   always_comb begin
        if (cache_hit) begin
            // Cache hit: Use data from cache
            ReadData = cache_data;
        end else begin
            case(funct3)
                3'b000: ReadData = {{24{ram_array[A][7]}}, ram_array[A]};                      // LB (Load Byte, Sign-Extend)
                3'b001: ReadData = {{16{ram_array[A+1][7]}}, ram_array[A+1], ram_array[A]};        // LH (Load Half, Sign-Extend)
                3'b010: ReadData = {ram_array[A + 3], ram_array[A + 2], ram_array[A + 1], ram_array[A]}; // LW (Load Word)
                3'b100: ReadData = {24'b0, ram_array[A]};                                          // LBU (Load Byte Unsigned, Zero-Extend)
                3'b101: ReadData = {16'b0, ram_array[A+1], ram_array[A]};                          // LHU (Load Half Unsigned, Zero-Extend)
                default: ReadData = 32'b0;
            endcase
        end
    end


    // Write data logic (update both memory and cache if needed)
    always_ff @(posedge clk) begin

        if((ResultSrcE == 2'b01) && cache_hit) begin
            hitcount <= hitcount + 1;
        end else if ((ResultSrcE == 2'b01) && (cache_hit == 0)) begin
            misscount <= misscount + 1;
        end

        if (WE) begin
            // Update main memory
            case (funct3)
                3'b000: ram_array[A] <= WD[7:0];// SB (Store Byte)
                    
                3'b001: begin// SH (Store Half)
                        ram_array[A]     <= WD[7:0];
                        ram_array[A + 1] <= WD[15:8];
                    end
                3'b010: begin// SW (Store Word)
                        ram_array[A]     <= WD[7:0];
                        ram_array[A + 1] <= WD[15:8];
                        ram_array[A + 2] <= WD[23:16];
                        ram_array[A + 3] <= WD[31:24];
                    end
                default: ram_array[A] <= 8'b0;
            endcase
        end
    end
endmodule
