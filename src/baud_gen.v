// Module      : baud_gen
// Description : Baud rate generator for UART. 
//               Creates a clock pulse with the timing of the specified baud rate, based on the system clock frequency.
// Updated     : Need to add this as a run time configurable variable in the future.

module baud_gen #(
    parameter CLK_FREQ  = 50_000_000,  // System clock frequency in Hz (e.g., 50 MHz)
    parameter BAUD_RATE = 115_200      // Target baud rate
) (
    input  wire clk,        // System clock
    input  wire rst_n,      // Active-low asynchronous reset
    input  wire en,         // Enable signal to start baud generation
    output reg  baud_tick   // Single-clock-cycle pulse generator at baud rate
);

    // Calculate maximum count required for baud rate generation
    localparam CNT_MAX = CLK_FREQ / BAUD_RATE;
    localparam CNT_WIDTH = $clog2(CNT_MAX);
    localparam [CNT_WIDTH-1:0] LAST_COUNT_VALUE = CNT_WIDTH'(CNT_MAX - 1);

    reg [CNT_WIDTH-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count     <= {CNT_WIDTH{1'b0}};
            baud_tick <= 1'b0;
        end else if (en) begin
            if (count == LAST_COUNT_VALUE) begin
                count     <= {CNT_WIDTH{1'b0}};
                baud_tick <= 1'b1;
            end else begin
                count     <= count + 1'b1;
                baud_tick <= 1'b0;
            end
        end else begin
            count     <= {CNT_WIDTH{1'b0}};
            baud_tick <= 1'b0;
        end
    end

endmodule