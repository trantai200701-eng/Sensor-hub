`default_nettype none
module uart_tx #(
    // 50 MHz / 115200 ≈ 434
    parameter [15:0] DIV = 16'd434
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       start,       // 1 xung để bắt đầu gửi
    input  wire [7:0] data,
    output reg        tx,          // idle = 1
    output reg        busy
);
    reg [15:0] cnt;
    reg [3:0]  bitpos;             // 0..9
    reg [9:0]  shifter;            // {stop(1), data[7:0], start(0)}

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt     <= 16'd0;
            bitpos  <= 4'd0;
            shifter <= 10'h3FF;
            tx      <= 1'b1;
            busy    <= 1'b0;
        end else begin
            if (!busy) begin
                cnt <= 16'd0;
                if (start) begin
                    shifter <= {1'b1, data, 1'b0};
                    bitpos  <= 4'd0;
                    busy    <= 1'b1;
                end
            end else begin
                if (cnt == DIV - 16'd1) begin
                    cnt     <= 16'd0;
                    tx      <= shifter[0];
                    shifter <= {1'b1, shifter[9:1]};
                    if (bitpos == 4'd9) begin
                        busy <= 1'b0;
                        tx   <= 1'b1;       // trở về idle
                    end else begin
                        bitpos <= bitpos + 4'd1;
                    end
                end else begin
                    cnt <= cnt + 16'd1;
                end
            end
        end
    end
endmodule
`default_nettype wire

