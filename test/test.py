import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

CLK_NS = 20  # 50 MHz

@cocotb.test()
async def test_uart_starts_transmitting(dut):
    # clock 50 MHz
    cocotb.start_soon(Clock(dut.clk, CLK_NS, units="ns").start())

    # init & reset
    dut.ena.value   = 1
    dut.rst_n.value = 0
    dut.ui_in.value = 0
    await Timer(5*CLK_NS, units="ns")
    dut.rst_n.value = 1

    # chờ thấy start bit (TX kéo xuống 0) trong một khoảng hợp lý
    saw_start = False
    for _ in range(200000):  # ~4 ms @50MHz
        await RisingEdge(dut.clk)
        if int(dut.uo_out.value) & 1 == 0:
            saw_start = True
            break

    assert saw_start, "UART TX did not start (no start bit seen)"
