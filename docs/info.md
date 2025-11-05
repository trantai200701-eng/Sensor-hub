## How it works
This TinyTapeout project streams an 8-bit “sensor” value over UART.
- A small module `adc8_fake` is an 8-bit up-counter that increments when `ena=1` and `rst_n=1`.
- A pace timer asserts `start_tx` about every ~1 ms (with 50 MHz clock).
- The UART transmitter sends one byte (LSB first), 8N1 at 115200 bps.
- I/O mapping:
  - `uo[0]` = UART TX (3.3 V).  
  - `uo[1..7]` = 0.  
  - `ui[7:0]`, `uio[7:0]` are not used.  
  - `uio_out = 0`, `uio_oe = 0`.

## How to test
**On silicon / FPGA board**
1. Select this project so `ena=1` (the TT mux does this automatically when your slot is addressed).
2. Connect a 3.3 V USB-UART RX to pad corresponding to `uo[0]` (see datasheet pinout table).
3. Open a serial terminal at **115200 8N1**.  
   You should see bytes increasing: `0x00, 0x01, 0x02, …` repeating (about 1 byte per ms).

**In simulation (optional)**
- Run: `make -C test sim` then open `test/tb.vcd` in GTKWave.  
  Check that `uart_tx` toggles with 115200 bps frame and the transmitted byte increments over time.
