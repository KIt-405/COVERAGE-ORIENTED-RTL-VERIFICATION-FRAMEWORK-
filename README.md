# Parameterized RTL FIFO & Advanced SystemVerilog Verification Environment

## 📌 Project Overview
This repository features a production-grade, parameterized synchronous FIFO (First-In, First-Out) memory buffer designed in synthesizable SystemVerilog, paired with a modern, object-oriented (OOP) verification environment. Moving beyond legacy linear testbenches, this framework utilizes **Constrained-Random Verification (CRV)**, **SystemVerilog Assertions (SVA)**, and a dynamic **Scoreboard Reference Model** to guarantee total data integrity and design robustness.

This architecture serves as a showcase of modern Design Verification (DV) methodology, proving state and protocol coverage scientifically via automated toolchain metrics and automated Python regression post-processing rather than manual waveform inspection.

---

## 🛠️ System Architecture

The verification environment completely decouples stimulus generation, driving mechanics, checking, and hardware tracking into independent structural layers connected via a virtual interface.

```text
       +-------------------------------------------------------------+
       |                  Testbench Top Module                       |
       |                                                             |
       |  +-------------------------------------------------------+  |
       |  |                 Generator & Driver                    |  |
       |  |       (OOP Constrained-Random Stimulus - CRV)         |  |
       |  +---------------------------|---------------------------+  |
       |                              | (Virtual Interface)          |
       |                              v                              |
       |  +-------------------------------------------------------+  |
       |  |               SystemVerilog Interface                 |  |
       |  |             (Clocking Block Protection)               |  |
       |  +---------------------------|---------------------------+  |
       |               |              |              |               |
       |               v              v              v               |
       |        +------------+ +------------+ +--------------+       |
       |        | SystemVeri-| |  Hardware  | |  Reference   |       |
       |        | log Asser- | |  DUT (RTL) | |  Scoreboard  |       |
       |        | tions(SVA) | | (Param FIFO) | (Data Queue) |       |
       |        +------------+ +------------+ +--------------+       |
       |                              |                              |
       |                              v                              |
       |  +-------------------------------------------------------+  |
       |  |                 Functional Coverage                   |  |
       |  |               (Covergroups & Monitors)                |  |
       |  +---------------------------|---------------------------+  |
       +------------------------------|------------------------------+
                                      v
       +-------------------------------------------------------------+
       |             Python Log Automation Pipeline                  |
       |     (Regex Parsing, Target Tracking & Report Generation)    |
       +-------------------------------------------------------------+
