`default_nettype none
module uart_tx #(
    parameter CLK_HZ = 50_000_000,
    parameter BAUD   = 115200
) (
    input  wire clk, rst_n,
    input  wire [7:0] data,
    input  wire       valid,
    output wire       ready,
    output reg        tx
);
    localparam integer DIV = CLK_HZ / BAUD;
    reg [15:0] divcnt; reg baud_tick;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin divcnt<=0; baud_tick<=1'b0; end
        else if (divcnt==DIV-1) begin divcnt<=0; baud_tick<=1'b1; end
        else begin divcnt<=divcnt+1; baud_tick<=1'b0; end
    end
    reg [3:0] bitpos;
    reg [9:0] shifter;
    reg busy;
    assign ready = ~busy;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin busy<=0; shifter<=10'h3FF; bitpos<=0; tx<=1'b1; end
        else if (!busy && valid) begin
            shifter <= {1'b1, data, 1'b0};
            bitpos  <= 4'd0;
            busy    <= 1'b1;
        end else if (busy && baud_tick) begin
            tx      <= shifter[0];
            shifter <= {1'b1, shifter[9:1]};
            bitpos  <= bitpos + 1'b1;
            if (bitpos==4'd9) busy<=1'b0;
        end
    end
endmodule
`default_nettype wire
