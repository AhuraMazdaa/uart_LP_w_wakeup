cmake_minimum_required(VERSION 3.16)
project(uart_LP_with_wakeup_functionality CXX)

# Find Verilator
find_package(verilator HINTS ${VERILATOR_ROOT} $ENV{VERILATOR_ROOT})

# SystemC dependencies
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# Find SystemC using SystemC's CMake integration
find_package(SystemCLanguage PATHS ${SYSTEMC_HOME})

add_executable(uart_tb_ex uart_tb.cc)

set_property(
        TARGET uart_tb_ex
        PROPERTY CXX_STANDARD ${SystemC_CXX_STANDARD}
)

verilate(uart_tb_ex SYSTEMC COVERAGE TRACE
        INCLUDE_DIRECTORIES "."
        SOURCES uart_rx.v uart_tx.v uart_top.v baud_gen.v uart_pwr_ctrl.v
)

verilator_link_systemc(uart_tb_ex)
