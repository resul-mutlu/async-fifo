# SystemVerilog Asynchronous FIFO Design

## Overview
This repository includes a multi-clock domain Asynchronous FIFO implemented in SystemVerilog. The design safely transfers data between two independent clock domains (Write Domain and Read Domain) using Gray code pointers and two-stage synchronizers, ensuring reliable operation without metastability issues.

## Architecture
The system consists of several hardware blocks integrated within the `async_fifo_top` module:

*   **Dual-Port RAM (`dual_port_ram.sv`):** A parameterized memory block that stores the data payload. It allows simultaneous, independent read and write operations from different clock domains.
*   **Write Domain Logic (`wptr_full.sv`):** Manages the write pointer (binary and Gray code) and safely calculates the `wfull` flag to prevent data overwriting (overflow).
*   **Read Domain Logic (`rptr_empty.sv`):** Manages the read pointer (binary and Gray code) and safely calculates the `rempty` flag to prevent invalid reads (underflow).
*   **Synchronizers (`sync_2ff.sv`):** Two-stage flip-flop synchronizers that securely pass the Gray-coded read pointer to the write domain, and the Gray-coded write pointer to the read domain.

## Development Process & Methodology
This project was developed with a strong focus on advanced Design Verification (DV) practices and handling complex clock domain crossing (CDC) scenarios:

*   **LLM Assistance:** AI tools were used to discuss best architectural practices for clock domain crossing, generate comprehensive testbench structures, and debug complex simulation scenarios (e.g., resolving reference model and hardware capacity mismatches).
*   **Testing Corner Cases:** The testbench (`tb_top.sv`) focuses on verifying corner cases and extreme conditions. These include "Write-on-Full" (overflow prevention), "Read-on-Empty" (underflow protection), concurrent read/write bursts, and Asynchronous Reset Storms to ensure proper system recovery.
*   **Waveform Verification:** Extensive manual debugging and waveform analysis were conducted using GTKWave to ensure cycle-accurate pointer generation and flawless synchronization behavior.

## Toolchain
*   **Language:** SystemVerilog (IEEE 1800-2012)
*   **Environment:** Windows Subsystem for Linux (WSL - Ubuntu)
*   **Compiler/Simulator:** Icarus Verilog (`iverilog`)
*   **Waveform Viewer:** GTKWave

## How to Run the Simulation
To compile and run the top-level testbench on a Linux/WSL terminal, run the following commands:

```bash
iverilog -g2012 -o sim.vvp rtl/*.sv tb/tb_top.sv
vvp sim.vvp
gtkwave dump.vcd &
```