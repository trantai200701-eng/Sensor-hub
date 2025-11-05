`default_nettype none
module tt_um_sensor_hub_top(
    input  wire        clk,        // TT clock
    input  wire        rst_n,      // async reset, active-low
    input  wire        ena,        // asserted khi project được chọn
    input  wire [7:0]  ui_in,      // có thể dùng ui_in[0] làm START ngoài
    output wire [7:0]  uo_out,     // uo_out[0] = UART TX
    input  wire [7:0]  uio_in,     // (để dành cho INP/INN thật sau này)
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);
    // Không dùng UIO giai đoạn này → high-Z
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    // Bộ lấy mẫu chậm: ~1 kHz từ 50 MHz (50_000_000/50_000 ≈ 1 kHz)
    localparam integer SAMPLE_DIV = 50000;
    reg [$clog2(SAMPLE_DIV)-1:0] s_cnt;
    wire sample_tick = (s_cnt == 0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) s_cnt <= 0;
        else if (!ena)    s_cnt <= 0;
        else              s_cnt <= (s_cnt == 0) ? (SAMPLE_DIV-1) : (s_cnt - 1'b1);
    end

    // Fake ADC
    wire [7:0] adc_data;
    adc8_fake u_adc(
        .clk    (clk),
        .rst_n  (rst_n),
        .sample (ena && sample_tick), // chỉ chạy khi ena=1
        .data   (adc_data)
    );

    // UART TX: gửi adc_data mỗi khi có sample_tick và UART rảnh
    wire uart_busy;
    reg  req_tx;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) req_tx <= 1'b0;
        else if (!ena) req_tx <= 1'b0;
        else if (sample_tick && !uart_busy) req_tx <= 1'b1;
        else req_tx <= 1'b0;
    end

    wire uart_tx;
    uart_tx #(.DIV(434)) u_tx (       // 115200 bps @ 50 MHz
        .clk   (clk),
        .rst_n (rst_n),
        .start (req_tx),
        .data  (adc_data),
        .tx    (uart_tx),
        .busy  (uart_busy)
    );

    assign uo_out[0]   = uart_tx;
    assign uo_out[7:1] = 7'b0;
endmodule
`default_nettype wire
