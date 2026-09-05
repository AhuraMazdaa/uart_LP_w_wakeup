//==============================================================================
// Module      : uart_tx (minimal version)
// Description : Bare-minimum UART transmitter. Sends 1 start bit (0),
//               8 data bits (LSB first), 1 stop bit (1). No parameters,
//               no oversampling — assumes baud_tick pulses once per bit
//               period, already aligned to the bit rate.
//==============================================================================

module uart_tx (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       baud_tick,   // one pulse per bit period
    input  wire       tx_start,    // pulse to begin sending
    input  wire [7:0] tx_data,     // byte to send
    output reg        tx_busy,     // high while sending
    output reg        tx           // serial output (idles high)
);

    localparam ST_IDLE  = 2'd0,
               ST_START = 2'd1,
               ST_DATA  = 2'd2,
               ST_STOP  = 2'd3;

    reg [1:0] state;
    reg [2:0] bit_cnt;   // counts 0..7 data bits
    reg [7:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= ST_IDLE;
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
            bit_cnt   <= 3'd0;
            shift_reg <= 8'd0;
        end else begin
            case (state)

                ST_IDLE: begin
                    tx <= 1'b1;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        tx_busy   <= 1'b1;
                        state     <= ST_START;
                    end
                end

                ST_START: begin
                    tx <= 1'b0; // start bit
                    if (baud_tick) begin
                        bit_cnt <= 3'd0;
                        state   <= ST_DATA;
                    end
                end

                ST_DATA: begin
                    tx <= shift_reg[0]; // LSB first
                    if (baud_tick) begin
                        shift_reg <= shift_reg >> 1;
                        if (bit_cnt == 3'd7) begin
                            state <= ST_STOP;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                        end
                    end
                end

                ST_STOP: begin
                    tx <= 1'b1; // stop bit
                    if (baud_tick) begin
                        tx_busy <= 1'b0;
                        state   <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule