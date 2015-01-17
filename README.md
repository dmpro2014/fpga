VHDL implementation of Demolicious' custom GPU
===============

This is a Xilinx ISE project with all the VHDL source code that implements our custom GPU.

For a general introduction to this project, please read/skim the [report](https://github.com/dmpro2014/report).

The GPU has been tested on an FPGA and can execute kernels on hundreds of thousands of threads 
and generate visual output over HDMI.

The majority of the code is the "hardware" directory. 

The top level module is System.vhdl, which contains four important modules: 
The Communication Module that communicates over EBI with the CPU of the computer.
The Video Module which is our HDMI implementation. (It might be a useful resource for anyone looking for HDMI in VHDL)
The SRAM Arbiter which controls access to the memory.
And finally the "ghettocuda" module, which is the implementation of the GPU architecture.
