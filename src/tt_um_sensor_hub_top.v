`default_nettype none
module tt_um_sensor_hub_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ena,
    input  wire [7:0]  ui_in,
    output wire [7:0]  uo_out,
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    // "ADC" giả tạo mẫu 8-bit
    wire        fake_busy;
    wire [7:0]  fake_data;
    adc8_fake UFAKE(.clk(clk), .rst_n(rst_n), .ena(ena), .busy(fake_busy), .dout(fake_data));

    // UART TX
    wire uart_ready, uart_tx;
    reg  uart_valid;
    reg  [7:0] uart_data;
    uart_tx #(.CLK_HZ(50_000_000), .BAUD(115200)) UTX (
        .clk(clk), .rst_n(rst_n),
        .data(uart_data), .valid(uart_valid), .ready(uart_ready),
        .tx(uart_tx)
    );
    assign uo_out[0]   = uart_tx;   // xuất ra pin uo[0]
    assign uo_out[7:1] = 7'b0;

    // đơn giản: cứ mỗi khi sẵn sàng thì gửi byte mới
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin uart_valid<=0; uart_data<=0; end
        else begin
            uart_valid <= 1'b0;
            if (ena && uart_ready && !fake_busy) begin
                uart_data  <= fake_data;
                uart_valid <= 1'b1;
            end
        end
    end
endmodule
`default_nettype wire
