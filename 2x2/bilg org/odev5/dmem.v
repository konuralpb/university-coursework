module dmem(
    input wire clk,
    input wire rst,
    input wire [ADDRESS_WIDTH-1:0] a,
    input wire [DATA_WIDTH-1:0] wd,
    input wire re,
    input wire we,
    output reg [DATA_WIDTH-1:0] rd,
    output reg hit
);
    parameter CACHE_SIZE = 256;
    parameter BLOCK_SIZE = 4;
    parameter ADDRESS_WIDTH = 32;
    parameter DATA_WIDTH = 32;
    parameter NUM_LINES = CACHE_SIZE / BLOCK_SIZE;
    parameter INDEX_WIDTH = $clog2(NUM_LINES);
    parameter TAG_WIDTH = ADDRESS_WIDTH - INDEX_WIDTH - $clog2(BLOCK_SIZE);

    reg [DATA_WIDTH-1:0] memory [0:1023];  // Simulate a memory with 1024 words

    wire [INDEX_WIDTH-1:0] index;
    wire [TAG_WIDTH-1:0] tag;
    wire [1:0] offset;

    assign index = a[INDEX_WIDTH + $clog2(BLOCK_SIZE) - 1:$clog2(BLOCK_SIZE)];
    assign tag = a[ADDRESS_WIDTH-1:INDEX_WIDTH + $clog2(BLOCK_SIZE)];
    assign offset = a[$clog2(BLOCK_SIZE)-1:0];

    reg write_en_cache;
    reg [TAG_WIDTH-1:0] tag_in_cache;
    reg [DATA_WIDTH-1:0] data_in_cache;

    cache_line #(.TAG_WIDTH(TAG_WIDTH), .DATA_WIDTH(DATA_WIDTH)) cache [0:NUM_LINES-1] (
        .clk(clk),
        .rst(rst),
        .we(we),
        .tag_in(tag_in_cache),
        .data_in(data_in_cache),
        .valid(cache_valid),
        .tag(cache_tag),
        .data(cache_data)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hit <= 0;
            rd <= 0;
        end else if (re) begin
            if (cache_valid[index] && (cache_tag[index] == tag)) begin
                // Cache hit
                hit <= 1;
                rd <= cache_data[index];
            end else begin
                // Cache miss
                hit <= 0;
                rd <= memory[a];  // Read from memory
                write_en_cache <= 1;
                tag_in_cache <= tag;
                data_in_cache <= memory[{tag, index}];  // Load block from memory
            end
        end else if (we) begin
            if (cache_valid[index] && (cache_tag[index] == tag)) begin
                // Cache hit
                hit <= 1;
                cache_data[index][offset*8 +: 8] <= wd;  // Update cache
                memory[a] <= wd;  // Write through to memory
            end else begin
                // Cache miss
                hit <= 0;
                write_en_cache <= 1;
                tag_in_cache <= tag;
                data_in_cache <= memory[{tag, index}];  // Load block from memory
                data_in_cache[offset*8 +: 8] <= wd;  // Update cache
                memory[a] <= wd;  // Write to memory
            end
        end else begin
            write_en_cache <= 0;
        end
    end
endmodule