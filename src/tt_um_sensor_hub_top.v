`default_nettype none
module tt_um_sensor_hub_top(
    input  wire        clk,       // 50 MHz
    input  wire        rst_n,     // async reset, active-low
    input  wire        ena,       // asserted when project is selected
    input  wire [7:0]  ui_in,     // not used yet
    output wire [7:0]  uo_out,    // uo_out[0] = UART TX
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);
    // Unused bidirs
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    // Fake 8-bit ADC (counter)
    wire [7:0] adc_data;
    adc8_fake u_adc (.clk(clk), .rst_n(rst_n), .ena(ena), .data(adc_data));

    // Pace: generate a start pulse roughly every ~1ms @50MHz (adjust as needed)
    reg [15:0] pace;
    reg        start_tx;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pace <= 16'd0;
            start_tx <= 1'b0;
        end else begin
            start_tx <= 1'b0;
            if (ena) begin
                if (pace == 16'd50000) begin
                    pace <= 16'd0;
                    start_tx <= 1'b1;
                end else begin
                    pace <= pace + 1'b1;
                end
            end else begin
                pace <= 16'd0;
            end
        end
    end

    // UART TX @115200 bps with 50MHz clock => DIV ≈ 434
    wire uart_tx;
    wire uart_busy;
    uart_tx #(.DIV(434)) u_tx (
        .clk(clk), .rst_n(rst_n),
        .start(start_tx), .data(adc_data),
        .tx(uart_tx), .busy(uart_busy)
    );

    // Drive outputs
    assign uo_out[0]   = uart_tx;
    assign uo_out[7:1] = 7'b0;

    // Gom các tín hiệu chưa dùng để tránh cảnh báo UNUSED (sẽ bị tối ưu bỏ khi tổng hợp)
    wire _unused_ok = &{1'b0, ui_in, uio_in, uart_busy};

endmodule
`default_nettype wire

