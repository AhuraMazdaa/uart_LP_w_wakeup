# uart_LP_w_wakeup
Verilog implementation of UART module with wakeup on activity functionality

Overview

This project implements a UART controller in Verilog, capable of serial data transmission and reception over a single 
TX/RX pair. The goal is to implement a UART module capable of entering low power mode and wake up on activity. Since 
there is no common clock, we have to depend on the Tx/Rx pair to detect activity.

I will also explore setting power saving techniques and provide power analysis of this design.

Modules:
uart_top.v  : Top wrapper
uart_tx.v   : Shifts bits out, adds start and stop bits
uart_rx.v   : Detects the start bit, checks the stop bit, samples at baud rate, shifts bits and framing error detector