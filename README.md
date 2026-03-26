# Async FIFO in Verilog

This project implements an asynchronous FIFO in Verilog with independent write and read clock domains. The design uses Gray-coded pointers and two-stage synchronizers so the FIFO status logic can safely compare pointers across clock boundaries.

The included Vivado project was created with `Vivado v2022.2`, and the current project file targets `xc7z010iclg225-1L`.

## Overview

The FIFO is built from small modules with clear responsibilities:

- `TOP` connects the full FIFO datapath and control logic.
- `wrptr_full` manages the write pointer and generates the `full` flag.
- `rdptr_empty` manages the read pointer and generates the `empty` flag.
- `sync` is a two-flop synchronizer used for Gray-coded pointer transfer between clock domains.
- `fifo_mem` stores FIFO data using the binary pointer address bits.
- `Async_FIFO_tb` is a behavioral testbench for basic functionality and corner cases.

## Design Summary

This FIFO separates storage, pointer control, and clock-domain crossing logic:

- Data is written in the write clock domain with `wr_clk`.
- Data is read in the read clock domain with `rd_clk`.
- Binary pointers are used for memory addressing.
- Gray-coded pointers are used for cross-domain synchronization.
- An extra pointer bit is used to detect wrap-around for `full` and `empty`.

The pointer width is derived from:

```verilog
PTR_WIDTH = $clog2(DEPTH) + 1;
```

## Default Parameters

| Parameter | Default | Description |
| --- | --- | --- |
| `DEPTH` | `16` | Number of FIFO entries |
| `DATA_WIDTH` | `8` | Width of the data bus |
| `PTR_WIDTH` | `$clog2(DEPTH) + 1` | Pointer width including wrap bit |

## Module Map

| File | Role |
| --- | --- |
| `Async_FIFO.srcs/sources_1/new/TOP.v` | Top-level FIFO wrapper |
| `Async_FIFO.srcs/sources_1/new/sync.v` | Two-flop Gray-pointer synchronizer |
| `Async_FIFO.srcs/sources_1/new/wrptr_full.v` | Write pointer and full detection |
| `Async_FIFO.srcs/sources_1/new/rdptr_empty.v` | Read pointer and empty detection |
| `Async_FIFO.srcs/sources_1/new/fifo_mem.v` | FIFO storage array |
| `Async_FIFO.srcs/sim_1/new/Async_FIFO_tb.v` | Behavioral testbench |

## Repository Layout

```text
.
|-- Async_FIFO.xpr
|-- Async_FIFO_tb_behav.wcfg
|-- Async_FIFO.srcs
|   |-- sources_1/new
|   |   |-- TOP.v
|   |   |-- sync.v
|   |   |-- wrptr_full.v
|   |   |-- rdptr_empty.v
|   |   `-- fifo_mem.v
|   `-- sim_1/new
|       `-- Async_FIFO_tb.v
`-- Async_FIFO.sim/sim_1/behav/xsim
    |-- compile.bat
    |-- elaborate.bat
    |-- simulate.bat
    `-- Async_FIFO_tb.tcl
```

## Testbench Coverage

The testbench currently exercises three basic scenarios:

1. Write data and read it back.
2. Fill the FIFO and attempt extra writes to check `full`.
3. Empty the FIFO and attempt extra reads to check `empty`.

The clocks are intentionally different to emulate asynchronous behavior:

- `wr_clk`: toggles every `5 ns`
- `rd_clk`: toggles every `10 ns`

The simulation TCL script runs the design for `1000 ns`.

## How to Run Simulation

### Option 1: Vivado GUI

1. Open `Async_FIFO.xpr` in Vivado 2022.2.
2. Select the simulation source set containing `Async_FIFO_tb.v`.
3. Run Behavioral Simulation.
4. Vivado can open the saved waveform configuration from `Async_FIFO_tb_behav.wcfg`.

### Option 2: Generated XSim scripts

Make sure Vivado tools are available in your terminal environment, then run:

```bat
cd Async_FIFO.sim\sim_1\behav\xsim
compile.bat
elaborate.bat
simulate.bat
```

## Notes

- The FIFO memory currently uses a combinational read path in `fifo_mem.v`.
- Both resets are active-low: `wr_rst_n` and `rd_rst_n`.
- The top-level module name is `TOP`.

## Screenshots

This README is ready for project images. Good additions would be:

- FIFO block diagram
- Behavioral waveform screenshot
- Vivado simulation window

Send me the images you want to use, and I can embed them directly into this README.
