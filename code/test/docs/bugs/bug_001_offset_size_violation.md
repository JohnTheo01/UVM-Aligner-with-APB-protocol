# Bug #001 — Illegal Size/Offset Combination Not Rejected

**Date Found**: 2026-05-03

## Description
The RTL accepts size/offset combinations where size + offset > data_width/8,
which exceeds the physical bus capacity.

## Example
- data_width = 32 (4 bytes)
- size = 5, offset = 1
- Satisfies (data_width/8 + offset) % size == 0 ✓
- But requires 6 bytes on a 4-byte bus ✗

## How It Was Found
Detected by constrained random test `cfs_algn_test_reg_access`
during register model integration.

## Fix
Added boundary check in `cfs_regs.sv` (line 210):
if the sum of the written offset and size exceeds the physical bus width
(`ALIGN_DATA_WIDTH / 8`), the write is flagged as illegal
(`wr_ctrl_is_illegal`) and the APB transfer is terminated.

## Notes
The assertion detecting this violation was disabled in this playground
to allow the simulation to complete and demonstrate the incorrect behavior
in the MD TX agent monitored items.

## Live Demo
[EDA Playground](https://edaplayground.com/x/F9m6)