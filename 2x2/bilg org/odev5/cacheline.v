module cache_line (
    input wire clk,
    input wire rst,
    input wire we,
    input wire [TAG_WIDTH-1:0] tag_in,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg valid,
    output reg [TAG_WIDTH-1:0] tag,
    output reg [DATA_WIDTH-1:0] data
);
    parameter TAG_WIDTH = 24;
    parameter DATA_WIDTH = 32;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            valid <= 0;
            tag <= 0;
            data <= 0;
        end else if (we) begin
            valid <= 1;
            tag <= tag_in;
            data <= data_in;
        end
    end
endmodule