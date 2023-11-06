# RTL Ethernet Physical Layer

Parametrisable implementation of the Ethernet physical layer's PCS for **10GBASE-R** and **40GBASE-R**.

RTL is platform agnostic but current synthesis flow target's the Intel **Cyclone 10 GX** FPGA series.

## Quickstart

Pre-requisite : 
Have `quartus` installed, and set in `PATH`. 

This quickstart will create test project for the `10CX150YF780E5G` part with a
`10GBASE-R` PCS and `40GBASE-R` PCS in loop-back mode on transceiver bank `1D`.

![Basic shematics of loopback!](/doc/quickstart.svg)

To create a new quartus project, and run lint, synthesize, and check timing and
then assemble; in the `tcl` directory run : 
```sh
make build 
```

A project named `PCS.qsf` will be created in the `tcl` directory and all logs, including timing
will be in the `tcl/PCS` directory.

### Quartus versions other then 22.3

This project was build for `quartus 22,3`, compatibility issues with the intel `IP` might
arise with other versions, to force compatibility use the `compat` argument.

```sh
make build compat=1
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

