# Data Transfer FSM (Dual-Port RAM Controller)

## Overview
This project implements a **Finite State Machine (FSM)** that controls **data transfer between two asynchronous dual-port RAM modules**.  
It reads bytes sequentially from an input memory (`RAM_IN`), pairs two bytes together, and writes them as a 16-bit word into an output memory (`RAM_OUT`).

This design demonstrates **memory interfacing**, **state-based control**, and **data width transformation (8-bit → 16-bit)** in Verilog.

---

## Tools Used
- **Icarus Verilog (iverilog)** – Simulation  
- **VS Code** – Code editing and project organization  
- *(Waveform analysis using GTKWave can be added later)*  

---

## Functional Description

###  FSM States
| State | Description | Operation |
|:------|:-------------|:-----------|
| **IDLE** | Waits for `opmode_in` to start data transfer | Idle |
| **READ_BY0** | Reads the first byte from input RAM | Stores in buffer |
| **READ_BY1** | Reads the next byte from input RAM | Prepares 2nd byte |
| **WRITE_BY12** | Combines two bytes and writes to output RAM | 16-bit write operation |

---

###  Memory Details
- **Input Memory (RAM_IN)**  
  - 8-bit wide × 32 locations  
  - Data is written externally using `ram_in_we`, `ram_in_addr_wr`, and `ram_in_data_wr`

- **Output Memory (RAM_OUT)**  
  - 16-bit wide × 16 locations  
  - Data is written by FSM during the `WRITE_BY12` state  

---

##  Operation Summary
1. On `opmode_in = 1`, FSM starts transferring data.  
2. Reads two consecutive bytes from `RAM_IN`.  
3. Combines them into one 16-bit word.  
4. Writes it to `RAM_OUT`.  
5. Repeats until all 32 bytes are processed (`done_out = 1`).  

---

##  Learning Takeaways
- FSM-based control for memory transfer  
- Data width conversion between memories  
- Dual-port RAM interfacing  
- Sequential state design and synchronization  

---
This project successfully showcases efficient data handling and width conversion using an FSM, highlighting the practical use of Verilog-based memory interfacing and sequential control logic.

  




