`default_nettype none
module adc8_fake(
    input  wire clk, input wire rst_n, input wire ena,
    output reg  [7:0] data
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) data <= 8'h00;
        else if (ena) data <= data + 8'd1;
    end
endmodule
`default_nettype wire
