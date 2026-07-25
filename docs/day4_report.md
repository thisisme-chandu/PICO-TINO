# PICO-TINO Day 4 Report

## Objective

Integrate the datapath, control FSM and external memory interfaces into
the first complete working PICO-TINO processor.

## Test Program

```text
LOADI R1, 5
LOADI R2, 3
ADD   R1, R2
STORE R1, [0x20]
HALT

```

## Machine Code

```text
0405
0803
1600
6420
8000
```

## Expected Result

```text
R1 = 8
R2 = 3
dmem[0x20] = 8
halted = 1
```

## Actual Result

```text
PASS: Processor reached HALT.
PASS: dmem[0x20] = 08
PICO-TINO CORE TEST: PASS
```

## Verification

| Check | Status |
|---|---|
| Full RTL compilation | PASS |
| Instruction fetch | PASS |
| LOADI execution | PASS |
| ADD execution | PASS |
| STORE execution | PASS |
| HALT execution | PASS |
| Data-memory result | PASS |
| Waveform generation | PASS |

## Day 4 Status

PASS



