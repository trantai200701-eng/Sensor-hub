`default_nettype none
module adc8_fake(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       sample,  // 1 chu kỳ để chốt giá trị
    output reg  [7:0] data
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) data <= 8'd0;
        else if (sample) data <= data + 8'd1;
    end
endmodule
`default_nettype wire
