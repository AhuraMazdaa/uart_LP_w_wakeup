#include "Vuart_top.h"
#include <systemc>

int sc_main(int argc, char* argv[]) {
	Vuart_top uart_top("uart_top");
	sc_core::sc_start();
	return 0;
}
