# HWPV7 - Writing a fullduplex protocol

## What it is
Practical coursework for the university hardware course.
The project targets the university's internal PCB boards and is not runnable
on standard hardware.

## Environment
- **Target:** University-internal PCB boards
- **Written in:** C++
- **Not runnable locally:** The code depends on the specific board and its
  peripheral setup, which is only available in the university lab.

## Contents
| File/Folder | Description |
|---|---|
| `protocol.cpp` | full duplex synchronous protocol |

## How it works

On an 8-Bit bus, the protocol simultaneously sends and receives 3 bits. The next cycle the protocol sends and receives inverted bits and checks if the received bits are inverted of the previously received bits. If not, it sends a re-send signal. If a resend is requested, it discards the previously received bits. After, it sends the next three bits.

## What I learned

- Embedded programming close to the hardware
- Register-level I/O and timing
- How do protocols work and how to implement my own version
