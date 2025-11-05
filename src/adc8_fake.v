`default_nettype none
module adc8_fake (
    input  wire clk, rst_n, ena,
    output reg        busy,
    output reg  [7:0] dout
);
    reg [15:0] tmr;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin tmr<=0; dout<=0; busy<=0; end
        else if (ena) begin
            if (tmr==16'd49999) begin   // ~1ms @50MHz
                tmr<=0; dout<=dout+8'd1; busy<=0;
            end else begin
                tmr<=tmr+1'b1; busy<=1'b1;
            end
        end
    end
endmodule
`default_nettype wire
