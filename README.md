# Project Overview: Spartan-6 FPGA DSP48A1 Slice

## Outline
This project involves designing and implementing the DSP48A1 slice of the Spartan-6 FPGA using Verilog. The DSP48A1 slice is a critical component for digital signal processing, enabling high-performance mathematical computations essential in various applications. This documentation outlines the design specifications, implementation details, simulation results, and references used.

## Tools
- Questasim
- Xilinx Vivado

## Design Specifications

The design of the DSP48A1 slice in the Spartan-6 FPGA involves several critical components and configurations, outlined as follows:

### Parameters and Attributes
- **Pipeline Registers**: Parameters such as `A0REG`, `A1REG`, `B0REG`, `B1REG`, `CREG`, `DREG`, `MREG`, `PREG`, `CARRYINREG`, `CARRYOUTREG`, and `OPMODEREG` define the number of pipeline stages, typically defaulting to 1 (registered).
- **Carry Cascade**: The `CARRYINSEL` attribute determines the source of the carry-in, defaulting to `OPMODE5`.
- **Input Routing**: `B_INPUT` controls whether the B input is directly from the port or cascaded from an adjacent slice.
- **Reset Type**: The `RSTTYPE` attribute selects synchronous or asynchronous resets, defaulting to synchronous.

### Data Ports
- **`A`, `B`, `D` (18-bit)**: Data inputs for multiplication and pre/post addition/subtraction.
- **`C` (48-bit)**: Data input to the post-adder/subtracter.
- **`CARRYIN`**: Input for carry-in to the adder/subtracter.
- **`M` (36-bit)**: Buffered multiplier output.
- **`P` (48-bit)**: Primary output from the adder/subtracter.
- **`CARRYOUT`, `CARRYOUTF`**: Cascade and logic carry-out signals.

### Control Input Ports
- **`CLK`**: Clock signal.
- **`OPMODE`**: Control signal for arithmetic operation selection.

### Clock Enable Input Ports
- **`CEA`, `CEB`, `CEC`, `CECARRYIN`, `CED`, `CEM`, `CEOPMODE`, `CEP`**: Clock enable signals for various registers.

### Reset Input Ports
- **`RSTA`, `RSTB`, `RSTC`, `RSTCARRYIN`, `RSTD`, `RSTM`, `RSTOPMODE`, `RSTP`**: Active-high reset signals, either synchronous or asynchronous.

### Cascade Ports
- **`BCOUT`, `PCIN`, `PCOUT`**: Ports for cascading data between adjacent DSP48A1 slices.


## Overall Block Diagram 
<p align="center">
    <img src="https://github.com/Yousseffekramy/Spartan-6-FPGA-DSP48A1-Slice/blob/master/Block%20Diagram.png" alt="Block Diagram">
</p>

## Codes
- [Design Codes](/01_Verilog%20Design)
- [Testbench Codes](/02_Verolog%20Testbench)

## Results

### Waveform
* [Testbench Waveform](/03_Waveform%20Snippets)

### Elaboration
* [Elaboration](04_Elaboration%20Design/RTL_Schematic.png)
<p align="center">
    <img src="https://github.com/Yousseffekramy/Spartan-6-FPGA-DSP48A1-Slice/blob/master/04_Elaboration%20Design/RTL_Schematic.png" alt="RTL Schematic">
</p>

### Synthesis
* [Messages Tab](05_Synthesis/Messages_Panel.xlsx)
* [Synthesis Schematic](05_Synthesis/Synthesis_Schematic.png)
* [Utilization Report](05_Synthesis/Utilization%20Report.txt)
* [Timing Report](05_Synthesis/timing_Report.txt)

### Implementation
* [Power Analysis](06_Implementation/Power%20Analysis.pwr)
* [Implementation Schematic](06_Implementation/implementation.pdf)
* [Utilization Report](06_Implementation/Utilization_Report.txt)
* [Timing Report](06_Implementation/timing_Report.txt)

## Resources 
This comprehensive specification ensures the DSP48A1 slice is optimally configured for high-performance digital signal processing applications within the Spartan-6 FPGA. For more info, refer to the original doc [Spartan-6 FPGA DSP484A1 Slice (User Guide)](https://docs.amd.com/v/u/en-US/ug389).


