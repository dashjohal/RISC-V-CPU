module cache #(
    parameter int OFFSET_BITS = 2,
    parameter int SET_BITS    = 6
) (
    input  logic       clk,
    input  logic       rst,
    input  logic [31:0] addr,
    input  logic [31:0] wdata,
    input  logic       we,          // 1 = write, 0 = read
    output logic [31:0] rdata,
    output logic       hit
);

    localparam int TAG_BITS  = 32 - SET_BITS - OFFSET_BITS;
    localparam int NUM_SETS  = 1 << SET_BITS;
    localparam int NUM_WAYS  = 4;

    // Address decomposition
    logic [TAG_BITS-1:0]  tag_in;
    logic [SET_BITS-1:0]  set_in;
    assign tag_in = addr[31 : SET_BITS + OFFSET_BITS];
    assign set_in = addr[SET_BITS + OFFSET_BITS - 1 : OFFSET_BITS];

    // Storage arrays
    logic [TAG_BITS-1:0]  tag_array   [NUM_WAYS][NUM_SETS];
    logic                 valid_array [NUM_WAYS][NUM_SETS];
    logic [31:0]          data_array  [NUM_WAYS][NUM_SETS];

    // True LRU: ranks 0 = MRU, 3 = LRU (always a permutation of 0,1,2,3)
    logic [1:0] lru_rank [NUM_SETS][NUM_WAYS];

    // Hit detection & victim selection (combinational)
    logic        hit_comb;
    logic [1:0]  hit_way_comb;
    logic [31:0] rdata_comb;
    logic [1:0]  victim_way;

    always_comb begin
        hit_comb     = 1'b0;
        hit_way_comb = 2'd0;
        rdata_comb   = 32'h0;

        // Check for hit (priority: way 0 → 3)
        for (int w = 0; w < NUM_WAYS; w++) begin
            if (!hit_comb && valid_array[w][set_in] && tag_array[w][set_in] == tag_in) begin
                hit_comb     = 1'b1;
                hit_way_comb = w[1:0];
                rdata_comb   = data_array[w][set_in];
            end
        end

        // Victim = way with highest rank (should be 3 if state is correct)
        victim_way = 2'd0;
        for (int w = 0; w < NUM_WAYS; w++) begin
            if (lru_rank[set_in][w] > lru_rank[set_in][victim_way]) begin
                victim_way = w[1:0];
            end
        end
    end

    // Register outputs
    assign hit   = hit_comb;
    assign rdata = rdata_comb;

    // Sequential logic: reset + updates
    always_ff @(posedge clk) begin
        if (rst) begin
            for (int s = 0; s < NUM_SETS; s++) begin
                for (int w = 0; w < NUM_WAYS; w++) begin
                    valid_array[w][s] <= 1'b0;
                    tag_array[w][s]   <= '0;
                    data_array[w][s]  <= '0;
                    // Initial permutation: way0=MRU ... way3=LRU
                    lru_rank[s][w]    <= w[1:0];
                end
            end
        end
        else begin
            logic do_update;
            logic [1:0] used_way;

            do_update = 1'b0;
            used_way  = 2'd0;

           
            if (hit_comb) begin
                do_update = 1'b1;
                used_way  = hit_way_comb;

                // Write-through / write-update on hit
                if (we) begin
                    data_array[hit_way_comb][set_in] <= wdata;
                end
            end

       
            else if (we) begin
                do_update = 1'b1;
                used_way  = victim_way;

                tag_array[used_way][set_in]   <= tag_in;
                valid_array[used_way][set_in] <= 1'b1;
                data_array[used_way][set_in]  <= wdata;
            end

            
            if (do_update) begin
                logic [1:0] old_rank_of_used;
                old_rank_of_used = lru_rank[set_in][used_way];

                for (int w = 0; w < NUM_WAYS; w++) begin
                    if (w[1:0] == used_way) begin
                        lru_rank[set_in][w] <= 2'd0;                // become MRU
                    end
                    else if (lru_rank[set_in][w] < old_rank_of_used) begin
                        // was more recent than used → age by 1
                        lru_rank[set_in][w] <= lru_rank[set_in][w] + 2'd1;
                    end
                    // else: was already older → no change
                end
            end
        end
    end

endmodule
