# FPGA-Based Digital Key Lock System with Configurable Security

**A synchronous digital security system implemented on Artix-7 FPGA, featuring runtime password configuration and a robust verification testbench.**

This project simulates a real-world access control mechanism. Unlike standard hard-coded locks, this system allows the user to overwrite the default security code during operation, utilizing internal register manipulation and a generic Moore Finite State Machine (FSM).

---

## 🛠️ Technical Specifications
* **Hardware:** Xilinx Artix-7 FPGA (Basys 3 Development Board).
* **Language:** VHDL (IEEE 1076).
* **Toolchain:** Xilinx Vivado ML Standard.
* **Keypad Driver:** 4x4 Matrix scanning (1 kHz) with **20ms debounce algorithm** for noise filtering.
* **Architecture:** Modular design separating the Hardware Driver (Keypad Controller) from the Control Logic (FSM).

---

## 🧠 System Architecture

### 1. The Datapath & Registers
The system utilizes a register-based datapath to allow for **Runtime Configuration**.
* **Storage:** Parallel registers store the "Master Key" (Default: 1-3-5-7).
* **Comparison:** A real-time comparator matches the 4-bit user input against the stored register values.
* **Security:** If the user enters the correct sequence followed by `*`, the system enters **Programming Mode**, allowing the `Master Key` registers to be rewritten.

![System Architecture](docs/system_architecture.png)
*(Figure 1: Datapath design showing register logic and comparator flow)*

### 2. Finite State Machine (Moore)
The control logic is governed by a **Moore Machine**, where outputs depend solely on the current state to ensure stability.
* **`S_IDLE`**: System Locked (Red LED).
* **`S_READ`**: Captures user input sequences.
* **`S_SET_KEY`**: Configuration mode to write new passwords to registers.
* **`S_UNLOCKED`**: Access Granted (Green LED) with a 0.5s hold timer.

![State Diagram](docs/fsm_state_diagram.png)
*(Figure 2: FSM State Transition Diagram)*

---

## 🔍 Verification & Simulation Strategy

Verification was conducted using a comprehensive Test Bench (`Top_Level_tb`) covering 4 critical scenarios over a 2500ms simulation run:

1.  **Integrity Test:** Validated unlocking with the default factory code (1-3-5-7). -> **PASSED**
2.  **Configuration Test:** Verified the ability to enter Programming Mode and update the password registers to a new code (e.g., 2-4-6-8). -> **PASSED**
3.  **Security Test:** Attempted to unlock using the *old* password after the update to ensure it was rejected. -> **PASSED**
4.  **Validation Test:** Unlocked the system using the *newly configured* password. -> **PASSED**

![Simulation Waveforms](docs/simulation_waveforms.png)
*(Figure 3: Behavioral Simulation results in Vivado verifying state transitions)*

---

## 📂 Project Structure
* **`src/`**: Synthesizable VHDL source files (Top_Level, keypad_controller, fsm_controller).
* **`sim/`**: Testbench files for behavioral simulation.
* **`constraints/`**: XDC file mapping I/O to the Basys 3 board.
* **`bitstream/`**: Generated `.bit` file for direct FPGA programming.
* **`docs/`**: Schematic diagrams and architecture sketches.
* **`Full_Project_Report.pdf`**: Complete engineering documentation.
