# PICO-TINO

PICO-TINO is a tiny 8-bit multi-cycle processor created to understand
the complete open-source RTL-to-GDSII journey before developing TINO-MC45.

## Architecture

- 8-bit datapath
- 16-bit instructions
- Four 8-bit registers
- 8-bit address space
- Multi-cycle FSM
- External instruction and data memories
- No pipeline or cache

## Toolchain

- Verilog-2001
- Verilator
- GTKWave
- Yosys
- OpenSTA
- OpenROAD Flow Scripts
- Nangate45

## Flow

RTL → Simulation → Synthesis → STA → Floorplan → Placement → CTS → Routing → GDSII

## Workspace

`/mnt/d/projects/PICO-TINO`
