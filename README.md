# RTL Ethernet Physical Layer

Parametrisable implementation of the ethernet physical layer's PCS for **10GBASE-R** and **40GBASE-R**.
 
## Roadmap

10GBASE-R:

[ ] 16b wide data path, very low latency
[x] 64b wide data path, no latency requirement

40GBASE-R:

[x] 4 lanes, 256b wide data path, no latency requirement

## Features not supported

- MDIO

- RS - Reconsiliation Sublayer

- WIS - WAN Interface Sublayer

- EEE - Ethernet Energy Efficiency 

## Testing

For more information on the testbenches and how to run them see the [README in the tb director](tb/README.md).

# License 

This code uses the MIT license, all rights belong to Julia Desmazes.

