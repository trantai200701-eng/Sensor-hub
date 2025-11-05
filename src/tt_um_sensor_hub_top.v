`default_nettype none
module tt_um_sensor_hub_top(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ena,
    input  wire [7:0]  ui_in,
    output wire [7:0]  uo_out,   // uo_out[0] = UART TX
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);
    // Chưa dùng UIO → High-Z
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    // Tạo tick ~1 kHz từ 50 MHz
    localparam integer SAMPLE_DIV = 50000;
    reg [$clog2(SAMPLE_DIV)-1:0] s_cnt;
    wire sample_tick = (s_cnt == 0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) s_cnt <= 0;
        else if (!ena) s_cnt <= 0;
        else s_cnt <= (s_cnt==0) ? (SAMPLE_DIV-1) : (s_cnt-1'b1);
    end

    // Fake ADC
    wire [7:0] adc_data;
    adc8_fake u_adc(
        .clk(clk), .rst_n(rst_n),
        .sample(ena && sample_tick),
        .data(adc_data)
    );

    // Phát UART mỗi sample khi TX rảnh
    wire uart_busy;
    reg  req_tx;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) req_tx <= 1'b0;
        else if (!ena) req_tx <= 1'b0;
        else if (sample_tick && !uart_busy) req_tx <= 1'b1;
        else req_tx <= 1'b0;
    end

    wire uart_tx;
    uart_tx #(.DIV(434)) u_tx(
        .clk(clk), .rst_n(rst_n),
        .start(req_tx), .data(adc_data),
        .tx(uart_tx), .busy(uart_busy)
    );

    assign uo_out[0]   = uart_tx;
    assign uo_out[7:1] = 7'b0;
endmodule
`default_nettype wire
