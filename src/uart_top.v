// Module      : uart_top

module uart_top #(
    parameter CLK_FREQ     = 16_000_000,  // System clock frequency (Hz)
    parameter BAUD_RATE    = 9600,        // Desired baud rate (bps). I will try and make this a runtime-configurable parameter in the future.
    parameter DATA_BITS    = 8,           // Data bits per frame
    parameter STOP_BITS    = 1,           // Stop bits per frame
    parameter LOW_POWER_EN = 1,           // 1 = enable low-power/wake-up feature
    parameter IDLE_TIMEOUT = 1_000_000    // Clock cycles of inactivity before sleep
)(
    input  wire                    clk,        // System clock
    input  wire                    rst_n,      
 
    // TX (host -> UART -> tx pin) interface
    input  wire                    tx_start,   
    input  wire [DATA_BITS-1:0]    tx_data,    
    output wire                    tx_busy,    
    output wire                    tx_done,    
    output wire                    tx,         // Serial transmit line
 
    // RX (rx pin -> UART -> host) interface
    input  wire                    rx,         // Serial receive line
    output wire [DATA_BITS-1:0]    rx_data,
    output wire                    rx_done,
    output wire                    rx_frame_err,
 
    // Low-power / wake-up control interface
    input  wire                    low_power_en_i, // Runtime enable (ANDed with LOW_POWER_EN param)
    input  wire [31:0]             idle_timeout_i, // Runtime-configurable idle timeout
    output wire                    sleep,          // High while UART is in low-power mode
    output wire                    wake_up         // Pulses high when woken by line activity
);
 
    wire baud_tick;          // Oversample tick from baud generator
    wire baud_gen_en;        // Enable/clock-gate for the baud generator
    wire pwr_ctrl_en;        // Combined enable (param AND runtime signal)
 
    assign pwr_ctrl_en = LOW_POWER_EN[0] & low_power_en_i;
 
    // Baud generator is gated off while asleep to save power;
    // pwr_ctrl_en=0 forces baud_gen_en high (feature disabled -> always run)
    assign baud_gen_en = pwr_ctrl_en ? ~sleep : 1'b1;
 
    baud_gen #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) u_baud_gen (
        .clk       (clk),
        .rst_n     (rst_n),
        .en        (baud_gen_en),
        .baud_tick (baud_tick)
    );
 
    uart_tx #(
        .DATA_BITS (DATA_BITS),
        .STOP_BITS (STOP_BITS)
    ) u_uart_tx (
        .clk       (clk),
        .rst_n     (rst_n),
        .baud_tick (baud_tick),
        .tx_start  (tx_start),
        .tx_data   (tx_data),
        .tx_busy   (tx_busy),
        .tx_done   (tx_done),
        .tx        (tx)
    );
 
    uart_rx #(
        .DATA_BITS (DATA_BITS),
        .STOP_BITS (STOP_BITS)
    ) u_uart_rx (
        .clk         (clk),
        .rst_n       (rst_n),
        .baud_tick   (baud_tick),
        .rx          (rx),
        .rx_data     (rx_data),
        .rx_done     (rx_done),
        .rx_frame_err(rx_frame_err)
    );
 
    uart_pwr_ctrl #(
        .IDLE_TIMEOUT (IDLE_TIMEOUT)
    ) u_uart_pwr_ctrl (
        .clk           (clk),            // always-on clock, not baud-gated
        .rst_n         (rst_n),
        .en            (pwr_ctrl_en),
        .idle_timeout_i(idle_timeout_i),
        .rx            (rx),             // raw rx line for activity/edge detection
        .tx_busy       (tx_busy),        // stay awake while transmitting
        .rx_done       (rx_done),        // resets idle counter on completed reception
        .sleep         (sleep),
        .wake_up       (wake_up)
    );
 
endmodule