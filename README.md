# RTL Ethernet Physical Layer

Parametrisable implementation of the ethernet physical layer's PCS for **10GBASE-R** and **40GBASE-R**.

RTL is platform agnostic but current synthesis flow target's the Intel **Cyclone 10 GX** FPGA series.

## Quickstart

I would recommend checking out the latest stable tag.

Pre-requisite : 
Have a working version of `verilator` installed and follow the 
[instructions set the path to your simulators vpi library](/tb/README.md#vpi).

To build and run the top level testbench:
```
make clean
make SIM=V run_pcs
```

Open the waves, here we are using `gtkwave` as our viewer :
```
gtkwave wave/pcs_tb.vcd
```

## Roadmap

10GBASE-R:

- [ ] 16b wide data path, very low latency

- [x] 64b wide data path, low latency requirement

40GBASE-R:

- [x] 4 lanes, 256b wide data path, no latency requirement

## Features not supported

- MDIO

- RS - Reconciliation Sublayer

- WIS - WAN Interface Sublayer

- EEE - Ethernet Energy Efficiency 

## Testing

For more information on the testbenches and how to run them see the [README in the tb director](tb/README.md).

# License 

This code uses the MIT license, all rights belong to Julia Desmazes.

