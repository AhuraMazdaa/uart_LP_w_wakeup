
// Module      : uart_tb
// Description : Testbench skeleton for uart_top.
//               DUT instantiation and the necessary functions are provided to test the DUT
//               

`timescale 1ns / 1ps

module uart_tb;

    localparam CLK_FREQ     = 50_000_000;
    localparam BAUD_RATE    = 9600;
    localparam DATA_BITS    = 8;
    localparam STOP_BITS    = 1;
    localparam LOW_POWER_EN = 1;
    localparam IDLE_TIMEOUT = 1_000_000;

    //Signals
    reg                     clk;
    reg                     rst_n;

    reg                     tx_start;
    reg  [DATA_BITS-1:0]    tx_data;
    wire                    tx_busy;
    wire                    tx_done;
    wire                    tx;

    reg                     rx;
    wire [DATA_BITS-1:0]    rx_data;
    wire                    rx_done;
    wire                    rx_frame_err;

    reg                     low_power_en_i;
    reg  [31:0]             idle_timeout_i;
    wire                    sleep;
    wire                    wake_up;

    // DUT instantiation
    uart_top #(
        .CLK_FREQ     (CLK_FREQ),
        .BAUD_RATE    (BAUD_RATE),
        .DATA_BITS    (DATA_BITS),
        .STOP_BITS    (STOP_BITS),
        .LOW_POWER_EN (LOW_POWER_EN),
        .IDLE_TIMEOUT (IDLE_TIMEOUT)
    ) u_uart_top (
        .clk            (clk),
        .rst_n          (rst_n),

        .tx_start       (tx_start),
        .tx_data        (tx_data),
        .tx_busy        (tx_busy),
        .tx_done        (tx_done),
        .tx             (tx),

        .rx             (rx),
        .rx_data        (rx_data),
        .rx_done        (rx_done),
        .rx_frame_err   (rx_frame_err),

        .low_power_en_i (low_power_en_i),
        .idle_timeout_i (idle_timeout_i),
        .sleep          (sleep),
        .wake_up        (wake_up)
    );

endmodule