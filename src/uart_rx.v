//==============================================================================
// Module      : uart_rx (minimal version)
// Pending items    : Wake functionality, low power mode
//==============================================================================

module uart_rx #(
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire       baud_tick,   // one pulse per bit period
    input  wire       rx,          // serial input (idles high)
    output reg  [7:0] rx_data,     // received byte
    output reg        rx_frame_err, // high if stop bit was not high
    output reg        rx_done      // 1-cycle pulse when byte is ready
);

    localparam ST_IDLE  = 2'd0,
               ST_START = 2'd1,
               ST_DATA  = 2'd2,
               ST_STOP  = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;

    // 2-flop synchronizer, since rx is asynchronous to clk
    reg rx_meta, rx_sync;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= ST_IDLE;
            bit_cnt   <= 3'd0;
            shift_reg <= 8'd0;
            rx_data   <= 8'd0;
            rx_done   <= 1'b0;
        end else begin
            rx_done <= 1'b0; // default; asserted for one cycle below

            case (state)

                ST_IDLE: begin
                    if (!rx_sync) begin // falling edge -> start bit
                        state <= ST_START;
                    end
                end

                ST_START: begin
                    if (baud_tick) begin
                        bit_cnt <= 3'd0;
                        state   <= ST_DATA;
                    end
                end

                ST_DATA: begin
                    if (baud_tick) begin
                        shift_reg <= {rx_sync, shift_reg[7:1]}; // LSB-first shift-in
                        if (bit_cnt == 3'd7) begin
                            state <= ST_STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end
                end

                ST_STOP: begin
                    if (baud_tick) begin
                        rx_data <= shift_reg;
                        rx_done <= 1'b1;
                        state   <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule