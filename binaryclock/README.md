# Binary Clock

## What it is

A binary clock built on a custom-made PCB. The time is displayed in binary
using LEDs, with the control logic running on a microcontroller.

## Hardware

- **Custom PCB:** Designed from scratch on a copper board
- **Design files:** KiCad project included in this repository
- **Microcontroller:** ATMEGA48
- **Not runnable locally:** The code targets the specific custom board and
  cannot run on standard hardware.

## Contents

| Folder | Description |
|---|---|
| `[kiCad/]` | KiCad project (schematic + PCB layout) |
| `[src/]` | Microcontroller code |
| `[other/]` | Photos, schematics, notes |

## How it works

The clock is driven by a quartz crystal for accurate timekeeping. It can be set via UART and additionally features a built-in stopwatch.


## What I learned
- Designing a PCB from schematic to finished board (KiCad)
- Soldering and hardware prototyping
- Programming a microcontroller for a physical device
