`default_nettype none
module uart_tx #(
    parameter integer DIV = 434  // 50 MHz / 115200 ≈ 434
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,
    input  wire [7:0] data,
    output reg        tx,        // idle = 1
    output reg        busy
);
    reg [15:0] cnt;
    reg [3:0]  bitpos;
    reg [9:0]  sh; // {stop(1), data[7:0], start(0)}
    initial tx = 1'b1;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx<=1'b1; busy<=1'b0; cnt<=16'd0; bitpos<=4'd0; sh<=10'h3FF;
        end else begin
            if (!busy) begin
                if (start) begin
                    sh <= {1'b1, data, 1'b0};
                    busy <= 1'b1; bitpos <= 4'd0; cnt <= DIV-1;
                end
            end else begin
                if (cnt==0) begin
                    tx <= sh[0];
                    sh <= {1'b1, sh[9:1]};
                    cnt <= DIV-1;
                    bitpos <= bitpos + 1'b1;
                    if (bitpos==4'd9) begin busy<=1'b0; tx<=1'b1; end
                end else cnt <= cnt-1'b1;
            end
        end
    end
endmodule
`default_nettype wire
