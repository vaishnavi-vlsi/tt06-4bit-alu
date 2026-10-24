# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: MIT
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start 4-bit ALU Test")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 2)

    dut._log.info("Test ALU Operations")

    # Test ADD: A=3, B=2, Opcode=000 -> Expected Result = 5 (0011 + 0010 = 0101)
    dut.ui_in.value = (2 << 4) | 3  # ui_in[7:4] = B (2), ui_in[3:0] = A (3)
    dut.uio_in.value = 0b000        # Opcode for ADD
    await ClockCycles(dut.clk, 2)
    dut._log.info(f"ADD: A=3, B=2 -> Output = {dut.uo_out.value}")
    assert (dut.uo_out.value & 0x0F) == 5

    # Test SUB: A=7, B=4, Opcode=001 -> Expected Result = 3 (0111 - 0100 = 0011)
    dut.ui_in.value = (4 << 4) | 7  # B=4, A=7
    dut.uio_in.value = 0b001        # Opcode for SUB
    await ClockCycles(dut.clk, 2)
    dut._log.info(f"SUB: A=7, B=4 -> Output = {dut.uo_out.value}")
    assert (dut.uo_out.value & 0x0F) == 3

    # Test AND: A=12 (1100), B=10 (1010), Opcode=010 -> Expected Result = 8 (1000)
    dut.ui_in.value = (10 << 4) | 12
    dut.uio_in.value = 0b010        # Opcode for AND
    await ClockCycles(dut.clk, 2)
    dut._log.info(f"AND: A=12, B=10 -> Output = {dut.uo_out.value}")
    assert (dut.uo_out.value & 0x0F) == 8

    dut._log.info("4-bit ALU Test Passed Successfully!")
