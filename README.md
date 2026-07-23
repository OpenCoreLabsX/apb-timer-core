<div align="center">

<img src="https://raw.githubusercontent.com/OpenCoreLabsX/apb-usart-core/36a802fc11f9a65acace85c78b591b82f889031f/banner.png" alt="OpenCoreLabsX Banner" width="100%">

# GitHub Readme Stats

Get dynamically generated GitHub stats on your READMEs!

<p>
  <img src="https://img.shields.io/badge/Language-SystemVerilog-blue?style=flat" alt="Language">
  <img src="https://img.shields.io/badge/Verification-UVM_1.2-brightgreen?style=flat" alt="Verification">
  <img src="https://img.shields.io/badge/Coverage-100%25-brightgreen?style=flat&logo=codecov" alt="Coverage">
  <img src="https://img.shields.io/badge/Status-Tapeout_Ready-success?style=flat" alt="Status">
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat" alt="License">
</p>

[![Powered by OpenCoreLabsX](https://img.shields.io/badge/Powered%20by-OpenCoreLabsX-black?style=for-the-badge&logo=github)](https://github.com/OpenCoreLabsX)

</div>

---

# APB Timer IP Core

APB Timer RTL written in SystemVerilog for MCU, SoC, and RISC-V based systems.

## Features

| Item | Description |
| --- | --- |
| Control interface | 32-bit APB (Advanced Peripheral Bus) register interface |
| Timer Modes | Up-counting, One-shot, and Continuous (Periodic) |
| Configurability | Programmable 16-bit Prescaler |
| Output | Configurable PWM (Pulse Width Modulation) output |
| Status flags | Overflow and Compare Match |
| Interrupts | Configurable IRQs for Overflow and Compare Match events |

## Registers

| Address | Name | Description |
| --- | --- | --- |
| `0x00` | `CTRL` | `[0]` Enable, `[1]` One-shot, `[2]` PWM Enable, `[31:16]` Prescaler |
| `0x04` | `STATUS` | `[0]` Overflow, `[1]` Compare Match (Read-only) |
| `0x08` | `VALUE` | Current counter value. Writes directly update the counter. |
| `0x0C` | `RELOAD` | Reload limit. Defines Timer Period and PWM Frequency. |
| `0x10` | `COMPARE` | Compare limit. Defines PWM Duty Cycle. |
| `0x14` | `IRQ_EN` | Mask to enable/disable interrupts. |
| `0x18` | `IRQ_STAT` | Interrupt status (Write 1 to clear) with loss-of-interrupt protection. |

## Repository Structure

```text
.
|-- rtl/        Synthesizable APB Timer RTL
|-- docs/       GitHub Pages documentation setup
|-- uvm/        UVM verification testbench environment & SVA assertions
|-- filelist.f  RTL compile filelist
`-- Makefile    ModelSim UVM run targets
```

## Build & Test

### Verification & SystemVerilog Assertions (SVA)

Cycle-accurate SystemVerilog Assertions (`timer_sva.sv`) are bound to `apb_timer_wrapper` inside `uvm/tb/apb_timer_tb_top.sv` to cover hardware invariants:
* **Counter Invariants:** Counter stability when disabled (`!timer_en`) and direct register write behavior.
* **One-Shot Mode:** Hardware clear trigger (`hw_clear_en`) upon overflow/reload.
* **PWM Output:** Forced low in disabled state (`!pwm_en || !timer_en`) and level comparison during active counting.
* **IRQ Status:** Unmasked interrupt matching equation (`timer_irq == |(irq_stat & irq_en)`).

### Run Commands

```sh
# Run static linting and assertion check (Verilator)
make lint

# Compile RTL and assertion hierarchy
make compile

# Execute simulation checks
make run

# Run UVM smoke test (ModelSim / Questasim)
make run UVM_TEST=apb_timer_smoke_test