# SystemVerilog Asynchronous FIFO

## Overview
A dual-clock (asynchronous) FIFO written in SystemVerilog. Data is written in one clock domain (`wclk`) and read in another, independent clock domain (`rclk`). The read and write pointers cross between domains as Gray code through two-flip-flop synchronizers, following the well-known Cummings architecture.

A two-flop synchronizer does not remove metastability. It makes a metastable value very unlikely to reach the rest of the logic (see MTBF). Gray code makes sure that only one pointer bit changes per increment, so a pointer sampled mid-transition is either the old value or the new one, never an unrelated value.

## Architecture
All blocks are integrated in `async_fifo_top.sv`:

* **`dual_port_ram.sv`**: Memory with a write port on `wclk` and a registered read port on `rclk`. `rdata` is valid one `rclk` cycle after an accepted read (`rinc && !rempty`).
* **`wptr_full.sv`**: Write pointer (binary + Gray) and the `wfull` flag. Full is detected when the next write Gray pointer equals the synchronized read Gray pointer with its two MSBs inverted.
* **`rptr_empty.sv`**: Read pointer (binary + Gray) and the `rempty` flag. Empty is detected when the next read Gray pointer equals the synchronized write Gray pointer.
* **`sync_2ff.sv`**: Two-flop synchronizers, one for each crossing direction.

The Gray pointers are registered (computed from the next binary value), so the synchronizers receive glitch-free signals.

`wfull` and `rempty` are conservative: because the other domain's pointer arrives two cycles late, the FIFO can report full or empty for a few cycles longer than strictly necessary. It never reports "not full" or "not empty" incorrectly.

## Verification status
`tb/tb_top.sv` is a **directed-stimulus** testbench. It drives these scenarios:

1. Write-on-full: fill the FIFO, then keep writing.
2. Read-on-empty, followed by concurrent read/write bursts.
3. Asynchronous reset during operation, then a write/read after reset.

Results were checked manually by inspecting waveforms in GTKWave. **The testbench is not self-checking yet**: it does not compare read data against written data, so it prints "completed", not "passed".

Only one configuration is exercised: `DATA_WIDTH=4`, `ADDR_WIDTH=4`, with `wclk` (100 MHz) faster than `rclk` (~43 MHz).

## Known limitations and next steps
- [ ] Self-checking scoreboard (queue-based reference model, accounting for the 1-cycle read latency)
- [ ] Randomized traffic and clock ratios in both directions (read faster than write)
- [ ] SystemVerilog assertions, e.g. Gray pointers change by at most one bit per cycle, no pointer movement on write-when-full / read-when-empty
- [ ] Simple functional coverage (full reached, empty reached, simultaneous read/write)
- [ ] Reset synchronizers: resets are currently asserted and released asynchronously with no synchronization on release
- [ ] UVM version of the testbench

## Use of AI tools
AI tools (LLMs) were used to discuss CDC design practices, to generate the initial testbench structure, and as a debugging aid. Results were checked by waveform analysis. Testbench timing was later corrected to avoid a race between TB drives and DUT sampling.

## Toolchain
* SystemVerilog (IEEE 1800-2012)
* Icarus Verilog (`iverilog`) on WSL (Ubuntu)
* GTKWave

## How to run
```bash
iverilog -g2012 -o sim.vvp rtl/*.sv tb/tb_top.sv
vvp sim.vvp
gtkwave dump.vcd &
```

## Reference
C. E. Cummings, "Simulation and Synthesis Techniques for Asynchronous FIFO Design", SNUG 2002.
