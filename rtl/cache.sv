module cache (
    input  logic        clk,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic        we,    // 1 = write, 0 = read
    output logic [31:0] rdata,
    output logic        hit
);

    localparam OFFSET_BITS = 2;
    localparam SET_BITS    = 6;
    localparam TAG_BITS    = 32 - SET_BITS - OFFSET_BITS; // 24

    wire [TAG_BITS-1:0]    tag_in = addr[31 : SET_BITS + OFFSET_BITS];   // [31:8]
    wire [SET_BITS-1:0]    set_in = addr[SET_BITS + OFFSET_BITS -1 : OFFSET_BITS]; // [7:2]

    // Cache storage arrays
    // 8 entries (2^3), each with a tag, a valid bit, and a 32-bit data word.
    logic [TAG_BITS-1:0] tag_array0   [0:(1<<SET_BITS)-1]; //1<<SET_BITS means 2^SET_BITS which equals 8
    logic                valid_array0 [0:(1<<SET_BITS)-1];
    logic [31:0]         data_array0  [0:(1<<SET_BITS)-1];

    logic [TAG_BITS-1:0] tag_array1   [0:(1<<SET_BITS)-1]; //1<<SET_BITS means 2^SET_BITS which equals 8
    logic                valid_array1 [0:(1<<SET_BITS)-1];
    logic [31:0]         data_array1  [0:(1<<SET_BITS)-1];

    logic [TAG_BITS-1:0] tag_array2   [0:(1<<SET_BITS)-1]; //1<<SET_BITS means 2^SET_BITS which equals 8
    logic                valid_array2 [0:(1<<SET_BITS)-1];
    logic [31:0]         data_array2  [0:(1<<SET_BITS)-1];

    logic [TAG_BITS-1:0] tag_array3   [0:(1<<SET_BITS)-1]; //1<<SET_BITS means 2^SET_BITS which equals 8
    logic                valid_array3 [0:(1<<SET_BITS)-1];
    logic [31:0]         data_array3  [0:(1<<SET_BITS)-1];


    logic [1:0]          lru_state [0:(1<<SET_BITS)-1][0:3]; // we have four different 2-bit 'least recently used' arrays
    logic [1:0]          lru_way;
    logic [1:0]          accessed_way;

    always_ff @(posedge clk) begin

        logic accessed; //is the cache accessed
        if(
            (valid_array0[SET_in] && (tag_array0[SET_in] == tag_in)) ||
            (valid_array1[SET_in] && (tag_array1[SET_in] == tag_in)) ||
            (valid_array2[SET_in] && (tag_array2[SET_in] == tag_in)) ||
            (valid_array3[SET_in] && (tag_array3[SET_in] == tag_in)) ||
            we
        ) begin
            accessed = 1;
        end else accessed = 0;
/*
        if (rst) begin
            for (int set = 0; set < (1 << SET_BITS); set++) begin
                valid_array0[set] <= 1'b0;
                tag_array0[set]   <= '0;
                data_array0[set]  <= '0;

                valid_array1[set] <= 1'b0;
                tag_array1[set]   <= '0;
                data_array1[set]  <= '0;

                valid_array2[set] <= 1'b0;
                tag_array2[set]   <= '0;
                data_array2[set]  <= '0;

                valid_array3[set] <= 1'b0;
                tag_array3[set]   <= '0;
                data_array3[set]  <= '0;

                // Reset LRU states to default (all ways initially unused)
                for (int way = 0; way < 4; way++) begin
                    lru_state[set][way] <= (2'({30'b0, 2'b11} - way)); // Assign default priority
                end
            end

        end else 
*/
        if (accessed) begin
                // Capture the old state of the accessed way
                logic [1:0] accessed_old_state = lru_state[SET_in][accessed_way];

                // Update LRU for all ways in the set
                for (int i = 0; i < 4; i++) begin
                    if (i == {30'b0, accessed_way}) begin
                        // Accessed way becomes MRU (state = 0)
                        lru_state[SET_in][i] <= 2'b00;
                    end else if (lru_state[SET_in][i] <= accessed_old_state) begin
                        // Increment state if it's less than or equal to the old state of the accessed way
                        lru_state[SET_in][i] <= lru_state[SET_in][i] + 1;
                    end
                end
            end

        // On a write, store the data and update tag + valid
        if (we) begin
            if (lru_way == 0) begin
                tag_array0[SET_in]   <= tag_in;
                valid_array0[SET_in] <= 1'b1;
                data_array0[SET_in]  <= wdata;
            end
            
            else if (lru_way == 1) begin
                tag_array1[SET_in]   <= tag_in;
                valid_array1[SET_in] <= 1'b1;
                data_array1[SET_in]  <= wdata;
            end

            else if (lru_way == 2) begin
                tag_array2[SET_in]   <= tag_in;
                valid_array2[SET_in] <= 1'b1;
                data_array2[SET_in]  <= wdata;
            end

                else if (lru_way == 3) begin
                tag_array3[SET_in]   <= tag_in;
                valid_array3[SET_in] <= 1'b1;
                data_array3[SET_in]  <= wdata;
            end
        end
    end

    // Read logic: check tag and valid
    always_comb begin
        // Find the way with the highest priority (3)
        lru_way = 0;
        for (int way = 0; way < 4; way++) begin
            if (lru_state[SET_in][way] == 2'b11) begin
                lru_way = {30'b0, way}[1:0];
            end
        end

        // Default values
        accessed_way = 2'bxx; // Indeterminate or invalid value for debugging
        hit = 1'b0;
        rdata = 32'h0;

        if (valid_array0[SET_in] && (tag_array0[SET_in] == tag_in)) begin
            hit   = 1'b1;
            rdata = data_array0[SET_in];
            accessed_way = 0;
        end else if (valid_array1[SET_in] && (tag_array1[SET_in] == tag_in)) begin
            hit   = 1'b1;
            rdata = data_array1[SET_in];
            accessed_way = 1;
        end else if (valid_array2[SET_in] && (tag_array2[SET_in] == tag_in)) begin
            hit   = 1'b1;
            rdata = data_array2[SET_in];
            accessed_way = 2;
        end else if (valid_array3[SET_in] && (tag_array3[SET_in] == tag_in)) begin
            hit   = 1'b1;
            rdata = data_array3[SET_in];
            accessed_way = 3;
        end 
    end

endmodule
